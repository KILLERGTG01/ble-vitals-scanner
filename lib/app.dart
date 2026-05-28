import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'core/ble/ble_repository.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class App extends HookWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<BleRepository>();
    final router = useMemoized(() => AppRouter.create(repository));

    return MaterialApp.router(
      title: 'BLE Scanner',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
