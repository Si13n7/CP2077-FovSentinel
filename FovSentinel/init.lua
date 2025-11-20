--[[
==============================================
This file is distributed under the MIT License
==============================================

FOV Sentinel

Allows you to lock the game's field of view
(FOV) and prevent unwanted changes caused by
in-game events or camera scripts.

Filename: init.lua
Version: 2025-11-20, 11:00 UTC+01:00 (MEZ)

Copyright (c) 2025, Si13n7 Developments(tm)
All rights reserved.
______________________________________________
--]]


--Aliases for commonly used standard library functions to simplify code.
local format, concat, insert, sort, unpack, abs, ceil, floor, bor =
	string.format,
	table.concat,
	table.insert,
	table.sort,
	table.unpack,
	math.abs,
	math.ceil,
	math.floor,
	bit32.bor

---Loads all static UI and log string constants from `text.lua` into the global `Text` table.
---This is the most efficient way to manage display strings separately from logic and code.
---@type table<string, string>
local Text = dofile("text.lua")

---Holds runtime state flags that control mod behavior.
local mod = {
	---Determines whether the mod is enabled.
	isEnabled = false,

	---Stores the last locked FOV value to detect external changes.
	frozenFov = 0,

	---Determines whether settings have been modified.
	unsavedSettings = false
}

---Stores user interface states, overlay visibility, and toast notification handling.
local gui = {
	---True if the CET overlay is currently open.
	isOverlayOpen = false,

	---True if the mod's window should remain visible even when the overlay is closed.
	isAlwaysVisible = false,

	---True if the on-screen FOV status widget is enabled.
	---The widget appears in the top-right corner and displays both the current and locked FOV values, along with the lock status icon.
	isWidgetEnabled = true,

	---If true, the on-screen widget is only shown while the FOV is locked.
	isWidgetPassive = false,

	---WIP
	widgetSizeOffset = 0,

	---If true, an on-screen notification is displayed when a hotkey is pressed.
	areAlertsAllowed = false,

	---True if toast notifications are enabled and can be shown.
	areToastsAllowed = true,

	---True if there are pending toasts waiting to be displayed.
	areToastsPending = false,

	---Maps toast types to concatenated messages for combined display.
	---@type table<ImGui.ToastType, string>
	toasterBumps = {}
}

---Outputs a formatted message with timestamp and level prefix to the CET console.
---@param lvl string # Message level or category label (e.g., "Info", "Warning", "Error").
---@param fmt string # The message text or printf-style format string.
---@param ... any # Optional arguments for string formatting.
local function echo(lvl, fmt, ...)
	if not lvl or not fmt then return end

	local pfx = format("[FovSentinel]  [%s]  ", lvl)
	local msg = select("#", ...) and format(pfx .. fmt, ...) or fmt

	print(msg)
end

---Displays a queued on-screen toast notification with optional formatted text.
---Messages are grouped by toast type and shown together in ImGui during the next draw cycle.
---@param kind integer # The toast category (e.g., Info, Warning, Error). Defaults to Info if invalid or nil.
---@param fmt string # The message or printf-style format string.
---@param ... any # Optional arguments for string formatting.
local function toast(kind, fmt, ...)
	if not gui.areToastsAllowed or not ImGui.ToastType then return end

	if type(fmt) ~= "string" or #fmt < 1 then return end
	kind = (type(kind) == "number" and kind > 0 and kind < 5) and kind or ImGui.ToastType.Info

	local bumps = gui.toasterBumps
	local msg = "\u{f099d} " .. fmt
	bumps[kind] = (bumps[kind] and bumps[kind] .. "\n\n" or "") .. (select("#", ...) > 0 and format(msg, ...) or msg)

	gui.areToastsPending = true
end

---Logs an error message to the CET console.
---@param fmt string # Format string for the error message.
---@param ... any # Optional arguments to be formatted into the message.
local function error(fmt, ...)
	echo("Error", fmt, ...)

	if gui.areToastsAllowed and ImGui.ToastType then
		toast(ImGui.ToastType.Error, fmt, ...)
	end
end

---Logs an informational message to the CET console.
---@param fmt string # Format string for the info message.
---@param ... any # Optional arguments to be formatted into the message.
local function success(fmt, ...)
	echo("Success", fmt, ...)

	if gui.areToastsAllowed and ImGui.ToastType then
		toast(ImGui.ToastType.Success, fmt, ...)
	end
end

---Displays an on-screen notification or relic-style warning message.
---If `relic` is true, shows a blue relic-style message above the player HUD (using `SetWarningMessage`).
---Otherwise, it sends a standard red warning popup to the UI notification system.
---@param msg string # The message text to display.
---@param relic boolean? # Optional; when true, shows the blue relic-style warning instead of a normal red UI message.
local function alert(msg, relic)
	if not gui.areAlertsAllowed then return end

	if relic then
		local player = Game.GetPlayer()
		if player then
			player:SetWarningMessage(msg, 5.0)
			return
		end
	end

	Game.ShowMessage(msg, 5.0)
end

---Checks whether the provided argument is a non-empty string.
---Returns false if the argument is not a string or is an empty string.
---@param s any # Value to check.
---@return boolean # True if the argument is a non-empty string, false otherwise.
local function isStringValid(s)
	return type(s) == "string" and #s > 0
end

---Checks whether all provided arguments are a non-empty strings.
---Returns false if any argument is not a string or is an empty string.
---@param ... any # Values to check.
---@return boolean # True if all arguments are non-empty strings, false otherwise.
local function areStringValid(...)
	for i = 1, select("#", ...) do
		local s = select(i, ...)
		if not isStringValid(s) then
			return false
		end
	end
	return true
end

---Checks whether the provided argument is a non-empty table.
---Returns false if the argument is not a table or is an empty table.
---@param t any # Value to check.
---@return boolean # True if the argument is a non-empty table, false otherwise.
local function isTableValid(t)
	return type(t) == "table" and next(t) ~= nil
end

---Ordered pairs iterator (deterministic lexicographic by key).
---@param t table # Table to iterate.
---@return fun(): string?, any # Iterator yielding key-value pairs in sorted order.
local function opairs(t)
	if type(t) ~= "table" then
		return function()
			return nil, nil
		end
	end
	local keys = {}
	for k in pairs(t) do
		keys[#keys + 1] = k
	end
	sort(keys)
	local i = 0
	return function()
		i = i + 1
		local k = keys[i]
		if k ~= nil then
			return k, t[k]
		end
	end
end

---Rounds a floating-point number to a specified number of decimal places using integer arithmetic for reliability.
---This avoids floating-point drift by scaling before rounding and rescaling afterward.
---@param value number # The numeric value to round.
---@param digits number? # Optional number of decimal digits to keep. Defaults to 0 if omitted or invalid.
---@return number # The reliably rounded numeric value.
local function roundF(value, digits)
	if type(value) ~= "number" then return 0 end
	digits = type(digits) == "number" and abs(digits) or 0
	local factor = 10 ^ digits
	local scaled = value * factor
	local result = (scaled >= 0) and floor(scaled + 0.5) or ceil(scaled - 0.5)
	return result / factor
end


---Initializes a table in the database.
---Creates the table if it does not exist.
---@param tableName string # Name of the table to create.
---@param ... string # Column definitions, each as a separate string.
local function sqliteInit(tableName, ...)
	assert(isStringValid(tableName) and select("#", ...) > 0, Text.THROW_SQL_INIT)
	local columns = concat({ ... }, ", ")
	local query = format("CREATE TABLE IF NOT EXISTS %s(%s);", tableName, columns)
	db:exec(query)
end

---Begins a transaction.
local function sqliteBegin()
	db:exec("BEGIN;")
end

---Commits a transaction.
local function sqliteCommit()
	db:exec("COMMIT;")
end

---Returns an iterator over the rows of a table.
---Each yielded row is an array (table) of column values.
---@param tableName string # Name of the table.
---@param ... string # Optional column names to select, defaults to `*`.
---@return (fun(): table)? # Iterator returning a row table or nil when finished.
local function sqliteRows(tableName, ...)
	if not isStringValid(tableName) then return end
	local columns = select("#", ...) > 0 and concat({ ... }, ", ") or "*"
	local query = format("SELECT %s FROM %s;", columns, tableName)
	return db:rows(query)
end

---Inserts or updates a row by primary key.
---If a conflict on the key occurs, the existing row will be updated.
---@param tableName string # Name of the table to insert into.
---@param keyColumn string # Column that acts as the primary key.
---@param colValPairs table # Key-value table of columns and their values.
---@return boolean? # True on success, nil on failure.
local function sqliteUpsert(tableName, keyColumn, colValPairs)
	assert(areStringValid(tableName, keyColumn) and isTableValid(colValPairs), Text.THROW_SQL_UPSERT)

	local fields, values, updates = {}, {}, {}
	for c, v in pairs(colValPairs) do
		insert(fields, c)

		local kind = type(v)
		if kind == "boolean" or kind == "number" then
			insert(values, tostring(v))
		else
			if kind ~= "string" then
				v = tostring(v) --Serializer not added to this script.
			end
			v = v:gsub("'", "''")
			insert(values, "'" .. v .. "'")
		end

		insert(updates, c .. "=excluded." .. c)
	end

	local query = format("INSERT INTO %s(%s) VALUES(%s) ON CONFLICT(%s) DO UPDATE SET %s;",
		tableName,
		concat(fields, ","),
		concat(values, ","),
		keyColumn,
		concat(updates, ","))

	return db:exec(query)
end

---Saves settings to `db.sqlite3` on disk.
local function saveSettings()
	if not mod.unsavedSettings then return end
	mod.unsavedSettings = false

	sqliteInit(
		"Settings",
		"Name TEXT PRIMARY KEY",
		"Value INTEGER"
	)

	sqliteBegin()

	local settings = {
		"isAlwaysVisible",
		"isWidgetEnabled",
		"isWidgetPassive",
		"areAlertsAllowed",
		"areToastsAllowed",
		"widgetSizeOffset"
	}
	for _, name in ipairs(settings) do
		local value = gui[name]
		if type(value) == "boolean" then
			value = value and 1 or 0
		end
		if type(value) == "number" then
			sqliteUpsert("Settings", "Name", {
				Name = name,
				Value = value
			})
		end
	end

	sqliteCommit()
end

---Loads saved settings from `db.sqlite3`.
local function loadSettings()
	sqliteInit(
		"Settings",
		"Name TEXT PRIMARY KEY",
		"Value INTEGER"
	)
	for row in sqliteRows("Settings", "Name, Value") do
		local name, value = unpack(row)
		if name and value then
			local kind = type(gui[name])
			if kind == "boolean" then
				gui[name] = value > 0
			elseif kind == "number" then
				gui[name] = value
			end
		end
	end
end

---Checks whether the field of view (FOV) is currently locked by the FovControl module.
---@return boolean # True if the FOV is locked, false otherwise.
local function isFovLocked()
	return mod.isEnabled and FovControl.IsLocked() or false
end

---Checks whether the player camera is currently in third-person perspective (TPP).
---@return boolean # True if the third-person camera is active, otherwise false.
local function isTPP()
	if not mod.isEnabled then return false end

	local player = Game.GetPlayer()
	local manager = player and player:FindVehicleCameraManager()
	if manager then
		return manager:IsTPPActive() == true
	end
	return false
end

---Returns the active camera component based on the specified perspective.
---@param tpp boolean? # Optional true to get the third-person camera component, false or nil for first-person.
---@return CameraComponent? # The corresponding camera component, or nil if unavailable.
local function getCamComp(tpp)
	if not mod.isEnabled then return nil end

	local player = Game.GetPlayer()
	if not player then return nil end

	return tpp and player:GetTPPCameraComponent() or player:GetFPPCameraComponent()
end

---Retrieves the current field of view (FOV) value.
---@param tpp boolean? # Optional true to read from the third-person camera, false or nil for first-person.
---@param settingsFormat boolean? # Optional  true to return the converted (display) FOV value instead of the internal one.
---@param digits integer? # Optional number of decimal digits for rounding when in display format. Defaults to 3.
---@return number # The current FOV value, or 0 if unavailable.
local function getFOV(tpp, settingsFormat, digits)
	if not mod.isEnabled then return 0 end

	local comp = getCamComp(tpp == true)
	if not comp then return 0 end

	local fov = settingsFormat and comp:GetDisplayFOV() or comp:GetFOV()
	if fov == 0 then return 0 end

	return type(digits) == "number" and roundF(fov, digits) or fov
end

---Returns the most recently locked (frozen) field of view (FOV) value.
---@param settingsFormat boolean? # Optional true to return the converted (display) FOV value instead of the internal one.
---@param digits integer? # Optional number of decimal digits for rounding when in display format. Defaults to 3.
---@return number # The frozen FOV value, converted and rounded if requested, or 0 if the mod is disabled or unset.
local function getFrozenFOV(settingsFormat, digits)
	if not mod.isEnabled then return 0 end

	local fov = mod.frozenFov
	if fov == 0 or not settingsFormat then return fov end

	return roundF(FovControl.ConvertFormat(fov, false), digits or 3)
end

---Updates the stored frozen field of view (FOV) value based on the current lock mod.
---@return number # The updated frozen FOV value, or 0 if the mod is disabled or the FOV is not locked.
local function updateFrozenFOV()
	if not mod.isEnabled then return 0 end
	mod.frozenFov = isFovLocked() and getFOV(isTPP()) or 0
	return mod.frozenFov
end

---Locks the current field of view (FOV) if not already locked or disabled.
local function lockFov()
	if not mod.isEnabled or isFovLocked() or abs(getFOV() - 51) < 1e-4 then return end

	if not FovControl.Lock() then
		error(Text.LOG_LOCK_FAIL)
		return
	end

	updateFrozenFOV()
end

---Unlocks the field of view (FOV) if currently locked and unchanged since it was frozen.
local function unlockFov()
	if not mod.isEnabled or not isFovLocked() then return end

	if not FovControl.Unlock() then
		error(Text.LOG_UNLOCK_FAIL)
		return
	end

	updateFrozenFOV()
end

---Toggles the current field of view (FOV) lock state without any checks.
---@return boolean # True if the FOV is now locked, false if unlocked.
local function toggleFovLock()
	if not mod.isEnabled then return false end

	if FovControl.ToggleLock() then
		return updateFrozenFOV() ~= 0
	end

	return isFovLocked()
end

---Adds centered text with custom word wrapping.
---@param text string # The text to display.
---@param wrap number # The maximum width before wrapping.
local function addTextCenterWrap(text, wrap)
	if not isStringValid(text) or not type(wrap) == "number" or wrap < 10 then return end

	local ln, w = "", ImGui.GetWindowSize()
	for s in text:gmatch("%S+") do
		local t = (not isStringValid(ln)) and s or (ln .. " " .. s)
		if ImGui.CalcTextSize(t) > wrap and ln ~= "" then
			ImGui.SetCursorPosX((w - ImGui.CalcTextSize(ln)) * 0.5)
			ImGui.Text(ln)
			ln = s
		else
			ln = t
		end
	end
	if isStringValid(ln) then
		ImGui.SetCursorPosX((w - ImGui.CalcTextSize(ln)) * 0.5)
		ImGui.Text(ln)
	end
end

---Adds a new row to the current ImGui table and fills its columns with provided values.
---@param ... any # One or more values to display in consecutive table columns.
local function addTableNextRow(...)
	local length = select("#", ...)
	if length < 1 then return end

	ImGui.TableNextRow()
	for i = 1, length do
		ImGui.TableNextColumn()
		ImGui.Text(tostring(select(i, ...)))
	end
end

---This event is triggered when the CET initializes this mod.
registerForEvent("onInit", function()
	pcall(function()
		local file = io.open("FovSentinel.log", "w")
		if file then file:close() end
	end)

	loadSettings()

	mod.isEnabled = FovControl and FovControl.IsPatchingAllowed() or false
	if not mod.isEnabled then
		error(Text.LOG_MODULE_MISSING)
		return
	end
	success(Text.LOG_MODULE_INIT)
end)

--Detects when the CET overlay is opened.
registerForEvent("onOverlayOpen", function()
	gui.isOverlayOpen = true
end)

--Detects when the CET overlay is closed.
registerForEvent("onOverlayClose", function()
	gui.isOverlayOpen = false
	saveSettings()
end)

--Display a simple GUI for debugging.
registerForEvent("onDraw", function()
	if gui.areToastsPending then
		if isTableValid(gui.toasterBumps) then
			for k, v in pairs(gui.toasterBumps) do
				local t = ImGui.Toast.new(k, v)
				ImGui.ShowToast(t)
			end
		end
		gui.toasterBumps = {}
		gui.areToastsPending = false
	end

	if not mod.isEnabled then
		if not gui.isOverlayOpen then return end
		local flags = bor(
			ImGuiWindowFlags.AlwaysAutoResize,
			ImGuiWindowFlags.NoCollapse,
			ImGuiWindowFlags.AlwaysAutoResize,
			ImGuiWindowFlags.NoSavedSettings
		)
		if ImGui.Begin("FOV Sentinel", flags) then
			local scale = ImGui.GetFontSize() / 18
			local width = 200 * scale
			ImGui.Dummy(width, 0)
			ImGui.PushStyleColor(ImGuiCol.Text, 0xff3d297a)
			addTextCenterWrap(Text.GUI_INCOMP, width)
			ImGui.Dummy(0, 4 * scale)
			ImGui.PopStyleColor()
			ImGui.End()
		end
		return
	end

	local isLocked = mod.frozenFov ~= 0
	if gui.isWidgetEnabled and (not gui.isWidgetPassive or isLocked) then
		local flags = bor(
			ImGuiWindowFlags.AlwaysAutoResize,
			ImGuiWindowFlags.NoTitleBar,
			ImGuiWindowFlags.NoMove,
			ImGuiWindowFlags.NoCollapse,
			ImGuiWindowFlags.AlwaysAutoResize,
			ImGuiWindowFlags.NoSavedSettings,
			ImGuiWindowFlags.NoFocusOnAppearing,
			ImGuiWindowFlags.NoBringToFrontOnFocus
		)
		ImGui.PushStyleColor(ImGuiCol.WindowBg, 0x00000000)
		ImGui.PushStyleVar(ImGuiStyleVar.WindowBorderSize, 0)
		if ImGui.Begin("##FakeWidget", flags) then
			local frozenFov = getFrozenFOV(true, 0)
			local currentFov = getFOV(isTPP(), true, 0)
			local scale = ImGui.GetFontSize() / 18
			local x, y = ImGui.GetCursorPos()

			local function drawText(value, yOffset, color)
				ImGui.PushStyleColor(ImGuiCol.Text, color)
				local text = tostring(value)
				local xOffset = ({
					isLocked and 7 or 5,
					isLocked and 4 or 2,
					isLocked and 1 or -1,
				})[#text] or 1
				ImGui.SetCursorPos(x - 1 + xOffset * scale, y + yOffset * scale)
				ImGui.SetWindowFontScale(0.7 + gui.widgetSizeOffset / 100)
				ImGui.Text(text)
				ImGui.PopStyleColor()
			end

			drawText(isLocked and frozenFov or currentFov, 14, 0xabf2e649)

			if isLocked and frozenFov ~= currentFov then
				drawText(currentFov, 22, 0xab49e6f2)
			end

			ImGui.SetWindowFontScale(1.0 + gui.widgetSizeOffset / 100)
			ImGui.SetCursorPos(x, y)

			ImGui.PushStyleColor(ImGuiCol.Text, 0xabf2e649)
			ImGui.Text(isLocked and "\u{f033e}" or "\u{f0fc6}")
			ImGui.PopStyleColor()

			local posX, posY = ImGui.GetWindowPos()
			local width = ImGui.GetWindowSize()
			local maxW = GetDisplayResolution()
			local newX = maxW - width
			if posX ~= newX or posY ~= 0 then
				ImGui.SetWindowPos(newX, 0)
			end

			ImGui.PopStyleColor()
			ImGui.End()
		end
	end

	if not gui.isAlwaysVisible and not gui.isOverlayOpen then return end

	local flags = ImGuiWindowFlags.AlwaysAutoResize
	if not gui.isOverlayOpen then
		flags = bor(flags,
			ImGuiWindowFlags.NoCollapse,
			ImGuiWindowFlags.NoInputs
		)
	end

	if not gui.isOverlayOpen then
		ImGui.PushStyleColor(ImGuiCol.WindowBg, 0x60000000)
		ImGui.PushStyleColor(ImGuiCol.TitleBg, 0x60000000)
		ImGui.PushStyleColor(ImGuiCol.TitleBgActive, 0x60000000)
		ImGui.PushStyleColor(ImGuiCol.TableHeaderBg, 0x40000000)
	else
		ImGui.PushStyleVar(ImGuiStyleVar.WindowBorderSize, 1)
	end

	if not ImGui.Begin("FOV Sentinel", flags) then return end

	if ImGui.BeginTable("Info", 2, ImGuiTableFlags.Borders) then
		ImGui.TableSetupColumn("\u{f1375}", ImGuiTableColumnFlags.WidthStretch)
		ImGui.TableSetupColumn("\u{f09a8}", ImGuiTableColumnFlags.WidthStretch)
		ImGui.TableHeadersRow()

		addTableNextRow(Text.GUI_LBL_LOCK, isFovLocked() and Text.ON or Text.OFF)

		local frozen = getFrozenFOV(true)
		if isLocked and frozen > 0 then
			addTableNextRow(Text.GUI_LBL_FROZEN, frozen)
		end

		local tpp = isTPP()
		local raw = getFOV(tpp, false, 3)
		if raw > 0 then
			local fov = getFOV(tpp, true, 3)
			addTableNextRow(Text.GUI_LBL_FOV, fov)
			addTableNextRow(Text.GUI_LBL_RAW, raw)
		end

		ImGui.EndTable()
	end

	if not gui.isOverlayOpen then
		ImGui.PopStyleColor(3)
		ImGui.End()
		return
	end

	local checkboxes = {
		{
			isAlwaysVisible = Text.GUI_CHK_WINDOW
		},
		{
			isWidgetEnabled = Text.GUI_CHK_WIDGET,
			isWidgetPassive = Text.GUI_CHK_WIDGET_WL
		},
		{
			areAlertsAllowed = Text.GUI_CHK_ALERTS,
			areToastsAllowed = Text.GUI_CHK_TOASTS
		}
	}

	for i, elements in ipairs(checkboxes) do
		for key, label in opairs(elements) do
			local current = gui[key]
			if type(current) == "boolean" then
				local recent = ImGui.Checkbox(label, current)
				if recent ~= current then
					gui[key] = recent
					mod.unsavedSettings = true
				end
			end
		end
		if i < #checkboxes then
			ImGui.Separator()
		end
	end

	ImGui.Separator()

	ImGui.SetNextItemWidth(floor(24 * (ImGui.GetFontSize() / 18)))
	local wOffset = gui.widgetSizeOffset
	local result = ImGui.DragInt(Text.GUI_INT_WSIZE, wOffset, 1, 0, 50)
	if result ~= wOffset and wOffset >= 0 and wOffset <= 50 then
		gui.widgetSizeOffset = result
		mod.unsavedSettings = true
	end

	ImGui.End()
end)

---Restores all changes upon mod shutdown.
registerForEvent("onShutdown", function()
	if not FovControl.IsLocked() then return end
	FovControl.ReleasePatching()
	FovControl.Unlock()
	alert(Text.MSG_UNLOCKED)
end)

---Hotkey: Locks the current field of view (FOV) and shows a relic-style alert with the locked FOV value.
local function hkLockOn()
	lockFov()
	alert(format(Text.MSG_LOCKED, getFrozenFOV(true, 0)), true)
end

---Hotkey: Unlocks the field of view (FOV) and shows a standard alert confirming unlock.
local function hkLockOff()
	unlockFov()
	alert(Text.MSG_UNLOCKED)
end

---Hotkey: Toggles the current FOV lock state and displays the result in an alert message.
local function hkLockToggle()
	local locked = toggleFovLock()
	alert(locked and format(Text.MSG_LOCKED, getFrozenFOV(true, 0)) or Text.MSG_UNLOCKED, locked)
end

---Hotkey: Toggles visibility of the main FOV Sentinel window.
local function hkWindowToggle()
	gui.isAlwaysVisible = not gui.isAlwaysVisible
end

---Registers both input and hotkey bindings for the given function, key, and label.
---@param key string # Unique identifier for the hotkey.
---@param label string # Label shown in CET settings.
---@param handler function # Function to bind.
local function registerHotkeyPair(key, label, handler)
	if not key or not label or not handler then return end

	registerInput("INP_FovSentinel_" .. key, label, function(down)
		if not down then handler() end
	end)

	registerHotkey("HK_FovSentinel_" .. key, label, handler)
end

---Handles hotkey actions registered through `registerInput` and `registerHotkey`.
local hotkeyMap = {
	LockOn = { label = Text.HK_LOCK_ON, handler = hkLockOn },
	LockOff = { label = Text.HK_LOCK_OFF, handler = hkLockOff },
	LockToggle = { label = Text.HK_LOCK_TOG, handler = hkLockToggle },
	WindowToggle = { label = Text.HK_WIN_TOG, handler = hkWindowToggle }
}
for key, e in opairs(hotkeyMap) do
	registerHotkeyPair(key, e.label, e.handler)
end
