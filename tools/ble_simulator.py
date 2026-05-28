"""
BLE peripheral simulator using macOS CoreBluetooth via pyobjc.

Advertises a custom service with one notifiable characteristic
that sends a simulated temperature value (float32 LE) at 1 Hz.

Usage:
    pip install -r tools/requirements.txt
    python3 tools/ble_simulator.py

Service UUID:  12345678-0000-1000-8000-00805F9B34FB
Char UUID:     12345678-0001-1000-8000-00805F9B34FB
Value format:  4-byte IEEE 754 float (little-endian), e.g. 23.5 degrees C
"""

import math
import signal
import struct
import logging
import threading
import time

import objc
from Foundation import NSObject, NSData, NSRunLoop, NSDate
from CoreBluetooth import (
    CBPeripheralManager,
    CBMutableService,
    CBMutableCharacteristic,
    CBUUID,
    CBAdvertisementDataLocalNameKey,
    CBAdvertisementDataServiceUUIDsKey,
)

# CoreBluetooth property / permission bit flags
_PROP_READ   = 0x02
_PROP_NOTIFY = 0x10
_PERM_READ   = 0x01

SERVICE_UUID = "12345678-0000-1000-8000-00805F9B34FB"
CHAR_UUID    = "12345678-0001-1000-8000-00805F9B34FB"
DEVICE_NAME  = "BLE-Simulator"

logging.basicConfig(level=logging.INFO, format="%(asctime)s  %(message)s")
log = logging.getLogger(__name__)


class _Delegate(NSObject):
    """CoreBluetooth CBPeripheralManagerDelegate."""

    def init(self):
        self = objc.super(_Delegate, self).init()
        if self is None:
            return None
        self._manager = None
        self._char    = None
        self._ready   = threading.Event()
        return self

    # ------------------------------------------------------------------
    # Delegate callbacks
    # ------------------------------------------------------------------

    def peripheralManagerDidUpdateState_(self, manager):
        # CBManagerState: 4=poweredOff, 5=poweredOn
        if manager.state() == 5:
            self._setup_service()

    def peripheralManager_didAddService_error_(self, manager, service, error):
        if error:
            log.error("Failed to add service: %s", error)
            return
        manager.startAdvertising_({
            CBAdvertisementDataLocalNameKey:    DEVICE_NAME,
            CBAdvertisementDataServiceUUIDsKey: [CBUUID.UUIDWithString_(SERVICE_UUID)],
        })
        log.info("Advertising as '%s'", DEVICE_NAME)
        log.info("Service UUID : %s", SERVICE_UUID)
        log.info("Char UUID    : %s", CHAR_UUID)
        log.info("Press Ctrl+C to stop.")
        self._ready.set()

    def peripheralManager_didReceiveReadRequest_(self, manager, request):
        request.setValue_(self._char.value())
        manager.respondToRequest_withResult_(request, 0)  # CBATTErrorSuccess

    def peripheralManager_central_didSubscribeToCharacteristic_(
        self, manager, central, characteristic
    ):
        log.info("Central subscribed: %s", central.identifier())

    def peripheralManager_central_didUnsubscribeFromCharacteristic_(
        self, manager, central, characteristic
    ):
        log.info("Central unsubscribed.")

    # ------------------------------------------------------------------
    # Internal helpers
    # ------------------------------------------------------------------

    @objc.python_method
    def _setup_service(self):
        init_value = NSData.dataWithBytes_length_(struct.pack("<f", 20.0), 4)
        self._char = CBMutableCharacteristic.alloc().initWithType_properties_value_permissions_(
            CBUUID.UUIDWithString_(CHAR_UUID),
            _PROP_READ | _PROP_NOTIFY,
            init_value,
            _PERM_READ,
        )
        service = CBMutableService.alloc().initWithType_primary_(
            CBUUID.UUIDWithString_(SERVICE_UUID), True
        )
        service.setCharacteristics_([self._char])
        self._manager.addService_(service)

    @objc.python_method
    def notify(self, value_bytes: bytes) -> None:
        data = NSData.dataWithBytes_length_(value_bytes, len(value_bytes))
        self._char.setValue_(data)
        self._manager.updateValue_forCharacteristic_onSubscribedCentrals_(
            data, self._char, None
        )


def _run_loop_worker(stop_event: threading.Event) -> None:
    """Pump the CoreBluetooth run loop on this thread."""
    rl = NSRunLoop.currentRunLoop()
    while not stop_event.is_set():
        rl.runMode_beforeDate_(
            "NSDefaultRunLoopMode",
            NSDate.dateWithTimeIntervalSinceNow_(0.05),
        )


def main() -> None:
    stop = threading.Event()
    signal.signal(signal.SIGINT, lambda *_: stop.set())
    signal.signal(signal.SIGTERM, lambda *_: stop.set())

    delegate = _Delegate.alloc().init()
    delegate._manager = CBPeripheralManager.alloc().initWithDelegate_queue_options_(
        delegate, None, None
    )

    rl_thread = threading.Thread(target=_run_loop_worker, args=(stop,), daemon=True)
    rl_thread.start()

    log.info("Waiting for Bluetooth to power on...")
    if not delegate._ready.wait(timeout=15):
        log.error("Bluetooth did not become ready. Is it enabled on this Mac?")
        stop.set()
        return

    tick = 0
    while not stop.is_set():
        temperature = 20.0 + 5.0 * math.sin(tick * 0.3)
        payload = struct.pack("<f", temperature)
        delegate.notify(payload)
        log.info("Notify -> %.2f deg C  %s", temperature, payload.hex(" ").upper())
        tick += 1
        time.sleep(1.0)

    log.info("Stopping...")
    delegate._manager.stopAdvertising()
    delegate._manager.removeAllServices()


if __name__ == "__main__":
    main()
