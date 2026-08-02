-- Ghostty: 操作系ショートカットで IME を ABC に強制する (sticky)
--
-- 設計: あらゆる操作は ABC 起点という不変条件を機械側が強制し、
-- 手動の切り替えは「日本語を書きたい瞬間の右 Cmd」だけにする。
-- ここでは Ghostty 内の herdr 操作キーを検知して ABC へ切り替える。

local ABC = "com.apple.keylayout.ABC"
local GHOSTTY_BUNDLE = "com.mitchellh.ghostty"

-- 対象キー (Ghostty の herdr マクロ + prefix 入口)
--   Cmd+T: 新規ウィンドウ / Cmd+1-9: ウィンドウ選択 / Cmd+B: コピーモード
--   Cmd+D: 右分割 / Cmd+Shift+D: 下分割 / Cmd+Shift+[ ]: 前後のウィンドウ
--   Ctrl+B: herdr prefix / Ctrl+Q: ワークスペースセレクタ
--   Ctrl+H/J/K/L: pane・window 移動 (snacks explorer は単キー操作のため ABC 必須)
local cmdKeys = { t = true, d = true, b = true }
for i = 1, 9 do
  cmdKeys[tostring(i)] = true
end
local cmdShiftKeys = { d = true, ["["] = true, ["]"] = true }
local ctrlKeys = { b = true, q = true, h = true, j = true, k = true, l = true }

local function setABC()
  hs.keycodes.currentSourceID(ABC)
end

-- 大半のキー入力を最小コストで素通しするため flags を先に判定する
local function isTargetKey(event)
  local f = event:getFlags()
  local keys
  if f.cmd and not (f.ctrl or f.alt or f.fn) then
    keys = f.shift and cmdShiftKeys or cmdKeys
  elseif f.ctrl and not (f.cmd or f.alt or f.shift or f.fn) then
    keys = ctrlKeys
  else
    return false
  end
  return keys[hs.keycodes.map[event:getKeyCode()]] == true
end

local tap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
  if isTargetKey(event) then
    -- watcher の deactivated 取りこぼしで tap が残るケースに備え、
    -- マッチ時のみ前面アプリを再確認する (毎キー入力のコストにはならない)
    local front = hs.application.frontmostApplication()
    if front and front:bundleID() == GHOSTTY_BUNDLE then
      setABC()
    end
  end
  return false -- イベントは消費せず Ghostty へそのまま渡す
end)

-- 全キー入力に Lua を挟まないよう、Ghostty が前面のときだけ tap を有効化
local watcher = hs.application.watcher.new(function(_, event, app)
  if not app or app:bundleID() ~= GHOSTTY_BUNDLE then
    return
  end
  if event == hs.application.watcher.activated then
    tap:start()
  elseif event == hs.application.watcher.deactivated then
    tap:stop()
  end
end)
watcher:start()

local frontmost = hs.application.frontmostApplication()
if frontmost and frontmost:bundleID() == GHOSTTY_BUNDLE then
  tap:start()
end

-- GC に回収されないよう参照を返す (package.loaded が保持する)
return { tap = tap, watcher = watcher }
