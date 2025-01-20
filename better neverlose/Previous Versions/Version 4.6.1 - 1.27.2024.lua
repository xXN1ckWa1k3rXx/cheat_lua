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
    Better Neverlose Recode v4
    Project owner: xXYu3_zH3nGL1ngXx
    Updated date: 1/27/2024
]]

local version = "1/27/2024 - 4.6.1"
_DEBUG = true

----------------------- FFI CODE ---------------------
local ffi = require("ffi")

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

------------------------------------------------------

local urlmon = ffi.load 'UrlMon'
local wininet = ffi.load 'WinInet'

print_dev("Welcome use " .. version)

local nick = {} -- You can't replace/change this name
local Elysia = {} -- lol, just don't edit this table name

local weapons = {"Global","SSG-08","Pistols","AutoSnipers","Snipers","Rifles","SMGs","Shotguns","Machineguns","AWP","AK-47","M4A1/M4A4","Desert Eagle","R8 Revolver","AUG/SG 553","Taser"}
local ui_ragebot = {}
nick.data = {}

nick.ref = {
    ["ragebot"] = {
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
    ["antiaim"] = {
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
    ["world"] = {
        main = ui.find("Visuals", "World", "Main"),
        other = ui.find("Visuals", "World", "Other"),
    },
    ["misc"] = {
        movement = ui.find("Miscellaneous", "Main", "Movement"),
        in_game = ui.find("Miscellaneous", "Main", "In-Game"),
        other = ui.find("Miscellaneous", "Main", "Other"),
        air_strafe = ui.find("Miscellaneous", "Main", "Movement", "Air Strafe"),
    }
}

nick.ragebot_item = function ()

    for i, v in ipairs(weapons) do
        ui_ragebot[i] = {
            only_head = ui.find("Aimbot", "Ragebot", "Safety", v):switch("Only Head"),
            baim = ui.find("Aimbot", "Ragebot", "Safety", v):switch("Force Baim"),
            safe = ui.find("Aimbot", "Ragebot", "Safety", v):switch("Force Safe Point"),
        }
    end

end

ui.sidebar("Better Neverlose", "star")
  
nick.menu = {
    ["ragebot"] = {
        tp = nick.ref.ragebot.main:switch("Teleport on Key (BIND)"):tooltip("Bind a key. Exploits charged and press key to teleport"),
        ax = nick.ref.ragebot.main:switch("\aF7FF8FFFAnti Defensive"):tooltip("Disabling lag compensation will allow to hit players which using defensive/lag-peek exploit.\n\nIt affects ragebot accuracy, avoid using it on high ping/head shot weapons\n\n\aF7FF8FFFTip: Does not bypass cl_lagcompensation detection, this operation may not be supported on some servers"),
        os_peek = nick.ref.ragebot.main:switch("OS Peek"):tooltip("Safety lag peek\n\nTeleport a short ticks in shooting"),
        jumpscout = nick.ref.ragebot.accuracy:switch("Jumpscout"):tooltip("Allow to static jump to stabilize accuracy"),
    },
    ["antiaim"] = {
        defensive = nick.ref.antiaim.angles:switch("Defensive Anti Aim"):tooltip("Breaking LC to break backtrack and jitter your head yaw\n\nMake it harder for enemies to hit you in the head"),
        alwayschoke = nick.ref.antiaim.fakelag:switch("Always Chock"):tooltip("Disabled variability jitter send packet"):disabled(true),
        flonshot = nick.ref.antiaim.fakelag:switch("Slient shots"):tooltip("A.K.A No fakelag on shots\n\nForce send packet while every shots"),
        manualaa = nick.ref.antiaim.misc:combo("Manual AA", {"None", "Left", "Backwards", "Right", "Forwards", "Freestanding"}):tooltip("\a698EFFFF" .. ui.get_icon("triangle-exclamation") .. " If you need to use Fake Flick, it is strongly recommended that you bind the keys, otherwise the settings will be messed up"),
        air_exploit = nick.ref.antiaim.misc:switch("Air Exploits"):tooltip("You need to bind it and use it"),
    },
    ["world"] = {
        viewmodel = nick.ref.world.main:switch("Custom Viewmodel"):tooltip("Allow to change viewmodel fov"),
        debug = nick.ref.world.main:switch("\a698EFFFF" .. ui.get_icon("triangle-exclamation") .. " Debug Mode"),
        misssound = nick.ref.world.other:switch("Missed sound"):tooltip("Play sound when missed shot\n\nPut the files in [csgo folder]/sound"),
        indicator = nick.ref.world.other:switch("Indicators")
    },
    ["misc"] = {
        fast_fall = nick.ref.misc.movement:switch("Fast Fall"),
        sv_cheat = nick.ref.misc.other:switch("Force sv_cheats"):tooltip("Unlock some client commands need sv_cheats 1"),
        sv_pure  = nick.ref.misc.other:switch("Bypass sv_pure"):tooltip("Bypass server checking local game files\n\nThat's allow you to use thrid-party model files in official server or enabled sv_pure server"),
        killsay  = nick.ref.misc.in_game:switch("Trashtalk on kill"):tooltip("Say something nonsense talk while kill a enemy"),
        vote     = nick.ref.misc.in_game:switch("Vote reveals"):tooltip("Print the voting information on the console")
    },
    group = ui.create("Main"),
}

nick.CreateElements = {
    ["ragebot"] = {
        ospeek = nick.menu.ragebot.os_peek:create(),
        dt = nick.ref.ragebot.dt:create(),
    },
    ["antiaim"] = {
        defensive = nick.menu.antiaim.defensive:create(),
        alwayschoke = nick.menu.antiaim.alwayschoke:create(),
        slientshots = nick.menu.antiaim.flonshot:create(),
    },
    ["world"] = {
        viewmodel = nick.menu.world.viewmodel:create(),
        debug = nick.menu.world.debug:create(),
        missed = nick.menu.world.misssound:create(),
        indicator = nick.menu.world.indicator:create(),
    },
    ["misc"] = {
        killsay = nick.menu.misc.killsay:create(),
    }
}

nick.Elements = {
    ["ospeek"] = {
        breaklc = nick.CreateElements.ragebot.ospeek:switch("Break LC"):tooltip("Breaking backtrack"),
    },
    ["defensive"] = {
        pitch = nick.CreateElements.antiaim.defensive:combo("Pitch", {"Zero", "Up", "Down", "Random", "Jitter", "45 deg", "Custom"}),
        pitch_custom = nick.CreateElements.antiaim.defensive:slider("Pitch", -86, 86, 0),
        yaw = nick.CreateElements.antiaim.defensive:combo("Yaw", {"Static", "Jitter", "Random", "Side-Way", "Spin"}),
        yaw_custom = nick.CreateElements.antiaim.defensive:slider("Yaw", -180, 180, 0),
        yaw_jitter_mode = nick.CreateElements.antiaim.defensive:combo("Jitter Mode", "Offset", "Center"),
        yaw_jitter = nick.CreateElements.antiaim.defensive:slider("Jitter", -180, 180, 0),
        inair = nick.CreateElements.antiaim.defensive:switch("Only In air"),
        spin = nick.CreateElements.antiaim.defensive:slider("Spin speed", 120, 7200, 1300),
    },
    ["alwayschoke"] = {
        mode = nick.CreateElements.antiaim.alwayschoke:combo("Mode", {"Limit", "Maxmium"}),
    },
    ["slientshots"] = {
        mode = nick.CreateElements.antiaim.slientshots:combo("Mode", "Overrides", "Send packets"),
    },
    ["miss_sound"] = {
        files = nick.CreateElements.world.missed:input("File name"),
        volume = nick.CreateElements.world.missed:slider("Volume", 0, 100, 70),
    },
    ["viewmodel"] = {
        fov = nick.CreateElements.world.viewmodel:slider("Fov", 0, 100, 90),
        x = nick.CreateElements.world.viewmodel:slider("X", - 15, 15, 0),
        y = nick.CreateElements.world.viewmodel:slider("Y", - 15, 15, 0),
        z = nick.CreateElements.world.viewmodel:slider("Z", - 15, 15, 0),
        aspectratio = nick.CreateElements.world.viewmodel:slider("Aspect Ratio", 0, 100, 0, 0.1),
    },
    ["debug"] = {
        watermark = nick.CreateElements.world.debug:switch("Watermark"),
        list = nick.CreateElements.world.debug:listable("Elements", {"Feet Yaw", "Choked Commands", "Real Yaw", "Abs Yaw", "Desync"}),
    },
    ["trashtalk"] = {
        text = nick.CreateElements.misc.killsay:input("Text"),
        check = nick.CreateElements.misc.killsay:switch("Add username"),
        test = nick.CreateElements.misc.killsay:label("\a698EFFFF" .. ui.get_icon("triangle-exclamation") .. " add username needs to be typed with a %s in the text, no more. Otherwise the script will crash, this is to let the user decide where to let the victim's name appear")
    },
    ["indicator"] = {
        crosshair = nick.CreateElements.world.indicator:switch("Crosshair"),
        slow_down = nick.CreateElements.world.indicator:switch("Slow Down Indicator"),
        left = nick.CreateElements.world.indicator:listable("Elements", {"Double Tap & Hide Shots", "Fake Duck", "DA", "AX", "DMG", "HC", "LC"}),
    },
    ["tp"] = {
        tp = nick.CreateElements.ragebot.dt:switch("Automatic Teleport"),
        inair = nick.CreateElements.ragebot.dt:switch("Auto Teleport in Air"),
    },
    ["group"] = {
        nick.menu.group:label("Hello, " .. common.get_username() .. "\n" .. "Current version: " .. version),
        check_update = nick.menu.group:button("Check for Update", function() nick.update_check() end),
    }
}

nick.menu_visible = function ()
    nick.Elements.defensive.pitch_custom:visibility(nick.Elements.defensive.pitch:get() == "Custom")
    nick.Elements.defensive.yaw_custom:visibility(nick.Elements.defensive.yaw:get() == "Static" or nick.Elements.defensive.yaw:get() == "Jitter")
    nick.Elements.defensive.spin:visibility(nick.Elements.defensive.yaw:get() == "Spin")
    nick.Elements.defensive.yaw_jitter_mode:visibility(nick.Elements.defensive.yaw:get() == "Jitter")
    nick.Elements.defensive.yaw_jitter:visibility(nick.Elements.defensive.yaw:get() == "Jitter")
end

nick.Elements.indicator.slow_down_color = nick.Elements.indicator.slow_down:color_picker("")

nick.CffiHelper = {
    PlaySound = (function()
		local PlaySound = utils.get_vfunc("engine.dll", "IEngineSoundClient003", 12, "void*(__thiscall*)(void*, const char*, float, int, int, float)")
		return function(sound_name, volume)
			local name = sound_name:lower():find(".wav") and sound_name or ("%s.wav"):format(sound_name)
			pcall(PlaySound, name, tonumber(volume) / 100, 100, 0, 0)
		end
	end)()
}

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

download = function()
    wininet.DeleteUrlCacheEntryA("https://raw.githubusercontent.com/xXN1ckWa1k3rXx/cheat_lua/main/better%20neverlose/better_neverlose_version.ini")

    urlmon.URLDownloadToFileA(nil, "https://raw.githubusercontent.com/xXN1ckWa1k3rXx/cheat_lua/main/better%20neverlose/better_neverlose_version.ini", "check.ini", 0,0)
end

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

local clamp = function (val, min, max) 
    if val > max then
        return max
    end

    if val < min then
        return min
    end

    return val
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

Elysia.check_conditions = function () -- No more asked why
    local me = entity.get_local_player()
    if not me then
        return 99
    end

    local vec = me.m_vecVelocity
    local velocity = math.sqrt((vec.x * vec.x) + (vec.y * vec.y))

    if nick.ref.antiaim.slowwalk:get() then
        return "Walking"
    elseif me.m_fFlags == 262 and me.m_flDuckAmount > 0.8 then
        return "In Air + Crouching"
    elseif me.m_fFlags == 256 then
        return "In Air"
    elseif me.m_flDuckAmount > 0.8 then
        return "Crouching"
    elseif velocity <= 2 then
        return "Standing"
    elseif velocity >= 3 then
        return "Running"
    end
end

nick.menu.ragebot.tp:set_callback(function()
    if nick.menu.ragebot.tp:get() then
        rage.exploit:force_teleport()
    end
end)

nick.ax_function = function ()
    
    if nick.menu.ragebot.ax:get() then 
        cvar.cl_lagcompensation:int(0) 
    else 
        cvar.cl_lagcompensation:int(1) 
    end

end

nick.jumpscout_fix = function ()

    local localplayer = entity.get_local_player()
    if not localplayer then return end
    
    local vel = localplayer.m_vecVelocity
    local speed = math.sqrt(vel.x * vel.x + vel.y * vel.y)

    if nick.menu.ragebot.jumpscout:get() then
        nick.ref.misc.air_strafe:override(math.floor(speed) > 15)
    end

end

nick.os_peek = function ()

    local localplayer = entity.get_local_player()
    if not localplayer then return end

    local my_weapon = localplayer:get_player_weapon()

    if nick.Elements.ospeek.breaklc:get() then
        nick.ref.ragebot.hs_options:override("Break LC")
    else
        nick.ref.ragebot.hs_options:override()
    end

    if my_weapon then
        local last_shot_time = my_weapon["m_fLastShotTime"]
		local time_difference = globals.curtime - last_shot_time

        if nick.menu.ragebot.os_peek:get() then
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

end

nick.defensive_aa = function (cmd)

    local exploit_state = rage.exploit:get() -- Defensive need always lag

    local localplayer = entity.get_local_player()
    if not localplayer then return end

    local prop = localplayer["m_fFlags"]

    local pitch_settings = nick.Elements.defensive.pitch:get()
    local yaw_settings = nick.Elements.defensive.yaw:get()

    local pitch_override = 0
    local yaw_override = 0
    
    if pitch_settings == "Zero" then
        pitch_override = 0
    elseif pitch_settings == "Up" then
        pitch_override = -89
    elseif pitch_settings == "Down" then
        pitch_override = 89
    elseif pitch_settings == "Random" then
        pitch_override = math.random(-89,89)
    elseif pitch_settings == "Jitter" then
        if (math.floor(globals.curtime * 100000) % 2) == 0 then
            pitch_override = 89
        else
            pitch_override = -89
        end
    elseif pitch_settings == "45 deg" then
        if (math.floor(globals.curtime * 10000) % 2) == 0 then
            pitch_override = 45
        else
            pitch_override = -45
        end
    elseif pitch_settings == "Custom" then
        pitch_override = nick.Elements.defensive.pitch_custom:get()
    end

    if yaw_settings == "Static" then
        yaw_override = nick.Elements.defensive.yaw_custom:get()
    elseif yaw_settings == "Random" then
        yaw_override = math.random(-180,180)
    elseif yaw_settings == "Side-Way" then
        if (math.floor(globals.curtime * 100000) % 2) == 0 then
            yaw_override = 89
        else
            yaw_override = -90
        end
    elseif yaw_settings == "Spin" then
        yaw_override = (globals.curtime * nick.Elements.defensive.spin:get()) % 360 - 180
    elseif yaw_settings == "Jitter" then
        if nick.Elements.defensive.yaw_jitter_mode:get() == "Center" then
            if (math.floor(globals.curtime * 10000) % 2) == 0 then
                yaw_override = nick.Elements.defensive.yaw_custom:get() - nick.Elements.defensive.yaw_jitter:get()
            else
                yaw_override = nick.Elements.defensive.yaw_custom:get() + nick.Elements.defensive.yaw_jitter:get()
            end
        else
            if (math.floor(globals.curtime * 10000) % 2) == 0 then
                yaw_override = nick.Elements.defensive.yaw_custom:get()
            else
                yaw_override = nick.Elements.defensive.yaw_custom:get() - nick.Elements.defensive.yaw_jitter:get()
            end
        end
    end


    -- Main

    if nick.menu.antiaim.defensive:get() and exploit_state ~= 0 then

        nick.ref.antiaim.hidden:override(true)

        if nick.Elements.defensive.inair:get() then
            if prop == 256 or prop == 262 then
                rage.antiaim:override_hidden_pitch(pitch_override)
                rage.antiaim:override_hidden_yaw_offset(yaw_override)
                nick.ref.ragebot.lag_options:override("Always On")
            else
                rage.antiaim:override_hidden_pitch(pitch_override)
                rage.antiaim:override_hidden_yaw_offset(yaw_override)
                nick.ref.ragebot.lag_options:override()
            end
        else
            rage.antiaim:override_hidden_pitch(pitch_override)
            rage.antiaim:override_hidden_yaw_offset(yaw_override)
            nick.ref.ragebot.lag_options:override("Always On")

        end
    else
        nick.ref.antiaim.hidden:override()
        nick.ref.antiaim.fs:override()
        nick.ref.ragebot.lag_options:override()
    end

end

nick.manual_aa = function ()

    if nick.menu.antiaim.defensive:get() and nick.ref.ragebot.dt:get() then return end

        if nick.menu.antiaim.manualaa:get() == "Left" then
            nick.ref.antiaim.yaw:override("Backward")
            nick.ref.antiaim.base:override("Local View")
            nick.ref.antiaim.offset:override(-90)
            nick.ref.antiaim.fs:override(false)
        elseif nick.menu.antiaim.manualaa:get() == "Backwards" then
            nick.ref.antiaim.yaw:override("Backward")
            nick.ref.antiaim.base:override("Local View")
            nick.ref.antiaim.offset:override(0)
            nick.ref.antiaim.fs:override(false)
        elseif nick.menu.antiaim.manualaa:get() == "Right" then
            nick.ref.antiaim.yaw:override("Backward")
            nick.ref.antiaim.base:override("Local View")
            nick.ref.antiaim.offset:override(90)
            nick.ref.antiaim.fs:override(false)
        elseif nick.menu.antiaim.manualaa:get() == "Forwards" then
            nick.ref.antiaim.yaw:override("Backward")
            nick.ref.antiaim.base:override("Local View")
            nick.ref.antiaim.offset:override(180)
            nick.ref.antiaim.fs:override(false)
        elseif nick.menu.antiaim.manualaa:get() == "Freestanding" then
            nick.ref.antiaim.yaw:override("Backward")
            nick.ref.antiaim.base:override("Local View")
            nick.ref.antiaim.offset:override(0)
            nick.ref.antiaim.fs:override(true)
        elseif nick.menu.antiaim.manualaa:get() == "None" then
            nick.ref.antiaim.yaw:override()
            nick.ref.antiaim.base:override()
            nick.ref.antiaim.fs:override()
            nick.ref.antiaim.offset:override()
        end
end

local tick_count = 0

nick.always_choke_slient_shots = function()

    events.createmove:set(function(cmd)
    
        local localplayer = entity.get_local_player()
        if not localplayer then return end
    
        local my_weapon = localplayer:get_player_weapon()
    
        if nick.menu.antiaim.flonshot:get() then
            if my_weapon then
                local last_shot_time = my_weapon["m_fLastShotTime"]
    	    	local time_difference = globals.curtime - last_shot_time
        
                if time_difference <= 0.025 then
                    if nick.Elements.slientshots.mode:get() == "Overrides" then
                        nick.ref.antiaim.bodyyaw:override(false)
                        nick.ref.antiaim.fl_enabled:override(false)
                        nick.ref.antiaim.limit:override(1)
                    elseif nick.Elements.slientshots.mode:get() == "Send packets" then
                        --sendpacket_switch = true
                        cmd.no_choke = true
                    end
                else
                    nick.ref.antiaim.bodyyaw:override()
                    nick.ref.antiaim.fl_enabled:override()
                    nick.ref.antiaim.limit:override()
                end
            end
        end
    end)
end

nick.missed_sound = function ()
    events.aim_ack:set(function(e)
        if e.state ~= nil then
            if nick.menu.world.misssound:get() then    
                nick.CffiHelper.PlaySound(nick.Elements.miss_sound.files:get(), nick.Elements.miss_sound.volume:get())
            end
        end
    end)
end

nick.vote_reveals = function()
    events.vote_cast:set(function(e)
        -- Source from: https://en.neverlose.cc/market/item?id=7IeKYA
        -- This event only on https://wiki.alliedmods.net/Generic_Source_Events
    
        if not nick.menu.misc.vote:get() then return end
    
        local team = e.team
        local voteOption = e.vote_option == 0 and "YES" or "NO"
    
        local user = entity.get(e.entityid)
    	local userName = user:get_name()
    
        print(("%s voted %s"):format(userName, voteOption))
        print_dev(("%s voted %s"):format(userName, voteOption))
    end)
end

nick.cvar_changer = function ()

    if nick.menu.misc.sv_cheat:get() then
        cvar.sv_cheats:int(1)
    else
        cvar.sv_cheats:int()
    end

    if nick.menu.misc.sv_pure:get() then
        cvar.sv_pure:int(0)
    else
        cvar.sv_pure:int()
    end

end

nick.viewmodel = function ()

    fov = nick.Elements.viewmodel.fov:get()
    x = nick.Elements.viewmodel.x:get()
    y = nick.Elements.viewmodel.y:get()
    z = nick.Elements.viewmodel.z:get()
    aspectratio = nick.Elements.viewmodel.aspectratio:get() / 10

    if nick.menu.world.viewmodel:get() then
        cvar["sv_competitive_minspec"]:int(0)
        cvar["viewmodel_fov"]:float(fov)
        cvar["viewmodel_offset_x"]:float(x)
        cvar["viewmodel_offset_y"]:float(y)
        cvar["viewmodel_offset_z"]:float(z)
        cvar["r_aspectratio"]:float(aspectratio)
    else
        cvar["sv_competitive_minspec"]:int(1)
        cvar["viewmodel_fov"]:string("def.")
        cvar["viewmodel_offset_x"]:string("def.")
        cvar["viewmodel_offset_y"]:string("def.")
        cvar["viewmodel_offset_z"]:string("def.")
        cvar["r_aspectratio"]:float(0)
    end

end

nick.trashtalk = function ()
    events.aim_ack:set(function(e)
        local target = e.target
        local get_target_entity = entity.get(target)
        if not get_target_entity then return end
        
        local health = get_target_entity.m_iHealth
    
        if not target:get_name() or not health then return end
        
        if not nick.menu.misc.killsay:get() then
            return end
        if health == 0 then
            if nick.Elements.trashtalk.check:get() then
                utils.console_exec("say " .. (nick.Elements.trashtalk.text:get()):format(target:get_name()))
            else
                utils.console_exec("say " .. nick.Elements.trashtalk.text:get())
            end
            
        end
    end)
end

nick.debug_mode = function()

    if not nick.menu.world.debug:get() then return end


    local elements = {
        ["Feet Yaw"] = nick.Elements.debug.list:get("Feet Yaw"),
        ["Choked Commands"] = nick.Elements.debug.list:get("Choked Commands"),
        ["Real Yaw"] = nick.Elements.debug.list:get("Real Yaw"),
        ["Abs Yaw"] = nick.Elements.debug.list:get("Abs Yaw"),
        ["Desync"] = nick.Elements.debug.list:get("Desync"),
    }

    local x,y = render.screen_size().x,render.screen_size().y
    local time_h = string.format("%02d", common.get_system_time().hours)
    local time_m = string.format("%02d", common.get_system_time().minutes)
    local time_s = string.format("%02d", common.get_system_time().seconds)
    local time = time_h .. ":" .. time_m .. ":" .. time_s

    if nick.Elements.debug.watermark:get() then
        if not globals.is_in_game or not globals.is_connected then
            render.text(1, vector(10, y - 15), color(255,255,255), "", "neverlose.cc - \a4FFF1EFFclient version:".. common.get_product_version() .. "\aDEFAULT / " .. common.get_username() .. " [Debug Mode] " .. time .. "")
        else
            render.text(1, vector(10, y - 15), color(255,255,255), "", "neverlose.cc - \a4FFF1EFFclient version:".. common.get_product_version() .. "\aDEFAULT / " .. common.get_username() .. " [Debug Mode] " .. time .. " info: " .. utils.net_channel():get_server_info().address .. " | " .. utils.net_channel():get_server_info().name)
        end
    end

    if not entity.get_local_player() then return end
    if not globals.is_in_game or not globals.is_connected then return end
    local DesyncAngle = math.ceil(math.abs(normalize_yaw(entity.get_local_player():get_anim_state().eye_yaw % 360 - math.floor(entity.get_local_player():get_anim_state().abs_yaw) % 360)))



    -- from newbing XD
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
            end
            render.text(1, position, color(255, 255, 255), "", text)
            i = i + 1
        end
    end

    

end
-- 1
local font = render.load_font("c:/windows/fonts/calibrib.ttf", 28, "ad")

nick.indicators = function()

    if not nick.menu.world.indicator:get() then return end

    local x, y = render.screen_size().x, render.screen_size().y

    local localplayer = entity.get_local_player()
    if not localplayer then return end
    
    local exploit_color = (rage.exploit:get() == 1) and color("#cccccd") or color(255,0,0,255)
    local slowdown = entity.get_local_player().m_flVelocityModifier
    local fade_factor = ((1 / .15) * globals.frametime) * 255

    local vel = localplayer.m_vecVelocity
    local speed = math.sqrt(vel.x * vel.x + vel.y * vel.y)

    local offset = 1

    ---------------------------------------------------------

    -- Code from Elysia.lua (market.neverlose.cc/ghvUp6)
    -- I'm not have too much time to recode this useless indicator, im lazy
    -- And dont ask why there r a elysia.check_conditions() function


    if nick.Elements.indicator.left:get("Double Tap & Hide Shots") and nick.ref.ragebot.dt:get() then
	    render.text(font, vector(20, y / 2 + 40 + (40 * offset)), exploit_color, "", "DT")
        offset = offset + 1
	end
	if nick.Elements.indicator.left:get("LC") and (Elysia.check_conditions() == "In Air" or Elysia.check_conditions() == "In Air + Crouching" ) then
	    lc_color = (speed >= 270 and globals.choked_commands > 2) and color("#7fbd14") or color(255,0,0,255)
        render.text(font, vector(24, y / 2 + 40 + (40 * offset)), lc_color, "", "LC")
        offset = offset + 1
	end
	if nick.Elements.indicator.left:get("AX") and nick.menu.ragebot.ax:get() then
	    render.text(font, vector(24, y / 2 + 40 + (40 * offset)), color("#FFD65A"), "", "AX")
        offset = offset + 1
	end
	if nick.Elements.indicator.left:get("HC") then
	    render.text(font, vector(24, y / 2 + 40 + (40 * offset)), color("#cccccd"), "", ("HC %s %%"):format(ui.find("Aimbot", "Ragebot", "Selection", "Hit Chance"):get()))
        offset = offset + 1
	end
	if nick.Elements.indicator.left:get("DMG") then
	    render.text(font, vector(24, y / 2 + 40 + (40 * offset)), color("#cccccd"), "", ("DMG %s"):format(ui.find("Aimbot", "Ragebot", "Selection", "Min. Damage"):get()))
        offset = offset + 1
	end
    if nick.Elements.indicator.left:get("DA") and nick.ref.ragebot.da:get() then
	    render.text(font, vector(24, y / 2 + 40 + (40 * offset)), color("#cccccd"), "", ("DA"):format(Elysia.ref.Ragebot.globals_dmg:get()))
        offset = offset + 1
	end
    if nick.Elements.indicator.left:get("Fake Duck") and nick.ref.antiaim.fd:get() then
	    render.text(font, vector(20, y / 2 + 40 + (40 * offset)), color("#FFD65A"), "", "FD")
        offset = offset + 1
	end
    

    ---------------------------------------------------------

    alpha = nick.math_new_lerp("alpha_slowdown", (nick.Elements.indicator.slow_down:get() and localplayer:is_alive() and (ui.get_alpha() == 1 or math.floor(slowdown * 100 + 0.5) ~= 100)) and 255 or 0, globals.frametime * 20)
    slow_down = nick.Elements.indicator.slow_down_color:get()

    if nick.Elements.indicator.crosshair:get() then
        render.text(1, vector(x / 2 - 110, y / 2 - 15), color("FFFFFF"), "", "" .. ui.find("Aimbot", "Ragebot", "Selection", "Hit Chance"):get())
        render.text(1, vector(x / 2 + 100, y / 2 - 15), color("FFFFFF"), "", "" .. ui.find("Aimbot", "Ragebot", "Selection", "Min. Damage"):get())
    end

    if not entity.get_local_player() then return end
    render.shadow(vector(x/2 - 120,y / 2 - 333), vector(x/2 + 120,y / 2 - 325), color(slow_down.r, slow_down.g, slow_down.b, alpha),20,0,1)
    render.rect_outline(vector(x/2 - 120,y / 2 - 333), vector(x/2 + 120,y / 2 - 325), color(0,0,0, alpha), 1.2)
    render.rect(vector(x/2 - 119,y / 2 - 332), vector(x/2 + slowdown * (119 - (-119)) + (-119) ,y / 2 - 326), color(slow_down.r, slow_down.g, slow_down.b, alpha))
    render.text(1, vector(x / 2, y / 2 - 345), color(slow_down.r, slow_down.g, slow_down.b, alpha), "c", ui.get_icon("triangle-exclamation") .. " Slowed Down: " .. math.floor(slowdown * 100 + 0.5) .. "%")

end

nick.autotp = function ()

    local tp = nick.Elements.tp.tp:get()
    local inair = nick.Elements.tp.inair:get()

    if not tp then return end

    local localplayer = entity.get_local_player()
    if not localplayer then return end

    local prop = localplayer["m_fFlags"]
    if inair then
        if prop == 256 or prop == 262 then
            if entity.get_threat(true) then rage.exploit:force_teleport() end
        end
    else
        if entity.get_threat(true) then rage.exploit:force_teleport() end
    end

end

nick.ragebot = function()
    for i, v in ipairs(weapons) do
        local baim = ui_ragebot[i].baim:get()
        local safe = ui_ragebot[i].safe:get()
        local only_head = ui_ragebot[i].only_head:get()

        ui.find("Aimbot", "Ragebot", "Selection", v, "Hitboxes"):override(baim and "Chest" or nil, baim and "Stomach" or nil)
        ui.find("Aimbot", "Ragebot", "Selection", v, "Multipoint"):override(baim and "Chest" or nil, baim and "Stomach" or nil)
        ui.find("Aimbot", "Ragebot", "Safety", v, "Body Aim"):override(baim and "Force" or nil)
        ui.find("Aimbot", "Ragebot", "Safety", v, "Safe Points"):override(safe and "Force" or nil)
        ui.find("Aimbot", "Ragebot", "Selection", v, "Hitboxes"):override(only_head and "Head" or nil)
        ui.find("Aimbot", "Ragebot", "Selection", v, "Multipoint"):override(only_head and "Head" or nil)
    end
end

nick.fast_fall = function (cmd)

    if not nick.menu.misc.fast_fall:get() then return end
	
	local localplayer = entity.get_local_player()
    if not localplayer then return end

	if localplayer.m_vecVelocity.z >= -480 then return end

	if nick.get_trace(75) then
		rage.exploit:force_teleport()
	end

end

nick.air_exploit = function (cmd)

    if not nick.menu.antiaim.air_exploit:get() then return end

    local localplayer = entity.get_local_player()
    if not localplayer then return end

    if rage.exploit:get() == 1 then
        nick.ref.antiaim.fd:override(globals.tickcount % 16 == 0 and true or nil)
    else
        nick.ref.antiaim.fd:override(nil)
    end
end


nick.unload = function ()

    ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding"):disabled(false)

    cvar["sv_competitive_minspec"]:int(1)
    cvar["r_aspectratio"]:float(0)
    cvar.sv_cheats:int()
    cvar.sv_pure:int()
    cvar.cl_lagcompensation:int(1)


end

nick.update_check = function ()

    download()

    if files.read("check.ini") ~= version then
        print_dev("New version is detected, please go to the market or Github repository to update manually.")
        print("New version is detected, please go to the market or Github repository to update manually. - https://github.com/xXN1ckWa1k3rXx/cheat_lua/blob/main/better%20neverlose/")
    else
        print("The current version is the latest")
        print_dev("The current version is the latest")
    end

end

events.createmove:set(function(cmd)
    nick.ax_function()
    nick.jumpscout_fix()
    nick.defensive_aa()
    nick.os_peek()
    nick.manual_aa()
    nick.autotp()
    nick.ragebot()
    nick.fast_fall(cmd)
    nick.air_exploit(cmd)
end)

events.render:set(function()
    nick.viewmodel()
    nick.debug_mode()
    nick.indicators()
    nick.menu_visible()
end)

nick.once_callback = function ()
    nick.ragebot_item()
    nick.vote_reveals()
    nick.missed_sound()
    nick.always_choke_slient_shots()
    nick.trashtalk()
end

events.shutdown:set(function()
    nick.unload()
end)

nick.once_callback()