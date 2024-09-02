script_author("alfantasyz")
script_name("FloodDetector v1.0")
script_description("Данный скрипт является универсальным детектором флуда одинаковых сообщений. Создан командой InfoSecurity для администрации RDS.")
require 'lib.moonloader'
local sampev = require ('lib.samp.events')
local imgui = require('imgui')
local encoding = require ('encoding')
local inicfg = require ('inicfg')
encoding.default = 'CP1251'
u8 = encoding.UTF8
local string_flood = ""
local string_number_max = 4
local msgs = {chat = {}}
local string_time = 30

script_properties('work-in-pause')

function detectedFlood(name,id,msg,time,count,number)
	lua_thread.create(function()
		if not isGamePaused() and not isPauseMenuActive() and isGameWindowForeground() then 
			sampAddChatMessage("{68EF9D}[FloodDetect] {FFFFFF}Замечен флуд в чате. Отправлено "..count.." сообщения, за "..time.." секунд из ".. string_time .. " разрешенных!", -1)
			sampAddChatMessage("{68EF9D}[FloodDetect] {FFFFFF}Сообщение: "..msg.." | Отправитель: "..sampGetPlayerNickname(tonumber(id)).."["..id.."]", -1)
			wait(100)
			sampSendChat("/mute " .. id .. " 120 Флуд/Спам.")
		end	
	end)
end	

-- [VIP чат] nick[id]: message

function sampev.onServerMessage(color, text)
    local _, check_flood_id, _, check_flood = string.match(text, "(.+)%((.+)%): {(.+)}(.+)")
	local _, check_floodv_id, check_floodv = string.match(text, "[VIP чат] (.+)%[(%d+)%]: (.+)")
	if not isGamePaused() and not isPauseMenuActive() and isGameWindowForeground() then 
		if check_floodv ~= nil and check_floodv_id ~= nil then  
			string_flood = check_floodv
			local playername,playerid, msg = text:match("[VIP чат] (.+)%[(%d+)%]: (.+)")
			if msgs.chat[playername] and msgs.chat[playername][1] then
				if (#msgs.chat[playername]+1 >= string_number_max) then
					while (#msgs.chat[playername] > string_number_max) do
						table.remove(msgs.chat[playername],1)
					end
					if msgs.chat[playername][#msgs.chat[playername]].id == playerid and msgs.chat[playername][#msgs.chat[playername]].msg == msg then
						msgs.chat[playername][#msgs.chat[playername]+1] = {id = playerid,msg = msg,time = os.clock()}
						if msgs.chat[playername][#msgs.chat[playername]].time and math.ceil(msgs.chat[playername][#msgs.chat[playername]].time - msgs.chat[playername][1].time) < string_time then
							if not isGamePaused() and not isPauseMenuActive() and isGameWindowForeground() then 
								sampAddChatMessage("[FLD] " .. text, -1)
								detectedFlood(playername,playerid,msg,math.ceil(msgs.chat[playername][#msgs.chat[playername]].time - msgs.chat[playername][1].time),#msgs.chat[playername],n)
							end
							for i = 1,string_number_max,1 do
								table.remove(msgs.chat[playername],1)
							end
						end
					else
						for i = 1,string_number_max,1 do
							table.remove(msgs.chat[playername],1)
						end
					end
				else
					if msgs.chat[playername][#msgs.chat[playername]].id == playerid and msgs.chat[playername][#msgs.chat[playername]].msg == msg then
						msgs.chat[playername][#msgs.chat[playername]+1] = {id = playerid,msg = msg,time = os.clock()}
					else
						for i = 1,string_number_max,1 do
							table.remove(msgs.chat[playername],1)
						end
					end
				end
			else
				msgs.chat[playername] = {}
				msgs.chat[playername][#msgs.chat[playername]+1] = {id = playerid,msg = msg,time = os.clock()}
				if string_number_max <= 1 then
					for i = 1,cfg[n].maxmsg,1 do
						table.remove(msgs.chat[playername],1)
					end
				end
			end
		end
	end
	if not isGamePaused() and not isPauseMenuActive() and isGameWindowForeground() then
		if check_flood ~= nil and check_flood_id ~= nil then  
			string_flood = check_flood
			local playername,playerid, _, msg = text:match("(.+)%((.+)%): {(.+)}(.+)")
			if msgs.chat[playername] and msgs.chat[playername][1] then
				if (#msgs.chat[playername]+1 >= string_number_max) then
					while (#msgs.chat[playername] > string_number_max) do
						table.remove(msgs.chat[playername],1)
					end
					if msgs.chat[playername][#msgs.chat[playername]].id == playerid and msgs.chat[playername][#msgs.chat[playername]].msg == msg then
						msgs.chat[playername][#msgs.chat[playername]+1] = {id = playerid,msg = msg,time = os.clock()}
						if msgs.chat[playername][#msgs.chat[playername]].time and math.ceil(msgs.chat[playername][#msgs.chat[playername]].time - msgs.chat[playername][1].time) < string_time then
							if not isGamePaused() and not isPauseMenuActive() and isGameWindowForeground() then 
								sampAddChatMessage("[FLD] " .. text, -1)
								detectedFlood(playername,playerid,msg,math.ceil(msgs.chat[playername][#msgs.chat[playername]].time - msgs.chat[playername][1].time),#msgs.chat[playername],n)
							end
							for i = 1,string_number_max,1 do
								table.remove(msgs.chat[playername],1)
							end
						end
					else
						for i = 1,string_number_max,1 do
							table.remove(msgs.chat[playername],1)
						end
					end
				else
					if msgs.chat[playername][#msgs.chat[playername]].id == playerid and msgs.chat[playername][#msgs.chat[playername]].msg == msg then
						msgs.chat[playername][#msgs.chat[playername]+1] = {id = playerid,msg = msg,time = os.clock()}
					else
						for i = 1,string_number_max,1 do
							table.remove(msgs.chat[playername],1)
						end
					end
				end
			else
				msgs.chat[playername] = {}
				msgs.chat[playername][#msgs.chat[playername]+1] = {id = playerid,msg = msg,time = os.clock()}
				if string_number_max <= 1 then
					for i = 1,cfg[n].maxmsg,1 do
						table.remove(msgs.chat[playername],1)
					end
				end
			end
		end
	end
end

function main()
    while not isSampAvailable() do wait(0) end
    
    sampAddChatMessage("{68EF9D}[FloodDetect] {FFFFFF}Детектор флуда успешно инициализирован.")

    while true do
        wait(0)
    end
end

function EXPORTS.off_script()
	thisScript():unload()
end