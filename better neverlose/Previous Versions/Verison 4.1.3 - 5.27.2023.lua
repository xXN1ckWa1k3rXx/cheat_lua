--[[ 
    Better Neverlose
    Author: xXYu3_zH3nGL1ngXx
    Version: 4.1.3
    Bulid date: 5.27.2023
 ]]

--[[ 
    Changelog:
        - Improved defenisve exploit antiaim
 ]]

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



_DEBUG = true
local ffi = require("ffi")

ffi.cdef[[
	bool PlaySound(
		const char* pszSound,
		void* hmod,
		unsigned int fdwSound
	);
]]

local nick = {}


nick.ref = {
    ragebot_main = ui.find("Aimbot", "Ragebot", "Main"),
    ragebot_accuracy = ui.find("Aimbot", "Ragebot", "Accuracy", "SSG-08"),
    ragebot_safety = ui.find("Aimbot", "Ragebot", "Safety"),
    hitboxes = ui.find("Aimbot", "Ragebot", "Selection", "Hitboxes"),
    multipoint = ui.find("Aimbot", "Ragebot", "Selection", "Multipoint"),
    safepoint = ui.find("Aimbot", "Ragebot", "Safety", "Safe Points"),
    baim = ui.find("Aimbot", "Ragebot", "Safety", "Body Aim"),
    autopeek = ui.find("Aimbot", "Ragebot", "Main", "Peek Assist"),
    hideshot = ui.find("Aimbot", "Ragebot", "Main", "Hide Shots"),
    hs_options = ui.find("Aimbot", "Ragebot", "Main", "Hide Shots", "Options"),
    dt = ui.find("Aimbot", "Ragebot", "Main", "Double Tap"),
    dt_inside = ui.find("Aimbot", "Ragebot", "Main", "Double Tap"):create(),
    fakelag_limit = ui.find("Aimbot","Anti Aim", "Fake Lag", "Limit"),
    fakelag = ui.find("Aimbot", "Anti Aim", "Fake Lag"),
    fl_enabled = ui.find("Aimbot", "Anti Aim", "Fake Lag", "Enabled"),
    fakelag_switch = ui.find("Aimbot", "Anti Aim", "Fake Lag", "Enabled"),
    slowwalk = ui.find("Aimbot","Anti Aim", "Misc", "Slow walk"),
    aa_misc = ui.find("Aimbot", "Anti Aim", "Misc"),
    desync = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw"),
    yaw_offset = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Offset"),
    yaw_base = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Base"),
    yaw = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw"),
    world = ui.find("Visuals", "World", "Other"),
    main = ui.find("Miscellaneous", "Main", "In-Game"),
    autostrafe = ui.find("Miscellaneous", "Main", "Movement", "Air Strafe"),
    ingame = ui.find("Miscellaneous", "Main", "In-Game"),
    fs = ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding"),
    movement = ui.find("Miscellaneous", "Main", "Movement"),
    main_other = ui.find("Miscellaneous", "Main", "Other"),
    angles = ui.find("Aimbot", "Anti Aim", "Angles"),
    pitch = ui.find("Aimbot", "Anti Aim", "Angles", "Pitch"),
    world_main = ui.find("Visuals", "World", "Main"),
    aa_enabled = ui.find("Aimbot", "Anti Aim", "Angles", "Enabled"),
}

nick.rage_ref = {  -- Oh god. Please help me
    globals         = ui.find("Aimbot", "Ragebot", "Safety", "Global"),
    ssg08           = ui.find("Aimbot", "Ragebot", "Safety", "SSG-08"),
    pistols         = ui.find("Aimbot", "Ragebot", "Safety", "Pistols"),
    autosnipers     = ui.find("Aimbot", "Ragebot", "Safety", "AutoSnipers"),
    snipers         = ui.find("Aimbot", "Ragebot", "Safety", "Snipers"),
    rifles          = ui.find("Aimbot", "Ragebot", "Safety", "Rifles"),
    smgs            = ui.find("Aimbot", "Ragebot", "Safety", "SMGs"),
    shotguns        = ui.find("Aimbot", "Ragebot", "Safety", "Shotguns"),
    machineguns     = ui.find("Aimbot", "Ragebot", "Safety", "Machineguns"),
    awp             = ui.find("Aimbot", "Ragebot", "Safety", "AWP"),
    ak47            = ui.find("Aimbot", "Ragebot", "Safety", "AK-47"),
    m4a1            = ui.find("Aimbot", "Ragebot", "Safety", "M4A1/M4A4"),
    eagle           = ui.find("Aimbot", "Ragebot", "Safety", "Desert Eagle"),
    revolver        = ui.find("Aimbot", "Ragebot", "Safety", "R8 Revolver"),
    aug             = ui.find("Aimbot", "Ragebot", "Safety", "AUG/SG 553"),
    taser           = ui.find("Aimbot", "Ragebot", "Safety", "Taser"),
    
}

nick.rage_hb = {
    globals         = ui.find("Aimbot", "Ragebot", "Selection", "Global", "Hitboxes"),
    ssg08           = ui.find("Aimbot", "Ragebot", "Selection", "SSG-08", "Hitboxes"),
    pistols         = ui.find("Aimbot", "Ragebot", "Selection", "Pistols", "Hitboxes"),
    autosnipers     = ui.find("Aimbot", "Ragebot", "Selection", "AutoSnipers", "Hitboxes"),
    snipers         = ui.find("Aimbot", "Ragebot", "Selection", "Snipers", "Hitboxes"),
    rifles          = ui.find("Aimbot", "Ragebot", "Selection", "Rifles", "Hitboxes"),
    smgs            = ui.find("Aimbot", "Ragebot", "Selection", "SMGs", "Hitboxes"),
    shotguns        = ui.find("Aimbot", "Ragebot", "Selection", "Shotguns", "Hitboxes"),
    machineguns     = ui.find("Aimbot", "Ragebot", "Selection", "Machineguns", "Hitboxes"),
    awp             = ui.find("Aimbot", "Ragebot", "Selection", "AWP", "Hitboxes"),
    ak47            = ui.find("Aimbot", "Ragebot", "Selection", "AK-47", "Hitboxes"),
    m4a1            = ui.find("Aimbot", "Ragebot", "Selection", "M4A1/M4A4", "Hitboxes"),
    eagle           = ui.find("Aimbot", "Ragebot", "Selection", "Desert Eagle", "Hitboxes"),
    revolver        = ui.find("Aimbot", "Ragebot", "Selection", "R8 Revolver", "Hitboxes"),
    aug             = ui.find("Aimbot", "Ragebot", "Selection", "AUG/SG 553", "Hitboxes"),
    taser           = ui.find("Aimbot", "Ragebot", "Selection", "Taser", "Hitboxes"),
}

nick.rage_mp = {
    globals         = ui.find("Aimbot", "Ragebot", "Selection", "Global", "Multipoint"),
    ssg08           = ui.find("Aimbot", "Ragebot", "Selection", "SSG-08", "Multipoint"),
    pistols         = ui.find("Aimbot", "Ragebot", "Selection", "Pistols", "Multipoint"),
    autosnipers     = ui.find("Aimbot", "Ragebot", "Selection", "AutoSnipers", "Multipoint"),
    snipers         = ui.find("Aimbot", "Ragebot", "Selection", "Snipers", "Multipoint"),
    rifles          = ui.find("Aimbot", "Ragebot", "Selection", "Rifles", "Multipoint"),
    smgs            = ui.find("Aimbot", "Ragebot", "Selection", "SMGs", "Multipoint"),
    shotguns        = ui.find("Aimbot", "Ragebot", "Selection", "Shotguns", "Multipoint"),
    machineguns     = ui.find("Aimbot", "Ragebot", "Selection", "Machineguns", "Multipoint"),
    awp             = ui.find("Aimbot", "Ragebot", "Selection", "AWP", "Multipoint"),
    ak47            = ui.find("Aimbot", "Ragebot", "Selection", "AK-47", "Multipoint"),
    m4a1            = ui.find("Aimbot", "Ragebot", "Selection", "M4A1/M4A4", "Multipoint"),
    eagle           = ui.find("Aimbot", "Ragebot", "Selection", "Desert Eagle", "Multipoint"),
    revolver        = ui.find("Aimbot", "Ragebot", "Selection", "R8 Revolver", "Multipoint"),
    aug             = ui.find("Aimbot", "Ragebot", "Selection", "AUG/SG 553", "Multipoint"),
    taser           = ui.find("Aimbot", "Ragebot", "Selection", "Taser", "Multipoint"),
}

nick.rage_baim = {
    globals         = ui.find("Aimbot", "Ragebot", "Safety", "Global", "Body Aim"),
    ssg08           = ui.find("Aimbot", "Ragebot", "Safety", "SSG-08", "Body Aim"),
    pistols         = ui.find("Aimbot", "Ragebot", "Safety", "Pistols", "Body Aim"),
    autosnipers     = ui.find("Aimbot", "Ragebot", "Safety", "AutoSnipers", "Body Aim"),
    snipers         = ui.find("Aimbot", "Ragebot", "Safety", "Snipers", "Body Aim"),
    rifles          = ui.find("Aimbot", "Ragebot", "Safety", "Rifles", "Body Aim"),
    smgs            = ui.find("Aimbot", "Ragebot", "Safety", "SMGs", "Body Aim"),
    shotguns        = ui.find("Aimbot", "Ragebot", "Safety", "Shotguns", "Body Aim"),
    machineguns     = ui.find("Aimbot", "Ragebot", "Safety", "Machineguns", "Body Aim"),
    awp             = ui.find("Aimbot", "Ragebot", "Safety", "AWP", "Body Aim"),
    ak47            = ui.find("Aimbot", "Ragebot", "Safety", "AK-47", "Body Aim"),
    m4a1            = ui.find("Aimbot", "Ragebot", "Safety", "M4A1/M4A4", "Body Aim"),
    eagle           = ui.find("Aimbot", "Ragebot", "Safety", "Desert Eagle", "Body Aim"),
    revolver        = ui.find("Aimbot", "Ragebot", "Safety", "R8 Revolver", "Body Aim"),
    aug             = ui.find("Aimbot", "Ragebot", "Safety", "AUG/SG 553", "Body Aim"),
    taser           = ui.find("Aimbot", "Ragebot", "Safety", "Taser", "Body Aim"),
    
}

nick.rage_sp = {
    globals         = ui.find("Aimbot", "Ragebot", "Safety", "Global", "Safe Points"),
    ssg08           = ui.find("Aimbot", "Ragebot", "Safety", "SSG-08", "Safe Points"),
    pistols         = ui.find("Aimbot", "Ragebot", "Safety", "Pistols", "Safe Points"),
    autosnipers     = ui.find("Aimbot", "Ragebot", "Safety", "AutoSnipers", "Safe Points"),
    snipers         = ui.find("Aimbot", "Ragebot", "Safety", "Snipers", "Safe Points"),
    rifles          = ui.find("Aimbot", "Ragebot", "Safety", "Rifles", "Safe Points"),
    smgs            = ui.find("Aimbot", "Ragebot", "Safety", "SMGs", "Safe Points"),
    shotguns        = ui.find("Aimbot", "Ragebot", "Safety", "Shotguns", "Safe Points"),
    machineguns     = ui.find("Aimbot", "Ragebot", "Safety", "Machineguns", "Safe Points"),
    awp             = ui.find("Aimbot", "Ragebot", "Safety", "AWP", "Safe Points"),
    ak47            = ui.find("Aimbot", "Ragebot", "Safety", "AK-47", "Safe Points"),
    m4a1            = ui.find("Aimbot", "Ragebot", "Safety", "M4A1/M4A4", "Safe Points"),
    eagle           = ui.find("Aimbot", "Ragebot", "Safety", "Desert Eagle", "Safe Points"),
    revolver        = ui.find("Aimbot", "Ragebot", "Safety", "R8 Revolver", "Safe Points"),
    aug             = ui.find("Aimbot", "Ragebot", "Safety", "AUG/SG 553", "Safe Points"),
    taser           = ui.find("Aimbot", "Ragebot", "Safety", "Taser", "Safe Points"),
    
}


nick.menu = {
    -- Ragebot main and accuracy settings
    tp = nick.ref.ragebot_main:switch("Teleport on key (BIND)"):tooltip("In the case of Exploits Charged, press to teleport for a short distance"),
    ax = nick.ref.ragebot_main:switch("\aF7FF8FFFAnti Defensive"):tooltip("Disabling lag compensation will allow to hit players which using defenisve/lag-peek exploit.\n\nIt affects ragebot accuracy, avoid using it on high ping/head shot weapons\n\n\aF7FF8FFFTip: Does not bypass cl_lagcompensation detection, this operation may not be supported on some servers"),
    ospeek = nick.ref.ragebot_main:switch("OS Peek"):tooltip("Experimental features, unstable"),
    jump = nick.ref.ragebot_accuracy:switch("Jumpscout fix"):tooltip("jump in place\n\nNote: This may conflict with v1pix's Helper. Since I am a beta user, I am not sure if the released version also has this situation"),

    -- Ragebot safety settings | 4/20/2023 - disabled now.
    --safepoint = nick.ref.ragebot_safety:switch("Force Safe Point"),
    --baim = nick.ref.ragebot_safety:switch("Force Body Aim"),
    --hs = nick.ref.ragebot_safety:switch("Only Head"),

    -- Fakelag
    --built_in = nick.ref.fakelag:slider("Advance Limit",0, 64):tooltip("Some reasons. we need to create new slider here."),
    on_shot = nick.ref.fakelag:switch("No fakelag on shots"):tooltip("Disable choke to hide shots when every shot"),
    alwayschoke = nick.ref.fakelag:switch("Always choke"):tooltip("Allows you not to use Neverlose's built-in Variability logic."),

    -- Antiaim
    manual_aa = nick.ref.aa_misc:combo("Manual AA", "None", "Left", "Backwards", "Right", "Forwards"):tooltip("Change your Head Yaw\n\n\aF7FF8FFFThis will disable FS"),

    -- Missed sound
    miss = nick.ref.world:switch("Miss sound"),

    -- Main
    killsay = nick.ref.main:switch("Kill say"),

    -- DT TP In Air
    tp_enabled = nick.ref.dt_inside:switch("Teleport in air (BETA)"):tooltip("automatic telpeort in air when found the threats\n\nThis trait reduces accuracy and firing speed"),

    -- DT speed
    exploit_speed = nick.ref.dt_inside:slider("Fire speed", 6, 30, 14):tooltip("Changed Exploits charge time and fire rate"),

    -- Indicators
    enabled_indicators = nick.ref.world:switch("Skeet Indicators"),

    -- Movement settings
    fast_fall = nick.ref.movement:switch("Fast fall (BETA)"):tooltip("\aF7FF8FFFTESTING!!\n\n\aDEFAULTSet the clock cycle of the state to in air, and the clock cycle is 0 to perform Teleport"),

    --Force sv_cheats 1 and sv_pure
    sv_cheats = nick.ref.main_other:switch("Force sv_cheats"):tooltip("Allows you to use console commands that require sv_cheats."),
    sv_pure = nick.ref.main_other:switch("Bypass sv_pure"):tooltip("Disable file checking for the server. Allows you to use third party edit game files (e.g: Weapons models and Players models)"),

    -- Defensive AA
    defenisve = nick.ref.angles:switch("Exploits Defensive AA"):tooltip("\aF7FF8FFFTESTING!!\n\n\aDEFAULTQuick Jitter Yaw or Pitch"),

    -- Custom ViewModel
    viewmodel = nick.ref.world_main:switch("Custom Viewmodel"),

}

nick.CreateElements = {
    idealtick_settings = nick.menu.ospeek:create(),
    fl_limit = nick.ref.fakelag_limit:create(),
    onshot_settings = nick.menu.on_shot:create(),
    choke_settings = nick.menu.alwayschoke:create(),
    slowwalk = nick.ref.slowwalk:create(),
    miss_settings = nick.menu.miss:create(),
    killsay_settings = nick.menu.killsay:create(),
    fast_fall_settings = nick.menu.fast_fall:create(),
    defenisve_settings = nick.menu.defenisve:create(),
    viewmodel_settings = nick.menu.viewmodel:create(),
}

nick.ospeek = {
    breaklc = nick.CreateElements.idealtick_settings:switch("Break LC"):tooltip("Breaking the backtracking. Avoid enemies hitting you backtrack when you returning.")
}


nick.smfl = {
    --mode = nick.CreateElements.onshot_settings:combo("Mode", "No choke", "Overrides")
}

nick.force_choke = {
    mode = nick.CreateElements.choke_settings:combo("Mode", "Limit", "Maximum choke")
}

nick.miss_sound = {
    file = nick.CreateElements.miss_settings:input("Sound"):tooltip("Put the sound files in [csgo folder]/sounds")
}

nick.killsay = {
    text = nick.CreateElements.killsay_settings:input("Text")
}

nick.slowwalk_settings = {
    mode  = nick.CreateElements.slowwalk:combo("Mode", "Static", "Perfect Aimbot"),
    speed = nick.CreateElements.slowwalk:slider("Speed", 0, 120, 120)
}

nick.in_game_settings = {
    vote_reveals = nick.ref.ingame:switch("Vote reveals (BETA)"),
}

nick.fast_fall = {
    timer = nick.CreateElements.fast_fall_settings:slider("Fall time", 0.5, 10, 0, 0.1)
}

nick.defensive_settings = {
    mode = nick.CreateElements.defenisve_settings:combo("Mode", "Custom", "Preset - Random", "Preset - Jitter"),
    inair = nick.CreateElements.defenisve_settings:switch("Only in air"),
    pitch = nick.CreateElements.defenisve_settings:combo("Pitch", "Disabled", "Down", "Fake Down", "Fake Up", "Random", "Jitter"),
    yaw = nick.CreateElements.defenisve_settings:combo("Yaw", "Backward", "Random", "Jitter", "Spin"),
}

nick.customviewmodel_settings = {
    fov = nick.CreateElements.viewmodel_settings:slider("Fov", 0, 100, 90),
    x   = nick.CreateElements.viewmodel_settings:slider("X", - 15, 15, 0),
    y   = nick.CreateElements.viewmodel_settings:slider("Y", - 15, 15, 0),
    z   = nick.CreateElements.viewmodel_settings:slider("Z", - 15, 15, 0)
}

nick.settings = function ()

    --nick.smfl.mode:visibility(nick.menu.on_shot:get())
    nick.force_choke.mode:visibility(nick.menu.alwayschoke:get())
    nick.slowwalk_settings.speed:visibility(nick.slowwalk_settings.mode:get() == "Static")
    nick.defensive_settings.pitch:visibility(nick.defensive_settings.mode:get() == "Custom")
    nick.defensive_settings.yaw:visibility(nick.defensive_settings.mode:get() == "Custom")

    nick.defensive_settings.inair:visibility(false) -- Broken lol

    nick.menu.alwayschoke:visibility(false)

end


nick.CffiHelper = {
    PlaySound = (function()
		local PlaySound = utils.get_vfunc("engine.dll", "IEngineSoundClient003", 12, "void*(__thiscall*)(void*, const char*, float, int, int, float)")
		return function(sound_name, volume)
			local name = sound_name:lower():find(".wav") and sound_name or ("%s.wav"):format(sound_name)
			pcall(PlaySound, name, tonumber(volume) / 100, 100, 0, 0)
		end
	end)()
}



events.render:set(function()
    if ui.get_alpha() == 1 then nick.settings() end
end)



-- Teleport
nick.menu.tp:set_callback(function()
    if nick.menu.tp:get() then
        rage.exploit:force_teleport()
    end
end)



-- Anti Defensive
nick.menu.ax:set_callback(function()
    if nick.menu.ax:get() then
        cvar.cl_lagcompensation:int(0)
    else
        cvar.cl_lagcompensation:int(1)
    end
end)



-- OS Peek
events.render:set(function()

    local localplayer = entity.get_local_player()
    if not localplayer then return end

    local my_weapon = localplayer:get_player_weapon()

    if nick.ospeek.breaklc:get() then
        nick.ref.hs_options:override("Break LC")
    else
        nick.ref.hs_options:override()
    end

    if my_weapon then
        local last_shot_time = my_weapon["m_fLastShotTime"]
		local time_difference = globals.curtime - last_shot_time
    
        if nick.menu.ospeek:get() then
    
            nick.ref.autopeek:override(true)
            if time_difference <= 0.5 and time_difference >= 0.255 then
                nick.ref.hideshot:override(false)
            elseif time_difference >= 0.5 then
                nick.ref.hideshot:override(true)
            end
        else
            nick.ref.hs_options:override()
            nick.ref.autopeek:override()
            nick.ref.hideshot:override()
        end
    end

end)



-- Jump scout fix
-- This may conflict with v1pix's Helper. Since I am a beta user, I am not sure if the released version also has this situation.
events.render:set(function()

    local localplayer = entity.get_local_player()
    if not localplayer then return end
    
    local vel = localplayer.m_vecVelocity
    local speed = math.sqrt(vel.x * vel.x + vel.y * vel.y)

    if nick.menu.jump:get() then
        nick.ref.autostrafe:override(math.floor(speed) > 15)
    end
end)



-- Maxmium choke

-- events.createmove:set(function(cmd)
--     if nick.ref.dt:get() then
--         cvar.sv_maxusrcmdprocessticks:int(nick.menu.exploit_speed:get() + 1)
--     else
--         cvar.sv_maxusrcmdprocessticks:int(nick.menu.built_in:get() + 1)
--     end
-- end)

-- No fakelag on shots

events.createmove:set(function(cmd)
    local localplayer = entity.get_local_player()
    if not localplayer then return end

    local my_weapon = localplayer:get_player_weapon()


    if my_weapon then
        local last_shot_time = my_weapon["m_fLastShotTime"]
		local time_difference = globals.curtime - last_shot_time

        if nick.menu.on_shot:get() then
            if nick.ref.fl_enabled:get() then
                if time_difference <= 0.025 then
                    cmd.no_choke = true
                    cmd.send_packet = true

                    nick.ref.fakelag_limit:override(0)
                    nick.ref.aa_enabled:override(false)
                    nick.ref.fl_enabled:override(false)
                    nick.ref.desync:override(false)
                else
                    cmd.no_choke = false

                    nick.ref.fakelag_limit:override()
                    nick.ref.aa_enabled:override()
                    nick.ref.fl_enabled:override()
                    nick.ref.desync:override()
                end
            end
        end
    end
end)




-- Manual AA
events.render:set(function()

    if nick.menu.manual_aa:get() == "None" then
        nick.ref.yaw_offset:override()
        nick.ref.yaw_base:override()
        nick.ref.yaw:override()
        nick.ref.fs:override()
    elseif nick.menu.manual_aa:get() == "Left" then
        nick.ref.yaw_offset:override(-90)
        nick.ref.yaw_base:override("Local View")
        nick.ref.yaw:override("Backward")
        nick.ref.fs:override(false)
    elseif nick.menu.manual_aa:get() == "Backwards" then
        nick.ref.yaw_offset:override(0)
        nick.ref.yaw_base:override("Local View")
        nick.ref.yaw:override("Backward")
        nick.ref.fs:override(false)
    elseif nick.menu.manual_aa:get() == "Right" then
        nick.ref.yaw_offset:override(90)
        nick.ref.yaw_base:override("Local View")
        nick.ref.yaw:override("Backward")
        nick.ref.fs:override(false)
    elseif nick.menu.manual_aa:get() == "Forwards" then
        nick.ref.yaw_offset:override(180)
        nick.ref.yaw_base:override("Local View")
        nick.ref.yaw:override("Backward")
        nick.ref.fs:override(false)
    end

end)


-- Always choke
events.createmove:set(function(e)
    if nick.ref.fl_enabled:get() then
        if nick.menu.alwayschoke:get() then
            if nick.force_choke.mode:get() == "Limit" then
                e.send_packet = e.choked_commands >= nick.ref.fakelag_limit:get()
            elseif nick.force_choke.mode:get() == "Maximum choke" then
                e.send_packet = false
            end
        end
    end
end)



-- Miss sound
events.aim_ack:set(function(e)
    if e.state ~= nil then
        if nick.menu.miss:get() then
            -- if files.read(nick.miss_sound.file:get()) == nil then return end
    
            nick.CffiHelper.PlaySound(nick.miss_sound.file:get(), 65)
        end
    end
end)



-- Killsay
events.aim_ack:set(function(e)
    local target = e.target
    local get_target_entity = entity.get(target)
    if not get_target_entity then return end
    
    local health = get_target_entity.m_iHealth

    if not target:get_name() or not health then return end
    
    if not nick.menu.killsay:get() then
        return end
    if health == 0 then
        utils.console_exec("say " .. nick.killsay.text:get())
    end

end)


-- Slow walk settings
events.createmove:set(function(cmd)

    local mode = nick.slowwalk_settings.mode:get()
    local speed = nick.slowwalk_settings.speed:get()


    -- Credit by @SYR2018
    local current_speed = speed or 100
	local min_speed = math.sqrt((cmd.forwardmove * cmd.forwardmove) + (cmd.sidemove * cmd.sidemove))

    if cmd.in_speed then
        if mode == "Static" then
		    if min_speed > current_speed then
		    	local speed_factor = current_speed / min_speed
		    	cmd.sidemove = cmd.sidemove * speed_factor
		    	cmd.forwardmove = cmd.forwardmove * speed_factor
		    end
        elseif mode == "Perfect Aimbot" then
            cmd.block_movement = 1
        else
            cmd.block_movement = 0
        end
    end


end)


-- Vote reveals
-- Source from: https://en.neverlose.cc/market/item?id=7IeKYA
-- It may be not working
-- This event only on https://wiki.alliedmods.net/Generic_Source_Events
events.vote_cast:set(function(e)

    if not nick.in_game_settings.vote_reveals:get() then return end

    local team = e.team
    local voteOption = e.vote_option == 0 and "YES" or "NO"

    local user = entity.get(e.entityid)
	local userName = user:get_name()

    print(("%s voted %s"):format(userName, voteOption))
    print_dev(("%s voted %s"):format(userName, voteOption))

end)



-- Teleport in air
events.createmove:set(function(cmd)

    local threat = entity.get_threat(true)


    local prop = entity.get_local_player()["m_fFlags"]

    if not nick.menu.tp_enabled:get() then return end

    if prop == 256 or prop == 262 then
        if threat and nick.ref.dt:get() then
            rage.exploit:force_teleport()
        end
    end

end)








-- Indicators

local font = render.load_font("c:/windows/fonts/calibrib.ttf", 28, "ad")

events.render:set(function()

    local screen_x = render.screen_size().x
    local screen_y = render.screen_size().y


    if not nick.menu.enabled_indicators:get() then return end
    if not globals.is_connected == true then return end

    if ui.find("Aimbot", "Ragebot", "Main", "\aF7FF8FFFAnti Defensive"):get() then
        render.text(font, vector(20,screen_y / 2 + 150 + 80), color("FFD65A"), "", "AX")
    end

    if nick.ref.dt:get() then
        if rage.exploit:get() == 0 then
            charge_color = color("ff0000")
        else
            charge_color = color("cccccd")
        end

        render.text(font, vector(20,screen_y / 2 + 150 - 80), charge_color, "", "DT")
    elseif nick.ref.hideshot:get() then

        if rage.exploit:get() == 0 then
            hs_color = color("ff0000")
        else
            hs_color = color("cccccd")
        end

        render.text(font, vector(20,screen_y / 2 + 150 - 80), hs_color, "", "ON SHOT")
    end

    if nick.ref.fs:get()then
        render.text(font, vector(20,screen_y / 2 + 150 - 40), color("cccccd"), "", "FS")
    elseif nick.ref.fs:get_override() == false then
        if ui.find("Aimbot", "Anti Aim", "Misc", "Manual AA"):get() ~= "None" then
            render.text(font, vector(20,screen_y / 2 + 150 - 40), color("cccccd"), "", string.upper(ui.find("Aimbot", "Anti Aim", "Misc", "Manual AA"):get()))
        end
    end
    
    render.text(font, vector(20,screen_y / 2 + 150), color("7fbd14"), "", "DMG: " .. ui.find("Aimbot", "Ragebot", "Selection", "Min. Damage"):get())
    render.text(font, vector(20,screen_y / 2 + 150 + 40), color("7fbd14"), "", "HC: " .. ui.find("Aimbot", "Ragebot", "Selection", "Hit Chance"):get())



end)






-- Fast fall

local realtime = globals.realtime
local lasttime = globals.realtime

events.render:set(function()

    local localplayer = entity.get_local_player()
    if not localplayer then return end

    local prop = localplayer["m_fFlags"]

    if not nick.menu.fast_fall:get() then return end

    

    if prop == 256 or prop == 262 then
        realtime = globals.realtime
        
        if realtime - lasttime > nick.fast_fall.timer:get() * 0.1 + 0.05 and (realtime - lasttime) >= 0.005 and (realtime - lasttime) ~= 0.004 then
            rage.exploit:force_teleport()
            lasttime = realtime
        end
    else
        realtime = 0
        lasttime = 0
    end

    if realtime < lasttime then

            realtime = globals.realtime
            lasttime = globals.realtime


    end

end)

-- Force sv_cheats 1 and bypass sv_pure

events.render:set(function()

    if nick.menu.sv_cheats:get() then
        cvar.sv_cheats:int(1)
    else
        cvar.sv_cheats:int()
    end

    if nick.menu.sv_pure:get() then
        cvar.sv_pure:int(0)
    else
        cvar.sv_pure:int()
    end

end)

-- Force baim/safepoint and OS only (I hope it's work)

local nick_safepoint = {}
local nick_baim = {}
local nick_os = {}

nick_safepoint = {
    globals         = nick.rage_ref.globals    :switch("Force Safe Point"),
    ssg08           = nick.rage_ref.ssg08      :switch("Force Safe Point"),
    pistols         = nick.rage_ref.pistols    :switch("Force Safe Point"),
    autosnipers     = nick.rage_ref.autosnipers:switch("Force Safe Point"),
    snipers         = nick.rage_ref.snipers    :switch("Force Safe Point"),
    rifles          = nick.rage_ref.rifles     :switch("Force Safe Point"),
    smgs            = nick.rage_ref.smgs       :switch("Force Safe Point"),
    shotguns        = nick.rage_ref.shotguns   :switch("Force Safe Point"),
    machineguns     = nick.rage_ref.machineguns:switch("Force Safe Point"),
    awp             = nick.rage_ref.awp        :switch("Force Safe Point"),
    ak47            = nick.rage_ref.ak47       :switch("Force Safe Point"),
    m4a1            = nick.rage_ref.m4a1       :switch("Force Safe Point"),
    eagle           = nick.rage_ref.eagle      :switch("Force Safe Point"),
    revolver        = nick.rage_ref.revolver   :switch("Force Safe Point"),
    aug             = nick.rage_ref.aug        :switch("Force Safe Point"),
    taser           = nick.rage_ref.taser      :switch("Force Safe Point"),
}

nick_baim = {
    globals         = nick.rage_ref.globals    :switch("Force Baim"),
    ssg08           = nick.rage_ref.ssg08      :switch("Force Baim"),
    pistols         = nick.rage_ref.pistols    :switch("Force Baim"),
    autosnipers     = nick.rage_ref.autosnipers:switch("Force Baim"),
    snipers         = nick.rage_ref.snipers    :switch("Force Baim"),
    rifles          = nick.rage_ref.rifles     :switch("Force Baim"),
    smgs            = nick.rage_ref.smgs       :switch("Force Baim"),
    shotguns        = nick.rage_ref.shotguns   :switch("Force Baim"),
    machineguns     = nick.rage_ref.machineguns:switch("Force Baim"),
    awp             = nick.rage_ref.awp        :switch("Force Baim"),
    ak47            = nick.rage_ref.ak47       :switch("Force Baim"),
    m4a1            = nick.rage_ref.m4a1       :switch("Force Baim"),
    eagle           = nick.rage_ref.eagle      :switch("Force Baim"),
    revolver        = nick.rage_ref.revolver   :switch("Force Baim"),
    aug             = nick.rage_ref.aug        :switch("Force Baim"),
    taser           = nick.rage_ref.taser      :switch("Force Baim"),
}

nick_os = {
    globals         = nick.rage_ref.globals    :switch("Only Head"),
    ssg08           = nick.rage_ref.ssg08      :switch("Only Head"),
    pistols         = nick.rage_ref.pistols    :switch("Only Head"),
    autosnipers     = nick.rage_ref.autosnipers:switch("Only Head"),
    snipers         = nick.rage_ref.snipers    :switch("Only Head"),
    rifles          = nick.rage_ref.rifles     :switch("Only Head"),
    smgs            = nick.rage_ref.smgs       :switch("Only Head"),
    shotguns        = nick.rage_ref.shotguns   :switch("Only Head"),
    machineguns     = nick.rage_ref.machineguns:switch("Only Head"),
    awp             = nick.rage_ref.awp        :switch("Only Head"),
    ak47            = nick.rage_ref.ak47       :switch("Only Head"),
    m4a1            = nick.rage_ref.m4a1       :switch("Only Head"),
    eagle           = nick.rage_ref.eagle      :switch("Only Head"),
    revolver        = nick.rage_ref.revolver   :switch("Only Head"),
    aug             = nick.rage_ref.aug        :switch("Only Head"),
    taser           = nick.rage_ref.taser      :switch("Only Head"),
}

local weapons = {"globals","ssg08","pistols","autosnipers","snipers","rifles","smgs","shotguns","machineguns","awp","ak47","m4a1","eagle","revolver","aug","taser"}


events.render:set(function()
    -- first time used a "For" loop XD

    for k,v in ipairs(weapons) do

        if nick_safepoint[v]:get() then nick.rage_sp[v]:override("Force") else nick.rage_sp[v]:override() end

        if nick_baim[v]:get() then nick.rage_baim[v]:override("Force") else nick.rage_baim[v]:override() end

        if nick_os[v]:get() then
            nick.rage_hb[v]:override("Head")
            nick.rage_mp[v]:override("Head")
        else
            nick.rage_hb[v]:override()
            nick.rage_mp[v]:override()
        end

    end
    
end)



-- Defensive AA
events.createmove:set(function(cmd)

    local os = ui.find("Aimbot", "Ragebot", "Main", "Hide Shots"):get()
    local dt = ui.find("Aimbot", "Ragebot", "Main", "Double Tap"):get()

    local exploit_state = os or dt -- You need always send the packets.

    local localplayer = entity.get_local_player()
    if not localplayer then return end

    local prop = localplayer["m_fFlags"]

    local pitch_s = nick.defensive_settings.pitch:get()
    local yaw_s = nick.defensive_settings.yaw:get()

    local inair_t = nil

    if nick.menu.defenisve:get() and exploit_state then

        ui.find("Aimbot", "Ragebot", "Main", "Double Tap", "Lag Options"):override("Always On")

        if nick.defensive_settings.mode:get() == "Custom" then

            if pitch_s == "Disabled" then
                nick.ref.pitch:override("Disabled")
            elseif pitch_s == "Down" then
                nick.ref.pitch:override("Down")
            elseif pitch_s == "Fake Down" then
                nick.ref.pitch:override("Fake Down")
            elseif pitch_s == "Fake Up" then
                nick.ref.pitch:override("Fake Up")
            elseif pitch_s == "Random" then
                value = math.random(3)
                if value == 1 then
                    nick.ref.pitch:override("Down")
                elseif value == 2 then
                    nick.ref.pitch:override("Disabled")
                elseif value == 3 then
                    nick.ref.pitch:override("Fake Up")
                end
                
            elseif pitch_s == "Jitter" then
                if (math.floor(globals.curtime * 100000) % 2) == 0 then
                    nick.ref.pitch:override("Down")
                else
                    nick.ref.pitch:override("Fake Up")
                end
            end

            if yaw_s == "Backward" then
                nick.ref.yaw:override("Backward")
                nick.ref.yaw_offset:override(0)
            elseif yaw_s == "Random" then
                nick.ref.yaw_offset:override(math.random(-89, 100))
            elseif yaw_s == "Jitter" then
                if (math.floor(globals.curtime * 100000) % 2) == 0 then
                    nick.ref.yaw_offset:override(48)
                else
                    nick.ref.yaw_offset:override(-50)
                end
            elseif yaw_s == "Spin" then                   
                nick.ref.yaw_offset:override(math.random(-180, 180))
            end

                
        elseif nick.defensive_settings.mode:get() == "Preset - Random" then
            value = math.random(3)
            if value == 1 then
                nick.ref.pitch:override("Down")
            elseif value == 2 then
                nick.ref.pitch:override("Disabled")
            elseif value == 3 then
                nick.ref.pitch:override("Fake Up")
            end

            nick.ref.yaw_offset:override(math.random(-89, 100))

        elseif nick.defensive_settings.mode:get() == "Preset - Jitter" then

            if (math.floor(globals.curtime * 100000) % 2) == 0 then
                nick.ref.pitch:override("Down")
                nick.ref.yaw_offset:override(48)
            else
                nick.ref.pitch:override("Fake Up")
                nick.ref.yaw_offset:override(-50)
            end

        end

    else
        ui.find("Aimbot", "Ragebot", "Main", "Double Tap", "Lag Options"):override("Always On")
    end
    
end)


-- Custom Viewmodel

events.render:set(function()

    fov = nick.customviewmodel_settings.fov:get() 
    x   = nick.customviewmodel_settings.x:get() 
    y   = nick.customviewmodel_settings.y:get()
    z   = nick.customviewmodel_settings.z:get()

    if nick.menu.viewmodel:get() then
        cvar["sv_competitive_minspec"]:int(0)
        cvar["viewmodel_fov"]:float(fov)
        cvar["viewmodel_offset_x"]:float(x)
        cvar["viewmodel_offset_y"]:float(y)
        cvar["viewmodel_offset_z"]:float(z)
    else
        cvar["sv_competitive_minspec"]:int()
        cvar["viewmodel_fov"]:float(90)
        cvar["viewmodel_offset_x"]:float(0)
        cvar["viewmodel_offset_y"]:float(0)
        cvar["viewmodel_offset_z"]:float(0)
    end

end)

