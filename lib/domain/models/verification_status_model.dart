enum VerificationStatus {
  unverified,
  pending,
  verified,
  expired,
  failed
}

class VerificationStatusModel {
  final VerificationStatus status;
  final DateTime? lastSentAt;
  final DateTime? verifiedAt;
  final String? errorMessage;
  final int resendCount;

  const VerificationStatusModel({
    required this.status,
    this.lastSentAt,
    this.verifiedAt,
    this.errorMessage,
    this.resendCount = 0,
  });

  factory VerificationStatusModel.fromMap(Map<String, dynamic> data) {
    return VerificationStatusModel(
      status: VerificationStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => VerificationStatus.unverified,
      ),
      lastSentAt: data['lastSentAt']?.toDate(),
      verifiedAt: data['verifiedAt']?.toDate(),
      errorMessage: data['errorMessage'],
      resendCount: data['resendCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'lastSentAt': lastSentAt,
      'verifiedAt': verifiedAt,
      'errorMessage': errorMessage,
      'resendCount': resendCount,
    };
  }

  VerificationStatusModel copyWith({
    VerificationStatus? status,
    DateTime? lastSentAt,
    DateTime? verifiedAt,
    String? errorMessage,
    int? resendCount,
  }) {
    return VerificationStatusModel(
      status: status ?? this.status,
      lastSentAt: lastSentAt ?? this.lastSentAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      resendCount: resendCount ?? this.resendCount,
    );
  }

  bool get isVerified => status == VerificationStatus.verified;
  bool get isPending => status == VerificationStatus.pending;
  bool get canResend => resendCount < 5 && status != VerificationStatus.verified;
}
