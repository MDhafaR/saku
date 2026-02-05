import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  bool _isReminderEnabled = true;
  List<String> _reminderTimes = ['08:00', '20:00'];
  int _selectedMessageType = 1; // 0: Random, 1: Custom
  final TextEditingController _customMessageController = TextEditingController(
    text: "Jangan lupa catat pengeluaran hari ini ya! 💸",
  );

  @override
  void dispose() {
    _customMessageController.dispose();
    super.dispose();
  }

  void _addTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF111111)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (!_reminderTimes.contains(formattedTime)) {
        setState(() {
          _reminderTimes.add(formattedTime);
          _reminderTimes.sort();
        });
      }
    }
  }

  void _removeTime(String time) {
    setState(() {
      _reminderTimes.remove(time);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          'Pengingat Harian',
          style: TextStyle(
            color: const Color(0xFF111111),
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Master Toggle
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aktifkan Pengingat',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Terima notifikasi untuk membangun kebiasaan',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isReminderEnabled,
                    onChanged: (val) =>
                        setState(() => _isReminderEnabled = val),
                    activeColor: const Color(0xFF111111), // Primary Dark
                  ),
                ],
              ),
            ),

            if (_isReminderEnabled) ...[
              SizedBox(height: 24.h),
              // Frequency Schedule
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'JADWAL FREKUENSI',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[400],
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ..._reminderTimes.map(
                      (time) => Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  time,
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.grey[400],
                                    size: 24.sp,
                                  ),
                                  onPressed: () => _removeTime(time),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.grey[100],
                                    padding: EdgeInsets.all(8.w),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            if (time != _reminderTimes.last)
                              Divider(height: 1.h, color: Colors.grey[100]),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 8.h),
                    InkWell(
                      onTap: _addTime,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: const BoxDecoration(
                                color: Color(0xFF111111),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 16.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Tambah Waktu Pengingat',
                              style: TextStyle(
                                color: const Color(0xFF111111),
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),
              // Content Message
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KONTEN PESAN',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[400],
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Option 1
                    _buildRadioOption(0, 'Kutipan Acak (Default)'),
                    SizedBox(height: 12.h),
                    // Option 2
                    _buildRadioOption(1, 'Pesan Kustom'),

                    if (_selectedMessageType == 1) ...[
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: _customMessageController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Tulis pesan penyemangatmu...',
                              ),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF4B5563),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Icon(
                                Icons.edit,
                                size: 16.sp,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Pesan ini akan dikirim sesuai jadwal di atas.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: 40.h),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(int value, String label) {
    final isSelected = _selectedMessageType == value;
    return InkWell(
      onTap: () => setState(() => _selectedMessageType = value),
      child: Row(
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? const Color(0xFF111111) : Colors.grey[300]!,
                width: isSelected ? 6.w : 1.w,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}
