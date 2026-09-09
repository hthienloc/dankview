# dank-qml-common

Common QML assets for DMS, Dank Calendar, and the rest of the Dank Linux Suite.

The library lives in `DankCommon/` and is consumed through Quickshell's `qs.` namespace:

```qml
import qs.DankCommon.Widgets
import qs.DankCommon.Common
import qs.DankCommon.Modals.FileBrowser
import qs.DankCommon.Session
```

`DankCommon/Session/` holds the components shared between the DMS lock screen and [dms-greeter](https://github.com/AvengeMedia/dank-greeter): the power menu (`LockPowerMenu`) and the on-screen keyboard (`Keyboard`, `KeyboardController`, `CustomButtonKeyboard`). `DankCommon/Common/LayoutCodes.js` (keyboard layout name → short code) is imported by relative path.

## Consuming from an app

Add this repo as a git submodule at the app repo root, then symlink it into the quickshell config root:

```sh
git submodule add https://github.com/AvengeMedia/dank-qml-common.git dank-qml-common
ln -s ../dank-qml-common/DankCommon quickshell/DankCommon
```

Anything that copies the quickshell tree for packaging must dereference the symlink (`cp -rL`) - `go:embed` and most packaging flows reject symlinks.

## Standalone development

The repo root is a runnable Quickshell config with stub singletons and a widget gallery:

```sh
qs -p /path/to/dank-qml-common
```

For qmlls completion, create an empty `.qmlls.ini` at the repo root once (`touch .qmlls.ini`, gitignored) - quickshell replaces it with a generated config on the next launch, and every file in the repo gets language-server support. The stubs in `Common/` and `Services/` double as the executable contract below - if a shared widget needs a new singleton property, add it to the stub in the same change.

## Expressive variants

`DankCommon/Widgets/Expressive/` (`qs.DankCommon.Widgets.Expressive`) holds Material 3 Expressive restyles of the interactive widgets (toggle, slider, buttons, button group, chips, tabs, dropdown, text fields, stepper, collapsible section, location search, refresh button, tooltip) plus `DankCard` (tonal surfaces with shared content colors, focus and pressed states), `DankClockFace` (responsive digital and stacked time layouts), `DankTimePicker`, `DankMonthGrid` (a month calendar grid with day cells, event dots, week numbers, optional weekend tint and a `dayClicked` signal), `DankMaterialShape` (M3 expressive shapes such as cookie, sunny, burst, clover, gem and diamond drawn with QtQuick.Shapes) and `DankSparkline` (a smoothed trend line with area fill for one or two series). The restyled files keep the exact public API of their classic sibling so an app switches by changing the import in its re-export stubs; the new widgets have no classic counterpart. Files there import the classic module `as Base` for shared leaves (`Base.StyledText`, `Base.DankIcon`, ...); an unqualified `import qs.DankCommon.Widgets` would outrank the directory and instantiate the classic sibling. Expressive widgets read the shape scale, state layer, spring and on-role tokens listed below.

## The contract

Shared code never imports app singletons. The app injects them once at startup (`DC.Style.theme = Theme`, `DC.Style.settings = SettingsData`, `DC.I18n.backend = I18n`, `DC.Paths.backend = Paths`, `DC.Log.backend = Log`, `DC.Host.session = SessionService`, `DC.Host.cache = CacheData`, with `import qs.DankCommon.Common as DC`), and `Style` reads every token through `theme?.x ?? fallback`. The gallery's `shell.qml` does the same with the stubs in `Common/` and `Services/`. Every consuming app must provide these singletons with at least the properties the library reads:

### `qs.Common` → Theme

Colors: `primary`, `primaryText`, `primaryContainer`, `primaryHover`, `primaryHoverLight`, `primaryPressed`, `primarySelected`, `secondary`, `surface`, `surfaceText`, `surfaceTextHover`, `surfaceTextMedium`, `surfaceTextSecondary`, `surfaceVariant`, `surfaceVariantText`, `surfaceVariantAlpha`, `surfaceHover`, `surfacePressed`, `surfaceContainer`, `surfaceContainerHigh`, `surfaceTint`, `surfaceLight`, `background`, `outline`, `outlineButton`, `outlineMedium`, `outlineStrong`, `outlineHeavy`, `error`, `errorHover`, `errorSelected`, `warning`, `shadowStrong`, `buttonBg`, `buttonText`, `buttonHover`, `buttonPressed`, `floatingSurface`, `nestedSurface`, `floatingWindowSurface`, `floatingWindowNestedSurface`, `floatingWindowFieldColor`, `floatingWindowFieldBorderColor`, `floatingWindowFieldFocusedBorderColor`, `popupFieldColor`, `popupFieldBorderColor`, `popupFieldFocusedBorderColor`, `widgetBaseHoverColor`, `onPrimary`, `onSurface`, `onSurface_12`, `onSurface_38`.
 M3 Expressive widgets (`qs.DankCommon.Widgets.Expressive`) additionally read `tertiary`, `surfaceContainerLowest`, `surfaceContainerLow`, `surfaceContainerHighest`, `surfaceBright`, `surfaceDim`, `outlineVariant`, `secondaryContainer`, `tertiaryContainer`, `onSurfaceVariant`, `onSurfaceVariant_30`, `onPrimaryContainer`, `onSecondaryContainer`, `onTertiaryContainer`, `inverseSurface`, `inverseOnSurface`, `tonalTintAlpha`.

Metrics: `spacingXXS`..`spacingXL`, `fontSizeSmall`..`fontSizeXLarge`, `iconSizeSmall`/`iconSize`/`iconSizeLarge`, `cornerRadius`.
 Expressive: `fontSizeXXLarge`, the shape scale `shapeScale`, `cornerRadiusXS`..`cornerRadiusXXL`, `cornerRadiusFull` (`cornerRadiusSmall`/`cornerRadiusLarge` alias S/L), `groupedListGap`, `groupedListInnerRadius`, `groupedListOuterRadius`, `iconButtonSize`, `listItemHeight`, `listItemTwoLineHeight`, `avatarSize`, `sliderTrackHeight`, `sliderHandleWidth`, `sliderHandleHeight`, `sliderHandleGap`, `sliderTrackHeightS/M/L/XL`, `sliderHandleHeightS/M/L/XL`, `switchTrackWidth`, `switchTrackHeight`, `switchOutlineWidth`, `switchThumbUnselected`, `switchThumbSelected`, `switchThumbPressed`, `sliderStopSize`, `sliderTickSize`, `menuItemHeight`, `iconSizeMedium`, `outlineWidth`, `outlineWidthFocused`, `dividerWidth`, `focusRingWidth`, `focusRingOffset`, `focusRingColor`, `scrimAlpha`, `smallBreakpoint`, `mediumBreakpoint`, `fontSizeDisplay`, `buttonHeightXS/S/M`, `buttonMinWidth`, `pressScale`, `iconEnterScale`, `popupEnterScale`, `pendingOpacity`, `spinnerStrokeWidth`, `tabMinWidth`, `tabIndicatorHeight`, `fieldDefaultWidth`, `fieldHeight`, `fieldHeightLarge`, `textEditHeight`, `tooltipMaxWidth`, `menuMaxHeight`, `clockFaceSize`, `clockOuterRingRatio`, `clockInnerRingRatio`, `clockHandWidth`, `clockHandleSize`, `clockCenterSize`, `clockSwitchDelay`, `chipIconSize`, `buttonGroupExpandRatio`.

`DankLayer` groups content for opacity effects and sizes its texture in physical pixels using the window's device pixel ratio.

Google Sans Flex is bundled under the [SIL Open Font License](DankCommon/assets/fonts/google-sans-flex/OFL.txt), from [Google Fonts](https://fonts.google.com/specimen/Google+Sans+Flex).

Typography: `fontFamily`, `monoFontFamily`, `defaultFontFamily`, `defaultMonoFontFamily`, `fontWeight`. The library bundles and registers its own fonts (Google Sans Flex, FiraCode Nerd Font, Material Symbols - `DankCommon/assets/fonts/`) through the `Fonts` singleton in `qs.DankCommon.Common`; apps typically bind `defaultFontFamily: Fonts.sans` and `defaultMonoFontFamily: Fonts.mono` rather than shipping font files of their own.

Animation: `shorterDuration`, `shortDuration`, `mediumDuration`, `standardEasing`, `emphasizedEasing`, `currentAnimationSpeed`, `expressiveCurves`, `expressiveDurations`.
 Expressive: `stateLayerHover`, `stateLayerFocus`, `stateLayerPressed`, `stateLayerDrag`, `springSpecs`, `springDampingScales`, `springMotionDisabled`, `springPreset(name, baseDuration)` returning `{stiffness, damping, mass}`, `elevationLevel1`, `elevationLevel3`.

Misc: `isLightMode`, `popupTransparency`, `floatingWindowTransparency`, `blurLayersActive`, `connectedSurfaceBlurEnabled`, `elevationEnabled`, `elevationLevel2` (`{blurPx, offsetX, offsetY, spreadPx, alpha}`), `currentAnimationBaseDuration`, `withAlpha(color, alpha)` - which must tolerate an undefined color and return transparent - and `blendAlpha(color, alpha)` with the same tolerance.

Optional (used by `ElevationShadow` when present, static fallbacks otherwise): `elevationLightDirection`, `elevationOffsetXFor()`, `elevationOffsetYFor()`, `elevationShadowColor()`, `elevationAmbient()`.

### `qs.Common` → SettingsData

Enums `AnimationSpeed`, `TextRenderType`, `TextRenderQuality`; properties `animationSpeed`, `enableRippleEffects`, `popoutElevationEnabled`, `textRenderType`, `textRenderQuality`.
 Expressive motion: `reduceMotion`, `springBounce`. Blur border (FileBrowser): `blurBorderEnabled`, `blurBorderOpacity`, `blurBorderColor`, `blurBorderCustomColor`.

Power menu (Session components): `powerActionConfirm`, `powerActionHoldDuration`, `powerMenuActions`, `powerMenuDefaultAction`, `powerMenuGridLayout`.

### `qs.Common` → Anims, Paths, CacheData, I18n

- Anims: `durShort`, `standard`, `emphasized` (bezier arrays)
- Paths: `xdgCache`, `imagecache` (urls), `strip(url)`, `stringify(url)`, `resolveIconPath(iconName)` (return `""` when the app has no icon-theme resolution), `trashPath(path, callback)` (callback receives a success bool), `copyPathToClipboard(path)`; the app must create `imagecache`. The stub defaults use `gio trash` and `Quickshell.clipboardText` - apps route these through their own trash and clipboard machinery so the library itself imposes no runtime dependency
- CacheData: `fileBrowserSettings` (var), `wallpaperLastPath`, `profileLastPath`, `saveCache()`
- I18n: `tr(term, context)`, `isRtl`

### `qs.Services` → Log

`scoped(module)` returning `{debug, info, warn, error}`.

### `qs.Services` → SessionService

Used by `LockPowerMenu`: `hibernateSupported` plus `logout()`, `suspend()`, `hibernate()`, `reboot()`, `poweroff()`. Apps where an action makes no sense (logout in a greeter) provide it as a no-op.

## Translations

Widget strings are owned here, not by the consuming apps. `translations/extract_translations.py` scrapes `I18n.tr()` from `DankCommon/` into `translations/en.json`; the DMS POEditor project is the source of truth for translating those terms, and its sync writes the per-locale exports into `DankCommon/translations/poexports/`. Because that directory lives inside `DankCommon/`, translations ship to every consumer with the submodule pointer like any other file.

Consuming apps keep their own POEditor projects app-only (their extractors must not descend into `DankCommon/`) and merge both sources at runtime in their `I18n` singleton - app terms win on collision.

## Making changes

The submodule is a real worktree; edit it in place inside whichever app you are working on and the running app picks changes up live. Land the library PR first, then bump the pointer in the app (`make update-common` keeps the submodule and nix flake input in lockstep; app CI re-syncs flake.lock automatically if they drift). If a change reads a new app-singleton property, add it to the root stubs and the contract above in the same PR; the gallery won't run without it. Other consumers upgrade whenever they bump the pointer - no lockstep.

## Notes

- `Common/Proc.qml` exposes `dmsBin` (`DMS_EXECUTABLE` env override) as a DMS convenience; it is inert elsewhere.
- Log stays app-owned so each app keeps its own env-var prefix (`DMS_LOG_LEVEL`, `DANKCAL_LOG_LEVEL`, ...).
