import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hajj_app/core/utils/name_formatter.dart';
import 'package:hajj_app/services/user_service.dart';

class HelpService {
  HelpService({
    FirebaseAuth? auth,
    FirebaseDatabase? database,
    UserService? userService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _database = database ?? FirebaseDatabase.instance,
        _userService = userService ?? UserService();

  final FirebaseAuth _auth;
  final FirebaseDatabase _database;
  final UserService _userService;

  static const List<String> defaultHelpTemplates = [
    'Saya tersesat',
    'Saya butuh pertolongan medis',
    'Saya terpisah dari rombongan',
    'Saya tidak menemukan tenda/kloter saya',
    'Saya kehabisan air atau makanan',
  ];

  static const List<String> defaultOfficerQuickReplies = [
    'Baik, saya menuju lokasi Anda sekarang.',
    'Tetap tenang, saya akan bantu Anda.',
    'Silakan tunggu di tempat aman terdekat.',
    'Jika darurat medis, saya koordinasikan tim kesehatan.',
  ];

  static const Map<String, List<String>> defaultOfficerQuickRepliesByRequest = {
    'Saya tersesat': [
      'Tenang, saya akan menjemput Anda. Tetap di lokasi aman.',
      'Mohon kirim patokan terdekat. Saya segera ke sana.',
      'Saya menuju Anda sekarang. Tetap di tempat aman.',
    ],
    'Saya butuh pertolongan medis': [
      'Saya koordinasikan tim kesehatan sekarang.',
      'Mohon tetap tenang, bantuan medis segera datang.',
      'Saya akan datangi lokasi Anda. Jika darurat, mohon hubungi petugas terdekat.',
    ],
    'Saya terpisah dari rombongan': [
      'Tetap di lokasi saat ini, saya akan membantu Anda.',
      'Mohon informasikan patokan terdekat. Saya segera ke sana.',
      'Saya menuju lokasi Anda sekarang.',
    ],
    'Saya tidak menemukan tenda/kloter saya': [
      'Mohon beri nomor kloter, saya bantu arahkan.',
      'Saya akan bantu Anda menuju tenda/kloter.',
      'Mohon tunggu di titik aman, saya segera ke sana.',
    ],
    'Saya kehabisan air atau makanan': [
      'Saya segera menuju lokasi Anda dengan bantuan logistik.',
      'Mohon tunggu di tempat aman terdekat.',
      'Saya akan bantu Anda, tetap tenang.',
    ],
  };

  static List<String> officerRepliesForRequest(String request) {
    return defaultOfficerQuickRepliesByRequest[request] ??
        defaultOfficerQuickReplies;
  }

  static const List<String> defaultPilgrimFollowUpReplies = [
    'Alhamdulillah, terima kasih banyak 🙏🏻',
    'Baik, saya tunggu!',
    'Terima kasih, saya akan mengikuti arahan.',
  ];

  DatabaseReference get _conversationsRef => _database.ref('helpConversations');
  DatabaseReference get _activeSessionsRef =>
      _database.ref('helpConversationSessions');

  Exception _permissionDeniedError() {
    return Exception(
      'Akses pesan bantuan ditolak oleh Firebase Rules. '
      'Aktifkan aturan read/write untuk partisipan di node helpConversations.',
    );
  }

  int _toMillis(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double _toDoubleValue(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Future<_CurrentUserContext> _currentUserContext() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Silakan login untuk menggunakan fitur bantuan.');
    }

    Map<String, dynamic> profile =
        await _userService.fetchCurrentUserProfile() ??
            _userService.getCachedCurrentUserProfile() ??
            <String, dynamic>{};

    final cachedLat = _toDoubleValue(profile['latitude']);
    final cachedLng = _toDoubleValue(profile['longitude']);
    if (cachedLat == 0.0 || cachedLng == 0.0) {
      final refreshed = await _userService.fetchCurrentUserProfile(
        forceRefresh: true,
      );
      if (refreshed != null && refreshed.isNotEmpty) {
        profile = refreshed;
      }
    }
    final role = profile['roles']?.toString() ?? 'Jemaah Haji';
    final name = toTitleCaseName(
      profile['displayName']?.toString().trim().isNotEmpty == true
          ? profile['displayName'].toString().trim()
          : (user.displayName?.trim().isNotEmpty == true
              ? user.displayName!.trim()
              : user.email?.trim() ?? 'User'),
    );
    final imageUrl = profile['imageUrl']?.toString().trim() ?? '';
    final isPetugas = _userService.isPetugasHajiRole(role);
    final latitude = _toDoubleValue(profile['latitude']);
    final longitude = _toDoubleValue(profile['longitude']);

    final roleLabel = role.trim().isNotEmpty
        ? role.trim()
        : (isPetugas ? 'Petugas Haji' : 'Jemaah Haji');

    return _CurrentUserContext(
      uid: user.uid,
      name: name,
      imageUrl: imageUrl,
      isPetugas: isPetugas,
      role: roleLabel,
      latitude: latitude,
      longitude: longitude,
    );
  }

  String buildConversationId({
    required String pilgrimId,
    required String officerId,
  }) {
    return '${pilgrimId}_$officerId';
  }

  String _buildSessionConversationId(String pairKey) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${pairKey}_$timestamp';
  }

  Future<HelpConversationHandle> ensureConversationWithPeer({
    required String peerId,
    required String peerName,
    String peerImageUrl = '',
    required bool peerIsPetugas,
    String peerRole = '',
  }) async {
    final current = await _currentUserContext();

    late final String pilgrimId;
    late final String pilgrimName;
    late final String pilgrimImageUrl;
    late final String pilgrimRole;
    late final String officerId;
    late final String officerName;
    late final String officerImageUrl;
    late final String officerRole;

    if (current.isPetugas) {
      officerId = current.uid;
      officerName = current.name;
      officerImageUrl = current.imageUrl;
      officerRole = current.role;
      pilgrimId = peerId;
      pilgrimName = toTitleCaseName(peerName);
      pilgrimImageUrl = peerImageUrl;
      pilgrimRole =
          peerRole.trim().isNotEmpty ? peerRole.trim() : 'Jemaah Haji';
    } else {
      pilgrimId = current.uid;
      pilgrimName = current.name;
      pilgrimImageUrl = current.imageUrl;
      pilgrimRole = current.role;
      officerId = peerId;
      officerName = toTitleCaseName(peerName);
      officerImageUrl = peerImageUrl;
      officerRole =
          peerRole.trim().isNotEmpty ? peerRole.trim() : 'Petugas Haji';
    }

    if (pilgrimId.isEmpty || officerId.isEmpty) {
      throw Exception('Data percakapan tidak valid.');
    }

    final pairKey = buildConversationId(
      pilgrimId: pilgrimId,
      officerId: officerId,
    );
    String conversationId = '';

    try {
      final activeSnapshot = await _activeSessionsRef.child(pairKey).get();
      if (activeSnapshot.exists && activeSnapshot.value != null) {
        final activeId = activeSnapshot.value.toString();
        if (activeId.isNotEmpty) {
          final activeConvSnap = await _conversationsRef.child(activeId).get();
          if (activeConvSnap.exists && activeConvSnap.value is Map) {
            final activeData =
                Map<String, dynamic>.from(activeConvSnap.value as Map);
            final status = activeData['status']?.toString() ?? 'open';
            final archived = activeData['archived'] == true;
            if (status != 'closed' && !archived) {
              conversationId = activeId;
            }
          }
        }
      }
    } catch (_) {
      // If session lookup fails, fall back to legacy behavior.
    }

    if (conversationId.isEmpty) {
      final legacyId = pairKey;
      try {
        final legacySnap = await _conversationsRef.child(legacyId).get();
        if (legacySnap.exists && legacySnap.value is Map) {
          final legacyData = Map<String, dynamic>.from(legacySnap.value as Map);
          final status = legacyData['status']?.toString() ?? 'open';
          final archived = legacyData['archived'] == true;
          if (status != 'closed' && !archived) {
            conversationId = legacyId;
          }
        }
      } catch (_) {
        // Ignore legacy lookup errors.
      }
    }

    if (conversationId.isEmpty) {
      conversationId = _buildSessionConversationId(pairKey);
    }

    final conversationRef = _conversationsRef.child(conversationId);

    final baseData = <String, dynamic>{
      'conversationId': conversationId,
      'pairKey': pairKey,
      'pilgrimId': pilgrimId,
      'pilgrimName': pilgrimName,
      'pilgrimImageUrl': pilgrimImageUrl,
      'pilgrimRole': pilgrimRole,
      'officerId': officerId,
      'officerName': officerName,
      'officerImageUrl': officerImageUrl,
      'officerRole': officerRole,
      'status': 'open',
      'archived': false,
      'openedAt': ServerValue.timestamp,
      // Keep conversation heartbeat fresh for inbox ordering.
      'updatedAt': ServerValue.timestamp,
    };

    if (current.latitude != 0.0 || current.longitude != 0.0) {
      if (current.isPetugas) {
        baseData['officerLat'] = current.latitude;
        baseData['officerLng'] = current.longitude;
        baseData['officerLocationUpdatedAt'] = ServerValue.timestamp;
      } else {
        baseData['pilgrimLat'] = current.latitude;
        baseData['pilgrimLng'] = current.longitude;
        baseData['pilgrimLocationUpdatedAt'] = ServerValue.timestamp;
      }
    }

    try {
      await conversationRef.update(baseData);

      // Persist active session pointer only after the conversation exists.
      // This allows Firebase Rules to validate participants from the conversation node.
      if (pairKey.isNotEmpty) {
        try {
          await _activeSessionsRef.child(pairKey).set(conversationId);
        } catch (_) {
          // Keep going even if we cannot write session pointer.
        }
      }
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw _permissionDeniedError();
      }
      rethrow;
    }

    return HelpConversationHandle(
      conversationId: conversationId,
      currentIsPetugas: current.isPetugas,
      peerIsPetugas: peerIsPetugas,
      peerId: peerId,
      peerName: peerName,
      peerImageUrl: peerImageUrl,
      peerRole: peerRole.trim().isNotEmpty
          ? peerRole.trim()
          : (peerIsPetugas ? 'Petugas Haji' : 'Jemaah Haji'),
    );
  }

  Future<void> sendMessage({
    required String conversationId,
    required String text,
    String type = 'custom',
    String templateKey = '',
    double? senderLatitude,
    double? senderLongitude,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final current = await _currentUserContext();
    final messageLatitude = senderLatitude ?? current.latitude;
    final messageLongitude = senderLongitude ?? current.longitude;
    final messageRef =
        _conversationsRef.child(conversationId).child('messages').push();

    try {
      await messageRef.set({
        'id': messageRef.key ?? '',
        'senderId': current.uid,
        'senderName': current.name,
        'senderImageUrl': current.imageUrl,
        'senderRole': current.role,
        'senderRoleType': current.isPetugas ? 'petugas' : 'jemaah',
        'senderLat': messageLatitude,
        'senderLng': messageLongitude,
        'text': trimmed,
        'type': type,
        'templateKey': templateKey,
        'createdAt': ServerValue.timestamp,
      });

      await _conversationsRef.child(conversationId).update({
        'lastMessage': trimmed,
        'lastSenderId': current.uid,
        'lastSenderName': current.name,
        'lastMessageAt': ServerValue.timestamp,
        'lastMessageType': type,
        if (messageLatitude != 0.0 || messageLongitude != 0.0)
          if (current.isPetugas) ...{
            'officerLat': messageLatitude,
            'officerLng': messageLongitude,
            'officerLocationUpdatedAt': ServerValue.timestamp,
          } else ...{
            'pilgrimLat': messageLatitude,
            'pilgrimLng': messageLongitude,
            'pilgrimLocationUpdatedAt': ServerValue.timestamp,
          },
        'readMeta/${current.uid}/lastReadAt': ServerValue.timestamp,
        'readMeta/${current.uid}/updatedAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      });

      await _enqueueNotificationRequest(
        conversationId: conversationId,
        sender: current,
        messageText: trimmed,
      );
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw _permissionDeniedError();
      }
      rethrow;
    }
  }

  Future<void> markConversationAsRead(String conversationId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || conversationId.trim().isEmpty) return;

    try {
      await _conversationsRef.child(conversationId).update({
        'readMeta/$uid/lastReadAt': ServerValue.timestamp,
        'readMeta/$uid/updatedAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return;
      }
      rethrow;
    }
  }

  Future<void> closeConversation(String conversationId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || conversationId.trim().isEmpty) return;

    try {
      final snapshot = await _conversationsRef.child(conversationId).get();
      if (!snapshot.exists || snapshot.value == null) return;
      if (snapshot.value is! Map) return;
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      final pilgrimId = data['pilgrimId']?.toString() ?? '';
      final officerId = data['officerId']?.toString() ?? '';
      final lastMessage = data['lastMessage']?.toString().trim() ?? '';
      final messagesNode = data['messages'];
      final hasMessages = lastMessage.isNotEmpty ||
          (messagesNode is Map && messagesNode.isNotEmpty);
      var hasOfficerReply = false;
      if (messagesNode is Map) {
        for (final value in messagesNode.values) {
          if (value is! Map) continue;
          final messageMap = Map<String, dynamic>.from(value);
          final senderId = messageMap['senderId']?.toString() ?? '';
          if (senderId == officerId && senderId.isNotEmpty) {
            hasOfficerReply = true;
            break;
          }
        }
      }
      final lastSenderId = data['lastSenderId']?.toString() ?? '';
      if (lastSenderId.isNotEmpty && lastSenderId == officerId) {
        hasOfficerReply = true;
      }
      final pairKey = data['pairKey']?.toString().trim().isNotEmpty == true
          ? data['pairKey'].toString()
          : (pilgrimId.isNotEmpty && officerId.isNotEmpty
              ? buildConversationId(
                  pilgrimId: pilgrimId,
                  officerId: officerId,
                )
              : '');

      if (!hasMessages) {
        await _conversationsRef.child(conversationId).remove();
        if (pairKey.isNotEmpty) {
          await _activeSessionsRef.child(pairKey).remove();
        }
        return;
      }

      // If officer has never replied yet, remove the conversation entirely
      // instead of archiving it.
      if (!hasOfficerReply) {
        await _conversationsRef.child(conversationId).remove();
        if (pairKey.isNotEmpty) {
          await _activeSessionsRef.child(pairKey).remove();
        }
        return;
      }

      await _conversationsRef.child(conversationId).update({
        'status': 'closed',
        'archived': true,
        'closedAt': ServerValue.timestamp,
        'closedBy': uid,
        'updatedAt': ServerValue.timestamp,
      });

      if (pairKey.isNotEmpty) {
        await _activeSessionsRef.child(pairKey).remove();
      }
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw _permissionDeniedError();
      }
      rethrow;
    }
  }

  Future<void> _enqueueNotificationRequest({
    required String conversationId,
    required _CurrentUserContext sender,
    required String messageText,
  }) async {
    try {
      final conversationSnapshot =
          await _conversationsRef.child(conversationId).get();
      if (!conversationSnapshot.exists || conversationSnapshot.value == null) {
        return;
      }
      if (conversationSnapshot.value is! Map) return;
      final conversationMap =
          Map<String, dynamic>.from(conversationSnapshot.value as Map);
      final officerId = conversationMap['officerId']?.toString() ?? '';
      final pilgrimId = conversationMap['pilgrimId']?.toString() ?? '';
      final receiverUid = sender.uid == officerId ? pilgrimId : officerId;
      if (receiverUid.isEmpty) return;

      final requestRef = _database.ref('helpNotificationRequests').push();
      await requestRef.set({
        'id': requestRef.key ?? '',
        'receiverUid': receiverUid,
        'senderUid': sender.uid,
        'senderName': sender.name,
        'senderRole': sender.role,
        'conversationId': conversationId,
        'title': 'Pesan bantuan baru',
        'body': '${sender.name}: $messageText',
        'createdAt': ServerValue.timestamp,
        'status': 'pending',
      });
    } on FirebaseException {
      // Notification queue is optional and should not block chat.
    }
  }

  Stream<List<HelpMessage>> watchMessages(String conversationId) {
    return _conversationsRef
        .child(conversationId)
        .child('messages')
        .onValue
        .map((event) {
      final raw = event.snapshot.value;
      if (raw is! Map) return <HelpMessage>[];
      final entries = raw.entries
          .map((entry) {
            if (entry.value is! Map) return null;
            final map = Map<String, dynamic>.from(entry.value as Map);
            map['id'] = map['id']?.toString().isNotEmpty == true
                ? map['id'].toString()
                : entry.key.toString();
            return HelpMessage.fromMap(map);
          })
          .whereType<HelpMessage>()
          .toList()
        ..sort((a, b) {
          final createdAtComparison = a.createdAt.compareTo(b.createdAt);
          if (createdAtComparison != 0) return createdAtComparison;
          return a.id.compareTo(b.id);
        });
      return entries;
    });
  }

  Stream<List<HelpConversationSummary>> watchInbox({
    required String currentUid,
    required bool currentIsPetugas,
  }) {
    final query = currentIsPetugas
        ? _conversationsRef.orderByChild('officerId').equalTo(currentUid)
        : _conversationsRef.orderByChild('pilgrimId').equalTo(currentUid);

    return query.onValue.map((event) {
      final raw = event.snapshot.value;
      if (raw is! Map) return <HelpConversationSummary>[];

      final summaries = raw.entries
          .map((entry) {
            if (entry.value is! Map) return null;
            final map = Map<String, dynamic>.from(entry.value as Map);
            map['conversationId'] =
                map['conversationId']?.toString().isNotEmpty == true
                    ? map['conversationId'].toString()
                    : entry.key.toString();
            final status = map['status']?.toString() ?? 'open';
            final archived = map['archived'] == true;
            if (status == 'closed' || archived) return null;
            return HelpConversationSummary.fromMap(
              map,
              currentUid: currentUid,
              currentIsPetugas: currentIsPetugas,
              toMillis: _toMillis,
            );
          })
          .whereType<HelpConversationSummary>()
          .toList()
        ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));

      return summaries;
    });
  }

  Stream<List<HelpConversationSummary>> watchArchivedInbox({
    required String currentUid,
    required bool currentIsPetugas,
  }) {
    final query = currentIsPetugas
        ? _conversationsRef.orderByChild('officerId').equalTo(currentUid)
        : _conversationsRef.orderByChild('pilgrimId').equalTo(currentUid);

    return query.onValue.map((event) {
      final raw = event.snapshot.value;
      if (raw is! Map) return <HelpConversationSummary>[];

      final summaries = raw.entries
          .map((entry) {
            if (entry.value is! Map) return null;
            final map = Map<String, dynamic>.from(entry.value as Map);
            map['conversationId'] =
                map['conversationId']?.toString().isNotEmpty == true
                    ? map['conversationId'].toString()
                    : entry.key.toString();
            final status = map['status']?.toString() ?? 'open';
            final archived = map['archived'] == true;
            if (status != 'closed' && !archived) return null;
            return HelpConversationSummary.fromMap(
              map,
              currentUid: currentUid,
              currentIsPetugas: currentIsPetugas,
              toMillis: _toMillis,
            );
          })
          .whereType<HelpConversationSummary>()
          .toList()
        ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));

      return summaries;
    });
  }

  Future<Map<String, dynamic>?> fetchConversationById(
    String conversationId,
  ) async {
    if (conversationId.trim().isEmpty) return null;
    try {
      final snapshot = await _conversationsRef.child(conversationId).get();
      if (!snapshot.exists || snapshot.value == null) return null;
      if (snapshot.value is! Map) return null;
      return Map<String, dynamic>.from(snapshot.value as Map);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return null;
      }
      rethrow;
    }
  }

  Future<Map<String, double>?> fetchConversationPeerLocation({
    required String conversationId,
    required bool currentIsPetugas,
  }) async {
    if (conversationId.trim().isEmpty) return null;
    try {
      final snapshot = await _conversationsRef.child(conversationId).get();
      if (!snapshot.exists || snapshot.value == null) return null;
      if (snapshot.value is! Map) return null;
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final latKey = currentIsPetugas ? 'pilgrimLat' : 'officerLat';
      final lngKey = currentIsPetugas ? 'pilgrimLng' : 'officerLng';
      final latitude = _toDoubleValue(data[latKey]);
      final longitude = _toDoubleValue(data[lngKey]);
      if (latitude == 0.0 || longitude == 0.0) return null;
      return {
        'latitude': latitude,
        'longitude': longitude,
      };
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return null;
      }
      rethrow;
    }
  }

  Future<Map<String, double>?> fetchLatestPeerMessageLocation({
    required String conversationId,
    required String peerId,
  }) async {
    if (conversationId.trim().isEmpty || peerId.trim().isEmpty) return null;
    try {
      final snapshot =
          await _conversationsRef.child(conversationId).child('messages').get();
      if (!snapshot.exists || snapshot.value == null) return null;
      if (snapshot.value is! Map) return null;

      final messages = Map<String, dynamic>.from(snapshot.value as Map);
      int latestAt = 0;
      double latestLat = 0.0;
      double latestLng = 0.0;

      for (final value in messages.values) {
        if (value is! Map) continue;
        final map = Map<String, dynamic>.from(value);
        final senderId = map['senderId']?.toString() ?? '';
        if (senderId != peerId) continue;
        final createdAt = _toMillis(map['createdAt']);
        final lat = _toDoubleValue(map['senderLat']);
        final lng = _toDoubleValue(map['senderLng']);
        if (lat == 0.0 || lng == 0.0) continue;
        if (createdAt >= latestAt) {
          latestAt = createdAt;
          latestLat = lat;
          latestLng = lng;
        }
      }

      if (latestLat == 0.0 || latestLng == 0.0) return null;
      return {
        'latitude': latestLat,
        'longitude': latestLng,
      };
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return null;
      }
      rethrow;
    }
  }
}

class HelpConversationHandle {
  const HelpConversationHandle({
    required this.conversationId,
    required this.currentIsPetugas,
    required this.peerIsPetugas,
    required this.peerId,
    required this.peerName,
    required this.peerImageUrl,
    required this.peerRole,
  });

  final String conversationId;
  final bool currentIsPetugas;
  final bool peerIsPetugas;
  final String peerId;
  final String peerName;
  final String peerImageUrl;
  final String peerRole;
}

class HelpConversationSummary {
  const HelpConversationSummary({
    required this.conversationId,
    required this.peerId,
    required this.peerName,
    required this.peerImageUrl,
    required this.peerIsPetugas,
    required this.peerRole,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.lastSenderId,
    required this.unreadMessageCount,
    required this.peerLatitude,
    required this.peerLongitude,
    required this.status,
    required this.archived,
  });

  final String conversationId;
  final String peerId;
  final String peerName;
  final String peerImageUrl;
  final bool peerIsPetugas;
  final String peerRole;
  final String lastMessage;
  final int lastMessageAt;
  final String lastSenderId;
  final int unreadMessageCount;
  final double peerLatitude;
  final double peerLongitude;
  final String status;
  final bool archived;

  static double _toDoubleValue(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory HelpConversationSummary.fromMap(
    Map<String, dynamic> data, {
    required String currentUid,
    required bool currentIsPetugas,
    required int Function(dynamic value) toMillis,
  }) {
    final peerId = currentIsPetugas
        ? data['pilgrimId']?.toString() ?? ''
        : data['officerId']?.toString() ?? '';
    final peerName = currentIsPetugas
        ? data['pilgrimName']?.toString() ?? 'Jemaah'
        : data['officerName']?.toString() ?? 'Petugas';
    final peerImageUrl = currentIsPetugas
        ? data['pilgrimImageUrl']?.toString() ?? ''
        : data['officerImageUrl']?.toString() ?? '';
    final peerRole = currentIsPetugas
        ? data['pilgrimRole']?.toString().trim()
        : data['officerRole']?.toString().trim();
    final lastMessageAt = toMillis(data['lastMessageAt']);
    final lastSenderId = data['lastSenderId']?.toString() ?? '';
    final pilgrimLat = _toDoubleValue(data['pilgrimLat']);
    final pilgrimLng = _toDoubleValue(data['pilgrimLng']);
    final officerLat = _toDoubleValue(data['officerLat']);
    final officerLng = _toDoubleValue(data['officerLng']);
    final status = data['status']?.toString() ?? 'open';
    final archived = data['archived'] == true;

    int lastReadAt = 0;
    final readMetaRaw = data['readMeta'];
    if (readMetaRaw is Map && currentUid.isNotEmpty) {
      final currentReadMeta = readMetaRaw[currentUid];
      if (currentReadMeta is Map) {
        lastReadAt = toMillis(currentReadMeta['lastReadAt']);
      }
    }

    var unreadMessageCount = 0;
    final messagesRaw = data['messages'];
    if (messagesRaw is Map) {
      for (final value in messagesRaw.values) {
        if (value is! Map) continue;
        final senderId = value['senderId']?.toString() ?? '';
        final createdAt = toMillis(value['createdAt']);
        if (senderId != currentUid && createdAt > lastReadAt) {
          unreadMessageCount++;
        }
      }
    } else if (lastSenderId.isNotEmpty &&
        lastSenderId != currentUid &&
        lastMessageAt > lastReadAt) {
      // Fallback when message map is not present in payload.
      unreadMessageCount = 1;
    }

    return HelpConversationSummary(
      conversationId: data['conversationId']?.toString() ?? '',
      peerId: peerId,
      peerName: toTitleCaseName(peerName),
      peerImageUrl: peerImageUrl,
      peerIsPetugas: !currentIsPetugas,
      peerRole: (peerRole?.isNotEmpty == true)
          ? peerRole!
          : (!currentIsPetugas ? 'Petugas Haji' : 'Jemaah Haji'),
      lastMessage: data['lastMessage']?.toString() ?? '',
      lastMessageAt: lastMessageAt,
      lastSenderId: lastSenderId,
      unreadMessageCount: unreadMessageCount,
      peerLatitude: currentIsPetugas ? pilgrimLat : officerLat,
      peerLongitude: currentIsPetugas ? pilgrimLng : officerLng,
      status: status,
      archived: archived,
    );
  }
}

class HelpMessage {
  const HelpMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.text,
    required this.type,
    required this.createdAt,
  });

  final String id;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String text;
  final String type;
  final int createdAt;

  factory HelpMessage.fromMap(Map<String, dynamic> data) {
    int parseMillis(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return HelpMessage(
      id: data['id']?.toString() ?? '',
      senderId: data['senderId']?.toString() ?? '',
      senderName: toTitleCaseName(data['senderName']?.toString() ?? ''),
      senderRole: data['senderRole']?.toString() ?? '',
      text: data['text']?.toString() ?? '',
      type: data['type']?.toString() ?? 'custom',
      createdAt: parseMillis(data['createdAt']),
    );
  }
}

class _CurrentUserContext {
  const _CurrentUserContext({
    required this.uid,
    required this.name,
    required this.imageUrl,
    required this.isPetugas,
    required this.role,
    required this.latitude,
    required this.longitude,
  });

  final String uid;
  final String name;
  final String imageUrl;
  final bool isPetugas;
  final String role;
  final double latitude;
  final double longitude;
}
