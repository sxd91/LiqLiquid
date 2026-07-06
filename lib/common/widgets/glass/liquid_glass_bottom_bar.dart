import 'package:flutter/material.dart';
import 'package:liqliquid/common/widgets/glass/glass_backdrop.dart';
import 'package:liqliquid/common/widgets/glass/interactive_highlight.dart';
import 'package:liqliquid/utils/storage_pref.dart';

/// Tab data for LiquidGlassBottomBar.
class GlassBottomTab {
  final Widget icon;
  final Widget? activeIcon;
  final String? label;
  final VoidCallback? onTap;

  const GlassBottomTab({
    required this.icon,
    this.activeIcon,
    this.label,
    this.onTap,
  });
}

/// Port of KMP LiquidBottomTabs + LiquidBottomTab.
///
/// A glass bottom navigation bar with:
/// - Full bar backdrop (blur + vibrancy)
/// - Animated pill indicator with GlassBackdrop (lens + shadow)
/// - Accent-colored icons on active tab
/// - Support for tap-to-switch
class LiquidGlassBottomBar extends StatefulWidget {
  // Compatibility params from GlassTabBar API (ignored)
  final dynamic settings;
  final dynamic indicatorColor;
  final double innerBlur;
  final bool enableBlend;
  final dynamic isSearchActive;
  final dynamic searchConfig;
  final dynamic selectedIconColor;
  final dynamic unselectedIconColor;
  final double iconSize;
  final double magnification;
  final dynamic quality;
  final int selectedIndex;
  final ValueChanged<int>? onTabSelected;
  final List<GlassBottomTab> tabs;
  final GlassBackdropConfig? barConfig;
  final GlassBackdropConfig? indicatorConfig;
  final Color? accentColor;
  final Color? containerColor;
  final Color? contentColor;
  final double height;
  final EdgeInsets padding;

  const LiquidGlassBottomBar({
    this.settings,
    this.indicatorColor,
    this.innerBlur = 0.5,
    this.enableBlend = false,
    this.isSearchActive,
    this.searchConfig,
    this.selectedIconColor,
    this.unselectedIconColor,
    this.iconSize = 26,
    this.magnification = 1.15,
    this.quality,
    super.key,
    required this.selectedIndex,
    this.onTabSelected,
    required this.tabs,
    this.barConfig,
    this.indicatorConfig,
    this.accentColor,
    this.containerColor,
    this.contentColor,
    this.height = 64,
    this.padding = const EdgeInsets.all(4),
  });

  @override
  State<LiquidGlassBottomBar> createState() => _LiquidGlassBottomBarState();
}

class _LiquidGlassBottomBarState extends State<LiquidGlassBottomBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = widget.accentColor ??
        (isDark ? const Color(0xFF0088FF) : const Color(0xFF0088FF));
    final container = widget.containerColor ??
        (isDark
            ? const Color(0x66121212)
            : const Color(0x66FAFAFA));
    final content = widget.contentColor ??
        (isDark ? Colors.white : Colors.black);

    final tabCount = widget.tabs.length;

    if (!Pref.useLiquidGlass) {
      return BottomNavigationBar(
        currentIndex: widget.selectedIndex,
        onTap: widget.onTabSelected,
        items: widget.tabs.map((tab) {
          return BottomNavigationBarItem(
            icon: tab.icon,
            activeIcon: tab.activeIcon,
            label: tab.label ?? '',
          );
        }).toList(),
        selectedItemColor: accent,
        unselectedItemColor: content.withValues(alpha: 0.6),
      );
    }

    return Container(
      height: widget.height,
      padding: widget.padding,
      child: GlassBackdrop(
        config: widget.barConfig ??
            GlassBackdropConfig(
              effects: [
                const VibrancyEffect(saturation: 1.5),
                const BlurEffect(radius: 8),
              ],
              surfaceColor: container,
              borderRadius: BorderRadius.circular(widget.height / 2 - 4),
            ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final tabWidth = (totalWidth - widget.padding.horizontal) / tabCount;
            final indicatorWidth = tabWidth;

            return Stack(
              children: [
                // Indicator pill
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  left: widget.padding.left +
                      widget.selectedIndex * tabWidth +
                      (tabWidth - indicatorWidth) / 2,
                  top: (widget.height - widget.padding.vertical - 56) / 2,
                  child: GlassBackdrop(
                    config: widget.indicatorConfig ??
                        GlassBackdropConfig(
                          effects: [
                            const LensEffect(
                              refractionHeight: 14,
                              refractionAmount: 14,
                              chromaticAberration: true,
                            ),
                          ],
                          surfaceColor: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(28),
                          shadows: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                    child: Container(
                      width: indicatorWidth,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
                // Tabs
                Row(
                  children: List.generate(tabCount, (index) {
                    final isSelected = index == widget.selectedIndex;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          widget.tabs[index].onTap?.call();
                          widget.onTabSelected?.call(index);
                        },
                        child: InteractiveHighlight(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconTheme(
                                data: IconThemeData(
                                  color: isSelected ? accent : content.withValues(alpha: 0.5),
                                  size: 28,
                                ),
                                child: isSelected && widget.tabs[index].activeIcon != null
                                    ? widget.tabs[index].activeIcon!
                                    : widget.tabs[index].icon,
                              ),
                              if (widget.tabs[index].label != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  widget.tabs[index].label!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected
                                        ? accent
                                        : content.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
