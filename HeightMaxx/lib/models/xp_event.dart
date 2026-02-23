enum XpActionType { 
  stretch, 
  postureCheck, 
  hydrationLog, 
  taskCompletion, 
  dailyBonus 
}

class XpEvent {
  final String id;
  final XpActionType type;
  final int xpAmount;
  final DateTime createdAt;

  const XpEvent({
    required this.id,
    required this.type,
    required this.xpAmount,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'xpAmount': xpAmount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory XpEvent.fromJson(Map<String, dynamic> json) {
    return XpEvent(
      id: json['id'] as String,
      // Map string back to enum safely
      type: XpActionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => XpActionType.taskCompletion,
      ),
      xpAmount: json['xpAmount'] as int? ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : DateTime.now(),
    );
  }
}