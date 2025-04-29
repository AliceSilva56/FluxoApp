// Arquivo: notificacoes.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;

class NotificacaoService {
  static final FlutterLocalNotificationsPlugin _notificacoes =
      FlutterLocalNotificationsPlugin();

  static Future<void> inicializarNotificacoes() async {
    tzData.initializeTimeZones();

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidInit,
    );

    await _notificacoes.initialize(settings);
  }

  static Future<void> mostrarNotificacao(String titulo, String mensagem) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'canal_desejos',
      'Gastos com Desejos',
      channelDescription: 'Notificações sobre gastos com desejos',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails detalhes = NotificationDetails(
      android: androidDetails,
    );

    await _notificacoes.show(
      0,
      titulo,
      mensagem,
      detalhes,
    );
  }

  static Future<void> agendarNotificacaoSemanal(String titulo, String mensagem) async {
    await _notificacoes.zonedSchedule(
      1,
      titulo,
      mensagem,
      _proximaSegundaFeira(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'canal_desejos',
          'Gastos com Desejos',
          channelDescription: 'Notificações semanais sobre gastos com desejos',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  static tz.TZDateTime _proximaSegundaFeira() {
    final agora = tz.TZDateTime.now(tz.local);
    final proximaSegunda = agora.add(Duration(days: (8 - agora.weekday) % 7));
    return tz.TZDateTime(tz.local, proximaSegunda.year, proximaSegunda.month,
        proximaSegunda.day, 10); // Notifica às 10h
  }
}
