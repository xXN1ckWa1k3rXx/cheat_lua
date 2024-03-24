--[[
    Better GameSense Loader
    Author: xXYu3_zH3nGL1ngXx
    Branch: Alpha
        - 2/13/2024
]]

--[[
    I don’t want to waste time on improving the Loader.
    Skeet dosen't like neverlose, it's not from workshop and idk workshop have auto update.

    It's only for load latest better gs script.

    i'll not check any reports of Loader issues. Please don’t waste your time.
]]

local http = require("gamesense/http") or error("Failed to load http library or missing http library");

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

local data = {
    success = false,
    version = "unknown.",
    branch = "unknown",
    date = "",
    file = "",
}

ui.new_label("lua", "a", "Better GameSense\a00FFFFFF Loader\aFFFFFFFF")
ui.new_label("lua", "a", "Author: xXYu3_zH3nGL1ngXx")
local branch = ui.new_combobox("lua", "a", "Branch", {"live", "alpha", "Untested beta"})

local connect__l = ui.new_button("lua", "a", "Github", function(self)
    panorama.open().SteamOverlayAPI.OpenExternalBrowserURL("https://github.com/xXN1ckWa1k3rXx/cheat_lua")
end)

local connect__l = ui.new_button("lua", "a", "Connect to server", function(self)
    http.get("https://raw.githubusercontent.com/xXN1ckWa1k3rXx/cheat_lua/main/better%20gamesense/ini_json.json",
    function (success, response)
        if not success or response.status ~= 200 then
            client.color_log(182, 231, 23, "[gamesense]\0")
            client.color_log(255, 35, 35, " Failed to connect to server")
        return end

        local json_data = response.body
        local decoded_data = json.parse(json_data)

        data.success = true

        if ui.get(branch) == "live" then
            data.version = ui.get(branch)
            data.date = decoded_data.latest_update_live
            data.file = decoded_data.live
        elseif ui.get(branch) == "alpha" then
            data.version = ui.get(branch)
            data.date = decoded_data.latest_update_alpha
            data.file = decoded_data.alpha
        elseif ui.get(branch) == "Untested beta" then
            data.version = ui.get(branch)
            data.date = decoded_data.latest_update_untested_beta
            data.file = decoded_data["Untested beta"]
        end

        menu()
    end)
end)

function menu ()
    ui.new_label("lua", "a", "Latest Update:" .. data.date .. " - " .. data.version)

    http.get("https://raw.githubusercontent.com/xXN1ckWa1k3rXx/cheat_lua/main/better%20gamesense/" .. ui.get(branch) .. "/" .. data.file .. ".lua",
    function (success, response)
            if not success then
                client.color_log(182, 231, 23, "[gamesense]\0")
                client.color_log(255, 35, 35, " Failed to connect to server")
            return end

            ui.new_button("lua", "a", "Load script", function()
                local data = response.body

                local script = load(data)
                script()
            end)
    end)
end