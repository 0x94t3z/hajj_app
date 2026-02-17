import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hajj_app/helpers/app_popup.dart';
import 'package:hajj_app/helpers/name_formatter.dart';
import 'package:hajj_app/helpers/styles.dart';
import 'package:hajj_app/models/users.dart';
import 'package:hajj_app/screens/features/finding/navigation.dart';
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
  });

  final String peerId;
  final String peerName;
  final String peerImageUrl;
  final bool peerIsPetugas;
  final String peerRole;

  @override
  State<HelpChatScreen> createState() => _HelpChatScreenState();
}

class _HelpChatScreenState extends State<HelpChatScreen> {
  final HelpService _helpService = HelpService();
  final UserService _userService = UserService();
  final TextEditingController _messageController = TextEditingController();

  String? _conversationId;
  bool _isLoading = true;
  bool _isSending = false;
  bool _currentIsPetugas = false;
  String _resolvedPeerRole = '';
  String _lastMarkedReadMessageId = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _prepareConversation();
  }

  @override
  void dispose() {
    _messageController.dispose();
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

  Future<void> _sendMessage({
    required String text,
    String type = 'custom',
    String templateKey = '',
  }) async {
    final conversationId = _conversationId;
    if (conversationId == null || _isSending) return;
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
      if (rawData == null) {
        await showAppPopup(
          context,
          type: AppPopupType.warning,
          title: 'Data Tidak Ditemukan',
          message: 'Data jemaah tidak ditemukan.',
        );
        return;
      }

      final normalizedData = <String, dynamic>{...rawData};
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

      final targetUser = UserModel.fromMap(normalizedData);
      if (targetUser.latitude == 0.0 || targetUser.longitude == 0.0) {
        await showAppPopup(
          context,
          type: AppPopupType.warning,
          title: 'Lokasi Belum Tersedia',
          message: 'Lokasi jemaah belum tersedia untuk navigasi.',
        );
        return;
      }

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

  Widget _buildQuickTemplateChips() {
    final templates = _currentIsPetugas
        ? HelpService.defaultOfficerQuickReplies
        : HelpService.defaultHelpTemplates;
    final sectionTitle =
        _currentIsPetugas ? 'Balasan cepat petugas' : 'Kirim bantuan cepat';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionTitle,
            style: textStyle(
              fontSize: 13,
              color: ColorSys.darkBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: templates.map((template) {
              return ActionChip(
                label: Text(
                  template,
                  style: textStyle(
                    fontSize: 12,
                    color: ColorSys.darkBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                side: const BorderSide(color: ColorSys.darkBlue),
                backgroundColor: Colors.white,
                onPressed: () => _sendMessage(
                  text: template,
                  type: 'template',
                  templateKey: template,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(HelpMessage message, String currentUid) {
    final isMine = message.senderId == currentUid;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 290),
        decoration: BoxDecoration(
          color: isMine ? ColorSys.darkBlue : const Color(0xFFEFF3F7),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMine)
              Text(
                toTitleCaseName(message.senderName),
                style: textStyle(
                  fontSize: 11,
                  color: ColorSys.darkBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            if (!isMine) const SizedBox(height: 2),
            Text(
              message.text,
              style: textStyle(
                fontSize: 14,
                color: isMine ? Colors.white : ColorSys.darkBlue,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatTime(message.createdAt),
              style: textStyle(
                fontSize: 10,
                color: isMine
                    ? Colors.white.withValues(alpha: 0.75)
                    : ColorSys.darkBlue.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
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
                    _buildQuickTemplateChips(),
                    if (_currentIsPetugas && !widget.peerIsPetugas)
                      Container(
                        width: double.infinity,
                        color: const Color(0xFFF8FAFC),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton.icon(
                            onPressed: _openGoToRequester,
                            icon: const Icon(
                              Iconsax.direct_up,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Find Pilgrim',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorSys.darkBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
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
                            return Center(
                              child: Text(
                                'Belum ada pesan. Kirim bantuan sekarang.',
                                style: textStyle(
                                  fontSize: 13,
                                  color: ColorSys.darkBlue,
                                ),
                              ),
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

                          return ListView.builder(
                            reverse: true,
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                            itemCount: orderedMessages.length,
                            itemBuilder: (context, index) {
                              return _buildMessageBubble(
                                orderedMessages[index],
                                currentUid,
                              );
                            },
                          );
                        },
                      ),
                    ),
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
                                minLines: 1,
                                maxLines: 4,
                                textInputAction: TextInputAction.newline,
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
}
