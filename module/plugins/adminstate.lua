script_name('AdminTool Statistic') 
script_description('Скрипт, записывающий статистику.')
script_author('alfantasyz')

-- ## Регистрация библиотек, плагинов и аддонов ## --
require 'lib.moonloader'
local flags_font = require("moonloader").font_flag -- внедрение шрифта для рендерных функций
local imgui = require('imgui') -- регистрация графического интерфейса ImGUI
local inicfg = require 'inicfg' -- работа с ini
local sampev = require "lib.samp.events" -- подключение основных библиотек, связанные с потокам пакетов ивентов SA:MP, и их прямое соединение с LUA
local atlibs = require 'libsfor' -- библиотека для работы с АТ
local encoding = require 'encoding' -- работа с кодировками
local notf_res, notf = pcall(import, 'lib/imgui_notf.lua')  -- плагин уведомлений
local fai = require "fAwesome5" -- работа с иконками Font Awesome 5
local fa = require 'faicons' -- работа с иконками Font Awesome 4
-- ## Регистрация библиотек, плагинов и аддонов ## --

-- ## Блок текстовых переменных ## --
local tag = "{00BFFF} [AT] {FFFFFF}" -- тэг AT
local log = "{00BFFF} [AdminTool-Log] {FFFFFF}" -- тэг лога АТ
local ntag = "{00BFFF} Notf - AdminTool" -- тэг уведомлений АТ
encoding.default = 'CP1251' -- смена кодировки на CP1251
u8 = encoding.UTF8 -- переименовка стандтартного режима кодировки UTF8 - u8
-- ## Блок текстовых переменных ## --

-- ## Регистрация уведомлений ## --
function showNotification(text)
	notf.addNotify(ntag, text, 2, 1, 6)
end
-- ## Регистрация уведомлений ## --

-- ## Блок переменных связанных с конфигами и элементами взаимодействия с параметрами конфига ## --
local directIni = 'AdminTool\\admstat.ini'
local config = inicfg.load({
    settings = {
        admin_state = false,
    },
    adminstate = {
        show_transparency = false,
        color_nick_id = "{FFFFFF}",
        color_time = "{FFFFFF}",
        color_online_day = "{FFFFFF}",
        color_online_now = "{FFFFFF}",
        color_afk_day = "{FFFFFF}",
        color_afk_now = "{FFFFFF}",
        color_ans_day = "{FFFFFF}",
        color_ans_now = "{FFFFFF}",
        color_mute_day = "{FFFFFF}",
        color_mute_now = "{FFFFFF}",
        color_kick_day = "{FFFFFF}",
        color_kick_now = "{FFFFFF}",
        color_jail_day = "{FFFFFF}",
        color_jail_now = "{FFFFFF}",
        color_ban_day = "{FFFFFF}",
        color_ban_now = "{FFFFFF}",

        show_mute_day = false,
        show_mute_now = false,
        show_report_day = false,
        show_report_now = false,
        show_jail_day = false,
        show_jail_now = false,
        show_ban_day = false,
        show_ban_now = false,
        show_kick_day = false,
        show_kick_now = false,
        show_online_day = false,
        show_online_now = false,
        show_afk_day = false,
        show_afk_now = false,
        show_nick_id = false, 
        show_time = false,

        dayReport = 0,
        dayTime = 1,
        today = os.date("%a"),
        online = 0,
        afk = 0,
        full = 0,
        dayMute = 0,
        dayJail = 0,
        dayBan = 0,
        dayKick = 0,

        posX = 0,
        posY = 0,
    },
}, directIni)
inicfg.save(config, directIni)

function save() 
    inicfg.save(config, directIni)
end

local elements = {
    boolean = {
        adminstate = imgui.ImBool(config.settings.admin_state)
    },
    admin_state = {
        color_nick_id = imgui.ImBuffer(tostring(config.adminstate.color_nick_id), 50),
        color_time = imgui.ImBuffer(tostring(config.adminstate.color_time), 50),
        color_online_day = imgui.ImBuffer(tostring(config.adminstate.color_online_day), 50),
        color_online_now = imgui.ImBuffer(tostring(config.adminstate.color_online_now), 50),
        color_afk_day = imgui.ImBuffer(tostring(config.adminstate.color_afk_day), 50),
        color_afk_now = imgui.ImBuffer(tostring(config.adminstate.color_afk_now), 50),
        color_ans_day = imgui.ImBuffer(tostring(config.adminstate.color_ans_day), 50),
        color_ans_now = imgui.ImBuffer(tostring(config.adminstate.color_ans_now), 50),
        color_mute_day = imgui.ImBuffer(tostring(config.adminstate.color_mute_day), 50),
        color_mute_now = imgui.ImBuffer(tostring(config.adminstate.color_mute_now), 50),
        color_kick_day = imgui.ImBuffer(tostring(config.adminstate.color_kick_day), 50),
        color_kick_now = imgui.ImBuffer(tostring(config.adminstate.color_kick_now), 50),
        color_jail_day = imgui.ImBuffer(tostring(config.adminstate.color_jail_day), 50),
        color_jail_now = imgui.ImBuffer(tostring(config.adminstate.color_jail_now), 50),
        color_ban_day = imgui.ImBuffer(tostring(config.adminstate.color_ban_day), 50),
        color_ban_now = imgui.ImBuffer(tostring(config.adminstate.color_ban_now), 50),

        show_mute_day = imgui.ImBool(config.adminstate.show_mute_day), 
        show_mute_now = imgui.ImBool(config.adminstate.show_mute_now),
        show_ban_day = imgui.ImBool(config.adminstate.show_ban_day), 
        show_ban_now = imgui.ImBool(config.adminstate.show_ban_now),
        show_jail_day = imgui.ImBool(config.adminstate.show_jail_day), 
        show_jail_now = imgui.ImBool(config.adminstate.show_jail_now),
        show_kick_day = imgui.ImBool(config.adminstate.show_kick_day), 
        show_kick_now = imgui.ImBool(config.adminstate.show_kick_now),
        show_nick_id = imgui.ImBool(config.adminstate.show_nick_id), 
        show_afk_day = imgui.ImBool(config.adminstate.show_afk_day), 
        show_afk_now = imgui.ImBool(config.adminstate.show_afk_now),
        show_online_day = imgui.ImBool(config.adminstate.show_online_day), 
        show_online_now = imgui.ImBool(config.adminstate.show_online_now),
        show_report_day = imgui.ImBool(config.adminstate.show_report_day), 
        show_report_now = imgui.ImBool(config.adminstate.show_report_now),
        show_time = imgui.ImBool(config.adminstate.show_time),
        show_transparency = imgui.ImBool(config.adminstate.show_transparency),
    },
}

local varstate = {
    sessionOnline = imgui.ImInt(0),
    sessionAfk = imgui.ImInt(0),
    sessionFull = imgui.ImInt(0),
    dayFull = imgui.ImInt(config.adminstate.full),
    nowTime = os.date("%H:%M:%S", os.time()),
    LReport = 0,
    LMute = 0,
    LBan = 0,
    LKick = 0,
    LJail = 0,
    changePosition = false,
}
-- ## Блок переменных связанных с конфигами и элементами взаимодействия с параметрами конфига ## --

-- ## Блок переменных связанных с графическим интерфейсом ImGUI ## -- 
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
local fai_glyph_ranges = imgui.ImGlyphRanges({ fai.min_range, fai.max_range })

local fontsize = nil

function imgui.BeforeDrawFrame()
    if fai_font == nil then
        local font_config = imgui.ImFontConfig()
        font_config.MergeMode = true
        fai_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 13.0, font_config, fai_glyph_ranges)
    end
    if fa_font == nil then
		local font_config = imgui.ImFontConfig()
		font_config.MergeMode = true 
		fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fontawesome-webfont.ttf', 14.0, font_config, fa_glyph_ranges)
	end	
    if fontsize == nil then
        fontsize = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\SegoeUI.ttf', 14.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) 
    end
end

imgui.ToggleButton = require('imgui_addons').ToggleButton
imgui.Tooltip = require('imgui_addons').Tooltip

local sw, sh = getScreenResolution()
-- ## Блок переменных связанных с графическим интерфейсом ImGUI ## -- 

-- ## Функции, захватывающие определенные значения пакетов ## --
function getMyId()
    local result, id = sampGetPlayerIdByCharHandle(playerPed)
    if result then
        return id
    end
end

function getMyNick()
    local result, id = sampGetPlayerIdByCharHandle(playerPed)
    if result then
        local nick = sampGetPlayerNickname(id)
        return nick
    end
end
-- ## Функции, захватывающие определенные значения пакетов ## --

function sampev.onServerMessage(color, text)
    if elements.boolean.adminstate.v then 
        if text:find('%[.*%] '..getMyNick()..'%['..getMyId()..'%] ответил (.*)%[(%d+)%]: (.*)') then 
            config.adminstate.dayReport = config.adminstate.dayReport + 1
            varstate.LReport = varstate.LReport + 1
            save()
            return true
        end	

        if text:find("Администратор .+ заткнул%(.+%) игрока .+ на .+ секунд. Причина: .+") then  
            amd_nick = text:match('Администратор (.+) заткнул%(.+%) игрока .+ на .+ секунд. Причина: .+') 
            if amd_nick:find(getMyNick()) then
                config.adminstate.dayMute = config.adminstate.dayMute + 1 
                varstate.LMute = varstate.LMute + 1 
                save()
            end
            return true 
        end 

        if text:find("Администратор .+ посадил%(.+%) игрока .+ в тюрьму на .+ секунд. Причина: .+") then  
            amd_nick = text:match('Администратор (.+) посадил%(.+%) игрока .+ в тюрьму на .+ секунд. Причина: .+') 
            if amd_nick:find(getMyNick()) then
                config.adminstate.dayJail = config.adminstate.dayJail + 1 
                varstate.LJail = varstate.LJail + 1 
                save()
            end 
            return true 
        end 
        
        if text:find("Администратор .+ забанил%(.+%) игрока .+ на .+ дней. Причина: .+") then  
            amd_nick = text:match('Администратор (.+) забанил%(.+%) игрока .+ на .+ дней. Причина: .+') 
            if amd_nick:find(getMyNick()) then
                config.adminstate.dayBan = config.adminstate.dayBan + 1 
                varstate.LBan = varstate.LBan + 1 
                save()
            end  
            return true 
        end 

        if text:find("Администратор .+ кикнул игрока .+. Причина: .+") then  
            amd_nick = text:match('Администратор (.+) кикнул игрока .+. Причина: .+') 
            if amd_nick:find(getMyNick()) then
                config.adminstate.dayKick = config.adminstate.dayKick + 1 
                varstate.LKick = varstate.LKick + 1 
                save()
            end 
            return true 
        end 
    end
end

function main()
    while not isSampAvailable() do wait(0) end
    
    lua_thread.create(time)

    sampfuncsLog(log .. 'Инициализация административной статистики.')

    if config.adminstate.today ~= os.date("%a") then 
		config.adminstate.today = os.date("%a")
		config.adminstate.online = 0
        config.adminstate.full = 0
		config.adminstate.afk = 0
		config.adminstate.dayReport = 0
        config.adminstate.dayKick = 0 
        config.adminstate.dayBan = 0  
        config.adminstate.dayJail = 0 
        config.adminstate.dayMute = 0 
	  	varstate.dayFull.v = 0
		save()
    end

    while true do
        wait(0)

        imgui.Process = true  

        if not elements.boolean.adminstate.v then
            elements.boolean.adminstate.v = false 
            imgui.ShowCursor = false  
            imgui.Process = false  
        end

        Position_AdminState()
    end
end

function showCursor(toggle)
    if toggle then
        sampSetCursorMode(CMODE_LOCKCAM)
    else
        sampToggleCursor(false)
    end
    cursorEnabled = toggle
end

function Position_AdminState()
    if varstate.changePosition then  
        showCursor(true, false)
        local mouseX, mouseY = getCursorPos()
        config.adminstate.posX, config.adminstate.posY = mouseX, mouseY
        if isKeyJustPressed(49) then
            showCursor(false, false)
            showNotification("Успешно сохранено")
            varstate.changePosition = false
            save()
        end
    end
end

function get_clock(time)
    local timezone_offset = 86400 - os.date('%H', 0) * 3600
    if tonumber(time) >= 86400 then onDay = true else onDay = false end
    return os.date((onDay and math.floor(time / 86400)..'д ' or '')..'%H:%M:%S', time + timezone_offset)
end

function time()
	startTime = os.time()
    while true do
        wait(1000)
        varstate.nowTime = os.date("%H:%M:%S", os.time()) 
        if sampGetGamestate() == 3 then 								
	        			
	        varstate.sessionOnline.v = varstate.sessionOnline.v + 1 							
	        varstate.sessionFull.v = os.time() - startTime 					
	        varstate.sessionAfk.v = varstate.sessionFull.v - varstate.sessionOnline.v		
			
			config.adminstate.online = config.adminstate.online + 1 				
	        config.adminstate.full = varstate.dayFull.v + varstate.sessionFull.v 						
			config.adminstate.afk = config.adminstate.full - config.adminstate.online

	    else
	    	startTime = startTime + 1
	    end
    end
end

function onScriptTerminate(script, quitGame)
	if script == thisScript() then 
		if inicfg.save(config, directIni) then sampfuncsLog(log .. 'Сохранение административной статистики.') end
	end
end


function imgui.OnDrawFrame()
    if elements.boolean.adminstate.v then  
        imgui.ShowCursor = false 
        if config.adminstate.posX == 0 and config.adminstate.posY == 0 then  
            imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirsUseEver, imgui.ImVec2(0.5, 0.5))
        else 
            imgui.SetNextWindowPos(imgui.ImVec2(config.adminstate.posX, config.adminstate.posY), imgui.Cond.FirsUseEver, imgui.ImVec2(0.5, 0.5))
        end 

        if elements.admin_state.show_transparency.v then  
            imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(1.00, 1.00, 1.00, 0.05))
        end  

        imgui.Begin('##AdminState', nil, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar)
            if elements.admin_state.show_nick_id.v then atlibs.imgui_TextColoredRGB(elements.admin_state.color_nick_id.v .. getMyNick() .. " || ID: " ..  getMyId()) end
            if elements.admin_state.show_online_day.v then atlibs.imgui_TextColoredRGB(elements.admin_state.color_online_day.v .. "Онлайн за день: " .. get_clock(config.adminstate.online)) end 
            if elements.admin_state.show_online_now.v then atlibs.imgui_TextColoredRGB(elements.admin_state.color_online_now.v .. "Онлайн за сеанс: " .. get_clock(varstate.sessionOnline.v)) end
            if elements.admin_state.show_afk_day.v then atlibs.imgui_TextColoredRGB(elements.admin_state.color_afk_day.v .. "AFK за день: " .. get_clock(config.adminstate.afk)) end
            if elements.admin_state.show_afk_now.v then atlibs.imgui_TextColoredRGB(elements.admin_state.color_afk_now.v .. "AFK за сеанс: " .. get_clock(varstate.sessionAfk.v)) end
            if elements.admin_state.show_report_day.v then atlibs.imgui_TextColoredRGB(elements.admin_state.color_ans_day.v .. "Репортов за день: " .. config.adminstate.dayReport) end
            if elements.admin_state.show_report_now.v then atlibs.imgui_TextColoredRGB(elements.admin_state.color_ans_now.v .. "Репортов за сеанс: " .. varstate.LReport) end
            if elements.admin_state.show_ban_day.v then atlibs.imgui_TextColoredRGB(elements.admin_state.color_ban_day.v .. "Баны за день: " .. config.adminstate.dayBan) end
            if elements.admin_state.show_ban_now.v then atlibs.imgui_TextColoredRGB(elements.admin_state.color_ban_now.v .. "Баны за сеанс: " .. varstate.LBan) end
            if elements.admin_state.show_mute_day.v then atlibs.imgui_TextColoredRGB(elements.admin_state.color_mute_day.v .. "Муты за день: " .. config.adminstate.dayMute) end
            if elements.admin_state.show_mute_now.v then atlibs.imgui_TextColoredRGB(elements.admin_state.color_mute_now.v .. "Муты за сеанс: " .. varstate.LMute) end
            if elements.admin_state.show_jail_day.v then atlibs.imgui_TextColoredRGB(elements.admin_state.color_jail_day.v .. "Джаилы за день: " .. config.adminstate.dayJail) end
            if elements.admin_state.show_jail_now.v then atlibs.imgui_TextColoredRGB(elements.admin_state.color_jail_now.v .. "Джаилы за сеанс: " .. varstate.LJail) end
            if elements.admin_state.show_kick_day.v then atlibs.imgui_TextColoredRGB(elements.admin_state.color_kick_day.v .. "Кики за день: " .. config.adminstate.dayKick) end
            if elements.admin_state.show_kick_now.v then atlibs.imgui_TextColoredRGB(elements.admin_state.color_kick_now.v .. "Кики за сеанс: " .. varstate.LKick) end
            if elements.admin_state.show_time.v then atlibs.imgui_TextColoredRGB(elements.admin_state.color_time.v .. (os.date("%d.%m.%y | %H:%M:%S", os.time()))) end
        imgui.End()

        if elements.admin_state.show_transparency.v then  
            imgui.PopStyleColor()
        end  
    end    
end

function EXPORTS.AdminStateMenu()
    imgui.Text(fa.ICON_ADDRESS_BOOK .. u8' Включение админ-статистики') 
    imgui.SameLine()
    if imgui.ToggleButton('##AdminStateVariable', elements.boolean.adminstate) then  
        config.settings.admin_state = elements.boolean.adminstate.v  
        save() 
    end
    imgui.SameLine(); imgui.SetCursorPosX(imgui.GetWindowWidth() - 250);
    if imgui.Button(fa.ICON_FA_COGS .. u8' Изменение позиции окна') then 
        varstate.changePosition = true 
        sampAddChatMessage(tag .. ' Чтобы подтвердить сохранение - нажмите <1>')
    end
    if imgui.Checkbox(u8'Прозрачное окно', elements.admin_state.show_transparency) then  
        config.adminstate.show_transparency = elements.admin_state.show_transparency.v  
        save() 
    end 
    imgui.Separator()
    imgui.Text(u8'Возле каждого из значений есть блок текста, в него можно внести текст формата {RRGGBB}')
    if imgui.Checkbox(u8'Показ никнейма и ID', elements.admin_state.show_nick_id) then  
        config.adminstate.show_nick_id = elements.admin_state.show_nick_id.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_nick_id", elements.admin_state.color_nick_id) then  
        config.adminstate.color_nick_id = elements.admin_state.color_nick_id.v  
        save() 
    end
    imgui.PopItemWidth()
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'Показ времени', elements.admin_state.show_time) then  
        config.adminstate.show_time = elements.admin_state.show_time.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_time", elements.admin_state.color_time) then  
        config.adminstate.color_time = elements.admin_state.color_time.v  
        save() 
    end
    imgui.PopItemWidth()
    if imgui.Checkbox(u8'Показ онлайна за день', elements.admin_state.show_online_day) then  
        config.adminstate.show_online_day = elements.admin_state.show_online_day.v  
        save() 
    end
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_online_day", elements.admin_state.color_online_day) then  
        config.adminstate.color_online_day = elements.admin_state.color_online_day.v  
        save() 
    end    
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'Показ онлайна за сеанс', elements.admin_state.show_online_now) then  
        config.adminstate.show_online_now = elements.admin_state.show_online_now.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_online_now", elements.admin_state.color_online_now) then  
        config.adminstate.color_online_now = elements.admin_state.color_online_now.v  
        save() 
    end    
    if imgui.Checkbox(u8'Показ AFK за день', elements.admin_state.show_afk_day) then  
        config.adminstate.show_afk_day = elements.admin_state.show_afk_day.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_afk_day", elements.admin_state.color_afk_day) then  
        config.adminstate.color_afk_day = elements.admin_state.color_afk_day.v  
        save() 
    end    
    imgui.PopItemWidth()
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'Показ AFK за сеанс', elements.admin_state.show_afk_now) then  
        config.adminstate.show_afk_now = elements.admin_state.show_afk_now.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_afk_now", elements.admin_state.color_afk_now) then  
        config.adminstate.color_afk_now = elements.admin_state.color_afk_now.v  
        save() 
    end    
    imgui.PopItemWidth()
    if imgui.Checkbox(u8'Показ репортов за день', elements.admin_state.show_report_day) then  
        config.adminstate.show_report_day = elements.admin_state.show_report_day.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_ans_day", elements.admin_state.color_ans_day) then  
        config.adminstate.color_ans_day = elements.admin_state.color_ans_day.v  
        save() 
    end    
    imgui.PopItemWidth()
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'Показ репортов за сеанс', elements.admin_state.show_report_now) then  
        config.adminstate.show_report_now = elements.admin_state.show_report_now.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_ans_day", elements.admin_state.color_ans_now) then  
        config.adminstate.color_ans_now = elements.admin_state.color_ans_now.v  
        save() 
    end    
    imgui.PopItemWidth()
    if imgui.Checkbox(u8'Показ мутов за день', elements.admin_state.show_mute_day) then  
        config.adminstate.show_mute_day = elements.admin_state.show_mute_day.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_mute_day", elements.admin_state.color_mute_day) then  
        config.adminstate.color_mute_day = elements.admin_state.color_mute_day.v  
        save() 
    end    
    imgui.PopItemWidth()
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'Показ мутов за сеанс', elements.admin_state.show_mute_now) then  
        config.adminstate.show_mute_now = elements.admin_state.show_mute_now.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_mute_now", elements.admin_state.color_mute_now) then  
        config.adminstate.color_mute_now = elements.admin_state.color_mute_now.v  
        save() 
    end    
    imgui.PopItemWidth()
    if imgui.Checkbox(u8'Показ киков за день', elements.admin_state.show_kick_day) then  
        config.adminstate.show_kick_day = elements.admin_state.show_kick_day.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_kick_day", elements.admin_state.color_kick_day) then  
        config.adminstate.color_kick_day = elements.admin_state.color_kick_day.v  
        save() 
    end    
    imgui.PopItemWidth()
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'Показ киков за сеанс', elements.admin_state.show_kick_now) then  
        config.adminstate.show_kick_now = elements.admin_state.show_kick_now.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_kick_now", elements.admin_state.color_kick_now) then  
        config.adminstate.color_kick_now = elements.admin_state.color_kick_now.v  
        save() 
    end    
    imgui.PopItemWidth()
    if imgui.Checkbox(u8'Показ джайлов за день', elements.admin_state.show_jail_day) then  
        config.adminstate.show_jail_day = elements.admin_state.show_jail_day.v  
        save() 
    end   
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_jail_day", elements.admin_state.color_jail_day) then  
        config.adminstate.color_jail_day = elements.admin_state.color_jail_day.v  
        save() 
    end    
    imgui.PopItemWidth()
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'Показ джайлов за сеанс', elements.admin_state.show_jail_now) then  
        config.adminstate.show_jail_now = elements.admin_state.show_jail_now.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_jail_now", elements.admin_state.color_jail_now) then  
        config.adminstate.color_jail_now = elements.admin_state.color_jail_now.v  
        save() 
    end    
    imgui.PopItemWidth()
    if imgui.Checkbox(u8'Показ банов за день', elements.admin_state.show_ban_day) then  
        config.adminstate.show_ban_day = elements.admin_state.show_ban_day.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_ban_day", elements.admin_state.color_ban_day) then  
        config.adminstate.color_ban_day = elements.admin_state.color_ban_day.v  
        save() 
    end    
    imgui.PopItemWidth()
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'Показ банов за сеанс', elements.admin_state.show_ban_now) then  
        config.adminstate.show_ban_now = elements.admin_state.show_ban_now.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_ban_now", elements.admin_state.color_ban_now) then  
        config.adminstate.color_ban_now = elements.admin_state.color_ban_now.v  
        save() 
    end    
    imgui.PopItemWidth()
end

function EXPORTS.OffScript()
    imgui.Process = false
    imgui.ShowCursor = false
    thisScript():unload()
end 