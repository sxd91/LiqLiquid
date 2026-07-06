import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liqliquid/utils/storage.dart';
import 'package:liqliquid/utils/storage_key.dart';
import 'package:liqliquid/utils/storage_pref.dart';

class GlassAppearancePage extends StatefulWidget {
  const GlassAppearancePage({super.key});
  @override
  State<GlassAppearancePage> createState() => _GlassAppearancePageState();
}

class _GlassAppearancePageState extends State<GlassAppearancePage> {
  final _setting = GStorage.setting;
  late double _blur, _refraction, _chromatic, _opacity, _scrollBlur;
  late double _topBaseBlur, _topHeight;
  late int _topLayers;
  @override
  void initState() {
    super.initState();
    _blur = Pref.glassBlur;
    _refraction = Pref.glassRefraction;
    _chromatic = Pref.glassChromatic;
    _opacity = Pref.glassOpacity;
    _scrollBlur = Pref.glassMaxScrollBlur;
    _topBaseBlur = Pref.topBlurBaseBlur;
    _topHeight = Pref.topBlurHeight;
    _topLayers = Pref.topBlurLayers;
  }

  void _put(String key, dynamic v) {
    _setting.put(key, v);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final previewSettings = LiquidGlassSettings(
      glassColor: isDark
          ? cs.primaryContainer.withValues(alpha: _opacity * 0.8)
          : cs.surfaceContainerHighest.withValues(alpha: _opacity),
      blur: _blur,
      refractiveIndex: _refraction,
      chromaticAberration: _chromatic,
      thickness: 12,
      lightIntensity: isDark ? 0.5 : 0.35,
      ambientStrength: isDark ? 0.25 : 0.15,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('液态玻璃外观')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Preview
          Text('预览', style: TextStyle(fontSize: 14, color: cs.primary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: Stack(
              children: [
                // Colorful background behind glass
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(colors: [
                        Color(0xFFFF6B6B), Color(0xFF4ECDC4), Color(0xFF45B7D1),
                      ]),
                    ),
                    child: const Center(
                      child: Text('背景内容 - 透过玻璃可见',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ),
                // Glass overlay
                Positioned.fill(
                  child: GlassCard(
                    settings: previewSettings,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GlassButton(icon: const Icon(Icons.favorite), width: 48, height: 48, iconSize: 20, onTap: () {}),
                        GlassSwitch(value: true, onChanged: (_) {}),
                        GlassSlider(value: 50, min: 0, max: 100, onChanged: (_) {}),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Glass params
          _section('全局玻璃参数'),
          _slider(SettingBoxKey.glassBlur, '模糊强度', _blur, 0, 50, (v) => _blur = v),
          _slider(SettingBoxKey.glassRefraction, '折射扭曲', _refraction, 0, 2, (v) => _refraction = v),
          _slider(SettingBoxKey.glassChromatic, '色散', _chromatic, 0, 1, (v) => _chromatic = v),
          _slider(SettingBoxKey.glassOpacity, '不透明度', _opacity, 0, 0.5, (v) => _opacity = v),
          _slider(SettingBoxKey.glassMaxScrollBlur, '滚动模糊上限', _scrollBlur, 0, 30, (v) => _scrollBlur = v),
          const SizedBox(height: 12),

          _section('顶部渐变模糊'),
          _slider(SettingBoxKey.topBlurBaseBlur, '基础模糊', _topBaseBlur, 0, 50, (v) => _topBaseBlur = v),
          _sliderInt(SettingBoxKey.topBlurLayers, '层数', _topLayers, 1, 10, (v) => _topLayers = v),
          _slider(SettingBoxKey.topBlurHeight, '高度', _topHeight, 40, 200, (v) => _topHeight = v),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 4),
    child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
  );

  Widget _slider(String key, String label, double val, double min, double max, Function(double) onChanged) {
    return Row(children: [
      SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12))),
      Expanded(
        child: GlassSlider(
          value: val, min: min, max: max,
          onChanged: (v) { onChanged(v); _put(key, v); },
        ),
      ),
      SizedBox(width: 40, child: Text(val.toStringAsFixed(2), style: const TextStyle(fontSize: 11))),
    ]);
  }

  Widget _sliderInt(String key, String label, int val, int min, int max, Function(int) onChanged) {
    return Row(children: [
      SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12))),
      Expanded(
        child: Slider(
          value: val.toDouble(), min: min.toDouble(), max: max.toDouble(), divisions: max - min,
          onChanged: (v) { final iv = v.round(); onChanged(iv); _put(key, iv); },
          label: '$val',
        ),
      ),
      SizedBox(width: 40, child: Text('$val', style: const TextStyle(fontSize: 11))),
    ]);
  }
}
