import 'package:flutter/material.dart';
import 'package:liqliquid/common/widgets/glass/glass_backdrop.dart';
import 'package:liqliquid/common/widgets/glass/glass_factory.dart';
import 'package:liqliquid/common/widgets/glass/liquid_glass_slider.dart';
import 'package:liqliquid/common/widgets/glass_interaction.dart';
import 'package:liqliquid/utils/platform_utils.dart';
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
  late double _lightIntensity, _ambientStrength;
  late double _bottomBlur, _bottomRefraction, _bottomChromatic;

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _lightIntensity = isDark ? 0.5 : 0.35;
    _ambientStrength = isDark ? 0.25 : 0.15;
    _bottomBlur = Pref.bottomBarBlur;
    _bottomRefraction = Pref.bottomBarRefractiveIndex;
    _bottomChromatic = Pref.bottomBarChromaticAberration;
  }

  void _put(String key, dynamic v) { _setting.put(key, v); setState(() {}); }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final previewSettings = GlassBackdropConfig(effects: [BlurEffect(radius: _blur), VibrancyEffect(saturation: 1.2)], 
      surfaceColor: isDark
          ? cs.primaryContainer.withValues(alpha: _opacity * 0.8)
          : cs.surfaceContainerHighest.withValues(alpha: _opacity),
      blur: _blur,
      refractionAmount: _refraction,
      chromaticAberration: _chromatic,
      refractionHeight: 12,
      
      
    );

    return Scaffold(
      appBar: AppBar(title: const Text('液态玻璃外观')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('预览', style: TextStyle(fontSize: 14, color: cs.primary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: Stack(
              children: [
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
                Positioned.fill(
                  child: GlassBackdrop(config: GlassFactory.standardGlass(context), child: 
                    
                    settings: previewSettings,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        LiquidGlassButton( icon: const Icon(Icons.favorite), width: 48, height: 48, iconSize: 20, onTap: () {}),
                        LiquidGlassToggle( value: true, onChanged: (_) {}),
                        LiquidGlassSlider( value: 50, min: 0, max: 100, onChanged: (_) {}),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _section('全局玻璃参数'),
          _slider(SettingBoxKey.glassBlur, '模糊强度', _blur, 0, 50, (v) => _blur = v),
          _slider(SettingBoxKey.glassRefraction, '折射扭曲', _refraction, 0, 2, (v) => _refraction = v),
          _slider(SettingBoxKey.glassChromatic, '色散强度', _chromatic, 0, 1, (v) => _chromatic = v),
          _slider(SettingBoxKey.glassOpacity, '不透明度', _opacity, 0, 0.5, (v) => _opacity = v),
          _slider(SettingBoxKey.glassMaxScrollBlur, '滚动模糊上限', _scrollBlur, 0, 30, (v) => _scrollBlur = v),
          _sliderNoKey('光照强度', _lightIntensity, 0, 1.5, (v) { _lightIntensity = v; setState(() {}); }),
          _sliderNoKey('环境光', _ambientStrength, 0, 0.5, (v) { _ambientStrength = v; setState(() {}); }),
          const SizedBox(height: 12),

          _section('顶部渐变模糊'),
          _slider(SettingBoxKey.topBlurBaseBlur, '基础模糊', _topBaseBlur, 0, 50, (v) => _topBaseBlur = v),
          _sliderInt(SettingBoxKey.topBlurLayers, '层数', _topLayers, 1, 10, (v) => _topLayers = v),
          _slider(SettingBoxKey.topBlurHeight, '高度', _topHeight, 40, 200, (v) => _topHeight = v),
          const SizedBox(height: 12),

          _section('底部导航栏玻璃'),
          _slider(SettingBoxKey.bottomBarBlur, '底栏模糊', _bottomBlur, 0, 50, (v) { _bottomBlur = v; _put(SettingBoxKey.bottomBarBlur, v); }),
          _slider(SettingBoxKey.bottomBarRefractiveIndex, '底栏折射', _bottomRefraction, 0, 2, (v) { _bottomRefraction = v; _put(SettingBoxKey.bottomBarRefractiveIndex, v); }),
          _slider(SettingBoxKey.bottomBarChromaticAberration, '底栏色散', _bottomChromatic, 0, 1, (v) { _bottomChromatic = v; _put(SettingBoxKey.bottomBarChromaticAberration, v); }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _section(String t) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 4),
    child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
  );

  Widget _slider(String key, String label, double val, double min, double max, Function(double) cb) {
    return Row(children: [
      SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12))),
      Expanded(child: LiquidGlassSlider( value: val, min: min, max: max, onChanged: (v) { cb(v); _put(key, v); })),
      SizedBox(width: 40, child: Text(val.toStringAsFixed(2), style: const TextStyle(fontSize: 11))),
    ]);
  }

  Widget _sliderNoKey(String label, double val, double min, double max, Function(double) cb) {
    return Row(children: [
      SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12))),
      Expanded(child: Slider(value: val, min: min, max: max, onChanged: cb)),
      SizedBox(width: 40, child: Text(val.toStringAsFixed(2), style: const TextStyle(fontSize: 11))),
    ]);
  }

  Widget _sliderInt(String key, String label, int val, int min, int max, Function(int) cb) {
    return Row(children: [
      SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12))),
      Expanded(child: Slider(value: val.toDouble(), min: min.toDouble(), max: max.toDouble(), divisions: max - min,
        onChanged: (v) { final iv = v.round(); cb(iv); _put(key, iv); }, label: '$val')),
      SizedBox(width: 40, child: Text('$val', style: const TextStyle(fontSize: 11))),
    ]);
  }
}