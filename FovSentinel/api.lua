--[[
==============================================
This file is distributed under the MIT License
==============================================

Standard API Definitions for IntelliSense

All definitions included here are used in the
main code.

These definitions have no functionality. They
are already provided by Lua or CET and exist
only for documentation and coding convenience.

Filename: api.lua
Version: 2025-11-17, 9:46 UTC+01:00 (MEZ)

Copyright (c) 2025, Si13n7 Developments(tm)
All rights reserved.
______________________________________________
--]]


---Enumerates the available types of Toast notifications for ImGui popups.
---@class ImGui.ToastType
---@field Success integer # A success notification, typically displayed in green.
---@field Warning integer # A warning notification, typically displayed in yellow or orange.
---@field Error integer # An error notification, typically displayed in red.
---@field Info integer # An informational notification, typically displayed in blue.
ImGui.ToastType = ImGui.ToastType

---Creates a Toast notification instance.
---@class ImGui.Toast
---@field type integer # The Toast type, typically a value from `ImGui.ToastType`.
---@field message string # The main text content of the Toast.
---@field new fun(type: ImGui.ToastType, message: string): ImGui.Toast # Creates a new Toast with the specified type and message.
ImGui.Toast = ImGui.Toast

---Provides functions to create graphical user interface elements within the Cyber Engine Tweaks overlay.
---@class ImGui
---@field Begin fun(title: string, flags?: integer): boolean # Begins a new ImGui window with optional flags. Must be closed with `ImGui.End()`. Returns true if the window is open and should be rendered.
---@field End fun() # Ends the creation of the current ImGui window. Must always be called after `ImGui.Begin()`.
---@field Dummy fun(width: number, height: number) # Creates an invisible element of specified width and height, useful for spacing.
---@field Separator fun() # Draws a horizontal line to visually separate UI sections.
---@field Text fun(text: string) # Displays text within the current window or tooltip.
---@field Checkbox fun(label: string, value: boolean): (boolean, boolean) # Creates a toggleable checkbox. Returns `changed` (true if state has changed) and `value` (the new state).
---@field BeginTable fun(id: string, columns: integer, flags?: integer): boolean # Begins a table with the specified number of columns. Returns true if the table is created successfully and should be rendered.
---@field TableSetupColumn fun(label: string, flags?: integer, init_width_or_weight?: number) # Defines a column in the current table with optional flags and initial width or weight.
---@field TableHeadersRow fun() # Automatically creates a header row using column labels defined by `TableSetupColumn()`. Must be called right after defining the columns.
---@field TableNextRow fun(row_flags?: integer, min_row_height?: number) # Advances to the next row. Optional: row flags and minimum height in pixels.
---@field TableNextColumn fun() # Advances to the next column in the current table row. Resets to column 0 after the last column.
---@field EndTable fun() # Ends the creation of the current table. Must always be called after `ImGui.BeginTable()`.
---@field CalcTextSize fun(text: string): number # Calculates the width of a given text string as it would be displayed using the current font. Returns the width in pixels as a floating-point number.
---@field GetWindowPos fun(): number, number # Returns the X and Y position of the current window, relative to the screen.
---@field GetWindowSize fun(): number, number # Returns the width and height of the current window in pixels.
---@field SetWindowPos fun(x: number, y: number) # Sets the position for the current window.
---@field SetWindowFontScale fun(scale: number) # Temporarily changes the font scaling for all text within the current window. Values below 1.0 make text smaller, values above 1.0 make it larger. Reset to 1.0 to restore normal size.
---@field GetCursorPos fun(): number, number # Returns the current cursor position (X, Y) within the window. Can be used to manually position elements.
---@field SetCursorPos fun(x: number, y: number) # Sets the cursor position within the window. Useful for manual placement of UI elements.
---@field SetCursorPosX fun(x: number) # Sets the X-position of the cursor within the window. Useful for manual horizontal positioning of UI elements.
---@field SetCursorPosY fun(y: number) # Sets the Y-position of the cursor within the window. Use to manually position elements vertically.
---@field GetFontSize fun(): number # Returns the height in pixels of the currently used font. Useful for vertical alignment calculations.
---@field PushStyleColor fun(idx: integer, color: integer) # Pushes a new color style override for the current ImGui context.
---@field PushStyleVar fun(idx: integer, value: number) # Pushes a single style variable override for the current ImGui context. `idx` is the ImGuiStyleVar enum value (e.g., WindowBorderSize, WindowPadding, ItemSpacing), and `value` is the number to set. Must be paired with `PopStyleVar()` to restore the previous style.
---@field PopStyleColor fun(count?: integer) # Removes one or more pushed style colors from the stack. Default count is 1.
---@field ShowToast fun(toast: ImGui.Toast) # Displays a Toast notification instance immediately.
ImGui = ImGui

---Flags used to configure ImGui window behavior and appearance.
---@class ImGuiWindowFlags
---@field NoTitleBar integer # Disables the window title bar.
---@field NoResize integer # Disables window resizing.
---@field NoMove integer # Disables window moving.
---@field NoCollapse integer # Disables the ability to collapse the window.
---@field AlwaysAutoResize integer # Automatically resizes the window to fit its content each frame.
---@field NoSavedSettings integer # Prevents the window from saving its settings to the .ini file.
---@field NoFocusOnAppearing integer # Prevents the window from taking focus when it appears.
---@field NoBringToFrontOnFocus integer # Prevents the window from being brought to the front when focused.
---@field NoInputs integer # Disables all inputs (mouse, keyboard, etc.) for the window.
ImGuiWindowFlags = ImGuiWindowFlags

---Style variables used to override ImGui layout and appearance settings temporarily.
---@class ImGuiStyleVar
---@field WindowBorderSize integer # Sets the thickness of a window's border in pixels. Can be pushed with `ImGui.PushStyleVar` to override the default border size. Set to 0 to remove the window border.
ImGuiStyleVar = ImGuiStyleVar

---Flags to customize table behavior and appearance.
---@class ImGuiTableFlags
---@field Borders integer # Draws borders between cells.
ImGuiTableFlags = ImGuiTableFlags

---Flags to customize individual columns within a table.
---@class ImGuiTableColumnFlags
---@field WidthStretch integer # Makes the column stretch to fill available space.
---@field WidthFixed integer # Makes the column have a fixed width.
ImGuiTableColumnFlags = ImGuiTableColumnFlags

---UI color indices used for styling via `ImGui.PushStyleColor()`.
---Each index refers to a specific UI element's color.
---@class ImGuiCol
---@field Text integer # The color of text.
---@field WindowBg integer # The background color of a window. Default is an opaque dark background.
---@field TitleBg integer # The background color of a window's title bar when inactive (not focused).
---@field TitleBgActive integer # The background color of a window's title bar when active (focused).
---@field TableHeaderBg integer # The background color of a table's header row.
ImGuiCol = ImGuiCol

---Bitwise operations (Lua 5.1 compatibility).
---@class bit32
---@field bor fun(...: integer): integer # Bitwise OR of all given integer values.
bit32 = bit32

---Manages vehicle camera behavior, including first-person and third-person perspectives.
---@class VehicleCameraManager
---@field IsTPPActive fun(self: VehicleCameraManager): boolean # Returns true if the third-person (TPP) vehicle camera is currently active.

---Represents a camera component that controls the player's viewing parameters.
---@class CameraComponent
---@field GetFOV fun(self: CameraComponent): number # Returns the current internal field of view (FOV) value used by the camera.
---@field GetDisplayFOV fun(self: CameraComponent): number # Returns the display-adjusted field of view (FOV) value shown to the player. Requires `FovControl` to be available.

---Represents the player character in the game, providing functions to interact with the player instance.
---@class Player
---@field FindComponentByType fun(self: Player, typeName: string): table # Finds and returns a component of the specified type attached to the player, or nil if not found.
---@field FindVehicleCameraManager fun(self: Player): VehicleCameraManager? # Returns the vehicle camera manager instance if the player is in a vehicle, otherwise nil.
---@field GetFPPCameraComponent fun(self: Player): CameraComponent? # Returns the first-person camera component, or nil if unavailable.
---@field GetTPPCameraComponent fun(self: Player): CameraComponent? # Returns the third-person camera component, or nil if unavailable. Requires `FovControl` and `Codeware` to be available.
---@field SetWarningMessage fun(self: Player, message: string, duration: number) # Displays a blue relic-style warning message on the player's screen for a specified duration.

---Provides various global game functions, such as getting the player, mounted vehicles, and converting names to strings.
---@class Game
---@field GetPlayer fun(): Player # Retrieves the current player instance if available.
---@field ShowMessage fun(message: string, duration: number) # Displays a red warning message on the player's screen for a specified duration.
Game = Game

---Returns the current screen resolution as width and height in pixels.
---@class GetDisplayResolution # Not a class — provided by CET.
---@field GetDisplayResolution fun(): integer, integer # Returns width and height of the active display in pixels.
GetDisplayResolution = GetDisplayResolution

---Allows the registration of functions to be executed when certain game events occur, such as initialization or shutdown.
---@class registerForEvent # Not a class — provided by CET.
---@field registerForEvent fun(eventName: string, callback: fun(...)) # Registers a callback function for a specified event (e.g., `onInit`, `onIsDefault`).
registerForEvent = registerForEvent

---Allows the registration of custom keyboard shortcuts that trigger specific Lua functions.
---@class registerHotkey # Not a class — provided by CET.
---@field registerHotkey fun(id: string, label: string, callback: fun()) # Registers a hotkey with a unique identifier, a descriptive label shown in CET's Hotkey menu, and a callback function to execute when pressed.
registerHotkey = registerHotkey

---Allows the registration of input bindings that respond to key press and release events.
---@class registerInput # Not a class — provided by CET.
---@field registerInput fun(id: string, label: string, callback: fun(down: boolean)) # Registers an input action with a unique identifier, a descriptive label for CET’s Input menu, and a callback function that receives `true` on key press and `false` on key release.
registerInput = registerInput

---SQLite database handle.
---@class db # Not a class — provided by CET.
---@field exec fun(self: db, sql: string): boolean?, string? # Executes a SQL statement. Returns true on success, or nil and an error message.
---@field rows fun(self: db, sql: string): fun(): table # Executes a SELECT statement and returns an iterator. Each yielded row is an array (table) of column values.
db = db

---Provides native functions for controlling and converting the in-game field of view (FOV).
---@class FovControl # RED4ext plugin.
---@field IsPatchingAllowed fun(): boolean # Returns true if memory patching operations (Lock/Unlock/Toggle) are currently allowed.
---@field PreventPatching fun(): boolean # Disables all future FOV patching operations until re-enabled with `ReleasePatching()`.
---@field ReleasePatching fun(): boolean # Re-enables FOV patching operations after they were disabled.
---@field IsLocked fun(): boolean # Returns true if the FOV is currently locked in memory.
---@field Lock fun(): boolean # Applies the patch that locks the FOV, preventing the game from adjusting it dynamically.
---@field Unlock fun(): boolean # Removes the patch and restores normal FOV behavior.
---@field ToggleLock fun(): boolean # Switches between locked and unlocked states.
---@field ConvertFormat fun(fov: number, isSettingsFormat: boolean): number # Converts a FOV value between internal and display (settings) formats. When `isSettingsFormat` is true, converts from internal to display; otherwise, converts from display to internal.
FovControl = FovControl
