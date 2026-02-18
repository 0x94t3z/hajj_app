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
  String? _currentUid;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _prepareInbox();
  }

  Future<void> _prepareInbox() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Silakan login untuk melihat pesan bantuan.');
      }
      final role = await _userService.fetchCurrentUserRole(forceRefresh: true);
      if (!mounted) return;
      setState(() {
        _currentUid = user.uid;
        _currentIsPetugas = _userService.isPetugasHajiRole(role);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
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

  Future<void> _openGoToRequester(HelpConversationSummary item) async {
    try {
      final rawData = await _userService.fetchAnyUserDataById(item.peerId);
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
              : item.peerId;
      normalizedData['displayName'] =
          normalizedData['displayName']?.toString().isNotEmpty == true
              ? normalizedData['displayName'].toString()
              : item.peerName;
      normalizedData['roles'] =
          normalizedData['roles']?.toString().isNotEmpty == true
              ? normalizedData['roles'].toString()
              : item.peerRole;
      normalizedData['imageUrl'] =
          normalizedData['imageUrl']?.toString().isNotEmpty == true
              ? normalizedData['imageUrl'].toString()
              : item.peerImageUrl;

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

  void _openChat(HelpConversationSummary item) {
    Navigator.pushNamed(
      context,
      '/help_chat',
      arguments: {
        'peerId': item.peerId,
        'peerName': toTitleCaseName(item.peerName),
        'peerImageUrl': item.peerImageUrl,
        'peerIsPetugas': item.peerIsPetugas,
        'peerRole': item.peerRole,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: ColorSys.darkBlue),
        title: Text(
          'Help Requests',
          style: textStyle(
            fontSize: 18,
            color: ColorSys.darkBlue,
            fontWeight: FontWeight.w700,
          ),
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
              : StreamBuilder<List<HelpConversationSummary>>(
                  stream: _helpService.watchInbox(
                    currentUid: _currentUid!,
                    currentIsPetugas: _currentIsPetugas,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final conversations =
                        snapshot.data ?? <HelpConversationSummary>[];
                    if (conversations.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Text(
                            _currentIsPetugas
                                ? 'Belum ada pesan bantuan dari jemaah.'
                                : 'Belum ada riwayat bantuan. Gunakan tombol Help pada daftar petugas.',
                            textAlign: TextAlign.center,
                            style: textStyle(
                              fontSize: 14,
                              color: ColorSys.darkBlue,
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                      itemCount: conversations.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = conversations[index];
                        return Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              _openChat(item);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Colors.grey.shade200,
                                    child: ClipOval(
                                      child: SizedBox.expand(
                                        child: item.peerImageUrl.trim().isEmpty
                                            ? const Icon(
                                                Iconsax.profile_circle,
                                                size: 22,
                                              )
                                            : Image.network(
                                                item.peerImageUrl.trim(),
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    const Icon(
                                                  Iconsax.profile_circle,
                                                  size: 22,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          toTitleCaseName(item.peerName),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: textStyle(
                                            fontSize: 14,
                                            color: ColorSys.darkBlue,
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
                                            color: ColorSys.darkBlue,
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
                                          color: ColorSys.grey,
                                        ),
                                      ),
                                      if (_currentIsPetugas &&
                                          !item.peerIsPetugas) ...[
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          height: 28,
                                          child: ElevatedButton.icon(
                                            onPressed: () =>
                                                _openGoToRequester(item),
                                            icon: const Icon(
                                              Iconsax.direct_up,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                            label: const Text(
                                              'Go',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  ColorSys.darkBlue,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 0,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                            ),
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
                      },
                    );
                  },
                ),
    );
  }
}
