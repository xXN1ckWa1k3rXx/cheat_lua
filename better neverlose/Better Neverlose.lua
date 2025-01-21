--[[
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
]]

--[[ 
    Better Neverlose Recode v5.1 - recoded
    author: xXYu3_zH3nGL1ngXx
    Updated date: 1/21/2025
]]

local version_ = "1/21/2025 - 5.1"
local ffi = require "ffi"
local http_lib = require "neverlose/http_lib"

local nick = {}
nick.data = {}

----------------------- FFI CODE ---------------------

ffi.cdef[[
	bool PlaySound(
		const char* pszSound,
		void* hmod,
		unsigned int fdwSound
	);

    typedef void* HANDLE;
    typedef HANDLE HWND;
    typedef const char* LPCSTR;
    typedef int BOOL;
    typedef unsigned int UINT;
    typedef long LONG;
    typedef LONG LPARAM;
    typedef LONG LRESULT;
    typedef UINT WPARAM;

    HWND FindWindowA(LPCSTR lpClassName, LPCSTR lpWindowName);
    BOOL SetWindowTextA(HWND hWnd, LPCSTR lpString);

    void* __stdcall URLDownloadToFileA(void* LPUNKNOWN, const char* LPCSTR, const char* LPCSTR2, int a, int LPBINDSTATUSCALLBACK); 
    bool DeleteUrlCacheEntryA(const char* lpszUrlName);
]]

ffi.cdef[[
    typedef struct {
        unsigned long pid;
        unsigned long tid;
        unsigned long exit_code;
        unsigned long reserved;
    } PROCESS_INFORMATION;

    typedef struct {
        unsigned long length;
        void* reserved1;
        void* desktop;
        void* title;
        unsigned long x;
        unsigned long y;
        unsigned long x_size;
        unsigned long y_size;
        unsigned long x_count_chars;
        unsigned long y_count_chars;
        unsigned long fill_attribute;
        unsigned long flags;
        unsigned short show_window;
        unsigned short reserved2;
        void* reserved3;
        void* std_input;
        void* std_output;
        void* std_error;
    } STARTUPINFOA;

    bool CreateProcessA(
        const char* lpApplicationName,
        char* lpCommandLine,
        void* lpProcessAttributes,
        void* lpThreadAttributes,
        bool bInheritHandles,
        unsigned long dwCreationFlags,
        void* lpEnvironment,
        const char* lpCurrentDirectory,
        STARTUPINFOA* lpStartupInfo,
        PROCESS_INFORMATION* lpProcessInformation
    );
]]



-------------------USER FUNCTIONS---------------------

function normalize_yaw (angle)
    adjusted_yaw = angle;

    if adjusted_yaw < -180 then
        adjusted_yaw = adjusted_yaw + 360
    end
    
    if adjusted_yaw > 180 then
        adjusted_yaw = adjusted_yaw - 360
    end
    

    return adjusted_yaw;
end

local PlaySound = (function()
    local PlaySound = utils.get_vfunc("engine.dll", "IEngineSoundClient003", 12, "void*(__thiscall*)(void*, const char*, float, int, int, float)")
    return function(sound_name, volume)
        local name = sound_name:lower():find(".wav") and sound_name or ("%s.wav"):format(sound_name)
        pcall(PlaySound, name, tonumber(volume) / 100, 100, 0, 0)
    end
end)()

nick.get_trace = function (length)
    local me = entity.get_local_player()
    if not me then return end

    local x, y, z = me.m_vecOrigin.x, me.m_vecOrigin.y, me.m_vecOrigin.z

    for a = 0, math.pi * 2, math.pi * 2 / 8 do
        local ptX, ptY = ((10 * math.cos(a)) + x), ((10 * math.sin(a)) + y)
        local trace = utils.trace_line(vector(ptX, ptY, z), vector(ptX, ptY, z - length), me)

        if trace.fraction ~= 1 then return true end
    end
    return false
end

nick.math_lerp = function(a, b, percentage)
    return a + (b - a) * percentage
end

nick.math_new_lerp = function(name, value, time)
    if nick.data[name] == nil then
        nick.data[name] = 0
    end
    nick.data[name] = nick.math_lerp(nick.data[name], value, time)
    return nick.data[name]
end

nick.open_link = function (link)
    local steam_overlay_API = panorama.SteamOverlayAPI
    local open_external_browser_url = steam_overlay_API.OpenExternalBrowserURL
    open_external_browser_url(link)
end

local function open_explorer(path)
    local startup_info = ffi.new("STARTUPINFOA")
    local process_info = ffi.new("PROCESS_INFORMATION")
    local command_line = ffi.new("char[?]", #path + 1, path)

    startup_info.length = ffi.sizeof(startup_info)

    local success = ffi.C.CreateProcessA(
        nil,
        command_line,
        nil,
        nil,
        false,
        0,
        nil,
        nil,
        startup_info,
        process_info
    )

    if not success then
        error("Failed to open explorer")
    end
end

-- Example usage:
-- open_explorer("C:\\Windows\\explorer.exe D:\\SteamLibrary\\steamapps\\common\\Counter-Strike Global Offensive\\nl\\scripts")

------------------------ MENU --------------------------

nick.ref = {
    ragebot = {
        main = ui.find("Aimbot", "Ragebot", "Main"),
        enabled = ui.find("Aimbot", "Ragebot", "Main", "Enabled"),
        autopeek = ui.find("Aimbot", "Ragebot", "Main", "Peek Assist"),
        hs = ui.find("Aimbot", "Ragebot", "Main", "Hide Shots"),
        dt = ui.find("Aimbot", "Ragebot", "Main", "Double Tap"),
        lag_options = ui.find("Aimbot", "Ragebot", "Main", "Double Tap", "Lag Options"),
        hs_options = ui.find("Aimbot", "Ragebot", "Main", "Hide Shots", "Options"),
        hitboxes = ui.find("Aimbot", "Ragebot", "Selection", "Hitboxes"),
        multipoint = ui.find("Aimbot", "Ragebot", "Selection", "Multipoint"),
        safepoint = ui.find("Aimbot", "Ragebot", "Safety", "Safe Points"),
        baim = ui.find("Aimbot", "Ragebot", "Safety", "Body Aim"),
        safety = ui.find("Aimbot", "Ragebot", "Safety"),
        accuracy = ui.find("Aimbot", "Ragebot", "Accuracy", "SSG-08"),
        da = ui.find("Aimbot", "Ragebot", "Main", "Enabled", "Dormant Aimbot"),
    },
    
    antiaim = {
        angles = ui.find("Aimbot", "Anti Aim", "Angles"),
        pitch = ui.find("Aimbot", "Anti Aim", "Angles", "Pitch"),
        yaw = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw"),
        base = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Base"),
        offset = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Offset"),
        fakelag = ui.find("Aimbot", "Anti Aim", "Fake Lag"),
        misc = ui.find("Aimbot", "Anti Aim", "Misc"),
        bodyyaw = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw"),
        fs = ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding"):disabled(true),
        fl_enabled = ui.find("Aimbot", "Anti Aim", "Fake Lag", "Enabled"),
        aa_enabled = ui.find("Aimbot", "Anti Aim", "Angles", "Enabled"),
        limit = ui.find("Aimbot", "Anti Aim", "Fake Lag", "Limit"),
        fd = ui.find("Aimbot", "Anti Aim", "Misc", "Fake Duck"),
        hidden = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Hidden"),
        slowwalk = ui.find("Aimbot", "Anti Aim", "Misc", "Slow Walk"),
    },

    world = {
        main = ui.find("Visuals", "World", "Main"),
        other = ui.find("Visuals", "World", "Other"),
        thridperson = ui.find("Visuals", "World", "Main", "Force Thirdperson"),
        distance = ui.find("Visuals", "World", "Main", "Force Thirdperson", "Distance"),
    },

    misc = {
        clan_tag = ui.find("Miscellaneous", "Main", "In-Game", "Clan Tag"),
        movement = ui.find("Miscellaneous", "Main", "Movement"),
        in_game = ui.find("Miscellaneous", "Main", "In-Game"),
        other = ui.find("Miscellaneous", "Main", "Other"),
        buybot = ui.find("Miscellaneous", "Main", "Buybot"),
        buybot_enabled = ui.find("Miscellaneous", "Main", "BuyBot", "Enabled"),
        air_strafe = ui.find("Miscellaneous", "Main", "Movement", "Air Strafe"),
    }
}

nick.icons = {
    warning = ui.get_icon("triangle-exclamation"),
    github = ui.get_icon("github"),
    user = ui.get_icon("user"),
    star = ui.get_icon("star"),
    branch = ui.get_icon("code-branch"),
    arrows_rotate = ui.get_icon("arrows-rotate"),
}

nick.items = {

    ui.sidebar("Better Neverlose", "star"),
    info = ui.create("Better Neverlose - INFO."),
    plist = ui.create("Players list"),

    ragebot = {
        ax = nick.ref.ragebot.main:switch("\af5fd8effAnti Defensive"),
        os_peek = nick.ref.ragebot.main:switch("OS Peek"),
        global_safety = nick.ref.ragebot.main:label("Global Safety"):create(),
        jump_scout = nick.ref.ragebot.accuracy:switch("Jump Scout"),
    },

    antiaim = {
        defensive = nick.ref.antiaim.angles:switch("Defensive Anti Aim"),

        manual = nick.ref.antiaim.misc:combo("Manual", "None", "Left", "Backward", "Right", "Forward", "Freestanding"),
        air_exploit = nick.ref.antiaim.misc:switch("Air Exploit"),
    },

    fakelag = {
        slientshots = nick.ref.antiaim.fakelag:switch("Slient Shots"),
    },

    visuals = {
        viewmodel = nick.ref.world.main:switch("Custom Viewmodel"),
        debug = nick.ref.world.main:switch("\a{Link Active}".. nick.icons.warning .."  Debug"),
        event_sound = nick.ref.world.other:switch("Event sound"),
        indicator = nick.ref.world.other:switch("Indicators")
    },

    misc = {
        fast_fall = nick.ref.misc.movement:switch("Fast Fall"),
        clan_tag = nick.ref.misc.in_game:switch("Clan Tag"),
        trashtalk = nick.ref.misc.in_game:switch("Trashtalk On Kill"),
        vote_reveals = nick.ref.misc.in_game:switch("Vote reveals"),
        modifier = nick.ref.misc.other:selectable("Modifier", "Force sv_cheats 1", "Bypass sv_pure", "Performance Mode"),
        disable_buybot = nick.ref.misc.buybot:switch("Diasbled when low money")
    }
}

nick.create_elements = {
    ragebot = {
        os_peek = nick.items.ragebot.os_peek:create(),
    },

    antiaim = {
        defensive = nick.items.antiaim.defensive:create(),
        slientshots = nick.items.fakelag.slientshots:create(),
        air_exploit = nick.items.antiaim.air_exploit:create(),
    },

    visuals = {
        thridperson = nick.ref.world.thridperson:create(),
        viewmodel = nick.items.visuals.viewmodel:create(),
        debug = nick.items.visuals.debug:create(),
        event_sound = nick.items.visuals.event_sound:create(),
        indicator = nick.items.visuals.indicator:create(),
    },

    misc = {
        clan_tag = nick.items.misc.clan_tag:create(),
        trashtalk = nick.items.misc.trashtalk:create(),
        disable_buybot = nick.items.misc.disable_buybot:create(),
    },
}

nick.elements = {
    os_peek = {
        breaklc = nick.create_elements.ragebot.os_peek:switch("Lag on peek"),
    },

    global_safety = {
        safe_point = nick.items.ragebot.global_safety:switch("Force Safe Point"),
        body_aim = nick.items.ragebot.global_safety:switch("Force Body Aim"),
        onlyhead = nick.items.ragebot.global_safety:switch("Only Head"),
    },

    defensive = {
        pitch = nick.create_elements.antiaim.defensive:combo("Pitch", {"Zero", "Up", "Down", "Random", "Jitter", "45 deg", "Custom"}),
        pitch_custom = nick.create_elements.antiaim.defensive:slider("Pitch", -86, 86, 0),
        yaw = nick.create_elements.antiaim.defensive:combo("Yaw", {"Default", "Static", "Jitter", "Random", "Side-Way", "Spin"}),
        yaw_custom = nick.create_elements.antiaim.defensive:slider("Yaw", -180, 180, 0),
        yaw_jitter_mode = nick.create_elements.antiaim.defensive:combo("Jitter Mode", "Offset", "Center"),
        yaw_jitter = nick.create_elements.antiaim.defensive:slider("Jitter", -180, 180, 0),
        spin = nick.create_elements.antiaim.defensive:slider("Spin speed", 120, 7200, 1300),
        inair = nick.create_elements.antiaim.defensive:switch("Only In air"),
    },

    air_exploit = {
        ticks = nick.create_elements.antiaim.air_exploit:slider("Ticks", 13, 21, 15),
    },

    slientshots = {
        mode = nick.create_elements.antiaim.slientshots:combo("Mode", "Overrides", "Send packets"),
    },

    event_sound = {
        event = nick.create_elements.visuals.event_sound:selectable("Event", "Missed shot", "Taser kill"),
        miss_file = nick.create_elements.visuals.event_sound:input("Missed shot - file"),
        taser_file = nick.create_elements.visuals.event_sound:input("Taser kill - file"),
        volume = nick.create_elements.visuals.event_sound:slider("Volume", 0, 100, 70),
        open_folder = nick.create_elements.visuals.event_sound:button("Open sound folder", function()  
            open_explorer("C:\\Windows\\explorer.exe " .. common.get_game_directory() .. "\\sound")
        end, true)
    },

    thridperson = {
        animation = nick.create_elements.visuals.thridperson:switch("Animation camera"),
        distance = nick.create_elements.visuals.thridperson:slider("~ Distance", 15, 250, 110),
    },

    viewmodel = {
        fov = nick.create_elements.visuals.viewmodel:slider("Fov", 0, 160, 70, 0.1),
        x = nick.create_elements.visuals.viewmodel:slider("X", -200, 200, 0, 0.1),
        y = nick.create_elements.visuals.viewmodel:slider("Y", -200, 200, 0, 0.1),
        z = nick.create_elements.visuals.viewmodel:slider("Z", -200, 200, 0, 0.1),
        aspectratio = nick.create_elements.visuals.viewmodel:slider("Aspect Ratio", 0, 50, 0, 0.1),
    },

    debug = {
        watermark = nick.create_elements.visuals.debug:switch("Watermark"),
        list = nick.create_elements.visuals.debug:selectable("Elements", {"Feet Yaw", "Choked Commands", "Real Yaw", "Abs Yaw", "Desync", "Threat", "Exploit charge"}),
    },

    indicator = {
        crosshair = nick.create_elements.visuals.indicator:switch("Crosshair"),
        slow_down = nick.create_elements.visuals.indicator:switch("Slow Down Indicator"),
        left = nick.create_elements.visuals.indicator:listable("Elements", {"Double Tap & Hide Shots", "Fake Duck", "DA", "AX", "DMG", "HC", "LC"}),
    },

    clan_tag ={
        style = nick.create_elements.misc.clan_tag:combo("Style", "Neverlose", "Custom"),
        text = nick.create_elements.misc.clan_tag:input("Text"),
        custom_style = nick.create_elements.misc.clan_tag:combo("Custom style", "Static", "Roll"),
        speed = nick.create_elements.misc.clan_tag:slider("Speed", 0, 100, 50),
    },

    trashtalk = {
        text = nick.create_elements.misc.trashtalk:input("Text"),
        check = nick.create_elements.misc.trashtalk:switch("Add username"),
        username_warm = nick.create_elements.misc.trashtalk:label("\a{Link Active}" .. nick.icons.warning .. " need to append a username just add \aDEFAULT %s\a{Link Active} above the content. The script will automatically place the username based on the content.")
    },

    disable_buybot = {
        money = nick.create_elements.misc.disable_buybot:slider("Money", 0, 16000, 3200),
    },

    info = {
        nick.items.info:label(nick.icons.star .." Better Neverlose"),
        nick.items.info:button(nick.icons.branch .. " " .. version_, nil, true),
        nick.items.info:label(nick.icons.user .."  Author"),
        nick.items.info:button("xXYu3_zH3nGL1ngXx", nil, true),
        nick.items.info:label("\a{Link Active}" .. nick.icons.warning .. "  Protip: Attention features tooltip. It can help you understand its work\n"),
        github = nick.items.info:button(nick.icons.github .. "  Github", function() nick.open_link("https://github.com/xXN1ckWa1k3rXx/cheat_lua") end, true),
        check_update = nick.items.info:button(nick.icons.arrows_rotate .. "  Check Update", function() nick.check_update() end, true),
    },

    plist = {
        list = nick.items.plist:list("Players", {"None."}),
        update = nick.items.plist:button("Update list", function(self)
            nick.plist()
        end),
    },
}

nick.color_picker = {
    slow_down = nick.elements.indicator.slow_down:color_picker("Slow Down Color") 
}

nick.tooltips_text = {
    ax = 
    [[Disabled your lag compensation.

    It will ignore any lag compensations and shot who using defensive lag easier.
    Not recommended use on scout or onetap weapons.]],

    os_peek =
    [[Use Hide shots to teleport on peeking.

Compared with Double tap, HS has a shorter tp distance.]],

    lag_on_peek =
    [[Same as double tap lag on peek

Both are breaking lc while teleporting]],

    air_exploit = [[Need holding with bind and already charged.]],

    event_sound = [[Sound files should in 
[csgo folder]/csgo/sound folder

Standard wave format (.wav)
]],

    disabled_buybot = [[Automatically disable Buy bot when the current amount of money is lower than expected
    
Suitable for specific situations and gameplay (e.g MM)]],

    plist_highlight = [[The highlight indicator is available in the ESP flags elements list of the Player enemy, which requires you to enable it manually.]],

    plist_whitelist = [[Due to logic and implementation, the HP after canceling the Whitelist will return to 100HP (even if it is not 100HP now), and only the HP of the player changes (being hit or recovering HP) will it return to normal HP
    
If you use Whitelist for this player, you will find that the player's HP is 0, which is normal.]]
}

nick.tooltip = {
    nick.items.ragebot.ax:tooltip(nick.tooltips_text.ax),
    nick.items.ragebot.os_peek:tooltip(nick.tooltips_text.os_peek),
    nick.elements.os_peek.breaklc:tooltip(nick.tooltips_text.lag_on_peek),

    nick.items.antiaim.air_exploit:tooltip(nick.tooltips_text.air_exploit),
    nick.items.visuals.event_sound:tooltip(nick.tooltips_text.event_sound),
    nick.items.misc.disable_buybot:tooltip(nick.tooltips_text.disabled_buybot),
    
    -- for plist tooltip go to plist function part
}

nick.menu_visible = function ()
    nick.elements.defensive.pitch_custom:visibility( nick.elements.defensive.pitch:get() == "Custom" )
    nick.elements.defensive.yaw_custom:visibility( nick.elements.defensive.yaw:get() == "Static" or nick.elements.defensive.yaw:get() == "Jitter" )
    nick.elements.defensive.spin:visibility(nick.elements.defensive.yaw:get() == "Spin")
    nick.elements.defensive.yaw_jitter_mode:visibility(nick.elements.defensive.yaw:get() == "Jitter")
    nick.elements.defensive.yaw_jitter:visibility(nick.elements.defensive.yaw:get() == "Jitter")

    nick.ref.world.distance:visibility(false)

    nick.elements.event_sound.miss_file:visibility(nick.elements.event_sound.event:get("Missed shot"))
    nick.elements.event_sound.taser_file:visibility(nick.elements.event_sound.event:get("Taser kill"))

    nick.ref.misc.clan_tag:visibility(false)
    nick.elements.clan_tag.text:visibility(nick.elements.clan_tag.style:get() == "Custom")
    nick.elements.clan_tag.custom_style:visibility(nick.elements.clan_tag.style:get() == "Custom")
    nick.elements.clan_tag.speed:visibility(nick.elements.clan_tag.style:get() == "Custom" and nick.elements.clan_tag.custom_style:get() == "Roll")
end

---------------------------override-----------------------

nick.override_state = {
    baim = nil,
    safepoint = nil,
    hitboxes = {},
    multipoint = {}
}

nick.update_override_state = function()
    local body_aim = nick.ref.ragebot.baim
    local safe_point = nick.ref.ragebot.safepoint
    local hitboxes = nick.ref.ragebot.hitboxes
    local multipoint = nick.ref.ragebot.multipoint

    if nick.override_state.baim or (nick.elements.global_safety.body_aim and nick.elements.global_safety.body_aim:get()) then
        body_aim:override("Force")
    else
        body_aim:override()
    end

    if nick.override_state.safepoint or (nick.elements.global_safety.safe_point and nick.elements.global_safety.safe_point:get()) then
        safe_point:override("Force")
    else
        safe_point:override()
    end

    if #nick.override_state.hitboxes > 0 then
        hitboxes:override(table.unpack(nick.override_state.hitboxes))
    elseif nick.elements.global_safety.onlyhead and nick.elements.global_safety.onlyhead:get() then
        hitboxes:override("Head")
    else
        hitboxes:override()
    end

    if #nick.override_state.multipoint > 0 then
        multipoint:override(table.unpack(nick.override_state.multipoint))
    elseif nick.elements.global_safety.onlyhead and nick.elements.global_safety.onlyhead:get() then
        multipoint:override("Head")
    else
        multipoint:override()
    end
end

------------------------ Features --------------------------

nick.anti_ax = function ()
    cvar["cl_lagcompensation"]:int(nick.items.ragebot.ax:get() and 0 or 1)
end

nick.os_peek = function ()
    local localplayer = entity.get_local_player()
    if not localplayer then return end

    local my_weapon = localplayer:get_player_weapon()
    if not my_weapon then return end

    local last_shot_time = my_weapon["m_fLastShotTime"]
    local time_difference = globals.curtime - last_shot_time

    if nick.elements.os_peek.breaklc:get() then
        nick.ref.ragebot.hs_options:override("Break LC")
    else
        nick.ref.ragebot.hs_options:override()
    end

    if nick.items.ragebot.os_peek:get() then
        nick.ref.ragebot.autopeek:override(true)
        if time_difference <= 0.5 and time_difference >= 0.255 then
            nick.ref.ragebot.hs:override(false)
        elseif time_difference >= 0.5 then
            nick.ref.ragebot.hs:override(true)
        end
    else
        nick.ref.ragebot.hs_options:override()
        nick.ref.ragebot.autopeek:override()
        nick.ref.ragebot.hs:override()
    end
end

nick.jumpscout_fix = function ()
    local localplayer = entity.get_local_player()
    if not localplayer then return end

    nick.ref.misc.air_strafe:override(nil)
    
    local vel = localplayer.m_vecVelocity
    local speed = math.sqrt(vel.x * vel.x + vel.y * vel.y)

    if nick.items.ragebot.jump_scout:get() then
        nick.ref.misc.air_strafe:override(math.floor(speed) > 15)
    end
end

nick.global_safety = function ()
    if nick.elements.global_safety.safe_point:get() then
        nick.override_state.safepoint = true
    else
        nick.override_state.safepoint = false
    end

    if nick.elements.global_safety.body_aim:get() then
        nick.override_state.baim = true
        nick.override_state.hitboxes = {"Chest", "Stomach"}
        nick.override_state.multipoint = {"Chest", "Stomach"}
    else
        nick.override_state.baim = false
        nick.override_state.hitboxes = {}
        nick.override_state.multipoint = {}
    end

    if nick.elements.global_safety.onlyhead:get() then
        nick.override_state.hitboxes = {"Head"}
        nick.override_state.multipoint = {"Head"}
    end

    nick.update_override_state()
end

nick.defensive_aa = function ()
    if rage.exploit:get() ~= 1 then return end

    local localplayer = entity.get_local_player()
    if not localplayer then return end

    if not nick.items.antiaim.defensive:get() then
        nick.ref.antiaim.hidden:override()
        nick.ref.antiaim.fs:override()
        nick.ref.ragebot.lag_options:override()
        return
    end

    local pitch_settings = nick.elements.defensive.pitch:get()
    local yaw_settings = nick.elements.defensive.yaw:get()
    local in_air = nick.elements.defensive.inair:get()
    local prop = localplayer["m_fFlags"]
    local flick_clock = (math.floor(globals.curtime * 10000) % 2) == 0

    local pitch_o = ({
        ["Zero"] = 0,
        ["Up"] = -89,
        ["Down"] = 89,
        ["Random"] = math.random(-89, 89),
        ["Jitter"] = flick_clock and -89 or 89,
        ["45 deg"] = flick_clock and -45 or 89,
        ["Custom"] = nick.elements.defensive.pitch_custom:get()
    })[pitch_settings] or 0

    local yaw_o = ({
        ["Static"] = -nick.elements.defensive.yaw_custom:get(),
        ["Jitter"] = (function()
            local yaw_value = nick.elements.defensive.yaw_custom:get()
            local jitter_value = nick.elements.defensive.yaw_jitter:get()
            if nick.elements.defensive.yaw_jitter_mode:get() == "Center" then
                return flick_clock and (yaw_value - jitter_value) or (yaw_value + jitter_value)
            else
                return flick_clock and yaw_value or yaw_value - jitter_value
            end
        end)(),
        ["Random"] = math.random(-180, 180),
        ["Side-Way"] = flick_clock and 89 or -89,
        ["Spin"] = (globals.tickcount * nick.elements.defensive.spin:get()) % 360 - 180
    })[yaw_settings] or 0

    nick.ref.antiaim.hidden:override(true)
    rage.antiaim:override_hidden_pitch(pitch_o)
    if yaw_settings ~= "Default" then
        rage.antiaim:override_hidden_yaw_offset(yaw_o)
    end

    if in_air and (prop == 257 or prop == 263) then
        nick.ref.ragebot.lag_options:override(nil)
    else
        nick.ref.ragebot.lag_options:override("Always On")
    end
end

nick.slientshots = function (cmd)
    local localplayer = entity.get_local_player()
    if not localplayer then return end

    local my_weapon = localplayer:get_player_weapon()
    if not my_weapon then return end

    if not nick.items.fakelag.slientshots:get() then return end

    local last_shot_time = my_weapon["m_fLastShotTime"]
    local time_difference = globals.curtime - last_shot_time
    local mode = nick.elements.slientshots.mode:get()

    if time_difference <= 0.025 then
        if mode == "Overrides" then
            nick.ref.antiaim.bodyyaw:override(false)
            nick.ref.antiaim.fl_enabled:override(false)
            nick.ref.antiaim.limit:override(1)
        elseif mode == "Send packets" then
            cmd.no_choke = true
        end
    else
        nick.ref.antiaim.bodyyaw:override()
        nick.ref.antiaim.fl_enabled:override()
        nick.ref.antiaim.limit:override()
    end
end

nick.manual_aa = function ()
    if nick.items.antiaim.defensive:get() and nick.ref.ragebot.dt:get() then return end

    local manual_aa = nick.items.antiaim.manual:get()
    local yaw_override = "Backward"
    local base_override = "Local View"
    local offset_override = 0
    local fs_override = false

    if manual_aa == "Left" then
        offset_override = -90
    elseif manual_aa == "Backwards" then
        offset_override = 0
    elseif manual_aa == "Right" then
        offset_override = 90
    elseif manual_aa == "Forward" then
        offset_override = 180
    elseif manual_aa == "Freestanding" then
        fs_override = true
    elseif manual_aa == "None" then
        yaw_override = nil
        base_override = nil
        offset_override = nil
        fs_override = nil
    end

    nick.ref.antiaim.yaw:override(yaw_override)
    nick.ref.antiaim.base:override(base_override)
    nick.ref.antiaim.offset:override(offset_override)
    nick.ref.antiaim.fs:override(fs_override)
end

nick.air_exploit = function ()
    local localplayer = entity.get_local_player()
    if not localplayer then return end

    reset = false

    if not nick.ref.ragebot.dt:get() then 
        if reset then
            nick.ref.antiaim.fd:override(nil)
            nick.ref.antiaim.limit:override(nil)
        end
 
    return end

    if nick.items.antiaim.air_exploit:get() then
		nick.ref.antiaim.limit:override(17)
        nick.ref.antiaim.fd:override(globals.tickcount % nick.elements.air_exploit.ticks:get() == 0 and true or false)
        reset = true
    else
        nick.ref.antiaim.fd:override(nil)
        nick.ref.antiaim.limit:override(nil)
    end
end

nick.thrid_person_camera = function ()

    local distance = nick.elements.thridperson.distance:get()
    local thrid_person = nick.ref.world.thridperson:get()
    local nl_distance = nick.ref.world.distance

    local dist = nick.math_new_lerp("thrid_camera", thrid_person and distance or 0, globals.frametime * 15)

    if nick.elements.thridperson.animation:get() then
        nl_distance:set(dist)
    else
        nl_distance:set(distance)
    end

end

nick.custom_viewmodel = function ()
    viewmodel = nick.elements.viewmodel
    x = viewmodel.x:get()
    y = viewmodel.y:get()
    z = viewmodel.z:get()
    fov = viewmodel.fov:get()
    aspectratio = viewmodel.aspectratio:get()

    -- cvar["viewmodel_fov"]:string("def.") will break cheat that is my unexpected.
    -- i realized i need to use ``utils.console_exec`` to set 'def.' value.
    if not nick.items.visuals.viewmodel:get() then
        cvar["sv_competitive_minspec"]:int()
        cvar["viewmodel_fov"]:int(68)
        cvar["viewmodel_offset_x"]:int(0)
        cvar["viewmodel_offset_y"]:int(0)
        cvar["viewmodel_offset_z"]:int(0)
        return
    end

    cvar["sv_competitive_minspec"]:int(1)
    cvar["viewmodel_fov"]:float(fov, true)
    cvar["viewmodel_offset_x"]:float(x / 10, true)
    cvar["viewmodel_offset_y"]:float(y / 10, true)
    cvar["viewmodel_offset_z"]:float(z / 10, true)
    cvar["r_aspectratio"]:float(aspectratio / 10)

end

nick.debug_mode = function ()  -- not for debug this script
    if not nick.items.visuals.debug:get() then return end

    local elements = {
        ["Feet Yaw"] = nick.elements.debug.list:get("Feet Yaw"),
        ["Choked Commands"] = nick.elements.debug.list:get("Choked Commands"),
        ["Real Yaw"] = nick.elements.debug.list:get("Real Yaw"),
        ["Abs Yaw"] = nick.elements.debug.list:get("Abs Yaw"),
        ["Desync"] = nick.elements.debug.list:get("Desync"),
        ["Threat"] = nick.elements.debug.list:get("Threat"),
        ["Exploit charge"] = nick.elements.debug.list:get("Exploit charge"),
    }

    local x,y = render.screen_size().x,render.screen_size().y
    local time_h = string.format("%02d", common.get_system_time().hours)
    local time_m = string.format("%02d", common.get_system_time().minutes)
    local time_s = string.format("%02d", common.get_system_time().seconds)
    local time = time_h .. ":" .. time_m .. ":" .. time_s

    if nick.elements.debug.watermark:get() then
        if not globals.is_in_game or not globals.is_connected then
            render.text(1, vector(5, y - 15), color(255,255,255), "", "neverlose.cc - \a4FFF1EFFclient version:".. common.get_product_version() .. "\aDEFAULT / " .. common.get_username() .. " [Debug Mode] " .. time .. "")
        else
            render.text(1, vector(10, y - 15), color(255,255,255), "", "neverlose.cc - \a4FFF1EFFclient version:".. common.get_product_version() .. "\aDEFAULT / " .. common.get_username() .. " [Debug Mode] " .. time .. " info: " .. utils.net_channel():get_server_info().address .. " | " .. utils.net_channel():get_server_info().name)
        end
    end

    if not entity.get_local_player() then return end
    if not globals.is_in_game or not globals.is_connected then return end
    local DesyncAngle = math.ceil(math.abs(normalize_yaw(entity.get_local_player():get_anim_state().eye_yaw % 360 - math.floor(entity.get_local_player():get_anim_state().abs_yaw) % 360)))

    local i = 0
    for element, value in pairs(elements) do
        if value then
            local position = vector(300, y - 800 + (15 * i))
            local text = ""
            
            if element == "Feet Yaw" then
                text = "Feet Yaw: " .. math.floor(entity.get_local_player().m_flPoseParameter[11] == nil and 0 or entity.get_local_player().m_flPoseParameter[11] * 120 - 60) or "Unknown ?"
            elseif element == "Choked Commands" then
                text = "Choke: " .. globals.choked_commands
            elseif element == "Real Yaw" then
                text = "Real yaw: " .. math.floor(entity.get_local_player():get_anim_state().eye_yaw)
            elseif element == "Abs Yaw" then
                text = "Abs yaw: " .. math.floor(entity.get_local_player():get_anim_state().abs_yaw)
            elseif element == "Desync" then
                text = "Desync: " .. DesyncAngle
            elseif element == "Threat" then
                text = entity.get_threat() and "Threat: " .. entity.get_threat():get_name() or "none"
            elseif element == "Exploit charge" then
                text = "Exploit charge: " .. math.floor(rage.exploit:get() * 100) .. "%"
            end
            render.text(1, position, color(255, 255, 255), "", text)
            i = i + 1
        end
    end
end

nick.event_sound = new_class()
    :struct 'main' {
        missed = function (event)
            if event.state ~= nil then
                if not nick.items.visuals.event_sound:get() then return end
    
                if not nick.elements.event_sound.event:get("Missed shot") then return end
    
                local file = nick.elements.event_sound.miss_file:get()
                local volume = nick.elements.event_sound.volume:get()
                PlaySound(file, volume)
            end
        end,

        taser = function (event)
            local localplayer = entity.get_local_player()
            if not localplayer then return end
            if entity.get(event.attacker, true) ~= localplayer then return end
            if event.weapon ~= "taser" then return end
            if not nick.elements.event_sound.event:get("Taser kill") then return end

            local file = nick.elements.event_sound.miss_file:get()
            local volume = nick.elements.event_sound.volume:get()
            PlaySound(file, volume)
        end
    }

local font = render.load_font("c:/windows/fonts/calibrib.ttf", 25, "ad")

nick.indicator = function ()
    if not nick.items.visuals.indicator:get() then return end

    local x, y = render.screen_size().x, render.screen_size().y
    local localplayer = entity.get_local_player()
    if not localplayer then return end

    local elements = nick.elements.indicator.left
    local prop = localplayer["m_fFlags"]
    local inair = not (prop == 257 or prop == 263)
    local exploit_color = (rage.exploit:get() == 1) and color("#cccccd") or color(255, 0, 0, 255)
    local slowdown = entity.get_local_player().m_flVelocityModifier
    local fade_factor = ((1 / .15) * globals.frametime) * 255
    local vel = localplayer.m_vecVelocity
    local speed = math.sqrt(vel.x * vel.x + vel.y * vel.y)
    local dmg = ui.find("Aimbot", "Ragebot", "Selection", "Min. Damage"):get()
    local hc = ui.find("Aimbot", "Ragebot", "Selection", "Hit Chance"):get()
    local offset = 1
    local alpha = nick.math_new_lerp("alpha_slowdown", (nick.elements.indicator.slow_down:get() and localplayer:is_alive() and (ui.get_alpha() == 1 or math.floor(slowdown * 100 + 0.5) ~= 100)) and 255 or 0, globals.frametime * 20)
    local slow_down = nick.color_picker.slow_down:get()

    local function draw_indicator(text, color_, offset)
        render.gradient(vector(15, y / 2 + 25 + (40 * offset)), vector(40, y / 2 + 58 + (40 * offset)), color(100, 100, 100, 0), color(100, 100, 100, 100), color(100, 100, 100, 0), color(100, 100, 100, 100))
        render.gradient(vector(40, y / 2 + 25 + (40 * offset)), vector(60, y / 2 + 58 + (40 * offset)), color(100, 100, 100, 100), color(100, 100, 100, 0), color(100, 100, 100, 100), color(100, 100, 100, 0))
        render.text(font, vector(25, y / 2 + 30 + (40 * offset)), color_, "", text)
    end

    if nick.elements.indicator.crosshair:get() then
        render.text(1, vector(x / 2 - 110, y / 2 - 15), color("FFFFFF"), "", "" .. ui.find("Aimbot", "Ragebot", "Selection", "Hit Chance"):get())
        render.text(1, vector(x / 2 + 100, y / 2 - 15), color("FFFFFF"), "", "" .. ui.find("Aimbot", "Ragebot", "Selection", "Min. Damage"):get())
    end

    render.shadow(vector(x/2 - 120,y / 2 - 333), vector(x/2 + 120,y / 2 - 325), color(slow_down.r, slow_down.g, slow_down.b, alpha),20,0,1)
    render.rect_outline(vector(x/2 - 120,y / 2 - 333), vector(x/2 + 120,y / 2 - 325), color(0,0,0, alpha), 1.2, 3)
    render.rect(vector(x/2 - 119,y / 2 - 332), vector(x/2 + slowdown * (119 - (-119)) + (-119) ,y / 2 - 326), color(slow_down.r, slow_down.g, slow_down.b, alpha), 3)
    render.text(1, vector(x / 2, y / 2 - 345), color(slow_down.r, slow_down.g, slow_down.b, alpha), "c", ui.get_icon("triangle-exclamation") .. " Slowed Down: " .. math.floor(slowdown * 100 + 0.5) .. "%")

    if elements:get("Double Tap & Hide Shots") then
        if nick.ref.ragebot.dt:get() then
            draw_indicator("DT", exploit_color, offset)
            offset = offset + 1
        elseif nick.ref.ragebot.hs:get() then
            draw_indicator("HS", exploit_color, offset)
            offset = offset + 1
        end
    end

    if elements:get("Fake Duck") and nick.ref.antiaim.fd:get() then
        draw_indicator("FD", color("#cccccd"), offset)
        offset = offset + 1
    end

    if elements:get("DA") and nick.ref.ragebot.da:get() then
        draw_indicator("DA", color("#FFD65A"), offset)
        offset = offset + 1
    end

    if elements:get("AX") and nick.items.ragebot.ax:get() then
        draw_indicator("AX", color("#FFD65A"), offset)
        offset = offset + 1
    end

    if elements:get("DMG") then
        draw_indicator("D:"..dmg, color("#cccccd"), offset)
        offset = offset + 1
    end

    if elements:get("HC") then
        draw_indicator("H:"..hc, color("#cccccd"), offset)
        offset = offset + 1
    end

    if elements:get("LC") and inair then
        local lc_color = (speed >= 270 and globals.choked_commands > 2) and color("#7fbd14") or color(255, 0, 0, 255)
        draw_indicator("LC", lc_color, offset)
        offset = offset + 1
    end
end

nick.fast_fall = function ()
    if not nick.items.misc.fast_fall:get() then return end

    local localplayer = entity.get_local_player()
    if not localplayer then return end

    if localplayer.m_vecVelocity.z > -480 then return end

    if nick.get_trace(75) then rage.exploit:force_teleport() end
end

nick.clan_tag = function ()
    if not nick.items.misc.clan_tag:get() then 
        nick.ref.misc.clan_tag:override()
    return end

    local style = nick.elements.clan_tag.style:get()
    local text = nick.elements.clan_tag.text:get()
    local custom_style = nick.elements.clan_tag.custom_style:get()
    local speed = nick.elements.clan_tag.speed:get()

    if style == "Neverlose" then
        nick.ref.misc.clan_tag:override(true)
    else
        if custom_style == "Static" then
            common.set_clan_tag(text)
        elseif custom_style == "Roll" then
            local tag_length = #text
            local tickcount = globals.tickcount
            local interval = math.floor(500 / speed)
            local index = math.floor(tickcount / interval) % (tag_length * 2 + 10)
    
            if index >= tag_length then
                if index < tag_length * 2 then
                    index = tag_length
                else
                    index = tag_length * 2 - index + 10
                end
            end
    
            common.set_clan_tag(text:sub(1, index))
        end
    end
end

nick.trashtalk = function(event)
    if not nick.items.misc.trashtalk:get() then return end

    local target = event.target
    local get_target_entity = entity.get(target)
    if not get_target_entity then return end

    local health = get_target_entity.m_iHealth
    
    if not target:get_name() or not health then return end
    if health ~= 0 then return end

    local text = nick.elements.trashtalk.text:get()
    local check = nick.elements.trashtalk.check:get()
    local username = target:get_name()

    if check then
        text = text:gsub("%%s", username)
    end

    if text == "" then return end

    utils.console_exec("say " .. text) 
end

-- @ vote reveals
nick.vote_reveals_started = function (event)
    if not nick.items.misc.vote_reveals:get() then return end

    print(string.format("Vote started! ~ %s initiated by %s", event.issue, entity.get(event.initiator, true):get_name()))
    print_dev(string.format("Vote started! ~ %s initiated by %s", event.issue, entity.get(event.initiator, true):get_name()))
end

nick.vote_reveals_cast = function(event)
    if not nick.items.misc.vote_reveals:get() then return end

    local voteOption = event.vote_option == 0 and "YES" or "NO"

    local user = entity.get(event.entityid)
    local userName = user:get_name()

    print(("%s voted %s"):format(userName, voteOption))
    print_dev(("%s voted %s"):format(userName, voteOption))
end

nick.modifier = function ()
    if nick.items.misc.modifier:get("Force sv_cheats 1") then
        cvar["sv_cheats"]:int(1)
    else
        cvar["sv_cheats"]:int()
    end

    if nick.items.misc.modifier:get("Bypass sv_pure") then
        cvar["sv_pure"]:int(0)
    else
        cvar["sv_pure"]:int()
    end

    if nick.items.misc.modifier:get("Performance Mode") then
        cvar["mat_queue_mode"]:int(2) -- idk what is this, github copilot do this. for queue/thread mode the material system should use
        cvar["fps_max"]:int(0)
        cvar["fps_max_menu"]:int(0)
        cvar["@panorama_disable_blur"]:int(1)
    else
        cvar["mat_queue_mode"]:int()
        cvar["fps_max"]:int()
        cvar["fps_max_menu"]:int()
        cvar["@panorama_disable_blur"]:int(0)
    end
end

nick.disable_buybot = function ()
    if not nick.items.misc.disable_buybot:get() then return end

    local localplayer = entity.get_local_player()
    if not localplayer then return end

    if localplayer.m_iAccount <= nick.elements.disable_buybot.money:get() then
        nick.ref.misc.buybot_enabled:override(false)
    else
        nick.ref.misc.buybot_enabled:override(nil)
    end
end

-- Create switches for each player
nick.highlight_switches = {}
nick.safepoint_switches = {}
nick.bodyaim_switches = {}
nick.whilelist_switches = {}

nick.plist = function ()
    local players = entity.get_players(true, true)
    local plist = {}
    local previous_count = #nick.elements.plist.list:list()
    local current_count = #players

    if previous_count ~= current_count then
        for i = 1, current_count do
            local player = players[i]
            local player_name = player:get_name()
            table.insert(plist, player_name)
            if not nick.highlight_switches[player_name] then
                nick.highlight_switches[player_name] = nick.items.plist:switch("Highlight this player"):visibility(false):tooltip(nick.tooltips_text.plist_highlight)
            end
            if not nick.safepoint_switches[player_name] then
                nick.safepoint_switches[player_name] = nick.items.plist:switch("Force Safe point this player"):visibility(false)
            end
            if not nick.bodyaim_switches[player_name] then
                nick.bodyaim_switches[player_name] = nick.items.plist:switch("Force Body aim this player"):visibility(false)
            end
            if not nick.whilelist_switches[player_name] then
                nick.whilelist_switches[player_name] = nick.items.plist:switch("Whitelist"):visibility(false):tooltip(nick.tooltips_text.plist_whitelist)
            end
        end
        nick.elements.plist.list:update(plist)
    else
        plist = nick.elements.plist.list:list()
    end

    local selected_id = nick.elements.plist.list:get()
    if selected_id and selected_id > 0 and selected_id <= #plist then
        local selected_player_name = plist[selected_id]

        for player_name, switch in pairs(nick.highlight_switches) do
            if player_name == selected_player_name then
                switch:visibility(true)
            else
                switch:visibility(false)
            end
        end

        for player_name, switch in pairs(nick.safepoint_switches) do
            if player_name == selected_player_name then
                switch:visibility(true)
            else
                switch:visibility(false)
            end
        end

        for player_name, switch in pairs(nick.bodyaim_switches) do
            if player_name == selected_player_name then
                switch:visibility(true)
            else
                switch:visibility(false)
            end
        end

        for player_name, switch in pairs(nick.whilelist_switches) do
            if player_name == selected_player_name then
                switch:visibility(true)
            else
                switch:visibility(false)
            end
        end
    else
        for _, switch in pairs(nick.highlight_switches) do
            switch:visibility(false)
        end

        for _, switch in pairs(nick.safepoint_switches) do
            switch:visibility(false)
        end

        for _, switch in pairs(nick.bodyaim_switches) do
            switch:visibility(false)
        end

        for _, switch in pairs(nick.whilelist_switches) do
            switch:visibility(false)
        end
    end

    local threat_player = entity.get_threat(true)
    local threat_name = threat_player and threat_player:get_name() or ""

    nick.override_state.baim = false
    nick.override_state.safepoint = false
    nick.override_state.hitboxes = {}
    nick.override_state.multipoint = {}

    for player_name, switch in pairs(nick.bodyaim_switches) do
        if switch:get() and player_name == threat_name then
            nick.override_state.baim = true
            nick.override_state.hitboxes = {"Chest", "Stomach"}
            nick.override_state.multipoint = {"Chest", "Stomach"}
        end
    end

    for player_name, switch in pairs(nick.safepoint_switches) do
        if switch:get() and player_name == threat_name then
            nick.override_state.safepoint = true
        end
    end

    nick.update_override_state()
    
    for player_name, switch in pairs(nick.whilelist_switches) do
        for _, player in ipairs(players) do
            if player:get_name() == player_name then
                if switch:get() then
                    if player.m_iHealth ~= 0 then
                        player.m_iHealth = 0
                    end
                else
                    if player.m_iHealth == 0 then
                        player.m_iHealth = 100
                    end
                end
            end
        end
    end


end

local highlight = esp.enemy:new_text("Highlight", "HIGHLIGHT", function(player)
    local name = player:get_name()

    if nick.highlight_switches[name] and nick.highlight_switches[name]:get() then
        return "HIGHLIGHT"
    end
end)

------------------------ UPDATED ----------------------------

local http = http_lib.new({
    task_interval = 0.3, -- polling intervals
    enable_debug = false, -- print http request s to the console
    timeout = 10 -- request expiration time
})

nick.check_update = function ()
    http:get("https://raw.githubusercontent.com/xXN1ckWa1k3rXx/cheat_lua/refs/heads/main/better%20neverlose/version.json", function(data)
        if data:success() and data.status == 200 and data.body then
            local data_decoded = json.parse(data.body)
            if version_ == data_decoded.version then
                print("You are using the latest version")
                print_dev("You are using the latest version")
            else
                print("new version available - " .. data_decoded.version)
                print_dev("new version available - " .. data_decoded.version)
            end
        end
    end)
end


------------------------ callbacks --------------------------

events.createmove:set(function(cmd)
    nick.os_peek()
    nick.jumpscout_fix()
    nick.defensive_aa()
    nick.slientshots(cmd)
    nick.manual_aa()
    nick.air_exploit()
    nick.fast_fall()
    nick.disable_buybot()
    nick.clan_tag()
    
end)

events.render:set(function()
    nick.menu_visible()
    nick.thrid_person_camera()
    nick.debug_mode()
    nick.indicator()
    nick.modifier()
    nick.plist(event)
end)

events.aim_ack:set(function(event)
    nick.event_sound.main.missed(event)
    nick.trashtalk(event)
end)

events.player_hurt:set(function(event)
    nick.event_sound.main.taser(event)
end)

events.vote_started:set(function(event)
    nick.vote_reveals_started(event)
end)

events.vote_cast:set(function(event)
    nick.vote_reveals_cast(event)
end)

events.shutdown:set(function()
    cvar["cl_lagcompensation"]:int()
    cvar["sv_competitive_minspec"]:int()
    cvar["viewmodel_fov"]:int()
    cvar["viewmodel_offset_x"]:int()
    cvar["viewmodel_offset_y"]:int()
    cvar["viewmodel_offset_z"]:int()
    cvar["sv_cheats"]:int()
    cvar["sv_pure"]:int()
    cvar["mat_queue_mode"]:int()
    cvar["fps_max"]:int()
    cvar["fps_max_menu"]:int()
    cvar["@panorama_disable_blur"]:int(0)
end)

nick.items.ragebot.ax:set_callback(nick.anti_ax)

nick.elements.global_safety.safe_point:set_callback(nick.global_safety)
nick.elements.global_safety.body_aim:set_callback(nick.global_safety)
nick.elements.global_safety.onlyhead:set_callback(nick.global_safety)
nick.items.visuals.viewmodel:set_callback(nick.custom_viewmodel)

nick.elements.viewmodel.x:set_callback(nick.custom_viewmodel)
nick.elements.viewmodel.y:set_callback(nick.custom_viewmodel)
nick.elements.viewmodel.z:set_callback(nick.custom_viewmodel)
nick.elements.viewmodel.fov:set_callback(nick.custom_viewmodel)
nick.elements.viewmodel.aspectratio:set_callback(nick.custom_viewmodel)

nick.items.misc.modifier:set_callback(nick.modifier)