import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hajj_app/core/utils/name_formatter.dart';
import 'package:hajj_app/core/theme/app_style.dart';
import 'package:hajj_app/services/help_service.dart';
import 'package:hajj_app/services/user_service.dart';
import 'package:iconsax/iconsax.dart';

class HelpInboxScreen extends StatefulWidget {
  const HelpInboxScreen({super.key});

  @override
  State<HelpInboxScreen> createState() => _HelpInboxScreenState();
}

class _HelpInboxScreenState extends State<HelpInboxScreen> {
  final HelpService _helpService = HelpService();
  final UserService _userService = UserService();

  bool _isLoading = true;
  bool _currentIsPetugas = false;
  String? _errorMessage;
  bool _showArchiveList = false;
  Stream<List<HelpConversationSummary>>? _allInboxStream;
  StreamSubscription<User?>? _authStateSubscription;
  int _prepareEpoch = 0;

  @override
  void initState() {
    super.initState();
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (user) {
        if (!mounted) return;
        if (user == null) {
          setState(() {
            _allInboxStream = null;
            _errorMessage = 'Sesi berakhir. Silakan login kembali.';
            _isLoading = false;
          });
          return;
        }
        if (_allInboxStream == null && !_isLoading) {
          _prepareInbox();
        }
      },
    );
    _prepareInbox();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _prepareInbox() async {
    final currentEpoch = ++_prepareEpoch;
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
      final role = await _userService.fetchCurrentUserRole(forceRefresh: true);
      if (!mounted || currentEpoch != _prepareEpoch) return;
      setState(() {
        _currentIsPetugas = _userService.isPetugasHajiRole(role);
        _allInboxStream = _helpService.watchAllInbox(
          currentUid: user.uid,
          currentIsPetugas: _userService.isPetugasHajiRole(role),
        );
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted || currentEpoch != _prepareEpoch) return;
      setState(() {
        _errorMessage = e.toString();
        _allInboxStream = null;
        _isLoading = false;
      });
    }
  }

  String _formatDateTime(int millis) {
    if (millis <= 0) return '-';
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final hh = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$dd/$mm $hh:$min';
  }

  void _openChat(HelpConversationSummary item) {
    Navigator.pushNamed(
      context,
      '/help_chat',
      arguments: {
        'conversationId': item.conversationId,
        'readOnly': item.archived || item.status == 'closed',
        'peerId': item.peerId,
        'peerName': toTitleCaseName(item.peerName),
        'peerImageUrl': item.peerImageUrl,
        'peerIsPetugas': item.peerIsPetugas,
        'peerRole': item.peerRole,
      },
    );
  }

  Widget _buildConversationTile(
    HelpConversationSummary item, {
    required bool archived,
  }) {
    final tileColor = archived ? Colors.grey.shade100 : Colors.white;
    final borderColor = archived ? Colors.grey.shade300 : Colors.grey.shade200;
    final nameColor = archived ? ColorSys.textSecondary : ColorSys.darkBlue;
    final messageColor = archived ? ColorSys.textSecondary : ColorSys.darkBlue;
    final timeColor = archived ? ColorSys.textSecondary : ColorSys.grey;
    final avatarBg = archived ? Colors.grey.shade300 : Colors.grey.shade200;

    Widget avatarContent = item.peerImageUrl.trim().isEmpty
        ? const Icon(
            Iconsax.profile_circle,
            size: 22,
          )
        : Image.network(
            item.peerImageUrl.trim(),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(
              Iconsax.profile_circle,
              size: 22,
            ),
          );

    if (archived) {
      avatarContent = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]),
        child: avatarContent,
      );
    }

    return Material(
      color: tileColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          _openChat(item);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: avatarBg,
                child: ClipOval(
                  child: SizedBox.expand(
                    child: avatarContent,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      toTitleCaseName(item.peerName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyle(
                        fontSize: 14,
                        color: nameColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.lastMessage.isEmpty
                          ? 'Belum ada pesan'
                          : item.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyle(
                        fontSize: 12,
                        color: messageColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDateTime(item.lastMessageAt),
                    style: textStyle(
                      fontSize: 10,
                      color: timeColor,
                    ),
                  ),
                  if (!archived && item.unreadMessageCount > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: ColorSys.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item.unreadMessageCount.toString(),
                        style: textStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                  if (archived) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Archived',
                      style: textStyle(
                        fontSize: 10,
                        color: ColorSys.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: ColorSys.primary),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help Requests',
          style: textStyle(color: ColorSys.primary),
        ),
        centerTitle: true,
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
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_allInboxStream == null)
                        const Center(child: CircularProgressIndicator())
                      else
                        StreamBuilder<List<HelpConversationSummary>>(
                          stream: _allInboxStream,
                          builder: (context, inboxSnapshot) {
                            if (inboxSnapshot.hasError) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: Text(
                                  'Akses inbox bantuan ditolak. '
                                  'Periksa Firebase Rules untuk helpConversations.',
                                  textAlign: TextAlign.center,
                                  style: textStyle(
                                    fontSize: 13,
                                    color: ColorSys.darkBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }

                            if (inboxSnapshot.connectionState ==
                                    ConnectionState.waiting &&
                                !inboxSnapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final allItems = inboxSnapshot.data ??
                                <HelpConversationSummary>[];
                            final activeItems = allItems
                                .where((item) =>
                                    item.status != 'closed' && !item.archived)
                                .take(5)
                                .toList();
                            final archivedItems = allItems
                                .where((item) =>
                                    item.status == 'closed' || item.archived)
                                .toList();
                            final archiveCount = archivedItems.length;
                            final visibleArchiveCount =
                                archivedItems.length >= 3
                                    ? 3
                                    : archivedItems.length;
                            final archiveListHeight = visibleArchiveCount == 0
                                ? 0.0
                                : (visibleArchiveCount * 78.0) +
                                    ((visibleArchiveCount - 1) * 10.0);

                            final hasActive = activeItems.isNotEmpty;
                            final hasArchived = archivedItems.isNotEmpty;
                            final totalUnread = activeItems.fold<int>(
                              0,
                              (sum, item) => sum + item.unreadMessageCount,
                            );

                            if (!hasActive && !hasArchived) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  _currentIsPetugas
                                      ? 'Belum ada permintaan bantuan masuk.'
                                      : 'Belum ada permintaan bantuan. Gunakan tombol Help pada daftar petugas.',
                                  style: textStyle(
                                    fontSize: 13,
                                    color: ColorSys.textSecondary,
                                  ),
                                ),
                              );
                            }

                            final sections = <Widget>[];

                            if (hasArchived) {
                              sections.add(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {
                                        setState(() {
                                          _showArchiveList = !_showArchiveList;
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.archive_rounded,
                                            color: ColorSys.darkBlue,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Archived',
                                            style: textStyle(
                                              fontSize: 14,
                                              color: ColorSys.darkBlue,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          if (archiveCount > 0 &&
                                              !_showArchiveList) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: ColorSys.primaryTint,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                archiveCount.toString(),
                                                style: textStyle(
                                                  fontSize: 11,
                                                  color: ColorSys.darkBlue,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                          const Spacer(),
                                          Icon(
                                            _showArchiveList
                                                ? Icons
                                                    .keyboard_arrow_up_rounded
                                                : Icons
                                                    .keyboard_arrow_down_rounded,
                                            color: ColorSys.darkBlue,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_showArchiveList) ...[
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        height: archiveListHeight,
                                        child: ListView.separated(
                                          itemCount: archivedItems.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(height: 10),
                                          itemBuilder: (context, index) {
                                            return _buildConversationTile(
                                              archivedItems[index],
                                              archived: true,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }

                            if (hasActive) {
                              if (sections.isNotEmpty) {
                                sections.add(const SizedBox(height: 18));
                              }
                              sections.add(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Active Requests',
                                          style: textStyle(
                                            fontSize: 14,
                                            color: ColorSys.darkBlue,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        if (totalUnread > 0) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: ColorSys.error,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              totalUnread.toString(),
                                              style: textStyle(
                                                fontSize: 11,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      height: 260,
                                      child: ListView.separated(
                                        itemCount: activeItems.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 10),
                                        itemBuilder: (context, index) {
                                          return _buildConversationTile(
                                            activeItems[index],
                                            archived: false,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: sections,
                            );
                          },
                        ),
                    ],
                  ),
                ),
    );
  }
}
