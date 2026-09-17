import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/financial_target_model.dart';
import '../../../../core/services/spending_planner_service.dart';

class FinancialTargetsBottomSheet extends StatefulWidget {
  final List<FinancialTarget> initialTargets;
  final VoidCallback onTargetsChanged;

  const FinancialTargetsBottomSheet({
    super.key,
    required this.initialTargets,
    required this.onTargetsChanged,
  });

  static Future<void> show(
    BuildContext context, {
    required List<FinancialTarget> initialTargets,
    required VoidCallback onTargetsChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FinancialTargetsBottomSheet(
        initialTargets: initialTargets,
        onTargetsChanged: onTargetsChanged,
      ),
    );
  }

  @override
  State<FinancialTargetsBottomSheet> createState() => _FinancialTargetsBottomSheetState();
}

class _FinancialTargetsBottomSheetState extends State<FinancialTargetsBottomSheet> {
  late List<FinancialTarget> _targets;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _targets = List.from(widget.initialTargets);
  }

  Future<void> _refreshTargets() async {
    setState(() => _isLoading = true);
    final updated = await SpendingPlannerService.getTargets();
    if (mounted) {
      setState(() {
        _targets = updated;
        _isLoading = false;
      });
      widget.onTargetsChanged();
    }
  }

  void _showAddEditBottomSheet([FinancialTarget? targetToEdit]) {
    final isEditing = targetToEdit != null;
    final titleController = TextEditingController(text: targetToEdit?.title ?? '');
    FinancialTargetType selectedType = targetToEdit?.type ?? FinancialTargetType.repeat;
    int selectedDayOfMonth = targetToEdit?.dayOfMonth ?? 25;
    DateTime selectedSpecificDate = targetToEdit?.specificDate ?? DateTime.now().add(const Duration(days: 14));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final theme = Theme.of(ctx);
          final cs = theme.colorScheme;
          final isDark = theme.brightness == Brightness.dark;
          final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;

          return Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            padding: EdgeInsets.only(bottom: bottomInset),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 44.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: cs.onSurface.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Header
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            isEditing ? Icons.edit_calendar_rounded : Icons.add_alarm_rounded,
                            color: cs.primary,
                            size: 22.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEditing ? 'Edit Target Pemasukan' : 'Tambah Target Pemasukan',
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.bold,
                                  color: cs.onSurface,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Tentukan tanggal gajian atau penerimaan dana',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: cs.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(sheetCtx),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // Title Field
                    Text(
                      'Nama Target / Sumber Pemasukan',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: titleController,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'Contoh: Gaji Kantor, Project Freelance',
                        hintStyle: TextStyle(
                          fontSize: 13.sp,
                          color: cs.onSurface.withValues(alpha: 0.35),
                          fontWeight: FontWeight.normal,
                        ),
                        prefixIcon: Icon(Icons.label_outline_rounded, size: 20.sp, color: cs.primary),
                        filled: true,
                        fillColor: isDark ? cs.surfaceContainerHighest.withValues(alpha: 0.4) : const Color(0xFFF9FAFB),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(color: cs.primary, width: 1.5),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Type Selector Cards (Repeat vs Once)
                    Text(
                      'Pilih Tipe Siklus',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        // Repeat Card
                        Expanded(
                          child: InkWell(
                            onTap: () => setSheetState(() => selectedType = FinancialTargetType.repeat),
                            borderRadius: BorderRadius.circular(14.r),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                              decoration: BoxDecoration(
                                color: selectedType == FinancialTargetType.repeat
                                    ? cs.primary.withValues(alpha: 0.1)
                                    : (isDark ? cs.surfaceContainerHighest.withValues(alpha: 0.3) : const Color(0xFFF9FAFB)),
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: selectedType == FinancialTargetType.repeat ? cs.primary : cs.outline.withValues(alpha: 0.2),
                                  width: selectedType == FinancialTargetType.repeat ? 1.8 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.repeat_rounded,
                                        size: 20.sp,
                                        color: selectedType == FinancialTargetType.repeat ? cs.primary : cs.onSurface.withValues(alpha: 0.6),
                                      ),
                                      const Spacer(),
                                      if (selectedType == FinancialTargetType.repeat)
                                        Icon(Icons.check_circle_rounded, size: 18.sp, color: cs.primary),
                                    ],
                                  ),
                                  SizedBox(height: 10.h),
                                  Text(
                                    'Rutin Bulanan',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                      color: selectedType == FinancialTargetType.repeat ? cs.primary : cs.onSurface,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'Gaji pokok, uang saku',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: cs.onSurface.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),

                        // Once Card
                        Expanded(
                          child: InkWell(
                            onTap: () => setSheetState(() => selectedType = FinancialTargetType.once),
                            borderRadius: BorderRadius.circular(14.r),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                              decoration: BoxDecoration(
                                color: selectedType == FinancialTargetType.once
                                    ? const Color(0xFFF97316).withValues(alpha: 0.1)
                                    : (isDark ? cs.surfaceContainerHighest.withValues(alpha: 0.3) : const Color(0xFFF9FAFB)),
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: selectedType == FinancialTargetType.once ? const Color(0xFFF97316) : cs.outline.withValues(alpha: 0.2),
                                  width: selectedType == FinancialTargetType.once ? 1.8 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.event_available_rounded,
                                        size: 20.sp,
                                        color: selectedType == FinancialTargetType.once ? const Color(0xFFF97316) : cs.onSurface.withValues(alpha: 0.6),
                                      ),
                                      const Spacer(),
                                      if (selectedType == FinancialTargetType.once)
                                        Icon(Icons.check_circle_rounded, size: 18.sp, color: const Color(0xFFF97316)),
                                    ],
                                  ),
                                  SizedBox(height: 10.h),
                                  Text(
                                    'Sekali Saja',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                      color: selectedType == FinancialTargetType.once ? const Color(0xFFF97316) : cs.onSurface,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'Project lepas, bonus',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: cs.onSurface.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // Date Selection Form
                    if (selectedType == FinancialTargetType.repeat) ...[
                      Text(
                        'Pilih Tanggal Penggajian / Masuk',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: isDark ? cs.surfaceContainerHighest.withValues(alpha: 0.4) : const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: selectedDayOfMonth,
                            isExpanded: true,
                            icon: Icon(Icons.keyboard_arrow_down_rounded, color: cs.primary),
                            items: List.generate(31, (i) => i + 1).map((day) {
                              return DropdownMenuItem<int>(
                                value: day,
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today_rounded, size: 16.sp, color: cs.primary),
                                    SizedBox(width: 10.w),
                                    Text(
                                      'Setiap tanggal $day tiap bulan',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: cs.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setSheetState(() => selectedDayOfMonth = val);
                              }
                            },
                          ),
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Pilih Tanggal Target Terjadwal',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: selectedSpecificDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 730)),
                            locale: const Locale('id', 'ID'),
                          );
                          if (picked != null) {
                            setSheetState(() => selectedSpecificDate = picked);
                          }
                        },
                        borderRadius: BorderRadius.circular(14.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                          decoration: BoxDecoration(
                            color: isDark ? cs.surfaceContainerHighest.withValues(alpha: 0.4) : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.event_note_rounded, size: 20.sp, color: const Color(0xFFF97316)),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(selectedSpecificDate),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: cs.onSurface,
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    Text(
                                      'Ketuk untuk mengubah tanggal',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: cs.onSurface.withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.calendar_month_rounded, size: 20.sp, color: const Color(0xFFF97316)),
                            ],
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 28.h),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetCtx),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              side: BorderSide(color: cs.outline.withValues(alpha: 0.3)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                            ),
                            child: Text(
                              'Batal',
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: cs.onSurface),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () async {
                              final title = titleController.text.trim();
                              if (title.isEmpty) return;

                              final newTarget = FinancialTarget(
                                id: isEditing ? targetToEdit.id : 'target_${DateTime.now().millisecondsSinceEpoch}',
                                title: title,
                                type: selectedType,
                                dayOfMonth: selectedType == FinancialTargetType.repeat ? selectedDayOfMonth : null,
                                specificDate: selectedType == FinancialTargetType.once ? selectedSpecificDate : null,
                                isEnabled: isEditing ? targetToEdit.isEnabled : true,
                                createdAt: isEditing ? targetToEdit.createdAt : DateTime.now(),
                              );

                              await SpendingPlannerService.saveTarget(newTarget);
                              if (ctx.mounted) {
                                Navigator.pop(sheetCtx);
                                _refreshTargets();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cs.primary,
                              foregroundColor: cs.onPrimary,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                            ),
                            child: Text(
                              isEditing ? 'Simpan Perubahan' : 'Tambah Target',
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(FinancialTarget target) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Target?'),
        content: Text('Yakin ingin menghapus target "${target.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await SpendingPlannerService.deleteTarget(target.id);
              _refreshTargets();
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final now = DateTime.now();

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          SizedBox(height: 12.h),
          Container(
            width: 44.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: cs.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 12.h),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jadwal Target Pemasukan',
                      style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: cs.onSurface),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Atur gajian & proyekan untuk hitungan jatah harian',
                      style: TextStyle(fontSize: 11.sp, color: cs.onSurface.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Target List
          Flexible(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _targets.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Text(
                            'Belum ada target pemasukan.\nTekan tombol + Tambah Target untuk mulai.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                        itemCount: _targets.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.h),
                        itemBuilder: (ctx, idx) {
                          final item = _targets[idx];
                          final nextOccur = item.getNextOccurrence(now);
                          final diffDays = nextOccur?.difference(DateTime(now.year, now.month, now.day)).inDays;

                          String scheduleInfo;
                          if (item.type == FinancialTargetType.repeat) {
                            scheduleInfo = 'Rutin tgl ${item.dayOfMonth ?? 1}';
                          } else {
                            final dateStr = item.specificDate != null ? DateFormat('d MMM yyyy', 'id_ID').format(item.specificDate!) : '-';
                            scheduleInfo = 'Sekali pada $dateStr';
                          }

                          String statusCountdown;
                          if (!item.isEnabled) {
                            statusCountdown = 'Nonaktif';
                          } else if (diffDays == null) {
                            statusCountdown = 'Sudah lewat';
                          } else if (diffDays == 0) {
                            statusCountdown = 'Hari ini!';
                          } else {
                            statusCountdown = '$diffDays hari lagi';
                          }

                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: item.isEnabled ? cs.surface : cs.surfaceContainerHighest.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: item.isEnabled ? cs.outline.withValues(alpha: 0.2) : cs.outline.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Icon
                                Container(
                                  width: 36.w,
                                  height: 36.w,
                                  decoration: BoxDecoration(
                                    color: (item.type == FinancialTargetType.repeat ? const Color(0xFF10B981) : const Color(0xFFF97316)).withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    item.type == FinancialTargetType.repeat ? Icons.repeat_rounded : Icons.event_available_rounded,
                                    color: item.type == FinancialTargetType.repeat ? const Color(0xFF10B981) : const Color(0xFFF97316),
                                    size: 18.sp,
                                  ),
                                ),
                                SizedBox(width: 10.w),

                                // Title & Subtitle (Badge placed under title, title wraps naturally)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        item.title,
                                        style: TextStyle(
                                          fontSize: 13.5.sp,
                                          fontWeight: FontWeight.w700,
                                          color: item.isEnabled ? cs.onSurface : cs.onSurface.withValues(alpha: 0.45),
                                          height: 1.25,
                                        ),
                                        softWrap: true,
                                      ),
                                      SizedBox(height: 4.h),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                                            decoration: BoxDecoration(
                                              color: (item.isEnabled ? (diffDays == 0 ? const Color(0xFF10B981) : cs.primary) : Colors.grey).withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(5.r),
                                            ),
                                            child: Text(
                                              statusCountdown,
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.bold,
                                                color: item.isEnabled ? (diffDays == 0 ? const Color(0xFF10B981) : cs.primary) : Colors.grey,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 6.w),
                                          Flexible(
                                            child: Text(
                                              scheduleInfo,
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                color: cs.onSurface.withValues(alpha: 0.6),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 4.w),

                                // Actions (Switch & 3-dots closely coupled)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Transform.scale(
                                      scale: 0.75,
                                      child: Switch(
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        value: item.isEnabled,
                                        onChanged: (val) async {
                                          await SpendingPlannerService.toggleTarget(item.id, val);
                                          _refreshTargets();
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 24.w,
                                      child: PopupMenuButton<String>(
                                        padding: EdgeInsets.zero,
                                        icon: Icon(Icons.more_vert_rounded, size: 18.sp, color: cs.onSurface.withValues(alpha: 0.6)),
                                        onSelected: (action) {
                                          if (action == 'edit') {
                                            _showAddEditBottomSheet(item);
                                          } else if (action == 'delete') {
                                            _confirmDelete(item);
                                          }
                                        },
                                        itemBuilder: (_) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit_rounded, size: 16),
                                                SizedBox(width: 8),
                                                Text('Edit'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red),
                                                SizedBox(width: 8),
                                                Text('Hapus', style: TextStyle(color: Colors.red)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),

          // Add Target Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddEditBottomSheet(),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Tambah Target Pemasukan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
