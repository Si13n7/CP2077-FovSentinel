--[[
==============================================
This file is distributed under the MIT License
==============================================

FOV Sentinel

Allows you to lock the game's field of view
(FOV) and prevent unwanted changes caused by
in-game events or camera scripts.

Filename: text.lua
Version: 2025-11-17, 9:46 UTC+01:00 (MEZ)

Copyright (c) 2025, Si13n7 Developments(tm)
All rights reserved.
______________________________________________
--]]


return {
	--GUI: 🧩 General
	ENABLED = "enabled",
	DISABLED = "disabled",
	ON = "On",
	OFF = "Off",

	--GUI: 🚀 Main Controls
	GUI_INCOMP = "This mod may be incompatible with your system. Contact the mod developer for support.",
	GUI_LBL_LOCK = "Lock State",
	GUI_LBL_FROZEN = "Frozen FOV",
	GUI_LBL_FOV = "Display FOV",
	GUI_LBL_RAW = "Internal FOV",
	GUI_CHK_WINDOW = "Keep Window Visible",
	GUI_CHK_WIDGET = "Show Lock State Widget",
	GUI_CHK_WIDGET_WL = "Widget Only When Locked",
	GUI_CHK_ALERTS = "Show On-Screen Alerts",
	GUI_CHK_TOASTS = "Show CET Notifications",

	--HK: 🎮 Input & Hotkey
	HK_LOCK_ON = "Force Lock",
	HK_LOCK_OFF = "Force Unlock",
	HK_LOCK_TOG = "Toggle Lock State",
	HK_WIN_TOG = "Toggle Window Mode",

	--MSG: 🚨 On-Screen Notifications
	MSG_LOCKED = "The field of view has been locked to 100.",
	MSG_UNLOCKED = "The field of view has been unlocked.",

	--LOG: ✅ Success
	LOG_MODULE_INIT = "Module initialized.",

	--LOG: ❌ Errors
	LOG_MODULE_MISSING = "Module not found!",
	LOG_LOCK_FAIL = "Failed to lock the field of view.",
	LOG_UNLOCK_FAIL = "Failed to unlock the field of view.",

	--THROW: 🆘 Errors
	THROW_SQL_INIT = "Invalid arguments in SQLite init.",
	THROW_SQL_UPSERT = "Invalid arguments in SQLite upserts."
}