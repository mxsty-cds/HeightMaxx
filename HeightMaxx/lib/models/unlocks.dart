enum UnlockType { theme, avatarTier, workoutTier }

class UnlockableReward {
  final String id;
  final UnlockType type;
  final String name;
  final String description;
  final int unlockLevel;

  const UnlockableReward({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.unlockLevel,
  });
}