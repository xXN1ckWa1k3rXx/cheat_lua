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
    Updated date: 6/27/2023
]]

_DEBUG = true

----------------------- FFI CODE ---------------------
local ffi = require("ffi")

ffi.cdef[[
	bool PlaySound(
		const char* pszSound,
		void* hmod,
		unsigned int fdwSound
	);
]]
------------------------------------------------------

local nick = {} -- You can't replace/change this name

nick.ref = {
    ["ragebot"] = {
        main = ui.find("Aimbot", "Ragebot", "Main"),
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
    },
    ["world"] = {
        main = ui.find("Visuals", "World", "Main"),
        other = ui.find("Visuals", "World", "Other"),
    },
    ["misc"] = {
        in_game = ui.find("Miscellaneous", "Main", "In-Game"),
        other = ui.find("Miscellaneous", "Main", "Other"),
        air_strafe = ui.find("Miscellaneous", "Main", "Movement", "Air Strafe"),
    }
}

nick.menu = {
    ["ragebot"] = {
        tp = nick.ref.ragebot.main:switch("Teleport on Key (BIND)"):tooltip("Bind a key. Exploits charged and press key to teleport"),
        ax = nick.ref.ragebot.main:switch("\aF7FF8FFFAnti Defensive"):tooltip("Disabling lag compensation will allow to hit players which using defensive/lag-peek exploit.\n\nIt affects ragebot accuracy, avoid using it on high ping/head shot weapons\n\n\aF7FF8FFFTip: Does not bypass cl_lagcompensation detection, this operation may not be supported on some servers"),
        os_peek = nick.ref.ragebot.main:switch("OS Peek"):tooltip("Safety lag peek\n\nTeleport a short ticks in shooting"),
        jumpscout = nick.ref.ragebot.accuracy:switch("Jumpscout"):tooltip("Allow to static jump to stabilize accuracy"),
    },
    ["antiaim"] = {
        defensive = nick.ref.antiaim.angles:switch("Defensive Anti Aim"):tooltip("Breaking LC to break backtrack and jitter your head yaw\n\nMake it harder for enemies to hit you in the head"),
        fakeflick = nick.ref.antiaim.angles:switch("Fake Flick (BETA)"):tooltip("Testing phase\n\nYou need to use it with Manual AA (Left and Right)\n\n\a698EFFFF" .. ui.get_icon("triangle-exclamation") .. " You need to bind it and use Hold, it is strongly recommended to bind it with Manual AA on a Key, Manual AA is not an override"),
        alwayschoke = nick.ref.antiaim.fakelag:switch("Always Chock"):tooltip("Disabled variability jitter send packet"),
        flonshot = nick.ref.antiaim.fakelag:switch("Slient shots"):tooltip("A.K.A No fakelag on shots\n\nForce send packet while every shots"),
        manualaa = nick.ref.antiaim.misc:combo("Manual AA", {"None", "Left", "Backwards", "Right", "Forwards", "Freestanding"}):tooltip("\a698EFFFF" .. ui.get_icon("triangle-exclamation") .. " If you need to use Fake Flick, it is strongly recommended that you bind the keys, otherwise the settings will be messed up"),
    },
    ["world"] = {
        viewmodel = nick.ref.world.main:switch("Custom Viewmodel"):tooltip("Allow to change viewmodel fov"):disabled(true),
        misssound = nick.ref.world.other:switch("Missed sound"):tooltip("Play sound when missed shot\n\nPut the files in [csgo folder]/sound"),
        indicator = nick.ref.world.other:switch("Indicators"):tooltip("Still in beta. Hold on!"):disabled(true)
    },
    ["misc"] = {
        sv_cheat = nick.ref.misc.other:switch("Force sv_cheats"):tooltip("Unlock some client commands need sv_cheats 1"),
        sv_pure  = nick.ref.misc.other:switch("Bypass sv_pure"):tooltip("Bypass server checking local game files\n\nThat's allow you to use thrid-party model files in official server or enabled sv_pure server"),
        killsay  = nick.ref.misc.in_game:switch("Trashtalk on kill"):tooltip("Say something nonsense talk while kill a enemy"):disabled(true),
        vote     = nick.ref.misc.in_game:switch("Vote reveals"):tooltip("Print the voting information on the console")
    }
}

nick.CreateElements = {
    ["ragebot"] = {
        ospeek = nick.menu.ragebot.os_peek:create(),
        dt = nick.ref.ragebot.dt:create(),
    },
    ["antiaim"] = {
        defensive = nick.menu.antiaim.defensive:create(),
        fakeflick = nick.menu.antiaim.fakeflick:create(),
        alwayschoke = nick.menu.antiaim.alwayschoke:create(),
        slientshots = nick.menu.antiaim.flonshot:create(),
    },
    ["world"] = {
        viewmodel = nick.menu.world.viewmodel:create(),
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
        pitch = nick.CreateElements.antiaim.defensive:combo("Pitch", {"Zero", "Up", "Down", "Random", "Jitter"}),
        yaw = nick.CreateElements.antiaim.defensive:combo("Yaw", {"Static", "Random", "Jitter", "Spin"}),
        inair = nick.CreateElements.antiaim.defensive:switch("Only In air"),
        spin = nick.CreateElements.antiaim.defensive:slider("Spin speed", 120, 7200, 360),
    },
    ["fakeflick"] = {
        timer = nick.CreateElements.antiaim.fakeflick:slider("LBY Break timer", 30, 160),
    },
    ["alwayschoke"] = {
        mode = nick.CreateElements.antiaim.alwayschoke:combo("Mode", {"Limit", "Maximum"}),
    },
    ["slientshots"] = {
        mode = nick.CreateElements.antiaim.slientshots:combo("Mode", "Overrides", "Send packets"),
    },
    ["miss_sound"] = {
        files = nick.CreateElements.world.missed:input("File name"),
        volume = nick.CreateElements.world.missed:slider("Volume", 0, 100, 70),
    }
}

nick.CffiHelper = {
    PlaySound = (function()
		local PlaySound = utils.get_vfunc("engine.dll", "IEngineSoundClient003", 12, "void*(__thiscall*)(void*, const char*, float, int, int, float)")
		return function(sound_name, volume)
			local name = sound_name:lower():find(".wav") and sound_name or ("%s.wav"):format(sound_name)
			pcall(PlaySound, name, tonumber(volume) / 100, 100, 0, 0)
		end
	end)()
}

nick.menu.ragebot.tp:set_callback(function()
    if nick.menu.ragebot.tp:get() then
        rage.exploit:force_teleport()
    end
end)

nick.ax_function = function ()
    
    if nick.menu.ragebot.ax:get() then 
        cvar.cl_lagcompensation:int(0) 
    else 
        cvar.cl_lagcompensation:int() 
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

    local exploit_state = nick.ref.ragebot.dt:get() -- Defensive need always lag

    local localplayer = entity.get_local_player()
    if not localplayer then return end

    local prop = localplayer["m_fFlags"]

    local pitch_settings = nick.Elements.defensive.pitch:get()
    local yaw_settings = nick.Elements.defensive.yaw:get()

    local pitch_override = nil
    local yaw_override = nil

    if pitch_settings == "Zero" then
        pitch_override = "Disabled"
    elseif pitch_settings == "Up" then
        pitch_override = "Fake Up"
    elseif pitch_settings == "Down" then
        pitch_override = "Down"
    elseif pitch_settings == "Random" then
        random_num = math.random(3)

        if random_num == 1 then
            pitch_override = "Down"
        elseif random_num == 2 then
            pitch_override = "Disabled"
        elseif random_num == 3 then
            pitch_override = "Fake Up"
        end
    elseif pitch_settings == "Jitter" then
        if (math.floor(globals.curtime * 100000) % 2) == 0 then
            pitch_override = "Down"
        else
            pitch_override = "Fake Up"
        end
    end


    if yaw_settings == "Static" then
        yaw_override = 0
    elseif yaw_settings == "Random" then
        yaw_override = math.random(-180,180)
    elseif yaw_settings == "Jitter" then
        if (math.floor(globals.curtime * 100000) % 2) == 0 then
            yaw_override = -52
        else
            yaw_override = 47
        end
    elseif yaw_settings == "Spin" then
        yaw_override = (globals.curtime * nick.Elements.defensive.spin:get()) % 360 - 180
    end


    -- Main

    if nick.menu.antiaim.defensive:get() and exploit_state then

        if nick.Elements.defensive.inair:get() then
            if prop == 256 or prop == 262 then
                nick.ref.antiaim.pitch:override(pitch_override)
                nick.ref.antiaim.yaw:override("Backward")
                nick.ref.antiaim.base:override("Local View")
                nick.ref.antiaim.offset:override(tonumber(yaw_override))
                nick.ref.antiaim.fs:override(false)
                nick.ref.ragebot.lag_options:override("Always On")
            else
                nick.ref.antiaim.pitch:override()
                nick.ref.antiaim.yaw:override()
                nick.ref.antiaim.base:override()
                nick.ref.antiaim.offset:override()
                nick.ref.antiaim.fs:override()
                nick.ref.ragebot.lag_options:override()
            end
        else
            nick.ref.antiaim.pitch:override(pitch_override)
            nick.ref.antiaim.yaw:override("Backward")
            nick.ref.antiaim.base:override("Local View")
            nick.ref.antiaim.offset:override(yaw_override)
            nick.ref.antiaim.fs:override(false)
            if prop == 256 or prop == 262 then
                nick.ref.ragebot.lag_options:override("Always On")
            end
        end
    else
        nick.ref.antiaim.pitch:override()
        nick.ref.antiaim.yaw:override()
        nick.ref.antiaim.base:override()
        nick.ref.antiaim.offset:override()
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
            nick.ref.antiaim.fs:override()
        end
end

local tick_count = 0

nick.fakeflick = function (cmd)

    if nick.menu.antiaim.fakeflick:get() then 

        nick.ref.antiaim.fl_enabled:override(false)
        nick.ref.antiaim.bodyyaw:override(false)

        tick_count = tick_count + 1
        if tick_count >= nick.Elements.fakeflick.timer:get() then
            if nick.menu.antiaim.manualaa:get() == "Left" then
                nick.menu.antiaim.manualaa:set("Right")
                utils.execute_after(globals.tickinterval / 10,function() 
                    nick.menu.antiaim.manualaa:set("Left")
                end)
            elseif nick.menu.antiaim.manualaa:get() == "Right" then
                nick.menu.antiaim.manualaa:set("Left")
                utils.execute_after(globals.tickinterval / 10,function() 
                    nick.menu.antiaim.manualaa:set("Right")
                end)
            elseif nick.menu.antiaim.manualaa:get() ~= "Right" and nick.menu.antiaim.manualaa:get() ~= "Left" then
                nick.menu.antiaim.manualaa:set()
            end
            tick_count = 0
        end
    
    else
        --nick.ref.antiaim.fl_enabled:override()
        --nick.ref.antiaim.bodyyaw:override()
    end
    
end

events.createmove:set(function(cmd)

    -- Always Choke and Slient shots

    local sendpacket_switch = true

    cmd.send_packet = sendpacket_switch


    if nick.menu.antiaim.alwayschoke:get() then
        if nick.Elements.alwayschoke.mode:get() == "Limit" then
            sendpacket_switch = cmd.choked_commands >= nick.ref.antiaim.limit:get()
        elseif nick.Elements.alwayschoke.mode:get() == "Maximum" then
            sendpacket_switch = false
        end
    end

    local localplayer = entity.get_local_player()
    if not localplayer then return end

    local my_weapon = localplayer:get_player_weapon()


    if my_weapon then
        local last_shot_time = my_weapon["m_fLastShotTime"]
		local time_difference = globals.curtime - last_shot_time

        if time_difference <= 0.025 then
            if nick.Elements.slientshots.mode:get() == "Overrides" then
                nick.ref.antiaim.bodyyaw:override(false)
                nick.ref.antiaim.fl_enabled:override(false)
                nick.ref.antiaim.limit:override(1)
            elseif nick.Elements.slientshots.mode:get() == "Send packets" then
                sendpacket_switch = true
                cmd.no_choke = true
            end
        else
            nick.ref.antiaim.bodyyaw:override()
            nick.ref.antiaim.fl_enabled:override()
            nick.ref.antiaim.limit:override()
        end
    end

end)

-- Missed sound
events.aim_ack:set(function(e)
    if e.state ~= nil then
        if nick.menu.world.misssound:get() then    
            nick.CffiHelper.PlaySound(nick.Elements.miss_sound.files:get(), nick.Elements.miss_sound.volume:get())
        end
    end
end)

nick.vote_reveals = function()

    -- Source from: https://en.neverlose.cc/market/item?id=7IeKYA
    -- It may be not working
    -- This event only on https://wiki.alliedmods.net/Generic_Source_Events

    if not nick.menu.misc.vote:get() then return end

    local team = e.team
    local voteOption = e.vote_option == 0 and "YES" or "NO"

    local user = entity.get(e.entityid)
	local userName = user:get_name()

    print(("%s voted %s"):format(userName, voteOption))
    print_dev(("%s voted %s"):format(userName, voteOption))

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

events.createmove:set(function(cmd)
    nick.fakeflick()
    nick.ax_function()
    nick.jumpscout_fix()
    nick.defensive_aa()
    nick.os_peek()
    nick.manual_aa()
    nick.vote_reveals()
end)