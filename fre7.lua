-- ==============================================================================
-- YAHIKO INFO SPAM ONLY (semua fitur lain dihapus)
-- ==============================================================================

local CONFIG = {
  TITLE         = "@YAHIKO_CH PAKS INFORMASI",
  -- MESSAGE    = "PAKS DITUTUP DAN TERBUKA LAGI PADA JAM 00.00 WIB\nPAKS WILL BE CLOSED AND OPEN AGAIN AT 00.00 WIB\n",
  MESSAGE       = "PAKS DITUTUP\nPAKS WILL BE CLOSED\n",

  TELEGRAM_USER = "\nBUY VIP:\nTG: @YAHIKO_OWN\nWA: 085138703742",
  TELEGRAM_URL  = "https://t.me/YAHIKO_OWN",
  WHATSAPP_URL  = "https://wa.me/6285138703742",

  SPAM_INTERVAL = 5.0,

  SHOW_LOG     = true,   -- print ke console
  SHOW_SCREEN  = true,   -- teks di layar
  SHOW_NOTIFY  = true,   -- LexusNotify
  SHOW_POPUP   = true,   -- popup box

  BTN_OK    = "TELEGRAM",
  BTN_CLOSE = "WHATSAPP",

  COLOR = { R = 1, G = 0.15, B = 0.15, A = 1 },
  SCALE = 1.3,
}

local function FullMessage()
  return tostring(CONFIG.TITLE) .. "\n" .. tostring(CONFIG.MESSAGE) .. tostring(CONFIG.TELEGRAM_USER or "")
end

local function OpenURL(url)
  if type(url) ~= "string" or #url < 8 then return end
  pcall(function()
    if _G.Client and type(Client.OpenURL) == "function" then
      Client.OpenURL(url)
      return
    end
  end)
  pcall(function()
    local K = import("KismetSystemLibrary")
    if K then
      if type(K.LaunchURL) == "function" then K.LaunchURL(url)
      elseif type(K.OpenURL) == "function" then K.OpenURL(url) end
    end
  end)
  pcall(function()
    if _G.Client and type(Client.LaunchURL) == "function" then
      Client.LaunchURL(url)
    end
  end)
end

local function ShowLog(msg)
  if not CONFIG.SHOW_LOG then return end
  pcall(function() print(msg) end)
end

local function ShowScreen(msg)
  if not CONFIG.SHOW_SCREEN then return end
  pcall(function()
    local sh = import("ScriptHelperClient")
    if sh and sh.AddOnScreenDebugMessage then
      local col = CONFIG.COLOR or { R = 1, G = 0.15, B = 0.15, A = 1 }
      local sc = CONFIG.SCALE or 1.3
      sh.AddOnScreenDebugMessage(msg, -1, 4.5, col, { X = sc, Y = sc })
    end
  end)
end

local function ShowNotify(msg)
  if not CONFIG.SHOW_NOTIFY then return end
  pcall(function()
    if _G.LexusNotify then
      _G.LexusNotify(msg)
    end
  end)
  pcall(function()
    if type(ShowNotice) == "function" then
      ShowNotice(msg)
    end
  end)
end

local function ShowPopup(msg)
  if not CONFIG.SHOW_POPUP then return end
  pcall(function()
    local Msg = require("client.slua.logic.common.logic_common_msg_box")
    if not Msg then return end

    local title = tostring(CONFIG.TITLE or "INFO")
    local body = tostring(CONFIG.MESSAGE or "") .. tostring(CONFIG.TELEGRAM_USER or "")

    local function onOk()
      OpenURL(CONFIG.TELEGRAM_URL)
    end
    local function onClose()
      OpenURL(CONFIG.WHATSAPP_URL)
    end

    if Msg.ShowMsgBox then
      pcall(function()
        Msg.ShowMsgBox(title, body, CONFIG.BTN_OK, CONFIG.BTN_CLOSE, onOk, onClose)
      end)
      pcall(function()
        Msg.ShowMsgBox(title, body, onOk, onClose, CONFIG.BTN_OK, CONFIG.BTN_CLOSE)
      end)
    elseif Msg.ShowMsgBoxByData then
      pcall(function()
        Msg.ShowMsgBoxByData({
          title = title,
          msg = body,
          styleType = 2,
          okText = CONFIG.BTN_OK,
          cancelText = CONFIG.BTN_CLOSE,
          okCallback = onOk,
          cancelCallback = onClose,
        })
      end)
    end
  end)
end

local function BroadcastOnce()
  local msg = FullMessage()
  ShowLog(msg)
  ShowScreen(msg)
  ShowNotify(msg)
  ShowPopup(msg)
end

local function StartSpamLoop()
  if _G.__YAHIKO_INFO_SPAM_STARTED then return end
  _G.__YAHIKO_INFO_SPAM_STARTED = true

  local interval = tonumber(CONFIG.SPAM_INTERVAL) or 5.0
  if interval < 1 then interval = 1 end

  pcall(function()
    local ticker = require("common.time_ticker")
    if ticker and ticker.AddTimerOnce then
      ticker.AddTimerOnce(1.0, function()
        pcall(BroadcastOnce)
      end)
      if ticker.AddTimerLoop then
        ticker.AddTimerLoop(0, function()
          pcall(BroadcastOnce)
        end, -1, interval)
      else
        local function schedule()
          ticker.AddTimerOnce(interval, function()
            pcall(BroadcastOnce)
            schedule()
          end)
        end
        schedule()
      end
      return
    end
  end)

  pcall(function()
    local ticker = package.loaded["common.time_ticker"]
    if not ticker then return end
    if ticker.AddTimerOnce then
      ticker.AddTimerOnce(2.0, function()
        if not _G.__YAHIKO_INFO_SPAM_LOOP then
          _G.__YAHIKO_INFO_SPAM_LOOP = true
          if ticker.AddTimerLoop then
            ticker.AddTimerLoop(0, function()
              pcall(BroadcastOnce)
            end, -1, interval)
          end
        end
      end)
    end
  end)
end

StartSpamLoop()

return {
  CONFIG = CONFIG,
  BroadcastOnce = BroadcastOnce,
  StartSpamLoop = StartSpamLoop,
}
