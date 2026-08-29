import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'dictionary.dart';
import 'settings.dart';

/// Which set of rules this build has to follow to put a word on the screen.
///
/// The three platforms disagree about almost everything — when consent is
/// asked for, whether it can be asked for twice, and whether it is needed at
/// all — so the difference is named once here rather than re-derived at each
/// call site.
enum NotifyPlatform {
  /// Android 13 and later show a runtime dialog; earlier versions grant it at
  /// install time and the request simply returns true.
  android,

  /// iOS asks once, in a system dialog the app cannot re-open. A second
  /// request after a refusal returns false without showing anything.
  ios,

  /// Windows toasts need no consent, only a registered app id — but the user
  /// can silence them in Focus Assist, which the app cannot detect.
  windows,

  /// Everything else: macOS, Linux and the test environment.
  other,
}

/// Delivers the word of the day, on whichever platform this build is running.
///
/// The schedule is rebuilt on every launch rather than left to repeat: each
/// day gets its *own* word, which a single repeating notification could never
/// do, and a rebuild also repairs a schedule the system dropped.
class WordNotifications {
  WordNotifications({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
      _enabled = true,
      available = isSupported;

  /// A service with no platform behind it: it reports itself available, so
  /// the switch and the consent page are still built and still reachable, and
  /// then refuses every request — which is exactly what a reader who declines
  /// the system dialog produces.
  ///
  /// The default in the widget tree, so a test never reaches for a channel
  /// that is not listening.
  WordNotifications.disabled({this.available = true})
    : _plugin = null,
      _enabled = false;

  final FlutterLocalNotificationsPlugin? _plugin;
  final bool _enabled;

  /// Whether this instance can deliver anything, asked of the instance rather
  /// than of the platform so a test can stand in for one it is not running on.
  final bool available;

  bool _ready = false;

  /// How many days ahead to queue. A week is enough that a reader who does not
  /// open the app for a few days keeps receiving words.
  static const _horizon = 7;

  /// Notification ids reserved for the daily word, one per queued day.
  static const _firstId = 4200;

  static const _channelId = 'daily_word';

  /// Windows identifies an app by this rather than by a permission grant.
  static const _windowsAppId = 'ElyasOmar.Qamus.AlMaani.1';
  static const _windowsGuid = '4b0d8f2e-6d3a-4a1c-9f7e-2c5a8b1d3e60';

  static NotifyPlatform get platform {
    if (kIsWeb) return NotifyPlatform.other;
    if (Platform.isAndroid) return NotifyPlatform.android;
    if (Platform.isIOS) return NotifyPlatform.ios;
    if (Platform.isWindows) return NotifyPlatform.windows;
    return NotifyPlatform.other;
  }

  /// True where this build can actually deliver a *scheduled* notification.
  ///
  /// Linux is deliberately absent. The plugin can post a notification there,
  /// but `zonedSchedule` is unimplemented, so offering a word each morning
  /// would be a promise the platform never keeps — better to say plainly that
  /// it cannot than to leave a switch on that does nothing.
  static bool get isSupported =>
      !kIsWeb &&
      (Platform.isAndroid ||
          Platform.isIOS ||
          Platform.isWindows ||
          Platform.isMacOS);

  /// Prepares the plugin and the timezone database.
  ///
  /// Every failure here is swallowed: a reader who cannot be sent a word
  /// should still get a dictionary. The flag stays false and every later call
  /// becomes a no-op.
  Future<void> init() async {
    if (_ready || !_enabled || !available) return;
    try {
      tz.initializeTimeZones();
      await _plugin!.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          // Consent is asked for explicitly during onboarding instead, so the
          // reader meets the system dialog with an explanation already on
          // screen rather than out of nowhere on first launch.
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
          macOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
          linux: LinuxInitializationSettings(defaultActionName: 'Open'),
          windows: WindowsInitializationSettings(
            appName: 'Qamus al-Maani',
            appUserModelId: _windowsAppId,
            guid: _windowsGuid,
          ),
        ),
      );
      _ready = true;
    } catch (error, stack) {
      debugPrint('notifications unavailable: $error\n$stack');
    }
  }

  /// Asks the platform for consent, in the way that platform expects.
  ///
  /// Returns whether words may now be delivered. On Windows and Linux there is
  /// nothing to ask, so it returns true once the plugin is up.
  Future<bool> requestPermission() async {
    await init();
    if (!_ready) return false;
    try {
      switch (platform) {
        case NotifyPlatform.android:
          final android = _plugin!
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
          // Below Android 13 there is no runtime permission and the call
          // returns null; that is a grant, not a refusal.
          final granted =
              await android?.requestNotificationsPermission() ?? true;
          if (!granted) return false;
          // Delivering at a chosen hour is an alarm, not a plain toast. If
          // the exact variant is refused we still schedule — inexactly.
          await android?.requestExactAlarmsPermission();
          return true;

        case NotifyPlatform.ios:
          final ios = _plugin!
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();
          return await ios?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
              false;

        case NotifyPlatform.windows:
        case NotifyPlatform.other:
          return true;
      }
    } catch (error) {
      debugPrint('notification permission request failed: $error');
      return false;
    }
  }

  /// Queues the next [_horizon] days, each with that day's own word.
  ///
  /// Always clears the old queue first, so turning the switch off and on, or
  /// moving the hour, never leaves a stale word waiting.
  Future<void> reschedule({
    required Dictionary dictionary,
    required Settings settings,
  }) async {
    await init();
    if (!_ready) return;
    try {
      await cancelAll();
      if (!settings.dailyWord) return;

      final now = tz.TZDateTime.now(tz.local);
      final hour = settings.dailyWordHour;
      var queued = 0;

      for (var day = 0; day < _horizon + 1 && queued < _horizon; day++) {
        final when = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day + day,
          hour,
        );
        // Today's slot has usually gone by the time the app is opened.
        if (!when.isAfter(now)) continue;

        final word = dictionary.wordOfDay(when);
        if (word == null) continue;

        await _plugin!.zonedSchedule(
          id: _firstId + queued,
          title: word.word,
          body: _preview(word.preview),
          scheduledDate: when,
          notificationDetails: _details(),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: word.key,
        );
        queued++;
      }
    } catch (error) {
      debugPrint('could not schedule the word of the day: $error');
    }
  }

  Future<void> cancelAll() async {
    if (!_ready) return;
    try {
      for (var i = 0; i < _horizon; i++) {
        await _plugin!.cancel(id: _firstId + i);
      }
    } catch (error) {
      debugPrint('could not clear the schedule: $error');
    }
  }

  /// A notification body is one glance, not a paragraph.
  static String _preview(String text) {
    final flat = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (flat.length <= 120) return flat;
    return '${flat.substring(0, 119)}…';
  }

  NotificationDetails _details() => const NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      'كلمة اليوم',
      channelDescription: 'One word from the lexicon, once a day',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    iOS: DarwinNotificationDetails(),
    macOS: DarwinNotificationDetails(),
    linux: LinuxNotificationDetails(),
    windows: WindowsNotificationDetails(),
  );
}
