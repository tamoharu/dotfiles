-- Rectangle 互換のウィンドウスナップ
-- Cmd+Option+←/→: 左右スナップ。連打で 1/2 → 2/3 → 1/3 をサイクル
-- (Rectangle の subsequentExecutionMode = resize 相当の挙動を再現)

-- AX API 経由のアニメーションはカクつくため無効化し即時スナップにする
hs.window.animationDuration = 0

-- サイクル順は Rectangle の CycleSize.sortedSizes に準拠 (1/2 開始、大→小で巡回)
local cycleSizes = { 1 / 2, 2 / 3, 1 / 3 }

-- ウィンドウごとの直前アクション記録 (Rectangle の WindowHistory 相当)
local lastActions = {}

-- AX の座標ゆらぎを許容するため 1px までは同一とみなす
local function rectsEqual(a, b)
  return math.abs(a.x - b.x) <= 1
    and math.abs(a.y - b.y) <= 1
    and math.abs(a.w - b.w) <= 1
    and math.abs(a.h - b.h) <= 1
end

local function sideRect(screenFrame, side, fraction)
  local w = math.floor(screenFrame.w * fraction + 0.5)
  local x = (side == "left") and screenFrame.x or (screenFrame.x + screenFrame.w - w)
  return hs.geometry.rect(x, screenFrame.y, w, screenFrame.h)
end

local function snap(side)
  local win = hs.window.focusedWindow()
  if not win then return end

  local id = win:id()
  local current = win:frame()
  local screenFrame = win:screen():frame()

  -- ウィンドウが外部で動かされていたらサイクルをリセット
  -- (Rectangle: windowMovedExternally 判定)
  local last = lastActions[id]
  if last and not rectsEqual(current, last.rect) then
    last = nil
    lastActions[id] = nil
  end

  local isRepeat = last and last.action == side
  local target
  if not isRepeat then
    target = sideRect(screenFrame, side, cycleSizes[1])
  else
    -- n 回目の連打は count % 3 番目のサイズ。
    -- 現在の frame と同一になる場合は変化が出るまで次の候補へ進める
    -- (Rectangle: calculateRepeatedSideRect)
    local index = last.count % #cycleSizes
    for _ = 1, #cycleSizes do
      target = sideRect(screenFrame, side, cycleSizes[index + 1])
      if not rectsEqual(current, target) then break end
      index = (index + 1) % #cycleSizes
    end
  end

  win:setFrame(target)

  lastActions[id] = {
    action = side,
    -- セル単位で丸めるアプリ (ターミナル等) があるため適用後の実測値を記録
    rect = win:frame(),
    count = isRepeat and (last.count + 1) or 1,
  }
end

-- Cmd+Option+↑/↓: 上下のディスプレイへ移動 (Rectangle の Next/Prev Display 相当)
-- 移動先の中央にサイズ維持で配置し、収まらない辺だけ縮小、
-- 縦横とも収まらなければ最大化 (Rectangle の CenterCalculation 準拠)

local function centerRect(winFrame, screenFrame)
  local heightExceeded = winFrame.h > screenFrame.h
  local widthExceeded = winFrame.w > screenFrame.w

  if heightExceeded and widthExceeded then
    return hs.geometry.rect(screenFrame.x, screenFrame.y, screenFrame.w, screenFrame.h)
  end

  local rect = hs.geometry.rect(winFrame.x, winFrame.y, winFrame.w, winFrame.h)
  if heightExceeded then
    rect.h = screenFrame.h
    rect.y = screenFrame.y
  else
    rect.y = math.floor((screenFrame.h - winFrame.h) / 2 + 0.5) + screenFrame.y
  end
  if widthExceeded then
    rect.w = screenFrame.w
    rect.x = screenFrame.x
  else
    rect.x = math.floor((screenFrame.w - winFrame.w) / 2 + 0.5) + screenFrame.x
  end
  return rect
end

local function moveToScreen(direction)
  local win = hs.window.focusedWindow()
  if not win then return end

  local screen = win:screen()
  -- and-or イディオムは toNorth() が nil のとき toSouth() へフォールスルーするため使わない
  local target
  if direction == "up" then
    target = screen:toNorth()
  else
    target = screen:toSouth()
  end
  -- その方向にディスプレイが無ければ何もしない (単一ディスプレイ時も no-op)
  if not target then return end

  local rect = centerRect(win:frame(), target:frame())
  win:setFrame(rect)
  -- 解像度の異なるディスプレイ間ではサイズが一度で適用されないことがあるため
  -- 再適用する (Rectangle も同様のリトライを行う)
  if not rectsEqual(win:frame(), rect) then
    win:setFrame(rect)
  end

  -- ディスプレイ移動で左右スナップのサイクルはリセット (Rectangle と同様)
  lastActions[win:id()] = nil
end

hs.hotkey.bind({ "cmd", "alt" }, "left", function() snap("left") end)
hs.hotkey.bind({ "cmd", "alt" }, "right", function() snap("right") end)
hs.hotkey.bind({ "cmd", "alt" }, "up", function() moveToScreen("up") end)
hs.hotkey.bind({ "cmd", "alt" }, "down", function() moveToScreen("down") end)
