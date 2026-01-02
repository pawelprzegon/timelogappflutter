class ContractInfo {
  final int id;
  final String contractType;
  final String contractPosition;
  final double baseWage;

  const ContractInfo({
    required this.id,
    required this.contractType,
    required this.contractPosition,
    required this.baseWage,
  });

  factory ContractInfo.fromJson(Map<String, dynamic> json) {
    return ContractInfo(
      id: (json['id'] ?? 0) as int,
      contractType: (json['contractType'] ?? '').toString(),
      contractPosition: (json['contractPosition'] ?? '').toString(),
      baseWage: (json['baseWage'] is num) ? (json['baseWage'] as num).toDouble() : 0.0,
    );
  }
}

class ActiveSession {
  final int id;
  final int userId;
  final ContractInfo? contract;
  final DateTime? start;
  final DateTime? workbreak;

  const ActiveSession({
    required this.id,
    required this.userId,
    required this.contract,
    required this.start,
    required this.workbreak,
  });

  factory ActiveSession.fromJson(Map<String, dynamic> json) {
    return ActiveSession(
      id: (json['id'] ?? 0) as int,
      userId: (json['userId'] ?? 0) as int,
      contract: (json['contract'] is Map<String, dynamic>)
          ? ContractInfo.fromJson(json['contract'] as Map<String, dynamic>)
          : null,
      start: _parseDt(json['start']),
      workbreak: _parseDt(json['workbreak']),
    );
  }

  bool get hasShift => start != null;
  bool get isOnBreak => workbreak != null;
}

DateTime? _parseDt(dynamic v) {
  if (v == null) return null;
  if (v is String && v.trim().isNotEmpty) return DateTime.tryParse(v);
  return null;
}
