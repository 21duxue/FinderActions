# FinderActions 安装说明

1. 解压下载的 FinderActions 压缩包。
2. 将 `FinderActions.app` 拖到 `/Applications`。
3. 打开 FinderActions。
4. 打开系统设置：
   - 通用
   - 登录项与扩展
   - Finder 扩展
5. 启用 FinderActions。
6. 如果 Finder 右键菜单没有出现，执行：

```bash
killall Finder
```

## 首次打开被 macOS 拦截

当前版本使用 ad-hoc 签名，未经过 Apple 公证。若系统阻止打开：

1. 打开系统设置中的“隐私与安全性”。
2. 找到 FinderActions 的拦截提示。
3. 点击“仍要打开”。
4. 再次确认打开。

也可以在 Finder 中右键 `FinderActions.app`，选择“打开”。
