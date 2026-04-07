import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class OmaoApp extends ConsumerWidget {
  const OmaoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MediaQuery.withClampedTextScaling(
      minScaleFactor: 1.0,
      maxScaleFactor: 1.0,
      child: MaterialApp.router(
        title: 'OMAO',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
