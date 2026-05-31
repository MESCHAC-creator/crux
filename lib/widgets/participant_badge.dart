import 'package:flutter/material.dart';
import '../models/participant_model.dart';
import '../theme/colors.dart';

class ParticipantBadge extends StatelessWidget {
  final ParticipantModel participant;
  final double size;

  const ParticipantBadge({
    Key? key,
    required this.participant,
    this.size = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: participant.isHost ? AppColors.primary : AppColors.border,
              width: participant.isHost ? 2 : 1,
            ),
          ),
          child: participant.avatarUrl != null
              ? ClipOval(
                  child: Image.network(
                    participant.avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildInitials(),
                  ),
                )
              : _buildInitials(),
        ),
        if (participant.isMuted)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: size * 0.35,
              height: size * 0.35,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mic_off,
                color: Colors.white,
                size: size * 0.2,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        participant.initials,
        style: TextStyle(
          fontSize: size * 0.35,
          fontWeight: FontWeight.w700,
          color: AppColors.secondary,
        ),
      ),
    );
  }
}
