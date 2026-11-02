import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tareas_app/main.dart';

Future<void> addTask(WidgetTester tester, String title) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField), title);
  await tester.tap(find.text('Guardar'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Agrega, edita y elimina la tarea seleccionada', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Sin tareas por ahora'), findsOneWidget);
    await addTask(tester, '  Comprar pan  ');
    await addTask(tester, 'Estudiar Flutter');
    expect(find.text('Comprar pan'), findsOneWidget);
    expect(find.text('2 pendientes de 2'), findsOneWidget);

    await tester.tap(find.byTooltip('Editar tarea').first);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, 'Comprar pan'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Comprar fruta');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Comprar pan'), findsNothing);
    expect(find.text('Comprar fruta'), findsOneWidget);
    expect(find.text('Estudiar Flutter'), findsOneWidget);

    await tester.tap(find.byTooltip('Eliminar tarea').first);
    await tester.pumpAndSettle();
    expect(find.text('Comprar fruta'), findsNothing);
    expect(find.text('Estudiar Flutter'), findsOneWidget);
    await tester.tap(find.text('Deshacer'));
    await tester.pumpAndSettle();
    expect(find.text('Comprar fruta'), findsOneWidget);

    await tester.tap(find.byTooltip('Eliminar tarea').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Eliminar tarea').first);
    await tester.pumpAndSettle();
    expect(find.text('Sin tareas por ahora'), findsOneWidget);
  });

  testWidgets('Rechaza nombres vacios y permite cancelar', (tester) async {
    await tester.pumpWidget(const MyApp());
    await addTask(tester, '   ');
    expect(find.text('Escribe una tarea'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Sin tareas por ahora'), findsOneWidget);

    await addTask(tester, 'Leer');
    await tester.tap(find.byTooltip('Editar tarea'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '   ');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Escribe una tarea'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Otro nombre');
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Leer'), findsOneWidget);
    expect(find.text('Otro nombre'), findsNothing);
  });

  testWidgets('Permite completar y reabrir tareas', (tester) async {
    await tester.pumpWidget(const MyApp());
    await addTask(tester, 'Leer');
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(find.text('0 pendientes de 1'), findsOneWidget);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(find.text('1 pendientes de 1'), findsOneWidget);
  });

  testWidgets('Filtra tareas y actualiza la lista al cambiar su estado', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await addTask(tester, 'Comprar pan');
    await addTask(tester, 'Leer');
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pendientes'));
    await tester.pumpAndSettle();
    expect(find.text('Comprar pan'), findsNothing);
    expect(find.text('Leer'), findsOneWidget);

    await tester.tap(find.text('Completadas'));
    await tester.pumpAndSettle();
    expect(find.text('Comprar pan'), findsOneWidget);
    expect(find.text('Leer'), findsNothing);
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(find.text('No hay tareas completadas'), findsOneWidget);

    await tester.tap(find.text('Pendientes'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(find.text('No hay tareas pendientes'), findsOneWidget);

    await tester.tap(find.text('Todas'));
    await tester.pumpAndSettle();
    expect(find.text('Comprar pan'), findsOneWidget);
    expect(find.text('Leer'), findsOneWidget);
  });

  testWidgets('Edita, elimina y restaura la tarea correcta con filtro activo', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await addTask(tester, 'Comprar pan');
    await addTask(tester, 'Leer');
    await tester.tap(find.byType(Checkbox).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Completadas'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Editar tarea'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Leer un libro');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Leer un libro'), findsOneWidget);

    await tester.tap(find.byTooltip('Eliminar tarea'));
    await tester.pumpAndSettle();
    expect(find.text('No hay tareas completadas'), findsOneWidget);
    await tester.tap(find.text('Deshacer'));
    await tester.pumpAndSettle();
    expect(find.text('Leer un libro'), findsOneWidget);

    await tester.tap(find.text('Todas'));
    await tester.pumpAndSettle();
    expect(find.text('Comprar pan'), findsOneWidget);
    expect(find.text('Leer un libro'), findsOneWidget);
  });

  testWidgets('Admite textos largos en una pantalla estrecha', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    await addTask(
      tester,
      'Preparar la lista de compras y revisar las tareas de toda la semana',
    );
    expect(find.byType(Checkbox), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
