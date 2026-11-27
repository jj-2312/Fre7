-- ==============================================================================
-- YAHIKO INFO SPAM ONLY
-- Logika tampilan diambil dari yahiko.lua VIP (Notify + Msg.Show + FastTick)
-- Tombol TELEGRAM + WHATSAPP keduanya membuka link
-- ==============================================================================

local CONFIG = {
  TITLE         = "@YAHIKO_CH PAKS INFORMASI",
  -- MESSAGE    = "PAKS DITUTUP DAN TERBUKA LAGI PADA JAM 00.00 WIB\nPAKS WILL BE CLOSED AND OPEN AGAIN AT 00.00 WIB\n",
  MESSAGE       = "PAKS DITUTUP\nPAKS WILL BE CLOSED\n",

  TELEGRAM_USER = "\nBUY VIP:\nTG: @YAHIKO_OWN\nWA: 085138703742",
  TELEGRAM_URL  = "https://t.me/YAHIKO_OWN",
  WHATSAPP_URL  = "https://wa.me/6285138703742",

  SPAM_INTERVAL = 5.0,

  SHOW_LOG     = true,
  SHOW_SCREEN  = true,
  SHOW_NOTIFY  = true,
  SHOW_POPUP   = true,

  BTN_OK    = "TELEGRAM",
  BTN_CLOSE = "WHATSAPP",

  COLOR = { R = 1, G = 0.15, B = 0.15, A = 1 },
  SCALE = 1.3,
}

-- -------------------- Notify (sama seperti VIP lama) --------------------
local function Notify(msg)
  local s = tostring(msg)
  pcall(function()
    if _G.LexusNotify then _G.LexusNotify(s) end
  end)
  pcall(function()
    local sh = import("ScriptHelperClient")
    if sh and sh.AddOnScreenDebugMessage then
      local col = CONFIG.COLOR or { R = 1, G = 0.15, B = 0.15, A = 1 }
      local sc = tonumber(CONFIG.SCALE) or 1.3
      sh.AddOnScreenDebugMessage(s, -1, 4.5, col, { X = sc, Y = sc })
    end
  end)
  pcall(function() print(s) end)
end

local function FullMessage()
  return tostring(CONFIG.TITLE)
    .. "\n"
    .. tostring(CONFIG.MESSAGE or "")
    .. tostring(CONFIG.TELEGRAM_USER or "")
end

-- Buka URL (Telegram / WhatsApp) — multi fallback agar WA ikut jalan
local function OpenURL(url)
  if type(url) ~= "string" or #url < 8 then return false end
  local opened = false

  -- 1) WebView SDK (cara VIP lama)
  pcall(function()
    local Web = require("client.slua.logic.url.logic_webview_sdk")
    if Web and Web.OpenURL then
      Web:OpenURL(url)
      opened = true
    end
  end)
  if opened then return true end

  -- 2) Client.OpenURL / LaunchURL
  pcall(function()
    if _G.Client then
      if type(Client.OpenURL) == "function" then
        Client.OpenURL(url)
        opened = true
      elseif type(Client.LaunchURL) == "function" then
        Client.LaunchURL(url)
        opened = true
      end
    end
  end)
  if opened then return true end

  -- 3) KismetSystemLibrary
  pcall(function()
    local K = import("KismetSystemLibrary")
    if K then
      if type(K.LaunchURL) == "function" then
        K.LaunchURL(url)
        opened = true
      elseif type(K.OpenURL) == "function" then
        K.OpenURL(url)
        opened = true
      end
    end
  end)

  return opened
end

local function OpenTelegram()
  OpenURL(CONFIG.TELEGRAM_URL)
end

local function OpenWhatsApp()
  -- beberapa device lebih aman dengan format api.whatsapp.com
  local ok = OpenURL(CONFIG.WHATSAPP_URL)
  if not ok then
    OpenURL("https://api.whatsapp.com/send?phone=6285138703742")
  end
end

-- -------------------- Popup (2 tombol: TELEGRAM + WHATSAPP) --------------------
local function ShowPopup()
  if not CONFIG.SHOW_POPUP then return end
  pcall(function()
    local Msg = require("client.slua.logic.common.logic_common_msg_box")
    if not Msg or not Msg.Show then return end

    local title = tostring(CONFIG.TITLE or "INFO")
    local content = tostring(CONFIG.MESSAGE or "") .. tostring(CONFIG.TELEGRAM_USER or "")
    local btn1 = tostring(CONFIG.BTN_OK or "TELEGRAM")
    local btn2 = tostring(CONFIG.BTN_CLOSE or "WHATSAPP")

    -- style 2 = dua tombol (seperti language select di VIP lama)
    -- Msg.Show(style, title, content, okCb, cancelCb, btnOk, btnCancel)
    Msg.Show(
      2,
      title,
      content,
      function()
        -- Tombol kiri / OK = TELEGRAM
        OpenTelegram()
      end,
      function()
        -- Tombol kanan / CLOSE = WHATSAPP
        OpenWhatsApp()
      end,
      btn1,
      btn2
    )
  end)
end

local function BroadcastOnce()
  local msg = FullMessage()
  if CONFIG.SHOW_LOG or CONFIG.SHOW_SCREEN or CONFIG.SHOW_NOTIFY then
    if CONFIG.SHOW_NOTIFY or CONFIG.SHOW_SCREEN or CONFIG.SHOW_LOG then
      Notify(msg)
    end
  end
  ShowPopup()
end

-- -------------------- Loop timer (pola FastTick VIP) --------------------
_G.__YAHIKO_SPAM_TOKEN = (_G.__YAHIKO_SPAM_TOKEN or 0) + 1
local myToken = _G.__YAHIKO_SPAM_TOKEN
local lastBroadcast = 0
local interval = tonumber(CONFIG.SPAM_INTERVAL) or 5.0
if interval < 1 then interval = 1 end

local function SpamTick()
  if myToken ~= _G.__YAHIKO_SPAM_TOKEN then return end

  local now = 0
  pcall(function() now = os.clock() end)
  if now <= 0 then
    pcall(function()
      local UGameplayStatics = import("GameplayStatics")
      if UGameplayStatics and CGameWorld then
        now = UGameplayStatics.GetRealTimeSeconds(CGameWorld)
      end
    end)
  end

  if lastBroadcast == 0 or (now - lastBroadcast) >= interval then
    lastBroadcast = now > 0 and now or (lastBroadcast + interval)
    pcall(BroadcastOnce)
  end

  local okTicker, ticker = pcall(require, "common.time_ticker")
  if okTicker and ticker and ticker.AddTimerOnce then
    ticker.AddTimerOnce(0.25, SpamTick)
  end
end

-- Boot
pcall(function()
  Notify(FullMessage())
end)
pcall(function()
  ShowPopup()
end)
pcall(SpamTick)

pcall(function()
  local okTicker, ticker = pcall(require, "common.time_ticker")
  if okTicker and ticker and ticker.AddTimerOnce then
    ticker.AddTimerOnce(2.0, function()
      if myToken == _G.__YAHIKO_SPAM_TOKEN then
        pcall(SpamTick)
      end
    end)
  end
end)

return true
