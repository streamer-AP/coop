enum AvatarPreset {
  flower('发光花朵', 'assets/avatars/flower.png'),
  star('发光星星', 'assets/avatars/star.png'),
  meteor('发光流星', 'assets/avatars/meteor.png'),
  feather('发光羽毛', 'assets/avatars/feather.png'),
  crystal('发光水晶', 'assets/avatars/crystal.png'),
  aurora('发光极光', 'assets/avatars/aurora.png');

  const AvatarPreset(this.label, this.assetPath);

  final String label;
  final String assetPath;
}
