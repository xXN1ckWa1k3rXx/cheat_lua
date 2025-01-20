--[[
    Better GameSense
    Author: xXYu3_zH3nGL1ngXx
    Branch: Alpha
        - 2/17/2024
]]

local vector = require "vector"
local __version = "Alpha 0.1"
print("Welcome use Better GameSense. Current version is " .. __version)

----------------------------------------------------
local nick = {}

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

    fl = {
        mode = nil,
        variance = 0,
        limit = 0,
    }
}

nick.ref = {
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
}

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

nick.items = {
    antiaim = {
        enabled = ui.new_checkbox("aa", "anti-aimbot angles", "[Better GS] Enabled AntiAim"),
        aa_conditions = ui.new_combobox("aa", "anti-aimbot angles", "Settings - AA Conditon", nick.data.conditions),

        aa_item = (function()
            for i, v in ipairs (nick.data.conditions) do
                nick.data.aa_menu_item[i] = {
                    override = ui.new_checkbox("aa", "anti-aimbot angles", ("%s - Override globals settings"):format(v)),
                    pitch = ui.new_combobox("aa", "anti-aimbot angles", ("%s - Pitch"):format(v), {"Off", "Default", "Up", "Down", "Minimal", "Random", "Custom"}),
                    _pitch = ui.new_slider("aa", "anti-aimbot angles", "\n", -180, 180, 0, true, "°"),
                    yaw_base = ui.new_combobox("aa", "anti-aimbot angles", ("%s - Yaw base"):format(v), {"Local view", "At targets"}),
                    yaw = ui.new_combobox("aa", "anti-aimbot angles", ("%s - Yaw"):format(v), {"Off", "180", "Spin", "Static", "180Z", "Crosshair"}),
                    _yaw = ui.new_slider("aa", "anti-aimbot angles", "\n", -180, 180, 0, true, "°"),
                    yaw_jitter = ui.new_combobox("aa", "anti-aimbot angles", ("%s - Yaw Jitter"):format(v), {"Off", "Offset", "Center", "Random", "Skitter", "[Better GS] 3-Way [WIP]", "[Better GS] 5-Way [WIP]"}),
                    _yaw_jitter = ui.new_slider("aa", "anti-aimbot angles", "\n", -180, 180, 0),
                    body_yaw = ui.new_combobox("aa", "anti-aimbot angles", ("%s - Body yaw"):format(v), {"Off", "Opposite", "Jitter", "Static"}),
                    _body_yaw = ui.new_slider("aa", "anti-aimbot angles", "\n", -180, 180, 0, true, "°"),
                    freestanding_body_yaw = ui.new_checkbox("aa", "anti-aimbot angles", ("%s - Freestanding body yaw"):format(v)),
                    edge_yaw = ui.new_checkbox("aa", "anti-aimbot angles", ("%s - Edge yaw"):format(v)),
                    roll = ui.new_slider("aa", "anti-aimbot angles", ("%s - Extended roll"):format(v), -45, 45, 0, true, "°"),
                }
            end
        end)(),
        freestanding = ui.new_hotkey("aa", "anti-aimbot angles", "Freestanding", false, 0),

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
        override_view_fov = ui.new_slider("misc", "Miscellaneous", "Override - FOV", 0, 160, 70, true, "°", 0.1),
        override_view_x = ui.new_slider("misc", "Miscellaneous", "Override - X", -200, 200, 0, true, "°", 0.1),
        override_view_y = ui.new_slider("misc", "Miscellaneous", "Override - Y", -200, 200, 0, true, "°", 0.1),
        override_view_z = ui.new_slider("misc", "Miscellaneous", "Override - Z", -200, 200, 0, true, "°", 0.1),
        override_aspect_ratio = ui.new_slider("misc", "Miscellaneous", "Override - Aspect ratio", 0, 50, 0, true, "%", 0.1),
    },
}

nick.antiaim = function ()
    if not ui.get(nick.items.antiaim.enabled) then return end

    ui.set(nick.ref.antiaim.aa_enabled, true)
    
    
    for i, v in ipairs(nick.data.conditions) do

        if not ui.get(nick.data.aa_menu_item[i].override) then i = 1 end

        if nick.get_condition() == v then 
            nick.data.aa.pitch = ui.get(nick.data.aa_menu_item[i].pitch)
            nick.data.aa.__pitch = ui.get(nick.data.aa_menu_item[i]._pitch)
            nick.data.aa.yaw_base = ui.get(nick.data.aa_menu_item[i].yaw_base)
            nick.data.aa.yaw = ui.get(nick.data.aa_menu_item[i].yaw)
            nick.data.aa.__yaw = ui.get(nick.data.aa_menu_item[i]._yaw)
            nick.data.aa.yaw_jitter = ui.get(nick.data.aa_menu_item[i].yaw_jitter)
            nick.data.aa.__yaw_jitter = ui.get(nick.data.aa_menu_item[i]._yaw_jitter)
            nick.data.aa.body_yaw = ui.get(nick.data.aa_menu_item[i].body_yaw)
            nick.data.aa.__body_yaw = ui.get(nick.data.aa_menu_item[i]._body_yaw)
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

nick.defensive_antiaim = function ()
    -- @WIP
end

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

nick.thridperson_camera = function ()
    local dist = nick.math_new_lerp("thrid_camera", ui.get(nick.ref.visuals.thrid_person[2]) and ui.get(nick.items.misc.thridperson_camera) or 0, globals.frametime() * 15)

    cvar.c_mindistance:set_int(dist)
    cvar.c_maxdistance:set_int(dist)
end

nick.override_viewmodel = function ()
    local fov = nick.math_new_lerp("viewmodel_fov", ui.get(nick.items.misc.override_view) and ui.get(nick.items.misc.override_view_fov) or 70, globals.frametime() * 15)
    local x = nick.math_new_lerp("viewmodel_x", ui.get(nick.items.misc.override_view) and ui.get(nick.items.misc.override_view_x) or 0, globals.frametime() * 15)
    local y = nick.math_new_lerp("viewmodel_y", ui.get(nick.items.misc.override_view) and ui.get(nick.items.misc.override_view_y) or 0, globals.frametime() * 15)
    local z = nick.math_new_lerp("viewmodel_z", ui.get(nick.items.misc.override_view) and ui.get(nick.items.misc.override_view_z) or 0, globals.frametime() * 15)

    cvar.viewmodel_fov:set_int(fov)
    cvar.viewmodel_offset_x:set_float(x / 10, true)
    cvar.viewmodel_offset_y:set_float(y / 10, true)
    cvar.viewmodel_offset_z:set_float(z / 10, true)

    scale = ui.get(nick.items.misc.override_aspect_ratio) == 0 and 17.5 or nick.math_new_lerp("aspect_ratio", ui.get(nick.items.misc.override_view) and ui.get(nick.items.misc.override_aspect_ratio) or 17.5, globals.frametime() * 15)

    cvar.r_aspectratio:set_float(scale / 10)
end

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

nick.callback = {
    ["paint"] = function ()
        nick.override_viewmodel()
        nick.thridperson_camera()
    end,

    ["paint_ui"] = function ()
        nick.menu__loaded()
    end,

    ["setup_command"] = function ()
        nick.antiaim()
        nick.fakelag()
    end,

    ["round_start"] = function ()
        nick.buy_bot()
    end,

    ["shutdown"] = function ()
        nick.menu__unloaded()
    end,
}

for key, handle in pairs(nick.callback) do
    client.set_event_callback(key, handle)
end