-- hs コマンド (CLI) からの操作を有効化
require("hs.ipc")

hs.dockIcon(false)
hs.autoLaunch(true)

require("window")
require("ime")

-- 設定ファイル変更時に自動リロード
-- (configdir は dotfiles への symlink のため、実体パスに解決してから監視する)
-- (グローバルに保持しないと GC に回収されて監視が止まる)
ConfigWatcher = hs.pathwatcher.new(hs.fs.pathToAbsolute(hs.configdir), hs.reload):start()
hs.alert.show("Hammerspoon: config loaded")
