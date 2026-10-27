# FinderActions v0.1.0

Initial public release.

## Features

- New File Here…
- Open Terminal Here
- Copy Path Here
- Copy Name Here
- Grouped / flat Finder menu modes
- Chinese / English interface
- Per-action switches
- Default file name
- Finder extension status and settings shortcut
- Menu bar app mode
- Launch at login
- App icon

## Installation

1. Download the DMG or ZIP.
2. Move `FinderActions.app` to `/Applications`.
3. Open FinderActions.
4. Enable the Finder extension in:

```text
System Settings
→ General
→ Login Items & Extensions
→ Finder Extensions
```

5. If the menu does not appear, restart Finder:

```bash
killall Finder
```

## Important

This release is ad-hoc signed and is not Apple-notarized. macOS may show a security warning on first launch.

## Known limitations

- File Provider directories such as iCloud Drive, OneDrive, Dropbox, and Google Drive are not supported.
- External drives and SMB shares are outside the v1 support scope.
- `swift test` requires a full Xcode installation; a runnable smoke-test executable is provided.
