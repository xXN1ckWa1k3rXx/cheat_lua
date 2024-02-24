--[[
    Better GameSense
    Author: xXYu3_zH3nGL1ngXx
    Branch: Live
        - 2/24/2024
]]

local ffi = require "ffi"
local weapondata = require "gamesense/csgo_weapons"
local vector = require "vector"

local __version = "Live 1.0"

------------------------------------------------------

__UPDATELOG = {
    "2/24/2024 - Changelog",
    "    - Release live version",
    "        ",
}

ui.new_label("lua", "a", "Better GameSense")
ui.new_label("lua", "a", "Version: " .. __version)
ui.new_label("lua", "a", "          ")

for i, v in ipairs (__UPDATELOG) do
    ui.new_label("lua", "a", v)
end
ui.new_label("lua", "a", "          ")

print("Welcome use Better GameSense. Current version is " .. __version)

----------------------------------------------------

local native_get_client_entity = vtable_bind("client.dll", "VClientEntityList003", 3, "void*(__thiscall*)(void*, int)")
local animstate_t = ffi.typeof 'struct { char pad0[0x18]; float anim_update_timer; char pad1[0xC]; float started_moving_time; float last_move_time; char pad2[0x10]; float last_lby_time; char pad3[0x8]; float run_amount; char pad4[0x10]; void* entity; void* active_weapon; void* last_active_weapon; float last_client_side_animation_update_time; int	 last_client_side_animation_update_framecount; float eye_timer; float eye_angles_y; float eye_angles_x; float goal_feet_yaw; float current_feet_yaw; float torso_yaw; float last_move_yaw; float lean_amount; char pad5[0x4]; float feet_cycle; float feet_yaw_rate; char pad6[0x4]; float duck_amount; float landing_duck_amount; char pad7[0x4]; float current_origin[3]; float last_origin[3]; float velocity_x; float velocity_y; char pad8[0x4]; float unknown_float1; char pad9[0x8]; float unknown_float2; float unknown_float3; float unknown; float m_velocity; float jump_fall_velocity; float clamped_velocity; float feet_speed_forwards_or_sideways; float feet_speed_unknown_forwards_or_sideways; float last_time_started_moving; float last_time_stopped_moving; bool on_ground; bool hit_in_ground_animation; char pad10[0x4]; float time_since_in_air; float last_origin_z; float head_from_ground_distance_standing; float stop_to_full_running_fraction; char pad11[0x4]; float magic_fraction; char pad12[0x3C]; float world_force; char pad13[0x1CA]; float min_yaw; float max_yaw; } **'
local animlayer_t = ffi.typeof 'struct { char pad_0x0000[0x18]; uint32_t sequence; float prev_cycle; float weight; float weight_delta_rate; float playback_rate; float cycle;void *entity;char pad_0x0038[0x4]; } **'

----------------------------------------------------

local nick = {} -- dont touch it

nick.data = {
    conditions = {"Globals", "Standing", "Running", "Walking", "Crouching", "In Air", "In Air + Crouching"},

	LastOutChoked = 0,
	LastOutGoing = 0,
	fakelag_limit = 0,

    aa_menu_item = {},
    defensive_aa_item = {},
    fakelag_item = {},

    animation = {
        data = {}
    },

    hitlog = {
        backtrack = nil,
        flag = nil,
    },

    aa = {
        pitch = nil,
        __pitch = 0,
        yaw_base = nil,
        yaw = nil,
        __yaw = 0,
        yaw_jitter = nil,
        __yaw_jitter = 0,
        body_yaw = nil,
        __body_yaw = 0,
        freestanding_body_freestanding = nil,
        freestanding = nil,
        edge_yaw = nil,
        roll = 0,
    },

    defensive = {
        def = false,
        defensive_tk = 0,
        pitch = 0,
        yaw = 0,
    },

    manual = {
        manual_side = 0,
        active = false,
        last = nil,
        now = nil,
    },

    fl = {
        mode = nil,
        variance = 0,
        limit = 0,
    },
}

nick.ref = {
    rage = {
        double_tap = {ui.reference("rage", "aimbot", "Double tap")},
        resolver = ui.reference("rage", "other", "anti-aim correction"),
    },
    antiaim = {
        aa_enabled = ui.reference("aa", "anti-aimbot angles", "Enabled"),
        pitch = {ui.reference("aa", "anti-aimbot angles", "Pitch")},
        yaw_base = ui.reference("aa", "anti-aimbot angles", "Yaw base"),
        yaw = {ui.reference("aa", "anti-aimbot angles", "Yaw")},
        yaw_jitter = {ui.reference("aa", "anti-aimbot angles", "Yaw jitter")},
        body_yaw = {ui.reference("aa", "anti-aimbot angles", "Body Yaw")},
        freestanding_body_yaw = ui.reference("aa", "anti-aimbot angles", "Freestanding body yaw"),
        edge_yaw = ui.reference("aa", "anti-aimbot angles", "Edge yaw"),
        freestanding = {ui.reference("aa", "anti-aimbot angles", "Freestanding")},
        roll = ui.reference("aa", "anti-aimbot angles", "Roll"),

        fl_enabled = {ui.reference("aa", "fake lag", "Enabled")},
        amount = ui.reference("aa", "fake lag", "Amount"),
        variance = ui.reference("aa", "fake lag", "Variance"),
        limit = ui.reference("aa", "fake lag", "Limit"),

        slow_walk = {ui.reference("aa", "other", "Slow motion")},
        leg_movement = ui.reference("aa", "other", "Leg movement"),
        on_shot = {ui.reference("aa", "other", "On shot anti-aim")},
    },
    visuals = {
        remove_fog = ui.reference("visuals", "effects", "Remove fog"),
        thrid_person = {ui.reference("visuals", "effects", "Force third person (alive)")},
    },
    misc = {
        air_strafe = ui.reference("misc", "movement", "air strafe"),
    },
}

----------------------

-- @region user functions

----------------------

local a = function (...) return ... end

math.normalize_yaw = function (yaw) return (yaw + 180) % -360 + 180 end
math.clamp = function (x, a, b) if a > x then return a elseif b < x then return b else return x end end

entity.get_simtime = function (ent)
    local pointer = native_get_client_entity(ent)
    if pointer then return entity.get_prop(ent, "m_flSimulationTime"), ffi.cast("float*", ffi.cast("uintptr_t", pointer) + 0x26C)[0] else return 0 end
end

entity.get_animstate = function (ent)
    local pointer = native_get_client_entity(ent)
    if pointer then return ffi.cast(animstate_t, ffi.cast("char*", ffi.cast("void***", pointer)) + 0x9960)[0] end
end

entity.get_max_desync = function (animstate)
    local speedfactor = math.clamp(animstate.feet_speed_forwards_or_sideways, 0, 1)
    local avg_speedfactor = (animstate.stop_to_full_running_fraction * -0.3 - 0.2) * speedfactor + 1

    local duck_amount = animstate.duck_amount
    if duck_amount > 0 then
        local duck_speed = duck_amount * speedfactor

        avg_speedfactor = avg_speedfactor + (duck_speed * (0.5 - avg_speedfactor))
    end

    return math.clamp(avg_speedfactor, .5, 1)
end

nick.ticks_switch = function (ticks, value1, value2)
    if math.floor(globals.tickcount() / ticks) % 2 == 0 then
		return value1
	else
		return value2
	end
end

nick.random_ticks_switch = function (ticks, value1, value2)
    if math.floor(globals.tickcount() / math.random(1,ticks)) % 2 == 0 then
		return value1
	else
		return value2
	end
end

nick.spin_num = function (spin_t, value1, value2)
    local spin = (globals.curtime() * spin_t) % 360 - 180
    local new_value = ((spin + 180) / 360) * (value2 - value1) + value1

    return new_value
end

nick.math_lerp = function(a, b, percentage)
    return a + (b - a) * percentage
end

nick.math_new_lerp = function(name, value, time)
    if nick.data.animation.data[name] == nil then
        nick.data.animation.data[name] = 0
    end
    nick.data.animation.data[name] = nick.math_lerp(nick.data.animation.data[name], value, time)
    return nick.data.animation.data[name]
end


nick.get_condition = function ()
    local localplayer = entity.get_local_player()
    if not localplayer then return 99 end

    local vec = vector(entity.get_prop(localplayer, "m_vecVelocity"))
    local velocity = math.sqrt((vec.x * vec.x) + (vec.y * vec.y)) 

    if ui.get(nick.ref.antiaim.slow_walk[2]) then 
        return "Walking"
    elseif entity.get_prop(localplayer, "m_fFlags") == 262 and entity.get_prop(localplayer, "m_flDuckAmount") > 0.8 then
        return "In Air + Crouching"
    elseif entity.get_prop(localplayer, "m_fFlags") == 256 then
        return "In Air"
    elseif entity.get_prop(localplayer, "m_flDuckAmount") > 0.8 then
        return "Crouching"
    elseif velocity <= 2 then
        return "Standing"
    elseif velocity >= 3 then
        return "Running"
    end
end

nick.get_rainbow = function(rate, rgb_split_ratio, rgb_alpha)
	local rgb_color = {1.0, 1.0, 1.0, 1.0}
	local frequency = (globals.realtime() * rate)
	local traverse_times = math.floor(frequency * 6)
	local cycles_traverse_times = traverse_times % 6
	local frequency_delta = frequency * 6 - traverse_times
	local frequency_update_color_1 = (1 - frequency_delta)
	local frequency_update_color_2 = (1 - (1 - frequency_delta))
	if cycles_traverse_times == 0 then
		rgb_color = {1.0, frequency_update_color_2, 0, 1.0}
	elseif cycles_traverse_times == 1 then
		rgb_color = {frequency_update_color_1, 1.0, 0, 1.0}
	elseif cycles_traverse_times == 2 then
		rgb_color = {0, 1.0, frequency_update_color_2, 1.0}
	elseif cycles_traverse_times == 3 then
		rgb_color = {0, frequency_update_color_1, 1.0, 1.0}
	elseif cycles_traverse_times == 4 then
		rgb_color = {frequency_update_color_2, 0, 1.0, 1.0}
	elseif cycles_traverse_times == 5 then
		rgb_color = {1.0, 0, frequency_update_color_1, 1.0}
	end

	return vector(
		(rgb_color[1] * rgb_split_ratio) * 255,
		(rgb_color[2] * rgb_split_ratio) * 255,
		(rgb_color[3] * rgb_split_ratio) * 255
	)
end

nick.is_shift = function ()
    local localplayer = entity.get_local_player()
    if not localplayer then return end

    local tickcount = globals.tickcount()
    local m_nTickBase = entity.get_prop(localplayer, "m_nTickBase")

    return tickcount > m_nTickBase
end

nick.get_defensive = function ()

    local localplayer = entity.get_local_player()
    if not localplayer then return end

    if localplayer == nil or not entity.is_alive(localplayer) then
        return
    end

    local Entity = native_get_client_entity(localplayer)
    local m_flOldSimulationTime = ffi.cast("float*", ffi.cast("uintptr_t", Entity) + 0x26C)[0]
    local m_flSimulationTime = entity.get_prop(localplayer, "m_flSimulationTime")

    local delta = m_flOldSimulationTime - m_flSimulationTime

    if delta > 0 then
        nick.data.defensive.defensive_tk = globals.tickcount() + toticks(delta - client.real_latency())
    end
end

----------------------

-- @region items

----------------------

nick.items = {
    rage = {
        jump_scout = ui.new_checkbox("rage", "other", "Static Jump scout"),
        hitlog = ui.new_checkbox("rage", "other", "Enabled aimbot log"),
        correction = ui.new_checkbox("rage", "other", "Extra correction"),
        correction_selection = ui.new_combobox("rage", "other", "\n", {"Disabled", "Random body yaw >:)", "Jitter correction"}),
        disable_correction = ui.new_checkbox("rage", "other", "Disabled correction on taser"),
    },
    antiaim = {
        enabled = ui.new_checkbox("aa", "anti-aimbot angles", "[Better GS] Enabled AntiAim"),
        aa_conditions = ui.new_combobox("aa", "anti-aimbot angles", "Settings - AA Conditon", nick.data.conditions),

        aa_item = (function()
            for i, v in ipairs (nick.data.conditions) do
                nick.data.aa_menu_item[i] = {
                    override = ui.new_checkbox("aa", "anti-aimbot angles", ("%s - Override globals settings"):format(v)),
                    pitch = ui.new_combobox("aa", "anti-aimbot angles", ("%s - Pitch"):format(v), {"Off", "Default", "Up", "Down", "Minimal", "Random", "Custom"}),
                    _pitch = ui.new_slider("aa", "anti-aimbot angles", "\n pitch value", -89, 89, 0, true, "°"),
                    yaw_base = ui.new_combobox("aa", "anti-aimbot angles", ("%s - Yaw base"):format(v), {"Local view", "At targets"}),
                    yaw = ui.new_combobox("aa", "anti-aimbot angles", ("%s - Yaw"):format(v), {"Off", "180", "Spin", "Static", "180Z", "Crosshair"}),
                    _yaw = ui.new_slider("aa", "anti-aimbot angles", "\n yaw value", -180, 180, 0, true, "°"),
                    yaw_jitter = ui.new_combobox("aa", "anti-aimbot angles", ("%s - Yaw Jitter"):format(v), {"Off", "Offset", "Center", "Random", "Skitter", "[Better GS] 3-Way [WIP]", "[Better GS] 5-Way [WIP]"}),
                    _yaw_jitter = ui.new_slider("aa", "anti-aimbot angles", "\n jitter value", -180, 180, 0),
                    body_yaw = ui.new_combobox("aa", "anti-aimbot angles", ("%s - Body yaw"):format(v), {"Off", "Opposite", "Jitter", "Static"}),
                    _body_yaw = ui.new_slider("aa", "anti-aimbot angles", "\n body yaw", -180, 180, 0, true, "°"),
                    freestanding_body_yaw = ui.new_checkbox("aa", "anti-aimbot angles", ("%s - Freestanding body yaw"):format(v)),
                    edge_yaw = ui.new_checkbox("aa", "anti-aimbot angles", ("%s - Edge yaw"):format(v)),
                    roll = ui.new_slider("aa", "anti-aimbot angles", ("%s - Extended roll"):format(v), -45, 45, 0, true, "°"),
                }
            end
        end)(),
        freestanding = ui.new_hotkey("aa", "anti-aimbot angles", "Freestanding", false, 0),
        inverter = ui.new_hotkey("aa", "anti-aimbot angles", "Body yaw Inverter", false, 0),
        manual_left = ui.new_hotkey("aa", "anti-aimbot angles", "Manual Yaw - Left", false, 0),
        manual_right = ui.new_hotkey("aa", "anti-aimbot angles", "Manual Yaw - Right", false, 0),
        manual_back = ui.new_hotkey("aa", "anti-aimbot angles", "Manual Yaw - Backwards", false, 0),

        ui.new_label("aa", "anti-aimbot angles", "          "),

        def_item = (function()
            for i, v in ipairs (nick.data.conditions) do
                nick.data.defensive_aa_item[i] = {
                    def_enabled = ui.new_checkbox("aa", "anti-aimbot angles", ("%s - Enabled defensive antiaim"):format(v)),
                    mode = ui.new_combobox("aa", "anti-aimbot angles", ("%s - Mode"):format(v), {"Disabled", "On Peek", "Always", "Enabled on auto stopping"}),
                    pitch = ui.new_combobox("aa", "anti-aimbot angles", ("%s - Pitch"):format(v), {"Default", "Up", "Down", "Static", "45°", "Jitter", "Random", "Defensive"}),
                    __ticks_p = ui.new_slider("aa", "anti-aimbot angles", ("%s - Delay tick(s)"):format(v), 0, 45, 0, true, "t"),
                    __pitch_1 = ui.new_slider("aa", "anti-aimbot angles", ("%s - Pitch 1"):format(v), -89, 89, 0, true, "°"),
                    __pitch_2 = ui.new_slider("aa", "anti-aimbot angles", ("%s - Pitch 2"):format(v), -89, 89, 0, true, "°"),
                    yaw = ui.new_combobox("aa", "anti-aimbot angles", ("%s - Yaw"):format(v), {"Default", "Zero", "Static", "Jitter", "Spin", "Sway", "Side-Way", "Random"}),
                    __ticks_y = ui.new_slider("aa", "anti-aimbot angles", ("%s - Delay tick(s)"):format(v), 0, 45, 0, true, "t"),
                    __yaw_1 = ui.new_slider("aa", "anti-aimbot angles", ("%s - Yaw 1"):format(v), -180, 180, 0, true, "°"),
                    __yaw_2 = ui.new_slider("aa", "anti-aimbot angles", ("%s - Yaw 2"):format(v), -180, 180, 0, true, "°"),
                }
            end
        end)()
    },
    fakelag = {
        enabled = ui.new_checkbox("aa", "fake lag", "[Better GS] Enabled Fake lag"),
        conditions = ui.new_combobox("aa", "fake lag", "Settings - FL Conditon", nick.data.conditions),
        fl_item = (function()
            for i, v in ipairs(nick.data.conditions) do
                nick.data.fakelag_item[i] = {
                    override = ui.new_checkbox("aa", "fake lag", ("%s - Override globals settings"):format(v)),
                    mode = ui.new_combobox("aa", "fake lag", ("%s - Mode"):format(v), {"Dynamic", "Maximum", "Fluctuate", "Randmized", "Jitter"}),
                    variance = ui.new_slider("aa", "fake lag", ("%s - Variance"):format(v), 0, 100, 0, true, "%"),
                    delay_ticks = ui.new_slider("aa", "fake lag", ("%s - Delay tick(s)"):format(v), 1, 40, 0, true, "t"),
                    limit_1 = ui.new_slider("aa", "fake lag", ("%s - Limit 1"):format(v), 1, 15, 0, true, "t"),
                    limit_2 = ui.new_slider("aa", "fake lag", ("%s - Limit 2"):format(v), 1, 15, 0, true, "t"),
                }
            end
        end)(),
        slient_shots = ui.new_checkbox("aa", "fake lag", "Slient shots"),
    },
    visuals = {
        bloom = ui.new_checkbox("visuals", "Effects", "Custom bloom"),
        bloom_warning = ui.new_label("visuals", "Effects", "   ⚠ The consequences of this operation may be irreversible"),

        bloom_reference = ui.new_slider("visuals", "Effects", "Bloom scale", -1, 500, -1, true, nil, 0.01, {[-1] = "Off"}),
        exposure_reference = ui.new_slider("visuals", "Effects", "Auto Exposure", -1, 2000, -1, true, nil, 0.001, {[-1] = "Off"}),
        model_ambient_min_reference = ui.new_slider("visuals", "Effects", "Minimum model brightness", 0, 1000, -1, true, nil, 0.05),

        fog_custom = ui.new_combobox("visuals", "Effects", "Fog changer", {"Default", "Clean", "Override"}),
        fog_color = ui.new_color_picker("visuals", "Effects", "Fog color", 255, 255, 255, 255),
        fog_start = ui.new_slider("visuals", "Effects", "Fog - Start", -200, 5000, 0, true, "ft."),
        fog_distance = ui.new_slider("visuals", "Effects", "Fog - Distance", 0, 5000, 0, true, "ft."),
        fog_density = ui.new_slider("visuals", "Effects", "Fog - Density", 0, 100, 0, true, "ft."),
    },
    misc = {
        buybot = ui.new_checkbox("misc", "Miscellaneous", "Automatic buy weapons"),
        buybot_p = ui.new_combobox("misc", "miscellaneous", "Buybot - Primary", {"-", "SSG08", "AWP", "\aead18affG3SG1\affffffff / \ab5d4eeffSCAR-20", "\aead18affAK-47\affffffff / \ab5d4eeffM4"}),
        buybot_s = ui.new_combobox("misc", "miscellaneous", "Buybot - Second", {"-", "\aead18affGlock18\affffffff / \ab5d4eeffUSP-S / P2000\affffffff", "Dual", "P250", "\aead18affTec-9\affffffff / \ab5d4eeffFive-Seven\affffffff", "Deagle / Revolver"}),
        buybot_r = ui.new_multiselect("misc", "miscellaneous", "Buybot - Equipment", {"Kevlar Vest", "Helmet", "Defuse", "Taser", "Flashbang", "High Explosive Grenade", "Smoke Grenade", "Molotov", "Decoy"}),
        
        thridperson_camera = ui.new_slider("misc", "Miscellaneous", "Override Thridperson Camera FOV", 40, 200, 120, true, "°"),

        override_view = ui.new_checkbox("misc", "Miscellaneous", "Override viewmodel"),
        override_view_fov = ui.new_slider("misc", "Miscellaneous", "Override - FOV", 0, 150, 60, true, "°"),
        override_view_x = ui.new_slider("misc", "Miscellaneous", "Override - X", -200, 200, 0, true, "°", 0.1),
        override_view_y = ui.new_slider("misc", "Miscellaneous", "Override - Y", -200, 200, 0, true, "°", 0.1),
        override_view_z = ui.new_slider("misc", "Miscellaneous", "Override - Z", -200, 200, 0, true, "°", 0.1),
        override_aspect_ratio = ui.new_slider("misc", "Miscellaneous", "Override - Aspect ratio", 0, 50, 0, true, "%", 0.1, {[0] = "Disabled"}),
    },
}

----------------------

-- @region ragebot - jumpscout fix

----------------------

nick.ragebot = function ()

    local localplayer = entity.get_local_player()
    if not localplayer then return end

    local vec = vector(entity.get_prop(localplayer, "m_vecVelocity"))
    local velocity = math.sqrt((vec.x * vec.x) + (vec.y * vec.y)) 
    
    if ui.get(nick.items.rage.jump_scout) then
        ui.set(nick.ref.misc.air_strafe, math.floor(velocity) > 15)
    else
        ui.set(nick.ref.misc.air_strafe, true)
    end

end

---------------------------------

-- @region ragebot - aimbot log

---------------------------------

nick.aimbot_log__fired = function (event)
    local flags = {
        event.teleported and "T" or "",
        event.interpolated and "I" or "",
        event.extrapolated and "E" or "",
        event.boosted and "B" or "",
        event.high_priority and "H" or ""
    }

    nick.data.hitlog.backtrack = event.backtrack
    nick.data.hitlog.flag = table.concat(flags)

end

nick.aimbot_log__hit = function (event)
    local hitgroup_names = {"generic", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "?", "gear"}
    local group = hitgroup_names[event.hitgroup + 1] or "?"

    if not ui.get(nick.items.rage.hitlog) then return end

    print(("Hit %s 's %s for %i damage (%i health remaining) hitchance: %i | backtrack: %i :: flag:%s"):format(entity.get_player_name(event.target), group, event.damage, entity.get_prop(event.target, "m_iHealth"), event.hit_chance, nick.data.hitlog.backtrack, nick.data.hitlog.flag))

end

nick.aimbot_log__missed = function (event)
    local reasons = {
        ["spread"] = "spread",
        ["prediction error"] = "prediction error",
        ["death"] = "death",
        ["?"] = "resolver",
    }

    if not ui.get(nick.items.rage.hitlog) then return end

    local hitgroup_names = {"generic", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "?", "gear"}
    local group = hitgroup_names[event.hitgroup + 1] or "?"

    print(("Missed shot %s 's %s due to %s (%i health remaining) hitchance: %i | backtrack: %i :: flag:%s"):format(entity.get_player_name(event.target), group, reasons[event.reason], entity.get_prop(event.target, "m_iHealth"), event.hit_chance,  nick.data.hitlog.backtrack, nick.data.hitlog.flag))

end

nick.harmed_log = function (event)

    local localplayer = entity.get_local_player()
    if not localplayer then return end

    local attacker = client.userid_to_entindex(event.attacker)
    if not attacker then return end

    local user = client.userid_to_entindex(event.userid)
    if not user then return end

    local hitgroup_names = {        
        [0] = "body",
        [1] = "head",
        [2] = "chest",
        [3] = "stomach",
        [4] = "left arm",
        [5] = "right arm",
        [6] = "left leg",
        [7] = "right leg",
        [8] = "neck",
        [9] = "generic",
        [10] = "unknown?"
    }
    local group = hitgroup_names[event.hitgroup]

    if user == localplayer then
        print(("Harmed by %s for %i hp in %s"):format(entity.get_player_name(attacker), event.dmg_health, group))
    end

end

---------------------------------

-- @region ragebot - Extra correction - Random body yaw

---------------------------------

nick.get_players = function ()
    local enemies = entity.get_players(true)
    for i = 1, #enemies do
        local player = enemies[i]

        if ui.get(nick.items.rage.correction_selection) == "Random body yaw >:)" and ui.get(nick.items.rage.correction) then
            plist.set(player, "Correction active", false)  -- skeet resolver sucks. turn it off.

            plist.set(player, "Force body yaw", true)
            plist.set(player, "Force body yaw value", math.random(-58, 58))
        end

    end
end

---------------------------------

-- @region ragebot - Extra correction - jitter correction

---------------------------------

nick.resolver = {
	records = {},
	work = a(function ()

        players = entity.get_players()
		local self = nick.resolver
		client.update_player_list()

		for i = 1, #players do
			local v = players[i]

			if entity.is_enemy(v) then

				local st_cur, st_pre = entity.get_simtime(v)
				st_cur, st_pre = toticks(st_cur), toticks(st_pre)

				if not self.records[v] then self.records[v] = setmetatable({}, {__mode = "kv"}) end

				local slot = self.records[v]

				slot[st_cur] = {
					pose = entity.get_prop(v, "m_flPoseParameter", 11) * 120 - 60,
					eye = select(2, entity.get_prop(v, "m_angEyeAngles"))
				}
				--

				local value
				local allow = (slot[st_pre] and slot[st_cur]) ~= nil

				if allow then
					local animstate = entity.get_animstate(v)
					local max_desync = entity.get_max_desync(animstate)
					if (slot[st_pre] and slot[st_cur]) and max_desync < .85 and (st_cur - st_pre < 2) then
						local side = math.clamp(math.normalize_yaw(animstate.goal_feet_yaw - slot[st_cur].eye), -1, 1)
						value = slot[st_pre] and (slot[st_pre].pose * side * max_desync) or nil
					end
					if value then plist.set(v, "Force body yaw value", value) end
				end

				plist.set(v, "Force body yaw", value ~= nil)
				plist.set(v, "Correction active", true)
			end
		end
	end),

	restore = a(function ()
		local self = nick.resolver
		for i = 1, 64 do
			plist.set(i, "Force body yaw", false)
		end
		self.records = {}
	end),

	run = a(function (self)

        if ui.get(nick.items.rage.correction_selection) == "Jitter correction" then
            client.set_event_callback("net_update_end", self.work)
        elseif ui.get(nick.items.rage.correction_selection) ~= "Jitter correction" then 
            self.restore()
        end
		
		defer(self.restore)
	end)
}

---------------------------------

-- @region ragebot - Disabled correction on taser

---------------------------------

nick.disabled_correction = function ()
    local localplayer = entity.get_local_player()
    if not localplayer then return end

    if not ui.get(nick.items.rage.disable_correction) then ui.set(nick.ref.rage.resolver, true) return end
    if weapondata(entity.get_player_weapon(localplayer)) == nil then return end

    if weapondata(entity.get_player_weapon(localplayer)).name == "Zeus x27" then
        ui.set(nick.ref.rage.resolver, false)
    else
        ui.set(nick.ref.rage.resolver, true)
    end
end

----------------------

-- @region antiaim

----------------------

nick.get_manual = function (self)

    local left = ui.get(nick.items.antiaim.manual_left)
    local right = ui.get(nick.items.antiaim.manual_right)
    local back = ui.get(nick.items.antiaim.manual_back)

    if last_forward == nil then
        last_forward, last_right, last_left = back, right, left
    end

    if left ~= last_left then
        if nick.data.manual.manual_side == 1 then
            nick.data.manual.manual_side = nil
        else
            nick.data.manual.manual_side = 1
        end
    end

    if right ~= last_right then
        if nick.data.manual.manual_side == 2 then
            nick.data.manual.manual_side = nil
        else
            nick.data.manual.manual_side = 2
        end
    end

    if back ~= last_forward then
        if nick.data.manual.manual_side == 3 then
            nick.data.manual.manual_side = nil
        else
            nick.data.manual.manual_side = 3
        end
    end

    last_forward, last_right, last_left = back, right, left

    if not nick.data.manual.manual_side then
        return
    end

    return ({-90, 90, 0})[nick.data.manual.manual_side]
end


nick.antiaim = function ()
    if not ui.get(nick.items.antiaim.enabled) then return end

    ui.set(nick.ref.antiaim.aa_enabled, true)

    local manual = nick.get_manual()
    
    
    for i, v in ipairs(nick.data.conditions) do

        if not ui.get(nick.data.aa_menu_item[i].override) then i = 1 end

        if nick.get_condition() == v then 
            nick.data.aa.pitch = ui.get(nick.data.aa_menu_item[i].pitch)
            nick.data.aa.__pitch = ui.get(nick.data.aa_menu_item[i]._pitch)
            nick.data.aa.yaw_base = ui.get(nick.data.aa_menu_item[i].yaw_base)
            nick.data.aa.yaw = ui.get(nick.data.aa_menu_item[i].yaw)

            if manual then
                nick.data.aa.__yaw = manual
            else
                nick.data.aa.__yaw = ui.get(nick.data.aa_menu_item[i]._yaw)
            end

            nick.data.aa.yaw_jitter = ui.get(nick.data.aa_menu_item[i].yaw_jitter)
            nick.data.aa.__yaw_jitter = ui.get(nick.data.aa_menu_item[i]._yaw_jitter)
            nick.data.aa.body_yaw = ui.get(nick.data.aa_menu_item[i].body_yaw)

            if ui.get(nick.items.antiaim.inverter) then
                if ui.get(nick.data.aa_menu_item[i]._body_yaw) > 0 then
                    nick.data.aa.__body_yaw = ui.get(nick.data.aa_menu_item[i]._body_yaw) - (ui.get(nick.data.aa_menu_item[i]._body_yaw) * 2)
                elseif ui.get(nick.data.aa_menu_item[i]._body_yaw) < 0 then
                    nick.data.aa.__body_yaw = math.abs(ui.get(nick.data.aa_menu_item[i]._body_yaw))
                end
            else
                nick.data.aa.__body_yaw = ui.get(nick.data.aa_menu_item[i]._body_yaw)
            end
        
            nick.data.aa.freestanding_body_yaw = ui.get(nick.data.aa_menu_item[i].freestanding_body_yaw)
            nick.data.aa.edge_yaw = ui.get(nick.data.aa_menu_item[i].edge_yaw)
            nick.data.aa.roll = ui.get(nick.data.aa_menu_item[i].roll)
        end
    end


    nick.data.aa.freestanding = ui.get(nick.items.antiaim.freestanding)

    ui.set(nick.ref.antiaim.aa_enabled, true)

    if nick.data.defensive.def then
        ui.set(nick.ref.antiaim.pitch[1], "Custom")
        ui.set(nick.ref.antiaim.pitch[2], nick.data.defensive.pitch)
    else
        ui.set(nick.ref.antiaim.pitch[1], nick.data.aa.pitch)
        ui.set(nick.ref.antiaim.pitch[2], nick.data.aa.__pitch)
    end

    ui.set(nick.ref.antiaim.yaw_base, nick.data.aa.yaw_base)

    if not nick.data.defensive.def then
        if nick.data.aa.yaw_jitter ~= "[Better GS] 3-Way [WIP]" or nick.data.aa.yaw_jitter ~= "[Better GS] 5-Way [WIP]" then
            ui.set(nick.ref.antiaim.yaw[1], nick.data.aa.yaw)
            ui.set(nick.ref.antiaim.yaw[2], nick.data.aa.__yaw)
            ui.set(nick.ref.antiaim.yaw_jitter[1], nick.data.aa.yaw_jitter)
            ui.set(nick.ref.antiaim.yaw_jitter[2], nick.data.aa.__yaw_jitter)
        elseif nick.data.aa.yaw_jitter == "[Better GS] 3-Way [WIP]" then
            ui.set(nick.ref.antiaim.yaw[1], "180")
            ui.set(nick.ref.antiaim.yaw[2], nick.data.aa.__yaw)
            ui.set(nick.ref.antiaim.yaw_jitter[1], "Off")
            ui.set(nick.ref.antiaim.yaw_jitter[2], 0)
        elseif nick.data.aa.yaw_jitter == "[Better GS] 5-Way [WIP]" then
            ui.set(nick.ref.antiaim.yaw[1], "180")
            ui.set(nick.ref.antiaim.yaw[2], nick.data.aa.__yaw)
            ui.set(nick.ref.antiaim.yaw_jitter[1], "Off")
            ui.set(nick.ref.antiaim.yaw_jitter[2], 0)
        end
    else
        ui.set(nick.ref.antiaim.yaw[1], "180")
        ui.set(nick.ref.antiaim.yaw[2], nick.data.defensive.yaw)
        ui.set(nick.ref.antiaim.yaw_jitter[1], "Off")
        ui.set(nick.ref.antiaim.yaw_jitter[2], 0)
    end

    ui.set(nick.ref.antiaim.body_yaw[1], nick.data.aa.body_yaw)
    ui.set(nick.ref.antiaim.body_yaw[2], nick.data.aa.__body_yaw)
    ui.set(nick.ref.antiaim.freestanding_body_yaw, nick.data.aa.freestanding_body_yaw)
    ui.set(nick.ref.antiaim.edge_yaw, nick.data.aa.edge_yaw)
    ui.set(nick.ref.antiaim.roll, nick.data.aa.roll)

    ui.set(nick.ref.antiaim.freestanding[1], nick.data.aa.freestanding)
    ui.set(nick.ref.antiaim.freestanding[2], nick.data.aa.freestanding and "Always on" or "On hotkey")


end

----------------------

-- @region defensive antiaim

----------------------

nick.defensive_antiaim = function (events)
    
    for i, v in ipairs (nick.data.conditions) do

        if nick.get_condition() == v then
            if not ui.get(nick.data.aa_menu_item[i].override) then
                i = 1 
            end

            if not ui.get(nick.data.defensive_aa_item[i].def_enabled) then
                --print("Def is disabled")
                nick.data.defensive.def = false
                return
            end

            if not ui.get(nick.ref.rage.double_tap[2]) or ui.get(nick.ref.antiaim.on_shot[2]) then 
                --print("Exploit is not active")
                nick.data.defensive.def = false
                return 
            end

            if not nick.is_shift() then
                --print("Exploit is not shifting")
                nick.data.defensive.def = false
                return
            end

            if ui.get(nick.data.defensive_aa_item[i].mode) == "Disabled" then
                --print("Def mode is disabled")
                nick.data.defensive.def = false
                return
            end

            if ui.get(nick.data.defensive_aa_item[i].mode) == "On Peek" and (globals.tickcount() > nick.data.defensive.defensive_tk - 2) then 
                --print("Tick compare failed")
                nick.data.defensive.def = false
                return 
            end

            if ui.get(nick.data.defensive_aa_item[i].mode) == "Enabled on auto stopping" and (not events.quick_stop) then
                nick.data.defensive.def = false
                return
            end



            nick.data.defensive.def = true

            events.force_defensive = true
            events.allow_send_packet = events.chokedcommands > 1

            yaw = ui.get(nick.data.defensive_aa_item[i].yaw)
            pitch = ui.get(nick.data.defensive_aa_item[i].pitch)

            if pitch == "Default" then
                nick.data.defensive.pitch = 89
            elseif pitch == "Up" then
                nick.data.defensive.pitch = -89
            elseif pitch == "Down" then
                nick.data.defensive.pitch = 89
            elseif pitch == "Static" then
                nick.data.defensive.pitch = ui.get(nick.data.defensive_aa_item[i].__pitch_1)
            elseif pitch == "45" then
                    nick.data.defensive.pitch = 45
            elseif pitch == "Jitter" then
                nick.data.defensive.pitch = nick.ticks_switch(ui.get(nick.data.defensive_aa_item[i].__ticks_p), ui.get(nick.data.defensive_aa_item[i].__pitch_1), ui.get(nick.data.defensive_aa_item[i].__pitch_2))
            elseif pitch == "Random" then
                nick.data.defensive.pitch = math.random(-89, 89)
            elseif pitch == "Defensive" then
                nick.data.defensive.pitch = nick.spin_num(600, 89, -89)
            end

            if yaw == "Default" then
                nick.data.defensive.yaw = nick.data.aa.yaw
            elseif yaw == "Zero" then
                nick.data.defensive.yaw = 0
            elseif yaw == "Static" then
                nick.data.defensive.yaw = ui.get(nick.data.defensive_aa_item[i].__yaw_1)
            elseif yaw == "Jitter" then
                nick.data.defensive.yaw = nick.ticks_switch(ui.get(nick.data.defensive_aa_item[i].__ticks_y), ui.get(nick.data.defensive_aa_item[i].__yaw_1), ui.get(nick.data.defensive_aa_item[i].__yaw_2))
            elseif yaw == "Spin" then
                nick.data.defensive.yaw = nick.spin_num(ui.get(nick.data.defensive_aa_item[i].__ticks_y) * 100, -180, 180)
            elseif yaw == "Sway" then
                nick.data.defensive.yaw = nick.spin_num(ui.get(nick.data.defensive_aa_item[i].__ticks_y) * 100, ui.get(nick.data.defensive_aa_item[i].__yaw_1), ui.get(nick.data.defensive_aa_item[i].__yaw_2))
            elseif yaw == "Side-Way" then
                nick.data.defensive.yaw = nick.ticks_switch(1, -85, 85)
            elseif yaw == "Random" then
                nick.data.defensive.yaw = math.random(-180, 180)
            end

        end

    end
    
end

----------------------

-- @region fake lag

----------------------

nick.fakelag = function ()
    if not ui.get(nick.items.fakelag.enabled) then return end

    ui.set(nick.ref.antiaim.fl_enabled[1], true)

    for i, v in ipairs(nick.data.conditions) do

        if not ui.get(nick.data.fakelag_item[i].override) then i = 1 end

        if nick.get_condition() == v then
            if (not ui.get(nick.data.fakelag_item[i].mode) == "Randmized") or (not ui.get(nick.data.fakelag_item[i].mode) == "Jitter") then
                nick.data.fl.mode = ui.get(nick.data.fakelag_item[i].mode)
                nick.data.fl.variance = ui.get(nick.data.fakelag_item[i].variance)

                nick.data.fl.limit = ui.get(nick.data.fakelag_item[i].limit_1)
            elseif ui.get(nick.data.fakelag_item[i].mode) == "Randmized" then
                nick.data.fl.mode = "Maximum"
                nick.data.fl.variance = ui.get(nick.data.fakelag_item[i].variance)

                nick.data.fl.limit = client.random_int(1, ui.get(nick.data.fakelag_item[i].limit_1))
            elseif ui.get(nick.data.fakelag_item[i].mode) == "Jitter" then
                nick.data.fl.mode = "Maximum"
                nick.data.fl.variance = ui.get(nick.data.fakelag_item[i].variance)

                nick.data.fl.limit = nick.ticks_switch(ui.get(nick.data.fakelag_item[i].delay_ticks), ui.get(nick.data.fakelag_item[i].limit_1), ui.get(nick.data.fakelag_item[i].limit_2))
            else -- shit code
                nick.data.fl.mode = ui.get(nick.data.fakelag_item[i].mode)
                nick.data.fl.variance = ui.get(nick.data.fakelag_item[i].variance)

                nick.data.fl.limit = ui.get(nick.data.fakelag_item[i].limit_1)
            end
        end

    end

    if ui.get(nick.items.fakelag.slient_shots) then
        my_weapon = entity.get_player_weapon(entity.get_local_player())

        if my_weapon then
            local last_shot_time = entity.get_prop(my_weapon, "m_fLastShotTime")
            local time_difference = globals.curtime() - last_shot_time
    
            if time_difference <= 0.045 then
                nick.data.fl.limit = 1
                ui.set(nick.ref.antiaim.fl_enabled[1], false)
            else
                ui.set(nick.ref.antiaim.fl_enabled[1], true)
            end
        end
    end


    ui.set(nick.ref.antiaim.amount, nick.data.fl.mode)
    ui.set(nick.ref.antiaim.variance, nick.data.fl.variance)
    ui.set(nick.ref.antiaim.limit, nick.data.fl.limit)

end

----------------------

-- @region buybot

----------------------

nick.buy_bot = function ()

    local buy_name = {
        ["-"] = "none",
        ["SSG08"] = "ssg08",
        ["AWP"] = "awp",
        ["\aead18affG3SG1\affffffff / \ab5d4eeffSCAR-20"] = "g3sg1",
        ["\aead18affAK-47\affffffff / \ab5d4eeffM4"] = "ak47",

        ["\aead18affGlock18\affffffff / \ab5d4eeffUSP-S / P2000\affffffff"] = "glock18",
        ["Dual"] = "elite",
        ["P250"] = "p250",
        ["\aead18affTec-9\affffffff / \ab5d4eeffFive-Seven\affffffff"] = "tec9",
        ["Deagle / Revolver"] = "deagle",

        ["Kevlar Vest"] = "vest",
        ["Helmet"] = "vesthelm",
        ["Taser"] = "taser",
        ["Defuse"] = "defuser",
        ["Flashbang"] = "flashbang",
        ["High Explosive Grenade"] = "hegrenade",
        ["Smoke Grenade"] = "smokegrenade",
        ["Molotov"] = "molotov",
        ["Decoy"] = "decoy",
    }

    if not ui.get(nick.items.misc.buybot) then return end

    if buy_name[ui.get(nick.items.misc.buybot_p)] ~= "none" then
        client.exec("buy " .. buy_name[ui.get(nick.items.misc.buybot_p)])
    end

    if buy_name[ui.get(nick.items.misc.buybot_s)] ~= "none" then
        client.exec("buy " .. buy_name[ui.get(nick.items.misc.buybot_s)])
    end

    for i, v in ipairs(ui.get(nick.items.misc.buybot_r)) do
        client.exec("buy " .. buy_name[v])
    end

end

----------------------

-- @region thridperson camera

----------------------

nick.thridperson_camera = function ()
    local dist = nick.math_new_lerp("thrid_camera", ui.get(nick.ref.visuals.thrid_person[2]) and ui.get(nick.items.misc.thridperson_camera) or 0, globals.frametime() * 15)

    cvar.c_mindistance:set_int(dist)
    cvar.c_maxdistance:set_int(dist)
end

----------------------

-- @region override viewmodel

----------------------

nick.override_viewmodel = function ()
    local fov = nick.math_new_lerp("viewmodel_fov", ui.get(nick.items.misc.override_view) and ui.get(nick.items.misc.override_view_fov) or 70, globals.frametime() * 15)
    local x = nick.math_new_lerp("viewmodel_x", ui.get(nick.items.misc.override_view) and ui.get(nick.items.misc.override_view_x) or 0, globals.frametime() * 15)
    local y = nick.math_new_lerp("viewmodel_y", ui.get(nick.items.misc.override_view) and ui.get(nick.items.misc.override_view_y) or 0, globals.frametime() * 15)
    local z = nick.math_new_lerp("viewmodel_z", ui.get(nick.items.misc.override_view) and ui.get(nick.items.misc.override_view_z) or 0, globals.frametime() * 15)

    cvar.viewmodel_fov:set_raw_float(fov)
    cvar.viewmodel_offset_x:set_raw_float(x / 10, true)
    cvar.viewmodel_offset_y:set_raw_float(y / 10, true)
    cvar.viewmodel_offset_z:set_raw_float(z / 10, true)

    scale = ui.get(nick.items.misc.override_aspect_ratio) == 0 and 17.5 or nick.math_new_lerp("aspect_ratio", ui.get(nick.items.misc.override_view) and ui.get(nick.items.misc.override_aspect_ratio) or 17.5, globals.frametime() * 15)

    cvar.r_aspectratio:set_float(scale / 10)
end

---------------------------------

-- @region bloom

---------------------------------

local bloom_default, exposure_min_default, exposure_max_default
local bloom_prev, exposure_prev, model_ambient_min_prev, wallcolor_prev
local mat_ambient_light_r, mat_ambient_light_g, mat_ambient_light_b = cvar.mat_ambient_light_r, cvar.mat_ambient_light_g, cvar.mat_ambient_light_b
local r_modelAmbientMin = cvar.r_modelAmbientMin
local max_val = 1

nick.bloom__reset = function (tone_map_controller)
	if bloom_default == -1 then
		entity.set_prop(tone_map_controller, "m_bUseCustomBloomScale", 0)
		entity.set_prop(tone_map_controller, "m_flCustomBloomScale", 0)
	else
		entity.set_prop(tone_map_controller, "m_bUseCustomBloomScale", 1)
		entity.set_prop(tone_map_controller, "m_flCustomBloomScale", bloom_default)
	end
end

nick.exposure__reset = function (tone_map_controller)
	if exposure_min_default == -1 then
		entity.set_prop(tone_map_controller, "m_bUseCustomAutoExposureMin", 0)
		entity.set_prop(tone_map_controller, "m_flCustomAutoExposureMin", 0)
	else
		entity.set_prop(tone_map_controller, "m_bUseCustomAutoExposureMin", 1)
		entity.set_prop(tone_map_controller, "m_flCustomAutoExposureMin", exposure_min_default)
	end
	if exposure_max_default == -1 then
		entity.set_prop(tone_map_controller, "m_bUseCustomAutoExposureMax", 0)
		entity.set_prop(tone_map_controller, "m_flCustomAutoExposureMax", 0)
	else
		entity.set_prop(tone_map_controller, "m_bUseCustomAutoExposureMax", 1)
		entity.set_prop(tone_map_controller, "m_flCustomAutoExposureMax", exposure_max_default)
	end
end

nick.bloom = function ()

    if not ui.get(nick.items.visuals.bloom) then return end

    local model_ambient_min = ui.get(nick.items.visuals.model_ambient_min_reference)
	if model_ambient_min > 0 or (model_ambient_min_prev ~= nil and model_ambient_min_prev > 0) then
		if r_modelAmbientMin:get_float() ~= model_ambient_min*0.05 then
			r_modelAmbientMin:set_raw_float(model_ambient_min*0.05)
		end
	end
	model_ambient_min_prev = model_ambient_min

    local bloom = ui.get(nick.items.visuals.bloom_reference)
    local exposure = ui.get(nick.items.visuals.exposure_reference)

	if bloom ~= -1 or exposure ~= -1 or bloom_prev ~= -1 or exposure_prev ~= -1 then
		local tone_map_controllers = entity.get_all("CEnvTonemapController")
		for i=1, #tone_map_controllers do
			local tone_map_controller = tone_map_controllers[i]
			if bloom ~= -1 then
				if bloom_default == nil then
					if entity.get_prop(tone_map_controller, "m_bUseCustomBloomScale") == 1 then
						bloom_default = entity.get_prop(tone_map_controller, "m_flCustomBloomScale")
					else
						bloom_default = -1
					end
				end
				entity.set_prop(tone_map_controller, "m_bUseCustomBloomScale", 1)
				entity.set_prop(tone_map_controller, "m_flCustomBloomScale", bloom*0.01)
			elseif bloom_prev ~= nil and bloom_prev ~= -1 and bloom_default ~= nil then
				nick.bloom__reset(tone_map_controller)
			end
			if exposure ~= -1 then
				if exposure_min_default == nil then
					if entity.get_prop(tone_map_controller, "m_bUseCustomAutoExposureMin") == 1 then
						exposure_min_default = entity.get_prop(tone_map_controller, "m_flCustomAutoExposureMin")
					else
						exposure_min_default = -1
					end
					if entity.get_prop(tone_map_controller, "m_bUseCustomAutoExposureMax") == 1 then
						exposure_max_default = entity.get_prop(tone_map_controller, "m_flCustomAutoExposureMax")
					else
						exposure_max_default = -1
					end
				end
				entity.set_prop(tone_map_controller, "m_bUseCustomAutoExposureMin", 1)
				entity.set_prop(tone_map_controller, "m_bUseCustomAutoExposureMax", 1)
				entity.set_prop(tone_map_controller, "m_flCustomAutoExposureMin", math.max(0.0000, exposure*0.001))
				entity.set_prop(tone_map_controller, "m_flCustomAutoExposureMax", math.max(0.0000, exposure*0.001))
			elseif exposure_prev ~= nil and exposure_prev ~= -1 and exposure_min_default ~= nil then
				nick.exposure__reset(tone_map_controller)
			end
		end
	end
	bloom_prev = bloom
	exposure_prev = exposure

end

nick.bloom__task = function ()
	if globals.mapname() == nil then
		bloom_default, exposure_min_default, exposure_max_default = nil, nil, nil
	end
	client.delay_call(0.5, nick.bloom__task)
end
nick.bloom__task()


nick.bloom__shutdown = function ()
	local tone_map_controllers = entity.get_all("CEnvTonemapController")
	for i=1, #tone_map_controllers do
		local tone_map_controller = tone_map_controllers[i]
		if bloom_prev ~= -1 and bloom_default ~= nil then
			nick.bloom__reset(tone_map_controller)
		end
		if exposure_prev ~= -1 and exposure_min_default ~= nil then
			nick.exposure__reset(tone_map_controller)
		end
	end
	mat_ambient_light_r:set_raw_float(0)
	mat_ambient_light_g:set_raw_float(0)
	mat_ambient_light_b:set_raw_float(0)
	r_modelAmbientMin:set_raw_float(0)
end

----------------------

-- @region fog

----------------------

nick.fog = function ()

    if not globals.mapname() then return end

    if ui.get(nick.items.visuals.fog_custom) == "Default" then
        cvar.fog_override:set_int(0)
        ui.set(nick.ref.visuals.remove_fog, false)
    elseif ui.get(nick.items.visuals.fog_custom) == "Clean" then
        cvar.fog_override:set_int(0)
        ui.set(nick.ref.visuals.remove_fog, true)
    else
        ui.set(nick.ref.visuals.remove_fog, false)

        color_r, color_g, color_b, color_a = ui.get(nick.items.visuals.fog_color)

        cvar.fog_override:set_int(1)
        cvar.fog_color:set_string(string.format("%s %s %s", color_r, color_g, color_b) or "0, 0, 0" )
        cvar.fog_start:set_int(ui.get(nick.items.visuals.fog_start))
        cvar.fog_end:set_int(ui.get(nick.items.visuals.fog_distance))
        cvar.fog_maxdensity:set_float(ui.get(nick.items.visuals.fog_density) / 100)
    end

end

----------------------

-- @region indicator

----------------------


nick.indicator = function ()

    local localplayer = entity.get_local_player()
    if not localplayer then return end

    if not entity.is_alive(localplayer) then return end
    
    local color_e = nick.get_rainbow(0.5, 1, 255)

    local vec = vector(entity.get_prop(entity.get_local_player(), "m_vecVelocity"))
    local velocity = math.sqrt((vec.x * vec.x) + (vec.y * vec.y)) 

    if ui.get(nick.items.rage.correction_selection) == "Random body yaw >:)" and ui.get(nick.items.rage.correction) then
        renderer.indicator(color_e.x, color_e.y, color_e.z, 255, "RANDOM BODY YAW")
    elseif ui.get(nick.items.rage.correction_selection) == "Jitter correction" and ui.get(nick.items.rage.correction) then
        renderer.indicator(176, 216, 67, 255, "JITTER RESOLVER")
    end

    if nick.get_manual() then
        if nick.get_manual() == -90 then
            renderer.indicator(255, 255, 255, 255, "LEFT")
        elseif nick.get_manual() == 0 then
            renderer.indicator(255, 255, 255, 255, "BACK")
        elseif nick.get_manual() == 90 then
            renderer.indicator(255, 255, 255, 255, "RIGHT")
        end
    end

    if ui.get(nick.items.antiaim.freestanding) then
        renderer.indicator(176, 216, 67, 255, "FS")
    end

    if nick.get_condition() == "In Air" or nick.get_condition() == "In Air + Crouching" and cvar.cl_lagcompensation:get_int() == 1 then -- disabled lc cant to get the lc
        lc_color = (velocity >= 270 and globals.chokedcommands() > 2) and {176, 216, 67, 255} or {255, 0, 0, 255}
        renderer.indicator(lc_color[1], lc_color[2], lc_color[3], 255, "LC")
    end

    if cvar.cl_lagcompensation:get_int() == 0 then
        renderer.indicator(255, 214, 90, 255, "AX")
    end

    if ui.get(nick.items.antiaim.inverter) then
        renderer.indicator(255, 255, 255, 255, "Inverter")
    end
end


----------------------

-- @region menu visible

----------------------


nick.menu__loaded = function()
    __anti_aimbot = {"Enabled", "Pitch", "Yaw base", "Yaw", "Yaw jitter", "Body yaw", "Freestanding body yaw", "Edge yaw", "Freestanding", "Roll"}
    __fakelag = {"Enabled", "Amount", "Variance", "Limit"}

    for i, k in ipairs(__anti_aimbot) do
        ui.set_visible(ui.reference("aa", "anti-aimbot angles", k), false)
    end
    for i, k in ipairs(__fakelag) do
        ui.set_visible(ui.reference("aa", "fake lag", k), false)
    end

    if ui.get(nick.ref.antiaim.pitch[1]) == "Custom" then
        ui.set_visible(nick.ref.antiaim.pitch[2], false)
    end
    if ui.get(nick.ref.antiaim.yaw[1]) ~= "Off" then
        ui.set_visible(nick.ref.antiaim.yaw[2], false)
    end
    if ui.get(nick.ref.antiaim.yaw_jitter[1]) ~= "Off" then
        ui.set_visible(nick.ref.antiaim.yaw_jitter[2], false)
    end
    if ui.get(nick.ref.antiaim.body_yaw[1]) ~= "Off" then
        ui.set_visible(nick.ref.antiaim.body_yaw[2], false)
    end
    ui.set_visible(nick.ref.antiaim.freestanding[2], false)

    ui.set_visible(nick.ref.antiaim.fl_enabled[2], false)

    ------------------------------------------------------------------------------

    ui.set_visible(nick.items.rage.correction_selection, ui.get(nick.items.rage.correction))

    for i, v in ipairs (nick.data.conditions) do
        ui.set_visible(nick.data.aa_menu_item[i].override, (ui.get(nick.items.antiaim.aa_conditions) ~= "Globals") and ui.get(nick.items.antiaim.aa_conditions) == v)
        ui.set_visible(nick.data.aa_menu_item[i].pitch, (ui.get(nick.items.antiaim.aa_conditions) == v))
        ui.set_visible(nick.data.aa_menu_item[i]._pitch, (ui.get(nick.items.antiaim.aa_conditions) == v) and ui.get(nick.data.aa_menu_item[i].pitch) == "Custom")
        ui.set_visible(nick.data.aa_menu_item[i].yaw_base, (ui.get(nick.items.antiaim.aa_conditions) == v))
        ui.set_visible(nick.data.aa_menu_item[i].yaw, (ui.get(nick.items.antiaim.aa_conditions) == v))
        ui.set_visible(nick.data.aa_menu_item[i]._yaw, (ui.get(nick.items.antiaim.aa_conditions) == v) and ui.get(nick.data.aa_menu_item[i].yaw) ~= "Off")
        ui.set_visible(nick.data.aa_menu_item[i].yaw_jitter, (ui.get(nick.items.antiaim.aa_conditions) == v))
        ui.set_visible(nick.data.aa_menu_item[i]._yaw_jitter, (ui.get(nick.items.antiaim.aa_conditions) == v) and ui.get(nick.data.aa_menu_item[i].yaw_jitter) ~= "Off")
        ui.set_visible(nick.data.aa_menu_item[i].body_yaw, (ui.get(nick.items.antiaim.aa_conditions) == v))
        ui.set_visible(nick.data.aa_menu_item[i]._body_yaw, (ui.get(nick.items.antiaim.aa_conditions) == v) and (ui.get(nick.data.aa_menu_item[i].body_yaw) ~= "Off" and ui.get(nick.data.aa_menu_item[i].body_yaw) ~= "Opposite"))
        ui.set_visible(nick.data.aa_menu_item[i].freestanding_body_yaw, (ui.get(nick.items.antiaim.aa_conditions) == v) and ui.get(nick.data.aa_menu_item[i].body_yaw) ~= "Off")
        ui.set_visible(nick.data.aa_menu_item[i].edge_yaw, (ui.get(nick.items.antiaim.aa_conditions) == v))
        ui.set_visible(nick.data.aa_menu_item[i].roll, (ui.get(nick.items.antiaim.aa_conditions) == v))


        ui.set_visible(nick.data.defensive_aa_item[i].def_enabled, (ui.get(nick.items.antiaim.aa_conditions) == v))
        ui.set_visible(nick.data.defensive_aa_item[i].mode, (ui.get(nick.items.antiaim.aa_conditions) == v) and ui.get(nick.data.defensive_aa_item[i].def_enabled))
        ui.set_visible(nick.data.defensive_aa_item[i].pitch, (ui.get(nick.items.antiaim.aa_conditions) == v) and ui.get(nick.data.defensive_aa_item[i].def_enabled))
        ui.set_visible(nick.data.defensive_aa_item[i].__ticks_p, (ui.get(nick.items.antiaim.aa_conditions) == v and ui.get(nick.data.defensive_aa_item[i].pitch) == "Jitter") and ui.get(nick.data.defensive_aa_item[i].def_enabled))
        ui.set_visible(nick.data.defensive_aa_item[i].__pitch_1, (ui.get(nick.items.antiaim.aa_conditions) == v and (ui.get(nick.data.defensive_aa_item[i].pitch) == "Static") or ui.get(nick.data.defensive_aa_item[i].pitch) == "Jitter")  and ui.get(nick.data.defensive_aa_item[i].def_enabled))
        ui.set_visible(nick.data.defensive_aa_item[i].__pitch_2, (ui.get(nick.items.antiaim.aa_conditions) == v and ui.get(nick.data.defensive_aa_item[i].pitch) == "Jitter" ) and ui.get(nick.data.defensive_aa_item[i].def_enabled))
        ui.set_visible(nick.data.defensive_aa_item[i].yaw, (ui.get(nick.items.antiaim.aa_conditions) == v) and ui.get(nick.data.defensive_aa_item[i].def_enabled))
        ui.set_visible(nick.data.defensive_aa_item[i].__ticks_y, (ui.get(nick.items.antiaim.aa_conditions) == v and (ui.get(nick.data.defensive_aa_item[i].yaw) == "Jitter" or ui.get(nick.data.defensive_aa_item[i].yaw) == "Spin" or ui.get(nick.data.defensive_aa_item[i].yaw) == "Sway")   and ui.get(nick.data.defensive_aa_item[i].def_enabled)  ))
        ui.set_visible(nick.data.defensive_aa_item[i].__yaw_1, (ui.get(nick.items.antiaim.aa_conditions) == v and (ui.get(nick.data.defensive_aa_item[i].yaw) == "Static" or ui.get(nick.data.defensive_aa_item[i].yaw) == "Jitter") or ui.get(nick.data.defensive_aa_item[i].yaw) == "Sway" )  and ui.get(nick.data.defensive_aa_item[i].def_enabled) )
        ui.set_visible(nick.data.defensive_aa_item[i].__yaw_2, (ui.get(nick.items.antiaim.aa_conditions) == v and (ui.get(nick.data.defensive_aa_item[i].yaw) == "Jitter") or ui.get(nick.data.defensive_aa_item[i].yaw) == "Sway") and ui.get(nick.data.defensive_aa_item[i].def_enabled) )
    
    
        ui.set_visible( nick.data.fakelag_item[i].override , ui.get(nick.items.fakelag.conditions) == v and ui.get(nick.items.fakelag.conditions) ~= "Globals"  )
        ui.set_visible( nick.data.fakelag_item[i].mode , ui.get(nick.items.fakelag.conditions) == v )
        ui.set_visible( nick.data.fakelag_item[i].variance , ui.get(nick.items.fakelag.conditions) == v )
        ui.set_visible( nick.data.fakelag_item[i].delay_ticks , ui.get(nick.items.fakelag.conditions) == v and (ui.get(nick.data.fakelag_item[i].mode) == "Jitter"))
        ui.set_visible( nick.data.fakelag_item[i].limit_1 , ui.get(nick.items.fakelag.conditions) == v )
        ui.set_visible( nick.data.fakelag_item[i].limit_2 , ui.get(nick.items.fakelag.conditions) == v and ui.get(nick.data.fakelag_item[i].mode) == "Jitter")
    end

    ui.set_visible(nick.items.visuals.bloom_reference, ui.get(nick.items.visuals.bloom))
    ui.set_visible(nick.items.visuals.exposure_reference, ui.get(nick.items.visuals.bloom))
    ui.set_visible(nick.items.visuals.model_ambient_min_reference, ui.get(nick.items.visuals.bloom))
    
    ui.set_visible(nick.items.visuals.fog_color, ui.get(nick.items.visuals.fog_custom) == "Override")
    ui.set_visible(nick.items.visuals.fog_start, ui.get(nick.items.visuals.fog_custom) == "Override")
    ui.set_visible(nick.items.visuals.fog_distance, ui.get(nick.items.visuals.fog_custom) == "Override")
    ui.set_visible(nick.items.visuals.fog_density, ui.get(nick.items.visuals.fog_custom) == "Override")

    ui.set_visible(nick.items.misc.buybot_p, ui.get(nick.items.misc.buybot))
    ui.set_visible(nick.items.misc.buybot_s, ui.get(nick.items.misc.buybot))
    ui.set_visible(nick.items.misc.buybot_r, ui.get(nick.items.misc.buybot))

    ui.set_visible(nick.items.misc.override_view_fov, ui.get(nick.items.misc.override_view))
    ui.set_visible(nick.items.misc.override_view_x, ui.get(nick.items.misc.override_view))
    ui.set_visible(nick.items.misc.override_view_y, ui.get(nick.items.misc.override_view))
    ui.set_visible(nick.items.misc.override_view_z, ui.get(nick.items.misc.override_view))
    ui.set_visible(nick.items.misc.override_aspect_ratio, ui.get(nick.items.misc.override_view))

    ui.set_visible(nick.ref.visuals.remove_fog, false)
    ui.set_visible(ui.reference("Misc", "Settings", "sv_maxusrcmdprocessticks2"), true)

end

nick.menu__unloaded = function()
    __anti_aimbot = {"Enabled", "Pitch", "Yaw base", "Yaw", "Yaw jitter", "Body yaw", "Freestanding body yaw", "Edge yaw", "Freestanding", "Roll"}
    __fakelag = {"Enabled", "Amount", "Variance", "Limit"}

    for i, k in ipairs(__anti_aimbot) do
        ui.set_visible(ui.reference("aa", "anti-aimbot angles", k), true)
    end
    for i, k in ipairs(__fakelag) do
        ui.set_visible(ui.reference("aa", "fake lag", k), true)
    end

    if ui.get(nick.ref.antiaim.pitch[1]) == "Custom" then
        ui.set_visible(nick.ref.antiaim.pitch[2], true)
    end
    if ui.get(nick.ref.antiaim.yaw[1]) ~= "Off" then
        ui.set_visible(nick.ref.antiaim.yaw[2], true)
    end
    if ui.get(nick.ref.antiaim.yaw_jitter[1]) ~= "Off" then
        ui.set_visible(nick.ref.antiaim.yaw_jitter[2], true)
    end
    if ui.get(nick.ref.antiaim.body_yaw[1]) ~= "Off" then
        ui.set_visible(nick.ref.antiaim.body_yaw[2], true)
    end
    ui.set_visible(nick.ref.antiaim.freestanding[2], true)

    ui.set_visible(nick.ref.antiaim.fl_enabled[2], true)

    
    ui.set_visible(nick.ref.visuals.remove_fog, true)
    ui.set_visible(ui.reference("Misc", "Settings", "sv_maxusrcmdprocessticks2"), false) -- do not touch it for normal people
end

----------------------

-- @region function callback

----------------------

nick.callback = {
    ["paint"] = function ()
        nick.override_viewmodel()
        nick.thridperson_camera()
        nick.fog()
        nick.bloom()
        
    end,

    ["paint_ui"] = function ()
        nick.menu__loaded()
        nick.indicator()
    end,

    ["setup_command"] = function (events)
        nick.ragebot()
        nick.disabled_correction()
        nick.antiaim()
        nick.defensive_antiaim(events)
        nick.fakelag()
        nick.resolver:run()
    end,

    ["net_update_start"] = function ()
        nick.get_players()
    end,

    ["net_update_end"] = function ()
        nick.get_defensive()
    end,

    ["round_start"] = function ()
        nick.buy_bot()
    end,

    ["shutdown"] = function ()
        nick.menu__unloaded()
        nick.bloom__shutdown()
    end,

    -- @region aimbot logs
    ["aim_fire"] = function (event)
        nick.aimbot_log__fired(event)
    end,

    ["aim_hit"] = function (event)
        nick.aimbot_log__hit(event)
    end,

    ["aim_miss"] = function (event)
        nick.aimbot_log__missed(event)
    end,

    ["player_hurt"] = function (event)
        nick.harmed_log(event)
    end,
}

for key, handle in pairs(nick.callback) do
    client.set_event_callback(key, handle)
end