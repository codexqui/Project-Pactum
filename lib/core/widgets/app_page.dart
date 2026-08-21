import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';
import 'page_header.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    required this.title,
    required this.subtitle,
    required this.children,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppLayout.pagePadding,
              AppSpacing.xl,
              AppLayout.pagePadding,
              AppSpacing.xxl,
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppLayout.maxContentWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PageHeader(title: title, subtitle: subtitle),
                    const SizedBox(height: AppSpacing.xl),
                    ...children,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
