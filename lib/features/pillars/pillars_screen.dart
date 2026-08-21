import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/async_state_views.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/pillar_card.dart';
import '../../providers/pillars_provider.dart';

class PillarsScreen extends ConsumerWidget {
  const PillarsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pillars = ref.watch(pillarsProvider);

    return pillars.when(
      data: (items) => AppPage(
        title: 'Pilares',
        subtitle: 'Fundamentos de control personal',
        children: [
          if (items.isEmpty)
            const EmptyState(message: 'Aún no hay pilares configurados.'),
          for (final pillar in items) ...[
            PillarCard(pillar: pillar),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
      loading: LoadingView.new,
      error: (error, stackTrace) => ErrorView(
        message: 'No se pudieron cargar los pilares.',
        onRetry: () => ref.invalidate(pillarsProvider),
      ),
    );
  }
}
