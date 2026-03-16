# Changelog
## [1.1.2] - 2026-03-16

### Added

- Add optional backdrop blur effect to settings panel overlay

---

## [1.1.1] - 2026-03-13

### Fixed

- Minor bug fixes and stability improvements.

---

## [1.1.0] - 2026-03-03

### Fixed

- **Memory leak** — Fixed an issue where the old `VideoPlayerController` position listener was not removed when switching sources. Added `_lastVideoController` tracking mechanism.
- **Fullscreen landscape layout** — Fixed incorrect `AspectRatio` usage when entering fullscreen due to `OrientationBuilder` delay. Replaced with `isFullScreen || isLandscape` logic.
- **`VideoCoreAspectRadio` crash** — Fixed crash caused by force unwrapping (`!`) when `video` was null or not initialized. Added null-safe checks.
- **`KenjiPlayer` silent init failure** — When `initialize()` failed, the UI remained stuck in loading state. Added try/catch and introduced an error widget with retry button.
- **Duration formatter bug** — `1:30:00` was incorrectly displayed as `1:90:00`. Added `remainder(60)` to `inMinutes` / `inSeconds`.
- **`VideoCoreAspectRadio` rebuild** — `listen: false` prevented rebuild when `isFullScreen` changed. Updated to `listen: true`.
- **`QualityMenu` duplicate condition** — Removed duplicated `if (entry.key != activeSourceName)` condition.
- **`SpeedMenu` null crash** — Made `video!.value.playbackSpeed` null-safe using `?.`.
- **`OverlayBottom` dead code** — Removed unused `_showRemaingText` `ValueNotifier` and converted to `StatelessWidget`.
- **`VideoCoreActiveSubtitleText` duplicate query** — Removed duplicate `listen: true` call and kept a single listener.
- **`CenterPlayAndPause` misleading naming** — Changed `isPlaying = !controller.isPlaying` → `playing = controller.isPlaying` for clarity.
- **Controller ownership** — `KenjiPlayer` previously disposed externally provided `KenjiPlayerController`. Added `_ownsController` flag to ensure only internally created controllers are disposed.

### Added

- **Error state UI** — Displays an error message with a "Retry" button when video loading fails. Added `VideoErrorState` and `retryCurrentSource()`.
- **Adaptive bitrate** — Automatically switches to lower quality when buffer drops below 10 seconds. Added `bufferHealthRatio` getter.
- **Pinch to zoom** — Added `ScaleGestureDetector` to support zooming between 1.0×–3.0×.
- **Fullscreen orientation lock** — Locks to `landscapeLeft + landscapeRight` automatically when entering fullscreen.
- **Fullscreen system UI** — Hides status bar and navigation bar using `SystemUiMode.immersiveSticky` in fullscreen. Restores `edgeToEdge` mode on exit.
- **Battery `ValueNotifier`** — Previously called `setState` every 5 seconds causing full widget rebuild. Now uses `ValueNotifier` so only the battery widget rebuilds.

### Changed

- **`SecondaryMenu`** — Replaced `for` loop with `...children` spread operator.
- **`VideoProgressBar`** — Fixed `NaN` issue when `end.inMilliseconds == 0`. Added `.clamp(0.0, 1.0)`.
- **`ProgressBar` width** — Prevented negative width values using `.clamp(0.0, double.infinity)`.
- **`Dot.opacity`** — Changed from nullable `double?` to non-nullable `double`.
- **`_TextPositionPainter`** — Replaced `ui.TextStyle + ParagraphBuilder` with `TextPainter`. Tooltip position is now based on progress dot position and properly clamped.

---

## [1.0.6] - 2026-01-13

### Fixed

- Added subtitle decrypt support (AES-128-CBC) for encrypted VTT files.
- Supported base64-wrapped CDN subtitle files.
- Improved subtitle parsing and stability when loading encrypted subtitles.

---

## [1.0.5] - 2025-12-xx

### Fixed

- Resolved `seekTo` related errors.
- Improved player UI and control icons for better user experience.

---

## [1.0.4] - 2025-12-xx

### Fixed

- Minor bug fixes and stability improvements.

---

## [1.0.3] - 2025-11-xx

### Changed

- **Breaking change**: `AdsRequest.adTagUrl` now returns `null` when an ad tag is not set.

---

## [1.0.2] - 2025-11-xx

### Fixed

- General bug fixes.
- Updated example project.

---

## [1.0.1] - 2025-11-xx

### Fixed

- Minor bug fixes.

---

## [1.0.0] - 2025-11-xx

### Added

- Initial release of **KenjiPlayer**.