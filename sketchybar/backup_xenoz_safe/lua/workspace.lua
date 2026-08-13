#!/usr/bin/env lua

-- XENOZ AeroSpace Workspace Controller
-- Handles sliding glass pill indicator and workspace state

local focused = os.getenv("FOCUSED_WORKSPACE")
local prev = os.getenv("PREV_WORKSPACE")
local is_init = os.getenv("INIT") == "true"
local script_name = os.getenv("NAME")

-- 1. Helper to run shell command and return stdout
local function exec(cmd)
    local handle = io.popen(cmd)
    if not handle then return "" end
    local result = handle:read("*a") or ""
    handle:close()
    return result
end

-- 2. Helper to read a single line file
local function read_file(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local content = f:read("*l")
    f:close()
    if content then
        return content:match("^%s*(.-)%s*$")
    end
    return nil
end

-- 3. Resolve focused workspace if not provided in environment
if not focused or focused == "" then
    local out = exec("aerospace list-workspaces --focused 2>/dev/null")
    focused = out:match("([^\r\n%s]+)")
end

if not focused or focused == "" then
    focused = "1"
end

-- 4. Retrieve previous workspace from cache if not passed
local cache_file = "/tmp/sketchybar_aerospace_prev_workspace"
if not prev or prev == "" then
    prev = read_file(cache_file) or focused
end

-- Save current focused workspace to cache
local f_cache = io.open(cache_file, "w")
if f_cache then
    f_cache:write(focused .. "\n")
    f_cache:close()
end

-- 5. Read theme colors if available
local theme_primary = read_file(os.getenv("HOME") .. "/.config/sketchybar/theme/current.primary") or "0xffcba6f7"
local theme_secondary = read_file(os.getenv("HOME") .. "/.config/sketchybar/theme/current.secondary") or "0xffa6adc8"
local color_active_icon = "0xffffffff"
local color_inactive_icon = "0xff6c7086"

-- 6. Helper to extract origin X and size W from sketchybar query
local function get_bounding_rect(item_name)
    local raw = exec("sketchybar --query " .. string.format("%q", item_name) .. " 2>/dev/null")
    local ox = tonumber(raw:match("\"origin\":%s*%[%s*([%d%.%-]+)"))
    local w = tonumber(raw:match("\"size\":%s*%[%s*([%d%.%-]+)"))
    return ox, w
end

-- 7. Query indicator and target space positions
local ind_x, ind_w = get_bounding_rect("workspace_indicator")
local space_x, space_w = get_bounding_rect("space." .. focused)

-- Fallback calculation if query fails
local target_offset = 34
if ind_x and space_x and space_w then
    local target_center = space_x + (space_w / 2)
    target_offset = math.floor(target_center - ind_x + 0.5)
else
    -- Fallback calculation based on workspace number
    local sid_num = tonumber(focused) or 1
    target_offset = 34 + (sid_num - 1) * 40
end

-- 8. Get all workspaces to update icon colors
local ws_raw = exec("aerospace list-workspaces --all 2>/dev/null")
local workspaces = {}
for ws in ws_raw:gmatch("([^\r\n%s]+)") do
    table.insert(workspaces, ws)
end

if #workspaces == 0 then
    workspaces = { "1", "2", "3", "4", "5", "6", "7", "8" }
end

-- 9. Determine animation parameters
local prev_num = tonumber(prev)
local focused_num = tonumber(focused)
local distance = 1
if prev_num and focused_num then
    distance = math.abs(focused_num - prev_num)
end

-- Adaptive duration: 15 frames for single step, up to 20 for multiple steps
local duration = math.min(22, 14 + (distance * 2))

-- 10. Build batch command
local batch = {}

-- Indicator animation or instant placement
if is_init or prev == focused then
    table.insert(batch, string.format("--set workspace_indicator drawing=on background.drawing=on background.x_offset=%d", target_offset))
else
    table.insert(batch, string.format("--animate tanh %d --set workspace_indicator drawing=on background.drawing=on background.x_offset=%d", duration, target_offset))
end

-- Workspace items highlight and colors
for _, ws in ipairs(workspaces) do
    if ws == focused then
        table.insert(batch, string.format("--set space.%s icon.color=%s icon.highlight=on", ws, color_active_icon))
    else
        table.insert(batch, string.format("--set space.%s icon.color=%s icon.highlight=off", ws, color_inactive_icon))
    end
end

-- Execute batched command in a single call
local cmd = "sketchybar " .. table.concat(batch, " ")
os.execute(cmd)
