#!/usr/bin/env lua

-- XENOZ — Caelestia Shell Workspace Controller
-- Pure smooth sliding glass pill indicator & AeroSpace workspace synchronization

local focused = os.getenv("FOCUSED_WORKSPACE")
local is_init = os.getenv("INIT") == "true"
local cache_file = "/tmp/sketchybar_aerospace_prev_workspace"

-- Helper to execute shell command and capture stdout
local function exec(cmd)
    local handle = io.popen(cmd)
    if not handle then return "" end
    local result = handle:read("*a") or ""
    handle:close()
    return result
end

-- Helper to read single-line file
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

-- 1. Determine active workspace
if not focused or focused == "" then
    local out = exec("aerospace list-workspaces --focused 2>/dev/null")
    focused = out:match("([^\r\n%s]+)")
end

if not focused or focused == "" then
    focused = "1"
end

-- 2. Determine previous workspace from cache
local prev = read_file(cache_file)
if not prev or prev == "" then
    prev = focused
end

-- Save current focused workspace to cache
local f_cache = io.open(cache_file, "w")
if f_cache then
    f_cache:write(focused .. "\n")
    f_cache:close()
end

-- 3. Discover all configured workspaces
local ws_raw = exec("aerospace list-workspaces --all 2>/dev/null")
local workspaces = {}
for ws in ws_raw:gmatch("([^\r\n%s]+)") do
    table.insert(workspaces, ws)
end

if #workspaces == 0 then
    workspaces = { "1", "2", "3", "4", "5", "6", "7", "8" }
end

-- Find indices for distance calculation
local prev_idx = 1
local focused_idx = 1
for i, ws in ipairs(workspaces) do
    if ws == prev then prev_idx = i end
    if ws == focused then focused_idx = i end
end

local distance = math.abs(focused_idx - prev_idx)

-- 4. Query exact bounding rectangles from SketchyBar geometry
local function get_bounding_rect(item_name)
    local raw = exec("sketchybar --query " .. string.format("%q", item_name) .. " 2>/dev/null")
    local ox = tonumber(raw:match("\"origin\":%s*%[%s*([%d%.%-]+)"))
    local w = tonumber(raw:match("\"size\":%s*%[%s*([%d%.%-]+)"))
    return ox, w
end

local ind_x, ind_w = get_bounding_rect("workspace_indicator")
local space_x, space_w = get_bounding_rect("space." .. focused)

local target_offset = 0
if ind_x and space_x and space_w then
    local ind_center = ind_x + ((ind_w and ind_w > 0) and (ind_w / 2) or 0)
    local space_center = space_x + (space_w / 2)
    target_offset = math.floor(space_center - ind_center + 0.5)
else
    -- Fallback estimation based on 40px workspace pitch
    target_offset = 8 + ((focused_idx - 1) * 40)
end

-- 5. Calculate smooth animation frames (tanh easing curve)
local duration = math.min(20, 14 + (distance * 2))

local color_active_icon = "0xffffffff"
local color_inactive_icon = "0xff6c7086"

-- 6. Build atomic batch command for SketchyBar
local batch = {}

if is_init or prev == focused then
    table.insert(batch, string.format("--set workspace_indicator drawing=on background.drawing=on background.x_offset=%d", target_offset))
else
    -- Pure horizontal translation without expanding
    table.insert(batch, string.format("--animate tanh %d --set workspace_indicator background.x_offset=%d", duration, target_offset))
end

-- Update all workspace item icon highlights and clear any lingering hover backgrounds
for _, ws in ipairs(workspaces) do
    if ws == focused then
        table.insert(batch, string.format("--set space.%s icon.color=%s icon.highlight=on background.drawing=off", ws, color_active_icon))
    else
        table.insert(batch, string.format("--set space.%s icon.color=%s icon.highlight=off background.drawing=off", ws, color_inactive_icon))
    end
end

-- Execute in a single atomic call to SketchyBar
local cmd = "sketchybar " .. table.concat(batch, " ")
os.execute(cmd)
