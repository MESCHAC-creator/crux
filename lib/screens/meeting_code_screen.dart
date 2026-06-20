import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/colors.dart';
import '../services/meeting_service.dart';

/// Screen shown to the host after creating a meeting.
/// Displays the 6-digit meeting code for easy sharing.
class MeetingCodeScreen extends StatefulWidget {
  final String meetingId;
  final String meetingName;
  final bool isHost;

  const MeetingCodeScreen({
    super.key,
    required this.meetingId,
    required this.meetingName,
    required this.isHost,
  });

  @override
  State<MeetingCodeScreen> createState() => _MeetingCodeScreenState();
}

class _MeetingCodeScreenState extends State<MeetingCodeScreen> {
  final _meetingService = MeetingService();
  String? _meetingCode;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generateCode();
  }

  Future<void> _generateCode() async {
    try {
      final code = await _meetingService.generateMeetingCode(widget.meetingId);
      if (mounted) {
        setState(() {
          _meetingCode = code;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erreur lors de la génération du code';
          _loading = false;
        });
      }
    }
  }

  void _copyCode() {
    if (_meetingCode == null) return;
    Clipboard.setData(ClipboardData(text: _meetingCode!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Code copié: $_meetingCode',
            style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _shareCode() {
    if (_meetingCode == null) return;
    final text = 'Rejoins ma réunion "${widget.meetingName}" sur CRUX !\n\n'
        'Code de réunion : $_meetingCode\n\n'
        '📱 Pas de compte requis.';
    Share.share(text, subject: 'Code réunion CRUX');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.tag, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Code de Réunion',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Partagez ce code pour que d\'autres vous rejoignent',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white60,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),

            // Code display
            if (_loading)
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2.5,
                ),
              )
            else if (_error != null)
              Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                  const SizedBox(height: 12),
                  Text(_error!,
                      textAlign: TextAlign.center,
                      style:
                          GoogleFonts.poppins(color: Colors.redAccent, fontSize: 14)),
                ],
              )
            else if (_meetingCode != null)
              GestureDetector(
                onTap: _copyCode,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Votre code',
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _meetingCode!.split('').join(' '),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.copy, color: AppColors.primary, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'Touchez pour copier',
                            style: GoogleFonts.poppins(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 28),

            // Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading || _meetingCode == null ? null : _shareCode,
                icon: const Icon(Icons.share, size: 18),
                label: Text(
                  'Partager le code',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Meeting info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Réunion',
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.meetingName,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ID Complet',
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.meetingId,
                    style: GoogleFonts.poppins(
                      color: Colors.white30,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Expiry info
            Text(
              'Code valide 24 heures',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white38,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
