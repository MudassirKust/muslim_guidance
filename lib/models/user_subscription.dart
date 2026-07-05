import 'package:cloud_firestore/cloud_firestore.dart';

class UserSubscription {
  final String uid;
  final String email;
  final String displayName;
  final String plan; // 'monthly' or 'yearly'
  final DateTime subscribedAt;
  final DateTime expiresAt;
  final bool isActive;

  const UserSubscription({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.plan,
    required this.subscribedAt,
    required this.expiresAt,
    required this.isActive,
  });

  factory UserSubscription.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final subscribedAt = (data['subscribedAt'] as Timestamp).toDate();
    final expiresAt = (data['expiresAt'] as Timestamp).toDate();
    return UserSubscription(
      uid: data['uid'] as String,
      email: data['email'] as String,
      displayName: data['displayName'] as String,
      plan: data['plan'] as String,
      subscribedAt: subscribedAt,
      expiresAt: expiresAt,
      isActive: expiresAt.isAfter(DateTime.now()),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'plan': plan,
      'subscribedAt': Timestamp.fromDate(subscribedAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'isActive': isActive,
    };
  }
}
