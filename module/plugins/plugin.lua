script_name('AdminTool ExtraFunctions') 
script_description('Специальный скрипт, позволяющий интегрировать сторонние функции вместе с основным скриптом АТ')
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

local ease = require('ease') -- работа с анимацией

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
local directIni = "AdminTool\\extraplugin.ini"
local config = inicfg.load({
    settings = {
        adminforms = false,
        adminchat = false,
        auto_adminforms = false,
        imgui_adminchat = false, 
        admin_state = false,
    },
    achat = {
        X = 48,
        Y = 298, 
        centered = 0,
        color = -1,
        nick = 1,
        lines = 10,
        Font = 10, 
		lines_imgui = 10,
		X_imgui = 50,
		Y_imgui = 298,
        iFont = 10,
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

function save() 
    inicfg.save(config, directIni)
end

local elements = {
    boolean = {
        adminchat = imgui.ImBool(config.settings.adminchat),
        adminforms = imgui.ImBool(config.settings.adminforms),
        auto_adminforms = imgui.ImBool(config.settings.auto_adminforms),
        imgui_adminchat = imgui.ImBool(config.settings.imgui_adminchat),
        adminstate = imgui.ImBool(config.settings.admin_state)
    },
    int = {
        adminFont = imgui.ImInt(config.achat.Font),
        imguiFont = imgui.ImInt(config.achat.iFont),
    },
    admin_state = {
        color_nick_id = imgui.ImBuffer(tostring(config.adminstate.color_nick_id), 50),
        color_time = imgui.ImBuffer(tostring(config.adminstate.color_time), 50),
        color_online_day = imgui.ImBuffer(tostring(config.adminstate.color_online_day), 50),
        color_online_now = imgui.ImBuffer(tostring(config.adminstate.color_online_now), 50),
        color_afk_day = imgui.ImBuffer(tostring(config.adminstate.color_afk_day), 50),
        color_afk_now = imgui.ImBuffer(tostring(config.adminstate.color_afk_now), 50),
        color_ans_day = imgui.ImBuffer(tostring(config.adminstate.color_ans_day), 50),
        color_ans_day = imgui.ImBuffer(tostring(config.adminstate.color_ans_now), 50),
        color_mute_day = imgui.ImBuffer(tostring(config.adminstate.olor_mute_day), 50),
        color_mute_now = imgui.ImBuffer(tostring(config.adminstate.color_mute_now), 50),
        color_kick_day = imgui.ImBuffer(tostring(config.adminstate.color_kick_day), 50),
        color_kick_now = imgui.ImBuffer(tostring(config.adminstate.ccolor_kick_now), 50),
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

local every_settings = {
    admin_chat = {
        centered = imgui.ImInt(0),
        nick = imgui.ImInt(1),
        color = -1,
        render_lines = imgui.ImInt(10),
        X = 0,
        Y = 0,
        lines_imgui = imgui.ImInt(10)
    },
    no_saved_ac = {
        chat_lines = { },
        pos = false,
        chat_lines_imgui = { },
        X = 0,
        Y = 0,
    },
}

function saveAC()
    config.achat.X = every_settings.admin_chat.X 
    config.achat.Y = every_settings.admin_chat.Y 
    config.achat.centered = every_settings.admin_chat.centered.v  
    config.achat.nick = every_settings.admin_chat.nick.v  
    config.achat.color = every_settings.admin_chat.color  
    config.achat.lines = every_settings.admin_chat.render_lines.v  
    config.achat.lines_imgui = every_settings.admin_chat.lines_imgui.v  
    save()
end

function loadAC()
    every_settings.admin_chat.X = config.achat.X  
    every_settings.admin_chat.Y = config.achat.Y
    every_settings.admin_chat.centered.v = config.achat.centered
    every_settings.admin_chat.nick.v = config.achat.nick
    every_settings.admin_chat.color = config.achat.color
    every_settings.admin_chat.render_lines.v = config.achat.lines
    every_settings.admin_chat.lines_imgui.v = config.achat.lines_imgui
end

local value, value_pos = 0, 0
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
        fontsize = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\SegoeUI.ttf', elements.int.imguiFont.v, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) 
    end
end

imgui.ToggleButton = require('imgui_addons').ToggleButton
imgui.Tooltip = require('imgui_addons').Tooltip

local changePosition_im = false

local sw, sh = getScreenResolution()
-- ## Блок переменных связанных с графическим интерфейсом ImGUI ## -- 

-- ## Внедрение рендерных параметров ## -- 
local font_ac = renderCreateFont("Arial",tonumber(elements.int.adminFont.v), flags_font.BOLD + flags_font.SHADOW)
-- ## Внедрение рендерных параметров ## -- 

-- ## Переменные, необходимые для правильной работы функций, работающих на основе ивента перехвата сообщений ## --
local lc_lvl, lc_adm, lc_color, lc_nick, lc_id, lc_text

local reasons = { 
	"/mute", "/jail", "/iban", "/ban", "/kick", "/skick", "/sban", "/muteakk", "/offban", "/banakk"
}
-- ## Переменные, необходимые для правильной работы функций, работающих на основе ивента перехвата сообщений ## --

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

    lc_lvl, lc_adm, lc_color, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] %((.+){(.+)}%) (.+)%[(%d+)%]: {FFFFFF}(.+)")

    local check_string = string.match(text, "[^%s]+")

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

    -- ## Работа с административными формами ## --
    if not isGamePaused() and not isPauseMenuActive() and isGameWindowForeground() then
        if elements.boolean.adminforms.v and lc_text ~= nil then  
            for k, v in ipairs(reasons) do  
                if lc_text:match(v) ~= nil then  
                    if lc_text:find(lc_nick) then
                        form = lc_text 
                    else   
                        form = lc_text .. " // " .. lc_nick
                    end  
                    showNotification("Пришла административная форма! \n Если у Вас включено автоматическое принятие форм, проигнорируйте уведомление\n /fac - принять | /fn - отклонить")
                    sampAddChatMessage(tag .. "Форма: " .. adm_form, -1)
                    if elements.boolean.auto_adminforms.v then
                        lua_thread.create(function()
                            sampSendChat("/a [AT] Форма принята.")
                            wait(5)
                            sampSendChat(adm_form)
                            adm_form = ''
                        end)
                    else
                        start_forms()
                    end  
                end  
            end
        end
    end

    function start_forms()
        sampRegisterChatCommand('fac', function()
            sampSendChat("/a [AT] Форма принята.")
            wait(5)
            sampSendChat(adm_form)
            adm_form = ''
        end)
        sampRegisterChatCommand('fn', function()
            sampSendChat('/a [AT] Форма отклонена.')
            adm_form = ''
        end)
    end
    -- ## Работа с административными формами ## --

    -- ## Работа с административным чатом. Работа с строками для рендера и интеграции AC (AdminChat) в ImGUI## -- 
    if (elements.boolean.adminchat.v or elements.boolean.imgui_adminchat.v) and check_string ~= nil and string.find(check_string, "%[A%-(%d+)%]") ~= nil and string.find(text, "%[A%-(%d+)%] (.+) отключился") == nil then


        if thread ~= nil and not thread.dead then 
            thread:terminate()  
        end
            
        if thread_pos ~= nil and not thread_pos.dead then  
            thread_pos:terminate()
            value_pos = every_settings.admin_chat.X
        end


        thread = ease(0, 1, nil, 1.0, "linear", function(v)
            value = v
        end)

        thread_pos = ease(-100, 0, nil, 1.0, "linear", function(v)
            value_pos = v
        end)

		local lc_text_chat
		if elements.boolean.adminchat.v then  
			if every_settings.admin_chat.nick.v == 1 then
				if lc_adm == nil then
					lc_lvl, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)")
					lc_text_chat = lc_lvl .. " • " .. lc_nick .. "[" .. lc_id .. "] : {FFFFFF}" .. lc_text
				else
					every_settings.admin_chat.color = color
					lc_text_chat = lc_adm .. "{" .. (bit.tohex(atlibs.join_argb(atlibs.explode_argb(color)))):sub(3, 8) .. "} • " .. lc_lvl .. " • " .. lc_nick .. "[" .. lc_id .. "] : {FFFFFF}" .. lc_text 
				end
			else
				if lc_adm == nil then
					lc_lvl, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)")
					lc_text_chat = "{FFFFFF}" .. lc_text .. " {" .. (bit.tohex(atlibs.join_argb(atlibs.explode_argb(color)))):sub(3, 8) .. "}: " .. lc_nick .. "[" .. lc_id .. "] • " .. lc_lvl
				else
					lc_text_chat = "{FFFFFF}" .. lc_text .. "{" .. (bit.tohex(atlibs.join_argb(atlibs.explode_argb(color)))):sub(3, 8) .. "} : " .. lc_nick .. "[" .. lc_id .. "] • " .. lc_lvl .. " • " .. lc_adm
					every_settings.admin_chat.color = color
				end
			end
		end
		if elements.boolean.imgui_adminchat.v then  
			if every_settings.admin_chat.nick.v == 1 then
				if lc_adm == nil then
					lc_lvl, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)")
					lc_text_chat = "[A-" .. lc_lvl .. "] " .. lc_nick .. "[" .. lc_id .. "] : {FFFFFF}" .. lc_text
				else
					every_settings.admin_chat.color = color
					lc_text_chat = lc_adm .. "{" .. (bit.tohex(atlibs.join_argb(atlibs.explode_argb(color)))):sub(3, 8) .. "} *  " .. lc_lvl .. " *  " .. lc_nick .. "[" .. lc_id .. "] : {FFFFFF}" .. lc_text 
				end
			else
				if lc_adm == nil then
					lc_lvl, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)")
					lc_text_chat = "{FFFFFF}" .. lc_text .. " {" .. (bit.tohex(atlibs.join_argb(atlibs.explode_argb(color)))):sub(3, 8) .. "}: " .. lc_nick .. "[" .. lc_id .. "] *  " .. lc_lvl
				else
					lc_text_chat = "{FFFFFF}" .. lc_text .. "{" .. (bit.tohex(atlibs.join_argb(atlibs.explode_argb(color)))):sub(3, 8) .. "} : " .. lc_nick .. "[" .. lc_id .. "] *  " .. lc_lvl .. " *  " .. lc_adm
					every_settings.admin_chat.color = color
				end
			end
		end	
		if elements.boolean.adminchat.v then 
			for i =  every_settings.admin_chat.render_lines.v, 1, -1 do
				if i ~= 1 then
					every_settings.no_saved_ac.chat_lines[i] = every_settings.no_saved_ac.chat_lines[i-1]
				else
					every_settings.no_saved_ac.chat_lines[i] = lc_text_chat
				end
			end
		end	
		if elements.boolean.imgui_adminchat.v then 
			for i = every_settings.admin_chat.lines_imgui.v, 1, -1 do
				if i ~= 1 then
					every_settings.no_saved_ac.chat_lines_imgui[i] = every_settings.no_saved_ac.chat_lines_imgui[i-1]
				else
					every_settings.no_saved_ac.chat_lines_imgui[i] = lc_text_chat
				end
			end 
		end		
		return false
	end		

end

function main()
    while not isSampAvailable() do wait(0) end
    
    admin_chat = lua_thread.create_suspended(drawAdminChat)
    lua_thread.create(time)

    sampfuncsLog(log .. " Инициализация дополнительного скрипта, выполняющего определенные вспомогательные функции, работающие вместе с АТ. \n Для правильной интеграции данного плагина проверьте его нахождение в сборке, в папке moonloader -> module ->  plugins -> plugin.lua")

    -- ## Запуск временных функций, запущенных для фрейма бесконечного цикла ## --
    admin_chat:run()
    -- ## Запуск временных функций, запущенных для фрейма бесконечного цикла ## --

    -- ## Выполнение загрузочных функций для конфигураций ## --
    loadAC()
    -- ## Выполнение загрузочных функций для конфигураций ## --

    -- ## Сброс значений статы при наступлении следующего дня ## --
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
    -- ## Сброс значений статы при наступлении следующего дня ## --

    while true do
        wait(0)

        imgui.Process = true

        if not elements.boolean.adminstate.v then  
            elements.boolean.adminstate.v = false  
            imgui.ShowCursor = false  
            imgui.Process = false  
        end

        if every_settings.no_saved_ac.pos then  
            CPosition_Render()
        end

        if not elements.boolean.imgui_adminchat.v then  
            imgui.Process = false 
            imgui.ShowCursor = false
        end

        CPosition_ImGUI()
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

function CPosition_Render()
    if isKeyJustPressed(VK_RBUTTON) then  
        every_settings.admin_chat.X = every_settings.no_saved_ac.X 
        every_settings.admin_chat.Y = every_settings.no_saved_ac.Y
        every_settings.no_saved_ac.pos = false 
    elseif isKeyJustPressed(VK_LBUTTON) then  
        every_settings.no_saved_ac.pos = false 
    else 
        every_settings.admin_chat.X, every_settings.admin_chat.Y = getCursorPos()
        saveAC()
    end
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

function CPosition_ImGUI()
    if changePosition_im then  
        showCursor(true, false)
        local mouseX, mouseY = getCursorPos()
        config.achat.X_imgui, config.achat.Y_imgui = mouseX, mouseY  
        if isKeyJustPressed(49) then  
            showCursor(false, false)
            showNotification("Положение окна AC сохранено!")
            changePosition_im = false  
            save() 
        end  
    end
end

function drawAdminChat()
    if elements.boolean.adminchat.v then
        while true do
			if every_settings.admin_chat.centered.v == 0 then
				for i = every_settings.admin_chat.render_lines.v, 1, -1 do
					if every_settings.no_saved_ac.chat_lines[i] == nil then
						every_settings.no_saved_ac.chat_lines[i] = " "
					end
                    if i == 1 then
                        renderFontDrawText(font_ac, every_settings.no_saved_ac.chat_lines[i], every_settings.admin_chat.X + value_pos, every_settings.admin_chat.Y+(elements.int.adminFont.v+4)*(every_settings.admin_chat.render_lines.v - i), atlibs.join_argb(math.modf(value*255), 255, 255, 255))
                    else 
                        renderFontDrawText(font_ac, every_settings.no_saved_ac.chat_lines[i], every_settings.admin_chat.X, every_settings.admin_chat.Y+(elements.int.adminFont.v+4)*(every_settings.admin_chat.render_lines.v - i), atlibs.join_argb(255, 255, 255, 255))
                    end
				end
			elseif admin_chat_lines.centered.v == 1 then
				for i = every_settings.admin_chat.render_lines.v, 1, -1 do
					if every_settings.no_saved_ac.chat_lines[i] == nil then
						every_settings.no_saved_ac.chat_lines[i] = " "
					end
                    if i == 1 then
					    renderFontDrawText(font_ac, every_settings.no_saved_ac.chat_lines[i], every_settings.admin_chat.X - renderGetFontDrawTextLength(font_ac, every_settings.no_saved_ac.chat_lines[i]) / 2 + value_pos, every_settings.admin_chat.Y+elements.int.adminFont.v*(every_settings.admin_chat.render_lines.v - i)+5, atlibs.join_argb(atlibs.explode_argb(every_settings.admin_chat.color)))
                    else 
                        renderFontDrawText(font_ac, every_settings.no_saved_ac.chat_lines[i], every_settings.admin_chat.X - renderGetFontDrawTextLength(font_ac, every_settings.no_saved_ac.chat_lines[i]) / 2, every_settings.admin_chat.Y+elements.int.adminFont.v*(every_settings.admin_chat.render_lines.v - i)+5, atlibs.join_argb(atlibs.explode_argb(every_settings.admin_chat.color)))
                    end
				end
			elseif admin_chat_lines.centered.v == 2 then
				for i = every_settings.admin_chat.render_lines.v, 1, -1 do
					if every_settings.no_saved_ac.chat_lines[i] == nil then
						every_settings.no_saved_ac.chat_lines[i] = " "
					end
                    if i == 1 then  
					    renderFontDrawText(font_ac, every_settings.no_saved_ac.chat_lines[i], every_settings.admin_chat.X - renderGetFontDrawTextLength(font_ac, every_settings.no_saved_ac.chat_lines[i]) + value_pos, every_settings.admin_chat.Y+elements.int.adminFont.v*(every_settings.admin_chat.render_lines.v - i), atlibs.join_argb(atlibs.explode_argb(every_settings.admin_chat.color)))
                    else 
                        renderFontDrawText(font_ac, every_settings.no_saved_ac.chat_lines[i], every_settings.admin_chat.X - renderGetFontDrawTextLength(font_ac, every_settings.no_saved_ac.chat_lines[i]), every_settings.admin_chat.Y+elements.int.adminFont.v*(every_settings.admin_chat.render_lines.v - i), atlibs.join_argb(atlibs.explode_argb(every_settings.admin_chat.color)))
                    end                        
				end
			end
            wait(1)
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

function imgui.OnDrawFrame()

    if elements.boolean.imgui_adminchat.v then  
        imgui.SetNextWindowPos(imgui.ImVec2(config.achat.X_imgui, config.achat.Y_imgui), imgui.Cond.FirsUseEver, imgui.ImVec2(0.5, 0.5))

        imgui.ShowCursor = false  

        imgui.Begin("##AdminChat", nil, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize)

            position_posY = imgui.GetCursorPosX()
            for i = every_settings.admin_chat.lines_imgui.v, 1, -1 do  
                if every_settings.no_saved_ac.chat_lines_imgui[i] ~= nil then  
                    imgui.PushFont(fontsize)
                        if i == 1 then 
                            imgui.SetCursorPosX(position_posY + value_pos)
                            atlibs.imgui_TextColoredRGB(every_settings.no_saved_ac.chat_lines_imgui[i])
                        else 
                            atlibs.imgui_TextColoredRGB(every_settings.no_saved_ac.chat_lines_imgui[i])
                        end
                    imgui.PopFont()
                end  
            end  
        imgui.End()
    end

end

function EXPORTS.ActiveATChat()
    if imgui.TreeNode(u8"Админ-чат в интерфейсе") then  
        imgui.Text(fai.ICON_FA_TOGGLE_ON .. u8" Включение вывода")
        imgui.SameLine()
        if imgui.ToggleButton('##AC_IMGUI', elements.boolean.imgui_adminchat) then  
            config.settings.imgui_adminchat = elements.boolean.imgui_adminchat.v  
            save()
        end
        if imgui.Button(u8"Изменение положения окна") then  
            sampAddChatMessage(tag .. "Для сохранения положения - нажмите на клавиатуре <1>")
            changePosition_im = true
        end 
        imgui.Text(u8"Кол-во строк: ")
        imgui.PushItemWidth(80)
        if imgui.InputInt('##changeLinesImGUI', every_settings.admin_chat.lines_imgui) then  
            config.achat.lines_imgui = every_settings.admin_chat.lines_imgui.v  
            save()  
        end  
        imgui.PopItemWidth()
        imgui.Text(u8"Размер шрифта: ")
        imgui.PushItemWidth(80)
        if imgui.SliderInt('##changeFontSize', elements.int.imguiFont, 1, 32) then  
            config.achat.iFont = elements.int.imguiFont.v  
            save() 
        end
        if imgui.Button(fai.ICON_FA_SAVE .. u8' Сохранить') then   
            showNotification('Настройки были успешно сохранены.')
            saveAC()
            save() 
        end
        imgui.PopItemWidth()
        imgui.TreePop()
    end
    if imgui.TreeNode(u8"Админ-чат в форме текста (рендер)") then  
        imgui.Text(fai.ICON_FA_TOGGLE_ON .. u8" Включение вывода")
        imgui.SameLine()
        if imgui.ToggleButton('##AC_IMGUI', elements.boolean.adminchat) then  
            config.settings.adminchat = elements.boolean.adminchat.v  
            save()
        end
        if imgui.Button(u8"Положение чата") then  
            every_settings.no_saved_ac.X = every_settings.admin_chat.X; every_settings.no_saved_ac.Y = every_settings.admin_chat.Y 
            every_settings.no_saved_ac.pos = true  
        end
        imgui.Text(u8'Выравнивание чата: ')
        imgui.PushItemWidth(120)
        imgui.Combo("##Position", every_settings.admin_chat.centered, {u8"Левый край", u8"Центр", u8"Правый край"})
        imgui.PopItemWidth()
        imgui.Text(u8"Размер шрифта: ")
        imgui.PushItemWidth(50)
        if imgui.SliderInt("##SizeACFont", elements.int.adminFont, 1, 32) then  
            font_ac = renderCreateFont("Arial",tonumber(elements.int.adminFont.v), flags_font.BOLD + flags_font.SHADOW)
            config.achat.Font = elements.int.adminFont.v  
            save()
        end
        imgui.PopItemWidth()
        imgui.Text(u8"Положение ника + уровня")
        imgui.PushItemWidth(120)
        imgui.Combo("##PositionRender", every_settings.admin_chat.nick, {u8"Справа", u8"Слева"})
        imgui.PopItemWidth()
        imgui.Text(u8"Кол-во строк: ")
        imgui.PushItemWidth(80)
        imgui.InputInt('##NumbersStrings', every_settings.admin_chat.render_lines)
        imgui.PopItemWidth()
        if imgui.Button(fai.ICON_FA_SAVE .. u8" Сохранить") then  
            showNotification('Настройки были успешно сохранены.')
            saveAC()
        end
        imgui.TreePop()
    end
end

function EXPORTS.ActiveForms()
    imgui.Text(fai.ICON_FA_UNDO .. u8" Админ.формы")
    imgui.SameLine()
    if imgui.ToggleButton('##AdminForms', elements.boolean.adminforms) then  
        config.settings.adminforms = elements.boolean.adminforms.v 
        save() 
    end; imgui.Tooltip(u8'Позволяет принимать формы на выдачу наказаний от администраторов.')
    imgui.SameLine()
    if imgui.Checkbox('##AutoForms', elements.boolean.auto_adminforms) then  
        elements.boolean.adminforms.v = elements.boolean.auto_adminforms.v 
        config.settings.adminforms = elements.boolean.auto_adminforms.v 
        config.settings.auto_adminforms = elements.boolean.auto_adminforms.v  
        save() 
    end; imgui.Tooltip(u8'Позволяет автоматически принимать формы от администраторов.\nПри включении данного параметра автоматически активируются административные формы с автопринятием.')
end

function EXPORTS.AdminStateMenu()
    imgui.Text(fa.ICON_ADDRESS_BOOK .. u8' Включение админ-статистики') 
    imgui.SameLine()
    if imgui.ToggleButton('##AdminStateVariable', elements.boolean.adminstate) then  
        config.settings.admin_state = elements.boolean.adminstate.v  
        save() 
    end
    imgui.SameLine(); imgui.SetCursorPosX(imgui.GetWindowWidth() - 250);
    if imgui.Button(fa.ICON_FA_COGS .. u8'Изменение позиции окна') then 
        varstate.changePosition = true 
        sampAddChatMessage(tag .. ' Чтобы подтвердить сохранение - нажмите <1>')
    end
    if imgui.Checkbox(u8'Прозрачное окно', elements.admin_state.show_transparency) then  
        config.admin_state.show_transparency = elements.admin_state.show_transparency.v  
        save() 
    end 
    imgui.Separator()
    imgui.Text(u8'Возле каждого из значений есть блок текста, в него можно внести текст формата {RRGGBB}')
end