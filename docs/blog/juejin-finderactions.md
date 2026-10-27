# 被 Finder 右键菜单折腾之后，我做了个开源小工具 FinderActions

![FinderActions icon](https://raw.githubusercontent.com/21duxue/FinderActions/main/docs/images/icon.png)

## 先说结论

我做了个 macOS 小工具，叫 **FinderActions**。

它只做四件事：

- 在当前 Finder 目录新建文件
- 在当前目录打开 Apple Terminal
- 复制文件或文件夹路径
- 复制文件或文件夹名称

项目已经开源：

- GitHub：https://github.com/21duxue/FinderActions
- Releases：https://github.com/21duxue/FinderActions/releases/tag/v0.1.0

如果你也在用 Finder 右键增强工具，或者被各种 Finder 扩展折磨过，可以看看下面的经历。

## 为什么又造一个 Finder 工具

macOS 的 Finder 很好用，但有几个动作一直让我觉得别扭。

最典型的是新建文件。

在 Windows 上，右键新建文本文件是一个很自然的动作。到了 macOS，Finder 原生没有这个入口。你要么打开终端 `touch`，要么打开编辑器再保存，要么装一个 Finder 扩展。

我一开始用的是 Easy New File。

它确实能解决问题，但在我自己的使用环境里，遇到过几个比较烦的情况：

- Finder 右键菜单偶尔不出现
- 系统升级或 Finder 重启后，扩展状态变得不稳定
- 多个 Finder 扩展同时存在时，菜单行为容易互相影响
- 有些设置改完以后，右键菜单没有立刻反映出来

这些问题不一定都是 Easy New File 本身的问题，很多时候是 macOS Finder Sync 扩展的机制导致的。Easy New File 本身也提供了不少功能。

但对我来说，我需要的不是一个“大而全”的 Finder 增强工具，而是一个更小、更可控、行为更明确的工具。

于是就有了 FinderActions。

## FinderActions 做了什么

### 1. New File Here…

在 Finder 当前目录新建一个空文件。

默认会弹出文件名输入框，并预填默认文件名。比如：

```text
Untitled.txt
```

你可以直接回车创建，也可以改成：

```text
notes.md
main.py
.env
README.md
```

重名时会自动追加编号，不会覆盖已有文件。

### 2. Open Terminal Here

在当前 Finder 目录打开 Apple Terminal。

这个功能对经常在终端和 Finder 之间切换的人比较实用。

### 3. Copy Path Here

复制选中项的完整 POSIX 路径。

支持多选，多个路径会按行输出。

### 4. Copy Name Here

复制文件名或文件夹名，不带路径。

写 issue、PR、文档或者终端命令时都挺方便。

## 菜单可以折叠，也可以平铺

FinderActions 支持两种显示方式。

### 折叠到 FinderActions

```text
FinderActions ▸
  New File Here…
  Open Terminal Here
  Copy Path
  Copy Name
```

适合不想污染 Finder 顶级菜单的人。

### 直接显示在右键菜单

```text
New File Here…
Open Terminal Here
Copy Path
Copy Name
```

适合更喜欢少点一次的人。

两种模式可以在设置里切换。

## 设置窗口

![FinderActions settings](https://raw.githubusercontent.com/21duxue/FinderActions/main/docs/images/settings.png)

设置项尽量保持克制：

- 中文 / English 切换
- 折叠 / 平铺菜单
- 每个动作独立开关
- 默认文件名
- Finder 扩展状态
- 登录时启动
- 恢复默认设置

默认语言是中文，也支持 English。

## 技术上是怎么做的

这个项目有几个关键点。

### 1. FinderSync Extension

右键菜单由 FinderSync Extension 提供。

但 FinderSync 扩展运行在沙盒里，不适合直接做所有文件操作。

### 2. 主 App 负责动作执行

扩展只负责生成菜单项，然后把动作转成自定义 URL：

```text
finderactions://new-file
finderactions://open-terminal
finderactions://copy-path
finderactions://copy-name
```

主 App 接收 URL，再执行真正的动作。

大概是这个链路：

```text
Finder 右键菜单
    ↓
FinderSync Extension
    ↓
finderactions:// URL
    ↓
主 App
    ↓
创建文件 / 打开终端 / 写剪贴板
```

这样做的好处是：

- 扩展职责更单一
- 文件操作集中在主 App
- 更容易测试和排查问题
- 避免在扩展里拼接 shell 命令

### 3. 设置共享

主 App 和扩展通过共享 Preferences 读取同一份设置。

这样切换折叠/平铺、关闭某个动作后，Finder 菜单会读取新的配置。

### 4. 登录时启动

使用 `SMAppService.mainApp` 注册登录项，可以在设置里打开：

```text
登录时启动 FinderActions
```

### 5. 核心逻辑独立

核心逻辑拆到了 `FinderActionsCore`：

- 文件名生成
- 路径选择
- URL 编解码
- 菜单展示模型
- 设置持久化
- 文件创建

这样不依赖 AppKit 也能测试。

## 适用范围

当前版本主要面向本机启动盘内的目录。

支持：

- Finder 空白区域右键
- 选中文件右键
- 选中文件夹右键
- 折叠菜单
- 平铺菜单
- 中文 / English
- 登录时启动

当前不支持：

- iCloud Drive、OneDrive、Dropbox、Google Drive 等 File Provider 目录
- 外接盘
- SMB
- 复杂模板系统
- 自动更新
- 网络访问
- 多语言
- 全局快捷键

File Provider 目录的问题不是简单 bug，Finder Sync 扩展在这些目录里的行为本来就受限。这个限制在 FinderActions 的 README 里也写清楚了。

## 安装流程

1. 从 Releases 下载 DMG 或 ZIP：

https://github.com/21duxue/FinderActions/releases/tag/v0.1.0

2. 将 `FinderActions.app` 移动到 `/Applications`

3. 打开 FinderActions

4. 到系统设置里启用 Finder 扩展：

```text
系统设置
→ 通用
→ 登录项与扩展
→ Finder 扩展
→ FinderActions
```

5. 如果右键菜单没有出现，重启 Finder：

```bash
killall Finder
```

## 当前版本的一个限制

v0.1.0 使用的是 ad-hoc 签名，没有经过 Apple 公证。

所以首次打开时，macOS 可能会拦截。处理方式是：

1. 打开“系统设置 → 隐私与安全性”
2. 找到 FinderActions 的拦截提示
3. 点击“仍要打开”
4. 再次确认

这不是功能问题，但确实会影响首次安装体验。

如果后面有合适的 Developer ID 签名和公证条件，这个问题可以解决。

## 测试情况

项目里有两类测试。

### Swift Testing

`Tests/FinderActionsCoreTests/` 下有标准 Swift Testing 测试。

### 可运行 Smoke Tests

当前机器只有 Command Line Tools，没有完整 Xcode，所以 `swift test` 会因为没有 Swift Testing 宏插件而失败。

为了让核心逻辑在当前环境下也能验证，我加了一个可以直接跑的测试程序：

```bash
swift run FinderActionsSmokeTests
```

覆盖内容包括：

- 默认语言
- 菜单模式
- 动作开关
- 文件名校验
- 重名处理
- 路径 / 名称复制
- 设置持久化
- URL Scheme
- 文件创建
- 折叠 / 平铺菜单模型

## 适合谁

FinderActions 比较适合：

- 经常在 Finder 和 Terminal 之间切换的开发者
- 需要频繁复制路径的人
- 不想安装一个功能很重的 Finder 增强工具的人
- 想自己改源码、自己控制行为的人

不适合：

- 需要复杂文件模板的人
- 需要多终端选择的人
- 需要 iCloud Drive / OneDrive / Dropbox / Google Drive 内右键菜单的人

## 最后

FinderActions 不是要替代所有 Finder 工具。

它只是把四个高频动作做好：

- New File Here…
- Open Terminal Here
- Copy Path
- Copy Name

如果你也遇到过 Finder 右键扩展不显示、设置不生效、多个扩展互相影响之类的问题，可以试试这个项目，也欢迎直接看源码或者提 issue。

- GitHub：https://github.com/21duxue/FinderActions
- 中文 README：https://github.com/21duxue/FinderActions/blob/main/README.zh-CN.md
- 最新 Release：https://github.com/21duxue/FinderActions/releases/tag/v0.1.0

如果这个工具对你有用，欢迎点个 Star。

---

标签：macOS、Swift、开源、效率工具、Finder
