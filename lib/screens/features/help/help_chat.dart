import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hajj_app/core/widgets/app_popup.dart';
import 'package:hajj_app/core/utils/name_formatter.dart';
import 'package:hajj_app/core/theme/app_style.dart';
import 'package:hajj_app/models/user_model.dart';
import 'package:hajj_app/screens/features/finding/navigation_screen.dart';
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
  final HelpService _helpService = HelpService();
  final UserService _userService = UserService();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  bool _showQuickTemplates = true;

  String? _conversationId;
  bool _isLoading = true;
  bool _isSending = false;
  bool _isClosingSession = false;
  bool _isArchived = false;
  bool _currentIsPetugas = false;
  String _resolvedPeerRole = '';
  String _lastMarkedReadMessageId = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final presetConversationId = widget.conversationId?.trim();
    if (presetConversationId != null && presetConversationId.isNotEmpty) {
      _loadConversationById(presetConversationId);
    } else {
      _prepareConversation();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _prepareConversation() async {
    try {
      var peerRoleForConversation = widget.peerRole.trim();
      try {
        final peerData = await _userService.fetchAnyUserDataById(widget.peerId);
        final fetchedRole = peerData?['roles']?.toString().trim() ?? '';
        if (fetchedRole.isNotEmpty) {
          peerRoleForConversation = fetchedRole;
        }
      } catch (_) {
        // Keep existing role fallback when user lookup is not available.
      }

      final handle = await _helpService.ensureConversationWithPeer(
        peerId: widget.peerId,
        peerName: widget.peerName,
        peerImageUrl: widget.peerImageUrl,
        peerIsPetugas: widget.peerIsPetugas,
        peerRole: peerRoleForConversation,
      );
      if (!mounted) return;
      setState(() {
        _conversationId = handle.conversationId;
        _currentIsPetugas = handle.currentIsPetugas;
        _resolvedPeerRole = peerRoleForConversation.isNotEmpty
            ? peerRoleForConversation
            : handle.peerRole;
        _isLoading = false;
        _isArchived = widget.readOnly;
      });
      unawaited(_helpService.markConversationAsRead(handle.conversationId));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadConversationById(String conversationId) async {
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
      final currentIsPetugas = user.uid == officerId;
      final peerRole = currentIsPetugas
          ? (data['pilgrimRole']?.toString().trim() ?? '')
          : (data['officerRole']?.toString().trim() ?? '');
      final status = data['status']?.toString() ?? 'open';
      final archived = data['archived'] == true || status == 'closed';

      if (!mounted) return;
      setState(() {
        _conversationId = conversationId;
        _currentIsPetugas = currentIsPetugas;
        _resolvedPeerRole = peerRole.isNotEmpty ? peerRole : widget.peerRole;
        _isArchived = widget.readOnly || archived;
        _isLoading = false;
      });
      unawaited(_helpService.markConversationAsRead(conversationId));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
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
        title: 'Session Archived',
        message: 'This session is archived. You can only view messages.',
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

  Future<void> _openGoToRequester() async {
    if (!_currentIsPetugas || widget.peerIsPetugas) return;

    try {
      final rawData = await _userService.fetchAnyUserDataById(widget.peerId);
      if (!mounted) return;

      final normalizedData = <String, dynamic>{
        ...(rawData ?? <String, dynamic>{}),
      };
      normalizedData['userId'] =
          normalizedData['userId']?.toString().isNotEmpty == true
              ? normalizedData['userId'].toString()
              : widget.peerId;
      normalizedData['displayName'] =
          normalizedData['displayName']?.toString().isNotEmpty == true
              ? normalizedData['displayName'].toString()
              : widget.peerName;
      normalizedData['roles'] =
          normalizedData['roles']?.toString().isNotEmpty == true
              ? normalizedData['roles'].toString()
              : _resolvedPeerRole;
      normalizedData['imageUrl'] =
          normalizedData['imageUrl']?.toString().isNotEmpty == true
              ? normalizedData['imageUrl'].toString()
              : widget.peerImageUrl;

      var targetUser = UserModel.fromMap(normalizedData);
      if (targetUser.latitude == 0.0 || targetUser.longitude == 0.0) {
        final conversationId = _conversationId;
        if (conversationId != null) {
          final location = await _helpService.fetchConversationPeerLocation(
            conversationId: conversationId,
            currentIsPetugas: _currentIsPetugas,
          );
          if (location != null) {
            normalizedData['latitude'] = location['latitude'];
            normalizedData['longitude'] = location['longitude'];
            targetUser = UserModel.fromMap(normalizedData);
          }
        }
      }

      if (targetUser.latitude == 0.0 || targetUser.longitude == 0.0) {
        final conversationId = _conversationId;
        if (conversationId != null) {
          final messageLocation =
              await _helpService.fetchLatestPeerMessageLocation(
            conversationId: conversationId,
            peerId: widget.peerId,
          );
          if (messageLocation != null) {
            normalizedData['latitude'] = messageLocation['latitude'];
            normalizedData['longitude'] = messageLocation['longitude'];
            targetUser = UserModel.fromMap(normalizedData);
          }
        }
      }

      if (targetUser.latitude == 0.0 || targetUser.longitude == 0.0) {
        if (!mounted) return;
        await showAppPopup(
          context,
          type: AppPopupType.warning,
          title: 'Lokasi Belum Tersedia',
          message: 'Lokasi jemaah belum tersedia untuk navigasi.',
        );
        return;
      }

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DirectionMapScreen(officer: targetUser),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      await showAppPopup(
        context,
        type: AppPopupType.error,
        title: 'Navigasi Gagal',
        message: 'Gagal membuka navigasi: $e',
      );
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
    String currentUid, {
    bool showFindPilgrimButton = false,
  }) {
    final isMine = message.senderId == currentUid;
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
      constraints: const BoxConstraints(maxWidth: 290),
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
            style: textStyle(
              fontSize: 14,
              color: isMine ? Colors.white : incomingMessageColor,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showFindPilgrimButton && !isMine) ...[
                  SizedBox(
                    height: 26,
                    child: ElevatedButton.icon(
                      onPressed: _openGoToRequester,
                      icon: const Icon(
                        Iconsax.direct_up,
                        size: 12,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Find Pilgrim',
                        style: textStyle(
                          fontSize: 10.5,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: ColorSys.darkBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
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

    final pilgrimId = _currentIsPetugas ? widget.peerId : currentUid;
    final petugasId = _currentIsPetugas ? currentUid : widget.peerId;
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
        : (widget.peerIsPetugas ? 'Petugas Haji' : 'Jemaah Haji');

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
                  child: widget.peerImageUrl.trim().isEmpty
                      ? const Icon(Iconsax.profile_circle, size: 20)
                      : Image.network(
                          widget.peerImageUrl.trim(),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Iconsax.profile_circle, size: 20);
                          },
                        ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    toTitleCaseName(widget.peerName),
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
          ? const Center(child: CircularProgressIndicator())
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
                                'Session archived. You can only view messages.',
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
                      child: StreamBuilder<List<HelpMessage>>(
                        stream: _helpService.watchMessages(_conversationId!),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  'Akses pesan bantuan ditolak. '
                                  'Periksa Firebase Rules untuk helpConversations.',
                                  textAlign: TextAlign.center,
                                  style: textStyle(
                                    fontSize: 13,
                                    color: ColorSys.darkBlue,
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
                              child: CircularProgressIndicator(),
                            );
                          }

                          final messages = snapshot.data ?? <HelpMessage>[];
                          if (messages.isEmpty) {
                            if (_isArchived) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  child: Text(
                                    'Session ini sudah diarsipkan.',
                                    textAlign: TextAlign.center,
                                    style: textStyle(
                                      fontSize: 13,
                                      color: ColorSys.darkBlue,
                                    ),
                                  ),
                                ),
                              );
                            }
                            final emptyTemplates =
                                _resolveQuickTemplates(messages, currentUid);
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

                          final orderedMessages = [
                            ...messages
                          ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                          final latestMessage = messages.last;
                          if (latestMessage.senderId != currentUid &&
                              latestMessage.id != _lastMarkedReadMessageId) {
                            _lastMarkedReadMessageId = latestMessage.id;
                            unawaited(
                              _helpService.markConversationAsRead(
                                _conversationId!,
                              ),
                            );
                          }

                          final templates =
                              _resolveQuickTemplates(messages, currentUid);
                          final showQuickReplies = templates.isNotEmpty;
                          var latestPilgrimMessageId = '';
                          if (_currentIsPetugas && !widget.peerIsPetugas) {
                            for (var i = messages.length - 1; i >= 0; i--) {
                              final candidate = messages[i];
                              if (candidate.senderId == widget.peerId) {
                                latestPilgrimMessageId = candidate.id;
                                break;
                              }
                            }
                          }

                          return Column(
                            children: [
                              if (showQuickReplies) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: _buildQuickTemplateList(templates),
                                ),
                              ],
                              Expanded(
                                child: ListView.builder(
                                  reverse: true,
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 12, 16, 12),
                                  itemCount: orderedMessages.length,
                                  itemBuilder: (context, index) {
                                    final message = orderedMessages[index];
                                    final showFindPilgrimButton =
                                        !_isArchived &&
                                            _currentIsPetugas &&
                                            !widget.peerIsPetugas &&
                                            latestPilgrimMessageId.isNotEmpty &&
                                            message.senderId == widget.peerId &&
                                            message.id ==
                                                latestPilgrimMessageId;
                                    return _buildMessageBubble(
                                      message,
                                      currentUid,
                                      showFindPilgrimButton:
                                          showFindPilgrimButton,
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    if (!_isArchived)
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

  Future<void> _confirmEndSession() async {
    final shouldClose = await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (dialogContext) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 26),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorSys.error.withValues(alpha: 0.12),
                      ),
                      child: const Icon(
                        Iconsax.danger,
                        color: ColorSys.error,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'End Session',
                      textAlign: TextAlign.center,
                      style: textStyle(
                        fontSize: 18,
                        color: ColorSys.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Jika masih butuh bantuan, jangan tekan End. '
                      'Percakapan ini akan diarsipkan.',
                      textAlign: TextAlign.center,
                      style: textStyle(
                        fontSize: 13,
                        color: ColorSys.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(false),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: ColorSys.error),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'Cancel',
                              style: textStyle(
                                fontSize: 14,
                                color: ColorSys.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(true),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: ColorSys.error,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'End',
                              style: textStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ) ??
        false;

    if (!shouldClose) return;
    await _closeSession();
  }

  Future<void> _handleBackPressed() async {
    if (_conversationId == null || _isLoading || _isArchived) {
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    }
    if (_isClosingSession) return;

    final conversationId = _conversationId!;
    final data = await _helpService.fetchConversationById(conversationId);
    if (!mounted) return;
    if (data == null || data.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final messagesNode = data['messages'];
    final lastMessage = data['lastMessage']?.toString().trim() ?? '';
    final hasMessages = lastMessage.isNotEmpty ||
        (messagesNode is Map && messagesNode.isNotEmpty);

    // No chat content yet: leave without end-session popup.
    if (!hasMessages) {
      Navigator.pop(context);
      return;
    }

    final officerId = data['officerId']?.toString() ?? '';
    var hasOfficerReply = false;
    if (messagesNode is Map) {
      for (final value in messagesNode.values) {
        if (value is! Map) continue;
        final map = Map<String, dynamic>.from(value);
        final senderId = map['senderId']?.toString() ?? '';
        if (senderId.isNotEmpty && senderId == officerId) {
          hasOfficerReply = true;
          break;
        }
      }
    }
    final lastSenderId = data['lastSenderId']?.toString() ?? '';
    if (!hasOfficerReply &&
        lastSenderId.isNotEmpty &&
        lastSenderId == officerId) {
      hasOfficerReply = true;
    }

    // For pilgrims without officer reply yet: just go back without popup,
    // so they can look for other officers.
    if (!_currentIsPetugas && !hasOfficerReply) {
      Navigator.pop(context);
      return;
    }

    await _confirmEndSession();
  }

  Future<void> _closeSession() async {
    final conversationId = _conversationId;
    if (conversationId == null) return;
    setState(() {
      _isClosingSession = true;
    });
    try {
      await _helpService.closeConversation(conversationId);
      if (!mounted) return;
      await showAppPopup(
        context,
        type: AppPopupType.success,
        title: 'Session Ended',
        message: 'This help request has been archived.',
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      await showAppPopup(
        context,
        type: AppPopupType.error,
        title: 'Action Failed',
        message: 'Unable to end the session: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isClosingSession = false;
        });
      }
    }
  }
}
