"""
BLE peripheral simulator for testing the BLE Scanner app.

Advertises a custom service with one notifiable characteristic
that cycles a simulated temperature sensor value (float32) at 1 Hz.

Usage:
    pip install -r tools/requirements.txt
    python tools/ble_simulator.py

Service UUID:  12345678-0000-1000-8000-00805F9B34FB
Char UUID:     12345678-0001-1000-8000-00805F9B34FB
Value format:  4-byte IEEE 754 float (little-endian), e.g. 23.5°C
"""

import asyncio
import logging
import struct
import math
from typing import Any

from bless import (
    BlessServer,
    BlessGATTCharacteristic,
    GATTCharacteristicProperties,
    GATTAttributePermissions,
)

SERVICE_UUID = "12345678-0000-1000-8000-00805F9B34FB"
CHAR_UUID = "12345678-0001-1000-8000-00805F9B34FB"
DEVICE_NAME = "BLE-Simulator"

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def read_request(characteristic: BlessGATTCharacteristic, **kwargs) -> bytearray:
    return characteristic.value


def write_request(
    characteristic: BlessGATTCharacteristic, value: Any, **kwargs
) -> None:
    characteristic.value = value
    logger.info("Write received: %s", list(value))


async def run():
    server = BlessServer(name=DEVICE_NAME)
    server.read_request_func = read_request
    server.write_request_func = write_request

    await server.add_new_service(SERVICE_UUID)

    char_flags = (
        GATTCharacteristicProperties.read
        | GATTCharacteristicProperties.write
        | GATTCharacteristicProperties.notify
    )
    permissions = (
        GATTAttributePermissions.readable | GATTAttributePermissions.writeable
    )

    initial_value = bytearray(struct.pack("<f", 20.0))
    await server.add_new_characteristic(
        SERVICE_UUID,
        CHAR_UUID,
        char_flags,
        initial_value,
        permissions,
    )

    await server.start()
    logger.info("Advertising as '%s'", DEVICE_NAME)
    logger.info("Service UUID : %s", SERVICE_UUID)
    logger.info("Char UUID    : %s", CHAR_UUID)
    logger.info("Press Ctrl+C to stop.")

    tick = 0
    try:
        while True:
            await asyncio.sleep(1.0)
            temperature = 20.0 + 5.0 * math.sin(tick * 0.3)
            payload = bytearray(struct.pack("<f", temperature))
            server.get_characteristic(CHAR_UUID).value = payload
            server.update_value(SERVICE_UUID, CHAR_UUID)
            logger.info("Notify → %.2f °C  %s", temperature, payload.hex(" ").upper())
            tick += 1
    except KeyboardInterrupt:
        logger.info("Stopping server…")
    finally:
        await server.stop()


if __name__ == "__main__":
    asyncio.run(run())
