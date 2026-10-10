import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import 'notification_service.dart';
import '../main.dart' show navigatorKey;
import '../services/auth_service.dart';
import '../screens/client/post_detail_screen.dart';
import '../screens/messaging/messaging_screen.dart';
import '../models/user_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Canal de notification Android — Général (likes, commentaires, collectes)
// ─────────────────────────────────────────────────────────────────────────────
const AndroidNotificationChannel _kChannel = AndroidNotificationChannel(
  'ecorewind_notifications',
  'EcoRewind Notifications',
  description: 'Notifications EcoRewind : j\'aimes, commentaires, collectes.',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
);

// ─────────────────────────────────────────────────────────────────────────────
// Canal de notification Android — Messages (sonnerie + vibration forte)
// Un canal séparé permet à l'utilisateur de gérer le son des messages
// indépendamment des autres notifications dans les paramètres du téléphone.
// ─────────────────────────────────────────────────────────────────────────────
const AndroidNotificationChannel _kMessagesChannel = AndroidNotificationChannel(
  'ecorewind_messages',
  'Messages EcoRewind',
  description: 'Notifications de nouveaux messages reçus.',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
  // Vibration : pause 0ms → vibre 400ms → pause 200ms → vibre 400ms
  vibrationPattern: null, // défini dans AndroidNotificationDetails
);

final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// ─────────────────────────────────────────────────────────────────────────────
// Handler de fond (doit être top-level ET annoté @pragma)
// Affiche la notification système même quand l'app est FERMÉE.
// ─────────────────────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialiser les plugins nécessaires dans l'isolate de fond
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
      InitializationSettings(android: androidSettings);
  await _flutterLocalNotificationsPlugin.initialize(initSettings);

  // Créer les deux canaux si besoin
  final androidPlugin = _flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.createNotificationChannel(_kChannel);
  await androidPlugin?.createNotificationChannel(_kMessagesChannel);

  final notification = message.notification;
  final title = notification?.title ?? 'EcoRewind';
  final body = notification?.body ?? '';
  final data = message.data;
  final type = data['type'] ?? 'info';

  // Choisir le bon canal selon le type
  final isMessage = type == 'message' || type == 'group_message';
  final channel = isMessage ? _kMessagesChannel : _kChannel;
  final vibration = isMessage
      ? Int64List.fromList([0, 400, 200, 400, 200, 400])
      : Int64List.fromList([0, 250, 100, 250]);

  await _flutterLocalNotificationsPlugin.show(
    message.hashCode,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF2E7D32),
        playSound: true,
        enableVibration: true,
        visibility: NotificationVisibility.public,
        vibrationPattern: vibration,
        ticker: title,
        styleInformation: BigTextStyleInformation(body),
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        // Pour les messages : afficher comme une conversation
        category: isMessage ? AndroidNotificationCategory.message : null,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      ),
    ),
    payload: jsonEncode({...data, 'type': type}),
  );

  debugPrint('[FCM-BG] Notification affichée ($type) : $title');
}

// ─────────────────────────────────────────────────────────────────────────────
// FcmService — service singleton de gestion complète des push notifications
// ─────────────────────────────────────────────────────────────────────────────
class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _initialized = false;

  // ── StreamSubscriptions — stockées pour pouvoir les annuler au logout ──────
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedAppSub;

  /// Annule tous les listeners FCM — appeler au logout pour éviter les fuites.
  static void cancelListeners() {
    final svc = FcmService();
    svc._tokenRefreshSub?.cancel();
    svc._foregroundSub?.cancel();
    svc._openedAppSub?.cancel();
    svc._tokenRefreshSub = null;
    svc._foregroundSub = null;
    svc._openedAppSub = null;
    debugPrint('[FCM] Listeners annulés (logout)');
  }

  // ── Initialiser FCM — appeler une seule fois depuis main.dart ────────────
  static Future<void> initialize({BuildContext? context}) async {
    await FcmService()._init(context: context);
  }

  // ── Appeler après chaque connexion réussie ───────────────────────────────
  // 1. Enregistre le token FCM auprès du backend
  // 2. Affiche toutes les notifications non lues dans la barre système Android
  static bool _loginInProgress = false; // mutex anti-double-appel

  static Future<void> onUserLoggedIn() async {
    // Évite les appels simultanés (session restore + login manuel)
    if (_loginInProgress) {
      debugPrint('[FCM] onUserLoggedIn() déjà en cours — appel ignoré.');
      return;
    }
    _loginInProgress = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      // Note : on NE force plus le renvoi systématique (ancienne étape 0).
      // Le mécanisme de dédup dans _sendTokenToBackend (fcm_last_sent_token)
      // évite les doubles envois lorsque sendPendingFcmToken() a déjà envoyé.
      // Le token est renvoyé automatiquement si Firebase en génère un nouveau.

      // Étape 1 : récupérer le token FCM avec retry
      // getToken() peut retourner null si les permissions viennent d'être
      // accordées et que Firebase n'a pas encore généré le token.
      String? token;
      for (int attempt = 1; attempt <= 5; attempt++) {
        token = await FirebaseMessaging.instance.getToken();
        debugPrint('[FCM] getToken() tentative $attempt : ${token != null ? '${token.substring(0, 20)}...' : 'null'}');
        if (token != null) break;
        await Future.delayed(const Duration(seconds: 2));
      }

      if (token != null) {
        // Vérifier qu'un JWT est disponible avant d'envoyer
        final jwt = AuthState.authToken;
        if (jwt != null) {
          await FcmService()._sendTokenToBackend(token);
          debugPrint('[FCM] ✅ Token FCM enregistré sur le backend après login.');
        } else {
          // Session fallback (JWT expiré) — sauvegarder le token localement.
          // Il sera envoyé dès que l'utilisateur se reconnecte avec un vrai JWT.
          debugPrint('[FCM] ⚠️ JWT absent en session fallback — token FCM sauvegardé localement, envoi différé à la prochaine connexion.');
          await prefs.setString('fcm_pending_token', token);
        }
      } else {
        debugPrint('[FCM] ⚠️ Token FCM indisponible après 5 tentatives.');
      }

      // Étape 2 : afficher les notifications manquées (seulement si JWT valide)
      await FcmService()._showPendingNotifications();
    } catch (e) {
      debugPrint('[FCM] Erreur onUserLoggedIn: $e');
    } finally {
      _loginInProgress = false; // libérer le mutex dans tous les cas
    }
  }

  // ── Rétro-compatibilité ───────────────────────────────────────────────────
  static Future<void> sendTokenToBackend() => onUserLoggedIn();

  /// Envoie le token FCM sauvegardé pendant une session fallback (JWT expiré).
  /// À appeler juste après qu'un vrai JWT soit disponible (login réussi).
  static Future<void> sendPendingFcmToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingToken = prefs.getString('fcm_pending_token');
      if (pendingToken != null && AuthState.authToken != null) {
        debugPrint('[FCM] Envoi du token FCM en attente (session fallback précédente)...');
        await FcmService()._sendTokenToBackend(pendingToken);
        await prefs.remove('fcm_pending_token');
        debugPrint('[FCM] ✅ Token FCM en attente envoyé avec succès.');
      }
    } catch (e) {
      debugPrint('[FCM] Erreur sendPendingFcmToken: $e');
    }
  }

  // ── Affiche uniquement les notifications reçues APRÈS la dernière déconnexion ──
  //
  // Logique :
  //  • Lit le timestamp de déconnexion sauvegardé par clearTokens().
  //  • Ne montre que les notifications dont created_at > last_logout_time.
  //  • Mise à jour du timestamp après chaque affichage pour le prochain login.
  //  • Première connexion (pas de timestamp) : aucune notification affichée
  //    pour ne pas submerger l'utilisateur.
  Future<void> _showPendingNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jwt = AuthState.authToken;
      if (jwt == null) return;

      // ── Lire la borne temporelle (timestamp de la dernière déconnexion) ──
      final lastLogoutStr = prefs.getString('fcm_last_logout_time');
      if (lastLogoutStr == null) {
        // Première connexion : on initialise la borne à maintenant
        // et on n'affiche rien (pas de spam au premier lancement)
        await prefs.setString(
          'fcm_last_logout_time',
          DateTime.now().toUtc().toIso8601String(),
        );
        debugPrint('[FCM] Première connexion — borne initialisée, aucune notif à afficher.');
        return;
      }

      final lastLogout = DateTime.tryParse(lastLogoutStr);
      if (lastLogout == null) return;

      debugPrint('[FCM] Borne de déconnexion : $lastLogoutStr');

      // ── Récupérer les notifications depuis le backend ─────────────────────
      final uri = Uri.parse('${ApiConstants.baseUrl}/notifications?skip=0&limit=50');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $jwt'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return;

      final List<dynamic> allNotifs = jsonDecode(utf8.decode(response.bodyBytes));

      // ── Filtrer : non lues ET créées APRÈS la dernière déconnexion ─────────
      final toShow = allNotifs.where((n) {
        // Doit être non lue
        final isUnread = n['is_read'] == false || n['is_read'] == null;
        if (!isUnread) return false;

        // Doit avoir un created_at valide
        final createdAtStr = n['created_at']?.toString();
        if (createdAtStr == null) return false;

        // Doit être postérieure à la dernière déconnexion
        final createdAt = DateTime.tryParse(createdAtStr);
        if (createdAt == null) return false;

        return createdAt.isAfter(lastLogout);
      }).toList();

      // Trier du plus ancien au plus récent pour un affichage chronologique
      toShow.sort((a, b) {
        final ta = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(0);
        final tb = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(0);
        return ta.compareTo(tb);
      });

      if (toShow.isEmpty) {
        debugPrint('[FCM] Aucune nouvelle notification depuis la dernière déconnexion.');
        return;
      }

      debugPrint('[FCM] ${toShow.length} notification(s) à afficher depuis la déconnexion.');

      for (int i = 0; i < toShow.length; i++) {
        final notif  = toShow[i];
        final id     = notif['id']?.toString() ?? '';
        final type   = notif['type']?.toString() ?? 'info';
        final title  = notif['title']?.toString() ?? 'EcoRewind';
        final body   = notif['body']?.toString() ?? '';
        final postId = notif['post_id']?.toString();

        if (id.isEmpty) continue;

        // Décalage progressif entre les notifications (max 5 affichées rapidement)
        if (i > 0) await Future.delayed(const Duration(milliseconds: 400));

        // Payload de navigation — interne, jamais affiché
        final navPayload = jsonEncode({
          'type': type,
          if (postId != null) 'post_id': postId,
          'notif_id': id,
        });

        // Afficher dans la barre système Android avec son + vibration
        await _flutterLocalNotificationsPlugin.show(
          int.tryParse(id) ?? id.hashCode,
          title,   // Texte lisible uniquement
          body,    // Texte lisible uniquement
          _buildNotifDetails(body: body),
          payload: navPayload,
        );

        // ── Mettre à jour la borne IMMÉDIATEMENT après chaque affichage ──────
        // Garantit que cette notification ne sera plus affichée même en cas de crash.
        final notifTime = DateTime.tryParse(notif['created_at'] ?? '');
        if (notifTime != null) {
          // La nouvelle borne = heure de la notification affichée + 1 ms
          final newBound = notifTime.add(const Duration(milliseconds: 1));
          await prefs.setString('fcm_last_logout_time', newBound.toIso8601String());
        }

        // Ajouter au cache in-app (badge + écran notifications)
        NotificationService().addNotification(
          title: title,
          body: body,
          type: _mapType(type),
        );
      }

      // Borne finale = maintenant (pour le prochain login)
      await prefs.setString(
        'fcm_last_logout_time',
        DateTime.now().toUtc().toIso8601String(),
      );

      debugPrint('[FCM] ✅ ${toShow.length} notification(s) affichée(s).');
    } catch (e) {
      debugPrint('[FCM] Erreur _showPendingNotifications: $e');
    }

  }

  // ── Construit les NotificationDetails (affichage pur—aucun JSON technique) ──
  // Le payload de navigation n'est JAMAIS inclus dans le texte visible.
  NotificationDetails _buildNotifDetails({String body = ''}) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _kChannel.id,
        _kChannel.name,
        channelDescription: _kChannel.description,
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF2E7D32),
        playSound: true,
        enableVibration: true,
        visibility: NotificationVisibility.public,
        vibrationPattern: Int64List.fromList([0, 300, 150, 300]),
        // BigTextStyleInformation affiche le texte lisible — jamais le payload JSON
        styleInformation: body.isNotEmpty
            ? BigTextStyleInformation(body)
            : const DefaultStyleInformation(false, false),
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        groupKey: 'ecorewind_group',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      ),
    );
  }

  /// Construit les NotificationDetails pour un MESSAGE entrant.
  /// Canal dédié + vibration forte + catégorie "message" pour Android.
  NotificationDetails _buildMessageNotifDetails({
    required String title,
    required String body,
    String? senderName,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _kMessagesChannel.id,
        _kMessagesChannel.name,
        channelDescription: _kMessagesChannel.description,
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF0288D1), // bleu pour les messages
        playSound: true,
        enableVibration: true,
        visibility: NotificationVisibility.public,
        vibrationPattern: Int64List.fromList([0, 400, 200, 400, 200, 400]),
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
          summaryText: senderName,
        ),
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        category: AndroidNotificationCategory.message,
        groupKey: 'ecorewind_messages_group',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        threadIdentifier: 'messages',
      ),
    );
  }

  Future<void> _init({BuildContext? context}) async {
    if (_initialized) return;
    _initialized = true;

    try {
      // 1. Demander la permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        // Sur Android 8.x (EMUI), requestPermission() peut retourner "denied"
        // même si flutter_local_notifications peut quand même afficher via les canaux Android.
        // On NE retourne PAS ici pour continuer l'initialisation complète.
        debugPrint('[FCM] ⚠️ Permission FCM refusée par l\'OS — init continue (canaux Android toujours actifs).');
      } else {
        debugPrint('[FCM] Permission: ${settings.authorizationStatus}');
      }

      // 2. Présentation foreground iOS
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 3. Initialiser flutter_local_notifications
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          try {
            if (response.payload != null) {
              final data = jsonDecode(response.payload!) as Map<String, dynamic>;
              _navigateFromPayload(data);
            }
          } catch (e) {
            debugPrint('[FCM] Erreur tap notification locale: $e');
          }
        },
        onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTap,
      );

      // 4. Créer les deux canaux Android haute importance
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(_kChannel);
      await androidPlugin?.createNotificationChannel(_kMessagesChannel);
      debugPrint('[FCM] Canaux Android créés/vérifiés (général + messages)');

      // 4b. Demander la permission Android explicitement via flutter_local_notifications
      // (nécessaire sur certains Huawei EMUI même si Firebase dit "denied")
      final granted = await androidPlugin?.requestNotificationsPermission();
      debugPrint('[FCM] Permission Android notifications : ${granted == true ? "✅ accordée" : "⚠️ non accordée (paramètres système requis)"}');

      // 5. (Handler de fond enregistré dans main.dart AVANT Firebase.initializeApp)

      // 6. Récupérer & envoyer le token FCM
      await _getAndSendToken();

      // 7. Écouter le rafraîchissement du token
      _tokenRefreshSub?.cancel();
      _tokenRefreshSub = _messaging.onTokenRefresh.listen(_sendTokenToBackend);

      // 8. Messages en FOREGROUND (app ouverte)
      _foregroundSub?.cancel();
      _foregroundSub = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[FCM-FG] Message: ${message.notification?.title}');
        _handleForegroundMessage(message);
      });

      // 9. Tap sur notification quand app en ARRIÈRE-PLAN (minimisrée)
      _openedAppSub?.cancel();
      _openedAppSub = FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[FCM-TAP] App en fond: ${message.notification?.title}');
        _navigateFromRemoteMessage(message);
      });

      // 10. App relancée depuis une notification (était FERMÉE)
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('[FCM-LAUNCH] App lancée via notif: ${initialMessage.notification?.title}');
        // Délai pour laisser le temps à l'arbre de widgets de se construire
        await Future.delayed(const Duration(milliseconds: 1500));
        _navigateFromRemoteMessage(initialMessage);
      }

      debugPrint('[FCM] ✅ Service FCM initialisé');
    } catch (e) {
      debugPrint('[FCM] Erreur init: $e');
    }
  }

  // ── Récupère le token et l'envoie au backend (avec retry différé) ──────────
  // Le token FCM est prêt dès le démarrage, mais le JWT peut ne pas encore
  // être disponible si la session est en cours de restauration.
  // On réessaie jusqu'à 3 fois avec un délai croissant.
  Future<void> _getAndSendToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null) {
        debugPrint('[FCM] Token null — Firebase pas encore prêt');
        return;
      }
      debugPrint('[FCM] Token: ${token.substring(0, 20)}...');

      // Vérifier si le token a changé depuis le dernier envoi
      final prefs = await SharedPreferences.getInstance();
      final lastSentToken = prefs.getString('fcm_last_sent_token');
      final jwt = AuthState.authToken;

      if (jwt == null) {
        // JWT pas encore disponible → réessayer après 3s puis 6s
        debugPrint('[FCM] JWT absent au démarrage → retry dans 3s');
        _scheduleTokenRetry(token);
        return;
      }

      if (lastSentToken == token) {
        // Token identique et déjà envoyé → pas besoin de renvoyer
        debugPrint('[FCM] Token inchangé, pas d\'envoi nécessaire');
        return;
      }

      await _sendTokenToBackend(token);
    } catch (e) {
      debugPrint('[FCM] Erreur récupération token: $e');
    }
  }

  // ── Retry différé pour envoyer le token quand le JWT est disponible ────────
  void _scheduleTokenRetry(String token) {
    Future.delayed(const Duration(seconds: 3), () async {
      final jwt = AuthState.authToken;
      if (jwt != null) {
        debugPrint('[FCM] Retry token (3s) — JWT disponible');
        await _sendTokenToBackend(token);
      } else {
        // Deuxième retry après 6s supplémentaires
        Future.delayed(const Duration(seconds: 6), () async {
          final jwt2 = AuthState.authToken;
          if (jwt2 != null) {
            debugPrint('[FCM] Retry token (9s) — JWT disponible');
            await _sendTokenToBackend(token);
          } else {
            debugPrint('[FCM] Token non envoyé après 2 retries (utilisateur non connecté)');
          }
        });
      }
    });
  }


  // ── Envoie le token au backend FastAPI ───────────────────────────────────
  Future<void> _sendTokenToBackend(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jwt = AuthState.authToken;
      if (jwt == null) {
        debugPrint('[FCM] Pas de JWT → token non envoyé (non connecté)');
        return;
      }
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/notifications/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
        body: jsonEncode({'token': token}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        debugPrint('[FCM] Token enregistré sur le backend');
        // Sauvegarder le token envoyé pour éviter les doublons
        await prefs.setString('fcm_last_sent_token', token);
      } else {
        debugPrint('[FCM] Erreur backend: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[FCM] Erreur envoi token: $e');
    }
  }

  // ── Affiche la notification en FOREGROUND (app ouverte) ──────────────────
  void _handleForegroundMessage(RemoteMessage message) async {
    final title = message.notification?.title ?? 'EcoRewind';
    final body = message.notification?.body ?? '';
    final data = message.data;
    final type = data['type'] ?? 'info';
    final navPayload = jsonEncode({...data, 'type': type});
    final isMessage = type == 'message' || type == 'group_message';
    final senderName = data['sender_name'] as String?;

    // ID unique basé sur le timestamp (Huawei EMUI ignore les IDs identiques)
    final notifId = DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF;

    // Afficher la notification système — avec gestion d'erreur explicite
    try {
      await _flutterLocalNotificationsPlugin.show(
        notifId,
        title,
        body,
        isMessage
            ? _buildMessageNotifDetails(title: title, body: body, senderName: senderName)
            : _buildNotifDetails(body: body),
        payload: navPayload,
      );
      debugPrint('[FCM-FG] ✅ Notification système affichée : $title (id=$notifId, type=$type)');
    } catch (e, stack) {
      // Sur Huawei EMUI, show() peut échouer si la permission est révoquée
      // ou si le canal est bloqué dans les paramètres du téléphone.
      debugPrint('[FCM-FG] ❌ Erreur affichage notification système : $e');
      debugPrint('[FCM-FG] Stack: $stack');
    }

    // Ajouter au cache in-app (badge + écran notifications) — toujours
    NotificationService().addNotification(
      title: title,
      body: body,
      type: _mapType(type),
    );

    // Toast in-app superposé uniquement si l'écran est visible
    final ctx = navigatorKey.currentContext;
    if (ctx != null && ctx.mounted) {
      NotificationService.showToast(ctx, title: title, body: body, type: _mapType(type));
    }
  }

  // ── Navigation intelligente depuis un RemoteMessage ──────────────────────
  void _navigateFromRemoteMessage(RemoteMessage message) {
    _navigateFromPayload({...message.data, 'type': message.data['type'] ?? 'info'});
  }

  // ── Navigation intelligente depuis un payload (tap local ou FCM) ─────────
  void _navigateFromPayload(Map<String, dynamic> data) {
    final postIdRaw       = data['post_id'];
    final assignmentIdRaw = data['assignment_id'];
    final type            = data['type'] ?? '';
    final partnerIdRaw    = data['partner_id'] ?? data['sender_id'];
    final partnerName     = data['sender_name'] as String? ?? 'Message';
    final groupIdRaw      = data['group_id'];
    final groupName       = data['group_name'] as String? ?? 'Groupe';
    debugPrint('[FCM] Navigation → type=$type, partner=$partnerIdRaw');

    final context = navigatorKey.currentContext;
    if (context == null) return;

    // ── Message direct → ouvrir la conversation ───────────────────────────
    if (type == 'message') {
      final partnerId = int.tryParse(partnerIdRaw?.toString() ?? '');
      if (partnerId != null) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => DirectChatRoute(
            partnerId: partnerId,
            partnerName: partnerName,
          ),
        ));
        return;
      }
    }

    // ── Message de groupe → ouvrir la conversation groupe ─────────────────
    if (type == 'group_message') {
      final groupId = int.tryParse(groupIdRaw?.toString() ?? '');
      if (groupId != null) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => GroupChatRoute(
            groupId: groupId,
            groupName: groupName,
          ),
        ));
        return;
      }
    }

    // ── Notification de mission (assignment) → Carte mission ─────────────
    if (type == 'assignment' || type == 'collector_assignment') {
      final assignmentId = int.tryParse(assignmentIdRaw?.toString() ?? '');
      if (assignmentId != null && assignmentId > 0) {
        Navigator.of(context).pushNamed(
          '/mission-map',
          arguments: {'assignment_id': assignmentId},
        );
        return;
      }
      // Fallback si pas d'ID
      Navigator.of(context).pushNamed('/notifications');
      return;
    }

    // Types liés à l'intercommunalité → écran Notifications
    const intercommunalityTypes = {
      'intercommunality_message',
      'intercommunality_group_message',
      'actor_reply',
    };
    if (intercommunalityTypes.contains(type)) {
      Navigator.of(context).pushNamed('/notifications');
      return;
    }

    if (postIdRaw != null) {
      final postId = int.tryParse(postIdRaw.toString());
      if (postId != null) {
        _openPost(context, postId);
        return;
      }
    }

    // Fallback : ouvrir l'écran des notifications
    Navigator.of(context).pushNamed('/notifications');
  }


  // ── Ouvre directement la publication depuis l'API ────────────────────────
  Future<void> _openPost(BuildContext context, int postId) async {
    try {
      final post = await AuthService().fetchSinglePost(postId);
      if (post != null && context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
        );
      } else if (context.mounted) {
        // Si la publication a été supprimée, ouvrir les notifications
        Navigator.of(context).pushNamed('/notifications');
      }
    } catch (e) {
      debugPrint('[FCM] Erreur ouverture post $postId: $e');
    }
  }

  NotificationType _mapType(String type) {
    switch (type) {
      case 'like': return NotificationType.like;
      case 'comment': return NotificationType.comment;
      case 'save': return NotificationType.save;
      default: return NotificationType.info;
    }
  }
}

// ── Handler de tap en arrière-plan (doit être top-level) ─────────────────────
@pragma('vm:entry-point')
void _onBackgroundNotificationTap(NotificationResponse response) {
  // Le navigatorKey n'est pas encore disponible dans ce contexte.
  // L'utilisateur relancera l'app, la navigation sera gérée par getInitialMessage.
  debugPrint('[FCM-BG-TAP] Payload: ${response.payload}');
}
