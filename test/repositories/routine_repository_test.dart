import 'package:flutter_test/flutter_test.dart';
import 'package:project_pactum/models/routine_task.dart';
import 'package:project_pactum/repositories/routine_repository.dart';
import 'package:project_pactum/services/local_storage_service.dart';

void main() {
  test(
    'inicia sin tareas hardcodeadas cuando no hay rutina guardada',
    () async {
      final repository = RoutineRepository(_MemoryStorageService());

      final tasks = await repository.getTasks();

      expect(tasks, isEmpty);
    },
  );

  test(
    'agrega, edita, marca, elimina y persiste tareas personalizadas',
    () async {
      final storage = _MemoryStorageService();
      final repository = RoutineRepository(storage);
      final createdAt = DateTime(2026, 6, 29, 8);

      await repository.addTask(
        RoutineTask(
          id: 'task-1',
          title: 'Caminar 15 minutos',
          category: RoutineCategory.morning,
          isCompleted: false,
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      );

      final afterAdd = await repository.getTasks();
      expect(afterAdd, hasLength(1));
      expect(afterAdd.single.category, RoutineCategory.morning);

      await repository.toggleTaskCompletion('task-1');
      final afterToggle = await repository.getTasks();
      expect(afterToggle.single.isCompleted, isTrue);

      await repository.updateTask(
        afterToggle.single.copyWith(
          title: 'Caminar 20 minutos',
          category: RoutineCategory.afternoon,
        ),
      );
      final afterEdit = await repository.getTasks();
      expect(afterEdit.single.title, 'Caminar 20 minutos');
      expect(afterEdit.single.category, RoutineCategory.afternoon);
      expect(afterEdit.single.isCompleted, isTrue);

      final restoredRepository = RoutineRepository(storage);
      final restored = await restoredRepository.getTasks();
      expect(restored.single.title, 'Caminar 20 minutos');
      expect(restored.single.isCompleted, isTrue);

      await restoredRepository.deleteTask('task-1');
      expect(await restoredRepository.getTasks(), isEmpty);
    },
  );

  test('rechaza títulos vacíos e identificadores duplicados', () async {
    final repository = RoutineRepository(_MemoryStorageService());
    final now = DateTime(2026, 6, 29);
    final task = RoutineTask(
      id: 'task-1',
      title: 'Hidratarse',
      category: RoutineCategory.morning,
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
    );

    await repository.addTask(task);

    await expectLater(repository.addTask(task), throwsA(isA<StateError>()));
    await expectLater(
      repository.addTask(task.copyWith(id: 'task-2', title: '   ')),
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
