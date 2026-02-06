import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:afriqueen/features/blocked/repository/blocked_repository.dart';

class ReportProfileRepository {
  ReportProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    BlockedRepository? blockedRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _blockedRepository = blockedRepository ?? BlockedRepository();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final BlockedRepository _blockedRepository;

  static const String _reportsCollection = 'reports';

  Future<void> submitProfileReport({
    required String reportedUserId,
    required String categoryKey,
    required String description,
    bool blockUser = false,
  }) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      throw Exception('user-not-authenticated');
    }

    try {
      final existingReport = await _firestore
          .collection(_reportsCollection)
          .where('reporterId', isEqualTo: currentUserId)
          .where('reportedUserId', isEqualTo: reportedUserId)
          .where('context', isEqualTo: 'profile')
          .limit(1)
          .get();

      if (existingReport.docs.isNotEmpty) {
        throw const ReportAlreadySubmittedException();
      }

      await _firestore.collection(_reportsCollection).add({
        'reporterId': currentUserId,
        'reportedUserId': reportedUserId,
        'category': categoryKey,
        'description': description,
        'context': 'profile',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (blockUser) {
        await _blockedRepository.blockUser(reportedUserId);
      }
    } catch (e, stackTrace) {
      debugPrint('ReportProfileRepository.submitProfileReport error: $e');
      debugPrint('$stackTrace');
      rethrow;
    }
  }
}

class ReportAlreadySubmittedException implements Exception {
  const ReportAlreadySubmittedException();
}

