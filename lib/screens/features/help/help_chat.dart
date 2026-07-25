import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hajj_app/core/widgets/app_popup.dart';
import 'package:hajj_app/core/utils/name_formatter.dart';
import 'package:hajj_app/core/theme/app_style.dart';
import 'package:hajj_app/services/help_service.dart';
import 'package:hajj_app/services/user_service.dart';
import 'package:iconsax/iconsax.dart';

class HelpChatScreen extends StatefulWidget {
  const HelpChatScreen({
    super.key,
    required this.peerId,
    required this.peerName,
    required this.peerImageUrl,
    required this.peerIsPetugas,
    required this.peerRole,
    this.conversationId,
    this.readOnly = false,
  });

  final String peerId;
  final String peerName;
  final String peerImageUrl;
  final bool peerIsPetugas;
  final String peerRole;
  final String? conversationId;
  final bool readOnly;

  @override
  State<HelpChatScreen> createState() => _HelpChatScreenState();
}

class _HelpChatScreenState extends State<HelpChatScreen> {
  static const String _defaultProfileAsset =
      'assets/images/default_profile.png';

  final HelpService _helpService = HelpService();
  final UserService _userService = UserService();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  bool _showQuickTemplates = true;

  String? _conversationId;
  bool _isLoading = true;
  bool _isSending = false;
  bool _isArchived = false;
  bool _messageAccessClosed = false;
  bool _currentIsPetugas = false;
  String _peerId = '';
  String _peerName = '';
  String _peerImageUrl = '';
  bool _peerIsPetugas = false;
  String _resolvedPeerRole = '';
  String _lastMarkedReadMessageId = '';
  String? _errorMessage;
  Stream<List<HelpMessage>>? _messagesStream;
  StreamSubscription<Map<String, dynamic>?>? _conversationSubscription;
  StreamSubscription<User?>? _authStateSubscription;
  int _conversationEpoch = 0;

  @override
  void initState() {
    super.initState();
    HelpService.registerHelpChatScreen();
    _peerId = widget.peerId.trim();
    _peerName = widget.peerName.trim();
    _peerImageUrl = UserService.normalizeProfileImageUrl(widget.peerImageUrl);
    _peerIsPetugas = widget.peerIsPetugas;
    _resolvedPeerRole = widget.peerRole.trim();
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (user) {
        if (!mounted) return;
        if (user == null) {
          _conversationEpoch++;
          setState(() {
            _messagesStream = null;
            _conversationId = null;
            _errorMessage = 'Sesi berakhir. Silakan login kembali.';
            _isLoading = false;
          });
        }
      },
    );
    final presetConversationId = widget.conversationId?.trim();
    if (presetConversationId != null && presetConversationId.isNotEmpty) {
      _loadConversationById(presetConversationId);
    } else {
      _prepareConversation();
    }
  }

  @override
  void dispose() {
    HelpService.unregisterHelpChatScreen();
    _conversationSubscription?.cancel();
    _authStateSubscription?.cancel();
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _bindMessagesStream(String conversationId) {
    _messagesStream = _helpService.watchMessages(conversationId);
  }

  void _bindConversationStream(String conversationId) {
    unawaited(_conversationSubscription?.cancel());
    _conversationSubscription =
        _helpService.watchConversation(conversationId).listen((data) {
      if (!mounted || data == null) return;

      final status = data['status']?.toString() ?? HelpService.statusRequested;
      final archived =
          data['archived'] == true || status == HelpService.statusClosed;
      final currentUser = FirebaseAuth.instance.currentUser;
      final officerId = data['officerId']?.toString() ?? '';
      final pilgrimId = data['pilgrimId']?.toString() ?? '';
      final currentIsPetugas = currentUser?.uid == officerId;
      final peerId = currentIsPetugas ? pilgrimId : officerId;

      final peerName = currentIsPetugas
          ? data['pilgrimName']?.toString().trim()
          : data['officerName']?.toString().trim();
      final peerImageUrl = currentIsPetugas
          ? data['pilgrimImageUrl']?.toString().trim()
          : data['officerImageUrl']?.toString().trim();
      final peerRole = currentIsPetugas
          ? data['pilgrimRole']?.toString().trim()
          : data['officerRole']?.toString().trim();

      setState(() {
        _isArchived = widget.readOnly || archived;
        _currentIsPetugas = currentIsPetugas;
        _peerIsPetugas = !currentIsPetugas;
        if (peerId.isNotEmpty) {
          _peerId = peerId;
        }
        if (peerName?.isNotEmpty == true) {
          _peerName = peerName!;
        }
        if (peerImageUrl?.isNotEmpty == true) {
          _peerImageUrl = UserService.normalizeProfileImageUrl(peerImageUrl!);
        }
        if (peerRole?.isNotEmpty == true) {
          _resolvedPeerRole = peerRole!;
        }
      });
    });
  }

  Widget _buildPeerImage(String imageUrl) {
    final normalizedUrl = UserService.normalizeProfileImageUrl(imageUrl);
    if (normalizedUrl.isEmpty ||
        normalizedUrl == UserService.defaultProfileImageUrl) {
      return Image.asset(_defaultProfileAsset, fit: BoxFit.cover);
    }
    return Image.network(
      normalizedUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(_defaultProfileAsset, fit: BoxFit.cover);
      },
    );
  }

  Future<void> _prepareConversation() async {
    final currentEpoch = ++_conversationEpoch;
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    try {
      var peerRoleForConversation = widget.peerRole.trim();
      try {
        final peerData = await _userService.fetchAnyUserDataById(_peerId);
        final fetchedRole = peerData?['roles']?.toString().trim() ?? '';
        if (fetchedRole.isNotEmpty) {
          peerRoleForConversation = fetchedRole;
        }
        final fetchedName = peerData?['displayName']?.toString().trim() ?? '';
        final fetchedImageUrl = peerData?['imageUrl']?.toString().trim() ?? '';
        if (fetchedName.isNotEmpty) {
          _peerName = fetchedName;
        }
        if (fetchedImageUrl.isNotEmpty) {
          _peerImageUrl = UserService.normalizeProfileImageUrl(fetchedImageUrl);
        }
      } catch (_) {
        // Keep existing role fallback when user lookup is not available.
      }

      final handle = await _helpService.ensureConversationWithPeer(
        peerId: _peerId,
        peerName: _peerName,
        peerImageUrl: UserService.normalizeProfileImageUrl(_peerImageUrl),
        peerIsPetugas: _peerIsPetugas,
        peerRole: peerRoleForConversation,
      );
      if (!mounted || currentEpoch != _conversationEpoch) return;
      setState(() {
        _conversationId = handle.conversationId;
        _bindMessagesStream(handle.conversationId);
        _bindConversationStream(handle.conversationId);
        _currentIsPetugas = handle.currentIsPetugas;
        _resolvedPeerRole = peerRoleForConversation.isNotEmpty
            ? peerRoleForConversation
            : handle.peerRole;
        _isLoading = false;
        _isArchived = widget.readOnly;
        _messageAccessClosed = false;
      });
      unawaited(_helpService.markConversationAsRead(handle.conversationId));
    } catch (e) {
      if (!mounted || currentEpoch != _conversationEpoch) return;
      setState(() {
        _errorMessage = e.toString();
        _messagesStream = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadConversationById(String conversationId) async {
    final currentEpoch = ++_conversationEpoch;
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Silakan login untuk melihat pesan bantuan.');
      }
      final data = await _helpService.fetchConversationById(conversationId);
      if (data == null || data.isEmpty) {
        throw Exception('Percakapan tidak ditemukan.');
      }

      final officerId = data['officerId']?.toString() ?? '';
      final pilgrimId = data['pilgrimId']?.toString() ?? '';
      final currentIsPetugas = user.uid == officerId;
      var peerId = currentIsPetugas ? pilgrimId : officerId;
      var peerName = currentIsPetugas
          ? (data['pilgrimName']?.toString().trim() ?? '')
          : (data['officerName']?.toString().trim() ?? '');
      var peerImageUrl = currentIsPetugas
          ? (data['pilgrimImageUrl']?.toString().trim() ?? '')
          : (data['officerImageUrl']?.toString().trim() ?? '');
      var peerRole = currentIsPetugas
          ? (data['pilgrimRole']?.toString().trim() ?? '')
          : (data['officerRole']?.toString().trim() ?? '');
      final peerIsPetugas = !currentIsPetugas;

      if (peerId.isNotEmpty) {
        try {
          final peerData = await _userService.fetchAnyUserDataById(peerId);
          final fetchedName = peerData?['displayName']?.toString().trim() ?? '';
          final fetchedImageUrl =
              peerData?['imageUrl']?.toString().trim() ?? '';
          final fetchedRole = peerData?['roles']?.toString().trim() ?? '';
          if (fetchedName.isNotEmpty) peerName = fetchedName;
          if (fetchedImageUrl.isNotEmpty) peerImageUrl = fetchedImageUrl;
          if (fetchedRole.isNotEmpty) peerRole = fetchedRole;
        } catch (_) {
          // Conversation data is enough to keep the chat usable.
        }
      }

      if (peerId.isEmpty) peerId = widget.peerId.trim();
      if (peerName.isEmpty) peerName = widget.peerName.trim();
      if (peerImageUrl.isEmpty) peerImageUrl = widget.peerImageUrl.trim();
      if (peerRole.isEmpty) peerRole = widget.peerRole.trim();
      peerImageUrl = UserService.normalizeProfileImageUrl(peerImageUrl);

      final status = data['status']?.toString() ?? 'open';
      final archived = data['archived'] == true || status == 'closed';

      if (!mounted || currentEpoch != _conversationEpoch) return;
      setState(() {
        _conversationId = conversationId;
        _bindMessagesStream(conversationId);
        _currentIsPetugas = currentIsPetugas;
        _peerId = peerId;
        _peerName = peerName;
        _peerImageUrl = peerImageUrl;
        _peerIsPetugas = peerIsPetugas;
        _resolvedPeerRole = peerRole;
        _isArchived = widget.readOnly || archived;
        _messageAccessClosed = false;
        _isLoading = false;
      });
      _bindConversationStream(conversationId);
      unawaited(_helpService.markConversationAsRead(conversationId));
    } catch (e) {
      if (!mounted || currentEpoch != _conversationEpoch) return;
      setState(() {
        _errorMessage = e.toString();
        _messagesStream = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage({
    required String text,
    String type = 'custom',
    String templateKey = '',
  }) async {
    final conversationId = _conversationId;
    if (conversationId == null || _isSending) return;
    if (_isArchived) {
      await showAppPopup(
        context,
        type: AppPopupType.warning,
        title: 'Sesi Diarsipkan',
        message: 'Sesi ini sudah diarsipkan. Anda hanya dapat melihat pesan.',
      );
      return;
    }
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      await _helpService.sendMessage(
        conversationId: conversationId,
        text: trimmed,
        type: type,
        templateKey: templateKey,
      );
      if (!mounted) return;
      _messageController.clear();
    } catch (e) {
      if (!mounted) return;
      await showAppPopup(
        context,
        type: AppPopupType.error,
        title: 'Gagal Mengirim',
        message: 'Gagal mengirim pesan: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  String _formatTime(int millis) {
    if (millis <= 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Widget _buildQuickTemplateList(List<String> templates) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(14),
        ),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Iconsax.message_text,
                size: 16,
                color: ColorSys.darkBlue,
              ),
              const SizedBox(width: 8),
              Text(
                'Pesan cepat',
                style: textStyle(
                  fontSize: 13,
                  color: ColorSys.darkBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showQuickTemplates = !_showQuickTemplates;
                  });
                },
                icon: Icon(
                  _showQuickTemplates
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: ColorSys.darkBlue,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          if (_showQuickTemplates) ...[
            const SizedBox(height: 6),
            ...templates.map((template) {
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      final text = template.trim();
                      if (text.isEmpty) return;
                      _messageController.text = text;
                      _messageController.selection = TextSelection.collapsed(
                        offset: text.length,
                      );
                      _messageFocusNode.requestFocus();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Text(
                        template,
                        style: textStyle(
                          fontSize: 12.5,
                          color: ColorSys.darkBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Divider(color: Colors.grey.shade200, height: 1),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    HelpMessage message,
    String currentUid,
  ) {
    final isMine = message.senderId == currentUid;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bubbleMaxWidth =
        (screenWidth * (isMine ? 0.82 : 0.78)).clamp(220.0, 420.0).toDouble();
    final bubbleColor = _isArchived
        ? (isMine ? ColorSys.darkBlue : const Color(0xFFEFF3F7))
        : (isMine
            ? ColorSys.darkBlue
            : ColorSys.primaryTint.withValues(alpha: 0.9));
    const senderNameColor = ColorSys.darkBlue;
    const incomingMessageColor = ColorSys.darkBlue;
    final incomingTimeColor = _isArchived
        ? ColorSys.darkBlue.withValues(alpha: 0.65)
        : ColorSys.darkBlue.withValues(alpha: 0.7);

    final bubble = Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMine)
            Text(
              toTitleCaseName(message.senderName),
              style: textStyle(
                fontSize: 11,
                color: senderNameColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          if (!isMine) const SizedBox(height: 2),
          Text(
            message.text,
            textAlign: TextAlign.start,
            style: textStyle(
              fontSize: 14,
              color: isMine ? Colors.white : incomingMessageColor,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            widthFactor: 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.createdAt),
                  style: textStyle(
                    fontSize: 10,
                    color: isMine
                        ? Colors.white.withValues(alpha: 0.75)
                        : incomingTimeColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: bubble,
    );
  }

  String _normalizeQuickText(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String? _matchRequestTemplate(
    String text,
    List<String> requestTemplates,
  ) {
    final normalizedText = _normalizeQuickText(text);
    for (final template in requestTemplates) {
      final normalizedTemplate = _normalizeQuickText(template);
      if (normalizedText == normalizedTemplate ||
          normalizedText.startsWith('$normalizedTemplate ') ||
          normalizedText.contains(normalizedTemplate)) {
        return template;
      }
    }
    return null;
  }

  List<String> _resolveQuickTemplates(
    List<HelpMessage> messages,
    String currentUid,
  ) {
    if (_isArchived) return const <String>[];

    final pilgrimId = _currentIsPetugas ? _peerId : currentUid;
    final petugasId = _currentIsPetugas ? currentUid : _peerId;
    const requestTemplates = HelpService.defaultHelpTemplates;
    const followUpTemplates = HelpService.defaultPilgrimFollowUpReplies;

    const stageIdle = 0; // no pilgrim request yet
    const stageWaitingOfficer = 1; // pilgrim request sent
    const stageWaitingPilgrim = 2; // officer replied
    const stageCompleted = 3; // pilgrim confirmed, quick flow ends

    var stage = stageIdle;
    String latestPilgrimRequestText = '';

    for (var i = 0; i < messages.length; i++) {
      final message = messages[i];
      if (stage == stageCompleted) {
        continue;
      }
      if (message.senderId == pilgrimId && stage == stageIdle) {
        stage = stageWaitingOfficer;
        latestPilgrimRequestText = message.text.trim();
        continue;
      }
      if (message.senderId == pilgrimId && stage == stageWaitingOfficer) {
        // Keep latest request text while waiting for first officer response.
        latestPilgrimRequestText = message.text.trim();
        continue;
      }
      if (message.senderId == petugasId && stage == stageWaitingOfficer) {
        stage = stageWaitingPilgrim;
        continue;
      }
      if (message.senderId == pilgrimId && stage == stageWaitingPilgrim) {
        stage = stageCompleted;
        continue;
      }
      if (message.senderId == petugasId && stage == stageWaitingPilgrim) {
        // Officer may send additional confirmations; still waiting pilgrim.
        continue;
      }
      if (message.senderId == petugasId && stage == stageIdle) {
        // Ignore any pre-existing officer/system messages before first request.
        continue;
      }
    }

    if (stage == stageCompleted) {
      return const <String>[];
    }

    if (_currentIsPetugas) {
      if (stage == stageWaitingOfficer) {
        final matchedTemplate = _matchRequestTemplate(
          latestPilgrimRequestText,
          requestTemplates,
        );
        if (matchedTemplate != null) {
          return HelpService.officerRepliesForRequest(matchedTemplate);
        }
        return HelpService.defaultOfficerQuickReplies;
      }
      return const <String>[];
    }

    if (stage == stageIdle) {
      return requestTemplates;
    }

    if (stage == stageWaitingPilgrim) {
      return followUpTemplates;
    }

    return const <String>[];
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final roleText = _resolvedPeerRole.trim().isNotEmpty
        ? _resolvedPeerRole.trim()
        : (_peerIsPetugas ? 'Petugas Haji' : 'Jemaah Haji');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: ColorSys.darkBlue),
        titleSpacing: 0,
        leading: IconButton(
          onPressed: _handleBackPressed,
          icon: const Icon(Iconsax.arrow_left_2),
          color: ColorSys.darkBlue,
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade200,
              child: ClipOval(
                child: SizedBox.expand(
                  child: _buildPeerImage(_peerImageUrl),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    toTitleCaseName(_peerName),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle(
                      fontSize: 16,
                      color: ColorSys.darkBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    roleText,
                    style: textStyle(
                      fontSize: 11,
                      color: ColorSys.darkBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: ColorSys.darkBlue),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      _errorMessage!,
                      style: textStyle(
                        fontSize: 14,
                        color: ColorSys.darkBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              : Column(
                  children: [
                    if (_isArchived)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        color: ColorSys.error.withValues(alpha: 0.08),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.archive_rounded,
                              color: ColorSys.error,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Sesi diarsipkan. Anda hanya dapat melihat pesan.',
                                style: textStyle(
                                  fontSize: 12,
                                  color: ColorSys.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: (_messagesStream == null)
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: ColorSys.darkBlue,
                              ),
                            )
                          : StreamBuilder<List<HelpMessage>>(
                              stream: _messagesStream,
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  if (!_messageAccessClosed) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      if (!mounted || _messageAccessClosed) {
                                        return;
                                      }
                                      setState(() {
                                        _messageAccessClosed = true;
                                        _isArchived = true;
                                      });
                                    });
                                  }
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Text(
                                        'Sesi ini sudah ditutup dan '
                                        'percakapan telah diarsipkan.',
                                        textAlign: TextAlign.center,
                                        style: textStyle(
                                          fontSize: 13,
                                          color: ColorSys.error,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                if (snapshot.connectionState ==
                                        ConnectionState.waiting &&
                                    !snapshot.hasData) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: ColorSys.darkBlue,
                                    ),
                                  );
                                }

                                final messages =
                                    snapshot.data ?? <HelpMessage>[];
                                if (messages.isEmpty) {
                                  if (_isArchived) {
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 16,
                                        ),
                                        child: Text(
                                          'Sesi ini sudah diarsipkan.',
                                          textAlign: TextAlign.center,
                                          style: textStyle(
                                            fontSize: 13,
                                            color: ColorSys.darkBlue,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  final emptyTemplates = _resolveQuickTemplates(
                                      messages, currentUid);
                                  return Column(
                                    children: [
                                      if (emptyTemplates.isNotEmpty) ...[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          child: _buildQuickTemplateList(
                                            emptyTemplates,
                                          ),
                                        ),
                                      ],
                                      Expanded(
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 16,
                                            ),
                                            child: Text(
                                              'Belum ada pesan. Kirim bantuan sekarang.',
                                              textAlign: TextAlign.center,
                                              style: textStyle(
                                                fontSize: 13,
                                                color: ColorSys.darkBlue,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                final orderedMessages = [...messages]..sort(
                                    (a, b) =>
                                        b.createdAt.compareTo(a.createdAt));

                                final latestMessage = messages.last;
                                if (latestMessage.senderId != currentUid &&
                                    latestMessage.id !=
                                        _lastMarkedReadMessageId) {
                                  _lastMarkedReadMessageId = latestMessage.id;
                                  unawaited(
                                    _helpService.markConversationAsRead(
                                      _conversationId!,
                                    ),
                                  );
                                }

                                final templates = _resolveQuickTemplates(
                                    messages, currentUid);
                                final showQuickReplies = templates.isNotEmpty;

                                return Column(
                                  children: [
                                    if (showQuickReplies) ...[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        child:
                                            _buildQuickTemplateList(templates),
                                      ),
                                    ],
                                    Expanded(
                                      child: ListView.builder(
                                        reverse: true,
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 12, 16, 12),
                                        itemCount: orderedMessages.length,
                                        itemBuilder: (context, index) {
                                          final message =
                                              orderedMessages[index];
                                          return _buildMessageBubble(
                                            message,
                                            currentUid,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                    if (!_isArchived && !_messageAccessClosed)
                      SafeArea(
                        top: false,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              top: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  focusNode: _messageFocusNode,
                                  minLines: 1,
                                  maxLines: 4,
                                  textInputAction: TextInputAction.newline,
                                  cursorColor: ColorSys.darkBlue,
                                  style: textStyle(
                                    color: ColorSys.textPrimary,
                                    fontSize: 14.0,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Tulis pesan bantuan...',
                                    hintStyle: textStyle(
                                      fontSize: 13,
                                      color: ColorSys.grey,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(14)),
                                      borderSide:
                                          BorderSide(color: ColorSys.darkBlue),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _isSending
                                      ? null
                                      : () => _sendMessage(
                                            text: _messageController.text,
                                          ),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    backgroundColor: ColorSys.darkBlue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: _isSending
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.send_rounded,
                                          color: Colors.white,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  void _handleBackPressed() {
    Navigator.pop(context);
  }
}
