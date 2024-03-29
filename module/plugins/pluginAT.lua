require 'lib.moonloader'
local inicfg = require 'inicfg' -- работа с ini
local sampev = require "lib.samp.events" -- подключение основных библиотек, связанные с потокам пакетов ивентов SA:MP, и их прямое соединение с LUA
local atlibs = require 'libsfor' -- библиотека для работы с АТ
local encoding = require 'encoding' -- работа с кодировками

-- ## Блок текстовых переменных ## --
local tag = "{00BFFF} [AT] {FFFFFF}" -- тэг AT
local log = "{00BFFF} [AdminTool-Log] {FFFFFF}" -- тэг лога АТ
local ntag = "{00BFFF} Notf - AdminTool" -- тэг уведомлений АТ
encoding.default = 'CP1251' -- смена кодировки на CP1251
u8 = encoding.UTF8 -- переименовка стандтартного режима кодировки UTF8 - u8
-- ## Блок текстовых переменных ## --

-- ## Блок переменных связанных с конфигами и элементами взаимодействия с параметрами конфига ## --
local directIni = "AdminTool\\cfgPlugin.ini"
local configPlugin = inicfg.load({
    settings = {
        adminchat = false,
        adminforms = false,
		autoforms = false,
    }
    achat = {
        X = 48,
        Y = 298, 
        centered = 0,
        color = -1,
        nick = 1,
        lines = 10,
        Font = 10, 
		lines_imgui = 10,
		X_size = 50,
		Y_size = 50,
		X_imgui = 50,
		Y_imgui = 298,
    },
}, directIni)
inicfg.save(configPlugin, directIni)

function save() 
    inicfg.save(configPlugin, directIni)
end
-- ## Блок переменных связанных с конфигами и элементами взаимодействия с параметрами конфига ## --

local elements = {
    boolean = {
        adminchat = imgui.ImBool(configPlugin.settings.adminchat),
		adminforms = imgui.ImBool(configPlugin.settings.adminforms),
		autoforms = imgui.ImBool(configPlugin.settings.autoforms),
    },
    int = {
        adminFont = imgui.ImInt(configPlugin.achat.Font),
		X_size = imgui.ImInt(configPlugin.achat.X_size),
		Y_size = imgui.ImInt(configPlugin.achat.Y_size),
		Font = imgui.ImInt(configPlugin.settings.Font),
    },
}

local admin_chat_lines = { 
	centered = imgui.ImInt(0),
	nick = imgui.ImInt(1),
	color = -1,
	lines = imgui.ImInt(10),
	X = 0,
	Y = 0,
	im_l = imgui.ImInt(10)
}

local line_ac = imgui.ImInt(16) 
local font_ac = renderCreateFont("Arial", tonumber(elements.int.adminFont.v), font_admin_chat.BOLD + font_admin_chat.SHADOW)

-- Блок отвечающий за административный чат ^

local cfg = inicfg.load({
    settings = {
        mute = { -- конфиг  мута
            automute_mat = false,
            automute_osk = false,
            automute_rod = false, 
            automute_upom = false, 
        },
        static = {
            admin_state = false, -- конфиг адм статы
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
        }
    },
}, directIni)
inicfg.save(cfg, directIni)

local changePosition = false -- позиция окна
local sessionOnline = imgui.ImInt(0) -- онлайн за сеанс
local sessionAfk = imgui.ImInt(0) -- афк за сеанс
local sessionFull = imgui.ImInt(0)-- я ебу?
local dayFull = imgui.ImInt(cfg.static.full)
local nowTime = os.date("%H:%M:%S", os.time())
local LsessionReport = 0
local LsessionMute = 0 
local LsessionBan = 0 
local LsessionKick = 0 
local LsessionJail = 0 

local ini = {
    mute = {
        automute_mat = imgui.ImBool(cfg.settings.automute_mat),
        automute_osk = imgui.ImBool(cfg.settings.automute_osk),
        automute_rod = imgui.ImBool(cfg.settings.automute_rod),
        automute_upom = imgui.ImBool(cfg.settings.automute_upom),
    },
    admin_station  = {
        admin_state = imgui.ImBool(cfg.settings.admin_state),
        color_nick_id = imgui.ImBuffer(tostring(cfg.settings.color_nick_id), 50),
        color_time = imgui.ImBuffer(tostring(cfg.settings.color_time), 50),
        color_online_day = imgui.ImBuffer(tostring(cfg.settings.color_online_day), 50),
        color_online_now = imgui.ImBuffer(tostring(cfg.settings.color_online_now), 50),
        color_afk_day = imgui.ImBuffer(tostring(cfg.settings.color_afk_day), 50),
        color_afk_now = imgui.ImBuffer(tostring(cfg.settings.color_afk_now), 50),
        color_ans_day = imgui.ImBuffer(tostring(cfg.settings.color_ans_day), 50),
        color_ans_day = imgui.ImBuffer(tostring(cfg.settings.color_ans_now), 50),
        color_mute_day = imgui.ImBuffer(tostring(cfg.settings.olor_mute_day), 50),
        color_mute_now = imgui.ImBuffer(tostring(cfg.settings.color_mute_now), 50),
        color_kick_day = imgui.ImBuffer(tostring(cfg.settings.color_kick_day), 50),
        color_kick_now = imgui.ImBuffer(tostring(cfg.settings.ccolor_kick_now), 50),
        color_jail_day = imgui.ImBuffer(tostring(cfg.settings.color_jail_day), 50),
        color_jail_now = imgui.ImBuffer(tostring(cfg.settings.color_jail_now), 50),
        color_ban_day = imgui.ImBuffer(tostring(cfg.settings.color_ban_day), 50),
        color_ban_now = imgui.ImBuffer(tostring(cfg.settings.color_ban_now), 50),

        show_mute_day = imgui.ImBool(cfg.settings.show_mute_day), 
        show_mute_now = imgui.ImBool(cfg.settings.show_mute_now),
        show_ban_day = imgui.ImBool(cfg.settings.show_ban_day), 
        show_ban_now = imgui.ImBool(cfg.settings.show_ban_now),
        show_jail_day = imgui.ImBool(cfg.settings.show_jail_day), 
        show_jail_now = imgui.ImBool(cfg.settings.show_jail_now),
        show_kick_day = imgui.ImBool(cfg.settings.show_kick_day), 
        show_kick_now = imgui.ImBool(cfg.settings.show_kick_now),
        show_nick_id = imgui.ImBool(cfg.settings.show_nick_id), 
        show_afk_day = imgui.ImBool(cfg.settings.show_afk_day), 
        show_afk_now = imgui.ImBool(cfg.settings.show_afk_now),
        show_online_day = imgui.ImBool(cfg.settings.show_online_day), 
        show_online_now = imgui.ImBool(cfg.settings.show_online_now),
        show_report_day = imgui.ImBool(cfg.settings.show_report_day), 
        show_report_now = imgui.ImBool(cfg.settings.show_report_now),
        show_time = imgui.ImBool(cfg.settings.show_time),
        show_transparency = imgui.ImBool(cfg.settings.show_transparency)
    },
}

if cfg.static.today ~= os.date("%a") then 
    cfg.static.today = os.date("%a")
    cfg.static.online = 0
    cfg.static.full = 0
    cfg.static.afk = 0
    cfg.static.dayReport = 0
    cfg.static.dayKick = 0 
    cfg.static.dayBan = 0  
    cfg.static.dayJail = 0 
    cfg.static.dayMute = 0 
      dayFull.v = 0
    save()
end

local onscene = { "блять", "сука", "хуй", "нахуй" } -- основная сцена мата
local control_onscene = false -- контролирование сцены мата
------ Введенные локальные переменные, отвечающие за автомут ----------

local onscene_2 = { "пидр", "лох", "гандон", "уебан" }
local ph_rod = { 
    "мать ебал", "mq", "мать в канаве", "твоя мать шлюха", "твой рот шатал", "mqq", "mmq", 'mmqq', "matb v kanave",
}
local neosk = { "я лох" }
local control_onscene_1 = false
local control_onscene_2 = false

local ph_upom = {
    "аризона", "russian roleplay", "evolve", "эвольв"
}

local automute_settings = {
    input_phrase = imgui.ImBuffer(500),
    input_mute = imgui.ImBool(false),
    input_osk = imgui.ImBool(false),
    input_upom = imgui.ImBool(false),
    input_rod = imgui.ImBool(false),
    show_file_mute = imgui.ImBool(false),
    show_file_osk = imgui.ImBool(false), 
    show_file_upom = imgui.ImBool(false), 
    show_file_rod = imgui.ImBool(false),
    stream = imgui.ImBuffer(50000)
}
 -- Блок административного  чата
function saveAdminChat()
	configPlugin.achat.X = admin_chat_lines.X
	configPlugin.achat.Y = admin_chat_lines.Y
	configPlugin.achat.centered = admin_chat_lines.centered.v
	configPlugin.achat.nick = admin_chat_lines.nick.v
	configPlugin.achat.color = admin_chat_lines.color
	configPlugin.achat.lines = admin_chat_lines.lines.v
	configPlugin.achat.lines_imgui = admin_chat_lines.im_l.v  
	save()
end

function loadAdminChat()
	admin_chat_lines.X = configPlugin.achat.X
	admin_chat_lines.Y = configPlugin.achat.Y
	admin_chat_lines.centered.v = configPlugin.achat.centered
	admin_chat_lines.nick.v = configPlugin.achat.nick
	admin_chat_lines.color = configPlugin.achat.color
	admin_chat_lines.lines.v = configPlugin.achat.lines
	admin_chat_lines.im_l.v = configPlugin.achat.lines_imgui
	elements.int.adminFont.v = configPlugin.achat.Font
end 

-- ## Регистрация пакетов и ивентов SAMP ## --
function sampev.onServerMessage(color, text)

    lc_lvl, lc_adm, lc_color, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] %((.+){(.+)}%) (.+)%[(%d+)%]: {FFFFFF}(.+)")

	local check_string = string.match(text, "[^%s]+")
	local check_string_2 = string.match(text, "[^%s]+")

    if (elements.boolean.adminchat.v or elements.boolean.im_ac.v) and check_string ~= nil and string.find(check_string, "%[A%-(%d+)%]") ~= nil and string.find(text, "%[A%-(%d+)%] (.+) отключился") == nil then
        local lc_text_chat
        if elements.boolean.adminchat.v then  
            if admin_chat_lines.nick.v == 1 then
                if lc_adm == nil then
                    lc_lvl, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)")
                    lc_text_chat = lc_lvl .. " • " .. lc_nick .. "[" .. lc_id .. "] : {FFFFFF}" .. lc_text
                else
                    admin_chat_lines.color = color
                    lc_text_chat = lc_adm .. "{" .. (bit.tohex(join_argb(explode_samp_rgba(color)))):sub(3, 8) .. "} • " .. lc_lvl .. " • " .. lc_nick .. "[" .. lc_id .. "] : {FFFFFF}" .. lc_text 
                end
            else
                if lc_adm == nil then
                    lc_lvl, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)")
                    lc_text_chat = "{FFFFFF}" .. lc_text .. " {" .. (bit.tohex(join_argb(explode_samp_rgba(color)))):sub(3, 8) .. "}: " .. lc_nick .. "[" .. lc_id .. "] • " .. lc_lvl
                else
                    lc_text_chat = "{FFFFFF}" .. lc_text .. "{" .. (bit.tohex(join_argb(explode_samp_rgba(color)))):sub(3, 8) .. "} : " .. lc_nick .. "[" .. lc_id .. "] • " .. lc_lvl .. " • " .. lc_adm
                    admin_chat_lines.color = color
                end
            end
        end
        if elements.boolean.im_ac.v then  
            if admin_chat_lines.nick.v == 1 then
                if lc_adm == nil then
                    lc_lvl, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)")
                    lc_text_chat = lc_lvl .. " *  " .. lc_nick .. "[" .. lc_id .. "] : {FFFFFF}" .. lc_text
                else
                    admin_chat_lines.color = color
                    lc_text_chat = lc_adm .. "{" .. (bit.tohex(join_argb(explode_samp_rgba(color)))):sub(3, 8) .. "} *  " .. lc_lvl .. " *  " .. lc_nick .. "[" .. lc_id .. "] : {FFFFFF}" .. lc_text 
                end
            else
                if lc_adm == nil then
                    lc_lvl, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)")
                    lc_text_chat = "{FFFFFF}" .. lc_text .. " {" .. (bit.tohex(join_argb(explode_samp_rgba(color)))):sub(3, 8) .. "}: " .. lc_nick .. "[" .. lc_id .. "] *  " .. lc_lvl
                else
                    lc_text_chat = "{FFFFFF}" .. lc_text .. "{" .. (bit.tohex(join_argb(explode_samp_rgba(color)))):sub(3, 8) .. "} : " .. lc_nick .. "[" .. lc_id .. "] *  " .. lc_lvl .. " *  " .. lc_adm
                    admin_chat_lines.color = color
                end
            end
        end	
        if elements.boolean.adminchat.v then 
            for i = admin_chat_lines.lines.v, 1, -1 do
                if i ~= 1 then
                    ac_no_saved.chat_lines[i] = ac_no_saved.chat_lines[i-1]
                else
                    ac_no_saved.chat_lines[i] = lc_text_chat
                end
            end
        end	
        if elements.boolean.im_ac.v then 
            for i = admin_chat_lines.im_l.v, 1, -1 do
                if i ~= 1 then
                    ac_no_saved.chat_imgui[i] = ac_no_saved.chat_imgui[i-1]
                else
                    ac_no_saved.chat_imgui[i] = lc_text_chat
                end
            end 
        end		
        return false
    end	

    if elements.boolean.adminforms.v and lc_text ~= nil then  
        for k, v in ipairs(reasons) do
            if lc_text:match(v) ~= nil then
                adm_form = lc_text .. " // " .. lc_nick
                showNotification(tag, "Пришла административная форма! \n /fac - принять | /fn - отклонить")
                sampAddChatMessage(tag .. "Форма: " .. adm_form, -1)
                if elements.boolean.autoforms.v and not isGamePaused() and not isPauseMenuActive() and isGameWindowForeground() then  
                    lua_thread.create(function()
                        sampSendChat("/a AT - Форма принята!")
                        wait(500)
                        sampSendChat("" .. adm_form)
                        adm_form = ""
                    end)
                elseif not isGamePaused() and not isPauseMenuActive() and isGameWindowForeground() then 
                    start_forms()
                end
            end 
        end 
    end
end

function main()
    while not isSampAvailable() do wait(0) end

    admin_chat = lua_thread.create_suspended(drawAdminChat)
    loadAdminChat()
	admin_chat:run()
	sampfuncsLog(tag .. " Подгрузка плагина дополнительных функций.")

    while true do
        wait(0)

		imgui.Process = true

        if ac_no_saved.pos then
			change_adm_chat()
		end

		if not elements.boolean.im_ac.v then  
			elements.boolean.im_ac.v = false 
			imgui.Process = false 
			imgui.ShowCursor = false  
		end	
		changePos()
    end
end   

function changePos()
	if changePosition then
        showCursor(true, false)
        local mouseX, mouseY = getCursorPos()
        configPlugin.achat.X_imgui, configPlugin.achat.Y_imgui = mouseX, mouseY
        if isKeyJustPressed(49) then
            showCursor(false, false)
            showNotification(tag, "Положение окна сохранено!")
            changePosition = false
            save()
        end
    end
end	

function change_adm_chat()
	if isKeyJustPressed(VK_RBUTTON) then
		admin_chat_lines.X = ac_no_saved.X
		admin_chat_lines.Y = ac_no_saved.Y
		ac_no_saved.pos = false
	elseif isKeyJustPressed(VK_LBUTTON) then
		ac_no_saved.pos = false
	else
		admin_chat_lines.X, admin_chat_lines.Y = getCursorPos()
	end
end

function drawAdminChat()
    while true do
		if elements.boolean.adminchat.v then
			if admin_chat_lines.centered.v == 0 then
				for i = admin_chat_lines.lines.v, 1, -1 do
					if ac_no_saved.chat_lines[i] == nil then
						ac_no_saved.chat_lines[i] = " "
					end
					renderFontDrawText(font_ac, ac_no_saved.chat_lines[i], admin_chat_lines.X, admin_chat_lines.Y+(elements.int.adminFont.v+4)*(admin_chat_lines.lines.v - i), join_argb(explode_samp_rgba(admin_chat_lines.color)))
				end
			elseif admin_chat_lines.centered.v == 1 then
				for i = admin_chat_lines.lines.v, 1, -1 do
					if ac_no_saved.chat_lines[i] == nil then
						ac_no_saved.chat_lines[i] = " "
					end
					renderFontDrawText(font_ac, ac_no_saved.chat_lines[i], admin_chat_lines.X - renderGetFontDrawTextLength(font_ac, ac_no_saved.chat_lines[i]) / 2, admin_chat_lines.Y+elements.int.adminFont.v*(admin_chat_lines.lines.v - i)+5, join_argb(explode_samp_rgba(admin_chat_lines.color)))
				end
			elseif admin_chat_lines.centered.v == 2 then
				for i = admin_chat_lines.lines.v, 1, -1 do
					if ac_no_saved.chat_lines[i] == nil then
						ac_no_saved.chat_lines[i] = " "
					end
					renderFontDrawText(font_ac, ac_no_saved.chat_lines[i], admin_chat_lines.X - renderGetFontDrawTextLength(font_ac, ac_no_saved.chat_lines[i]), admin_chat_lines.Y+elements.int.adminFont.v*(admin_chat_lines.lines.v - i), join_argb(explode_samp_rgba(admin_chat_lines.color)))
				end
			end
		end
        wait(1)
    end
end

function imgui.OnDrawFrame()
    
    if elements.boolean.im_ac.v then  

		imgui.SetNextWindowSize(imgui.ImVec2(elements.int.X_size.v, elements.int.Y_size.v), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(configPlugin.achat.X_imgui, configPlugin.achat.Y_imgui), imgui.Cond.FirsUseEver, imgui.ImVec2(0.5, 0.5))

		imgui.ShowCursor = false

        imgui.Begin(u8'AdminChat', nil, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize)
		
			for i = admin_chat_lines.im_l.v, 1, -1 do 
				if ac_no_saved.chat_imgui[i] ~= nil then	
					imgui.PushFont(fontsize)
						imgui.TextColoredRGB(u8(ac_no_saved.chat_imgui[i]))	
					imgui.PopFont()
				end	
			end
		imgui.End()
    end    
end

function EXPORTS.ActiveATChat()
    imgui.BeginChild('##AdminChat', imgui.ImVec2(230, 250), true)
	imgui.Text(u8"Данный блок отвечает за административный чат.")
	imgui.Separator()
	if imgui.RadioButton(u8"Imgui-чат ##1",rbutton,1) then  
		changeint = 1  
	end 
	imgui.SameLine() 
	if imgui.RadioButton(u8" Рендер-чат ##2", rbutton,2) then  
		changeint = 2 
	end	 
	imgui.Separator()
	if changeint == 1 then  
		imgui.Text(fa.ICON_TELEGRAM .. u8" Админ-чат") 
		imgui.SameLine()
		if imgui.ToggleButton('##AdminChat_Imgui', elements.boolean.im_ac) then 
			configPlugin.settings.lcadm_imgui = elements.boolean.im_ac.v
			save()
		end	
		imgui.SameLine()
		imgui.TextQuestion('(?)', u8"Выводит отдельно от основного чата - административный, при помощи интерфейса imgui\nДля обновление настроек, необходимо перезагрузить скрипт (ALT+R)!")
		if imgui.Button(u8"Изменение положения окна") then  
			sampAddChatMessage(tag .. ' Чтобы сохранить положение - нажмите 1')
			changePosition = true
		end	
		imgui.Text(u8"Изменение ширины окна: ")
		imgui.PushItemWidth(80)
		if imgui.InputInt('##changenumberX_imgui', elements.int.X_size) then  
			configPlugin.achat.X_size = elements.int.X_size.v 
			save()
		end	
		imgui.PopItemWidth()
		imgui.Text(u8"Изменение длины окна: ")
		imgui.PushItemWidth(80)
		if imgui.InputInt('##changenumberY_imgui', elements.int.Y_size) then  
			configPlugin.achat.Y_size = elements.int.Y_size.v 
			save()
		end	
		imgui.PopItemWidth()
		imgui.Text(u8'Количество строк: ')
		imgui.PushItemWidth(80)
		imgui.InputInt('##changenumberlinesimgui', admin_chat_lines.im_l)
		imgui.PopItemWidth()
		imgui.Text(u8'Размер шрифта: ')
		imgui.PushItemWidth(80)
		if imgui.SliderInt('##changenumberfontsize', elements.int.Font, 1, 64) then  
			configPlugin.settings.Font = elements.int.Font.v  
			save() 
		end	
		imgui.PopItemWidth()
		if imgui.Button(u8'Сохранить') then
			showNotification("Save Admin-Chat", "Настройки сохранены \nImgui-AdminChat")
			saveAdminChat()
			save()
		end
	end	

	if changeint == 2 then  
		imgui.Text(fa.ICON_TELEGRAM .. u8" Админ-чат")
		imgui.SameLine()
		if imgui.ToggleButton('##AdminChat_Render', elements.boolean.adminchat) then 
			configPlugin.settings.adminchat = elements.boolean.adminchat.v
			save()
		end	
		imgui.SameLine()
		imgui.TextQuestion('(?)', u8"Выводит отдельно от основного чата - административный, при помощи рендера текста")
		imgui.Separator()
		if imgui.Button(u8'Положение чата') then
			ac_no_saved.X = admin_chat_lines.X; ac_no_saved.Y = admin_chat_lines.Y
			ac_no_saved.pos = true
		end
		imgui.Text(u8'Выравнивание чата: ')
		imgui.Combo("##Position", admin_chat_lines.centered,  {u8"По левый край.", u8"По центру.", u8"По правый край."})
		imgui.PushItemWidth(50)
		imgui.Text(u8'Размер шрифта:')
		if imgui.SliderInt("##sizeAcFont", elements.int.adminFont, 1, 20) then
			font_ac = renderCreateFont("Arial", tonumber(elements.int.adminFont.v), font_admin_chat.BOLD + font_admin_chat.SHADOW)
			configPlugin.achat.Font = elements.int.adminFont.v
			save()
		end	
		imgui.PopItemWidth()
		imgui.Text(u8'Положение ника и уровня: ')
		imgui.Combo("##Pos", admin_chat_lines.nick, {u8"Справа.", u8"Слева."})
		imgui.Text(u8'Количество строк: ')
		imgui.PushItemWidth(80)
		imgui.InputInt(' ', admin_chat_lines.lines)
		imgui.PopItemWidth()
		if imgui.Button(u8'Сохранить!') then
			showNotification("Save Admin-Chat", "Настройка админ-чата сохранены\nRender-AdminChat")
			saveAdminChat()
		end
	end	
    imgui.EndChild()
end    

-- Блок административного  чата ^

-- Блок  отвечающий за административные реформы

function start_forms()
    sampRegisterChatCommand('fac', function()
        lua_thread.create(function()
            sampSendChat("/a AT - Форма принята!")
            wait(500)
            sampSendChat("".. adm_form)
            adm_form = ""
        end)
    end)
    sampRegisterChatCommand("fn", function()
        sampSendChat("/a AT - Форма отклонена!")
        adm_form = ""        
    end)
end


-- ## Экспорт функции для активации административных форм ## --
function EXPORTS.OnAdminForms()
    
	imgui.Text(fai.ICON_FA_COMMENTS .. u8" Административнвые формы")
	imgui.SameLine()
	imgui.SetCursorPosX(imgui.GetWindowWidth() - 100)
	if imgui.ToggleButton("##AdminForms", elements.boolean.adminforms) then  
		configPlugin.settings.adminforms = elements.boolean.adminforms.v  
		save()
	end	
	imgui.SameLine()
	if imgui.Checkbox('##AutoForms', elements.boolean.autoforms) then  
		configPlugin.settings.autoforms = elements.boolean.autoforms.v  
		save()   
	end
end
-- ## Экспорт функции для активации административных форм ## --

-- ## Чтение файлов автомута ## --
function check_file_mute()
    local file_check = assert(io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\mat.txt", "r"))
    local t = file_check:read("*all")
    file_check:close() 
        return t
end

function check_file_osk()
    local file_check1 = assert(io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\osk.txt", "r"))
    local t1 = file_check1:read("*all")
    file_check1:close() 
        return t1
end

function check_file_upom()
    local file_check = assert(io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\upom.txt", "r"))
    local t = file_check:read("*all")
    file_check:close() 
        return t
end

function check_file_rod()
    local file_check = assert(io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\rod.txt", "r"))
    local t = file_check:read("*all")
    file_check:close() 
        return t
end

-- ## Чтение файлов автомута ## --

function checkMessage(msg, arg)
    if arg == 1 then 
        if msg ~= nil then  
            for i, ph in ipairs(ph_rod) do  
                if string.find(msg, ph, 1, true) then  
                    return true, ph 
                end  
            end  
        end
    elseif arg == 2 then  
        if msg ~= nil then  
            for i, ph in ipairs(ph_upom) do  
                if string.find(msg, ph, 1, true) then  
                    return true, ph 
                end 
            end 
        end
    elseif arg == 3 then  
        if msg ~= nil then  
            for i, ph in ipairs(onscene_2) do  
                nmsg = string.split(msg, " ")
                for j, word in ipairs(nmsg) do  
                    if ph == string.rlower(word) then
                        return true, ph  
                    end  
                end
            end  
        end  
    elseif arg == 4 then  
        if msg ~= nil then  
            for i, ph in ipairs(onscene) do  
                nmsg = string.split(msg, " ")
                for j, word in ipairs(nmsg) do  
                    if ph == string.rlower(word) then
                        return true, ph  
                    end  
                end
            end  
        end
    end
end

function save() 
    inicfg.save(cfg, directIni)
end

function EXPORTS.ActiveAutoMute()
    imgui.Text(fa.ICON_NEWSPAPER_O .. u8" Автомут")
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 400)
    if imgui.Button(u8"On/Off") then  
        imgui.OpenPopup('settingautomute')
    end    
    if imgui.BeginPopup('settingautomute') then  
        if imgui.ToggleButton(u8" Автомут за мат ", ini.automute_mat) then 
            cfg.settings.automute_mat = ini.automute_mat.v 
            save() 
        end	
        if imgui.ToggleButton(u8" Автомут за оск ", ini.automute_osk) then 
            cfg.settings.automute_osk = ini.automute_osk.v 
            save() 
        end	
        if imgui.ToggleButton(u8' Автомут за оск родных', ini.automute_rod) then  
            cfg.settings.automute_rod = ini.automute_rod.v  
            save()
        end
        if imgui.ToggleButton(u8' Автомут за упом.стор.проектов', ini.automute_upom) then  
            cfg.settings.automute_upom = ini.automute_upom.v  
            save()
        end
        imgui.EndPopup()
    end    
end

function EXPORTS.up_automute()
    imgui.Text(u8"Здесь можно отредактировать файлы автомута без взаимодействия с командой.")
    imgui.Text(u8"Метод позволяет добавить слова в ОДИН файл. \nУ него нет возможности добавления в несколько файлов одновременно")
    imgui.Checkbox(u8'Добавить/Удалить слово в списке мата', automute_settings.input_mute)
    imgui.SameLine() 
    if imgui.Button(u8"Просмотр файла ##1") then  
        automute_settings.show_file_mute.v = true  
    end
    imgui.Checkbox(u8'Добавить/Удалить фразу в списке оскорблений родных', automute_settings.input_rod)
    imgui.SameLine() 
    if imgui.Button(u8"Просмотр файла ##2") then  
        automute_settings.show_file_rod.v = true  
    end
    imgui.Checkbox(u8'Добавить/Удалить слово в списке оскорблений/унижений', automute_settings.input_osk)
    imgui.SameLine() 
    if imgui.Button(u8"Просмотр файла ##3") then  
        automute_settings.show_file_osk.v = true  
    end
    imgui.Checkbox(u8"Добавить/Удалить фразу в списке упоминаний проектов", automute_settings.input_upom)
    imgui.SameLine() 
    if imgui.Button(u8"Просмотр файла ##4") then  
        automute_settings.show_file_upom.v = true  
    end
    imgui.Separator()
    imgui.Text(u8"Сюда можно ввести слово: \n(с случае с упоминанием проектов или оскорбление родных - можно и фразы)")
    imgui.InputText('##Phrase', automute_settings.input_phrase) 
    imgui.SameLine()
    if imgui.Button(fa.ICON_REFRESH) then  
        automute_settings.input_phrase.v = ""
    end
    if imgui.Button(u8"Сохранить") then  
        if #automute_settings.input_phrase.v > 0 then  
            if automute_settings.input_mute.v then  
                for _, val in ipairs(onscene) do 
                    if string.rlower(u8:decode(automute_settings.input_phrase.v)) == val then  
                        showNotification("AutoMute", "Ошибка. Данное слово: \n\"" .. val .. "\" \nуже есть в списке.")
                        return false
                    end 
                end 
                local file_write, c_line = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\mat.txt", "w"), 1
                onscene[#onscene + 1] = string.rlower(u8:decode(automute_settings.input_phrase.v))
                for _, val in ipairs(onscene) do
                    file_write:write(val .. "\n")
                end
                file_write:close()
                showNotification("AutoMute", " Слово: \n\"" .. string.rlower(u8:decode(automute_settings.input_phrase.v)) .. "\" успешно добавлено в список.")
            elseif automute_settings.input_osk.v then  
                for _, val in ipairs(onscene_2) do
                    if string.rlower(u8:decode(automute_settings.input_phrase.v)) == val then
                        showNotification("AutoMute", "Ошибка. Данное слово: \n\"" .. val .. "\" \nуже есть в списке.")
                        return false
                    end
                end
                local file_write_1, c_line_1 = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\osk.txt", "w"), 1
                onscene_2[#onscene_2 + 1] = string.rlower(u8:decode(automute_settings.input_phrase.v))
                for _, val in ipairs(onscene_2) do
                    file_write_1:write(val .. "\n")
                end
                file_write_1:close()
                showNotification("AutoMute", " Слово: \n\"" .. string.rlower(u8:decode(automute_settings.input_phrase.v)) .. "\" успешно добавлено в список.")
            elseif automute_settings.input_upom.v then  
                for _, val in ipairs(ph_upom) do 
                    if string.rlower(u8:decode(automute_settings.input_phrase.v)) == val then  
                        showNotification("AutoMute", "Ошибка. Данное слово: \n\"" .. val .. "\" \nуже есть в списке.")
                        return false 
                    end 
                end 
                local file_read_upom, c_line_upom = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\upom.txt", "w"), 1
                ph_upom[#ph_upom + 1] = string.rlower(u8:decode(automute_settings.input_phrase.v))
                for _, val in ipairs(ph_upom) do 
                    file_read_upom:write(val .. "\n")
                end 
                file_read_upom:close() 
                showNotification("AutoMute", " Слово: \n\"" .. string.rlower(u8:decode(automute_settings.input_phrase.v)) .. "\" успешно добавлено в список.")
            elseif automute_settings.input_rod.v then  
                for _, val in ipairs(ph_rod) do 
                    if string.rlower(u8:decode(automute_settings.input_phrase.v)) == val then  
                        showNotification("AutoMute", "Ошибка. Данное слово: \n\"" .. val .. "\" \nуже есть в списке.")
                        return false 
                    end 
                end 
                local file_write_rod, c_line_rod = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\rod.txt", "w"), 1
                ph_rod[#ph_rod + 1] = string.rlower(u8:decode(automute_settings.input_phrase.v))
                for _, val in ipairs(ph_rod) do 
                    file_write_rod:write(val .. "\n")
                end 
                file_write_rod:close() 
                showNotification("AutoMute", " Слово: \n\"" .. string.rlower(u8:decode(automute_settings.input_phrase.v)) .. "\" успешно добавлено в список.")
            end
        end
    end
    imgui.SameLine()
    if imgui.Button(u8"Удалить") then  
        if #automute_settings.input_phrase.v > 0 then  
            if automute_settings.input_mute.v then  
                local file_write, c_line = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\mat.txt", "w"), 1
                for i, val in ipairs(onscene) do 
                    if val == string.rlower(u8:decode(automute_settings.input_phrase.v)) then  
                        onscene[i] = nil  
                        control_onscene = true 
                    else 
                        file_write:write(val .. "\n")
                    end 
                end 
                file_write:close()
                if control_onscene then  
                    showNotification("AutoMute", " Слово: \n\"" .. string.rlower(u8:decode(automute_settings.input_phrase.v)) .. "\" успешно удалено из списка")
                    control_onscene = false  
                else
                    showNotification("AutoMute", " Слово: \n\"" .. string.rlower(u8:decode(automute_settings.input_phrase.v)) .. "\" не существует в списке.")
                end
            elseif automute_settings.input_osk.v then  
                local file_write, c_line = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\osk.txt", "w"), 1
                for i, val in ipairs(onscene_2) do 
                    if val == string.rlower(u8:decode(automute_settings.input_phrase.v)) then  
                        onscene_2[i] = nil  
                        control_onscene = true 
                    else 
                        file_write:write(val .. "\n")
                    end 
                end 
                file_write:close()
                if control_onscene then  
                    showNotification("AutoMute", " Слово: \n\"" .. string.rlower(u8:decode(automute_settings.input_phrase.v)) .. "\" успешно удалено из списка")
                    control_onscene = false  
                else
                    showNotification("AutoMute", " Слово: \n\"" .. string.rlower(u8:decode(automute_settings.input_phrase.v)) .. "\" не существует в списке.")
                end
            elseif automute_settings.input_upom.v then  
                local file_write, c_line = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\upom.txt", "w"), 1
                for i, val in ipairs(ph_upom) do 
                    if val == string.rlower(u8:decode(automute_settings.input_phrase.v)) then  
                        ph_upom[i] = nil  
                        control_onscene = true 
                    else 
                        file_write:write(val .. "\n")
                    end 
                end 
                file_write:close()
                if control_onscene then  
                    showNotification("AutoMute", " Слово: \n\"" .. string.rlower(u8:decode(automute_settings.input_phrase.v)) .. "\" успешно удалено из списка")
                    control_onscene = false  
                end
                showNotification("AutoMute", " Слово: \n\"" .. string.rlower(u8:decode(automute_settings.input_phrase.v)) .. "\" не существует в списке.")
            elseif automute_settings.input_rod.v then  
                local file_write, c_line = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\rod.txt", "w"), 1
                for i, val in ipairs(ph_rod) do 
                    if val == string.rlower(u8:decode(automute_settings.input_phrase.v)) then  
                        ph_rod[i] = nil  
                        control_onscene = true 
                    else 
                        file_write:write(val .. "\n")
                    end 
                end 
                file_write:close()
                if control_onscene then  
                    showNotification("AutoMute", " Слово: \n\"" .. string.rlower(u8:decode(automute_settings.input_phrase.v)) .. "\" успешно удалено из списка")
                    control_onscene = false  
                else
                    showNotification("AutoMute", " Слово: \n\"" .. string.rlower(u8:decode(automute_settings.input_phrase.v)) .. "\" не существует в списке.")
                end
            end
        end
    end
    imgui.SameLine()
    if imgui.Button(u8"Закрыть просмотр") then  
        if automute_settings.show_file_mute.v then  
            automute_settings.show_file_mute.v = false 
        elseif automute_settings.show_file_osk.v then  
            automute_settings.show_file_osk.v = false  
        elseif automute_settings.show_file_rod.v then  
            automute_settings.show_file_rod.v = false  
        elseif automute_settings.show_file_upom.v then  
            automute_settings.show_file_upom.v = false  
        else 
            showNotification("AdminTool", "Ни один из существующих файлов\nне просматривается :(")
        end
    end
    imgui.Separator()
    if automute_settings.show_file_mute.v then 
        automute_settings.stream.v = check_file_mute()
        for line in automute_settings.stream.v:gmatch("[^\r\n]+") do
            imgui.Text(u8(line))
        end
    elseif automute_settings.show_file_osk.v then  
        automute_settings.stream.v = check_file_osk()
        for line in automute_settings.stream.v:gmatch("[^\r\n]+") do
            imgui.Text(u8(line))
        end
    elseif automute_settings.show_file_rod.v then  
        automute_settings.stream.v = check_file_rod()
        for line in automute_settings.stream.v:gmatch("[^\r\n]+") do
            imgui.Text(u8(line))
        end
    elseif automute_settings.show_file_upom.v then   
        automute_settings.stream.v = check_file_upom()
        for line in automute_settings.stream.v:gmatch("[^\r\n]+") do
            imgui.Text(u8(line))
        end
    else
        imgui.Text(u8"Ни один файл не просматривается. :(")
    end
end

function sampev.onServerMessage(color, text)
 
    while true do
        wait(0)

        imgui.Process = true

        if not ini.admin_state.v then 
            ini.admin_state.v = false
            imgui.ShowCursor = false  
            imgui.Process = false
        end    
        isPos()
    end
end

function isPos() 
	if changePosition then
        showCursor(true, false)
        local mouseX, mouseY = getCursorPos()
        cfg.settings.posX, cfg.settings.posY = mouseX, mouseY
        if isKeyJustPressed(49) then
            showCursor(false, false)
            showNotification(tag, "Успешно сохранено")
            changePosition = false
            save()
        end
    end
end

function time()
	startTime = os.time()
    while true do
        wait(1000)
        nowTime = os.date("%H:%M:%S", os.time()) 
        if sampGetGamestate() == 3 then 								
	        			
	        sessionOnline.v = sessionOnline.v + 1 							
	        sessionFull.v = os.time() - startTime 					
	        sessionAfk.v = sessionFull.v - sessionOnline.v		
			
			cfg.static.online = cfg.static.online + 1 				
	        cfg.static.full = dayFull.v + sessionFull.v 						
			cfg.static.afk = cfg.static.full - cfg.static.online

	    else
	    	startTime = startTime + 1
	    end
    end
end

function EXPORTS.AdminState()
    imgui.Text(fa.ICON_ADDRESS_BOOK .. u8" Админ-стата") 
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 300)
    if imgui.ToggleButton('##AdminState', ini.admin_state) then 
        cfg.settings.admin_state = ini.admin_state.v
        save()
    end
end 

function EXPORTS.AdminStateCheckbox()
    imgui.Text(u8" Возле каждого значения есть блок текста, в него можно ввести текст формата {RRGGBB}")
    if imgui.Checkbox(u8'Прозрачное окно статистики', ini.show_transparency) then  
        cfg.settings.show_transparency = ini.show_transparency.v  
        save() 
    end
    if imgui.Button(fa.ICON_FA_COGS .. u8" Изменение положения") then  
        changePosition = true
        sampAddChatMessage(tag .. ' Чтобы подтвердить сохранение - нажмите 1')
    end    
    if imgui.Checkbox(u8'Показ никнейма и ID', ini.show_nick_id) then  
        cfg.settings.show_nick_id = ini.show_nick_id.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_nick_id", ini.color_nick_id) then  
        cfg.settings.color_nick_id = ini.color_nick_id.v  
        save() 
    end
    imgui.PopItemWidth()
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'Показ времени', ini.show_time) then  
        cfg.settings.show_time = ini.show_time.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_time", ini.color_time) then  
        cfg.settings.color_time = ini.color_time.v  
        save() 
    end
    imgui.PopItemWidth()
    if imgui.Checkbox(u8'Показ онлайна за день', ini.show_online_day) then  
        cfg.settings.show_online_day = ini.show_online_day.v  
        save() 
    end
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_online_day", ini.color_online_day) then  
        cfg.settings.color_online_day = ini.color_online_day.v  
        save() 
    end    
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'Показ онлайна за сеанс', ini.show_online_now) then  
        cfg.settings.show_online_now = ini.show_online_now.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_online_now", ini.color_online_now) then  
        cfg.settings.color_online_now = ini.color_online_now.v  
        save() 
    end    
    if imgui.Checkbox(u8'Показ AFK за день', ini.show_afk_day) then  
        cfg.settings.show_afk_day = ini.show_afk_day.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_afk_day", ini.color_afk_day) then  
        cfg.settings.color_afk_day = ini.color_afk_day.v  
        save() 
    end    
    imgui.PopItemWidth()
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'Показ AFK за сеанс', ini.show_afk_now) then  
        cfg.settings.show_afk_now = ini.show_afk_now.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_afk_now", ini.color_afk_now) then  
        cfg.settings.color_afk_now = ini.color_afk_now.v  
        save() 
    end    
    imgui.PopItemWidth()
    if imgui.Checkbox(u8'Показ репортов за день', ini.show_report_day) then  
        cfg.settings.show_report_day = ini.show_report_day.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_ans_day", ini.color_ans_day) then  
        cfg.settings.color_ans_day = ini.color_ans_day.v  
        save() 
    end    
    imgui.PopItemWidth()
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'Показ репортов за сеанс', ini.show_report_now) then  
        cfg.settings.show_report_now = ini.show_report_now.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_ans_day", ini.color_ans_day) then  
        cfg.settings.color_ans_day = ini.color_ans_day.v  
        save() 
    end    
    imgui.PopItemWidth()
    if imgui.Checkbox(u8'Показ мутов за день', ini.show_mute_day) then  
        cfg.settings.show_mute_day = ini.show_mute_day.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_mute_day", ini.color_mute_day) then  
        cfg.settings.color_mute_day = ini.color_mute_day.v  
        save() 
    end    
    imgui.PopItemWidth()
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'Показ мутов за сеанс', ini.show_mute_now) then  
        cfg.settings.show_mute_now = ini.show_mute_now.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_mute_now", ini.color_mute_now) then  
        cfg.settings.color_mute_now = ini.color_mute_now.v  
        save() 
    end    
    imgui.PopItemWidth()
    if imgui.Checkbox(u8'Показ киков за день', ini.show_kick_day) then  
        cfg.settings.show_kick_day = ini.show_kick_day.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_kick_day", ini.color_kick_day) then  
        cfg.settings.color_kick_day = ini.color_kick_day.v  
        save() 
    end    
    imgui.PopItemWidth()
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'Показ киков за сеанс', ini.show_kick_now) then  
        cfg.settings.show_kick_now = ini.show_kick_now.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_kick_now", ini.color_kick_now) then  
        cfg.settings.color_kick_now = ini.color_kick_now.v  
        save() 
    end    
    imgui.PopItemWidth()
    if imgui.Checkbox(u8'Показ джайлов за день', ini.show_jail_day) then  
        cfg.settings.show_jail_day = ini.show_jail_day.v  
        save() 
    end   
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_jail_day", ini.color_jail_day) then  
        cfg.settings.color_jail_day = ini.color_jail_day.v  
        save() 
    end    
    imgui.PopItemWidth()
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'Показ джайлов за сеанс', ini.show_jail_now) then  
        cfg.settings.show_jail_now = ini.show_jail_now.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_jail_now", ini.color_jail_now) then  
        cfg.settings.color_jail_now = ini.color_jail_now.v  
        save() 
    end    
    imgui.PopItemWidth()
    if imgui.Checkbox(u8'Показ банов за день', ini.show_ban_day) then  
        cfg.settings.show_ban_day = ini.show_ban_day.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_ban_day", ini.color_ban_day) then  
        cfg.settings.color_ban_day = ini.color_ban_day.v  
        save() 
    end    
    imgui.PopItemWidth()
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'Показ банов за сеанс', ini.show_ban_now) then  
        cfg.settings.show_ban_now = ini.show_ban_now.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color_ban_now", ini.color_ban_now) then  
        cfg.settings.color_ban_now = ini.color_ban_now.v  
        save() 
    end    
    imgui.PopItemWidth()
end 

function imgui.OnDrawFrame()

    if ini.admin_state.v then 
        
        imgui.ShowCursor = false

        if cfg.settings.posX == 0 and cfg.settings.posY == 0 then  
            imgui.SetNextWindowPos(imgui.ImVec2(1786, 736), imgui.Cond.FirsUseEver, imgui.ImVec2(0.5, 0.5))
        else
            imgui.SetNextWindowPos(imgui.ImVec2(cfg.settings.posX, cfg.settings.posY), imgui.Cond.FirsUseEver, imgui.ImVec2(0.5, 0.5)) 
        end

        if ini.show_transparency.v then  
            imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(1.00, 1.00, 1.00, 0.05))
        end

        imgui.Begin(u8'Статистика', nil, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar)

        if ini.show_nick_id.v then imgui.TextColoredRGB(ini.color1.v .. getMyNick() .. " || ID: " ..  getMyId()) end
        if ini.show_online_day.v then imgui.TextColoredRGB(ini.color3.v .. u8"Онлайн за день: " .. get_clock(cfg.static.online)) end 
        if ini.show_online_now.v then imgui.TextColoredRGB(ini.color4.v .. u8"Онлайн за сеанс: " .. get_clock(sessionOnline.v)) end
        if ini.show_afk_day.v then imgui.TextColoredRGB(ini.color5.v .. u8"AFK за день: " .. get_clock(cfg.static.afk)) end
        if ini.show_afk_now.v then imgui.TextColoredRGB(ini.color6.v .. u8"AFK за сеанс: " .. get_clock(sessionAfk.v)) end
        if ini.show_report_day.v then imgui.TextColoredRGB(ini.color7.v .. u8"Репортов за день: " .. cfg.static.dayReport) end
        if ini.show_report_now.v then imgui.TextColoredRGB(ini.color8.v .. u8"Репортов за сеанс: " .. LsessionReport) end
        if ini.show_ban_day.v then imgui.TextColoredRGB(ini.color15.v .. u8"Баны за день: " .. cfg.static.dayBan) end
        if ini.show_ban_now.v then imgui.TextColoredRGB(ini.color16.v .. u8"Баны за сеанс: " .. LsessionBan) end
        if ini.show_mute_day.v then imgui.TextColoredRGB(ini.color9.v .. u8"Муты за день: " .. cfg.static.dayMute) end
        if ini.show_mute_now.v then imgui.TextColoredRGB(ini.color10.v .. u8"Муты за сеанс: " .. LsessionMute) end
        if ini.show_jail_day.v then imgui.TextColoredRGB(ini.color13.v .. u8"Джаилы за день: " .. cfg.static.dayJail) end
        if ini.show_jail_now.v then imgui.TextColoredRGB(ini.color14.v .. u8"Джаилы за сеанс: " .. LsessionJail) end
        if ini.show_kick_day.v then imgui.TextColoredRGB(ini.color11.v .. u8"Кики за день: " .. cfg.static.dayKick) end
        if ini.show_kick_now.v then imgui.TextColoredRGB(ini.color12.v .. u8"Кики за сеанс: " .. LsessionKick) end
        if ini.show_time.v then imgui.TextColoredRGB(ini.color2.v .. u8(os.date("%d.%m.%y | %H:%M:%S", os.time()))) end
        imgui.End()
        if ini.show_transparency.v then  
            imgui.PopStyleColor()
        end
    end    
end 

