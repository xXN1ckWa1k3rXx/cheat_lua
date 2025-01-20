--[[
    Better GameSense
    Author: xXYu3_zH3nGL1ngXx
    Branch: Alpha
        - 2/19/2024
]]

local ffi = require "ffi"
local vector = require "vector"

local __version = "Alpha 0.3"

------------------------------------------------------

__UPDATELOG = {
    "2/19/2024 - Changelog",
    "    - Added \"Disabled correction on taser\"",
    "    - Added body yaw inverter",
    "    - Added LC and Freestanding indicator",
    "    - Added AX indicator",
    "    - Added harmed logs",
    "    - Fixed custom aa pitch slider out of 89",
    "    - Fixed some antiaim settings config not loaded",
    "    - Fixed jitter correction not working",
    "    - Improved Antiaim manual yaw",
    "    - Improved override viewmodel",
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
    }
}

nick.ref = {
    rage = {
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

nick.spin_num = function (spin, value1, value2)
    local spin = (globals.curtime() * 500) % 360 - 180
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
                    def_enabled = ui.new_checkbox("aa", "anti-aimbot angles", ("%s - Enabled defensive antiaim [WIP Not working]"):format(v)),
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
        override_aspect_ratio = ui.new_slider("misc", "Miscellaneous", "Override - Aspect ratio", 0, 50, 0, true, "%", 0.1),
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


resolver = {
	records = {},
	work = a(function ()
		local self = resolver
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
		local self = resolver
		for i = 1, 64 do
			plist.set(i, "Force body yaw", false)
		end
		self.records = {}
	end),
	run = a(function (self)

        if ui.get(nick.items.rage.correction_selection) == "Jitter correction" then
            client.set_event_callback("net_update_end", self.work)
            if not this.value then self.restore() end
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

    if not ui.get(nick.items.rage.disable_correction) then return end

    if entity.get_player_weapon(localplayer) == 79 then -- 79 is taser/zeus
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
                    nick.data.aa.__body_yaw = nick.data.aa_menu_item[i]._body_yaw - (nick.data.aa_menu_item[i]._body_yaw * 2)
                elseif ui.get(nick.data.aa_menu_item[i]._body_yaw) < 0 then
                    nick.data.aa.__body_yaw = math.abs(nick.data.aa_menu_item[i]._body_yaw)
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

    ui.set(nick.ref.antiaim.pitch[1], nick.data.aa.pitch)
    ui.set(nick.ref.antiaim.pitch[2], nick.data.aa.__pitch)
    ui.set(nick.ref.antiaim.yaw_base, nick.data.aa.yaw_base)

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

nick.defensive_antiaim = function ()
    -- @WIP
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
        renderer.indicator(color_e.x, color_e.y, color_e.z, 255, "Random body yaw")
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
        ui.set_visible(nick.data.defensive_aa_item[i].pitch, (ui.get(nick.items.antiaim.aa_conditions) == v) and ui.get(nick.data.defensive_aa_item[i].def_enabled))
        ui.set_visible(nick.data.defensive_aa_item[i].__ticks_p, (ui.get(nick.items.antiaim.aa_conditions) == v and ui.get(nick.data.defensive_aa_item[i].pitch) == "Jitter") and ui.get(nick.data.defensive_aa_item[i].def_enabled))
        ui.set_visible(nick.data.defensive_aa_item[i].__pitch_1, (ui.get(nick.items.antiaim.aa_conditions) == v and (ui.get(nick.data.defensive_aa_item[i].pitch) == "Static") or ui.get(nick.data.defensive_aa_item[i].pitch) == "Jitter")  and ui.get(nick.data.defensive_aa_item[i].def_enabled))
        ui.set_visible(nick.data.defensive_aa_item[i].__pitch_2, (ui.get(nick.items.antiaim.aa_conditions) == v and ui.get(nick.data.defensive_aa_item[i].pitch) == "Jitter" ) and ui.get(nick.data.defensive_aa_item[i].def_enabled))
        ui.set_visible(nick.data.defensive_aa_item[i].yaw, (ui.get(nick.items.antiaim.aa_conditions) == v) and ui.get(nick.data.defensive_aa_item[i].def_enabled))
        ui.set_visible(nick.data.defensive_aa_item[i].__ticks_y, (ui.get(nick.items.antiaim.aa_conditions) == v and (ui.get(nick.data.defensive_aa_item[i].yaw) == "Jitter" or ui.get(nick.data.defensive_aa_item[i].yaw) == "Spin" or ui.get(nick.data.defensive_aa_item[i].yaw) == "Sway")   and ui.get(nick.data.defensive_aa_item[i].def_enabled)  ))
        ui.set_visible(nick.data.defensive_aa_item[i].__yaw_1, (ui.get(nick.items.antiaim.aa_conditions) == v and (ui.get(nick.data.defensive_aa_item[i].yaw) == "Static" or ui.get(nick.data.defensive_aa_item[i].yaw) == "Jitter" or ui.get(nick.data.defensive_aa_item[i].yaw) == "Spin") or ui.get(nick.data.defensive_aa_item[i].yaw) == "Sway" )  and ui.get(nick.data.defensive_aa_item[i].def_enabled) )
        ui.set_visible(nick.data.defensive_aa_item[i].__yaw_2, (ui.get(nick.items.antiaim.aa_conditions) == v and (ui.get(nick.data.defensive_aa_item[i].yaw) == "Jitter") or ui.get(nick.data.defensive_aa_item[i].yaw) == "Spin" or ui.get(nick.data.defensive_aa_item[i].yaw) == "Sway") and ui.get(nick.data.defensive_aa_item[i].def_enabled) )
    
    
        ui.set_visible( nick.data.fakelag_item[i].override , ui.get(nick.items.fakelag.conditions) == v and ui.get(nick.items.fakelag.conditions) ~= "Globals"  )
        ui.set_visible( nick.data.fakelag_item[i].mode , ui.get(nick.items.fakelag.conditions) == v )
        ui.set_visible( nick.data.fakelag_item[i].variance , ui.get(nick.items.fakelag.conditions) == v )
        ui.set_visible( nick.data.fakelag_item[i].delay_ticks , ui.get(nick.items.fakelag.conditions) == v and (ui.get(nick.data.fakelag_item[i].mode) == "Jitter"))
        ui.set_visible( nick.data.fakelag_item[i].limit_1 , ui.get(nick.items.fakelag.conditions) == v )
        ui.set_visible( nick.data.fakelag_item[i].limit_2 , ui.get(nick.items.fakelag.conditions) == v and ui.get(nick.data.fakelag_item[i].mode) == "Jitter")
    end

    ui.set_visible(nick.items.misc.buybot_p, ui.get(nick.items.misc.buybot))
    ui.set_visible(nick.items.misc.buybot_s, ui.get(nick.items.misc.buybot))
    ui.set_visible(nick.items.misc.buybot_r, ui.get(nick.items.misc.buybot))

    ui.set_visible(nick.items.misc.override_view_fov, ui.get(nick.items.misc.override_view))
    ui.set_visible(nick.items.misc.override_view_x, ui.get(nick.items.misc.override_view))
    ui.set_visible(nick.items.misc.override_view_y, ui.get(nick.items.misc.override_view))
    ui.set_visible(nick.items.misc.override_view_z, ui.get(nick.items.misc.override_view))
    ui.set_visible(nick.items.misc.override_aspect_ratio, ui.get(nick.items.misc.override_view))

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

    ui.set_visible(ui.reference("Misc", "Settings", "sv_maxusrcmdprocessticks2"), false) -- do not touch it for normal people
end

----------------------

-- @region function callback

----------------------

nick.callback = {
    ["paint"] = function ()
        nick.override_viewmodel()
        nick.thridperson_camera()
    end,

    ["paint_ui"] = function ()
        nick.menu__loaded()
        nick.indicator()
    end,

    ["setup_command"] = function ()
        nick.ragebot()
        nick.disabled_correction()
        nick.antiaim()
        nick.fakelag()
    end,

    ["net_update_start"] = function ()
        nick.get_players()
    end,

    ["round_start"] = function ()
        nick.buy_bot()
    end,

    ["shutdown"] = function ()
        nick.menu__unloaded()
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