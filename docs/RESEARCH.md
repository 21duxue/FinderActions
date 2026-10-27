# FinderActions 调研

## 结论速览

- **已核实**：Finder 右键菜单增强类工具的主流实现路径是 **FinderSync Extension**；创建文件、打开终端、复制路径都是真实需求，且在不同项目中反复出现。
- **已核实**：主要工程风险集中在四个方面：
  1. Finder 扩展需要用户手动启用，且在系统更新、重装、缓存刷新后可能失效；
  2. 外接盘、SMB、iCloud Drive、OneDrive、Dropbox、Google Drive 等位置存在大量兼容性问题；
  3. FinderSync 扩展的沙盒和 AppleScript / shell 调用边界容易引入权限、稳定性、甚至命令注入问题；
  4. 菜单层级、终端选择、新建文件交互、图标显示等细节会显著影响用户感知。
- **合理推测**：`FinderActions ▸` 子菜单 + `New File Here` 弹出命名输入框 + 精简终端选择，是最适合 v1 的方向。
- **工程判断**：v1 应先做 **New File Here / Open Terminal Here / Copy Path Here** 三个核心能力，并显式放弃模板系统、云同步、主题、自动更新、网络访问和全局快捷键；语言范围收敛为中文 / English，默认中文。

## 调研对象

| 项目 | 语言 | Stars | Forks | License | 主要结论 |
|---|---:|---:|---:|---|---|
| [Finder Menu](https://github.com/nikgrbn/finder-menu) | Swift | 512 | 32 | MIT | 功能覆盖最全，架构最清晰，工程细节最接近 FinderActions 目标 |
| [MacNewFile](https://github.com/GarfieldFluffJr/MacNewFile) | Objective-C | 199 | 25 | GPL-3.0 | 直接对应用户痛点，但实现较粗，安全与可维护性弱 |
| [OpenInTerminal](https://github.com/Ji4n1ng/OpenInTerminal) | Swift | 7037 | 316 | MIT | 终端与编辑器生态最成熟，架构复杂，曾出现命令注入漏洞 |
| [Easy New File](https://github.com/SkStore/Easy-New-File) | Objective-C | 46 | 4 | 未标注 | 早期项目，验证了需求，但维护停滞 |

## 1. FinderSync 是主流实现路径

### 1.1 Apple 官方接口

Apple 的 FinderSync 框架提供了两类核心能力：

- 通过 `FIFinderSyncController.directoryURLs` 声明扩展要监视的目录；
- 在 `FIFinderSyncProtocol` 的 `menuForMenuKind:` 中返回右键菜单或工具栏菜单；
- 通过 `targetedURL()` 与 `selectedItemURLs()` 获取当前 Finder 目标或选中项。

相关官方文档：

- [FIFinderSync](https://developer.apple.com/documentation/findersync/fifindersync)
- [FIFinderSyncController](https://developer.apple.com/documentation/findersync/fifindersynccontroller)
- [directoryURLs](https://developer.apple.com/documentation/findersync/fifindersynccontroller/directoryurls)
- [menuForMenuKind](https://developer.apple.com/documentation/findersync/fifindersync/menuformenukind)
- [targetedURL()](https://developer.apple.com/documentation/findersync/fifindersynccontroller/targetedurl())
- [selectedItemURLs()](https://developer.apple.com/documentation/findersync/fifindersynccontroller/selecteditemurls())

### 1.2 参考项目的实际用法

四个项目均使用 FinderSync Extension：

- Finder Menu 的实现见 [FinderSync.swift](https://github.com/nikgrbn/finder-menu/blob/3276924ec50b7e97908bf30992576352386fa75e/Sources/FinderMenuExtension/FinderSync.swift)。
- MacNewFile 的实现见 [FinderSync.m](https://github.com/GarfieldFluffJr/MacNewFile/blob/9ae35d2986355cb4d13f04a497e32b6b105d4636/MacNewFileFinderExtension/FinderSync.m)。
- OpenInTerminal 的实现见 [FinderSync.swift](https://github.com/Ji4n1ng/OpenInTerminal/blob/537ac2a5ee69ae46d4948c9b259e067a0c179a5f/OpenInTerminalFinderExtension/FinderSync.swift)。
- Easy New File 的 README 明确说明其使用 Finder extension 添加右键菜单功能，见 [README.md](https://github.com/SkStore/Easy-New-File/blob/e36917e9d8e65e87a2c66a885e2cac11ee9f1668/README.md)。

## 2. 用户真实需求

### 2.1 New File Here 是明确痛点

多个项目都把“在 Finder 中直接新建文件”作为核心功能：

- MacNewFile README 明确说用户从 Windows 迁移到 macOS 后，无法通过右键直接创建 text、Word、Excel 等文件，见 [README.md](https://github.com/GarfieldFluffJr/MacNewFile/blob/9ae35d2986355cb4d13f04a497e32b6b105d4636/README.md)。
- Finder Menu README 将 `New File…` 作为第一个功能，见 [README.md](https://github.com/nikgrbn/finder-menu/blob/3276924ec50b7e97908bf30992576352386fa75e/README.md)。
- Easy New File README 将 `Quick new file` 列为第一项功能，见 [README.md](https://github.com/SkStore/Easy-New-File/blob/e36917e9d8e65e87a2c66a885e2cac11ee9f1668/README.md)。
- OpenInTerminal 也有用户主动请求类似功能，见 issue [#176](https://github.com/Ji4n1ng/OpenInTerminal/issues/176)。

**结论**：
- 需求真实且跨项目重复出现。
- 对 `FinderActions` 而言，New File Here 应作为 v1 核心功能。

### 2.2 Open Terminal Here 是高频需求

- OpenInTerminal README 显示其支持大量终端和编辑器，见 [README.md](https://github.com/Ji4n1ng/OpenInTerminal/blob/537ac2a5ee69ae46d4948c9b259e067a0c179a5f/README.md)。
- Finder Menu 支持 Terminal、iTerm2、Ghostty、Warp、WezTerm、kitty、Alacritty 等终端，见 [README.md](https://github.com/nikgrbn/finder-menu/blob/3276924ec50b7e97908bf30992576352386fa75e/README.md)。
- MacNewFile 有用户希望自定义默认终端，见 issue [#24](https://github.com/GarfieldFluffJr/MacNewFile/issues/24)。
- Easy New File 也有用户请求支持 iTerm、kitty 等终端，见 issue [#19](https://github.com/SkStore/Easy-New-File/issues/19)。

**结论**：
- Open Terminal Here 是强需求，但“支持多少终端”是明显的范围风险。
- v1 应先支持 Apple Terminal + 少量主流终端，避免一开始就维护庞大的终端矩阵。

### 2.3 Copy Path Here 是稳定基础功能

- Finder Menu、MacNewFile、Easy New File 都提供复制路径能力。
- OpenInTerminal 也支持复制路径，见 [FinderSync.swift](https://github.com/Ji4n1ng/OpenInTerminal/blob/537ac2a5ee69ae46d4948c9b259e067a0c179a5f/OpenInTerminalFinderExtension/FinderSync.swift)。
- OpenInTerminal 还支持路径转义选项，说明用户不仅需要“复制”，还需要可用的 shell 形式。

**结论**：
- Copy Path Here 应保留在 v1。
- v1 建议只复制 POSIX 路径，后续再考虑带引号、URL、Windows 风格等选项。

## 3. 项目级发现

## 3.1 Finder Menu

**功能**：New File、Open Terminal Here、Open Folder With、Copy Path、Copy Name、Go to Parent Folder。

**架构**：
- FinderSync Extension 负责菜单展示；
- 宿主 App 处理创建文件、打开终端等操作；
- 核心逻辑与 UI 有一定分层；
- 项目支持 Homebrew 安装和源码构建。

**关键源码**：[FinderSync.swift](https://github.com/nikgrbn/finder-menu/blob/3276924ec50b7e97908bf30992576352386fa75e/Sources/FinderMenuExtension/FinderSync.swift)

**优点**：
- 功能覆盖完整，覆盖了 FinderActions 的三个目标功能；
- 对外接盘、SMB、iCloud Drive、OneDrive 等边界场景处理得最完整；
- 明确声明无网络访问、无遥测；
- 提供设置窗口和本地化，用户体验较完整。

**缺点**：
- 功能较多，包含模板、父级跳转、多语言、图标开关等；
- 菜单层级与图标显示等细节复杂；
- 部分功能如 `Go to Parent Folder` 超出了 FinderActions v1 范围。

**对 FinderActions 的启示**：
- 应重点借鉴其“外接卷动态注册”的思路；
- 但 v1 不应同时实现模板、父级跳转等功能；语言只保留中文和 English。

## 3.2 MacNewFile

**功能**：New File、Open Terminal、Copy Path。

**架构**：主要逻辑集中在 `FinderSync.m`，通过 AppleScript 和 shell 命令创建文件、打开终端、复制路径。

**关键源码**：[FinderSync.m](https://github.com/GarfieldFluffJr/MacNewFile/blob/9ae35d2986355cb4d13f04a497e32b6b105d4636/MacNewFileFinderExtension/FinderSync.m)

**优点**：
- 功能与 FinderActions 高度重合；
- 证明了这三个功能确实能覆盖目标用户痛点；
- 项目较年轻，结构简单，便于对比。

**缺点**：
- 大量逻辑集中在单个扩展文件中，UI 与业务逻辑耦合；
- 使用 AppleScript 拼接 shell 命令，安全与可维护性较差；
- 对外接盘、OneDrive、iCloud Drive 等兼容性问题处理不足；
- 设置能力弱，默认终端无法直接配置。

**对 FinderActions 的启示**：
- 应避免在 FinderSync Extension 中直接拼接 shell 命令；
- 应把核心逻辑拆到独立模块；
- 应从第一天就考虑外接盘和云盘目录的边界情况。

## 3.3 OpenInTerminal

**功能**：打开终端、打开编辑器、复制路径、快捷键、自定义应用、Finder 菜单、工具栏菜单。

**架构**：
- FinderSync Extension 负责菜单展示；
- 宿主 App 负责设置和快捷键；
- 使用 AppleScript 与应用脚本桥接沙盒内外操作。

**关键源码**：
- [FinderSync.swift](https://github.com/Ji4n1ng/OpenInTerminal/blob/537ac2a5ee69ae46d4948c9b259e067a0c179a5f/OpenInTerminalFinderExtension/FinderSync.swift)
- [App.swift](https://github.com/Ji4n1ng/OpenInTerminal/blob/537ac2a5ee69ae46d4948c9b259e067a0c179a5f/OpenInTerminalCore/App.swift)

**优点**：
- 终端和编辑器生态最完整；
- 支持自定义菜单、快捷键、多语言、自定义应用；
- 工程量大，可作为复杂度上限的参照。

**缺点**：
- 功能范围远超 FinderActions v1；
- 架构复杂，包含 FinderSync、宿主 App、应用脚本、快捷键、状态栏等多个组件；
- 曾出现命令注入漏洞，说明路径处理必须使用参数数组，不能拼字符串。

**对 FinderActions 的启示**：
- v1 不应做全局快捷键、主题、复杂自定义应用；语言范围限定为中文 / English。
- 终端启动逻辑必须使用参数数组或系统 API，禁止拼接 shell 字符串；
- 菜单可以支持“子菜单”和“平铺”两种形式，但 v1 只需一种。

## 3.4 Easy New File

**功能**：Quick new file、Copy file path、支持常见扩展名。

**架构**：项目结构较老，源码不在仓库中，仅保留 README 和发布产物。

**关键源码**：[README.md](https://github.com/SkStore/Easy-New-File/blob/e36917e9d8e65e87a2c66a885e2cac11ee9f1668/README.md)

**优点**：
- 直接验证了用户需求；
- README 明确说明启用系统扩展后才能使用；
- 提供了早期用户反馈，包括外接盘、OneDrive、模板、终端等问题。

**缺点**：
- 源码缺失，无法深入验证实现细节；
- 维护停滞，许多 issue 长期未解决；
- 对现代 macOS 和云盘兼容性不足。

**对 FinderActions 的启示**：
- 需求判断更依赖其他三个项目；
- 但它证明了这些问题不是 Finder Menu 独有，而是 FinderSync 生态的普遍问题。

## 4. 主要痛点

## 4.1 权限启用与系统重启

多个项目都要求用户到系统设置中启用 Finder 扩展，且在重装、系统更新或 Finder 重启后可能出现菜单消失的问题。

**证据**：
- MacNewFile issue [#14](https://github.com/GarfieldFluffJr/MacNewFile/issues/14)
- Easy New File issue [#22](https://github.com/SkStore/Easy-New-File/issues/22)
- OpenInTerminal issue [#192](https://github.com/Ji4n1ng/OpenInTerminal/issues/192)

**结论**：
- 设置窗口必须能显示扩展是否启用；
- 应提供“打开系统扩展设置”的按钮；
- 不应假设用户能自己找到系统设置入口。

## 4.2 外接盘、SMB、网络盘

FinderSync 需要明确声明要监视的卷。只注册启动盘 `/` 时，外接盘、SMB、USB、FUSE 等位置不会显示菜单。

**证据**：
- Finder Menu issue [#2](https://github.com/nikgrbn/finder-menu/issues/2)
- Finder Menu issue [#13](https://github.com/nikgrbn/finder-menu/issues/13)
- MacNewFile issue [#17](https://github.com/GarfieldFluffJr/MacNewFile/issues/17)

**结论**：
- 应动态注册所有已挂载卷；
- 应监听挂载和卸载事件；
- 应接受副作用：外接盘在 Finder 侧边栏可能显示为应用图标。

## 4.3 iCloud Drive、OneDrive、Dropbox、Google Drive

多个项目在 File Provider 目录中遇到菜单不显示的问题，包括 iCloud Drive、OneDrive、Dropbox、Google Drive。

**证据**：
- Finder Menu issue [#29](https://github.com/nikgrbn/finder-menu/issues/29)
- MacNewFile issue [#20](https://github.com/GarfieldFluffJr/MacNewFile/issues/20)
- MacNewFile issue [#26](https://github.com/GarfieldFluffJr/MacNewFile/issues/26)
- Easy New File issue [#23](https://github.com/SkStore/Easy-New-File/issues/23)

**结论**：
- 这是 FinderSync / File Provider 边界问题，不是简单的路径拼接问题；
- v1 应明确降级为“不支持 File Provider 目录中的右键菜单”，或者只支持本地文件系统；
- 设置界面和 README 应显式说明这一限制，避免用户误以为是 Bug。

## 4.4 安全与沙盒

FinderSync Extension 运行在沙盒中。要创建文件或打开终端，常见做法包括：

1. 在扩展中直接操作；
2. 通过宿主 App 或 AppleScript 桥接；
3. 通过应用脚本目录执行系统命令。

**证据**：
- MacNewFile 直接拼接 AppleScript 和 shell 命令，见 [FinderSync.m](https://github.com/GarfieldFluffJr/MacNewFile/blob/9ae35d2986355cb4d13f04a497e32b6b105d4636/MacNewFileFinderExtension/FinderSync.m)。
- OpenInTerminal 曾在路径处理中出现命令注入漏洞，后来改为参数数组执行，见 [App.swift](https://github.com/Ji4n1ng/OpenInTerminal/blob/537ac2a5ee69ae46d4948c9b259e067a0c179a5f/OpenInTerminalCore/App.swift)。

**结论**：
- FinderActions 必须从第一版起就使用参数数组、系统 API 或受控桥接；
- 禁止拼接 shell 命令或 AppleScript 字符串；
- 应在核心模块中集中处理路径校验、重名处理和错误反馈。

## 4.5 菜单层级

不同项目对菜单层级的取舍不同：

- OpenInTerminal 支持将多个菜单项折叠到一个子菜单中，也支持平铺，见 [FinderSync.swift](https://github.com/Ji4n1ng/OpenInTerminal/blob/537ac2a5ee69ae46d4948c9b259e067a0c179a5f/OpenInTerminalFinderExtension/FinderSync.swift)。
- MacNewFile 将 `New File` 做成子菜单，而 Copy Path 和 Open Terminal 直接平铺，见 [FinderSync.m](https://github.com/GarfieldFluffJr/MacNewFile/blob/9ae35d2986355cb4d13f04a497e32b6b105d4636/MacNewFileFinderExtension/FinderSync.m)。
- Finder Menu 菜单项较丰富，存在明显的菜单膨胀风险。

**结论**：
- v1 应默认使用 `FinderActions ▸` 子菜单，避免污染 Finder 顶级菜单；
- 是否提供平铺开关，可以留到 v1.1，不作为初始必需功能。

## 4.6 新建文件的交互

主要分歧是“直接创建默认文件”还是“弹出输入框”。

**证据**：
- Finder Menu 的 `New File…` 会弹出输入框，支持任意扩展名和隐藏文件名，见 [README.md](https://github.com/nikgrbn/finder-menu/blob/3276924ec50b7e97908bf30992576352386fa75e/README.md)。
- MacNewFile 直接创建 `Untitled.txt` 等默认文件名，见 [FinderSync.m](https://github.com/GarfieldFluffJr/MacNewFile/blob/9ae35d2986355cb4d13f04a497e32b6b105d4636/MacNewFileFinderExtension/FinderSync.m)。
- OpenInTerminal 用户请求“创建文件并提示用户命名”，见 issue [#176](https://github.com/Ji4n1ng/OpenInTerminal/issues/176)。

**结论**：
- 直接创建默认文件虽然快，但用户经常需要再改一次文件名；
- 弹出输入框更符合实际使用流程；
- v1 推荐默认弹出输入框，并预填 `Untitled.txt`，回车即创建。

## 4.7 终端选择

**证据**：
- Finder Menu 支持 Terminal、iTerm2、Ghostty、Warp、WezTerm、kitty、Alacritty。
- OpenInTerminal 支持 Terminal、iTerm、Hyper、Alacritty、kitty、WezTerm、Tabby、Warp、Ghostty、cmux 等。
- MacNewFile 有用户希望默认终端可配置，见 issue [#24](https://github.com/GarfieldFluffJr/MacNewFile/issues/24)。

**结论**：
- 终端选择是真实需求；
- 但 v1 应控制范围，只做可靠的一小部分；
- 建议支持 `Terminal`、`iTerm2`、`Ghostty`、`Warp`，后续再扩展。

## 4.8 图标显示

**证据**：
- Finder Menu issue [#19](https://github.com/nikgrbn/finder-menu/issues/19) 显示部分用户认为图标在 Finder 菜单中显得突兀。

**结论**：
- v1 可以先不显示图标；
- 若后续增加，应提供开关。

## 5. 对 FinderActions v1 的建议

### 5.1 功能范围

**应该做**：
1. `New File Here`
2. `Open Terminal Here`
3. `Copy Path Here`

**不应该做**：
- 云同步
- 复杂模板系统
- 自动更新
- 网络访问
- 主题系统
- 全局快捷键
- 打开编辑器
- 打开任意应用
- 父级跳转
- 复制文件名
- 自定义菜单排序

### 5.2 架构建议

建议采用三层结构：

1. **FinderActionsCore**
   - 纯逻辑模块
   - 不依赖 AppKit UI
   - 负责文件名校验、唯一文件名生成、终端选择、路径处理、错误模型
2. **FinderActionsExtension**
   - 只负责菜单展示和事件转发
   - 尽量不做业务逻辑
3. **FinderActionsApp**
   - 设置窗口
   - 扩展启用状态检查
   - 必要时的弹窗和宿主桥接

### 5.3 菜单结构建议

默认采用：

```text
FinderActions ▸
  New File Here…
  Open Terminal Here
  Copy Path Here
```

理由：
- 避免污染 Finder 顶级菜单；
- 便于后续增加功能而不破坏用户习惯；
- 更容易在设置中做统一开关。

### 5.4 New File Here 交互建议

默认流程：

1. 用户点击 `New File Here…`
2. 弹出原生输入框
3. 预填 `Untitled.txt`
4. 用户可直接回车创建
5. 重名时自动追加 ` 2`
6. 非法文件名时提示错误
7. 创建成功后在 Finder 中选中新文件

### 5.5 终端建议

v1 建议：
- 默认 `Terminal`
- 可选 `iTerm2`
- 可选 `Ghostty`
- 可选 `Warp`

后续再考虑：
- WezTerm
- kitty
- Alacritty
- Hyper
- 自定义应用

### 5.6 设置窗口建议

v1 设置窗口应只包含：
1. 三个功能的启用开关
2. 默认终端选择
3. 新建文件的默认文件名
4. 扩展启用状态提示
5. 打开系统扩展设置的按钮

不应包含：
- 主题
- 自动更新
- 账户
- 快捷键
- 模板管理
- 菜单排序
- 复杂搜索

## 6. 尚未确定的问题

1. **FinderActions 是否必须同时支持外接盘和 SMB？**
   - 建议支持，但需要接受侧边栏图标替换的副作用。
2. **FinderActions 是否要明确声明不支持 iCloud Drive、OneDrive、Dropbox、Google Drive 中的 File Provider 目录？**
   - 建议在 v1 中明确声明不支持。
3. **New File Here 是否应默认预填 `Untitled.txt`，还是保留上次使用的扩展名？**
   - 建议先预填 `Untitled.txt`，后续再考虑记忆上次输入。
4. **终端选择是否需要自动检测已安装应用？**
   - 建议仅显示可检测到的已安装终端，避免用户选择不存在的应用。
5. **是否在 v1 中支持平铺菜单开关？**
   - 建议先只支持子菜单，后续根据反馈增加开关。

## 7. 结论

综合四个项目，可以确认：

1. FinderSync Extension 是当前最合适的实现路径。
2. New File Here、Open Terminal Here、Copy Path Here 是真实且稳定的核心需求。
3. 主要风险来自系统权限、File Provider 目录、外接卷、沙盒和命令拼接。
4. v1 应严格控制功能范围，优先保证可靠性和可测试性。
5. 架构上应将核心逻辑拆到独立模块，避免将业务逻辑塞进 FinderSync Extension。

## 8. 语言范围补充

原调研结论曾把“多语言”整体排除在 v1 外。这个结论需要按最新产品要求修正：

- v1 必须支持中文和 English
- 默认语言为中文
- 不支持更多语言
- 参考项目中的多语言能力不等于 FinderActions 需要完整国际化框架
- v1 只需要维护两套文案，避免引入复杂翻译管理系统

结论：

- **已核实事实**：参考项目普遍支持多语言，但维护成本随语言数量增加。
- **工程判断**：中文 / English 双语符合当前目标用户，同时能把维护成本控制在较低水平。

## 9. 最新范围修正

根据最新产品决策，前文建议需按以下方式修正：

1. 菜单结构同时支持子菜单和平铺，默认子菜单。
2. 终端只使用 Apple Terminal，不提供 iTerm2、Ghostty、Warp 等选择。
3. 外接盘和 SMB 不属于 v1 支持范围。
4. v1 仅覆盖本机启动盘内的目录。
5. File Provider 目录仍不属于 v1 支持范围。

这属于工程判断：
- 菜单双模式覆盖两类用户偏好。
- 固定 Apple Terminal 可显著降低终端兼容矩阵和失败路径。
- 外接盘与 SMB 涉及卷挂载、权限和网络文件系统差异，暂不纳入 v1。

## 10. 功能范围最终修正

在前述建议基础上，最终 v1 功能范围修正为：

1. New File Here
2. Open Terminal Here
3. Copy Path Here
4. Copy Name Here

不再纳入：

- New Folder Here
  - macOS Finder 原生已提供新建文件夹能力
- Copy Shell Path Here
  - 需要额外定义引号与转义策略，暂不纳入
- 打开编辑器
- Git 相关动作
- 模板系统
- 更多终端选择

这是工程判断：
- 保留四个动作可以覆盖高频场景，同时避免功能膨胀。
- `Copy Name Here` 实现简单，与 `Copy Path Here` 心智一致。
- `New Folder Here` 与系统能力重复。
- `Copy Shell Path Here` 的正确性依赖 shell 引号规则，边界较多。
