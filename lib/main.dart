import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'core/ble/ble_repository.dart';
import 'core/permissions/permission_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => BleRepository()),
        RepositoryProvider(create: (_) => PermissionService()),
      ],
      child: const App(),
    ),
  );
}
