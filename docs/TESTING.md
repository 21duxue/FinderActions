# FinderActions 测试说明

## 1. 构建验证

```bash
swift build
```

## 2. 可运行的核心测试

当前机器只有 Command Line Tools，缺少 Swift Testing 宏插件，因此 `swift test` 无法运行。

项目内置了一个不依赖宏的测试程序：

```bash
swift run FinderActionsSmokeTests
```

当前覆盖：

- 默认语言、菜单模式、默认文件名
- 菜单动作开关
- 文件名校验与唯一文件名
- 路径 / 名称复制
- 设置持久化
- 子菜单 / 平铺菜单展示模型
- 关闭动作后从菜单中移除
- FinderActions URL Scheme 编解码
- 文件创建与重名处理

## 3. Swift Testing

仓库中保留了标准 Swift Testing 测试：

```bash
swift test
```

安装完整 Xcode 后可运行。

测试文件：

- `ActionLinkTests`
- `AppSettingsTests`
- `FileCreatorTests`
- `FilenameGeneratorTests`
- `MenuConfigurationTests`
- `MenuPresentationTests`
- `PathSelectionTests`

## 4. App Bundle 验证

```bash
./Scripts/build-app.sh release
codesign --verify --deep --strict build/FinderActions.app
```

## 5. FinderSync 扩展验证

```bash
pluginkit -m -A -p com.apple.FinderSync
```

应看到：

```text
+ dev.finderactions.FinderActions.FinderSync
```

## 6. 手动端到端验证

已验证：

- `finderactions://copy-path` 写入正确路径
- `finderactions://copy-name` 写入正确名称
- `finderactions://open-terminal` 打开 Terminal
- `finderactions://new-file` 弹出保存面板并创建文件
- 关闭设置窗口后，点击 App 图标可重新打开
- 多次打开 URL 不会创建多个设置窗口

## 7. 登录时启动

设置窗口包含 `登录时启动 FinderActions` 开关，使用 macOS 13+ 的 `SMAppService.mainApp` 实现。

已验证：

- 打开开关后，`sfltool dumpbtm` 能看到 FinderActions 登录项
- 登录项状态为 `enabled`
- 路径为 `/Applications/FinderActions.app`
