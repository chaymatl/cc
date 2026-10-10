import 'package:shared_preferences/shared_preferences.dart';

class L10n {
  static String _locale = 'fr';
  static final List<Function()> _listeners = [];

  static String get locale => _locale;

  static void addListener(Function() listener) {
    _listeners.add(listener);
  }

  static void removeListener(Function() listener) {
    _listeners.remove(listener);
  }

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _locale = prefs.getString('app_locale') ?? 'fr';
    } catch (_) {}
  }

  static Future<void> setLocale(String lang) async {
    _locale = 'fr';
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_locale', 'fr');
    } catch (_) {}
    for (final listener in _listeners) {
      listener();
    }
  }

  // Dictionnaire de traduction Français
  static final Map<String, Map<String, String>> _keys = {
    // Brand
    'app_name': {'fr': 'EcoRewind'},
    
    // Onboarding
    'onboarding_title_1': {'fr': 'Tri Intelligent'},
    'onboarding_desc_1': {
      'fr': 'Simplifiez votre gestion des déchets grâce à notre IA de reconnaissance visuelle.'
    },
    'onboarding_title_2': {'fr': 'Impact Réel'},
    'onboarding_desc_2': {
      'fr': 'Visualisez vos économies de CO2 et gagnez des points éco-citoyens à chaque geste.'
    },
    'onboarding_title_3': {'fr': 'Communauté Active'},
    'onboarding_desc_3': {
      'fr': 'Rejoignez des milliers de Tunisiens engagés pour un environnement plus propre.'
    },
    'onboarding_title_4': {'fr': 'Guide du Tri'},
    'onboarding_desc_4': {
      'fr': 'Apprenez les gestes simples pour trier vos déchets comme un expert.'
    },
    'btn_start': {'fr': 'COMMENCER'},
    'btn_next': {'fr': 'SUIVANT'},
    
    // Navigation Tabs (Mobile & Web)
    'tab_feed': {'fr': 'Fil'},
    'tab_multimedia': {'fr': 'Formation'},
    'tab_rewards': {'fr': 'Impact'},
    'tab_map': {'fr': 'Carte'},
    'tab_community': {'fr': 'Communauté'},
    'tab_profile': {'fr': 'Profil'},
    
    // Role-specific tab labels
    'tab_educator': {'fr': 'Éducateur'},
    'tab_collector': {'fr': 'Collecte'},
    'tab_intercommunality': {'fr': 'Gestion'},
    'tab_pointManager': {'fr': 'Points'},
    
    // Profile Menu
    'menu_sec_security': {'fr': 'SÉCURITÉ ET DONNÉES'},
    'menu_sec_preferences': {'fr': 'PRÉFÉRENCES'},
    

    
    'menu_change_pass': {'fr': 'Changer le mot de passe'},
    'menu_change_pass_sub': {'fr': 'Mis à jour il y a 3 mois'},
    
    'menu_saved_posts': {'fr': 'Publications enregistrées'},
    'menu_saved_posts_sub': {'fr': 'Accédez à votre bibliothèque éco'},
    
    'menu_notifications': {'fr': 'Notifications'},
    'menu_notif_unread': {'fr': 'non lue'},
    'menu_notif_unreads': {'fr': 'non lues'},
    'menu_notif_none': {'fr': 'Aucune nouvelle'},
    
    'menu_dark_mode': {'fr': 'Mode Sombre'},
    'menu_dark_mode_sub': {'fr': 'Système par défaut'},
    
    'menu_logout': {'fr': 'Déconnexion'},
    
    // Profile Cards & Buttons
    'prof_badge_title': {'fr': 'Espace Professionnel'},
    'prof_badge_desc': {
      'fr': 'Vous avez accès aux outils d\'administration avancés.'
    },
    'prof_role_superadmin': {'fr': 'SUPER ADMINISTRATEUR'},
    'prof_role_admin': {'fr': 'DIRECTEUR TECHNIQUE'},
    'prof_role_user': {'fr': 'USER ENGAGÉ'},
    
    'prof_stats_score': {'fr': 'SCORE GLOBAL'},
    'prof_stats_posts': {'fr': 'POSTS'},
    'prof_stats_likes': {'fr': 'LIKES'},
    'prof_stats_comments': {'fr': 'COMMENTAIRES'},
    
    'prof_btn_eco_badge': {'fr': 'Mon Eco-Badge'},
    'prof_btn_eco_badge_sub': {'fr': 'Scannez pour ouvrir une borne de tri'},
    
    'prof_btn_scan_bin': {'fr': 'Scanner une Poubelle'},
    'prof_btn_scan_bin_sub': {'fr': 'Gagnez des points en recyclant'},
    
    'menu_lang': {'fr': 'Langue'},
    'menu_lang_sub': {'fr': 'Français'},

    // Admin App
    'admin_app_bar_title': {'fr': 'EcoRewind Admin'},
    'admin_header_title': {'fr': 'Dashboard'},
    'admin_system_active': {'fr': '● Système actif'},
    
    // Admin Dashboard Tabs
    'admin_tab_indicators': {'fr': 'INDICATEURS'},
    'admin_tab_moderation': {'fr': 'MODÉRATION'},
    'admin_tab_content': {'fr': 'CONTENUS'},
    'admin_tab_proposals': {'fr': 'PROPOSITIONS'},
    'admin_tab_points': {'fr': 'POINTS DE TRI'},
    'admin_tab_users': {'fr': 'UTILISATEURS'},
    'admin_tab_profile': {'fr': 'MON PROFIL'},

    // Admin Dashboard KPI & Titles
    'admin_kpi_overview': {'fr': 'Vue d\'ensemble'},
    'admin_kpi_users': {'fr': 'Citoyens'},
    'admin_kpi_users_sub': {'fr': 'Comptes actifs'},
    'admin_kpi_scans': {'fr': 'Scans QR'},
    'admin_kpi_scans_sub': {'fr': 'Total historique'},
    'admin_kpi_points': {'fr': 'Points'},
    'admin_kpi_points_sub': {'fr': 'Distribués'},
    'admin_kpi_centers': {'fr': 'Centres'},
    'admin_kpi_centers_sub': {'fr': 'Actifs / Total'},
    'admin_kpi_avg_score': {'fr': 'Score moyen'},
    'admin_kpi_avg_score_sub': {'fr': 'Moyenne citoyens'},
    'admin_kpi_quiz': {'fr': 'Quiz faits'},
    'admin_kpi_quiz_sub': {'fr': 'Soumissions totales'},
    'admin_kpi_moderation': {'fr': 'Modération'},
    'admin_kpi_moderation_sub': {'fr': 'Signalements'},
    'admin_kpi_firebase': {'fr': 'Firebase'},
    'admin_kpi_firebase_sub': {'fr': 'Désynchronisations'},

    // Client Pages Headers
    'tab_multimedia_title': {'fr': 'Formation Éco'},
    'tab_rewards_title': {'fr': 'Récompenses'},

    // Rewards Screen Specifics
    'Solde Actuel': {'fr': 'Solde Actuel'},
    'pts': {'fr': 'pts'},
    'Niveau Maximum atteint ! 🎉': {'fr': 'Niveau Maximum atteint ! 🎉'},
    'Niveaux & Avantages': {'fr': 'Niveaux & Avantages'},
    'Vos Badges': {'fr': 'Vos Badges'},
    'Récompenses Exclusives': {'fr': 'Récompenses Exclusives'},
    'Éco-Citoyen': {'fr': 'Éco-Citoyen'},
    'Champion Vert': {'fr': 'Champion Vert'},
    'Légende Éco': {'fr': 'Légende Éco'},
    'Niveau de départ': {'fr': 'Niveau de départ'},
    '2 000 pts': {'fr': '2 000 pts'},
    '5 000 pts': {'fr': '5 000 pts'},
    'Premier Tri': {'fr': 'Premier Tri'},
    'Série 7J': {'fr': 'Série 7J'},
    'Expert Quiz': {'fr': 'Expert Quiz'},
    'Communauté': {'fr': 'Communauté'},
    'Bon d\'achat 10 DT': {'fr': 'Bon d\'achat 10 DT'},
    '1000 pts': {'fr': '1000 pts'},
    'Sac en toile bio': {'fr': 'Sac en toile bio'},
    '1500 pts': {'fr': '1500 pts'},
    'Gourde écologique': {'fr': 'Gourde écologique'},
    '2500 pts': {'fr': '2500 pts'},
    'Plantation d\'arbre': {'fr': 'Plantation d\'arbre'},
    '3000 pts': {'fr': '3000 pts'},

    // Multimedia Screen Specifics
    'Tout': {'fr': 'Tout'},
    'Vidéos': {'fr': 'Vidéos'},
    'Quiz': {'fr': 'Quiz'},
    'VIDÉOS ÉDUCATIVES': {'fr': 'VIDÉOS ÉDUCATIVES'},
    'AUTRES VIDÉOS': {'fr': 'AUTRES VIDÉOS'},
    'QUIZ IA': {'fr': 'QUIZ IA'},
    'Aucun quiz': {'fr': 'Aucun quiz'},
    'Revenez plus tard pour de nouveaux défis': {'fr': 'Revenez plus tard pour de nouveaux défis'},

     // Feed Screen Specifics
     'Impossible de charger le fil': {'fr': 'Impossible de charger le fil'},
     'Nouvelle publication': {'fr': 'Nouvelle publication'},
     'Partagez votre geste écologique...': {'fr': 'Partagez votre geste écologique...'},
     'Ajouter une photo': {'fr': 'Ajouter une photo'},
     'Publier': {'fr': 'Publier'},
     'Aucune publication': {'fr': 'Aucune publication'},
     'Soyez le premier à partager un geste éco !': {'fr': 'Soyez le premier à partager un geste éco !'},
     'Créer une publication': {'fr': 'Créer une publication'},

     // Community Screen Specifics
     'Espace Communauté': {'fr': 'Espace Communauté'},
     'Témoignages et propositions de nos éco-citoyens': {'fr': 'Témoignages et propositions de nos éco-citoyens'},
     'Avis de nos citoyens': {'fr': 'Avis de nos citoyens'},
     'Partager votre avis': {'fr': 'Partager votre avis'},
     'Votre expérience compte !': {'fr': 'Votre expérience compte !'},
     'Proposer un centre de tri': {'fr': 'Proposer un centre de tri'},
     'Suggérez un nouvel emplacement': {'fr': 'Suggérez un nouvel emplacement'},
     'Votre avis': {'fr': 'Votre avis'},
     'Partagez votre expérience avec EcoRewind': {'fr': 'Partagez votre expérience avec EcoRewind'},
     'Note': {'fr': 'Note'},
     'Votre témoignage': {'fr': 'Votre témoignage'},

     // Intercommunality Tab Specifics
     'Coordination Territoriale': {'fr': 'Coordination Territoriale'},
     'Gerez les politiques de tri et les acteurs locaux.': {'fr': 'Gérez les politiques de tri et les acteurs locaux.'},
     'Consignes de tri locales': {'fr': 'Consignes de tri locales'},
     'Mise à jour des règles 2026': {'fr': 'Mise à jour des règles 2026'},
     'Points de collecte': {'fr': 'Points de collecte'},
     'Centralisation (342 points)': {'fr': 'Centralisation (342 points)'},
     'Acteurs locaux': {'fr': 'Acteurs locaux'},
     'Coordination : 12 prestataires': {'fr': 'Coordination : 12 prestataires'},
     'RAPPORTS DE PERFORMANCE INTERCOMMUNALE': {'fr': 'RAPPORTS DE PERFORMANCE INTERCOMMUNALE'},

     // Feed Screen Additional
     'Réessayer': {'fr': 'Réessayer'},

     // Home Dashboard
     'home_score_label': {'fr': 'SCORE ÉCO ACTUEL'},
     'home_details': {'fr': 'Détails'},
     'home_tip_text': {'fr': 'Rincez vos contenants en plastique avant de les jeter pour un meilleur recyclage.'},
     'home_tip_label': {'fr': 'Conseil du jour'},
     'home_quick_services': {'fr': 'Services Rapides'},
     'home_action_centers': {'fr': 'Centres de Tri'},
     'home_action_quiz': {'fr': 'Quiz & Apprendre'},
     'home_action_feed': {'fr': 'Fil Citoyen'},
     'home_action_shop': {'fr': 'Boutique'},
     'home_scan_title': {'fr': 'Scanner une Poubelle'},
     'home_scan_sub': {'fr': 'Gagnez des points éco instantanément'},
     'home_history': {'fr': 'Historique'},
     'home_education_section': {'fr': 'Espace Éducation'},
     'home_see_all': {'fr': 'Voir tout'},
     'home_see_all_arrow': {'fr': 'Tout voir →'},
    'home_stat_co2': {'fr': 'CO₂ ÉVITÉ'},
    'home_stat_sorted': {'fr': 'TRIÉ'},
    'home_stat_trees': {'fr': 'ARBRES'},
    'home_news_section': {'fr': 'Actualités'},
    'home_no_posts': {'fr': 'Aucune publication pour le moment'},

    // ── Mode hors-ligne ─────────────────────────────────────────────────────
    'offline_banner': {'fr': '📦 Mode hors-ligne'},
    'offline_cached': {'fr': 'données mises en cache'},
    'offline_updated_now': {'fr': 'mis à jour à l\'instant'},
    'offline_updated_min': {'fr': 'mis à jour il y a'},
    'offline_retry': {'fr': 'Réessayer la connexion'},

    // ── Gestion utilisateurs (admin) ─────────────────────────────────────────
    'user_mgmt_title': {'fr': 'Gestion des Utilisateurs'},
    'user_mgmt_search': {'fr': 'Rechercher un utilisateur…'},
    'user_mgmt_all_roles': {'fr': 'Tous les rôles'},
    'user_mgmt_no_result': {'fr': 'Aucun utilisateur trouvé'},
    'user_mgmt_score': {'fr': 'Score'},
    'user_mgmt_ban': {'fr': 'Désactiver'},
    'user_mgmt_activate': {'fr': 'Activer'},
    'user_mgmt_delete': {'fr': 'Supprimer'},

    // ── Modération (admin) ────────────────────────────────────────────────────
    'mod_pending': {'fr': 'En attente'},
    'mod_approved': {'fr': 'Approuvé'},
    'mod_rejected': {'fr': 'Rejeté'},
    'mod_approve': {'fr': 'Approuver'},
    'mod_reject': {'fr': 'Rejeter'},
    'mod_ai_label': {'fr': 'Analyse IA'},
    'mod_no_pending': {'fr': 'Aucune publication en attente'},

    // ── Éducation / Quiz (commun) ────────────────────────────────────────────
    'edu_no_video': {'fr': 'Aucune vidéo disponible'},
    'edu_no_quiz': {'fr': 'Aucun quiz disponible'},
    'edu_score_you': {'fr': 'Votre score'},
    'edu_correct': {'fr': 'Correct !'},
    'edu_wrong': {'fr': 'Mauvaise réponse'},
    'edu_next': {'fr': 'Question suivante'},
    'edu_finish': {'fr': 'Terminer le quiz'},

    // ── Erreurs communes ─────────────────────────────────────────────────────
    'err_network': {'fr': 'Erreur réseau. Vérifiez votre connexion.'},
    'err_server': {'fr': 'Erreur serveur. Réessayez plus tard.'},
    'err_unauthorized': {'fr': 'Session expirée. Reconnectez-vous.'},
    'err_not_found': {'fr': 'Introuvable.'},
    'err_unknown': {'fr': 'Une erreur est survenue.'},

    // ── Chargement ────────────────────────────────────────────────────────────
    'loading': {'fr': 'Chargement…'},
    'loading_data': {'fr': 'Chargement des données…'},
    'no_data': {'fr': 'Aucune donnée disponible'},

    // ── Actions communes ──────────────────────────────────────────────────────
    'btn_save': {'fr': 'Enregistrer'},
    'btn_cancel': {'fr': 'Annuler'},
    'btn_confirm': {'fr': 'Confirmer'},
    'btn_delete': {'fr': 'Supprimer'},
    'btn_edit': {'fr': 'Modifier'},
    'btn_share': {'fr': 'Partager'},
    'btn_send': {'fr': 'Envoyer'},
    'btn_close': {'fr': 'Fermer'},

    // ── Messagerie ────────────────────────────────────────────────────────────
    'msg_title': {'fr': 'Messagerie'},
    'msg_new': {'fr': 'Nouvelle conversation'},
    'msg_placeholder': {'fr': 'Écrivez un message…'},
    'msg_empty': {'fr': 'Aucune conversation'},
    'msg_empty_sub': {'fr': 'Démarrez une nouvelle discussion'},

    // ── Carte / Points de collecte ────────────────────────────────────────────
    'map_title': {'fr': 'Points de Collecte'},
    'map_search': {'fr': 'Rechercher un centre…'},
    'map_available': {'fr': 'Disponible'},
    'map_saturated': {'fr': 'Saturé'},
    'map_maintenance': {'fr': 'Maintenance'},
    'map_directions': {'fr': 'Itinéraire'},
  };

  static String tr(String key) {
    return _keys[key]?['fr'] ?? key;
  }
}
