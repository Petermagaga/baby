class MatchedUser {
  final int id;
  final String username;
  final String email;
  final String location;
  final double distanceKm;

  MatchedUser({
    required this.id,
    required this.username,
    required this.email,
    required this.location,
    required this.distanceKm,
  });

  factory MatchedUser.fromJson(Map<String, dynamic> json) {
    return MatchedUser(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      location: json['location'] ?? '',
      distanceKm: (json['distance_km'] ?? 0).toDouble(),
    );
  }
}
