/// HOME SCREEN CORRECTED
/// This is the _showNewMeetingSheet method CORRECTED to fix the _isLargeConference bug
/// 
/// ISSUE FIXED:
/// The old code used a global `_isLargeConference` variable that persisted between meeting creations.
/// This caused the next meeting creation to remember the "Large Conference" choice from the previous one.
///
/// SOLUTION:
/// Use a LOCAL variable `sheetIsLargeConf` inside the StatefulBuilder,
/// scoped only to that bottom sheet. This way, each sheet gets a fresh state.

// ─── CORRECTED METHOD ─────────────────────────────────────────────────────────

void _showNewMeetingSheet_CORRECTED(String lang) {
  // LOCAL state variables - scoped to this bottom sheet only
  bool sheetIsLargeConf = false;
  bool sheetShowPasscode = false;
  bool sheetObscurePasscode = true;
  bool sheetCreating = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: StatefulBuilder(
          builder: (ctx2, setSheet) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Handle ──
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              
              // ── Title ──
              Text(
                AppTranslations.t('new_meeting', lang),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              // ── Meeting Name Input ──
              TextField(
                controller: _meetingNameController,
                style: GoogleFonts.poppins(color: Colors.white),
                autofocus: true,
                decoration: InputDecoration(
                  hintText: AppTranslations.t('meeting_name_hint', lang),
                  hintStyle: GoogleFonts.poppins(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Passcode Toggle ──
              GestureDetector(
                onTap: () {
                  setSheet(() {
                    sheetShowPasscode = !sheetShowPasscode;
                    if (!sheetShowPasscode) _passcodeController.clear();
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      sheetShowPasscode
                          ? Icons.lock_outline
                          : Icons.lock_open_outlined,
                      size: 14,
                      color: Colors.white54,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      sheetShowPasscode
                          ? AppTranslations.t('remove_passcode', lang)
                          : AppTranslations.t('add_passcode', lang),
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Passcode Input (Conditional) ──
              if (sheetShowPasscode) ...[
                const SizedBox(height: 10),
                TextField(
                  controller: _passcodeController,
                  keyboardType: TextInputType.number,
                  obscureText: sheetObscurePasscode,
                  style: GoogleFonts.poppins(color: Colors.white),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Code (4-6 chiffres)',
                    hintStyle: GoogleFonts.poppins(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        sheetObscurePasscode
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white54,
                        size: 18,
                      ),
                      onPressed: () {
                        setSheet(
                          () =>
                              sheetObscurePasscode = !sheetObscurePasscode,
                        );
                      },
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),

              // ── Meeting Type Selector (Standard vs Large) ──
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    // ── Standard Option ──
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setSheet(
                            () => sheetIsLargeConf = false,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: !sheetIsLargeConf
                                ? const Color(0xFFE53935)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 14,
                                color: !sheetIsLargeConf
                                    ? Colors.white
                                    : Colors.white38,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Standard (≤6)',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: !sheetIsLargeConf
                                      ? Colors.white
                                      : Colors.white38,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── Large Conference Option ──
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setSheet(
                            () => sheetIsLargeConf = true,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: sheetIsLargeConf
                                ? const Color(0xFF1565C0)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.groups_outlined,
                                size: 14,
                                color: sheetIsLargeConf
                                    ? Colors.white
                                    : Colors.white38,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Grande (100+)',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: sheetIsLargeConf
                                      ? Colors.white
                                      : Colors.white38,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Jitsi Powered Label (Conditional) ──
              if (sheetIsLargeConf)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Powered by Jitsi Meet — jusqu\'à 100+ participants',
                    style: GoogleFonts.poppins(
                      color: Colors.blue.shade300,
                      fontSize: 11,
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // ── Create Button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: sheetCreating
                      ? null
                      : () async {
                          setSheet(() => sheetCreating = true);
                          try {
                            // Pass the LOCAL sheetIsLargeConf value
                            await _createMeeting(
                              isLargeConference: sheetIsLargeConf,
                            );
                          } finally {
                            if (mounted) {
                              setSheet(() => sheetCreating = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: sheetCreating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          AppTranslations.t('start_meeting', lang),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// UPDATED _createMeeting() - accepts isLargeConference as parameter
Future<void> _createMeeting({required bool isLargeConference}) async {
  final lang = context.read<LocaleProvider>().locale.languageCode;
  final name = _meetingNameController.text.trim();
  
  if (name.isEmpty) {
    _errorHandler.showErrorDialog(
      context,
      '⚠️ ${AppTranslations.t('attention', lang)}',
      AppTranslations.t('meet_enter_name', lang),
    );
    return;
  }

  final rawPasscode = _showPasscode ? _passcodeController.text.trim() : null;
  if (rawPasscode != null && rawPasscode.isNotEmpty) {
    if (rawPasscode.length < 4 || rawPasscode.length > 6) {
      _errorHandler.showErrorDialog(
        context,
        '⚠️ ${AppTranslations.t('attention', lang)}',
        AppTranslations.t('meet_code_range', lang),
      );
      return;
    }
    if (!RegExp(r'^\d+$').hasMatch(rawPasscode)) {
      _errorHandler.showErrorDialog(
        context,
        '⚠️ ${AppTranslations.t('attention', lang)}',
        AppTranslations.t('meet_code_digits', lang),
      );
      return;
    }
  }

  try {
    final meetingId = await _meetingService.createMeeting(
      title: name,
      description: '',
      organizerName: _displayName(),
      organizerId: widget.user.uid,
      passcode: rawPasscode?.isNotEmpty == true ? rawPasscode : null,
      isLargeConference: isLargeConference, // USE PARAMETER, NOT GLOBAL
    );

    _meetingNameController.clear();
    _passcodeController.clear();
    setState(() => _showPasscode = false); // Reset only global flag

    if (!mounted) return;
    Navigator.pop(context);

    if (isLargeConference) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LargeConferenceScreen(
            meetingId: meetingId,
            meetingName: name,
            userId: widget.user.uid,
            userName: _displayName(),
            userEmail: widget.user.email,
            isHost: true,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MeetingScreen(
            meetingId: meetingId,
            meetingName: name,
            userId: widget.user.uid,
            userName: _displayName(),
            userEmail: widget.user.email,
            isHost: true,
          ),
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      final lang = context.read<LocaleProvider>().locale.languageCode;
      _errorHandler.showErrorDialog(
        context,
        '❌ ${AppTranslations.t('error', lang)}',
        _errorHandler.getMeetingErrorMessageL(
          e.toString().replaceFirst('Exception: ', ''),
          lang,
        ),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KEY CHANGES SUMMARY:
// ─────────────────────────────────────────────────────────────────────────────
//
// 1. ✅ REMOVED global _isLargeConference variable from _HomeScreenState
//
// 2. ✅ Created LOCAL variables inside _showNewMeetingSheet_CORRECTED():
//    - sheetIsLargeConf (scoped to this sheet only)
//    - sheetShowPasscode
//    - sheetObscurePasscode
//    - sheetCreating
//
// 3. ✅ Updated onTap callbacks to use setSheet(() => sheetIsLargeConf = ...)
//    instead of setState(() => _isLargeConference = ...)
//
// 4. ✅ Modified _createMeeting() to accept isLargeConference as parameter
//    instead of using global state
//
// 5. ✅ Pass LOCAL sheetIsLargeConf value when calling _createMeeting()
//
// 6. ✅ Each meeting sheet now gets FRESH state - no persistence between sheets
//
// ─────────────────────────────────────────────────────────────────────────────
