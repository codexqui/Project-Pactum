import 'package:flutter_test/flutter_test.dart';
import 'package:project_pactum/models/daily_review.dart';
import 'package:project_pactum/models/daily_review_metric.dart';
import 'package:project_pactum/repositories/daily_review_repository.dart';
import 'package:project_pactum/services/local_storage_service.dart';

void main() {
  test(
    'inicia sin categorías hardcodeadas cuando no hay configuración',
    () async {
      final repository = DailyReviewRepository(_MemoryStorageService());

      final metrics = await repository.getMetrics();

      expect(metrics, isEmpty);
    },
  );

  test('gestiona categorías personalizadas y puntuaciones dinámicas', () async {
    final storage = _MemoryStorageService();
    final repository = DailyReviewRepository(storage);
    final now = DateTime(2026, 6, 29, 8);

    await repository.addMetric(
      DailyReviewMetric(
        id: 'energy',
        title: 'Energía',
        score: 5,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await repository.addMetric(
      DailyReviewMetric(
        id: 'mood',
        title: 'Estado de ánimo',
        score: 5,
        createdAt: now,
        updatedAt: now,
      ),
    );

    await repository.updateScore('energy', 10);
    await repository.updateScore('mood', 6);
    await repository.updateMetric(
      (await repository.getMetrics()).last.copyWith(title: 'Ánimo'),
    );
    await repository.reorderMetrics(1, 0);

    final metrics = await repository.getMetrics();
    expect(metrics.map((metric) => metric.title), ['Ánimo', 'Energía']);
    expect(DailyReview.calculateAverage(metrics), 8);

    await repository.deleteMetric('energy');
    final afterDelete = await repository.getMetrics();
    expect(afterDelete, hasLength(1));
    expect(afterDelete.single.title, 'Ánimo');
  });

  test(
    'guarda una fotografía diaria independiente de cambios futuros',
    () async {
      final storage = _MemoryStorageService();
      final repository = DailyReviewRepository(storage);
      final now = DateTime(2026, 6, 29, 8);

      await repository.addMetric(
        DailyReviewMetric(
          id: 'focus',
          title: 'Enfoque',
          score: 5,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await repository.addMetric(
        DailyReviewMetric(
          id: 'stress',
          title: 'Estrés',
          score: 5,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await repository.updateScore('focus', 8);
      await repository.updateScore('stress', 4);

      final review = DailyReview.fromMetrics(
        date: DateTime(2026, 6, 28),
        metrics: await repository.getMetrics(),
        updatedAt: DateTime(2026, 6, 28, 22),
      );
      await repository.saveReview(review);

      await repository.deleteMetric('stress');
      await repository.updateScore('focus', 10);

      final restored = await repository.loadForDate(DateTime(2026, 6, 28));
      expect(restored.metrics.map((metric) => metric.title), [
        'Enfoque',
        'Estrés',
      ]);
      expect(restored.averageValue, 6);
      expect(restored.updatedAt, DateTime(2026, 6, 28, 22));
    },
  );

  test('rechaza nombres vacíos e ids duplicados', () async {
    final repository = DailyReviewRepository(_MemoryStorageService());
    final now = DateTime(2026, 6, 29);
    final metric = DailyReviewMetric(
      id: 'metric-1',
      title: 'Sueño',
      score: 5,
      createdAt: now,
      updatedAt: now,
    );

    await repository.addMetric(metric);

    await expectLater(repository.addMetric(metric), throwsA(isA<StateError>()));
    await expectLater(
      repository.addMetric(metric.copyWith(id: 'metric-2', title: '   ')),
      throwsA(isA<ArgumentError>()),
    );
  });
}

class _MemoryStorageService implements LocalStorageService {
  final values = <String, String>{};

  @override
  Future<String?> readString(String key) async => values[key];

  @override
  Future<void> writeString(String key, String value) async {
    values[key] = value;
  }
}
