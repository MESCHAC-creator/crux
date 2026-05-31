import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/meeting_model.dart';
import '../theme/colors.dart';

class MeetingDetailsScreen extends StatelessWidget {
  final MeetingModel meeting;

  const MeetingDetailsScreen({Key? key, required this.meeting}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBg,
      appBar: AppBar(
        backgroundColor: AppColors.whiteBg,
        elevation: 1,
        title: Text(
          'Détails de la réunion',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoCard(
              icon: Icons.title,
              label: 'Titre',
              value: meeting.title,
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.description,
              label: 'Description',
              value: meeting.description.isEmpty ? 'Aucune description' : meeting.description,
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.person,
              label: 'Organisateur',
              value: meeting.organizer,
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.access_time,
              label: 'Début',
              value: _formatDateTime(meeting.startTime),
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.timer_off,
              label: 'Fin prévue',
              value: _formatDateTime(meeting.endTime),
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.people,
              label: 'Participants',
              value: '${meeting.participants.length} participant(s)',
            ),
            const SizedBox(height: 12),
            _StatusBadge(status: meeting.status),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    '/meeting',
                    arguments: {
                      'meetingId': meeting.id,
                      'meetingName': meeting.title,
                    },
                  );
                },
                icon: const Icon(Icons.video_call),
                label: Text(
                  'Rejoindre la réunion',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} à '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final MeetingStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case MeetingStatus.ongoing:
        color = AppColors.success;
        label = 'En cours';
        icon = Icons.fiber_manual_record;
        break;
      case MeetingStatus.ended:
        color = AppColors.textTertiary;
        label = 'Terminée';
        icon = Icons.check_circle_outline;
        break;
      case MeetingStatus.scheduled:
      default:
        color = AppColors.info;
        label = 'Planifiée';
        icon = Icons.schedule;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
