import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/ble/ble_repository.dart';
import '../../features/scanner/bloc/scanner_event.dart';
import '../../features/scanner/models/scanned_device.dart';
import '../../features/scanner/view/scanner_screen.dart';
import '../../features/device_detail/bloc/device_event.dart';
import '../../features/device_detail/view/device_detail_screen.dart';

abstract final class AppRouter {
  static GoRouter create(BleRepository repository) => GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => BlocProvider(
              create: (_) => ScannerBloc(repository: repository),
              child: const ScannerScreen(),
            ),
          ),
          GoRoute(
            path: '/device/:id',
            builder: (context, state) {
              final device = state.extra! as ScannedDevice;
              return BlocProvider(
                create: (_) => DeviceBloc(repository: repository)
                  ..add(ConnectDevice(device.id)),
                child: DeviceDetailScreen(device: device),
              );
            },
          ),
        ],
      );
}
