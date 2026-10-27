# FinderActions

<p align="center">
  <img src="docs/images/icon.png" width="128" alt="FinderActions icon">
</p>

<p align="center">
  A lightweight macOS Finder context-menu utility for creating files, opening Terminal, copying paths, and copying names.
  <br>
  一个轻量的 macOS Finder 右键菜单工具。
</p>

**English** · [中文](#中文)

![FinderActions settings](docs/images/settings.png)

## English

### Features

- **New File Here…**
  - Create an empty file in the current Finder folder.
  - Uses a file-name prompt with the configured default name.
- **Open Terminal Here**
  - Open the current folder in Apple Terminal.
- **Copy Path Here**
  - Copy the selected items' full POSIX paths.
- **Copy Name Here**
  - Copy the selected items' names.
- **Grouped or flat menu**
  - Group actions under `FinderActions ▸`, or show them directly in Finder's context menu.
- **Chinese / English interface**
  - Defaults to Chinese.
- **Launch at login**
  - Optional login-item support using `SMAppService`.
- **No network access**
  - No telemetry, analytics, sync, or update checks.

### Requirements

- macOS 13 or later
- Finder Sync extension enabled in System Settings

### Download

Get the latest build from [Releases](https://github.com/21duxue/FinderActions/releases/latest).

- **Recommended:** `FinderActions-v0.1.0-macOS.dmg`
- **Alternative:** `FinderActions-v0.1.0-macOS.zip`
- **Checksums:** `SHA256SUMS.txt`

### Install

#### DMG

1. Open `FinderActions-v0.1.0-macOS.dmg`.
2. Drag `FinderActions.app` to `Applications`.
3. Open FinderActions.

#### ZIP

1. Unzip `FinderActions-v0.1.0-macOS.zip`.
2. Move `FinderActions.app` to `/Applications`.
3. Open FinderActions.

#### Enable the Finder extension

1. Open:

```text
System Settings
→ General
→ Login Items & Extensions
→ Finder Extensions
```

2. Enable **FinderActions**.
3. If the context menu does not appear, restart Finder:

```bash
killall Finder
```

### First launch

This release is ad-hoc signed and is not Apple-notarized. macOS may block the first launch.

If macOS blocks the app:

1. Open **System Settings → Privacy & Security**.
2. Find the FinderActions warning.
3. Click **Open Anyway**.
4. Confirm the launch.

You can also right-click `FinderActions.app` in Finder and choose **Open**.

### Usage

In Finder, right-click:

- an empty area in a folder
- a selected file
- a selected folder

Depending on the selected display mode, you will see either:

```text
FinderActions ▸
  New File Here…
  Open Terminal Here
  Copy Path
  Copy Name
```

or:

```text
New File Here…
Open Terminal Here
Copy Path
Copy Name
```

Actions disabled in Settings are removed from the Finder menu immediately.

### Settings

FinderActions includes:

- Chinese / English language switch
- Grouped / flat Finder menu
- Per-action enable switches
- Default file name
- Finder extension status and settings shortcut
- Launch at login
- Reset to defaults

### Build from source

```bash
swift build
swift run FinderActionsSmokeTests
./Scripts/build-app.sh release
```

The app bundle is created at:

```text
build/FinderActions.app
```

### Testing

Standard Swift Testing suites live in `Tests/FinderActionsCoreTests/`.

This machine currently has only Command Line Tools, not a full Xcode installation, so `swift test` cannot load the Swift Testing macro plugin. A runnable smoke-test executable is included:

```bash
swift run FinderActionsSmokeTests
```

See [docs/TESTING.md](docs/TESTING.md) for details.

### Project structure

```text
Sources/
  FinderActions/            AppKit shell, SwiftUI settings, action coordinator
  FinderActionsCore/        Menu, settings, path, file, and URL logic
  FinderActionsExtension/   Finder Sync extension
  FinderActionsSmokeTests/  Runnable core tests
Tests/
  FinderActionsCoreTests/   Swift Testing suites
Scripts/
  build-app.sh              Builds and signs the app bundle
  make-icon.swift           Regenerates the app icon
  package-release.sh        Creates DMG/ZIP release artifacts
prototype/
  index.html                Interactive design prototype
```

### Known limitations

- Finder Sync menus are not available inside File Provider directories such as iCloud Drive, OneDrive, Dropbox, and Google Drive.
- External drives and SMB shares are outside the v1 support scope.
- The current release is ad-hoc signed, not notarized.
- `swift test` requires a full Xcode installation.

### Privacy

FinderActions performs all work locally:

- no network requests
- no telemetry
- no accounts
- no cloud sync
- no automatic update checks

### License

MIT. See [LICENSE](LICENSE).

---

## 中文

### 功能

- **New File Here…**
  - 在当前 Finder 目录创建空文件。
  - 弹出文件名输入框，并使用设置的默认文件名。
- **Open Terminal Here**
  - 使用 Apple Terminal 打开当前目录。
- **Copy Path Here**
  - 复制选中项的完整 POSIX 路径。
- **Copy Name Here**
  - 复制选中项的名称。
- **折叠或平铺菜单**
  - 可以选择折叠到 `FinderActions ▸`，也可以直接显示在 Finder 右键菜单中。
- **中文 / English**
  - 默认中文。
- **登录时启动**
  - 使用 `SMAppService` 注册登录项。
- **无网络访问**
  - 没有遥测、统计、云同步或自动更新检查。

### 系统要求

- macOS 13 或更高版本
- 在系统设置中启用 Finder 扩展

### 下载

前往 [Releases](https://github.com/21duxue/FinderActions/releases/latest) 下载最新版本。

- **推荐：** `FinderActions-v0.1.0-macOS.dmg`
- **备选：** `FinderActions-v0.1.0-macOS.zip`
- **校验文件：** `SHA256SUMS.txt`

### 安装

#### 使用 DMG

1. 打开 `FinderActions-v0.1.0-macOS.dmg`。
2. 将 `FinderActions.app` 拖到 `Applications`。
3. 打开 FinderActions。

#### 使用 ZIP

1. 解压 `FinderActions-v0.1.0-macOS.zip`。
2. 将 `FinderActions.app` 移动到 `/Applications`。
3. 打开 FinderActions。

#### 启用 Finder 扩展

1. 打开：

```text
系统设置
→ 通用
→ 登录项与扩展
→ Finder 扩展
```

2. 启用 **FinderActions**。
3. 如果右键菜单没有出现，重启 Finder：

```bash
killall Finder
```

### 首次打开

当前版本使用 ad-hoc 签名，未经过 Apple 公证。macOS 可能会在首次启动时拦截。

如果系统拦截：

1. 打开 **系统设置 → 隐私与安全性**。
2. 找到 FinderActions 的拦截提示。
3. 点击 **仍要打开**。
4. 再次确认启动。

也可以在 Finder 中右键 `FinderActions.app`，选择 **打开**。

### 使用方式

在 Finder 中右键：

- 文件夹空白区域
- 选中的文件
- 选中的文件夹

根据设置的显示方式，你会看到：

```text
FinderActions ▸
  New File Here…
  Open Terminal Here
  Copy Path
  Copy Name
```

或者：

```text
New File Here…
Open Terminal Here
Copy Path
Copy Name
```

在设置中关闭的动作会立即从 Finder 菜单中移除。

### 设置

FinderActions 提供：

- 中文 / English 切换
- 折叠 / 平铺菜单
- 每个动作的独立开关
- 默认文件名
- Finder 扩展状态与系统设置入口
- 登录时启动
- 恢复默认设置

### 从源码构建

```bash
swift build
swift run FinderActionsSmokeTests
./Scripts/build-app.sh release
```

App Bundle 输出位置：

```text
build/FinderActions.app
```

### 测试

标准 Swift Testing 测试位于：

```text
Tests/FinderActionsCoreTests/
```

当前机器只有 Command Line Tools，没有完整 Xcode，因此 `swift test` 无法加载 Swift Testing 宏插件。仓库提供了一个可直接运行的 Smoke Test：

```bash
swift run FinderActionsSmokeTests
```

详情见 [docs/TESTING.md](docs/TESTING.md)。

### 项目结构

```text
Sources/
  FinderActions/            AppKit 外壳、SwiftUI 设置界面、动作协调器
  FinderActionsCore/        菜单、设置、路径、文件和 URL 逻辑
  FinderActionsExtension/   Finder Sync 扩展
  FinderActionsSmokeTests/  可运行的核心测试
Tests/
  FinderActionsCoreTests/   Swift Testing 测试
Scripts/
  build-app.sh              构建并签名 App Bundle
  make-icon.swift           重新生成 App 图标
  package-release.sh        生成 DMG / ZIP 发布包
prototype/
  index.html                交互设计原型
```

### 已知限制

- iCloud Drive、OneDrive、Dropbox、Google Drive 等 File Provider 目录不支持 Finder Sync 菜单。
- 外接盘和 SMB 不在 v1 支持范围内。
- 当前版本使用 ad-hoc 签名，未经过 Apple 公证。
- `swift test` 需要完整 Xcode 环境。

### 隐私

FinderActions 的所有操作都在本地完成：

- 不发起网络请求
- 不上报遥测
- 不需要账号
- 不做云同步
- 不检查自动更新

### 许可证

MIT，详见 [LICENSE](LICENSE)。
