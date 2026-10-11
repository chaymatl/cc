enum UserRole { citoyen, admin, superadmin, educator, intercommunality, collector }

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final int points;
  final double globalScore;
  final String avatarUrl;
  final String qrCode;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.points = 0,
    this.globalScore = 0.0,
    this.avatarUrl = '',
    this.qrCode = '',
  });

  /// Cree un User depuis la reponse du backend.
  /// Si data['id'] est null, id vaut '' (chaine vide) et non "0",
  /// ce qui empeche le listener Firebase d'ecouter /scores/0.
  factory User.fromBackend(Map<String, dynamic> data) {
    return User(
      id: data['id']?.toString() ?? '',
      name: data['full_name'] ?? 'Utilisateur',
      email: data['email'] ?? '',
      role: _parseRole(data['role'] ?? 'citoyen'),
      points: (data['points'] as num?)?.toInt() ?? 0,
      globalScore: data['global_score'] != null
          ? double.tryParse(data['global_score'].toString()) ?? 0.0
          : 0.0,
      avatarUrl: data['avatar_url'] ?? '',
      qrCode: data['qr_code'] ?? '',
    );
  }

  static UserRole _parseRole(String role) {
    switch (role) {
      case 'superadmin': return UserRole.superadmin;
      case 'admin': return UserRole.admin;
      case 'educator': return UserRole.educator;
      case 'intercommunality': return UserRole.intercommunality;
      case 'collector': return UserRole.collector;
      case 'citoyen':
      case 'user':
        return UserRole.citoyen;
      default: return UserRole.citoyen;
    }
  }

  String get roleDisplayName {
    switch (role) {
      case UserRole.superadmin: return 'Super Administrateur';
      case UserRole.admin: return 'Administrateur';
      case UserRole.educator: return 'Educateur';
      case UserRole.intercommunality: return 'Intercommunalite';
      case UserRole.collector: return 'Collecteur';
      default: return 'Citoyen';
    }
  }

  User copyWithScore(double newScore) => User(
    id: id, name: name, email: email, role: role,
    points: points, globalScore: newScore,
    avatarUrl: avatarUrl, qrCode: qrCode,
  );
}

class AuthState {
  static User? currentUser;

  static void loginFromBackend(Map<String, dynamic> data) {
    currentUser = User.fromBackend(data);
    final token = data['access_token']?.toString();
    if (token != null && token.isNotEmpty) authToken = token;
  }

  static void logout() { currentUser = null; }

  static String? authToken;

  static Map<String, String> get authHeader =>
      authToken != null ? {'Authorization': 'Bearer $authToken'} : {};

  static bool get isLoggedIn => currentUser != null;

  /// Vrai seulement si un token JWT valide est en memoire.
  /// Guard a utiliser avant tout appel API protege.
  static bool get hasValidToken => authToken != null;

  static bool get isAdmin => currentUser?.role == UserRole.admin || currentUser?.role == UserRole.superadmin;
}
