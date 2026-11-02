# tareas_app

Aplicacion Flutter para gestionar tareas.

## Ejecutar

Requisitos: Flutter SDK instalado y un emulador o dispositivo conectado.

Desde la carpeta del proyecto, ejecuta:

```bash
flutter pub get
flutter run
```

## Pruebas automatizadas

Desde la carpeta del proyecto, ejecuta todas las pruebas con:

```bash
flutter test
```

Para ejecutar solo las pruebas de la lista de tareas:

```bash
flutter test test/widget_test.dart
```

## Decisiones de implementacion

- Material 3 y widgets estandar de Flutter para una interfaz adaptable, sin dependencias adicionales.
- Las tareas se guardan en memoria y se pueden filtrar por todas, pendientes o completadas.
- El formulario valida que el nombre no este vacio; al eliminar una tarea se puede deshacer la accion.

## Uso de IA

Se utilizo Claude con prompts sencillos como apoyo para implementar y documentar la aplicacion y sus pruebas. Los cambios se verificaron con `flutter test`.

## Tiempo dedicado

30 minutos.
