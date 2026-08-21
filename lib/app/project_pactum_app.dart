import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../navigation/app_router.dart';

class ProjectPactumApp extends ConsumerWidget {
  const ProjectPactumApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Project Pactum',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.light,
    );
  }
}
