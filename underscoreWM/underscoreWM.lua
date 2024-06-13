local lgi = require 'lgi'
local cqueues = require 'cqueues'
local xlib = lgi.xlib

local conf_path = os.getenv("HOME") .. "/.config/underscore/conf.fig"
local default_backdrop = os.getenv("HOME") .. "/.config/underscore/default.png"
local config = {}

-- Initialize X11
local display = xlib.XOpenDisplay(nil)
local root = xlib.XDefaultRootWindow(display)

-- Function to parse the config file
local function parse_config()
    for line in io.lines(conf_path) do
        -- Remove comments
        line = line:gsub("||.*", "")
        -- Trim whitespace
        line = line:match("^%s*(.-)%s*$")
        
        -- Process non-empty lines
        if line ~= "" then
            local command, args = line:match("^(%S+)%s+(.*)$")
            if command and args then
                if command == "ras" then
                    table.insert(config.startup_commands, args)
                elseif command == "rafb" then
                    table.insert(config.first_boot_commands, args)
                elseif command == "bind" then
                    local key, cmd = args:match("^(%S+)%s*;%s*(.*)$")
                    table.insert(config.keybindings, { key = key, command = cmd })
                elseif command == "bgd" then
                    config.background = args
                end
            end
        end
    end
end

-- Function to execute startup commands
local function run_startup_commands()
    for _, cmd in ipairs(config.startup_commands) do
        os.execute(cmd)
    end
end

-- Function to set background
local function set_background()
    if config.background then
        os.execute("feh --bg-scale " .. config.background)
    elseif os.execute("[ -f " .. default_backdrop .. " ]") then
        os.execute("feh --bg-scale " .. default_backdrop)
    end
end

-- Function to manage windows (tiling logic)
local function manage_windows()
    local screen = xlib.XDefaultScreenOfDisplay(display)
    local width = xlib.XWidthOfScreen(screen)
    local height = xlib.XHeightOfScreen(screen)
    
    local windows = {}
    
    local function tile_windows()
        local count = #windows
        if count == 0 then return end
        
        local cols = math.ceil(math.sqrt(count))
        local rows = math.ceil(count / cols)
        local win_width = width // cols
        local win_height = height // rows
        
        for i, win in ipairs(windows) do
            local col = (i - 1) % cols
            local row = math.floor((i - 1) / cols)
            xlib.XMoveResizeWindow(display, win, col * win_width, row * win_height, win_width, win_height)
        end
        xlib.XFlush(display)
    end
    
    local function add_window(win)
        table.insert(windows, win)
        tile_windows()
    end
    
    local function remove_window(win)
        for i, w in ipairs(windows) do
            if w == win then
                table.remove(windows, i)
                break
            end
        end
        tile_windows()
    end
    
    -- Listen for events
    local function event_loop()
        local event = xlib.XEvent()
        while true do
            xlib.XNextEvent(display, event)
            if event.type == xlib.ClientMessage then
                local ev = xlib.XClientMessageEvent(event)
                if ev.message_type == xlib.XInternAtom(display, "_NET_WM_STATE", false) and ev.format == 32 then
                    local action = ev.data.l[0]
                    local win = ev.window
                    if action == xlib.XInternAtom(display, "_NET_WM_STATE_ADD", false) then
                        add_window(win)
                    elseif action == xlib.XInternAtom(display, "_NET_WM_STATE_REMOVE", false) then
                        remove_window(win)
                    end
                end
            elseif event.type == xlib.MapRequest then
                local ev = xlib.XMapRequestEvent(event)
                xlib.XMapWindow(display, ev.window)
                add_window(ev.window)
            elseif event.type == xlib.DestroyNotify then
                local ev = xlib.XDestroyWindowEvent(event)
                remove_window(ev.window)
            elseif event.type == xlib.KeyPress then
                local ev = xlib.XKeyEvent(event)
                local keysym = xlib.XLookupKeysym(ev, 0)
                for _, binding in ipairs(config.keybindings) do
                    if keysym == xlib.XStringToKeysym(binding.key) then
                        os.execute(binding.command)
                    end
                end
            end
        end
    end
    
    -- Run the event loop in a separate thread
    local cq = cqueues.new()
    cq:wrap(event_loop)
    cq:loop()
end

-- Main function
local function main()
    config = {
        startup_commands = {},
        first_boot_commands = {},
        keybindings = {},
        background = nil,
    }

    parse_config()
    set_background()
    run_startup_commands()
    manage_windows()
end

main()
