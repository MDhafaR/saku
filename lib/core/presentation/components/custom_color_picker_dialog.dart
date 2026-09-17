import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shows a rich custom color picker dialog
Future<Color?> showCustomColorPickerDialog(
  BuildContext context, {
  required Color initialColor,
}) {
  return showDialog<Color>(
    context: context,
    builder: (context) => CustomColorPickerDialog(initialColor: initialColor),
  );
}

class CustomColorPickerDialog extends StatefulWidget {
  final Color initialColor;

  const CustomColorPickerDialog({
    super.key,
    required this.initialColor,
  });

  @override
  State<CustomColorPickerDialog> createState() =>
      _CustomColorPickerDialogState();
}

class _CustomColorPickerDialogState extends State<CustomColorPickerDialog> {
  late HSVColor _hsvColor;
  late TextEditingController _hexController;
  bool _isHexUpdating = false;

  final List<Color> _curatedPalettes = const [
    Color(0xFFFF1744), // Neon Red
    Color(0xFFFF5252), // Coral
    Color(0xFFFF6D00), // Amber Deep
    Color(0xFFFFAB00), // Gold
    Color(0xFFAEEA00), // Lime
    Color(0xFF00E676), // Spring Green
    Color(0xFF1DE9B6), // Mint Teal
    Color(0xFF00E5FF), // Electric Cyan
    Color(0xFF2979FF), // Bright Blue
    Color(0xFF651FFF), // Deep Purple
    Color(0xFFD500F9), // Magenta Neon
    Color(0xFFF50057), // Rose Pink
    Color(0xFF8D6E63), // Mocha
    Color(0xFF78909C), // Slate
    Color(0xFF263238), // Dark Navy
  ];

  @override
  void initState() {
    super.initState();
    _hsvColor = HSVColor.fromColor(widget.initialColor);
    _hexController = TextEditingController(text: _colorToHex(_hsvColor.toColor()));
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  String _colorToHex(Color color) {
    return color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
  }

  void _updateFromHsv(HSVColor newHsv) {
    setState(() {
      _hsvColor = newHsv;
      if (!_isHexUpdating) {
        _hexController.text = _colorToHex(_hsvColor.toColor());
      }
    });
  }

  void _updateFromHex(String hex) {
    final cleanHex = hex.replaceAll('#', '').trim();
    if (cleanHex.length == 6) {
      final value = int.tryParse('FF$cleanHex', radix: 16);
      if (value != null) {
        _isHexUpdating = true;
        setState(() {
          _hsvColor = HSVColor.fromColor(Color(value));
        });
        _isHexUpdating = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final currentColor = _hsvColor.toColor();

    return Dialog(
      backgroundColor: isDark ? colorScheme.surface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const SweepGradient(
                        colors: [
                          Colors.red,
                          Colors.yellow,
                          Colors.green,
                          Colors.cyan,
                          Colors.blue,
                          Colors.purple,
                          Colors.red,
                        ],
                      ),
                    ),
                    padding: EdgeInsets.all(2.w),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? colorScheme.surface : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.palette_rounded,
                        size: 18.sp,
                        color: currentColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pilih Warna Kustom',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Atur saturasi, kecerahan & kode HEX',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: colorScheme.onSurfaceVariant,
                      size: 20.sp,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Preview Box & Hex Input
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isDark
                      ? colorScheme.surfaceContainer
                      : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    // Color Preview swatch
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: currentColor,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: currentColor.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 14.w),
                    // Hex input field
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KODE HEX',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Text(
                                '#',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: TextField(
                                  controller: _hexController,
                                  maxLength: 6,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                    letterSpacing: 1.2,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    counterText: '',
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: _updateFromHex,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // 1. Hue Slider (Spectrum)
              Text(
                'Warna Dasar (Hue)',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 6.h),
              _buildSliderTrack(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF0000),
                    Color(0xFFFFFF00),
                    Color(0xFF00FF00),
                    Color(0xFF00FFFF),
                    Color(0xFF0000FF),
                    Color(0xFFFF00FF),
                    Color(0xFFFF0000),
                  ],
                ),
                value: _hsvColor.hue / 360,
                onChanged: (val) {
                  _updateFromHsv(_hsvColor.withHue(val * 360));
                },
              ),
              SizedBox(height: 12.h),

              // 2. Saturation Slider
              Text(
                'Kepekatan (Saturation)',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 6.h),
              _buildSliderTrack(
                gradient: LinearGradient(
                  colors: [
                    HSVColor.fromAHSV(1.0, _hsvColor.hue, 0.0, _hsvColor.value)
                        .toColor(),
                    HSVColor.fromAHSV(1.0, _hsvColor.hue, 1.0, _hsvColor.value)
                        .toColor(),
                  ],
                ),
                value: _hsvColor.saturation,
                onChanged: (val) {
                  _updateFromHsv(_hsvColor.withSaturation(val));
                },
              ),
              SizedBox(height: 12.h),

              // 3. Brightness/Value Slider
              Text(
                'Kecerahan (Brightness)',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 6.h),
              _buildSliderTrack(
                gradient: LinearGradient(
                  colors: [
                    Colors.black,
                    HSVColor.fromAHSV(1.0, _hsvColor.hue, _hsvColor.saturation, 1.0)
                        .toColor(),
                  ],
                ),
                value: _hsvColor.value,
                onChanged: (val) {
                  _updateFromHsv(_hsvColor.withValue(val));
                },
              ),
              SizedBox(height: 16.h),

              // Quick Swatches
              Text(
                'Pilihan Cepat',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _curatedPalettes.map((color) {
                  final isSelected = currentColor.toARGB32() == color.toARGB32();
                  return GestureDetector(
                    onTap: () {
                      _updateFromHsv(HSVColor.fromColor(color));
                    },
                    child: Container(
                      width: 26.w,
                      height: 26.w,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 6,
                            ),
                        ],
                      ),
                      child: isSelected
                          ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 24.h),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.25),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentColor,
                        foregroundColor:
                            _hsvColor.value < 0.5 ? Colors.white : Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, currentColor);
                      },
                      child: Text(
                        'Pilih Warna',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 4,
                            ),
                          ],
                        ),
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
  }

  Widget _buildSliderTrack({
    required Gradient gradient,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final thumbRadius = 10.w;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (details) {
            final localX = details.localPosition.dx.clamp(0.0, trackWidth);
            onChanged(localX / trackWidth);
          },
          onTapDown: (details) {
            final localX = details.localPosition.dx.clamp(0.0, trackWidth);
            onChanged(localX / trackWidth);
          },
          child: Container(
            height: 24.h,
            alignment: Alignment.centerLeft,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Gradient Track
                Container(
                  height: 12.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                ),
                // Thumb
                Positioned(
                  left: (value.clamp(0.0, 1.0) * (trackWidth - (thumbRadius * 2))),
                  child: Container(
                    width: thumbRadius * 2,
                    height: thumbRadius * 2,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.2),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
