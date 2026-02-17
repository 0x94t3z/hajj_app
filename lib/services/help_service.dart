import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hajj_app/helpers/name_formatter.dart';
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

  DatabaseReference get _conversationsRef => _database.ref('helpConversations');

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

  Future<_CurrentUserContext> _currentUserContext() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Silakan login untuk menggunakan fitur bantuan.');
    }

    final profile = await _userService.fetchCurrentUserProfile() ??
        _userService.getCachedCurrentUserProfile() ??
        <String, dynamic>{};
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

    final roleLabel = role.trim().isNotEmpty
        ? role.trim()
        : (isPetugas ? 'Petugas Haji' : 'Jemaah Haji');

    return _CurrentUserContext(
      uid: user.uid,
      name: name,
      imageUrl: imageUrl,
      isPetugas: isPetugas,
      role: roleLabel,
    );
  }

  String buildConversationId({
    required String pilgrimId,
    required String officerId,
  }) {
    return '${pilgrimId}_$officerId';
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

    final conversationId = buildConversationId(
      pilgrimId: pilgrimId,
      officerId: officerId,
    );
    final conversationRef = _conversationsRef.child(conversationId);

    final baseData = <String, dynamic>{
      'conversationId': conversationId,
      'pilgrimId': pilgrimId,
      'pilgrimName': pilgrimName,
      'pilgrimImageUrl': pilgrimImageUrl,
      'pilgrimRole': pilgrimRole,
      'officerId': officerId,
      'officerName': officerName,
      'officerImageUrl': officerImageUrl,
      'officerRole': officerRole,
      // Keep conversation heartbeat fresh for inbox ordering.
      'updatedAt': ServerValue.timestamp,
    };

    try {
      await conversationRef.update(baseData);
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
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final current = await _currentUserContext();
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
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
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
  });

  final String uid;
  final String name;
  final String imageUrl;
  final bool isPetugas;
  final String role;
}
