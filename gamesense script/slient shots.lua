-- Slient Shots for gamesense.pub
-- Part of the code of Better neverlose

local nick = {}
local enabled = ui.new_checkbox("aa", "fake lag", "Slient shots")


nick.slient_shots = function()
  
    local localplayer = entity.get_local_player()
    if not localplayer then return end
    
    local my_weapon = entity.get_player_weapon(localplayer)
    
    if ui.get(enabled) then
        if my_weapon then
            local last_shot_time = entity.get_prop(my_weapon, "m_fLastShotTime")
	    	local time_difference = globals.curtime() - last_shot_time
    
            if time_difference <= 0.025 then
                ui.set(ui.reference("aa", "fake lag", "enabled"), false)
            else
                ui.set(ui.reference("aa", "fake lag", "enabled"), true)
            end
        end
    end
end

client.set_event_callback("paint", nick.slient_shots)