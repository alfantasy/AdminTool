script_name('AdminTool') -- название скрипта
-- Помощники, авторы, соавторы скрипта: alfantasy, Unite, Liquit, Natsuki, Shtormo., Yuri_Dan__, Yamada, Soulful., Lebedev
script_description('Скрипт для облегчения работы администраторам') -- описание скрипта

------- Подключение всех нужных библиотек ----------
require "lib.moonloader" -- подключение основной библиотеки mooloader
local ffi = require "ffi" -- cпец структура
local dlstatus = require('moonloader').download_status
local font_admin_chat = require ("moonloader").font_flag -- шрифт для админ-чата
local vkeys = require "vkeys" -- регистр для кнопок
local imgui = require 'imgui' -- регистр imgui окон
local encoding = require 'encoding' -- дешифровка форматов
local inicfg = require 'inicfg' -- работа с ini
local sampev = require "lib.samp.events" -- подключение основных библиотек, связанные с потокам пакетов ивентов SA:MP, и их прямое соединение с LUA
local mem = require "memory" -- библиотека, отвечающие за чтение памяти, и её факторы
encoding.default = 'CP1251' -- смена кодировки на CP1251
u8 = encoding.UTF8 -- переименовка стандтартного режима кодировки UTF8 - u8
------- Подключение всех нужных библиотек -----------


local directIni = "AdminTool\\settings.ini" -- создание специального файла, отвечающего за настройки.

local themes = import "config/AdminTool/imgui_themes.lua" -- подключение плагина тем
local notify = import "module/lib_imgui_notf.lua" -- подключение плагина уведомлений
local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280) -- захват позиции костей
local control_wallhack = false -- контролируемая переменная для wallhack
local chat_logger_text = { } -- текст логгера
local accept_load_clog = false -- принятие переменной логгера

-------- Введение локальные переменные, отвечающие за автообновление ----------

update_state = false -- перехват нужности обновление

local script_version = 15 -- основная версия, перехватываемая сайтом и скриптом
local script_version_text = "9.0" -- текстовая версия
local script_path = thisScript().path  -- патц
local script_url = "https://raw.githubusercontent.com/alfantasy/AdminTool/main/AdminTool.lua" -- основной скрипт на github
local update_path = getWorkingDirectory() .. '/update.ini' -- основной патч
local update_url = "https://raw.githubusercontent.com/alfantasy/AdminTool/main/update.ini" -- загрузка патча
local config_url = "https://raw.githubusercontent.com/alfantasy/AdminTool/main/settings.ini" -- загрузка настроек
local config_path = getWorkingDirectory() .. '\\config\\AdminTool\\settings.ini' -- идентификация патча настроек
local themes_url = "https://raw.githubusercontent.com/alfantasy/AdminTool/main/imgui_themes.lua" -- темы на github
local themes_path = getWorkingDirectory() .. '\\config\\AdminTool\\imgui_themes.lua' -- их идентификация в патче
-------- Введение локальные переменные, отвечающие за автообновление ----------


----- Введенные локальные переменные, отвечающие за админский чат ---------
local font_size_ac = imgui.ImBuffer(16) -- буфер для ввода шрифта
local line_ac = imgui.ImInt(16) -- буфер для ввода линий
local font_ac -- шрифт

--------------- Локальные переменные отвечающие за config -----------
local defTable = {
	setting = {
		Y = 300,
		Admin_chat = false,
		Push_Report = false,
		Chat_Logger = false,
		Chat_Logger_osk = false,
		ATALogin = false,
		ranremenu = false,
		anti_cheat = false,
		auto_mute_mat = false,
		ATAdminPass = "",
		prefix_adm = "",
		prefix_STadm = "",
		prefix_Madm = "",
		prefix_ZGAadm = "",
		prefix_GAadm = "",
		-- new
	},
	keys = {
		ATWHkeys = "None",
		ATTool =  "None",
		ATOnline = "None",
		ATReportAns = "None",
		ATReportRP = "None",
		ATReportRP1 = "None",
		ATReportRP2 = "None",
		P_Log = "None",
		Re_menu = "None",
	},
	achat = {
		X = 48,
		Y = 298, 
		centered = 0,
		color = -1,
		nick = 1,
		lines = 10,
		Font = 10
	}
}

local setting_items = {
	Admin_chat = imgui.ImBool(false),
	Push_Report = imgui.ImBool(false),
	Chat_Logger = imgui.ImBool(false),
	Chat_Logger_osk = imgui.ImBool(false),
	ATAlogin = imgui.ImBool(false),
	ranremenu = imgui.ImBool(false),
	anti_cheat = imgui.ImBool(false),
	auto_mute_mat = imgui.ImBool(false),
	}

--------------- Локальные переменные отвечающие за config -----------

local admin_chat_lines = { 
	centered = imgui.ImInt(0),
	nick = imgui.ImInt(1),
	color = -1,
	lines = imgui.ImInt(10),
	X = 0,
	Y = 0
}
-- линии равны

local ac_no_saved = {
	chat_lines = { },
	pos = false,
	X = 0,
	Y = 0
}
-- не сохраненный


function saveAdminChat()
	config.achat.X = admin_chat_lines.X
	config.achat.Y = admin_chat_lines.Y
	config.achat.centered = admin_chat_lines.centered.v
	config.achat.nick = admin_chat_lines.nick.v
	config.achat.color = admin_chat_lines.color
	config.achat.lines = admin_chat_lines.lines.v
	config.achat.Font = font_size_ac.v
	inicfg.save(config, directIni)
end
-- сохранение админчата
function loadAdminChat()
	admin_chat_lines.X = config.achat.X
	admin_chat_lines.Y = config.achat.Y
	admin_chat_lines.centered.v = config.achat.centered
	admin_chat_lines.nick.v = config.achat.nick
	admin_chat_lines.color = config.achat.color
	admin_chat_lines.lines.v = config.achat.lines
	font_size_ac.v = tostring(config.achat.Font)
end
-- загрузка админчата

----- Введенные локальные переменные, отвечающие за админский чат ---------


------ Введенные локальные переменные, отвечающие за цвет ----------
local label = 0 -- основа
local main_color = 0xe01df2 -- основной цвет
local text_color = 0x4169E1 -- цвет текста
local main_color_text = "{6e73f0}" -- 2 цвет
local white_color = "{FFFFFF}" -- белый цвет
local mcolor -- локальная переменная для регистрации рандомного цвета
local tag = "{87CEEB}[AdminTool]  {4169E1}" -- локальная переменная, которая регистрирует тэг AT
------ Введенные локальные переменные, отвечающие за цвет ----------


------- Введенные локальные переменные, отвечающие за меню рекона -----------------
local player_info = {} -- инфа о челике
local player_to_streamed = {} -- инфа о преследуемым
local text_remenu = { "Очки:", "Здоровье:", "Броня:", "ХП машины:", "Скорость:", "Ping:", "Патроны:", "Выстрелы:", "Время выстрелов:", "Время АФК:", "P.Loss:", "VIP:", "Passive Мод:", "Turbo:", "Коллизия:" }
local control_recon_playerid = -1 -- контролируемая переменная за ид игрока
local control_tab_playerid = -1 -- в табе
local control_recon_playernick = nil -- ник
local next_recon_playerid = nil -- следующий ид
local control_recon = false -- контролирование рекона
local control_info_load = false -- контролирование загрузки инфы
local right_re_menu = true -- ременю справа
local check_mouse = false -- проверка курсора мыши
local mouse_cursor = true -- равен ли курсор правде
local check_cmd_re = false -- контроль команды о слежке
local accept_load = false -- загрузка рекона
local tool_re
------- Введенные локальные переменные, отвечающие за меню рекона -----------------

------ Введенные локальные переменные, отвечающие за автомут ----------
local onscene = { "блять", "сука", "хуй", "нахуй" } -- основная сцена мата
local control_onscene = false -- контролирование сцены мата
local log_onscene = { } -- лог сцены
local date_onscene = {} -- дата сцены
------ Введенные локальные переменные, отвечающие за автомут ----------

----- Введенные локальные переменные, которые отвечают за imgui окно и/или относятся к нему -------



function imgui.TextColoredRGB(text, render_text)
    local max_float = imgui.GetWindowWidth()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text)
        for w in text:gmatch('[^\r\n]+') do
            local text, colors, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors[#colors + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end

            local length = imgui.CalcTextSize(w)
            if render_text == 2 then
                imgui.NewLine()
                imgui.SameLine(max_float / 2 - ( length.x / 2 ))
            elseif render_text == 3 then
                imgui.NewLine()
                imgui.SameLine(max_float - length.x - 5 )
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], text[i])
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(w) end


        end
    end

    render_text(text)
end


local ac_string = '' -- строка античита


imgui.ToggleButton = require('imgui_addons').ToggleButton
imgui.Spinner = require('imgui_addons').Spinner
imgui.BufferingBar = require('imgui_addons').BufferingBar
local one_window_state = imgui.ImBool(false)
local two_window_state = imgui.ImBool(false)
local three_window_state = imgui.ImBool(false)
local four_window_state = imgui.ImBool(false)
local five_window_state = imgui.ImBool(false)
local six_window_state = imgui.ImBool(false)
local seven_window_state = imgui.ImBool(false)
local ATChat = imgui.ImBool(false)
local ATChatLogger = imgui.ImBool(false)
local ATre_menu = imgui.ImBool(false)
local chat_logger = imgui.ImBuffer(10000)
local chat_find = imgui.ImBuffer(256)
local settings_keys = imgui.ImBool(false)
local btn_size = imgui.ImVec2(-0.1, 0)
local ATAdminPass = imgui.ImBuffer(214)
local ban_id = imgui.ImBuffer(50)
local ban_nick = imgui.ImBuffer(100)
local text_buffer_mp = imgui.ImBuffer(516)
local text_buffer_prize = imgui.ImBuffer(524)
local text_buffer_name = imgui.ImBuffer(256)
local text_buffer_sniat = imgui.ImBuffer(2048)
local text_buffer_kick = imgui.ImBuffer(1024)
local text_buffer_adm = imgui.ImBuffer(4096)
local prefix_Madm = imgui.ImBuffer(4096)
local prefix_adm = imgui.ImBuffer(4096)
local prefix_STadm = imgui.ImBuffer(4096)
local prefix_ZGAadm = imgui.ImBuffer(4096)
local prefix_GAadm = imgui.ImBuffer(4096)
local arr_str = {u8"1 LVL", 
				u8"2 LVL", 
				u8"3 LVL", 
				u8"4 LVL", 
				u8"5 LVL", 
				u8"6 LVL", 
				u8"7 LVL", 
				u8"8 LVL", 
				u8"9 LVL", 
				u8"10 LVL", 
				u8"11 LVL", 
				u8"12 LVL", 
				u8"13 LVL", 
				u8"14 LVL", 
				u8"15 LVL", 
				u8"16 LVL", 
				u8"17 LVL", 
				u8"18 LVL" }

local ban_str = {u8" 7  Использование читерского ПО",
				u8" 3  Неадекватное поведение. (3)",
				u8" 7  Неадекватное поведение. (7)",
				u8" 30  Обман администрации. ",
				u8" 30  Обман игроков. ",
				u8" 7  Банда, содержающая нецензурную лексику.",
				u8" 7  Обход прошлого бана.",
				u8" 30  Оскорбление в сторону проекта."}

local checked_test = imgui.ImBool(false) -- отвечает за чекбокс
local checked_test_2 = imgui.ImBool(false) -- отвечает за второй введенный чекбокс

local checked_radio = imgui.ImInt(1) -- отвечает за радиобаттоны

local combo_select = imgui.ImInt(0) -- отвечает за комбо-штучки

local sw1, sh1 = getScreenResolution() -- отвечает за ширину и длину, короче говоря - размер окна.
local sw, sh = getScreenResolution() -- отвечает за второстепенную длину и ширину окон.

local ATadm_forms = '' -- переменная, отвечающая за пустую строчку формы

----- Введенные локальные переменные, которые отвечают за imgui окно и/или относятся к нему -------

------ Введенные локальные переменная, отвечающие за перевод символов, или остальных свойств чата -----------
local russian_characters = {
    [168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я',
} 

local translate = {
	["й"] = "q",
	["ц"] = "w",
	["у"] = "e",
	["к"] = "r",
	["е"] = "t",
	["н"] = "y",
	["г"] = "u",
	["ш"] = "i",
	["щ"] = "o",
	["з"] = "p",
	["х"] = "[",
	["ъ"] = "]",
	["ф"] = "a",
	["ы"] = "s",
	["в"] = "d",
	["а"] = "f",
	["п"] = "g",
	["р"] = "h",
	["о"] = "j",
	["л"] = "k",
	["д"] = "l",
	["ж"] = ";",
	["э"] = "'",
	["я"] = "z",
	["ч"] = "x",
	["с"] = "c",
	["м"] = "v",
	["и"] = "b",
	["т"] = "n",
	["ь"] = "m",
	["б"] = ",",
	["ю"] = "."
}
----- локальная переменная отвечает за перевод русских символов, ответ за цифренную часть букв.

------ Введенные локальные переменная, отвечающие за перевод символов, или остальных свойств чата -----------






function set_custom_theme()
	imgui.SwitchContext()
	local style  = imgui.GetStyle()
	local colors = style.Colors
	local clr    = imgui.Col
	local ImVec4 = imgui.ImVec4
	local ImVec2 = imgui.ImVec2

	style.WindowPadding       = ImVec2(4, 8)
	style.WindowRounding      = 16
	style.ChildWindowRounding = 16
	style.FramePadding        = ImVec2(8, 3)
	style.FrameRounding       = 16
	style.ItemSpacing         = ImVec2(6, 4)
	style.TouchExtraPadding   = ImVec2(0, 0)
	style.IndentSpacing       = 21
	style.ScrollbarSize       = 15
	style.ScrollbarRounding   = 16
	style.GrabMinSize         = 10
	style.GrabRounding        = 4
	style.WindowTitleAlign    = ImVec2(0.50, 0.50)
	style.ButtonTextAlign     = ImVec2(0, 0)

	colors[clr.Text]                 = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled]         = ImVec4(0.73, 0.75, 0.74, 1.00)
	colors[clr.WindowBg]             = ImVec4(0.09, 0.09, 0.09, 0.94)
	colors[clr.ChildWindowBg]        = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.Border]               = ImVec4(0.20, 0.20, 0.20, 0.50)
	colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.FrameBg]              = ImVec4(0.13, 0.37, 0.53, 0.37)
	colors[clr.FrameBgHovered]       = ImVec4(0.14, 0.21, 0.67, 0.00)
	colors[clr.FrameBgActive]        = ImVec4(0.84, 0.66, 0.66, 0.67)
	colors[clr.TitleBg]              = ImVec4(0.39, 0.33, 0.51, 0.00)
	colors[clr.TitleBgActive]        = ImVec4(0.26, 0.20, 0.53, 1.00)
	colors[clr.TitleBgCollapsed]     = ImVec4(0.47, 0.22, 0.59, 0.35)
	colors[clr.MenuBarBg]            = ImVec4(0.34, 0.16, 0.22, 0.00)
	colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.31, 0.64)
	colors[clr.ScrollbarGrab]        = ImVec4(0.31, 0.31, 0.31, 1.00)
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.ScrollbarGrabActive]  = ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.ComboBg]              = ImVec4(0.20, 0.20, 0.20, 0.99)
	colors[clr.CheckMark]            = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.SliderGrab]           = ImVec4(0.71, 0.39, 0.39, 1.00)
	colors[clr.SliderGrabActive]     = ImVec4(0.84, 0.66, 0.66, 1.00)
	colors[clr.Button]               = ImVec4(0.32, 0.20, 0.33, 0.59)
	colors[clr.ButtonHovered]        = ImVec4(0.71, 0.39, 0.39, 0.65)
	colors[clr.ButtonActive]         = ImVec4(0.20, 0.20, 0.20, 0.50)
	colors[clr.Header]               = ImVec4(0.71, 0.39, 0.39, 0.54)
	colors[clr.HeaderHovered]        = ImVec4(0.84, 0.66, 0.66, 0.65)
	colors[clr.HeaderActive]         = ImVec4(0.84, 0.66, 0.66, 0.00)
	colors[clr.Separator]            = ImVec4(0.43, 0.43, 0.50, 0.50)
	colors[clr.SeparatorHovered]     = ImVec4(0.71, 0.39, 0.39, 0.54)
	colors[clr.SeparatorActive]      = ImVec4(0.71, 0.39, 0.39, 0.54)
	colors[clr.ResizeGrip]           = ImVec4(0.71, 0.39, 0.39, 0.54)
	colors[clr.ResizeGripHovered]    = ImVec4(0.84, 0.66, 0.66, 0.66)
	colors[clr.ResizeGripActive]     = ImVec4(0.84, 0.66, 0.66, 0.66)
	colors[clr.CloseButton]          = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.CloseButtonHovered]   = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.CloseButtonActive]    = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered]     = ImVec4(1.00, 0.43, 0.35, 1.00)
	colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
	colors[clr.TextSelectedBg]       = ImVec4(0.26, 0.59, 0.98, 0.35)
	colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
end	
set_custom_theme()


function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end

	local file_read, c_line = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\mat.txt", "r"), 1
	if file_read ~= nil then
		file_read:seek("set", 0)
		for line in file_read:lines() do
			onscene[c_line] = line
			c_line = c_line + 1
		end
		file_read:close()
	end
	-- чтение файла

	sampRegisterChatCommand('s_mat', function(param) -- сохранение мата
		if param == nil then
			return false
		end
		for _, val in ipairs(onscene) do
			if string.rlower(param) == val then
				sampAddChatMessage(tag .. "Слово \"" .. val .. "\" уже присутствует в списке нецензурной брани.")
				return false
			end
		end
		local file_write, c_line = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\mat.txt", "w"), 1
		onscene[#onscene + 1] = string.rlower(param)
		for _, val in ipairs(onscene) do
			file_write:write(val .. "\n")
		end
		file_write:close()
		sampAddChatMessage(tag .. "Слово \"" .. string.rlower(param) .. "\" успешно добавлено в список нецензурной лексики.")
	end)
	sampRegisterChatCommand('d_mat', function(param) -- удаление мата
		if param == nil then
			return false
		end
		local file_write, c_line = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\mat.txt", "w"), 1
		for i, val in ipairs(onscene) do
			if val == string.rlower(param) then
				onscene[i] = nil
				control_onscene = true
			else
				file_write:write(val .. "\n")
			end
		end
		file_write:close()
		if control_onscene then
			sampAddChatMessage(tag .. "Слово \"" .. string.rlower(param) .. "\" было успешно удалено из списка нецензурной брани.")
			control_onscene = false
		else
			sampAddChatMessage(tag .. "Слова \"" .. string.rlower(param) .. "\" нет в списке нецензурщины.")
		end
	end)

	_, watermark_id = sampGetPlayerIdByCharHandle(playerPed)
    watermark_nick = sampGetPlayerNickname(watermark_id)
	
	downloadUrlToFile(update_url, update_path, function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then  
			updateIni = inicfg.load(nil, update_path)
			if tonumber(updateIni.info.version) > script_version then 
				notify.addNotify("{87CEEB}[AdminTool]", 'На GitHub новая версия \nAdminTool обновляется', 2, 1, 6)
				update_state = true
			end
			os.remove(update_path)
		end
	end)
	-- перехват переменной о том, что нужно обновится

	------------- Чтение ChatLogger -----------------
	chatlogDirectory = getWorkingDirectory() .. "\\config\\AdminTool\\chatlog"
    if not doesDirectoryExist(chatlogDirectory) then
        createDirectory(getWorkingDirectory() .. "\\config\\AdminTool\\chatlog")
    end
	------------- Чтение ChatLogger -----------------


	--------- Отвечающие функции для настроек ---------
	config = inicfg.load(defTable, directIni)
	setting_items.Admin_chat.v = config.setting.Admin_chat
	setting_items.Push_Report.v = config.setting.Push_Report
	setting_items.Chat_Logger.v = config.setting.Chat_Logger
	setting_items.ATAlogin.v = config.setting.ATAlogin
	setting_items.ranremenu.v = config.setting.ranremenu
	setting_items.anti_cheat.v = config.setting.anti_cheat
	setting_items.auto_mute_mat.v = config.setting.auto_mute_mat

	prefix_adm.v = config.setting.prefix_adm
	prefix_STadm.v = config.setting.prefix_STadm
	prefix_Madm.v = config.setting.prefix_Madm
	prefix_ZGAadm.v = config.setting.prefix_ZGAadm
	prefix_GAadm.v = config.setting.prefix_GAadm

	ATAdminPass.v = config.setting.ATAdminPass
	index_text_pos = config.setting.Y
	
	if not doesDirectoryExist(getWorkingDirectory() .. "/config/AdminTool") then
		createDirectory(getWorkingDirectory() .. "/config/AdminTool")
	end
	--------- Отвечающие функции для настроек ---------


	--------- Команды рендеринга текста -------
	local an_tag = tag .. 'Anti-Cheat:'
	font_ac = renderCreateFont("Arial", config.setting.Font, font_admin_chat.BOLD + font_admin_chat.SHADOW)
		--------- Команда, отвечающая за шрифт административного чата ----------
	font_watermark = renderCreateFont("Arial", 10, font_admin_chat.BOLD)
	lua_thread.create(function()
		while true do
			renderFontDrawText(font_watermark, tag .. "v." .. script_version_text .. "{FFFFFF} | {AAAAAA}" .. watermark_nick .. " [" .. watermark_id .. "] ", 10, sh-20, 0xCCFFFFFF)

			if setting_items.anti_cheat.v then 
				renderFontDrawText(font_watermark, an_tag.. '\n' ..ac_string, 20, sh-430, 0xCCFFFFFF)
				renderFontDrawText(font_watermark, an_tag.. '\n' ..ac_string, 20, sh-430, 0xCCFFFFFF)
				renderFontDrawText(font_watermark, an_tag.. '\n' ..ac_string, 20, sh-430, 0xCCFFFFFF)

				end
			   wait(1)
		end
	end)
	--------- Команды рендеринга текста -------


	------------- Команды, отвечающие за замороженные функции ---------
	admin_chat = lua_thread.create_suspended(drawAdminChat)
	wallhack = lua_thread.create(drawWallhack)
	load_chat_log = lua_thread.create_suspended(loadChatLog)
	load_info_player = lua_thread.create_suspended(loadPlayerInfo)
	draw_re_menu = lua_thread.create_suspended(drawRePlayerInfo)
	check_cmd = lua_thread.create_suspended(function()
		wait(1000)
		check_cmd_re = false
	end)
	------------- Команды, отвечающие за замороженные функции ---------


	--------- Команды, ИСКЛЮЧИТЕЛЬНО ДЛЯ РАЗРАБОТЧИКОВ ИЛИ ВНУТРИИГРОВЫХ ДЕЙСТВИЙ -----------
	sampRegisterChatCommand("update", update)
	sampRegisterChatCommand("tpcord", tpcord)
	sampRegisterChatCommand("iddialog", iddialog)
	sampRegisterChatCommand("delch", delch)
	sampRegisterChatCommand("tpad", tpad)
	--------- Команды, ИСКЛЮЧИТЕЛЬНО ДЛЯ РАЗРАБОТЧИКОВ ИЛИ ВНУТРИИГРОВЫХ ДЕЙСТВИЙ -----------
	
	--------------------------- Команды для префиксов -------------------
	sampRegisterChatCommand("pradm1", pradm1)
	sampRegisterChatCommand("pradm2", pradm2)
	sampRegisterChatCommand("pradm3", pradm3)
	sampRegisterChatCommand("pradm4", pradm4)
	sampRegisterChatCommand("pradm5", pradm5)
	--------------------------- Команды для префиксов -------------------

	------- Команды для запуска интерфейса ------- 
	sampRegisterChatCommand("tool", cmd_tool)
	sampRegisterChatCommand("toolmp", cmd_toolmp)
	sampRegisterChatCommand("toolfd", cmd_toolfd)
	sampRegisterChatCommand("toolans", cmd_toolans)
	sampRegisterChatCommand("tooladm", cmd_tooladm)
	------- Команды для запуска интерфейса ------- 

	------- Команды исключительно для мутов -------
	sampRegisterChatCommand("fd1", cmd_fd1)
	sampRegisterChatCommand("fd2", cmd_fd2)
	sampRegisterChatCommand("fd3", cmd_fd3)
	sampRegisterChatCommand("fd4", cmd_fd4)
	sampRegisterChatCommand("fd5", cmd_fd5)
	sampRegisterChatCommand("po1", cmd_po1)
	sampRegisterChatCommand("po2", cmd_po2)
	sampRegisterChatCommand("po3", cmd_po3)
	sampRegisterChatCommand("po4", cmd_po4)
	sampRegisterChatCommand("po5", cmd_po5)
	sampRegisterChatCommand("m", cmd_m)
	sampRegisterChatCommand("ok", cmd_ok)
	sampRegisterChatCommand("oa", cmd_oa)
	sampRegisterChatCommand("kl", cmd_kl)
	sampRegisterChatCommand("up", cmd_up)
	sampRegisterChatCommand("or", cmd_or)
	sampRegisterChatCommand("nm", cmd_nm)
	sampRegisterChatCommand("nm1", cmd_nm1)
	sampRegisterChatCommand("nm2", cmd_nm2)
	sampRegisterChatCommand("ia", cmd_ia)
	------- Команды исключительно для мутов -------

	------- Команды исключительно для мутов репорта -------
	sampRegisterChatCommand("roa", cmd_roa)
	sampRegisterChatCommand("ror", cmd_ror)
	sampRegisterChatCommand("rpo", cmd_rpo)
	sampRegisterChatCommand("cp", cmd_cp)
	sampRegisterChatCommand("rnm", cmd_rnm)
	sampRegisterChatCommand("rnm1", cmd_rnm1)
	sampRegisterChatCommand("rnm2", cmd_rnm2)
	sampRegisterChatCommand("rup", cmd_rup)
	sampRegisterChatCommand("rok", cmd_rok)
	sampRegisterChatCommand("rm", cmd_rm)
	------- Команды исключительно для мутов репорта -------

	------- Команды исключительно для джайлов -------
	sampRegisterChatCommand("sk", cmd_sk)
	sampRegisterChatCommand("dz", cmd_dz)
	sampRegisterChatCommand("dz1", cmd_dz1)
	sampRegisterChatCommand("dz2", cmd_dz2)
	sampRegisterChatCommand("jm", cmd_jm)
	sampRegisterChatCommand("td", cmd_td)
	sampRegisterChatCommand("skw", cmd_skw)
	sampRegisterChatCommand("ngw", cmd_ngw)
	sampRegisterChatCommand("dbgw", cmd_dbgw)
	sampRegisterChatCommand("fsh", cmd_fsh)
	sampRegisterChatCommand("bag", cmd_bag)
	sampRegisterChatCommand("pmx", cmd_pmx)
	sampRegisterChatCommand("pk", cmd_pk)
	sampRegisterChatCommand("zv", cmd_zv)
	sampRegisterChatCommand("jch", cmd_jch)
	sampRegisterChatCommand("dgw", cmd_dgw)
	sampRegisterChatCommand("sch", cmd_sch)
	sampRegisterChatCommand("jcw", cmd_jcw)
	------- Команды исключительно для джайлов -------

	------- Команды исключительно для банов -------
	sampRegisterChatCommand("pl", cmd_pl)
	sampRegisterChatCommand("ch", cmd_ch)
	sampRegisterChatCommand("ob", cmd_ob)
	sampRegisterChatCommand("hl", cmd_hl)
	sampRegisterChatCommand("nk", cmd_nk)
	sampRegisterChatCommand("gcnk", cmd_gcnk)
	sampRegisterChatCommand("okpr", cmd_okpr)
	sampRegisterChatCommand("okprip", cmd_okprip)
	sampRegisterChatCommand("svocakk", cmd_svocakk)
	sampRegisterChatCommand("svocip", cmd_svocip)
	------- Команды исключительно для банов -------

	------- Команды исключительно для мутов в оффлайне -------
	sampRegisterChatCommand("am", cmd_am)
	sampRegisterChatCommand("aok", cmd_aok)
	sampRegisterChatCommand("afd", cmd_afd)
	sampRegisterChatCommand("apo", cmd_apo)
	sampRegisterChatCommand("aoa", cmd_aoa)
	sampRegisterChatCommand("aup", cmd_aup)
	sampRegisterChatCommand("anm", cmd_anm)
	sampRegisterChatCommand("anm1", cmd_anm1)
	sampRegisterChatCommand("anm2", cmd_anm2)
	sampRegisterChatCommand("aor", cmd_aor)
	sampRegisterChatCommand("aia", cmd_aia)
	sampRegisterChatCommand("akl", cmd_akl)
	------- Команды исключительно для мутов в оффлайне -------


	------- Команды исключительно для джайлов в оффлайне -------
	sampRegisterChatCommand("ajcw", cmd_ajcw)
	sampRegisterChatCommand("ask", cmd_ask)
	sampRegisterChatCommand("adz", cmd_adz)
	sampRegisterChatCommand("adz1", cmd_adz1)
	sampRegisterChatCommand("adz2", cmd_adz2)
	sampRegisterChatCommand("afsh", cmd_afsh)
	sampRegisterChatCommand("atd", cmd_atd)
	sampRegisterChatCommand("abag", cmd_abag)
	sampRegisterChatCommand("apk", cmd_apk)
	sampRegisterChatCommand("azv", cmd_azv)
	sampRegisterChatCommand("askw", cmd_askw)
	sampRegisterChatCommand("angw", cmd_angw)
	sampRegisterChatCommand("adbgw", cmd_adbgw)
	sampRegisterChatCommand("adgw", cmd_adgw)
	sampRegisterChatCommand("ajch", cmd_ajch)
	sampRegisterChatCommand("apmx", cmd_apmx)
	sampRegisterChatCommand("asch", cmd_asch)
	------- Команды исключительно для джайлов в оффлайне -------


	------- Команды исключительно для киков -------
	sampRegisterChatCommand("dj", cmd_dj)
	sampRegisterChatCommand("gnk1", cmd_gnk1)
	sampRegisterChatCommand("gnk2", cmd_gnk2)
	sampRegisterChatCommand("gnk3", cmd_gnk3)
	sampRegisterChatCommand("cafk", cmd_cafk)
	------- Команды исключительно для киков -------


	------- Команды исключительно для банов в оффлайне -------
	sampRegisterChatCommand("aob", cmd_aob)
	sampRegisterChatCommand("ahl", cmd_ahl)
	sampRegisterChatCommand("ahli", cmd_ahli)
	sampRegisterChatCommand("apl", cmd_apl)
	sampRegisterChatCommand("ach", cmd_ach)
	sampRegisterChatCommand("achi", cmd_achi)
	sampRegisterChatCommand("ank", cmd_ank)
	sampRegisterChatCommand("agcnk", cmd_agcnk)
	sampRegisterChatCommand("agcnkip", cmd_agcnkip)
	sampRegisterChatCommand("rdsob", cmd_rdsob)
	sampRegisterChatCommand("rdsip", cmd_rdsip)
	------- Команды исключительно для банов в оффлайне -------
	

	------- Команды исключительно для быстрых ответов -------
	sampRegisterChatCommand("tdd", cmd_tdd)
	sampRegisterChatCommand("gadm", cmd_gadm)
	sampRegisterChatCommand("enk", cmd_enk)
	sampRegisterChatCommand("gak", cmd_gak)
	sampRegisterChatCommand("ctun", cmd_ctun)
	sampRegisterChatCommand("gn", cmd_gn)
	sampRegisterChatCommand("pd", cmd_pd)
	sampRegisterChatCommand("dtl", cmd_dtl)
	sampRegisterChatCommand("nz", cmd_nz)
	sampRegisterChatCommand("yes", cmd_yes)
	sampRegisterChatCommand("net", cmd_net)
	sampRegisterChatCommand("nt", cmd_nt)
	sampRegisterChatCommand("fp", cmd_fp)
	sampRegisterChatCommand("mg", cmd_mg)
	sampRegisterChatCommand("pg", cmd_pg)
	sampRegisterChatCommand("krb", cmd_krb)
	sampRegisterChatCommand("kmd", cmd_kmd)
	sampRegisterChatCommand("gm", cmd_gm)
	sampRegisterChatCommand("plg", cmd_plg)
	sampRegisterChatCommand("vbg", cmd_vbg)
	sampRegisterChatCommand("en", cmd_en)
	sampRegisterChatCommand("of", cmd_of)
	sampRegisterChatCommand("nv", cmd_nv)
	sampRegisterChatCommand("bk", cmd_bk)
	sampRegisterChatCommand("h7", cmd_h7)
	sampRegisterChatCommand("h8", cmd_h8)
	sampRegisterChatCommand("h13", cmd_h13)
	sampRegisterChatCommand("zba", cmd_zba)
	sampRegisterChatCommand("zbp", cmd_zbp)
	sampRegisterChatCommand("int", cmd_int)
	sampRegisterChatCommand("og", cmd_og)
	sampRegisterChatCommand("dis", cmd_dis)
	sampRegisterChatCommand("avt", cmd_avt)
	sampRegisterChatCommand("avt1", cmd_avt1)
	sampRegisterChatCommand("pgf", cmd_pgf)
	sampRegisterChatCommand("igf", cmd_igf)
	sampRegisterChatCommand("msid", cmd_msid)
	sampRegisterChatCommand("al", cmd_al)
	sampRegisterChatCommand("c", cmd_c)
	sampRegisterChatCommand("cl", cmd_cl)
	sampRegisterChatCommand("yt", cmd_yt)
	sampRegisterChatCommand("n", cmd_n)
	sampRegisterChatCommand("nac", cmd_nac)
	sampRegisterChatCommand("hg", cmd_hg)
	sampRegisterChatCommand("tm", cmd_tm)
	sampRegisterChatCommand("cpt", cmd_cpt)
	sampRegisterChatCommand("psv", cmd_psv)
	sampRegisterChatCommand("drb", cmd_drb)
	sampRegisterChatCommand("prk", cmd_prk)
	sampRegisterChatCommand("zsk", cmd_zsk)
	sampRegisterChatCommand("vgf", cmd_vgf)
	sampRegisterChatCommand("stp", cmd_stp)
	sampRegisterChatCommand("rid", cmd_rid)
	sampRegisterChatCommand("gvs", cmd_gvs)
	sampRegisterChatCommand("gvm", cmd_gvm)
	sampRegisterChatCommand("msp", cmd_msp)
	sampRegisterChatCommand("chap", cmd_chap)
	sampRegisterChatCommand("lgf", cmd_lgf)
	sampRegisterChatCommand("trp", cmd_trp)
	sampRegisterChatCommand("cops", cmd_cops)
	sampRegisterChatCommand("bal", cmd_bal)
	sampRegisterChatCommand("cro", cmd_cro)
	sampRegisterChatCommand("vg", cmd_vg)
	sampRegisterChatCommand("rumf", cmd_rumf)
	sampRegisterChatCommand("var", cmd_var)
	sampRegisterChatCommand("triad", cmd_triad)
	sampRegisterChatCommand("mf", cmd_mf)
	sampRegisterChatCommand("smc", cmd_smc)
	sampRegisterChatCommand("html", cmd_html)
	sampRegisterChatCommand("ugf", cmd_ugf)
	sampRegisterChatCommand("vp1", cmd_vp1)
	sampRegisterChatCommand("vp2", cmd_vp2)
	sampRegisterChatCommand("vp3", cmd_vp3)
	sampRegisterChatCommand("vp4", cmd_vp4)
	sampRegisterChatCommand("ktp", cmd_ktp)
	sampRegisterChatCommand("tcm", cmd_tcm)
	sampRegisterChatCommand("gfi", cmd_gfi)
	sampRegisterChatCommand("hin", cmd_hin)
	sampRegisterChatCommand("smh", cmd_smh)
	sampRegisterChatCommand("cr", cmd_cr)
	sampRegisterChatCommand("hct", cmd_hct)
	sampRegisterChatCommand("gvr", cmd_gvr)
	sampRegisterChatCommand("gvc", cmd_gvc)
	------- Команды исключительно для быстрых ответов -------

	------ Команды, используемые в вспомогательных случаях -------
	sampRegisterChatCommand("u", cmd_u)
	sampRegisterChatCommand("uu", cmd_uu)
	sampRegisterChatCommand("as", cmd_as)
	sampRegisterChatCommand("stw", cmd_stw)
	sampRegisterChatCommand("ru", cmd_ru)
	------ Команды, используемые в вспомогательных случаях -------


	----------------- Раздел отвечающий за показ уведомлений -------------------------
	sampRegisterChatCommand("notify", cmd_notify)
	----------------- Раздел отвечающий за показ уведомлений -------------------------
	
	----------------- Команды исключительно для старшего состава ---------------------
	sampRegisterChatCommand("nba", cmd_nba)
	sampRegisterChatCommand("dpv", cmd_dpv)
	sampRegisterChatCommand("arep", cmd_arep)
	----------------- Команды исключительно для старшего состава ---------------------
	
	----------------- Команды исключительно для включения/выключения ВХ -----------------------
	sampRegisterChatCommand("wh", cmd_wh)
	----------------- Команды исключительно для включения/выключения ВХ -----------------------
	--local fonte = renderCreateFont("Arial", 8, 5) --creating font
	--sampfuncsRegisterConsoleCommand("showtdid", show)   --registering command to sampfuncs console, this will call function that shows textdraw id's

	sampRegisterChatCommand('leb', leb)

	sampRegisterChatCommand('spp', function()
	local playerid_to_stream = playersToStreamZone()
	for _, v in pairs(playerid_to_stream) do
	sampSendChat('/aspawn ' .. v)
	end
	end)
	-- заспавни всех вокруге стрима

	sampRegisterChatCommand('cfind', function(param)
		if param == nil then
			ATChatLogger.v = not ATChatLogger.v
			imgui.Process = true
			chat_logger_text = readChatlog()
		else
			ATChatLogger.v = not ATChatLogger.v
			imgui.Process = true
			chat_find.v = param
			chat_logger_text = readChatlog()
		end
		load_chat_log:run()
	end)
	-- активация чат-логгера

	------------------ Показ запуска скрипта, указ автора и функций -------------------------
	sampAddChatMessage("{87CEEB}[AdminTool] {4169E1}Автор данного скрипта: Егор Федосеев, VK ID: alfantasy", 0xe01df2)
	sampAddChatMessage("{87CEEB}[AdminTool] {4169E1}Разработчик будет вводить новые фукнции, так что следите за обновлениями.", 0xe01df2)
	sampAddChatMessage("{87CEEB}[AdminTool] {4169E1}Скрипт используется администраторами для облегчения их работы", 0xe01df2)
	sampAddChatMessage("{87CEEB}[AdminTool] {4169E1}Для просмотра помощи по командам AdminTool введите /tool", 0xe01df2)
	sampAddChatMessage("{87CEEB}[AdminTool] {4169E1}Также, для просмотра помощи по командам, нажмите F3. Два способа", 0xe01df2)
	sampAddChatMessage("{87CEEB}[AdminTool] {4169E1}Если вы нашли ошибку, напишите в ВК разработчика.", 0xe01df2)
	sampAddChatMessage("{87CEEB}[AdminTool] {4169E1}Хорошей работы вам, коллега! :3", 0x6e73f0)
	------------------ Показ запуска скрипта, указ автора и функций -------------------------

	-- просмотр ID -- 
	_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	nick = sampGetPlayerNickname(id)

	if nick == "Kintzel." then
		sampAddChatMessage("{87CEEB}Приветик, {FF69B4} Настююшка {DB7093}<3", 0x87CEEB)
	end

	if nick == "Shtormo." then
		sampAddChatMessage("{87CEEB}Приветушки, {008000} Мишуля {DB7093}<3", 0x87CEEB)
	end

	if nick == "index." then
		sampAddChatMessage("{87CEEB}Привет, {4169E1} Линар {DB7093}<3", 0x87CEEB)
	end

	if nick == "Langermann" then
		sampAddChatMessage("{87CEEB}Приветик, {FF69B4} Мариша {DB7093}<3", 0x87CEEB)
	end

	if nick == "Unite." then
		sampAddChatMessage("{87CEEB}Приветик, {98FB98} Таирка {DB7093}<3", 0x87CEEB)
	end

	if nick == "lxrdsavage.fedos" then
		sampAddChatMessage("{87CEEB}Приветик, {66CDAA} семпай {DB7093}<3", 0x87CEEB)
	end

	if nick == "Yuri_Dan__" then   
		sampAddChatMessage("{87CEEB}Приветик, {FA8072}Юрочка {DB7093}<3", 0x87CEEB)
	end

	if nick == "Guardian." then   
		sampAddChatMessage("{87CEEB}Приветик, {7B68EE}Сережа {DB7093}<3", 0x87CEEB)
	end

	if nick == "Flike." then
		sampAddChatMessage("{87CEEB}Привет, {4169E1} Флике Схелбу {DB7093}<3", 0x87CEEB)
	end
		
	if nick == "ZXCMAGIC." then
		sampAddChatMessage("{87CEEB}Приветик, {7B68EE}Vladick {DB7093}<3", 0x87CEEB)
	end
		
	if nick == "David_Yan" then
		sampAddChatMessage("{87CEEB}Приветик, {7B68EE}Кахасик {DB7093}<3", 0x87CEEB)
	end
		
	if nick == "Soldd." then
		sampAddChatMessage("{87CEEB}Приветик, {7B68EE}dungeon master {DB7093}<3", 0x87CEEB)
	end

	imgui.Process = false
	res = false

	thread = lua_thread.create_suspended(thread_function)
	-- введение смены темы на imgui окно.


	--------------- Загрузка админского чата -------------
	loadAdminChat()
	admin_chat:run()
	--------------- Загрузка админского чата -------------

	--sampAddChatMessage("Скрипт imgui перезагружен", -1)

	while true do
		wait(0)


		--if toggle then --params that not declared has a nil value that same as false
		--	for a = 0, 2304	do --cycle trough all textdeaw id
		--		if sampTextdrawIsExists(a) then --if textdeaw exists then
		--			x, y = sampTextdrawGetPos(a) --we get it's position. value returns in game coords
		--			x1, y1 = convertGameScreenCoordsToWindowScreenCoords(x, y) --so we convert it to screen cuz render needs screen coords
		--			renderFontDrawText(fonte, a, x1, y1, 0xFFBEBEBE) --and then we draw it's id on textdeaw position
		--		end
		--	end
		--end





		if update_state then  
			downloadUrlToFile(script_url, script_path, function(id, status)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then  
					notify.addNotify("{87CEEB}[AdminTool]", 'AdminTool обновлен. \nПриятной работы!', 2, 1, 6)
					thisScript():reload()
				end
			end)
			break
		end
		if update_state then  
			downloadUrlToFile(config_url, config_path, function(id, status)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then  
					notify.addNotify("{87CEEB}[AdminTool]", 'Настройки обновлены. \nВсе выставлено по умолчанию.', 2, 1, 6)
				end
			end)
			break
		end
		if update_state then  
			downloadUrlToFile(themes_url, themes_path, function(id, status)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then  
					notify.addNotify("{87CEEB}[AdminTool]", 'Темы обновлены. \nПлагин был снова обновлен.', 2, 1, 6)
				end
			end)
			break
		end
		------ Формальное обновление
		
		--------- Активация /remenu ---------------
		if control_recon and recon_to_player then
			if control_info_load then
				control_info_load = false
				load_info_player:run()
				ATre_menu.v = true
				imgui.Process = true
				tool_re = 0
			end
		else
			ATre_menu.v = false
		end
		if not sampIsPlayerConnected(control_recon_playerid) then
			ATre_menu.v = false
			control_recon_playerid = -1
		end
		if ATre_menu.v then
			check_mouse = true
		end

		if isKeyDown(VK_R) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) and control_recon and recon_to_player then
			sampSendClickTextdraw(48)
		end
		---------- Обновление рекона -----------

		if isKeyDown(VK_NumPad6) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) and control_recon and recon_to_player then
			sampSendChat("/re " .. control_recon_playerid+1)
		end
		---------- Следующий игрок -----------

		if isKeyDown(VK_NumPad4) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) and control_recon and recon_to_player then
			sampSendChat("/re " .. control_recon_playerid-1)
		end
		---------- Предыдущий игрок -----------

		if isKeyDown(VK_Q) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) and control_recon and recon_to_player then
			recon_to_player = false
			sampSendChat("/reoff ")
		end
		--------------- Выход из рекона ------------

		if isKeysDown(strToIdKeys(config.keys.Re_menu)) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) and control_recon and recon_to_player then
			right_re_menu = not right_re_menu	
		end
		--------- Активация /remenu ---------------


		--------------- Загрузка админского чата -------------
		if ac_no_saved.pos then
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
		--------------- Загрузка админского чата -------------

		if setting_items.ATAlogin.v == true then
			if sampGetCurrentDialogId() == 1227 and ATAdminPass.v and sampIsDialogActive() then
        	    sampSendDialogResponse(1227, 1, _, ATAdminPass.v)
				sampCloseCurrentDialogWithButton(1227, 1)
			end
		end
		-- автоматический ввод пароля

		if isKeyDown(strToIdKeys(config.keys.ATOnline)) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) then
			sampSendChat("/online")
			wait(100)
			local c = math.floor(sampGetPlayerCount(false) / 10)
			sampSendDialogResponse(1098, 1, c - 1)
			sampCloseCurrentDialogWithButton(0)
			wait(650)
		end
		-- введенный ключ клавиши по выдаче за online

		if isKeyDown(strToIdKeys(config.keys.ATTool)) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) then
			wait(100)
			one_window_state.v = not one_window_state.v
			imgui.Process = one_window_state.v
		end
		-- введенный ключ клавиши по /tool

		if isKeyDown(strToIdKeys(config.keys.ATReportRP)) and sampIsDialogActive() then 
			local string = string.sub(sampGetCurrentDialogEditboxText(), 0, string.len(sampGetCurrentDialogEditboxText()) - 1)
			sampSetCurrentDialogEditboxText(string .. color() .. " | Приятной игры на RDS <3 ")
			wait(650)
		end 
		-- введенный ключ клавиши по /ans
		
		if isKeyDown(strToIdKeys(config.keys.ATReportRP1)) and sampIsDialogActive() then 
			local string = string.sub(sampGetCurrentDialogEditboxText(), 0, string.len(sampGetCurrentDialogEditboxText()) - 1)
			sampSetCurrentDialogEditboxText(string .. color() .. " | Удачного времяпрепровождения. ")
			wait(650)
		end
		-- введенный ключ клавиши по NumPad / (/ans)

		if isKeyDown(109) and sampIsDialogActive() then 
			local string = string.sub(sampGetCurrentDialogEditboxText(), 0, string.len(sampGetCurrentDialogEditboxText()) - 1)
			sampSetCurrentDialogEditboxText(string .. color() .. "Приятного времяпрепровождения на сервере RDS!")
			wait(650)
		end
		-- введенный ключ клавиши по NumPad - (/ans)

		if sampGetCurrentDialogEditboxText() == '/gvk' then 
			local string = string.sub(sampGetCurrentDialogEditboxText(), 0, string.len(sampGetCurrentDialogEditboxText()) - 1)
			sampSetCurrentDialogEditboxText(string .. color() .. "https://vk.com/dmdriftgta")
		end

		if sampGetCurrentDialogEditboxText() == '.счет' or sampGetCurrentDialogEditboxText() == '/cxtn' then  
			sampSetCurrentDialogEditboxText('/count time || /dmcount time' .. color() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.ц' or sampGetCurrentDialogEditboxText() == '/w' then  
			sampSetCurrentDialogEditboxText(color())
		end

		if sampGetCurrentDialogEditboxText() == '.кар' or sampGetCurrentDialogEditboxText() == '/rfh' then 
			sampSetCurrentDialogEditboxText('/car' .. color() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.кпа' or sampGetCurrentDialogEditboxText() == '/rgf' then 
			sampSetCurrentDialogEditboxText(color() .. 'Продать аксессуары, или купить можно на /trade. Чтобы продать, /sell около лавки')
		end

		if sampGetCurrentDialogEditboxText() == '.тюн' or sampGetCurrentDialogEditboxText() == '/n.y' then 
			sampSetCurrentDialogEditboxText('/menu (/mm) - ALT/Y -> Т/С -> Тюнинг ' .. color() .. ' | Приятной игры на RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.ган' or sampGetCurrentDialogEditboxText() == '/ufy' then 
			sampSetCurrentDialogEditboxText('/menu (/mm) - ALT/Y -> Оружие ' .. color() .. ' | Приятной игры на RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.дтт' or sampGetCurrentDialogEditboxText() == '/lnn' then 
			sampSetCurrentDialogEditboxText('/dt 0-990 / Виртуальный мир ' .. color() .. ' | Приятной игры на RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.пед' or sampGetCurrentDialogEditboxText() == '/gtl' then 
			sampSetCurrentDialogEditboxText('/menu (/mm) - ALT/Y -> Предметы ' .. color() .. ' | Приятной игры на RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.иск' or sampGetCurrentDialogEditboxText() == '/bcr' then 
			sampSetCurrentDialogEditboxText(color() .. 'Детали разбросаны по всей карте. Обмен происходится на /garage. ')
		end

		if sampGetCurrentDialogEditboxText() == '.нз' or sampGetCurrentDialogEditboxText() == '/yp' then 
			sampSetCurrentDialogEditboxText('Не запрещено. '  .. color() .. ' | Удачного времяпрепровожодения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.жда' or sampGetCurrentDialogEditboxText() == '/;lf' then 
			sampSetCurrentDialogEditboxText('Да. ' .. color() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.жне' or sampGetCurrentDialogEditboxText() == '/;yt' then 
			sampSetCurrentDialogEditboxText('Нет. ' .. color() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.нк' or sampGetCurrentDialogEditboxText() == '/yr' then 
			sampSetCurrentDialogEditboxText('Никак. ' .. color() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.отф' or sampGetCurrentDialogEditboxText() == '/jna' then 
			sampSetCurrentDialogEditboxText('/familypanel ' .. color() .. ' | Удачного времяпрепровождения ')
		end

		if sampGetCurrentDialogEditboxText() == '.отб' or sampGetCurrentDialogEditboxText() == '/jn,' then 
			sampSetCurrentDialogEditboxText('/menu (/mm) - ALT/Y -> Система банд ' .. color() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.пр' or sampGetCurrentDialogEditboxText() == '/gh' then 
			sampSetCurrentDialogEditboxText('Проверим. ' .. color() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.крб' or sampGetCurrentDialogEditboxText() == '/rh,' then 
			sampSetCurrentDialogEditboxText('Казино, работы, бизнес. ' .. color() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.кмд' or sampGetCurrentDialogEditboxText() == '/rvl' then 
			sampSetCurrentDialogEditboxText('Казино, МП, достижения, работы, обмен очков на коины(/trade)' .. color() .. ' | Приятной игры на RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.гм' or sampGetCurrentDialogEditboxText() == '/uv' then 
			sampSetCurrentDialogEditboxText('GodMode (ГодМод) на сервере не работает. ' .. color() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.рлг' or sampGetCurrentDialogEditboxText() == '/hku' then 
			sampSetCurrentDialogEditboxText('Попробуйте перезайти. '  .. color() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.нвд' or sampGetCurrentDialogEditboxText() == '/ydl' then 
			sampSetCurrentDialogEditboxText('Не выдаем. ' .. color() .. ' | Удачного времяпрепровожодения ')
		end

		if sampGetCurrentDialogEditboxText() == '.офф' or sampGetCurrentDialogEditboxText() == '/jaa' then 
			sampSetCurrentDialogEditboxText('Не оффтопьте. ' .. color() .. ' | Удачного времяпрепровожодения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.нез' or sampGetCurrentDialogEditboxText() == '/ytp' then 
			sampSetCurrentDialogEditboxText('Не знаем.' .. color() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.баг' or sampGetCurrentDialogEditboxText() == '/,fu' then 
			sampSetCurrentDialogEditboxText('Скорей всего - это баг. ' .. color() .. ' | Удачного времяпрепровождения ')
		end

		if sampGetCurrentDialogEditboxText() == '/smh' or sampGetCurrentDialogEditboxText() == '.ыьр' then 
			sampSetCurrentDialogEditboxText('/sellmyhouse (игроку)  ||  /hpanel -> слот -> Изменить -> Продать дом государству')
		end

		if sampGetCurrentDialogEditboxText() == '.дчд' or sampGetCurrentDialogEditboxText() == '/lxl' then 
			sampSetCurrentDialogEditboxText('/hpanel -> Слот1-3 -> Изменить -> Аренда дома | Приятной игры на RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.обм' or sampGetCurrentDialogEditboxText() == '/j,v' then
			sampSetCurrentDialogEditboxText(color() .. 'Чтобы обменять валюту, введите /trade, и подойдите к NPC Арману, стоит справа') 
		end

		if sampGetCurrentDialogEditboxText() == '.ктп' or sampGetCurrentDialogEditboxText() == '/rng' then
			sampSetCurrentDialogEditboxText(color() .. '/tp (по локациям), /g (/goto) id (к игроку) с VIP (/help -> 7 пункт)') 
		end

		if sampGetCurrentDialogEditboxText() == '.кпт' or sampGetCurrentDialogEditboxText() == '/rgn' then
			sampSetCurrentDialogEditboxText('Для того, чтобы начать капт, нужно ввести /capture | ' .. color() .. ' Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.вп1' or sampGetCurrentDialogEditboxText() == '/dg1' then
			sampSetCurrentDialogEditboxText('Данный игрок с привелегией Premuim VIP (/help -> 7) | ' .. color() .. ' Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.вп2' or sampGetCurrentDialogEditboxText() == '/dg2' then
			sampSetCurrentDialogEditboxText('Данный игрок с привелегией Diamond VIP (/help -> 7) | ' .. color() .. ' Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.вп3' or sampGetCurrentDialogEditboxText() == '/dg3' then
			sampSetCurrentDialogEditboxText('Данный игрок с привелегией Platinum VIP (/help -> 7) | ' .. color() .. ' Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.вп4' or sampGetCurrentDialogEditboxText() == '/dg4' then
			sampSetCurrentDialogEditboxText('Данный игрок с привелегией "Личный" VIP (/help -> 7) | ' .. color() .. ' Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.падм' or sampGetCurrentDialogEditboxText() == '/gflv' then
			sampSetCurrentDialogEditboxText('Ожидать набор, или же /help -> 17 пункт. | ' .. color() .. ' Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.копы' or sampGetCurrentDialogEditboxText() == '/rjgs' then
			sampSetCurrentDialogEditboxText('265-267, 280-286, 288, 300-304, 306, 307, 309-311 | ' .. color() .. ' Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.бал' or sampGetCurrentDialogEditboxText() == '/,fk' then
			sampSetCurrentDialogEditboxText('102-104| ' .. color() .. ' Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.грув' or sampGetCurrentDialogEditboxText() == '/uhed' then
			sampSetCurrentDialogEditboxText('105-107 | ' .. color() .. ' Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.румф' or sampGetCurrentDialogEditboxText() == '/heva' then
			sampSetCurrentDialogEditboxText('111-113 | ' .. color() .. ' Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.вар' or sampGetCurrentDialogEditboxText() == '/dfh' then
			sampSetCurrentDialogEditboxText('114-116 | ' .. color() .. ' Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.триад' or sampGetCurrentDialogEditboxText() == '/nhbfl' then
			sampSetCurrentDialogEditboxText('117-188, 120 | ' .. color() .. ' Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.ваг' or sampGetCurrentDialogEditboxText() == '/dfu' then
			sampSetCurrentDialogEditboxText('108-110 | ' .. color() .. ' Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.мф' or sampGetCurrentDialogEditboxText() == '/va' then
			sampSetCurrentDialogEditboxText('124-127 | ' .. color() .. ' Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.спр' or sampGetCurrentDialogEditboxText() == '/cgh' then
			sampSetCurrentDialogEditboxText('/mm -> Действия -> Сменить пароль | ' .. color() .. '  Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.мсп' or sampGetCurrentDialogEditboxText() == '/vcg' then
			sampSetCurrentDialogEditboxText('/mm -> Транспортное средство -> Тип транспорта| ' .. color() .. '  Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.уид' or sampGetCurrentDialogEditboxText() == '/ebl' then
			sampSetCurrentDialogEditboxText('Уточните ID нарушителя/читера в /report ' .. color() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.стп' or sampGetCurrentDialogEditboxText() == '/cng' then
			sampSetCurrentDialogEditboxText(color() .. 'Чтобы посмотреть коины, вирты, рубли и т.д. - /statpl ')
		end

		if sampGetCurrentDialogEditboxText() == '.гвм' or sampGetCurrentDialogEditboxText() == '/udv' then
			sampSetCurrentDialogEditboxText('Для перевода денег, необхдимо ввести /givemoney IDPlayer сумму | ' .. color() .. ' Приятной игры!')
		end

		if sampGetCurrentDialogEditboxText() == '.гвс' or sampGetCurrentDialogEditboxText() == '/udc' then
			sampSetCurrentDialogEditboxText('Для перевода очков, необходимо ввести /givescore IDPlayer сумму |' .. color() .. ' С Diamond VIP.')
		end

		if sampGetCurrentDialogEditboxText() == '.пм' or sampGetCurrentDialogEditboxText() == '/gv' then
			sampSetCurrentDialogEditboxText('/sellmycar IDPlayer Слот(1-3) RDScoin (игроку), в гос: /car | ' .. color() .. ' Приятной игры!')
		end

		if sampGetCurrentDialogEditboxText() == '.вуб' or sampGetCurrentDialogEditboxText() == '/de,' then
			sampSetCurrentDialogEditboxText(color() .. 'Чтобы выдать выговор участнику банды, есть команда: /gvig ')
		end

		if sampGetCurrentDialogEditboxText() == '.зч' or sampGetCurrentDialogEditboxText() == '/px' then
			sampSetCurrentDialogEditboxText('Если вы застряли, введите /spawn | /kill, ' .. color() .. ' но мы можем вам помочь! ')
		end

		if sampGetCurrentDialogEditboxText() == '/prk' or sampGetCurrentDialogEditboxText() == '.зкл' then
			sampSetCurrentDialogEditboxText('/parkour - записатся на паркур | '  .. color() ..  ' Приятной игры на RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '/drb' or sampGetCurrentDialogEditboxText() == '.вки' then
			sampSetCurrentDialogEditboxText('/derby - записатся на дерби | '  .. color() ..  ' Приятной игры на RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.псв' or sampGetCurrentDialogEditboxText() == '/gcd' then
			sampSetCurrentDialogEditboxText('/passive ' .. color() ..  ' Приятной игры на RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.инф' or sampGetCurrentDialogEditboxText() == '/bya' then
			sampSetCurrentDialogEditboxText('Данную информацию можно узнать в интернете. '  .. color() ..  ' Приятной игры!')
		end

		if sampGetCurrentDialogEditboxText() == '.ог' or sampGetCurrentDialogEditboxText() == '/ju' then
			sampSetCurrentDialogEditboxText('Встать на пикап "Ограбление банка", после около ячеек нажимать на ALT и ехать на красный маркер на карте' .. color() ..  ' Приятной игры на RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.ож' or sampGetCurrentDialogEditboxText() == '/j;' then
			sampSetCurrentDialogEditboxText('Ожидайте. '  .. color() ..  ' Приятного времяпрепровождения на RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.цвет' or sampGetCurrentDialogEditboxText() == '/wdtn' then 
			sampSetCurrentDialogEditboxText('https://colorscheme.ru/html-colors.html ' .. color() .. ' Приятной игры на RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.жба' or sampGetCurrentDialogEditboxText() == '/;,f' then
			sampSetCurrentDialogEditboxText('Пишите жалобу на администратора в VK: vk.com/dmdriftgta ')
		end

		if sampGetCurrentDialogEditboxText() == '.жби'or sampGetCurrentDialogEditboxText() == '/;,b'  then
			sampSetCurrentDialogEditboxText('Вы можете оставить жалобу на игрока в VK: vk.com/dmdriftgta ')
		end

		if sampGetCurrentDialogEditboxText() == '.нч' or sampGetCurrentDialogEditboxText() == '/yx' then
			sampSetCurrentDialogEditboxText('Начал(а) работу по вашей жалобе! ' .. color() .. ' Приятной игры на сервере RDS. <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.ич' or sampGetCurrentDialogEditboxText() == '/bx' then
			sampSetCurrentDialogEditboxText('Данный игрок чист. ' .. color() .. ' Приятной игры на сервере RDS. <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.сл' then
			sampSetCurrentDialogEditboxText(color() .. ' Слежу за данным игроком, ожидайте. :3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.п7' or sampGetCurrentDialogEditboxText() == '/g7' then
			sampSetCurrentDialogEditboxText('Данную информацию можно найти в /help -> 7 пункт. | '  .. color() ..  ' Приятной игры на RDS. <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.п13' or sampGetCurrentDialogEditboxText() == '/g13' then
			sampSetCurrentDialogEditboxText('Данную информацию можно найти в /help -> 13 пункт. | '  .. color() ..  ' Приятной игры на RDS. <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.п8' or sampGetCurrentDialogEditboxText() == '/g8' then
			sampSetCurrentDialogEditboxText('Данную информацию можно найти в /help -> 8 пункт. | '  .. color() ..  ' Приятной игры на RDS. <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.нак' or sampGetCurrentDialogEditboxText() == '/yfr' then
			sampSetCurrentDialogEditboxText('Данный игрок наказан. | '  .. color() ..  '  Приятной игры на RDS! <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.нн' or sampGetCurrentDialogEditboxText() == '/yy' then
			sampSetCurrentDialogEditboxText('Не вижу нарушений от игрока. | ' .. color() .. ' Приятной игры на RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.нв' or sampGetCurrentDialogEditboxText() == '/yd' then
			sampSetCurrentDialogEditboxText('Данный игрок не в сети. | ' .. color() .. ' Приятной игры на RDS. <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.бк' or sampGetCurrentDialogEditboxText() == '/,r' then
			sampSetCurrentDialogEditboxText('Оплатить бизнес/дом можно с помощью /bank или /tp -> Разное -> Банк ')
		end

		if sampGetCurrentDialogEditboxText() == '.тас' or sampGetCurrentDialogEditboxText() == '/nfc' then
			sampSetCurrentDialogEditboxText('/tp -> Разное -> Автосалоны |' .. color() .. '  Приятной игры на RDS. <3')
		end

		if sampGetCurrentDialogEditboxText() == '.там' or sampGetCurrentDialogEditboxText() == '/nfv' then
			sampSetCurrentDialogEditboxText('/tp -> Разное -> Автосалоны -> Автомастерская | ' .. color() .. ' Приятной игры на RDS. <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.пгф' or sampGetCurrentDialogEditboxText() == '/gua' then
			sampSetCurrentDialogEditboxText('/gleave (банда) || /fleave (семья)| ' .. color() .. ' Приятной игры на RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.плм' or sampGetCurrentDialogEditboxText() == '/gkv' then
			sampSetCurrentDialogEditboxText('/leave (покинуть мафию)| ' .. color() .. ' Приятной игры на RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.ут' or sampGetCurrentDialogEditboxText() == '/en' then
			sampSetCurrentDialogEditboxText('Уточните ваш вопрос/запрос. ' .. color() .. ' Удачной игры <3')
		end

		if sampGetCurrentDialogEditboxText() == '.пгб' or sampGetCurrentDialogEditboxText() == '/gu,' then
			sampSetCurrentDialogEditboxText('/ginvite (банда) || /finvite (семья) | ' .. color() .. ' Удачной игры на RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.угб' or sampGetCurrentDialogEditboxText() == '/eu,' then
			sampSetCurrentDialogEditboxText('/guninvite (банда) || /funinvite (семья) | ' .. color() .. ' Удачной игры на RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.гвр' or sampGetCurrentDialogEditboxText() == '/udh' then
			sampSetCurrentDialogEditboxText('/giverub IDPlayer rub | С Личного (/help -> 7) | ' .. color() .. ' Удачной игры на RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.гвк' or sampGetCurrentDialogEditboxText() == '/udr' then
			sampSetCurrentDialogEditboxText('/givecoin IDPlayer coin | С Личного (/help -> 7) | ' .. color() .. ' Удачной игры на RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.пв' or sampGetCurrentDialogEditboxText() == '/gd' then
			sampSetCurrentDialogEditboxText('Помогли вам. | ' .. color() .. ' Удачной игры на RDS <3')
		end

		if string.find(sampGetChatInputText(), "%.пр") then
			sampSetChatInputText(string.gsub(sampGetChatInputText(), ".пр", "| Приятной игры на RDS <3"))
		end

		if string.find(sampGetChatInputText(), "%/vrm") then
			sampSetChatInputText(string.gsub(sampGetChatInputText(), "/vrm", "Приятного времяпрепровождения на Russian Drift Server!"))
		end

		if string.find(sampGetChatInputText(), "%/gvk") then
			sampSetChatInputText(string.gsub(sampGetChatInputText(), "/gvk", "https://vk.com/dmdriftgta"))
		end

		if isKeyDown(strToIdKeys(config.keys.ATReportRP2)) and sampIsChatInputActive() then
			local string = string.sub(sampGetChatInputText(), 0, string.len(sampGetChatInputText()) - 1)
			sampSetChatInputText(string .. " | Приятной игры на RDS! <3")
			wait(650)
		end

		if isKeyJustPressed(strToIdKeys(config.keys.ATReportAns)) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) then
			sampSendChat("/ans ")
			sampSendDialogResponse (2348, 1, 0)
		end

		if isKeyDown(strToIdKeys(config.keys.ATWHkeys)) then  
			if control_wallhack then
				sampAddChatMessage(tag .."WallHack был выключен.")
				nameTagOff()
				control_wallhack = false
			else
				sampAddChatMessage(tag .."WallHack был включен.")
				nameTagOn()
				control_wallhack = true
			end
		end

		-- NumPad0 - активация /ans, isKeyJustPressed является функцией, чтобы активировать клавишу
		-- Данная основа кода, является ответом в /ans (спец.символ $)
		-- Блок выполняющийся бесконечно (пока самп активен)

	end
end

local lc_lvl, lc_adm, lc_color, lc_nick, lc_id, lc_text

-- выдача префиксов --
function pradm1(arg)
	sampSendChat("/prefix " .. arg .. " Мл.Администратор " .. prefix_Madm.v)
end

function pradm2(arg)
	sampSendChat("/prefix " .. arg .. " Администратор " .. prefix_adm.v)
end  

function pradm3(arg)
	sampSendChat("/prefix " .. arg .. " Ст.Администратор " .. prefix_STadm.v)
end  

function pradm4(arg)
	sampSendChat("/prefix " .. arg .. " Зам.Гл.Администратора " .. prefix_ZGAadm.v)
end  

function pradm5(arg)
	sampSendChat("/prefix " .. arg .. " Главный.Администратор " .. prefix_GAadm.v)
end  
-- выдача префиксов --

function tpcord(coords)
	local x, y, z = coords:match('(.+) (.+) (.+)') 
	setCharCoordinates(PLAYER_PED, x, y, z)
end  
-- телепортация по координатам

function tpad(arg)
	sampAddChatMessage(tag .. " Телепортация на административный остров.. ")
	setCharCoordinates(PLAYER_PED,3321,2308,35)
end
-- телепортация на админ-остров

function iddialog(arg)
	iddea = sampGetCurrentDialogId()
	sampAddChatMessage(tag .. "Диалог с ID: " .. iddea)
end
-- показ ID последнего/активного диалога

function delch(arg)
	notify.addNotify("{87CEEB}[AdminTool]", 'Визуальная очистка чата началась', 2, 1, 6)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
end
-- функция, отвечающая за очистку чата (визуал)

function cmd_tool(arg)
	one_window_state.v = not one_window_state.v
	imgui.Process = one_window_state.v
end
-- первоначальный интерфейс AdminTool

function cmd_toolmp(arg)
	two_window_state.v = not two_window_state.v
	imgui.Process = two_window_state.v
end
-- вспомогательный интерфейс AdminTool по MP

function cmd_toolfd(arg)
	three_window_state.v = not three_window_state.v
	imgui.Process = three_window_state.v
end
-- вспомогательный интерфейс AdminTool по flood

function cmd_toolans(arg)
	four_window_state.v = not four_window_state.v
	imgui.Process = four_window_state.v
end
-- вспомогательный интерфейс AdminTool по /ans

function cmd_tooladm(arg)
	five_window_state.v = not five_window_state.v	
	imgui.Process = five_window_state.v
end  
-- вспомогательный интерфейс AdminTool для старшей администрации

function color() -- функция, выполняющая рандомнизацию и вывод рандомного цвета с помощью специального os.time()
	mcolor = "{"
	math.randomseed( os.time() )
	for i = 1, 6 do
		local b = math.random(1, 16)
		if b == 1 then
			mcolor = mcolor .. "A"
		end
		if b == 2 then
			mcolor = mcolor .. "B"
		end
		if b == 3 then
			mcolor = mcolor .. "C"
		end
		if b == 4 then
			mcolor = mcolor .. "D"
		end
		if b == 5 then
			mcolor = mcolor .. "E"
		end
		if b == 6 then
			mcolor = mcolor .. "F"
		end
		if b == 7 then
			mcolor = mcolor .. "0"
		end
		if b == 8 then
			mcolor = mcolor .. "1"
		end
		if b == 9 then
			mcolor = mcolor .. "2"
		end
		if b == 10 then
			mcolor = mcolor .. "3"
		end
		if b == 11 then
			mcolor = mcolor .. "4"
		end
		if b == 12 then
			mcolor = mcolor .. "5"
		end
		if b == 13 then
			mcolor = mcolor .. "6"
		end
		if b == 14 then
			mcolor = mcolor .. "7"
		end
		if b == 15 then
			mcolor = mcolor .. "8"
		end
		if b == 16 then
			mcolor = mcolor .. "9"
		end
	end
	--print(mcolor)
	mcolor = mcolor .. '}'
	return mcolor
end

function cmd_nba(arg)
	thread:run("nba")
end
-- запуск основной функции для набора администраторов

function cmd_dpv(arg)
	thread:run("dpv")
end  
-- запуск основной функции для вывода сообщений при проверке на читы

function cmd_arep(arg) 
	thread:run("arep")
end  
-- запуск основной функции для показателя репорта

function thread_function(opt)
	if opt == "dpv" then  
		sampSendChat("/gethere " .. arg)
		wait(1000)
		sampSendChat("/freeze " .. arg)
		wait(3000)
		sampSendChat("/d Проверка на читерское ПО. Выход - бан.")
		wait(3000)
		sampSendChat("/d Проверка на читерское ПО. ВК в /d чат.")
	end
	if opt == "nba" then 
		sampSendChat("/d Здравствуйте!")
		wait(3000)
		sampSendChat("/d Не желаете ли попробовать себя в роли администратора?")
	end
	if opt == "arep" then  
		sampSendChat("/a /ans -> отвечаем на репорт")
		wait(2500)
		sampSendChat("/a /ans -> отвечаем на репорт")
		wait(2500)
		sampSendChat("/a /ans -> отвечаем на репорт")
	end
	-- запуск замороженной/временной функции для набора администраторов
end	


-- function sampev.onSendClickTextDraw(id)
	-- sampAddChatMessage(tag .. " ID TextDraw: " .. id)
-- end

------- Функции, относящиеся к мутам -------
function cmd_fd1(arg)
	sampSendChat("/mute " .. arg .. " 120 " .. " Спам/Флуд")
end

function cmd_fd2(arg)
	sampSendChat("/mute " .. arg .. " 240 " .. " Спам/Флуд - x2 ")
end

function cmd_fd3(arg)
   sampSendChat("/mute " .. arg .. " 360 " .. " Спам/Флуд - x3 ")
end

function cmd_fd4(arg)
   sampSendChat("/mute " .. arg .. " 480 " .. " Спам/Флуд - x4 ")
end

function cmd_fd5(arg)
  sampSendChat("/mute " .. arg .. " 600 " .. " Спам/Флуд - x5 ")
end

function cmd_po1(arg)
	sampSendChat("/mute "  .. arg .. " 120 " .. " Попрошайничество")
end

function cmd_po2(arg)
	sampSendChat("/mute " .. arg .. " 240 " .. " Попрошайничество - x2")
end

function cmd_po3(arg)
	sampSendChat("/mute " .. arg .. " 360 " .. " Попрошайничество - x3")
end

function cmd_po4(arg)
	sampSendChat("/mute " .. arg .. " 480 " .. " Попрошайничество - x4")
end

function cmd_po5(arg)
	sampSendChat("/mute " .. arg .. " 600 " .. " Попрошайничество - x5")
end

function cmd_m(arg)
	sampSendChat("/mute " .. arg .. " 300 " .. " Нецензурная лексика")
end

function cmd_ia(arg)
	sampSendChat("/mute " ..  arg .. " 2500 " .. " Выдача себя за администрацию ")
end

function cmd_kl(arg)
	sampSendChat("/mute " .. arg .. " 3000 " .. " Клевета на администрацию ")
end

function cmd_oa(arg)
	sampSendChat("/mute " .. arg .. " 2500 " .. " Оскорбление/Унижение администратора")
end

function cmd_ok(arg)
	sampSendChat("/mute " .. arg .. " 400 " .. " Оскорбление/Унижение")
end

function cmd_nm1(arg)
	sampSendChat("/mute " .. arg .. " 2500 " .. " Неадекватное поведение ")
end

function cmd_nm2(arg)
	sampSendChat("/mute " .. arg .. " 5000 " ..  " Неадекватное поведение ")
end

function cmd_or(arg)
	sampSendChat("/mute " .. arg .. " 5000 " .. " Оскорбление/Унижение родных")
end

function cmd_nm(arg)
	sampSendChat("/mute " .. arg .. " 900 " .. " Неадекватное поведение ")
end

function cmd_up(arg)
	sampSendChat("/mute " .. arg .. " 1000 " .. " Упоминание сторонних проектов ")
end
------- Функции, относящиеся к мутам -------


------- Функции, относящиеся к мутам за репорт -------
function cmd_rup(arg)
	sampSendChat("/rmute " .. arg .. " 1000 " .. " Упоминание сторонних проектов. ")
  end
 
function cmd_ror(arg)
	sampSendChat("/rmute " .. arg .. " 5000 " .. " Оскорбление/Унижение родных ")
end
  
function cmd_cp(arg)
	sampSendChat("/rmute " .. arg .. " 120 " .. " caps/offtop in report ")
end
  
function cmd_rpo(arg)
	sampSendChat("/rmute " .. arg .. " 120 " .. " Попрошайничество ")
end

function cmd_rm(arg)
	sampSendChat("/rmute " .. arg .. " 300 " .. " Нецензурная лексика ")
end

function cmd_roa(arg)
	sampSendChat("/rmute " .. arg .. " 2500 " .. " Оскорбление/Унижение администратора ")
end

function cmd_rnm(arg)
  sampSendChat("/rmute " .. arg .. " 900 " .. " Неадекватное поведение ")
end

function cmd_rnm1(arg)
  sampSendChat("/rmute " .. arg .. " 2500 " .. " Неадекватное поведение ")
end

function cmd_rnm2(arg)
  sampSendChat("/rmute " .. arg .. " 5000 " ..  " Неадекватное поведение ")
end

function cmd_rok(arg)
	sampSendChat("/rmute " .. arg .. " 400 " .. " Оскорбление/Унижение ")
end
------- Функции, относящиеся к мутам за репорт -------





------- Функции, относящиеся к джайлам -------
function cmd_sk(arg)
	sampSendChat("/jail " .. arg .. " 300 " .. " Spawn Kill")
end

function cmd_dz(arg)
	sampSendChat("/jail " .. arg .. " 300 " .. " DM/DB in zz")
end

function cmd_dz1(arg)
	sampSendChat("/jail " .. arg .. " 600 " .. " DM/DB in zz x2")
end

function cmd_dz2(arg)
	sampSendChat("/jail " .. arg .. " 900 " .. " DM/DB in zz x3")
end

function cmd_dz3(arg)
	sampSendChat("/jail " .. arg .. " 1200 " .. " DM/DB in zz x4")
end

function cmd_td(arg)
	sampSendChat("/jail " .. arg .. " 300 " .. " DB/car in trade ")
end

function cmd_jm(arg)
	sampSendChat("/jail " .. arg .. " 300 " .. " Нарушение правил МП ")
end

function cmd_pmx(arg)
	sampSendChat("/jail " .. arg .. " 300 " .. " Серьезная помеха игрокам ")
end

function cmd_skw(arg)
  sampSendChat("/jail " .. arg .. " 600 " .. " SK in /gw ")
end

function cmd_dgw(arg)
  sampSendChat("/jail " .. arg .. " 500 " .. " Использование наркотиков in /gw ")
end

function cmd_ngw(arg)
	sampSendChat("/jail " .. arg .. " 600 " .. " Использование запрещенных команд in /gw ")
end

function cmd_dbgw(arg)
	sampSendChat("/jail " .. arg .. " 600 " .. " Использование вертолета in /gw ")
end

function cmd_fsh(arg)
	sampSendChat("/jail " .. arg .. " 900 " .. " Использование SpeedHack/FlyCar ")
end

function cmd_bag(arg)
	sampSendChat("/jail " .. arg .. " 300 " .. " Игровой багоюз (deagle in car)")
end

function cmd_pk(arg)
  	sampSendChat("/jail " .. arg .. " 900 " .. " Использование паркур/дрифт мода ")
end

function cmd_jch(arg)
	sampSendChat("/jail " .. arg .. " 3000 " .. " Использование читерского скрипта/ПО ")
end

function cmd_zv(arg)
	sampSendChat("/jail " ..  arg .. " 3000 " .. " Злоупотребление VIP`om ")
end

function cmd_sch(arg)
	sampSendChat("/jail " .. arg .. " 900 " .. " Использование запрещенных скриптов ")
end

function cmd_jcw(arg)
	sampSendChat("/jail " .. arg .. " 900 " .. " Использование ClickWarp/Metla (ИЧС)")
end
------- Функции, относящиеся к джайлам -------


------- Функции, относящиеся к банам -------
function cmd_hl(arg)
	sampSendChat("/ans " .. arg .. " Уважаемый игрок, вы нарушали правила сервера, и если вы..")
	sampSendChat("/ans " .. arg .. " ..не согласны с наказанием, напишите жалобу в VK: dmdriftgta")
	sampSendChat("/iban " .. arg .. " 3 " .. " Оскорбление/Унижение/Мат в хелпере")
end

function cmd_pl(arg)
	sampSendChat("/ans " .. arg .. " Уважаемый игрок, вы нарушали правила сервера, и если вы..")
  	sampSendChat("/ans " .. arg .. " ..не согласны с наказанием, напишите жалобу в VK: dmdriftgta")
  	sampSendChat("/ban " .. arg .. " 7 " .. " Плагиат ника администратора ")
end

function cmd_ob(arg)
	sampSendChat("/ans " .. arg .. " Уважаемый игрок, вы нарушали правила сервера, и если вы..")
	sampSendChat("/ans " .. arg .. " ..не согласны с наказанием, напишите жалобу в VK: dmdriftgta")
	sampSendChat("/iban " .. arg .. " 7 " .. " Обход прошлого бана ")
end 	

function cmd_ch(arg)
	sampSendChat("/ans " .. arg .. " Уважаемый игрок, вы нарушали правила сервера, и если вы..")
  	sampSendChat("/ans " .. arg .. " ..не согласны с наказанием, напишите жалобу в VK: dmdriftgta")
	sampSendChat("/iban " .. arg .. " 7 " .. " Использование читерского скрипта/ПО. ")
end

function cmd_gcnk(arg)
	sampSendChat("/ans " .. arg .. " Уважаемый игрок, вы нарушали правила сервера, и если вы..")
 	sampSendChat("/ans " .. arg .. " ..не согласны с наказанием, напишите жалобу в VK: dmdriftgta")
	sampSendChat("/iban " .. arg .. " 7 " .. " Банда, содержащая нецензурную лексину ")
end

function cmd_nk(arg)
	sampSendChat("/ans " .. arg .. " Уважаемый игрок, вы нарушали правила сервера, и если вы..")
 	sampSendChat("/ans " .. arg .. " ..не согласны с наказанием, напишите жалобу в VK: dmdriftgta")
	sampSendChat("/ban " .. arg .. " 7 " .. " Ник, содержащий нецензурную лексику ")
end


------- Функции, относящиеся к банам -------

------- Функции, относящиеся к джайлам в оффлайне -------

function cmd_asch(arg)
	sampSendChat("/prisonakk " .. arg .. " 900 " .. " Использование запрещенных скриптов ")
end

function cmd_ajch(arg)
	sampSendChat("/prisonakk " .. arg .. " 3000 " .. " Использование читерского скрипта/ПО ")
end

function cmd_azv(arg)
	sampSendChat("/prisonakk " ..  arg .. " 3000 " .. " Злоупотребление VIP`om ")
end

function cmd_adgw(arg)
	sampSendChat("/prisonakk " .. arg .. " 500 " .. " Использование наркотиков in /gw ")
end

function cmd_ask(arg)
	sampSendChat("/prisonakk " .. arg .. " 300 " .. " Spawn Kill in zz ")
end

function cmd_adz(arg)
	sampSendChat("/prisonakk " .. arg .. " 300 " .. " DM/DB in zz ")
end

function cmd_adz1(arg)
	sampSendChat("/prisonakk " .. arg .. " 600 " .. " DM/DB in zz x2")
end

function cmd_adz2(arg)
	sampSendChat("/prisonakk " .. arg .. " 900 " .. " DM/DB in zz x3")
end

function cmd_adz3(arg)
	sampSendChat("/prisonakk " .. arg .. " 1200 " .. " DM/DB in zz x4")
end

function cmd_atd(arg)
	sampSendChat("/prisonakk " .. arg .. " 300 " .. " DB/car in trade ")
end

function cmd_ajm(arg)
	sampSendChat("/prisonakk " .. arg .. " 300 " .. " Нарушение правил МП ")
end

function cmd_apmx(arg)
	sampSendChat("/prisonakk " .. arg .. " 300 " .. " Серьезная помеха игрокам ")
end

function cmd_askw(arg)
    sampSendChat("/prisonakk " .. arg .. " 600 " .. " SK in /gw ")
end

function cmd_angw(arg)
    sampSendChat("/prisonakk " .. arg .. " 600 " .. " Использование запрещенных команд in /gw ")
end

function cmd_adbgw(arg)
    sampSendChat("/prisonakk " .. arg .. " 600 " .. " db-верт, стрельба с авт/мото/крыши in /gw ")
end

function cmd_afsh(arg)
    sampSendChat("/prisonakk " .. arg .. " 900 " .. " Использование SpeedHack/FlyCar ")
end

function cmd_abag(arg)
    sampSendChat("/prisonakk " .. arg .. " 300 " .. " Игровой багоюз (deagle in car)")
end

function cmd_apk(arg)
	sampSendChat("/prisonakk " .. arg .. " 900 " .. " Использование паркур/дрифт мода ")
end

function cmd_ajcw(arg)
	sampSendChat("/prisonakk " .. arg .. " 900 " .. " Использование ClickWarp/Metla (ИЧС)")
end
------- Функции, относящиеся к джайлам в оффлайне -------


------- Функции, относящиеся к мутам в оффлайне -------
function cmd_afd(arg)
	sampSendChat("/muteakk " .. arg .. " 120 " .. " Спам/Флуд")
end

function cmd_apo(arg)
	sampSendChat("/muteakk " .. arg .. " 120 " .. " Попрошайничество ")
end

function cmd_am(arg)
	sampSendChat("/muteakk " .. arg .. " 300 " .. " Нецензурная лексика")
end

function cmd_aok(arg)
	sampSendChat("/muteakk " .. arg .. " 400 " .. " Оскорбление/Унижение ")
end

function cmd_anm(arg)
	sampSendChat("/muteakk " .. arg .. " 900 " .. " Неадекватное поведение ")
end

function cmd_anm1(arg)
	sampSendChat("/muteakk " .. arg .. " 2500 " .. " Неадекватное поведение ")
end

function cmd_anm2(arg)
	sampSendChat("/muteakk " .. arg .. " 5000 " .. " Неадекватное поведение ")
end

function cmd_aoa(arg)
	sampSendChat("/muteakk " .. arg .. " 2500 " .. " Оскорбление/Унижение админа ")
end

function cmd_aor(arg)
	sampSendChat("/muteakk " .. arg .. " 5000 " .. " Оскорбление/Унижение/Упоминание родных ")
end

function cmd_aup(arg)
	sampSendChat("/muteakk " .. arg .. " 1000 " .. " Упоминание иного проекта ")
end 

function cmd_aia(arg)
	sampSendChat("/muteakk " .. arg .. " 2500 " .. " Выдача себя за администратора ")
end

function cmd_akl(arg)
	sampSendChat("/muteakk " .. arg .. " 3000 " .. " Клевета на администрацию ")
end
------- Функции, относящиеся к мутам в оффлайне -------


------- Функции, относящиеся к кикам -------
function cmd_dj(arg)
	sampSendChat("/kick " .. arg .. " dm in jail ")
end

function cmd_gnk1(arg)
	sampSendChat("/kick " .. arg .. " Смените никнейм. 1/3 ")
end

function cmd_gnk2(arg)
	sampSendChat("/kick " .. arg .. " Смените никнейм. 2/3 ")
end

function cmd_gnk3(arg)
	sampSendChat("/kick " .. arg .. " Смените никнейм. 3/3 ")
end

function cmd_cafk(arg)
	sampSendChat("/kick " .. arg .. " AFK in /arena ")
end
------- Функции, относящиеся к кикам -------


-------- Функции, относящиеся к банам в оффлайне -----------

function cmd_ahl(arg)
	sampSendChat("/offban " .. arg .. " 3 " .. " Оск/Унижение/Мат в хелпере")
	sampSendChat("/offstats " .. arg)
end

function cmd_ahli(arg)
	sampSendChat("/banip " .. arg .. " 3 " .. " Оск/Унижение/Мат в хелпере")
end

function cmd_aob(arg)
	sampSendChat("/offban " .. arg .. " 7 " .. " Обход бана ")
	sampSendChat("/offstats " .. arg)
end

function cmd_apl(arg)
	sampSendChat("/offban " .. arg .. " 7 " .. " Плагиат никнейма администратора")
end

function cmd_ach(arg)
	sampSendChat("/offban " .. arg .. " 7 " .. "  Использование читерского скрипта/ПО ")
	sampSendChat("/offstats " .. arg)
end

function cmd_achi(arg)
	sampSendChat("/banip " .. arg .. " 7 " .. " ИЧС/ПО (ip) ") 
end

function cmd_ank(arg)
	sampSendChat("/banakk " .. arg .. " 7 " .. " Ник, содержащий нецензурщину ")
end

function cmd_agcnk(arg)
	sampSendChat("/banakk " .. arg .. " 7 " .. " Банда, содержит нецензурщину")
	sampSendChat("/offstats " .. arg)
end

function cmd_agcnkip(arg)
	sampSendChat("/banip " .. arg .. " 7 "  .. " Банда, содержит нецензурщину (ip)")
end

function cmd_okpr(arg)
	sampSendChat("/banakk " .. arg .. " 30 " .. " Оскорбление в сторону проекта. ")
	sampSendChat("/offstats " .. arg)
end

function cmd_okprip(arg)
	sampSendChat("/banip " .. arg .. " 30 " .. " Оскорбление в сторону проекта. ")
end

function cmd_svocakk(arg)
	sampSendChat("/banakk " .. arg .. " 999 " .. " Реклама иного сервера/проекта ")
	sampSendChat("/offstats " .. arg)
end

function cmd_svocip(arg)
	sampSendChat("/banip " .. arg .. " 999 " .. " Реклама иного сервера/проекта ")
end

function cmd_rdsob(arg)
	sampSendChat("/banakk " .. arg .. " 30 " .. " Обман администрации/игроков")
end	
function cmd_rdsip(arg)
	sampSendChat("/banip " .. arg .. " 30 " .. " Обман администрации/игроков")
end	
-------- Функции, относящиеся к банам в оффлайне -----------


------- Функции, относящиеся к быстрым ответам -------
function cmd_tcm(arg)
	sampSendChat("/ans " .. arg .. " Чтобы обменять валюту, введите /trade, и подойдите к NPC Арману, стоит справа ")
end 

function cmd_tm(arg)
	sampSendChat("/ans " .. arg .. " Ожидайте. | Приятного времяпрепровождения на RDS <3 ")
end

function cmd_zsk(arg)
	sampSendChat("/ans " .. arg .. " Если вы застряли, введите /spawn | /kill, но мы можем вам помочь! ")
end

function cmd_vgf(arg)
	sampSendChat("/ans " .. arg .. " Чтобы выдать выговор участнику банды, есть команда: /gvig ")
end

function cmd_html(arg)
	sampSendChat("/ans ".. arg .. " https://colorscheme.ru/html-colors.html | Приятной игры! ")
end

function cmd_ktp(arg)
	sampSendChat("/ans " .. arg .. " /tp (по локациям), /g (/goto) id (к игроку) с VIP (/help -> 7 пункт) ")
end

function cmd_vp1(arg)
	sampSendChat("/ans " .. arg .. " Данный игрок с привелегией Premuim VIP (/help -> 7)  | Приятной игры! <3 ")
end

function cmd_vp2(arg)
	sampSendChat("/ans " .. arg .. " Данный игрок с привелегией Diamond VIP (/help -> 7) | Приятной игры! <3 ")
end

function cmd_vp3(arg)
	sampSendChat("/ans " .. arg .. " Данный игрок с привелегией Platinum VIP (/help -> 7) | Приятной игры! <3 ")
end

function cmd_vp4(arg)
	sampSendChat("/ans " .. arg .. " Данный игрок с привелегией «Личный» VIP (/help -> 7) | Приятной игры! <3 ")
end

function cmd_chap(arg)
	sampSendChat("/ans " .. arg .. " /mm -> Действия -> Сменить пароль | Приятной игры! <3 ")
end

function cmd_msp(arg)
	sampSendChat("/ans " .. arg .. " /mm -> Транспортное средство -> Тип транспорта | Приятной игры на RDS. <3 ")
end

function cmd_trp(arg)
	sampSendChat("/ans " .. arg .. " /report | Приятной игры на RDS. <3 ")
end

function cmd_rid(arg)
	sampSendChat("/ans " .. arg .. " Уточните ID нарушителя/читера в /report | Удачного времяпрепровождения. ")
end

function cmd_bk(arg)
	sampSendChat("/ans " .. arg .. " Оплатить бизнес/дом можно с помощью /bank или /tp -> Разное -> Банк ")
end

function cmd_h7(arg)
	sampSendChat("/ans " .. arg .. " Посмотреть информацию можно в /help -> 7 пункт. | Приятной игры на RDS. <3 ")
end

function cmd_h8(arg)
	sampSendChat("/ans " .. arg .. " Узнать данную информацию можно в /help -> 8 пункт. | Приятной игры на RDS. <3 ")
end

function cmd_h13(arg)
	sampSendChat("/ans " .. arg .. " Узнать данную информацию можно в /help -> 13 пункт. | Приятной игры на RDS. <3 ")
end

function cmd_zba(arg)
	sampSendChat("/ans " .. arg .. " Админ наказал не так? Пишите жалобу в группу https://vk.com/dmdriftgta")
end

function cmd_zbp(arg)
	sampSendChat("/ans " .. arg .. " Пишите жалобу на игрока в группу https://vk.com/dmdriftgta")
end

function cmd_avt(arg)
	sampSendChat("/ans " .. arg .. " /tp -> Разное -> Автосалоны | Приятной игры!")
end

function cmd_avt1(arg)
 sampSendChat("/ans " .. arg .. " /tp -> Разное -> Автосалоны -> Автомастерская | Приятной игры!")
end

function cmd_pgf(arg)
	sampSendChat("/ans " .. arg .. " /gleave (банда) || /fleave (семья)| Приятной игры на RDS <3")
end

function cmd_lgf(arg)
	sampSendChat("/ans " .. arg .. " /leave (покинуть мафию) | Приятной игры на RDS <3")
end

function cmd_igf(arg)
	sampSendChat("/ans " .. arg .. " /ginvite (банда) || /finvite (семья) | Удачной игры на RDS <3" )
end

function cmd_ugf(arg)
	sampSendChat("/ans " .. arg .. " /guninvite (банда) || /funinvite (семья) | Удачной игры на RDS <3 ")
end

function cmd_cops(arg)
	sampSendChat("/ans " .. arg .. " 265-267, 280-286, 288, 300-304, 306, 307, 309-311 | Удачной игры на RDS <3")
end

function cmd_bal(arg)
	sampSendChat("/ans " .. arg .. "  102-104 | Удачной игры на RDS <3")
end

function cmd_cro(arg)
	sampSendChat("/ans " .. arg .. " 105-107 | Удачной игры на RDS <3")
end

function cmd_rumf(arg)
	sampSendChat("/ans " .. arg .. " 111-113 | Удачной игры на RDS <3")
end

function cmd_vg(arg)
	sampSendChat("/ans " .. arg .. " 108-110 | Удачной игры на RDS <3 ")
end

function cmd_var(arg)
	sampSendChat("/ans " .. arg .. " 114-116 | Удачной игры на RDS <3")
end

function cmd_triad(arg)
	sampSendChat("/ans " .. arg .. " 117-118, 120  | Удачной игры на RDS <3")
end

function cmd_mf(arg)
	sampSendChat("/ans " .. arg .. " 124-127 | Удачной игры на RDS <3")
end

function cmd_gvm(arg)
	sampSendChat("/ans " .. arg .. " Для перевода денег, необхдимо ввести /givemoney IDPlayer сумму | Приятной игры!' ")
end

function cmd_gvs(arg)
	sampSendChat("/ans " .. arg .. " Для перевода очков, необходимо ввести /givescore IDPlayer сумму | С Diamond VIP. ")
end

function cmd_cpt(arg)
	sampSendChat("/ans " .. arg .. " Для того, чтобы начать капт, нужно ввести /capture | Приятной игры! ")
end

function cmd_psv(arg)
	sampSendChat("/ans " .. arg .. " /passive - пассивный режим, для того, чтобы вас не могли убить.  ")
end

function cmd_dis(arg)
	sampSendChat("/ans " ..  arg .. " Игрок не в сети. | Приятной игры на RDS <3 ")
end

function cmd_nac(arg)
	sampSendChat("/ans " .. arg .. " Игрок наказан. | Приятной игры на RDS <3")
end

function cmd_cl(arg)
	sampSendChat("/ans " .. arg .. " Данный игрок чист. | Приятной игры на RDS <3")
end

function cmd_yt(arg)
	sampSendChat("/ans " .. arg .. " Уточните ваш запрос/вопрос. | Приятной игры на RDS <3")
end

function cmd_drb(arg)
	sampSendChat("/ans " .. arg .. " /derby - записатся на дерби | Приятной игры на RDS 02 <3 ")
end

function cmd_smc(arg)
	sampSendChat("/ans " .. arg .. " /sellmycar IDPlayer Слот(1-3) RDScoin (игроку), в гос: /car ")
end

function cmd_c(arg)
	sampSendChat("/ans " .. arg .. " Начал(а) работу по вашей жалобе. | Приятной игры на RDS <3")
end

function cmd_stp(arg)
	sampSendChat("/ans " .. arg .. " Чтобы посмотреть коины, вирты, рубли и т.д. - /statpl ")
end

function cmd_prk(arg)
	sampSendChat("ans ".. arg .. " /parkour - записатся на паркур | Приятной игры на RDS 02 <3 ")
end

function cmd_n(arg)
	sampSendChat("/ans " .. arg .. " Не вижу нарушений от игрока. | Приятной игры на RDS <3")
end

function cmd_hg(arg)
	sampSendChat("/ans " .. arg .. " Помогли вам. | Приятного времяпрепровождения на RDS <3 ")
end

function cmd_int(arg)
	sampSendChat("/ans " .. arg .. " Данную информацию можно узнать в интернете. Приятной игры! ")
end

function cmd_og(arg)
	sampSendChat("/ans " .. arg ..  'Встать на пикап "Ограбление банка", после около ячеек нажимать на ALT и ехать на красный маркер на карте')
end

function cmd_msid(arg)
	sampSendChat("/ans " .. arg .. " Здравствуйте! Произошла ошибка в ID! Наказание снято. ")
	sampSendChat("/ans " .. arg .. " Приятного времяпрепровождения на Russian Drift Server! ")
end

function cmd_al(arg)
	sampSendChat("/ans " .. arg .. " Здравствуйте! Вы забыли ввести /alogin! ")
	sampSendChat("/ans " .. arg .. " Введите команду /alogin и свой пароль, пожалуйста.")
end

function cmd_gfi(arg)
	sampSendChat("/ans " .. arg .. " /funinvite id (в семью), /ginvite id (в банду) ")
end

function cmd_hin(arg)
	sampSendChat("/ans " .. arg .. ' /hpanel -> Слот1-3 -> Изменить -> Аренда дома | Приятной игры на RDS <3 ')
end

function cmd_gn(arg)
	sampSendChat("/ans " .. arg .. " /menu (/mm) - ALT/Y -> Оружие | Удачного времяпреповождения")
end

function cmd_pd(arg)
	sampSendChat("/ans " .. arg .. " /menu (/mm) - ALT/Y -> Предметы | Удачного времяпреповождения")
end

function cmd_dtl(arg)
	sampSendChat("/ans " .. arg .. " Детали разбросаны по всей карте. Обмен происходится на /garage. | Удачного времяпреповождения")
end

function cmd_nz(arg)
	sampSendChat("/ans " .. arg .. " Не запрещено. | Удачного времяпреповождения")
end

function cmd_y(arg)
	sampSendChat("/ans " .. arg .. " Да. | Удачного времяпреповождения")
end

function cmd_net(arg)
	sampSendChat("/ans " .. arg .. " Нет. | Удачного времяпреповождения")
end

function cmd_gak(arg)
	sampSendChat("/ans" .. arg .. " Продать аксессуары, или купить можно на /trade. Чтобы продать, /sell около лавки ")
end

function cmd_enk(arg)
	sampSendChat("/ans " .. arg .. " Никак. | Удачного времяпреповождения")
end

function cmd_fp(arg)
	sampSendChat("/ans " .. arg .. " /familypanel | Удачного времяпреповождения")
end

function cmd_mg(arg)
	sampSendChat("/ans " .. arg .. " /menu (/mm) - ALT/Y -> Система банд | Удачного времяпреповождения")
end

function cmd_pg(arg)
	sampSendChat("/ans " .. arg .. " Проверим. | Удачного времяпреповождения")
end

function cmd_krb(arg)
	sampSendChat("/ans " .. arg .. " Казино, работы, бизнес. | Удачного времяпреповождения")
end

function cmd_kmd(arg)
	sampSendChat("/ans " .. arg .. " Казино, МП, достижения, работы, обмен очков на коины(/trade) | Приятной игры на RDS <3")
end

function cmd_gm(arg)
	sampSendChat("/ans " .. arg .. " GodMode (ГодМод) на сервере не работает. | Удачного времяпреповождения")
end

function cmd_plg(arg)
	sampSendChat("/ans " .. arg .. " Попробуйте перезайти. | Удачного времяпреповождения")
end

function cmd_nv(arg)
	sampSendChat("/ans " .. arg .. " Не выдаем. | Удачного времяпреповождения")
end

function cmd_of(arg)
	sampSendChat("/ans " .. arg .. " Не оффтопьте. | Удачного времяпреповождения")
end

function cmd_en(arg)
	sampSendChat("/ans " .. arg .. " Не знаем. | Удачного времяпреповождения")
end

function cmd_vbg(arg)
	sampSendChat("/ans " .. arg .. " Скорей всего - это баг. | Удачного времяпреповождения")
end

function cmd_ctun(arg)
	sampSendChat("/ans " .. arg .. ' /menu (/mm) - ALT/Y -> Т/С -> Тюнинг | Приятной игры на RDS <3')
end

function cmd_cr(arg)
	sampSendChat("/ans " .. arg .. ' /car | Приятной игры на сервере RDS <3 ')
end

function cmd_zsk(arg)
	sampSendChat("/ans " .. arg .. " Если вы застряли, введите /spawn | /kill | Приятной игры на RDS <3")
end

function cmd_smh(arg)
	sampSendChat("/ans " .. arg .. " /sellmyhouse (игроку)  ||  /hpanel -> слот -> Изменить -> Продать дом государству ")
end

function cmd_gadm(arg)
	sampSendChat("/ans " .. arg .. " Ожидать набор, или же /help -> 17 пункт. | Приятной игры на RDS. <3")
end

function cmd_hct(arg)
	sampSendChat("/ans " .. arg .. " /count time || /dmcount time | Приятной игры на RDS. <3 ")
end

function cmd_gvr(arg)
	sampSendChat("/ans " .. arg .. " /giverub IDPlayer rub | С Личного (/help -> 7) | Приятной игры!")
end

function cmd_gvc(arg)
	sampSendChat("/ans " .. arg .. " /givecoin IDPlayer coin | С Личного (/help -> 7) | Приятной игры!")
end

function cmd_tdd(arg)
	sampSendChat("/ans " .. arg .. " /dt 0-990 / Виртуальный мир | Приятной игры!")
end
------- Функции, относящиеся к быстрым ответам -------


------ Функции, используемые в вспомогательных случаях -------

function cmd_u(arg)
	sampSendChat("/unmute " .. arg)
end  

function cmd_uu(arg)
	sampSendChat("/unmute " .. arg)
	sampSendChat("/ans " .. arg .. " Извиняемся за ошибку, наказание снято. Приятной игры")
end

function cmd_stw(arg)
	sampSendChat("/setweap " .. arg .. " 38 5000 ")
end  

function cmd_as(arg)
	sampSendChat("/aspawn " .. arg)
end

function cmd_ru(arg)
	sampSendChat("/rmute " .. arg .. " 5 " .. "  Mistake/Ошибка")
	sampSendChat("/ans " .. arg .. " Извиняемся за ошибку, наказание снято. Приятной игры.")
end

------ Функции, используемые в вспомогательных случаях -------


----------------- Раздел отвечающий за показ уведомлений -------------------------
	function cmd_notify(arg)
		notify.addNotify("{87CEEB}[AdminTool]", 'Шаблон \n для шаблона', 2, 1, 6)
	end 
----------------- Раздел отвечающий за показ уведомлений -------------------------


------------------- Раздел отвечающий за чтение/запись ChatLogger ------------------------
function readChatlog()
	local file_check = assert(io.open(getWorkingDirectory() .. "\\config\\AdminTool\\chatlog\\" .. os.date("!*t").day .. "-" .. os.date("!*t").month .. "-" .. os.date("!*t").year .. ".txt", "r"))
	local t = file_check:read("*all")
	sampAddChatMessage(tag .. " Чтение файла. ", -1)
	file_check:close()
	t = t:gsub("{......}", "")
	local final_text = {}
	final_text = string.split(t, "\n")
	sampAddChatMessage(tag .. " Файл прочитан. ", -1)
		return final_text
end

function loadChatLog()
	wait(6000)
	accept_load_clog = true
end

function  getFileName()
    if not doesFileExist(getWorkingDirectory() .. "\\config\\AdminTool\\chatlog\\" .. os.date("!*t").day .. "-" .. os.date("!*t").month .. "-" .. os.date("!*t").year .. ".txt") then
        f = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\chatlog\\" .. os.date("!*t").day .. "-" .. os.date("!*t").month .. "-" .. os.date("!*t").year .. ".txt","w")
        f:close()
        file = string.format(getWorkingDirectory() .. "\\config\\AdminTool\\chatlog\\" .. os.date("!*t").day .. "-" .. os.date("!*t").month .. "-" .. os.date("!*t").year .. ".txt")
        return file
    else
        file = string.format(getWorkingDirectory() .. "\\config\\AdminTool\\chatlog\\" .. os.date("!*t").day .. "-" .. os.date("!*t").month .. "-" .. os.date("!*t").year .. ".txt")
        return file  
    end
end
------------------- Раздел отвечающий за чтение/запись ChatLogger ------------------------


----------------- Функции, отвечающие за административный чат ----------------------------------
function sampev.onServerMessage(color, text)
	chatlog = io.open(getFileName(), "r+")
    chatlog:seek("end", 0);
	chatTime = "[" .. os.date("*t").hour .. ":" .. os.date("*t").min .. ":" .. os.date("*t").sec .. "] "
    chatlog:write(chatTime .. text .. "\n")
    chatlog:flush()
	chatlog:close()
	lc_lvl, lc_adm, lc_color, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] %((.+){(.+)}%) (.+)%[(%d+)%]: {FFFFFF}(.+)")

	

	local check_string = string.match(text, "[^%s]+")
	local check_string_2 = string.match(text, "[^%s]+")
	local _, check_mat_id, _, check_mat = string.match(text, "(.+)%((.+)%): {(.+)}(.+)")
	local reasons = {"/mute","/jail","/iban","/ban","/mpwin","/kick","/muteakk","/prisonakk","/banakk"}
	if lc_text ~= nil then
   		for k, v in ipairs(reasons) do
			if lc_text:match(v) ~= nil then
				ATadm_forms = lc_text .. " | " .. lc_nick
				notify.addNotify("{87CEEB}[AdminTool]", 'Обнаружена админ-форма\nДля принятия: /faccept ', 2, 1, 6)
				sampAddChatMessage(tag .. "Административная форма: ".. ATadm_forms)
				sampAddChatMessage(tag .. "Для принятия формы напишите /faccept")
				start_forms()
			break
			end
		end
    end	

	function start_forms()
			sampRegisterChatCommand('faccept', function()
				lua_thread.create(function()
				sampSendChat("/a [AT] Форма принята AdminTool`ом.")
				wait(900)
				sampSendChat("".. ATadm_forms)
				end)
			end)
	end


	if text:sub(1, 13) == '<AC-WARNING> ' then -- вызывается, когда появляется строка античита
		ac_string = text
	  end


	if setting_items.auto_mute_mat.v then
		if check_mat ~= nil and check_mat_id ~= nil and not isGamePaused() then
			local string_os = string.split(check_mat, " ")
			for i, value in ipairs(onscene) do
				for j, val in ipairs(string_os) do
					val = val:match("(%P+)")
					if val ~= nil then
						if value == string.rlower(val) then
							sampAddChatMessage(text, color)
							if not isGamePaused() and not isPauseMenuActive() then
								sampSendChat("/mute " .. check_mat_id .. " 300 " .. " Нецензурная лексика.")
								notify.addNotify("{87CEEB}[AdminTool]", 'Обнаружена нецензурная лексика!\nСкрипт выдал мут.\nЗапрещенное слово: {FFFFFF}' .. value .. '\n{FFFFFF}Ник нарушителя: {FFFFFF}' .. sampGetPlayerNickname(tonumber(check_mat_id)), 2, 1, 6)
							end
							break
							break
						end
					end
				end
			end
			return true
		end
	end
	
	if setting_items.Admin_chat.v and check_string ~= nil and string.find(check_string, "%[A%-(%d+)%]") ~= nil and string.find(text, "%[A%-(%d+)%] (.+) отключился") == nil then
		local lc_text_chat
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
		for i = admin_chat_lines.lines.v, 1, -1 do
			if i ~= 1 then
				ac_no_saved.chat_lines[i] = ac_no_saved.chat_lines[i-1]
			else
				ac_no_saved.chat_lines[i] = lc_text_chat
			end
		end
		return false
	elseif check_string == '(Жалоба/Вопрос)' and setting_items.Push_Report.v then
		notify.addNotify("{87CEEB}[AdminTool]", 'Поступил новый репорт.', 2, 1, 6)
		return true
	end
	if text == "Вы отключили меню при наблюдении" and setting_items.ranremenu.v then
		sampSendChat("/remenu")
		return false
	end
	if text == "Вы включили меню при наблюдении" then
		control_recon = true
		if recon_to_player then
			control_info_load = true
			accept_load = false
		end
		return false
	end
	if text == "Вы отключили меню при наблюдении" and not setting_items.ranremenu.v then
		control_recon = false
		return false
	end
	if text == "Игрок не в сети" and recon_to_player then
		recon_to_player = false
		notify.addNotify("{87CEEB}[AdminTool]", 'Игрок не в сети', 2, 1, 6)
		sampSendChat("/reoff")
	end
end
	function drawAdminChat()
		while true do
			if setting_items.Admin_chat.v then
				if admin_chat_lines.centered.v == 0 then
					for i = admin_chat_lines.lines.v, 1, -1 do
						if ac_no_saved.chat_lines[i] == nil then
							ac_no_saved.chat_lines[i] = " "
						end
						renderFontDrawText(font_ac, ac_no_saved.chat_lines[i], admin_chat_lines.X, admin_chat_lines.Y+((tonumber(font_size_ac.v) or 10)+5)*(admin_chat_lines.lines.v - i), join_argb(explode_samp_rgba(admin_chat_lines.color)))
					end
				elseif admin_chat_lines.centered.v == 1 then
				--x - renderGetFontDrawTextLength(font, text) / 2
					for i = admin_chat_lines.lines.v, 1, -1 do
						if ac_no_saved.chat_lines[i] == nil then
							ac_no_saved.chat_lines[i] = " "
						end
						renderFontDrawText(font_ac, ac_no_saved.chat_lines[i], admin_chat_lines.X - renderGetFontDrawTextLength(font_ac, ac_no_saved.chat_lines[i]) / 2, admin_chat_lines.Y+((tonumber(font_size_ac.v) or 10)+5)*(admin_chat_lines.lines.v - i), join_argb(explode_samp_rgba(admin_chat_lines.color)))
					end
				elseif admin_chat_lines.centered.v == 2 then
					for i = admin_chat_lines.lines.v, 1, -1 do
						if ac_no_saved.chat_lines[i] == nil then
							ac_no_saved.chat_lines[i] = " "
						end
						renderFontDrawText(font_ac, ac_no_saved.chat_lines[i], admin_chat_lines.X - renderGetFontDrawTextLength(font_ac, ac_no_saved.chat_lines[i]), admin_chat_lines.Y+((tonumber(font_size_ac.v) or 10)+5)*(admin_chat_lines.lines.v - i), join_argb(explode_samp_rgba(admin_chat_lines.color)))
					end
				end
			end
			wait(1)
		end
	end
----------------- Функции, отвечающие за административный чат ----------------------------------



------------------ Функции, отвечающие за перевод символов --------------------------------

function sampev.onSendChat(message)

	local id; trans_cmd = message:match("[^%s]+")
	if trans_cmd:find("%.(.+)") ~= nil  then
		trans_cmd = message:match("%.(.+)")
		sampSendChat("/" .. RusToEng(trans_cmd))
	end

end

function RusToEng(text)
    result = text == '' and nil or ''
    if result then
        for i = 0, #text do
            letter = string.sub(text, i, i)
            if letter then
                result = (letter:find('[А-Я/{/}/</>]') and string.upper(translate[string.rlower(letter)]) or letter:find('[а-я/,]') and translate[letter] or letter)..result
            end
        end
    end
    return result and result:reverse() or result
end


function string.rlower(s)
    s = s:lower()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:lower()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 192 and ch <= 223 then -- upper russian characters
            output = output .. russian_characters[ch + 32]
        elseif ch == 168 then -- Ё
            output = output .. russian_characters[184]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end

function string.rupper(s)
    s = s:upper()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:upper()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 224 and ch <= 255 then -- lower russian characters
            output = output .. russian_characters[ch - 32]
        elseif ch == 184 then -- ё
            output = output .. russian_characters[168]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end

function string.split(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            t[i] = str
            i = i + 1
    end
    return t
end
------------------ Функции, отвечающие за перевод символов --------------------------------


------ Функции, отвечающие за RGB-color ----------
	function join_argb(a, r, g, b)
		local argb = b  -- b
		argb = bit.bor(argb, bit.lshift(g, 8))  -- g
		argb = bit.bor(argb, bit.lshift(r, 16)) -- r
		argb = bit.bor(argb, bit.lshift(a, 24)) -- a
		return argb
	end
	  function explode_argb(argb)
		local a = bit.band(bit.rshift(argb, 24), 0xFF)
		local r = bit.band(bit.rshift(argb, 16), 0xFF)
		local g = bit.band(bit.rshift(argb, 8), 0xFF)
		local b = bit.band(argb, 0xFF)
		return a, r, g, b
	end
	  function explode_samp_rgba(rgba)
		local b = bit.band(bit.rshift(rgba, 24), 0xFF)
		local r = bit.band(bit.rshift(rgba, 16), 0xFF)
		local g = bit.band(bit.rshift(rgba, 8), 0xFF)
		local a = bit.band(rgba, 0xFF)
		return a, r, g, b
	end
------ Функции, отвечающие за RGB-color ----------


-------------- Функции, отвечающие за WH ----------------

function cmd_wh()
	if control_wallhack then
		sampAddChatMessage(tag .."WallHack был выключен.")
		nameTagOff()
		control_wallhack = false
	else
		sampAddChatMessage(tag .."WallHack был включен.")
		nameTagOn()
		control_wallhack = true
	end
end


function convert3Dto2D(x, y, z)
	local result, wposX, wposY, wposZ, w, h = convert3DCoordsToScreenEx(x, y, z, true, true)
	local fullX = readMemory(0xC17044, 4, false)
	local fullY = readMemory(0xC17048, 4, false)
	wposX = wposX * (640.0 / fullX)
	wposY = wposY * (448.0 / fullY)
	return result, wposX, wposY
end

function getBodyPartCoordinates(id, handle)
	local pedptr = getCharPointer(handle)
	local vec = ffi.new("float[3]")
	getBonePosition(ffi.cast("void*", pedptr), vec, id, true)
	return vec[0], vec[1], vec[2]
  end

function drawWallhack()
	local peds = getAllChars()
	local _, pid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	while true do
		wait(10)
		for i = 0, sampGetMaxPlayerId() do
			if sampIsPlayerConnected(i) and control_wallhack then
				local result, cped = sampGetCharHandleBySampPlayerId(i)
				local color = sampGetPlayerColor(i)
				local aa, rr, gg, bb = explode_argb(color)
				local color = join_argb(255, rr, gg, bb)
				if result then
					if doesCharExist(cped) and isCharOnScreen(cped) then
						local t = {3, 4, 5, 51, 52, 41, 42, 31, 32, 33, 21, 22, 23, 2}
						for v = 1, #t do
							pos1X, pos1Y, pos1Z = getBodyPartCoordinates(t[v], cped)
							pos2X, pos2Y, pos2Z = getBodyPartCoordinates(t[v] + 1, cped)
							pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
							pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
							renderDrawLine(pos1, pos2, pos3, pos4, 1, color)
						end
						for v = 4, 5 do
							pos2X, pos2Y, pos2Z = getBodyPartCoordinates(v * 10 + 1, cped)
							pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
							renderDrawLine(pos1, pos2, pos3, pos4, 1, color)
						end
						local t = {53, 43, 24, 34, 6}
						for v = 1, #t do
							posX, posY, posZ = getBodyPartCoordinates(t[v], cped)
							pos1, pos2 = convert3DCoordsToScreen(posX, posY, posZ)
						end
					end
				end
			end
		end
	end
end

function nameTagOn()
	local pStSet = sampGetServerSettingsPtr();
	NTdist = mem.getfloat(pStSet + 39)
	NTwalls = mem.getint8(pStSet + 47)
	NTshow = mem.getint8(pStSet + 56)
	mem.setfloat(pStSet + 39, 1488.0)
	mem.setint8(pStSet + 47, 0)
	mem.setint8(pStSet + 56, 1)
	nameTag = true
end
function nameTagOff()
	local pStSet = sampGetServerSettingsPtr();
	mem.setfloat(pStSet + 39, NTdist)
	mem.setint8(pStSet + 47, NTwalls)
	mem.setint8(pStSet + 56, NTshow)
	nameTag = false
end

-------------- Функции, отвечающие за WH ----------------


------------- Функции, отвечающие за RE_MENU ---------------
function sampev.onTextDrawSetString(id, text)
	if id == 2078 and setting_items.ranremenu.v then
		player_info = textSplit(text, "~n~")
	end
end

--function show()
--	toggle = not toggle
--end

function sampev.onShowTextDraw(id, data)
	if (id >= 3 and id <= 54 or id == 228 or id == 2078 or id == 266 or id == 2050 or id == 21) and setting_items.ranremenu.v then
		return false
	end
end
function loadPlayerInfo()
	wait(3000)
	accept_load = true
end
------------- Функции, отвечающие за RE_MENU ---------------


-------------- Функции, отвечающие за перехват ID ------------------
function playersToStreamZone()
	local peds = getAllChars()
	local streaming_player = {}
	local _, pid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	for key, v in pairs(peds) do
		local result, id = sampGetPlayerIdByCharHandle(v)
		if result and id ~= pid and id ~= tonumber(control_recon_playerid) then
			streaming_player[key] = id
		end
	end
	return streaming_player
end

function sampev.onSendCommand(command)
	local id = string.match(command, "/re (%d+)")
	if id ~= nil and not check_cmd_re and setting_items.ranremenu.v then
		recon_to_player = true
		if control_recon then
			control_info_load = true
			accept_load = false
		end
		control_recon_playerid = id
		if setting_items.ranremenu.v then
			check_cmd_re = true
			sampSendChat("/re " .. id)
			check_cmd:run()
			sampSendChat("/remenu")
		end
	end
	if command == "/reoff" then
		recon_to_player = false
		check_mouse = false
		control_recon_playerid = -1
	end
end

function textSplit(str, delim, plain)
    local tokens, pos, plain = {}, 1, not (plain == false) --[[ delimiter is plain text by default ]]
    repeat
        local npos, epos = string.find(str, delim, pos, plain)
        table.insert(tokens, string.sub(str, pos, npos and npos - 1))
        pos = epos and epos + 1
    until not pos
    return tokens
end
-------------- Функции, отвечающие за перехват ID ------------------


------------- Функции, отвечающие за привязку/отвязку клавиш -----------------
function getDownKeys()
    local curkeys = ""
    local bool = false
    for k, v in pairs(vkeys) do
        if isKeyDown(v) and (v == VK_MENU or v == VK_CONTROL or v == VK_SHIFT or v == VK_LMENU or v == VK_RMENU or v == VK_RCONTROL or v == VK_LCONTROL or v == VK_LSHIFT or v == VK_RSHIFT) then
            if v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT then
                curkeys = v
            end
        end
    end
    for k, v in pairs(vkeys) do
        if isKeyDown(v) and (v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT and v ~= VK_LMENU and v ~= VK_RMENU and v ~= VK_RCONTROL and v ~= VK_LCONTROL and v ~= VK_LSHIFT and v ~= VK_RSHIFT) then
            if tostring(curkeys):len() == 0 then
                curkeys = v
            else
                curkeys = curkeys .. " " .. v
            end
            bool = true
        end
    end
    return curkeys, bool
end

function getDownKeysText()
	tKeys = string.split(getDownKeys(), " ")
	if #tKeys ~= 0 then
		for i = 1, #tKeys do
			if i == 1 then
				str = vkeys.id_to_name(tonumber(tKeys[i]))
			else
				str = str .. "+" .. vkeys.id_to_name(tonumber(tKeys[i]))
			end
		end
		return str
	else
		return "None"
	end
end

function strToIdKeys(str)
	tKeys = string.split(str, "+")
	if #tKeys ~= 0 then
		for i = 1, #tKeys do
			if i == 1 then
				str = vkeys.name_to_id(tKeys[i], false)
			else
				str = str .. " " .. vkeys.name_to_id(tKeys[i], false)
			end
		end
		return tostring(str)
	else
		return "(("
	end
end

function isKeysDown(keylist, pressed)
    local tKeys = string.split(keylist, " ")
    if pressed == nil then
        pressed = false
    end
    if tKeys[1] == nil then
        return false
    end
    local bool = false
    local key = #tKeys < 2 and tonumber(tKeys[1]) or tonumber(tKeys[2])
    local modified = tonumber(tKeys[1])
    if #tKeys < 2 then
        if not isKeyDown(VK_RMENU) and not isKeyDown(VK_LMENU) and not isKeyDown(VK_LSHIFT) and not isKeyDown(VK_RSHIFT) and not isKeyDown(VK_LCONTROL) and not isKeyDown(VK_RCONTROL) then
            if wasKeyPressed(key) and not pressed then
                bool = true
            elseif isKeyDown(key) and pressed then
                bool = true
            end
        end
    else
        if isKeyDown(modified) and not wasKeyReleased(modified) then
            if wasKeyPressed(key) and not pressed then
                bool = true
            elseif isKeyDown(key) and pressed then
                bool = true
            end
        end
    end
    if nextLockKey == keylist then
        if pressed and not wasKeyReleased(key) then
            bool = false
        else
            bool = false
            nextLockKey = ""
        end
    end
    return bool
end
------------- Функции, отвечающие за привязку/отвязку клавиш -----------------

function imgui.TextQuestion(label, description)
    imgui.TextDisabled(label)

    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
            imgui.PushTextWrapPos(600)
                imgui.TextUnformatted(description)
            imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function imgui.OnDrawFrame()
	
	if not one_window_state.v and 
	not two_window_state.v and 
	not three_window_state.v and 
	not four_window_state.v and 
	not five_window_state.v and 
	not six_window_state.v and 
	not seven_window_state.v and
	not ATChat.v and 
	not settings_keys.v and
	not ATre_menu.v and
	not ATChatLogger.v then
		imgui.Process = false
	end

	if one_window_state.v then

		imgui.SetNextWindowSize(imgui.ImVec2(655, 400), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw1 / 2), sh1 / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

		imgui.ShowCursor = true

		imgui.Begin(u8"Помощь с командами, и бинды", one_window_state)
		imgui.Text(u8"Для выдачи наказания, после введение команды, ставите пробел и ID нарушителя")
		imgui.Text(u8"Для выведение быстрых ответов, /h7 и т.д., нужно ставить ID: /h13 ID, и обратите внимание..")
		imgui.Text(u8".. на примечание в интерфейсе по /ans, команды с значком $, могут вводится как ответ в окне /ans")
		imgui.Text(" ")
		imgui.Separator()
			imgui.Text(u8"Ниже будут приведены координаты персонажа.")
			psX, psY, psZ = getCharCoordinates(PLAYER_PED)
			imgui.Text(u8"Позиция от X:" .. psX .. u8" | Позиция от Y:" .. psY .. u8" | Позиция от Z: " .. psZ)
		imgui.Separator()
		if imgui.CollapsingHeader(u8"Дополнительные команды") then
			imgui.Text(u8"Команда для мероприятий: /toolmp | помощь по командам: /tool (напоминание)")
			imgui.Text(u8"Помощь по флудам: /toolfd | Помощь по /ans: /toolans")
			imgui.Text(u8"Нажатие на NumPad0 открывает /ans и первый репорт.")
			imgui.Text(u8"/u id - размутить игрока; /uu id - размутить и попросить прощение")
			imgui.Text(u8"/stw id - выдать миниган кому-то; /as id - заспавнить игрока")
			imgui.Text(u8"/wh - включение/выключение ВХ")
			imgui.Text(u8"/delch - визуальная очистка чата; /cfind - чат-логгер")
			imgui.Text(u8"/tpad - телепорт на адм-остров")
		end
		imgui.Separator()
				imgui.BeginChild("##Punish.", imgui.ImVec2(350, 200), true)
					if imgui.Selectable(u8"Наказания в онлайне", beginchild == 1) then beginchild = 1 end
					if imgui.Selectable(u8"Наказания в оффлайне", beginchild == 2) then beginchild = 2 end
					imgui.Separator()
					if imgui.CollapsingHeader(u8"Бан в ручную") then
						imgui.Text(u8"Выбор причины")
						imgui.Combo(u8"Причина", combo_select, ban_str, #ban_str)
						imgui.Separator()
						imgui.Text(u8"Напишите ID")
						imgui.InputText(u8"ID", ban_id)
						if imgui.Button(u8"Ban") then  
							sampSendChat("/iban " .. u8:decode(ban_id.v) .. "" .. u8:decode(ban_str[combo_select.v +1]))
						end 
						imgui.SameLine()
						imgui.TextQuestion("(?)", u8"Бан в онлайне")
						imgui.Separator()	
						imgui.Text(u8"Напишите ник")
						imgui.InputText(u8"Nick", ban_nick)
						if imgui.Button(u8"Ban#2") then  
							sampSendChat("/banakk " .. u8:decode(ban_nick.v) .. "" .. u8:decode(ban_str[combo_select.v +1]))
						end	
						imgui.SameLine()
						imgui.TextQuestion("(?)", u8"Бан в оффлайне")
					end	

					if beginchild == 1 then  
						imgui.BeginChild("##PunishInOnline", imgui.ImVec2(325, 200), true)
							if imgui.CollapsingHeader(u8"Ban") then  
								imgui.Text(u8"/pl - бан за плагиат ника админа \n/ch - бан за читы")
								imgui.Text(u8"/nk - бан за ник с оском/унижением")
								imgui.Text(u8"/gcnk - бан за название банды с оском/унижением")
								imgui.Text(u8"/okpr/ip - оск проекта \n(необходимо ввести ник/ip)") 
								imgui.Text(u8"/svocakk/ip - бан по акк/ип по рекламе")
								imgui.Text(u8"/hl - бан за оск в хелпере")
								imgui.Text(u8"/ob - бан за обход бана")
							end
							imgui.Separator()
							if imgui.CollapsingHeader(u8"Jail") then  
								imgui.Text(u8"/sk - jail за SK in zz")
								imgui.Text(u8"/dz - jail за DM/DB in zz")
								imgui.Text(u8"/dz1 - /dz3 - jail DM/DB in zz (x2-x4)")
								imgui.Text(u8"/td - jail за DB/car in /trade")
								imgui.Text(u8"/fsh - /jail за SH and FC")
								imgui.Text(u8"/jm - jail за нарушение правил мероприятия.")
								imgui.Text(u8"/bag - jail за багоюз")
								imgui.Text(u8"/pk - jail за дрифт/паркур мод")
								imgui.Text(u8"/zv - jail за злоуп.вип")
								imgui.Text(u8"/skw - jail за SK на /gw")
								imgui.Text(u8"/ngw - jail за использование запрет.команд на /gw")
								imgui.Text(u8"/dbgw - jail за DB верт на /gw | /jch - jail за читы")
								imgui.Text(u8"/pmx - jail за серьезная помеха игрокам")
								imgui.Text(u8"/dgw - jail за наркотики на /gw")
								imgui.Text(u8"/sch - jail за запрещенные скрипты")
							end
							imgui.Separator()
							if imgui.CollapsingHeader(u8"Kick") then  
								imgui.Text(u8"/dj - кик за dm in jail")
								imgui.Text(u8"/gnk1 -- /gnk3 - кик за нецензуру в нике.")
								imgui.Text(u8"/cafk - кик за афк на арене")
							end  
							imgui.Separator()
							if imgui.CollapsingHeader(u8"Mute") then  
								imgui.Text(u8"/m - мут за мат | /rm - мут за мат в репорт ")
								imgui.Text(u8"/ok - мут за оск ")
								imgui.Text(u8"/fd1 - /fd5 - мут за флуд/спам x1-x5")
								imgui.Text(u8"/po1 - /po5 - мут за попрошайку x1-x5")
								imgui.Text(u8"/oa - мут за оск адм ")
								imgui.Text(u8"/roa - мут за оск адм в репорт")
								imgui.Text(u8"/up - мут за упом.проект")
								imgui.Text(u8"/rup - мут за у.п в репорт")
								imgui.Text(u8"/ia - мут за выдачу себя за адм")
								imgui.Text(u8"/kl - мут за клевету на адм")
								imgui.Text(u8"/nm(900), /nm1(2500), /nm2(5000) - мут за неадекват. ")
								imgui.Text(u8"/rnm(900), /rnm1(2500), /rnm2(5000) - мут за неадекват в реп.")
								imgui.Text(u8"/or - мут за оск род")
								imgui.Text(u8"/ror - мут за оск род в репорт")
								imgui.Text(u8"/cp - капс/оффтоп в репорт")
								imgui.Text(u8"/rpo - попрошайка в репорт")
								imgui.Text(u8"/rkl - клевета на адм в репорт")
							end
						imgui.EndChild()
					end
					if beginchild == 2 then  
						imgui.BeginChild("##PunishInOffline", imgui.ImVec2(325,200), true)
							if imgui.CollapsingHeader(u8"Ban") then  
								imgui.Text(u8"/apl - бан за плагиат ник админа")
								imgui.Text(u8"/ach (/achi) - бан за читы (ip)")
								imgui.Text(u8"/ank - бан за ник с оск/униж")
								imgui.Text(u8"/agcnk - бан за название банды с оск/униж")
								imgui.Text(u8"/agcnkip - бан по IP за название банды с оск/униж")
								imgui.Text(u8"/okpr/ip - оск проекта")
								imgui.Text(u8"/svoakk/ip - бан по акк/IP по рекламе")
								imgui.Text(u8"/ahl (/achi) - бан за оск в хелпере (ip)")
								imgui.Text(u8"/aob - бан за обход бана")
								imgui.Text(u8"/rdsob - бан за обман адм/игроков")
								imgui.Text(u8"/rdsip - бан по IP за обман адм/игроков")
							end
							imgui.Separator()
							if imgui.CollapsingHeader(u8"Jail") then  
								imgui.Text(u8"/ask - jail за SK in zz")
								imgui.Text(u8"/adz - jail за DM/DB in zz")
								imgui.Text(u8"/adz1 - /adz3 - jail DM/DB in zz (x2-x4)")
								imgui.Text(u8"/atd - jail за DB/CAR in trade")
								imgui.Text(u8"/afsh - jail за SH ans FC")
								imgui.Text(u8"/ajm - jail за наруш.правил МП")
								imgui.Text(u8"/abag - jail за багоюз")
								imgui.Text(u8"/apk - jail за дрифт/паркур мод")
								imgui.Text(u8"/azv - jail за злоуп.вип")
								imgui.Text(u8"/askw - jail за SK на /gw")
								imgui.Text(u8"/angw - исп.запрет.команд на /gw")
								imgui.Text(u8"/adbgw - jail за DB верт на /gw")
								imgui.Text(u8"/ajch - jail за читы")
								imgui.Text(u8"/apmx - jail за серьез.помеху")
								imgui.Text(u8"/adgw - jail за наркотики на /gw")
								imgui.Text(u8"/asch - jail за запрещенные скрипты")
							end
							imgui.Separator()
							if imgui.CollapsingHeader(u8"Mute") then  
								imgui.Text(u8"/am - мут за мат ")
								imgui.Text(u8"/aok - мут за оск ")
								imgui.Text(u8"/afd - мут за флуд/спам")
								imgui.Text(u8"/apo  - мут за попрошайку")
								imgui.Text(u8"/aoa - мут за оск.адм")
								imgui.Text(u8"/aup - мут за упоминание проектов")
								imgui.Text(u8"/anm(900) /anm1(2500) /anm2(5000) - мут за неадеквата")
								imgui.Text(u8"/aor - мут за оск/упом родных")
								imgui.Text(u8"/aia - мут за выдачу себя за адм")
								imgui.Text(u8"/akl - мут за клевету на адм")
							end
						imgui.EndChild()
					end
				imgui.EndChild()
			imgui.SameLine()
			imgui.BeginChild("##Interface", imgui.ImVec2(250, 200), true)
				if imgui.Button(u8'Помощь по мероприятиям (интерфейс)') then
					two_window_state.v = not two_window_state.v
					imgui.Process = two_window_state.v
				end
				if imgui.Button(u8'Помощь по флудам (интерфейс)') then
					three_window_state.v = not three_window_state.v
					imgui.Process = three_window_state.v
				end
				if imgui.Button(u8'Помощь по /ans (интерфейс)') then
					four_window_state.v = not four_window_state.v
					imgui.Process = four_window_state.v
				end
				if imgui.Button(u8'Панель старших администраторов') then 
					five_window_state.v = not five_window_state.v	
					imgui.Process = five_window_state.v
				end
				if imgui.Button(u8"Настройки") then  
					six_window_state.v = not six_window_state.v
					imgui.Process = six_window_state.v 
				end
				if imgui.Button(u8"Помощь по ID Guns") then  
					seven_window_state.v = not seven_window_state.v
					imgui.Process = seven_window_state
				end
			imgui.EndChild()
		imgui.Separator()

		--Блок one_window_state отвечает за помощь по командам
		--sampAddChatMessage(u8:decode(text_buffer_name.v), -1)


		imgui.End()
	end

	if two_window_state.v then

		set_custom_theme()

		imgui.SetNextWindowSize(imgui.ImVec2(550, 350), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw1 / 2), sh1 / 6), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

		imgui.ShowCursor = true

		imgui.Begin(u8"Помощник по МП", two_window_state)
		imgui.Text(u8"Данные кнопки отправляют мгновенные сообщения в /mess сразу.")
		imgui.Text(u8"Нажимать необходимо, лишь ОДИН раз, скрипт все сделает за вас.")
		imgui.Text(u8"Ваша задача лишь открыть телепорт, нажать кнопки и ввести МП.")
		imgui.Text(u8"Для открытия телепорта используется команда /mp")
		imgui.Text(u8"/jm - jail за нарушение правил мероприятия.")
		imgui.Separator()

		imgui.BeginChild("##SelectWorkingMP", imgui.ImVec2(195, 225), true)
			if imgui.Selectable(u8"Вспомогательные штучки", beginchild == 50) then beginchild = 50 end
			if imgui.Selectable(u8"Свое МП", beginchild == 51) then beginchild = 51 end
			if imgui.Selectable(u8"Заготовки МП", beginchild == 52) then beginchild = 52 end
			if imgui.Selectable(u8"Описания МПшек", beginchild == 53) then beginchild = 53 end
		imgui.EndChild()
		imgui.SameLine()

		if beginchild == 50 then   
			imgui.BeginChild("##CheckingMP", imgui.ImVec2(335, 225), true)
					imgui.Text(u8"Выдача приза:")
					imgui.InputText(u8'Введите ID', text_buffer_prize)
					if imgui.Button(u8'Вывод') then 
						sampSendChat("/mess 10 У нас есть победитель в мероприятии!")
						sampSendChat("/mess 10 И это игрок с ID: " .. u8:decode(text_buffer_prize.v))
						sampSendChat("/mpwin " .. text_buffer_prize.v)
						notify.addNotify("{87CEEB}[AdminTool]", "Вы выдали приз игроку с ID " .. u8:decode(text_buffer_prize.v) .. ", вам\nвыдана зарплата", 2, 1, 6)
						sampSendChat("/spp")
					end
					imgui.Separator()
				if imgui.Button(u8'Выдача минигана самому себе') then
					sampSendChat("/setweap " .. id .. " 38 " .. " 5000 ")
				end
				if imgui.Button(u8"Призыв к телепортации") then  
					sampSendChat("/mess 10 Дорогие игроки, телепорт все ещё открыт! /tpmp")
					sampSendChat("/mess 10 Успейте, до начала мероприятия!")
				end
			imgui.EndChild()
		end
		if beginchild == 51 then   
			imgui.BeginChild("##YouCreateMP?", imgui.ImVec2(335, 225), true)
				imgui.Text(u8"Название своего мероприятия:")
				imgui.InputText(u8'', text_buffer_mp)
				if imgui.Button(u8'Вывод') then 
					sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: " .. u8:decode(text_buffer_mp.v))
					sampSendChat("/mp")
					sampSendDialogResponse(5343, 1, 0)
					sampSendDialogResponse(5344, 1, 0, u8:decode(text_buffer_mp.v))
					sampSendChat("/mess 10 Чтобы попасть на мероприятие, введите /tpmp")
					notify.addNotify("{87CEEB}[AdminTool]", "Мероприятие успешно создано\nТелепортация открыта", 2, 1, 6)
				end
				imgui.Separator()
				if imgui.Button(u8'Стандарт.правила') then  
					sampSendChat("/mess 6 Правила: Нельзя использовать /passive, /fly, /r - /s, баги, /flycar")
					sampSendChat("/mess 6 Следуем командам администратора, ДМ запрещено, если..")
					sampSendChat("/mess 6 ..это не предусмотрено мероприятием. Начинаем!")
				end
			imgui.EndChild()
		end
		if beginchild == 52 then 
			imgui.BeginChild("##ZagotovkiMP", imgui.ImVec2(335, 225), true)
				if imgui.Button(u8'Мероприятия "Прятки"') then
					lua_thread.create(function()
						setCharCoordinates(PLAYER_PED,-2315,1545,18)
						wait(1000)
						sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Прятки. Желающие /tpmp")
						sampSendChat("/mp")
						sampSendDialogResponse(5343, 1, 0)
						sampSendDialogResponse(5344, 1, 0, "Прятки")
						sampSendChat("/mess 10 Активнее /tpmp, делаем строй и ожидаем команды")
						notify.addNotify("{87CEEB}[AdminTool]", 'Мероприятие "Прятки" успешно создано\nТелепортация открыта', 2, 1, 6)
					end)
				end
				if imgui.Button(u8'Правила МП "Прятки"') then
					sampSendChat("/mess 6 Правила: Нельзя использовать /passive, /fly, /r - /s и баги. ДМ запрещено.")
					sampSendChat("/mess 6 Правила знаем, значит у вас есть минута, чтобы спрятаться")
				end
				imgui.Separator()
				if imgui.Button(u8'Мероприятие "Король дигла"') then
					lua_thread.create(function()
						setCharCoordinates(PLAYER_PED,1753,2072,1955)
						wait(1000)
						sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Король Дигла. Желающие /tpmp")
						sampSendChat("/mp")
						sampSendDialogResponse(5343, 1, 0)
						sampSendDialogResponse(5344, 1, 0, "КД")
						sampSendChat("/mess 10 Активнее /tpmp, делаем строй и ожидаем команды")
						notify.addNotify("{87CEEB}[AdminTool]", 'Мероприятие "Король дигла" \nуспешно создано\nТелепортация открыта', 2, 1, 6)
					end)
				end
				if imgui.Button(u8'Правила МП "Король дигла"') then
					sampSendChat("/mess 6 Правила: Нельзя использовать /passive, /fly, /r - /s и баги. ДМ запрещено.")
					sampSendChat("/mess 6 Я буду вызывать двоих игроков, после начну отсчет от пяти секунд.")
				end
				imgui.Separator()
				if imgui.Button(u8'Мероприятие "Русская рулетка"') then
					lua_thread.create(function()
						setCharCoordinates(PLAYER_PED,1973,-978,1371)
						wait(1000)
						sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Русская рулетка. Желающие /tpmp")
						sampSendChat("/mp")
						sampSendDialogResponse(5343, 1, 0)
						sampSendDialogResponse(5344, 1, 0, "РР")
						sampSendChat("/mess 10 Активнее /tpmp, делаем строй и ожидаем команды")
						notify.addNotify("{87CEEB}[AdminTool]", 'Мероприятие "Русская рулетка" \nуспешно создано\nТелепортация открыта', 2, 1, 6)
					end)
				end
				if imgui.Button(u8'Правила МП "Русская рулетка"') then
					sampSendChat("/mess 6 Правила: Нельзя использовать /passive, /fly, /r - /s и баги. ДМ запрещено.")
					sampSendChat("/mess 6 Я буду действовать с помощью команды /try - убил. Удачно - убиты. Неудачно - живы.")
				end
				imgui.Separator()
				if imgui.Button(u8'Мероприятие "Поливалка"') then
					lua_thread.create(function()
						setCharCoordinates(PLAYER_PED,-2304,872,59)
						wait(1000)
						sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Поливалка. Желающие: /tpmp")
						sampSendChat("/mp")
						sampSendDialogResponse(5343, 1, 0)
						sampSendDialogResponse(5344, 1, 0, "Поливалка")
						sampSendChat("/mess 10 Активнее /tpmp, делаем строй и ожидаем комадны")
						notify.addNotify("{87CEEB}[AdminTool]", 'Мероприятие "Поливалка" \nуспешно создано\nТелепортация открыта', 2, 1, 6)
					end)
				end
				if imgui.Button(u8'Правила МП "Поливалка"') then
					sampSendChat("/mess 6 Правила: Нельзя использовать /passive, /fly, /r - /s и баги. ДМ запрещено.")
					sampSendChat("/mess 6 Я буду использовать Swat Tank, и буду сбивать вас с выбранного места.")
					sampSendChat("/mess 6 Последний, кто остается - победитель.")
				end
				imgui.Separator()
				if imgui.Button(u8'Мероприятие "Крылья смерти"') then
					lua_thread.create(function()
						setCharCoordinates(PLAYER_PED,2027,-2434,13)
						wait(1000)
						sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Крылья смерти. Желающие: /tpmp")
						sampSendChat("/mp")
						sampSendDialogResponse(5343, 1, 0)
						sampSendDialogResponse(5344, 1, 0, "Крылья смерти")
						sampSendChat("/mess 10 Активнее /tpmp, делаем строй и ожидаем команды")
						notify.addNotify("{87CEEB}[AdminTool]", 'Мероприятие "Крылья смерти" \nуспешно создано\nТелепортация открыта', 2, 1, 6)
					end)
				end
				if imgui.Button(u8'Правила МП "Крылья смерти"') then
					sampSendChat("/mess 6 Правила: Нельзя использовать /passive, /fly, /r - /s и баги. ДМ запрещено.")
					sampSendChat("/mess 6 Я буду использовать самолет Shamal, а ваша задача залезть на крылья")
					sampSendChat("/mess 6 Ваша последующая задача не упасть, а я буду выполнять трюки.")
					sampSendChat("/mess 6 Тот, кто останется последним на самолете - победитель")
				end
				imgui.Separator()
				if imgui.Button(u8'Мероприятие "Виторина"') then
					sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Викторина! Телепорта не будет")
					sampSendChat("/mess 10 Сейчас, я объясню правила игры, и те, кто прочитает правила, мне в /pm +")
					notify.addNotify("{87CEEB}[AdminTool]", 'Мероприятие "Викторина" \nзапущена\nГотовьте вопросы', 2, 1, 6)
				end
				if imgui.Button(u8'Правила МП "Викторина"') then
					sampSendChat("/mess 6 Я задаю вопрос из любой категории, и жду ответа.")
					sampSendChat("/mess 6 Первый, кто отвечает - получает один балл")
					sampSendChat("/mess 6 Всего баллов - 5. Готовность отправляем мне в /pm знаком +")
				end
				imgui.Separator()
				if imgui.Button(u8'Мероприятие "Живи или умри') then  
					lua_thread.create(function()
						setCharCoordinates(PLAYER_PED,1547,-1359,329)
						wait(1000)
						sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Живи или умри. Желающие: /tpmp")
						sampSendChat("/mp")
						sampSendDialogResponse(5343, 1, 0)
						sampSendDialogResponse(5344, 1, 0, "ЖилиУ")
						sampSendChat("/mess 10 Активнее /tpmp, делаем строй и ожидаем команды")
						notify.addNotify("{87CEEB}[AdminTool]", 'Мероприятие "Живи или умри" \nуспешно создано\nТелепортация открыта', 2, 1, 6)
					end)
				end
				if imgui.Button(u8'Правила МП "Живи или умри"') then  
					sampSendChat("/mess 6 Правила: Нельзя использовать /passive, /fly, /r - /s и баги. ДМ запрещено.")
					sampSendChat("/mess 6 Я буду использовать комбайн. Моя задача - давить вас")
					sampSendChat("/mess 6 Ваша задача - разбегаться в крыше, и выживать.")
					sampSendChat("/mess 6 Тот, кто будет последним - победитель")
				end
				imgui.Separator()
				if imgui.Button(u8'Мероприятие "Развлечение"') then  
					lua_thread.create(function()
						setCharCoordinates(PLAYER_PED,626,-1891,3)
						wait(1000)
						sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Развлечение. Желающие: /tpmp")
						sampSendChat("/mp")
						sampSendDialogResponse(5343, 1, 0)
						sampSendDialogResponse(5344, 1, 0, "Развлекательное МП")
						sampSendChat("/mess 10 Активнее /tpmp, делаем строй и ожидаем команды")
						notify.addNotify("{87CEEB}[AdminTool]", 'Мероприятие "Развлечение" \nуспешно создано\nТелепортация открыта', 2, 1, 6)
					end)
				end
				if imgui.Button(u8'Правила МП "Развлечение"') then  
					sampSendChat("/mess 6 Правила: Нельзя использовать /passive, /fly, /r - /s и баги. ДМ запрещено.")
					sampSendChat("/mess 6 Я вам ставлю любые объекты, ставите бумбокс. В течении 10 минут..")
					sampSendChat("/mess 6 ...вы свободно веселитесь! Цель самого мероприятия - собрать сервер!")
				end
				imgui.Separator()
				if imgui.Button(u8'Мероприятие "Поле чудес"') then  
					lua_thread.create(function()
						sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Поле чудес! Телепорта не будет")
						sampSendChat("/mess 10 Сейчас, я объясню правила игры, и те, кто прочитает правила, мне в /pm +")
						notify.addNotify("{87CEEB}[AdminTool]", 'Мероприятие "Поле чудес" \nзапущена\nГотовьте слово', 2, 1, 6)
					end)
				end
				if imgui.Button(u8'Правила МП "Поле чудес"') then
					sampSendChat("/mess 6 Я загадываю слово, говорю его примерное значение")  
					sampSendChat("/mess 6 Ваша задача - угадать слово, открывать буквы")
					sampSendChat("/mess 6 Тот, кто отгадает слово - победитель")
					sampSendChat("/mess 6 Одна буква = один балл. Один балл - 1кк виртов.")
				end
				imgui.Text(u8"Swat Tank - 601 ID, Shamal - 519 ID.") 
				imgui.Text(u8"Комбайн - 532 ID")
				imgui.Text(u8"Чтобы заспавнить машину,")
				imgui.Text(u8"введите /veh ID 1 1")
				imgui.Text(u8"Вопросы для Викторины,")
				imgui.Text(u8"вы должны приготовить сами")
			imgui.EndChild()
		end
		if beginchild == 53 then 
			imgui.BeginChild("##WriteOnMP", imgui.ImVec2(340, 225), true)
				if imgui.CollapsingHeader(u8"Прятки") then 
					imgui.Text(u8"Первоначально собирается строй. \nРассказываются правила.")
					imgui.Text(u8"Люди разбегаются. \nАдминистратор начинает искать")
					imgui.Text(u8"Администратор бегает с миниганом и \nубивает каждого, кого найдет")
					imgui.Text(u8"Тот, кто остается последним - побеждает")
				end 
				imgui.Separator()
				if imgui.CollapsingHeader(u8"Король дигла") then
					imgui.Text(u8"Собирается строй, рассказываются правила игры.")
					imgui.Text(u8"Игроки восстанавливают здоровье, берут Desert Eagle.")
					imgui.Text(u8"Администратор выбирает двух игроков каждый раунд")
					imgui.Text(u8"Погибающий - выбывает, \nпобедитель - остается.")
					imgui.Text(u8"Победивший в последнем раунде получает приз")
				end 
				imgui.Separator()
				if imgui.CollapsingHeader(u8"Русская рулетка") then  
					imgui.Text(u8"Делается строй, рассказываются правила")
					imgui.Text(u8"Администратор берет миниган, и начинается русская рулетка")
					imgui.Text(u8'Это делается с помощью команды "/try убил"')
					imgui.Text(u8'Если "удачно" - игрок погибает. \nЕсли "неудачно" - жив')
					imgui.Text(u8'Тот, кто остается последним побеждает')
				end 
				imgui.Separator()
				if imgui.CollapsingHeader(u8"Крылья смерти") then  
					imgui.Text(u8"Сначала делается строй, рассказываются правила")
					imgui.Text(u8"Администратор спавнит самолет Shamal")
					imgui.Text(u8"Игроки запрыгивают на крылья самолета")
					imgui.Text(u8"Администратор начинает полет и трюки")
					imgui.Text(u8"Тот, кто останется последний \n на самолете побеждает")
				end 
				imgui.Separator()
				if imgui.CollapsingHeader(u8"Викторина") then  
					imgui.Text(u8"Администратор объявляет о начале Викторины")
					imgui.Text(u8"Тем временем, телепортация не задается")
					imgui.Text(u8"Ответ = 1 балл. Тот, кто набрал 5 баллов - победитель")
					imgui.Text(u8"Можно задавать любые вопросы. \nДаже, если они не связанные с модом сервера")
				end 
				imgui.Separator()
				if imgui.CollapsingHeader(u8"Поливалка") then  
					imgui.Text(u8"Делается строй, администратор рассказывает правила")
					imgui.Text(u8"Он спавнит Swat Tank, и начинает поливать игроков")
					imgui.Text(u8"Последний, кто остался на платформе - победитель")
				end 
				imgui.Separator()
				if imgui.CollapsingHeader(u8"Живи или умри") then  
					imgui.Text(u8"Делается строй, рассказываются правила")
					imgui.Text(u8"Администратор сбивает игроков на комбайне")
					imgui.Text(u8"Тот, кто остался последний - победил")
				end 
				imgui.Separator()
				if imgui.CollapsingHeader(u8"Развлекательное МП") then  
					imgui.Text(u8"Делается строй, рассказывается короткие правила")
					imgui.Text(u8"Им можно на мероприятии выдавать объекты (/object)")
					imgui.Text(u8"Слушать музыку, и веселиться всячески..\n в течении 10 минут")
					imgui.Text(u8"БОЛЬШАЯ ПРОСЬБА! \nПОСЛЕ МЕРОПРИЯТИЯ ЗАБРАТЬ ОБЪЕКТЫ")
				end 
				imgui.Separator()
				if imgui.CollapsingHeader(u8"Поле чудес") then  
					imgui.Text(u8"Объявляется о начале.. Поле чудес, ТП нету")
					imgui.Text(u8"Рассказываются правила, загадывается слово")
					imgui.Text(u8"Игроки выбирают буквы в ЛС, но как..")
					imgui.Text(u8"Им задаются три варианта, а они выбирают .. \nодин - верный")
					imgui.Text(u8"Первый, кто написал вариант, тот вариант учитывается")
					imgui.Text(u8"Тот, кто отгадал слово победитель.")
					imgui.Text(u8"Но, участникам выдаются вирты. Одна буква = 1 балл")
					imgui.Text(u8"1 балл - 1кк.")
				end
			imgui.EndChild()
		end
		imgui.End()
	end
  	-- Блок two_window_state отвечает за интерфейс по мероприятиям

 		if three_window_state.v then

			set_custom_theme()

			imgui.SetNextWindowSize(imgui.ImVec2(650, 350), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2((sw1 / 3), sh1 / 6), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

			imgui.ShowCursor = true

			imgui.Begin(u8"Помощник по флудам", three_window_state)
			imgui.Text(u8"Данные кнопки отвечают за мгновенную отправу флуда. Интервал между флудом 1-5 минут.")
			imgui.Text(u8"Просьба, при использовании, нажать лишь ОДИН раз на кнопку.")
			imgui.Text(u8"Напоминание: использовать команду /online для выдачи виртов и очков за онлайн!")
			imgui.Text(u8"Но, есть автовыдача за /online, нажмите NumPad3 и произойдет выдача за онлайн")
			imgui.Text("  ")
			imgui.Separator()

			imgui.BeginChild("##SelectFlood", imgui.ImVec2(150, 220), true)

			if imgui.Selectable(u8"Флуды", beginchild == 100) then beginchild = 100 end
			if imgui.Selectable(u8"Призыв в /gw", beginchild == 101) then beginchild = 101 end
			if imgui.Selectable(u8"Остальное", beginchild == 102) then beginchild = 102 end

			imgui.EndChild()
			imgui.SameLine()


			if beginchild == 100 then  
				imgui.BeginChild("##Floods", imgui.ImVec2(480, 220), true)
					if imgui.Button(u8'Флуд про репорты') then
						sampSendChat("/mess 7 Информация на Russian Drift Server!")
						sampSendChat("/mess 10 Вы заметили читера? Или увидели нарушение?")
						sampSendChat("/mess 10 Напишите /report, а там ID читера/нарушителя")
						sampSendChat("/mess 10 Администраторы ответят вам и разберуться с негодяем! :D")
						sampSendChat("/mess 7 Мы рассказали, что хотели :D. Удачной игры! :3")
					end
					imgui.SameLine()
					if imgui.Button(u8'Флуд про VIP') then
						sampSendChat("/mess 7 Информация на Russian Drift Server!")
						sampSendChat("/mess 10 Вы давно хотели смотреть на людей свыше?")
						sampSendChat("/mess 10 У вас есть лишние 10.000 очков?")
						sampSendChat("/mess 10 Вводи команду /sellvip и ты получишь VIP!")
						sampSendChat("/mess 7 Мы рассказали, что хотели :D. Удачной игры! :3")
					end
					imgui.SameLine()
					if imgui.Button(u8'Флуд про оплату бизнеса/дома') then
						sampSendChat("/mess 7 Информация на Russian Drift Server!")
						sampSendChat("/mess 10 Купили дом или бизнес? Его обязательно нужно оплатить.")
						sampSendChat("/mess 10 Для этого необходимо, написать /tp, затем Разное -> Банк...")
						sampSendChat("/mess 10 ...после этого пройти в Банк, открыть счет и..")
						sampSendChat("/mess 10 ..и щелкнуть по Оплата дома или Оплата бизнеса. На этом все.")
						sampSendChat("/mess 7 Мы рассказали, что хотели :D. Удачной игры! :3")
					end
					if imgui.Button(u8'Флуд про /dt 0-990 (режим тренировки)') then
						sampSendChat("/mess 7 Информация на Russian Drift Server!")
						sampSendChat("/mess 10 Устали от перестрелок? Устали от бесконечных смертей?")
						sampSendChat("/mess 10 Хочется отдохнуть с друзьями отдельно? У нас есть способ.")
						sampSendChat("/mess 10 Введите команду /dt 0-990 и отдыхайте на здоровье.")
						sampSendChat("/mess 10 Не забудьте сообщить друзьям свой мир. Удачной игры. :3")
						sampSendChat("/mess 7 Мы рассказали, что хотели :D. Удачной игры! :3")
					end
					imgui.SameLine()
					if imgui.Button(u8'Флуд про /arena') then
						sampSendChat("/mess 7 Информация на Russian Drift Server!")
						sampSendChat("/mess 10 Хочется постреляться?")
						sampSendChat("/mess 10 Вводи /arena или /tp -> Deatchmatch-Арены. Их много.")
						sampSendChat("/mess 10 Покажи, кто в игре - войн. :3")
						sampSendChat("/mess 7 Мы рассказали, что хотели :D. Удачной игры! :3")
					end
					if imgui.Button(u8'Флуд про VK group') then
						sampSendChat("/mess 7 Информация на Russian Drift Server!")
						sampSendChat("/mess 10 Хотите участвовать в конкурсах?")
						sampSendChat("/mess 10 Или хочешь написать предложение/улучшение к серверу?")
						sampSendChat("/mess 10 Заходи в нашу группу ВКонтакте: https://vk.com/dmdriftgta")
						sampSendChat("/mess 7 Мы рассказали, что хотели :D. Удачной игры! :3")
					end
					imgui.SameLine()
					if imgui.Button(u8'Флуд про автосалон') then
						sampSendChat("/mess 7 Информация на Russian Drift Server!")
						sampSendChat("/mess 10 Хочешь кататься на личном транспорте, чтобы он был у тебя?")
						sampSendChat("/mess 10 Вводи команду /tp -> Разное -> Автосалоны")
						sampSendChat("/mess 10 Выбирай нужный автосалон, купи машину за RDS коины. И катайся :3")
						sampSendChat("/mess 7 Мы рассказали, что хотели :D. Удачной игры! :3")
					end
					if imgui.Button(u8'Флуд про сайт RDS') then
						sampSendChat("/mess 7 Информация на Russian Drift Server!")
						sampSendChat("/mess 8 Давно хотел задонатить на любимый сервер RDS?")
						sampSendChat("/mess 8 Ты это можешь сделать с радостью!")
						sampSendChat("/mess 8 Сделай это через сайт: myrds.ru")
						sampSendChat("/mess 7 Мы рассказали, что хотели :D. Удачной игры! :3")
					end
					imgui.SameLine()
					if imgui.Button(u8'Флуд про /gw') then
						sampSendChat("/mess 7 Информация на Russian Drift Server!")
						sampSendChat("/mess 10 Хотел поиграть за свою любимую игровую банду?")
						sampSendChat("/mess 10 Сделай это с помощью /gw, едь на территорию с друзьями")
						sampSendChat("/mess 10 Чтобы начать воевать за территорию, введи команду /capture")
						sampSendChat("/mess 7 Мы рассказали, что хотели :D. Удачной игры! :3")
					end
					imgui.SameLine()
					if imgui.Button(u8"Флуд про группу Сейчас на RDS") then
						sampSendChat("/mess 7 Информация на Russian Drift Server!")
						sampSendChat("/mess 10 Давно хотели скинуть свои скрины, и показать другим?")
						sampSendChat("/mess 10 Попробовать продать что-нибудь, но в игре никто не отзывается?")
						sampSendChat("/mess 10 Вы можете посетить свободную группу: https://vk.com/freerds")
						sampSendChat("/mess 7 Мы рассказали, что хотели :D. Удачной игры! :3")
					end
					if imgui.Button(u8"Флуд про /gangwar") then 
						sampSendChat("/mess 7 Информация на Russian Drift Server!")
						sampSendChat("/mess 10 Хотели сразиться с другими бандами? Выпустить гнев?")
						sampSendChat("/mess 10 Вы можете себе это позволить! Можете побороть другие банды")
						sampSendChat("/mess 10 Команда /gangwar, выбираете территорию и сражаетесь за неё.")
						sampSendChat("/mess 7 Мы рассказали, что хотели :D. Удачной игры! :3")
					end 
					imgui.SameLine()
					if imgui.Button(u8"Флуд про работы") then
						sampSendChat("/mess 7 Информация на Russian Drift Server!")
						sampSendChat("/mess 10 Не хватает денег на оружие? Не хватает на машинку?")
						sampSendChat("/mess 10 Ради наших ДМеров и дрифтеров, придуманы работы для деньжат")
						sampSendChat("/mess 10 Черный день открыт, переходи /tp -> Разное -> Работы")
						sampSendChat("/mess 7 Мы рассказали, что хотели :D. Удачной игры! :3")
					end
					imgui.SameLine()
					if imgui.Button(u8"Флуд о моде") then  
						sampSendChat("/mess 7 Информация на Russian Drift Server!")
						sampSendChat("/mess 10 Посвящаем вас в мод RDS. Прежде всего, мы Drift Server")
						sampSendChat("/mess 10 Также у нас есть дополнения, это GangWar, DM")
						sampSendChat("/mess 10 Большинство команд и все остальное указано в /help")
						sampSendChat("/mess 7 Мы рассказали, что хотели :D. Удачной игры! :3")
					end
					imgui.SameLine()
					if imgui.Button(u8'Флуд про /trade') then
						sampSendChat("/mess 7 Информация на Russian Drift Server!")
						sampSendChat("/mess 10 Хотите разные аксессуары, а долго играть не хочется и есть вирты/очки/коины/рубли?")
						sampSendChat("/mess 10 Введите /trade, подойдите к занятой лавки, спросите у человека и купите предмет.")
						sampSendChat("/mess 10 Также, справа от лавок есть NPC Арман, у него также можно что-то взять.")
						sampSendChat("/mess 7 Мы рассказали, что хотели :D. Удачной игры! :3")
					end
				imgui.EndChild()
			end

			if beginchild == 101 then  
				imgui.BeginChild("##GangWar", imgui.ImVec2(480, 220), true)
					if imgui.Button(u8"Aztecas vs Ballas") then  
						sampSendChat("/mess 7 Игра -  GangWar: /gw")
						sampSendChat("/mess 10 Varios Los Aztecas vs East Side Ballas ")
						sampSendChat("/mess 10 Помогите своим братьям, заходите через /gw за любимую банду")
						sampSendChat("/mess 7 Игра - GangWar: /gw")
					end
					imgui.SameLine()
					if imgui.Button(u8"Aztecas vs Groove") then  
						sampSendChat("/mess 7 Игра -  GangWar: /gw")
						sampSendChat("/mess 10 Varios Los Aztecas vs Groove Street ")
						sampSendChat("/mess 10 Помогите своим братьям, заходите через /gw за любимую банду")
						sampSendChat("/mess 7 Игра - GangWar: /gw")
					end
					imgui.SameLine()
					if imgui.Button(u8"Aztecas vs Vagos") then  
						sampSendChat("/mess 7 Игра -  GangWar: /gw")
						sampSendChat("/mess 10 Varios Los Aztecas vs Los Santos Vagos ")
						sampSendChat("/mess 10 Помогите своим братьям, заходите через /gw за любимую банду")
						sampSendChat("/mess 7 Игра - GangWar: /gw")
					end
					imgui.SameLine()
					if imgui.Button(u8"Aztecas vs Rifa") then  
						sampSendChat("/mess 7 Игра -  GangWar: /gw")
						sampSendChat("/mess 10 Varios Los Aztecas vs The Rifa ")
						sampSendChat("/mess 10 Помогите своим братьям, заходите через /gw за любимую банду")
						sampSendChat("/mess 7 Игра - GangWar: /gw")
					end
					if imgui.Button(u8"Ballas vs Groove") then  
						sampSendChat("/mess 7 Игра -  GangWar: /gw")
						sampSendChat("/mess 10 East Side Ballas vs Groove Street  ")
						sampSendChat("/mess 10 Помогите своим братьям, заходите через /gw за любимую банду")
						sampSendChat("/mess 7 Игра - GangWar: /gw")
					end
					imgui.SameLine()
					if imgui.Button(u8"Ballas vs Rifa") then  
						sampSendChat("/mess 7 Игра -  GangWar: /gw")
						sampSendChat("/mess 10 East Side Ballas vs The Rifa ")
						sampSendChat("/mess 10 Помогите своим братьям, заходите через /gw за любимую банду")
						sampSendChat("/mess 7 Игра - GangWar: /gw")
					end
					imgui.SameLine()
					if imgui.Button(u8"Groove vs Rifa") then  
						sampSendChat("/mess 7 Игра -  GangWar: /gw")
						sampSendChat("/mess 10 Groove Street  vs The Rifa ")
						sampSendChat("/mess 10 Помогите своим братьям, заходите через /gw за любимую банду")
						sampSendChat("/mess 7 Игра - GangWar: /gw")
					end
					imgui.SameLine()
					if imgui.Button(u8"Groove vs Vagos") then  
						sampSendChat("/mess 7 Игра -  GangWar: /gw")
						sampSendChat("/mess 10 Groove Street vs Los Santos Vagos ")
						sampSendChat("/mess 10 Помогите своим братьям, заходите через /gw за любимую банду")
						sampSendChat("/mess 7 Игра - GangWar: /gw")
					end
					imgui.SameLine()
					if imgui.Button(u8"Vagos vs Rifa") then  
						sampSendChat("/mess 7 Игра -  GangWar: /gw")
						sampSendChat("/mess 10 Los Santos Vagos vs The Rifa ")
						sampSendChat("/mess 10 Помогите своим братьям, заходите через /gw за любимую банду")
						sampSendChat("/mess 7 Игра - GangWar: /gw")
					end
					if imgui.Button(u8"Ballas vs Vagos") then  
						sampSendChat("/mess 7 Игра -  GangWar: /gw")
						sampSendChat("/mess 10 East Side Ballas vs Los Santos Vagos ")
						sampSendChat("/mess 10 Помогите своим братьям, заходите через /gw за любимую банду")
						sampSendChat("/mess 7 Игра - GangWar: /gw")
					end
				imgui.EndChild()
			end
			if beginchild == 102 then  
				imgui.BeginChild("##Other", imgui.ImVec2(480, 220), true)
					if imgui.Button(u8'Спавн каров на 15 секунд') then
						sampSendChat("/mess 14 Уважаемые игроки. Сейчас будет респавн всего серверного транспорта")
						sampSendChat("/mess 14 Займите водительские места, и продолжайте дрифтить, наши любимые :3")
						sampSendChat("/delcarall ")
						sampSendChat("/spawncars 15 ")
						notify.addNotify("{87CEEB}[AdminTool]", 'Вы запустили респавн машин, \nожидайте', 2, 1, 6)
					end
					if imgui.Button(u8'Напоминание цветов к /mess') then
						sampAddChatMessage("{87CEEB}[AdminTool] {4169E1}0 - белый, 1 - черный, 2 - зеленый, 3 - светло-зеленый", main_color)
						sampAddChatMessage("{87CEEB}[AdminTool] {4169E1}4 - красный, 5 - синий, 6 - желтый, 7 - оранжевый", main_color)
						sampAddChatMessage("{87CEEB}[AdminTool] {4169E1}8 - фиолетовый, 9 - бирюзовый, 10 - голубой", main_color)
						sampAddChatMessage("{87CEEB}[AdminTool] {4169E1}11 - темно-зеленый, 12 - золотой, 13 - серый, 14 - светло-желтый", main_color)
						sampAddChatMessage("{87CEEB}[AdminTool] {4169E1}15 - розовый, 16 - коричневый, 17 - темно-розовый", main_color)
						sampAddChatMessage("{87CEEB}[AdminTool] {4169E1}Данное сообщение выведено лишь вам...", main_color)
					end
				imgui.EndChild()
			end
			imgui.End()
		end
			-- Блок three_window_state отвечает за интерфейс по флудам

			if four_window_state.v  then

				set_custom_theme()

				imgui.SetNextWindowSize(imgui.ImVec2(600, 350), imgui.Cond.FirstUseEver)
				imgui.SetNextWindowPos(imgui.ImVec2(sw1 / 4, (sh1 / 6)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

				imgui.ShowCursor = true

				imgui.Begin(u8'Помощник по командам /ans', four_window_state)
				if imgui.CollapsingHeader(u8"Объяснения") then
					imgui.Text(u8"Для выведение быстрых ответов, /h7 и т.д., нужно ставить ID: /h13 ID, и обратите внимание")
					imgui.Text(u8"на примечание в интерфейсе по /ans, команды с значком $, могут вводится как ответ в окне /ans")
					imgui.Text(u8"После введения команды, необходимо нажать пробел!")
					imgui.Text(u8"Нажатие на NumPad0 открывает /ans и первый репорт.")
					imgui.Text(u8"Команды введение на английском языке: используются лишь на чат")
					imgui.Text(u8"А те, которые на русском и в скобках после значка $ пишутся в окне /ans")
					imgui.Text(u8"Если случайно написали .нч на английском, т.е. /yx - все равно выведится. Введен перевод")
					imgui.Text(u8".ц (/w) - вывод рандомного цвета, для своих ответов")
				end
				imgui.Separator()
					imgui.BeginChild("##QuestionSelect", imgui.ImVec2(205, 225), true)
					if imgui.Selectable(u8"Жалобы на что-то/кого-то", beginchild == 103) then beginchild = 103 end
					if imgui.Selectable(u8"Вопросы по командам, /help", beginchild == 104) then beginchild = 104 end
					if imgui.Selectable(u8"Помощь по банде/семье", beginchild == 105) then beginchild = 105 end
					if imgui.Selectable(u8"Помощь по телепортации", beginchild == 106) then beginchild = 106 end
					if imgui.Selectable(u8"Помощь по продаже/покупке", beginchild == 107) then beginchild = 107 end
					if imgui.Selectable(u8"Помощь по передаче чего-то", beginchild == 108) then beginchild = 108 end
					if imgui.Selectable(u8"Остальные независимые вопросы", beginchild == 109) then beginchild = 109 end
					if imgui.Selectable(u8"Скины", beginchild == 110) then beginchild = 110 end
					if imgui.Selectable(u8"Горячие клавиши для /ans", beginchild == 111) then beginchild = 111 end
					imgui.EndChild()
					
					imgui.SameLine()

					if beginchild == 103 then  
						imgui.BeginChild("##2Reports", imgui.ImVec2(480, 225), true)
							imgui.Text(u8"/c - начал(а) работать по жалобе ($ .нч ) | /hg - помогли вам ")
							imgui.Text(u8" .сл - слежу за игроком (исключительно $)  \n/tm - ожидайте ($ .ож )")
							imgui.Text(u8"/zba - жалоба на администратора ($ .жба ) \n/zbp - жалоба на игрока ($ .жби )")
							imgui.Text(u8"/vrm - приятного времяпрепровождения (no ID) \n/cl - игрок чист ")
							imgui.Text(u8".пр - приятной игры (no ID) | /dis - игрок не в сети ($ .нв )")
							imgui.Text(u8"/yt - уточните ваш вопрос/запрос ($ .ут) \n/n - нет нарушений у игрока ($ .нн )")
							imgui.Text(u8"/rid - уточнение ID ($.уид ) | /nac - игрок наказан ($ .нак )")
							imgui.Text(u8"/msid - ошибка в ID | /pg - проверим ($ .пр ) \n/gm - гм не робит ($ .гм )")
							imgui.Text(u8"/enk - никак ($ .нк ) | /nz - не запрещено ($ .нз ) \n/en - не знаем ($ .нез )")
							imgui.Text(u8"/yes - да ($ .жда ) | /net - нет ($ .жне ) \n/of - не оффтопить ($ .офф ) | /nv - не выдаем ($ .нвд")
							imgui.Text(u8"/vbg - скорей всего - баг ($ .баг ) | /plg - перезайдите ($ .рлг )")
							imgui.Text(u8"/trp - жалобу в /report")
						imgui.EndChild()
					end
					if beginchild == 104 then   
						imgui.BeginChild("##2QuestionsHelp", imgui.ImVec2(480, 225), true)
							imgui.Text(u8"/h7 - vip ($ .п7 ), /h8 - кмд на свадьбы ($ .п8 )\n/h13 - заработок ($ .п13 ) ")
							imgui.Text(u8"/int - Инфа в инете ($ .инф ) \n/vp1 - /vp4 - привелегии от Premuim до Личного ($ .вп1 - .вп4)")
							imgui.Text(u8"/gadm - получение адм ($ .падм)")
						imgui.EndChild()
					end
					if beginchild == 105 then   
						imgui.BeginChild("##2QuestionGangFamily", imgui.ImVec2(480, 225), true)
							imgui.Text(u8"/fp - как открыть меню семьи ($ .отф )\n/mg - как открыть меню банды ($ .отб )")
							imgui.Text(u8"/ugf - как исключить человека из банды/семьи ($ .угб )")
							imgui.Text(u8"/igf - как пригласить игроков в банду/семью ($ .пгб )")
							imgui.Text(u8"/lgf - покинуть мафию ($ .плм ) \n/pgf - выйти из банды/семьи ($ .пгф )")
							imgui.Text(u8"/vgf - выговор участнику банды ($ .вуб ) ")
						imgui.EndChild()
					end
					if beginchild == 106 then   
						imgui.BeginChild("##2QuestionsTP", imgui.ImVec2(480, 225), true)
							imgui.Text(u8"/avt - /tp автосалон ($ .тас ) | ")
							imgui.Text(u8"/avt1 - /tp автомастерская ($ .там ) | /bk - tp in bank ($ .бк ) ")
							imgui.Text(u8"/ktp - как телепортироваться ($ .ктп ) \n/og - ограб.банка ($ .ог )")
						imgui.EndChild()
					end
					if beginchild == 107 then  
						imgui.BeginChild("##2SellBuy", imgui.ImVec2(480, 225), true)
							imgui.Text(u8"/gak - как продать аксессуары ($ .кпа )")
							imgui.Text(u8"/tcm - обмен очков/коинов/рублей ($ .обм )")
							imgui.Text(u8"/smc - продажа машины ($ .пм ) | /smh - продажа дома ($ .пд )")
						imgui.EndChild()
					end
					if beginchild == 108 then  
						imgui.BeginChild('##2GiveEveryone', imgui.ImVec2(480, 225), true)
							imgui.Text(u8"/gvm - передача денег ($ .гвм ) | /gvs - передача очков ($ .гвс )")
							imgui.Text(u8"/gvr - передача рублей ($ .гвр) | /gvc - передача коинов ($ .гвк)")
						imgui.EndChild()
					end
					if beginchild == 109 then  
						imgui.BeginChild("##2OtherQuestions2", imgui.ImVec2(480, 225), true)
							imgui.Text(u8"/html - цвета ($ .цвет ) | /cr - /car ($ .кар ) ")
							imgui.Text(u8"/gn - как взять оружие ($ .ган ) \n/pd - как взять предметы ($ .пед )")
							imgui.Text(u8"/dtl - как искать детали ($ .иск ) \n/krb - казик, работы, и бизнес ($ .крб )  ")
							imgui.Text(u8"/kmd - казик, мп, обмен на trade, достижения ($ .кмд )")
							imgui.Text(u8"/gvk - (no id)")
							imgui.Text(u8"/cpt - начать капт ($ .кпт ) | /psv - пассивный режим ($ .псв )")
							imgui.Text(u8"/stp - /statpl (показ коинов, виртов) ($ .стп )")
							imgui.Text(u8"/msp - как спавнить машину ($ .мсп ) \n/chap - смена пароля ($ .спр )")
							imgui.Text(u8"/hin - как добавить человека в дом ($ .дчд )")
							imgui.Text(u8"/ctun - как протюнить машину ($ .тюн )\n /zsk - застрял человек ($ .зч )")
							imgui.Text(u8"/tdd - виртуальный мир ($ .дтт )")
						imgui.EndChild()
					end
					if beginchild == 110 then  
						imgui.BeginChild("##2KakSkins", imgui.ImVec2(480, 225), true)	
							imgui.Text(u8"/cops - копы ($ .копы ) \n/bal - балласы ($ .бал ) | /cro - грув ($ .грув ) ")
							imgui.Text(u8"/vg - вагосы ($ .ваг ) \n/rumf - ru.мафия ($ .румф ) | /var - вариосы ($ .вар )")
							imgui.Text(u8"/triad - триада ($ .триад ) \n/mf - мафия ($ .мф )")
						imgui.EndChild()
					end 
					if beginchild == 111 then 
						imgui.BeginChild("##ForAnsKeys", imgui.ImVec2(480, 225), true)
							imgui.Text(u8"Кнопка HOME - желает в чат приятной игры")
							imgui.Text(u8"Ниже все клавиши можно сменить! // В настройках.")
							imgui.Text(u8"Numpad {.} - вывод приятной игры с цветом \nNumpad {/} - вывод удачного.. ")
							imgui.Text(u8"..времяпрепровождения с цветом ")
							imgui.Text(u8"Numpad {-} - вывод приятного времяпрепровождения.. \nна сервере с цветом.")
							imgui.Text(u8"Яркий пример использования... \nПри ручном вводе ответа в диалоговом окне /ans, ")
							imgui.Text(u8"вы тыкаете Numpad {.} и у вас выведется:\nПриятной игры на RDS с цветом.")
						imgui.EndChild()
					end
				imgui.End()
			end
			-- Блок four_window_state отвечает за интерфейс по /ans

			if five_window_state.v then

				set_custom_theme()

				imgui.SetNextWindowSize(imgui.ImVec2(600, 350), imgui.Cond.FirstUseEver)
				imgui.SetNextWindowPos(imgui.ImVec2((sw1 / 4.5), sh1 / 4), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

				imgui.ShowCursor = true
				imgui.LockPlayer = true

				imgui.Begin(u8'Панель старших администраторов', five_window_state) 
				imgui.Text(u8"Данный интерфейс предназначен для обеспечения простой работы..")
				imgui.Text(u8"..старших администраторов.")
					imgui.BeginChild('Основание по снятием, восстановлением', imgui.ImVec2(300, 200), true)
						if imgui.CollapsingHeader(u8"Для снятие администраторов и т.д.") then
							imgui.Text(u8"Введите ник для того, чтобы снять админа")
							imgui.InputText(u8'Nick and sniat', text_buffer_sniat)
							if imgui.Button(u8'Вывод') then 
								sampSendChat("/makeadmin " .. u8:decode(text_buffer_sniat.v) .. " 0 ")
								notify.addNotify("{87CEEB}[AdminTool]", "Вы сняли администратора с ником:\n " .. u8:decode(text_buffer_sniat.v) .. "", 2, 1, 6)
							end 
							imgui.Separator()
							imgui.Text(u8"Введите ID, чтобы тихо кикнуть адм/игрока")
							imgui.InputText(u8'ID and kick', text_buffer_kick)
							if imgui.Button(u8"Кик") then
								sampSendChat("/skick " .. text_buffer_kick.v)
								notify.addNotify("{87CEEB}[AdminTool]", "Вы тихо кикнули игрока/адм ID: " .. u8:decode(text_buffer_kick.v) .. "", 2, 1, 6)
							end
						end
						if imgui.CollapsingHeader(u8'Для того, чтобы поставить администратора') then 
							imgui.Text(u8"Для использование, необходимо выбрать LVL,")
							imgui.Text(u8"затем ввести ник, нажать на кнопку")
							imgui.Text(u8"и ему выдается LVL")
							imgui.PushItemWidth(100)
							imgui.Combo(u8"Выбор LVL", combo_select, arr_str, #arr_str)
							imgui.PushItemWidth(175)
							imgui.InputText(u8"Введите ник", text_buffer_adm)
							if imgui.Button(u8"Поставить") then 
								sampSendChat("/makeadmin " .. u8:decode(text_buffer_adm.v) .. " " .. u8:decode(arr_str[combo_select.v + 1]))
								notify.addNotify("{87CEEB}[AdminTool]", "Вы поставили администратора на LVL:" .. u8:decode(arr_str[combo_select.v +1]) .. "\nNick: " .. u8:decode(text_buffer_adm.v), 2, 1, 6)
							end	
						end 
					imgui.EndChild()
					imgui.SameLine()
					imgui.BeginChild('Остальное', imgui.ImVec2(270, 200), true)
						if imgui.CollapsingHeader(u8"Команды для старших администраторов") then
							imgui.Text(u8"/al id - флуд про /alogin администратору")
							imgui.Text(u8"/dpv - проверка на читы")
							imgui.Text(u8"/arep - призыв админов в /a чат \nдля ответа на репорт")
						end
						imgui.Separator()
						imgui.Text(u8"Актив вспом.команд (/tr, /ears)")
						if imgui.Button(u8"Клик") then
							sampSendChat("/tr")
							sampSendChat("/ears")
							notify.addNotify("{87CEEB}[AdminTool]", 'Вы включили просмотр /pm, \nи ворование репортов', 2, 1, 6)
						end
					imgui.EndChild()
					imgui.BeginChild('Префиксы', imgui.ImVec2(400, 200), true)
						if imgui.CollapsingHeader(u8"Ввод цветов для префиксов") then  
							imgui.InputText(u8"Префикс Мл.Адм", prefix_Madm)
							imgui.InputText(u8"Префикс Адм", prefix_adm)
							imgui.InputText(u8"Префикс Ст.Адм", prefix_STadm)
							imgui.InputText(u8"Префикс ЗГА", prefix_ZGAadm)
							imgui.InputText(u8"Префикс ГА", prefix_GAadm)
							if imgui.Button(u8"Сохранить префиксы") then
								config.setting.prefix_adm = prefix_adm.v
								config.setting.prefix_Madm = prefix_Madm.v
								config.setting.prefix_STadm = prefix_STadm.v
								config.setting.prefix_ZGAadm = prefix_ZGAadm.v
								config.setting.prefix_GAadm = prefix_GAadm.v
								inicfg.save(config, directIni)
								notify.addNotify("{87CEEB}[AdminTool]", 'Сохранение прошло успешно.', 2, 1, 6)
							end
						end
						imgui.Text(u8"/pradm1 id - префикс Мл.Админ | /pradm2 id - префикс Админ")
						imgui.Text(u8"/pradm3 id - префикс Ст.Админ | /pradm4 id - префикс ЗГА")
						imgui.Text(u8"/pradm5 id - префикс ГА")
					imgui.EndChild()
				imgui.End()
			end
 			-- Блок five_window_state отвечает за панель старших администраторов

			if six_window_state.v then  -- настройки AT

				set_custom_theme()

				imgui.SetNextWindowSize(imgui.ImVec2(425, 350), imgui.Cond.FirstUseEver)
				imgui.SetNextWindowPos(imgui.ImVec2((sw1 / 2), sh1 / 6), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

				imgui.ShowCursor = true
				imgui.LockPlayer = true

				imgui.Begin(u8"Настройки AdminTool", six_window_state)
				imgui.BeginChild('Админчат', imgui.ImVec2(400, 60), true)
					imgui.Text(u8"Административный чат")
					imgui.SameLine()
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
					imgui.ToggleButton("##1", setting_items.Admin_chat)
					if setting_items.Admin_chat.v then
						if imgui.Button(u8'Настройка админ чата.', btn_size) then
							ATChat.v = not ATChat.v
						end
					end
				imgui.EndChild()
				imgui.Text(u8"Кастомное меню наблюдения за игроком")
				imgui.SameLine()
				imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
				imgui.ToggleButton("##3", setting_items.ranremenu)
				imgui.Text(u8"Уведомления о новых репортах")
				imgui.SameLine()
				imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
				imgui.ToggleButton("##Push_Report", setting_items.Push_Report)
				imgui.Text(u8"Чат-логгер")
				imgui.SameLine()
				imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
				imgui.ToggleButton("##2", setting_items.Chat_Logger)
				imgui.Text(u8"Показывать античит")
				imgui.SameLine()
				imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
				imgui.ToggleButton("##4", setting_items.anti_cheat)
				imgui.Text(u8"Авто-мут за мат")
				imgui.SameLine()
				imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
				imgui.ToggleButton("##5", setting_items.auto_mute_mat)
				imgui.Separator()
					if imgui.Button(u8"Привязка клавиш", btn_size) then  
						settings_keys.v = not settings_keys.v
					end
					imgui.Separator()
					if imgui.Button("WallHack", btn_size) then
						if control_wallhack then
							sampAddChatMessage(tag .."WallHack был выключен.")
							nameTagOff()
							control_wallhack = false
						else
							sampAddChatMessage(tag .."WallHack был включен.")
							nameTagOn()
							control_wallhack = true
						end
					end
				imgui.Separator()
				imgui.Text(u8"AutoALogin")
				imgui.SameLine()
				imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
				imgui.ToggleButton("##AutoALogin", setting_items.ATAlogin)
				imgui.Text(u8"Ввод пароля для /alogin")
				imgui.InputText(u8"Password for Admin", ATAdminPass)
				imgui.Separator()
				if imgui.Button(u8"Сохранить.") then
					config.setting.Admin_chat = setting_items.Admin_chat.v
					config.setting.Chat_Logger = setting_items.Chat_Logger.v
					config.setting.Chat_Logger_osk = setting_items.Chat_Logger_osk.v
					config.setting.Push_Report = setting_items.Push_Report.v
					config.setting.ATAlogin = setting_items.ATAlogin.v
					config.setting.ranremenu = setting_items.ranremenu.v
					config.setting.anti_cheat = setting_items.anti_cheat.v
					config.setting.auto_mute_mat = setting_items.auto_mute_mat.v
					config.setting.ATAdminPass = ATAdminPass.v
					inicfg.save(config, directIni)
					notify.addNotify("{87CEEB}[AdminTool]", 'Сохранение прошло успешно.', 2, 1, 6)
				end
				imgui.SameLine()
				imgui.Text(u8"Настройки можно посмотреть в config/AdminTool")
				imgui.Separator()
				if imgui.Button(u8"Выключение скрипта") then  
						lua_thread.create(function()
							imgui.Process = false
							wait(200)
							sampAddChatMessage(tag .. "Выгрузка скрипта из процесса MoonLoader...")
							sampAddChatMessage(tag .. "Если остался курсор есть, то откройте консоль SAMPFUNCS и закройте.")
							sampAddChatMessage(tag .. "Консоль открывается на клавишу: Тильда (Ё)")
							wait(200)
							imgui.ShowCursor = false
							thisScript():unload()
						end)
				end  
				imgui.Text(u8"Для того, чтобы снова запустить скрипт: ALT+R \n(перезагрузка всех скриптов)")
				imgui.Separator()
				imgui.End()
			end

			if seven_window_state.v then  

				set_custom_theme()

				imgui.SetNextWindowSize(imgui.ImVec2(650, 350), imgui.Cond.FirstUseEver)
				imgui.SetNextWindowPos(imgui.ImVec2((sw1 / 3), sh1 / 6), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

				imgui.ShowCursor = true  

				imgui.Begin(u8"ID оружия", seven_window_state)
					
					imgui.Text(u8"Все ID расположены с названиями! Никаких картинок.")
					imgui.Text(u8"При необходимости, ниже будут приведены ссылки для картинок:")
					imgui.Text(u8"https://gtaxmods.com/skins-id.html - скины")
					imgui.Text(u8"https://samp-mods.com/id-vehicles-samp.html - машины")
					
					if imgui.CollapsingHeader(u8"ID guns") then  
						imgui.Text(u8"1 ID - кастет | 2 ID - клюшка | 3 ID - дубинка")
						imgui.Text(u8"4 ID - нож | 5 ID - бита | 6 ID - лопата")
						imgui.Text(u8"7 ID - кий | 8 ID - катана | 9 ID - бензопила")
						imgui.Text(u8"10 ID - фаллоимитатор | 11-13 ID - вибраторы")
						imgui.Text(u8"14 ID - букет цветов | 15 ID - трость")
						imgui.Text(u8"16 ID - гранаты | 17 ID - дым/газ гранаты")
						imgui.Text(u8"18 ID - молотов | 22 ID - Colt 45 (пистолет)")
						imgui.Text(u8"23 ID - Colt 45 с глушителем | 24 ID - Deagle")
						imgui.Text(u8"25 ID - ShotGun | 26 ID - двухстволки")
						imgui.Text(u8"27 ID - Combat ShotGun | 28 ID - Узи")
						imgui.Text(u8"29 ID - MP5 | 30 ID - AK-47 | 31 ID - M4")
						imgui.Text(u8"32 ID - Tec-9 | 33 ID - Rifle | 34 ID - Sniper")
						imgui.Text(u8"35 ID - RPG | 36 ID - ракетница")
						imgui.Text(u8"37 ID - огнемет | 38 ID - minigun | 39-40 ID - C4")
						imgui.Text(u8"41 ID - баллончики | 42 ID - огнетушитель")
						imgui.Text(u8"43 ID - фотоаппарат | 44-45 ID - очки ночного видения")
						imgui.Text(u8"46 ID - парашют")
					end
				imgui.End()

			end
			-- идшники оружек

			if ATChat.v then

				set_custom_theme()

				imgui.LockPlayer = true
				imgui.ShowCursor = true

				imgui.SetNextWindowPos(imgui.ImVec2(10, 10), imgui.Cond.FirstUseEver, imgui.ImVec2(0, 0))
				imgui.SetNextWindowSize(imgui.ImVec2(300, -0.1), imgui.Cond.FirstUseEver)
				local btn_size = imgui.ImVec2(-0.1, 0)
				imgui.Begin(u8"Настройки админ чата.", ATChat)
				if imgui.Button(u8'Положение чата.', btn_size) then
					ac_no_saved.X = admin_chat_lines.X; ac_no_saved.Y = admin_chat_lines.Y
					ac_no_saved.pos = true
				end
				imgui.Text(u8'Выравнивание чата.')
				imgui.Combo("##Position", admin_chat_lines.centered, {u8"По левый край.", u8"По центру.", u8"По правый край."})
				imgui.PushItemWidth(50)
				if imgui.InputText(u8"Размер чата.", font_size_ac) then
					font_ac = renderCreateFont("Arial", tonumber(font_size_ac.v) or 10, font_admin_chat.BOLD + font_admin_chat.SHADOW)
				end
				imgui.PopItemWidth()
				imgui.Text(u8'Положение ника и уровня.')
				imgui.Combo("##Pos", admin_chat_lines.nick, {u8"Справа.", u8"Слева."})
				imgui.Text(u8'Количество строк.')
				imgui.PushItemWidth(80)
				imgui.InputInt(' ', admin_chat_lines.lines)
				imgui.PopItemWidth()
				if imgui.Button(u8'Сохранить.', btn_size) then
					sampAddChatMessage(tag .. " Поднастройка административного чата сохранена.")
					saveAdminChat()
				end
				imgui.End()
			end
			-- настройки адм-чата

			if settings_keys.v then  

				set_custom_theme()

				imgui.LockPlayer = true  
				imgui.ShowCursor = true

				imgui.SetNextWindowSize(imgui.ImVec2(425, 350), imgui.Cond.FirstUseEver)
				imgui.SetNextWindowPos(imgui.ImVec2((sw1 / 6), sh1 / 6), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
				imgui.Begin(u8"Настройки клавиш", settings_keys)
					imgui.Text(u8"Зажатые кнопки: ")
					imgui.SameLine()
					imgui.Text(getDownKeysText())
					imgui.Separator()
					imgui.Text(u8"Открытие интерфейса (/tool): ")
					imgui.SameLine()
					imgui.Text(config.keys.ATTool)
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 84)
					if imgui.Button(u8"Записать. ## 1", imgui.ImVec2(75, 0)) then
						config.keys.ATTool = getDownKeysText()
						inicfg.save(config, directIni)
					end
					imgui.Separator()
					imgui.Text(u8"Выдача за онлайн: ")
					imgui.SameLine()
					imgui.Text(config.keys.ATOnline)
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 84)
					if imgui.Button(u8"Записать. ## 2", imgui.ImVec2(75, 0)) then
						config.keys.ATOnline = getDownKeysText()
						inicfg.save(config, directIni)
					end
					imgui.Separator()
					imgui.Text(u8"Открытие /ans: ")
					imgui.SameLine()
					imgui.Text(config.keys.ATReportAns)
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 84)
					if imgui.Button(u8"Записать. ## 3", imgui.ImVec2(75, 0)) then
						config.keys.ATReportAns = getDownKeysText()
						inicfg.save(config, directIni)
					end
					imgui.Separator()
					imgui.Text(u8'Вывод "Приятной игры" в /ans: ' )
					imgui.SameLine()
					imgui.Text(config.keys.ATReportRP)
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 84)
					if imgui.Button(u8"Записать. ## 4", imgui.ImVec2(75, 0)) then
						config.keys.ATReportRP = getDownKeysText()
						inicfg.save(config, directIni)
					end
					imgui.Separator()
					imgui.Text(u8"Статистика игрока при слежке: ")
					imgui.SameLine()
					imgui.Text(config.keys.Re_menu)
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 84)
					if imgui.Button(u8"Записать. ## 5", imgui.ImVec2(75, 0)) then
						config.keys.Re_menu = getDownKeysText()
						inicfg.save(config, directIni)
					end
					imgui.Separator()
					imgui.Text(u8'Вывод "Приятного времяпрепровождения" в /ans: ' )
					imgui.SameLine()
					imgui.Text(config.keys.ATReportRP1)
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 84)
					if imgui.Button(u8"Записать. ## 6", imgui.ImVec2(75, 0)) then
						config.keys.ATReportRP1 = getDownKeysText()
						inicfg.save(config, directIni)
					end
					imgui.Separator()
					imgui.Text(u8'Вывод "Приятной игры" в чат: ' )
					imgui.SameLine()
					imgui.Text(config.keys.ATReportRP2)
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 84)
					if imgui.Button(u8"Записать. ## 7", imgui.ImVec2(75, 0)) then
						config.keys.ATReportRP2 = getDownKeysText()
						inicfg.save(config, directIni)
					end
					imgui.Separator()
					imgui.Text(u8'Включение/выключение WallHack: ' )
					imgui.SameLine()
					imgui.Text(config.keys.ATWHkeys)
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 84)
					if imgui.Button(u8"Записать. ## 8", imgui.ImVec2(75, 0)) then
						config.keys.ATWHkeys = getDownKeysText()
						inicfg.save(config, directIni)
					end
				imgui.End()
			end
			-- привязка клавиш

			if ATChatLogger.v then

				set_custom_theme()

				imgui.LockPlayer = true
				imgui.ShowCursor = true

				imgui.SetNextWindowSize(imgui.ImVec2(600, 350), imgui.Cond.FirstUseEver)
				imgui.SetNextWindowPos(imgui.ImVec2((sw1 / 4.5), sh1 / 4), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
				imgui.Begin(u8"Чат-логгер", ATChatLogger)
				if setting_items.Chat_Logger.v then
					if accept_load_clog then
						imgui.InputText(u8"Поиск.", chat_find)
						if chat_find.v == "" then
							imgui.Text(u8'Начните вводить текст\n')
						else
							for key, v in pairs(chat_logger_text) do
								if v:find(chat_find.v) ~= nil then
									imgui.Text(u8:encode(v))
								end
							end
						end
					else
						imgui.SetCursorPosX(imgui.GetWindowWidth()/2.3)
						imgui.SetCursorPosY(imgui.GetWindowHeight()/2.3)
						imgui.Spinner(20, 7)
					end
				else 
					imgui.Text(u8"Поднастройка чат-логгера не была включена.")
					imgui.Text(u8"Q: Как его включить?")
					imgui.Text(u8"A: Все просто! Заходи в /tool. Потом жмякай на < Настройки >")
					imgui.Text(u8"A: Жмякнул? Нажимай на переключатель < Чат-логгер > и пробуй ещё раз")
				end
				imgui.End()
			end
			-- чат-логгер

			if ATre_menu.v and control_recon and recon_to_player and setting_items.ranremenu.v then -- рекон

				set_custom_theme()

				imgui.LockPlayer = false
				if isKeyJustPressed(VK_RBUTTON) and not sampIsChatInputActive() and not sampIsDialogActive() then
					imgui.ShowCursor = not imgui.ShowCursor
				end

				imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/1.06), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1))
				imgui.SetNextWindowSize(imgui.ImVec2(660, 80), imgui.Cond.FirstUseEver)
				imgui.Begin(u8"Наказания игрока", false, 2+4+32)
					if imgui.Button(u8"Back Player") then  
						sampSendChat("/re " .. control_recon_playerid-1)
					end
					imgui.SameLine()
					if imgui.Button(u8"Заспавнить") then
						sampSendChat("/aspawn " .. control_recon_playerid)
					end
					imgui.SameLine()
					if imgui.Button(u8"Обновить") then
						sampSendClickTextdraw(48)
					end
					imgui.SameLine()
					if imgui.Button(u8"Слапнуть") then  
						sampSendChat("/slap " .. control_recon_playerid)
					end
					imgui.SameLine()
					if imgui.Button(u8"Заморозить") then  
						sampSendChat("/freeze " .. control_recon_playerid)
					end
					imgui.SameLine()
					if imgui.Button(u8"Разморозить") then  
						sampSendChat("/freeze " .. control_recon_playerid)
					end
					imgui.SameLine()
					if imgui.Button(u8"Выйти") then
						sampSendChat("/reoff")
						control_recon_playerid = -1
					end
					imgui.SameLine()
					if imgui.Button(u8"Next Player") then  
						sampSendChat("/re " .. control_recon_playerid+1)
					end
					imgui.Separator()
					imgui.SetCursorPosX(imgui.GetWindowWidth()/2.43-80)
					if imgui.Button(u8"Посадить") then
						tool_re = 1
					end
					imgui.SameLine()
					imgui.SetCursorPosX(imgui.GetWindowWidth()/2.41)
					if imgui.Button(u8"Забанить") then
						tool_re = 2
					end
					imgui.SameLine()
					imgui.SetCursorPosX(imgui.GetWindowWidth()/2.43+80)
					if imgui.Button(u8"Кикнуть") then
						tool_re = 3
					end
				imgui.End()
				imgui.SetNextWindowPos(imgui.ImVec2(sw-10, 10), imgui.Cond.FirstUseEver, imgui.ImVec2(1, 0.5))
				imgui.SetNextWindowSize(imgui.ImVec2(250, sh/1.15), imgui.Cond.FirstUseEver)

				if right_re_menu then -- рекон

					set_custom_theme()

					imgui.Begin(u8"Информация об игроке", false, 2+4+32)
					if accept_load then
						if not sampIsPlayerConnected(control_recon_playerid) then
							control_recon_playernick = "-"
						else
							control_recon_playernick = sampGetPlayerNickname(control_recon_playerid)
						end
						imgui.Text(u8"Игрок: " .. control_recon_playernick .. "[" .. control_recon_playerid .. "]")
						imgui.Separator()
						for key, v in pairs(player_info) do
							if key == 2 then
								imgui.Text(u8:encode(text_remenu[2]) .. " " .. player_info[2])
								imgui.BufferingBar(tonumber(player_info[2])/100, imgui.ImVec2(imgui.GetWindowWidth()-10, 10), false)
							end
							if key == 3 and tonumber(player_info[3]) ~= 0 then
								imgui.Text(u8:encode(text_remenu[3]) .. " " .. player_info[3])
								imgui.BufferingBar(tonumber(player_info[3])/100, imgui.ImVec2(imgui.GetWindowWidth()-10, 10), false)
							end
							if key == 4 and tonumber(player_info[4]) ~= -1 then
								imgui.Text(u8:encode(text_remenu[4]) .. " " .. player_info[4])
								imgui.BufferingBar(tonumber(player_info[4])/1000, imgui.ImVec2(imgui.GetWindowWidth()-10, 10), false)
							end
							if key == 5 then
								imgui.Text(u8:encode(text_remenu[5]) .. " " .. player_info[5])
								local speed, const = string.match(player_info[5], "(%d+) / (%d+)")
								if tonumber(speed) > tonumber(const) then
									speed = const
								end
								imgui.BufferingBar((tonumber(speed)*100/tonumber(const))/100, imgui.ImVec2(imgui.GetWindowWidth()-10, 10), false)
							end
							if key ~= 2 and key ~= 3 and key ~= 4 and key ~= 5 then
								imgui.Text(u8:encode(text_remenu[key]) .. " " .. player_info[key])
							end
						end
						imgui.Separator()
						if imgui.Button("WallHack") then
							if control_wallhack then
								nameTagOff()
								control_wallhack = false
							else
								nameTagOn()
								control_wallhack = true
							end
						end
						imgui.SameLine()
						imgui.TextQuestion("(?)", u8"Включение/Выключение WH")
						if imgui.Button(u8"Статистика данного игрока") then  
							sampSendChat("/statpl " .. control_recon_playerid)
						end	
						imgui.SameLine()
						imgui.TextQuestion("(?)", u8"/statpl\nКликабельно")
						if imgui.Button(u8"Вторая статистика игрока") then  
							sampSendChat("/offstats " .. control_recon_playernick)
						end
						imgui.SameLine()
						imgui.TextQuestion("(?)", u8"Показ Reg/Last IP, /offstats\nКликабельно")
						imgui.Separator()
						imgui.Text(u8"Игроки рядом:")
						local playerid_to_stream = playersToStreamZone()
						for _, v in pairs(playerid_to_stream) do
							if imgui.Button(" - " .. sampGetPlayerNickname(v) .. "[" .. v .. "] - ", imgui.ImVec2(-0.1, 0)) then
								sampSendChat("/re " .. v)
							end
						end
						imgui.Separator()
						imgui.Text(u8"Что бы убрать курсор для\n осмотра камерой: Нажмите ПКМ.")
						imgui.Text(u8"Клавиша: R - обновить рекон. \nКлавиша: Q - выйти из рекона")
						imgui.Text(u8"NumPad4 - предыдущий игрок \nNumPad6 - следующий игрок")

					else
						imgui.SetCursorPosX(imgui.GetWindowWidth()/2.3)
						imgui.SetCursorPosY(imgui.GetWindowHeight()/2.3)
						imgui.Spinner(20, 7)
					end
					imgui.End()
				end

				if tool_re > 0 then -- интерфейс по наказаниям в реконе

					set_custom_theme()

						imgui.LockPlayer = true
					imgui.SetNextWindowPos(imgui.ImVec2(10, 10), imgui.Cond.FirstUseEver, imgui.ImVec2(1, 0.5))
					imgui.SetNextWindowSize(imgui.ImVec2(250, sh/1.15), imgui.Cond.FirstUseEver)
					imgui.Begin(u8"Наказания игрока. ##Nak", false, 2+4+32)
					if tool_re == 1 then
						if imgui.Button("Cheat", btn_size) then
							sampSendChat("/jail " .. control_recon_playerid .. " 3000 Использование читерского скрипта/ПО")
						end
						if imgui.Button(u8"Исп.запрещенных скриптов", btn_size) then  
							sampSendChat("/jail " .. control_recon_playerid .. " 900 Использование ClickWarp/Metla (ИЧС)")
						end	
						if imgui.Button(u8"Злоупотребление VIP", btn_size) then
							sampSendChat("/jail " .. control_recon_playerid .. " 3000 Злоупотребление VIP")
						end
						if imgui.Button("Speed Hack/Fly", btn_size) then
							sampSendChat("/jail " .. control_recon_playerid .. " 900 SpeedHack/Fly/Flycar")
						end
						if imgui.Button(u8"Помеха MP", btn_size) then
							sampSendChat("/jail " .. control_recon_playerid .. " 300 Нарушение правил MP.")
						end
						if imgui.Button("Spawn Kill", btn_size) then
							sampSendChat("/jail " .. control_recon_playerid .. " 300 Spawn Kill")
						end
						if imgui.Button("DM in ZZ", btn_size) then  
							sampSendChat("/jail " .. control_recon_playerid .. " 300 DM/DB in ZZ")
						end
						if imgui.Button(u8"Помеха игрокам", btn_size) then  
							sampSendChat("/jail " .. control_recon_playerid .. " 300 Серьезная помеха игрокам")
						end
						if imgui.Button(u8"Паркур/дрифт мод", btn_size) then  
							sampSendChat("/jail " .. control_recon_playerid .. " 900 Использование паркур/дрифт мода")
						end
						if imgui.Button(u8"Car in /trade", btn_size) then  
							sampSendChat("/jail " .. control_recon_playerid .. " 300 DB/Car in /trade")
						end
						if imgui.Button(u8"Игровой багоюз (дигл в машине)", btn_size) then  
							sampSendChat("/jail " .. control_recon_playerid .. " 300 Игровой багоюз (deagle in car)")
						end
						if imgui.Button(u8"Использование вертолета на /gw", btn_size) then  
							sampSendChat("/jail " .. control_recon_playerid .. " 600 Исп. вертолета на /gw")
						end
						if imgui.Button(u8"SpawnKill на /gw", btn_size) then  
							sampSendChat("/jail " .. control_recon_playerid .. " 500 SK in /gw")
						end
						if imgui.Button(u8"Использование запрещ.команд на /gw", btn_size) then  
							sampSendChat("/jail " .. control_recon_playerid .. " 600 Исп. запрещенных команд на /gw")
						end
						imgui.Separator()
						if imgui.Button(u8"Назад. ##1", btn_size) then
							tool_re = 0
						end
					elseif tool_re == 2 then
						if imgui.Button("Cheat", btn_size) then
							sampSendChat("/ans " .. control_recon_playerid .. " Уважаемый игрок, вы нарушали правила сервера, и если вы..")
							sampSendChat("/ans " .. control_recon_playerid .. " ..не согласны с наказанием, напишите жалобу в VK: dmdriftgta")
							sampSendChat("/iban " .. control_recon_playerid .. " 7 Использование читерского скрипта/ПО")
						end
						if imgui.Button(u8"Обход бана", btn_size) then
							sampSendChat("/ans " .. control_recon_playerid .. " Уважаемый игрок, вы нарушали правила сервера, и если вы..")
							sampSendChat("/ans " .. control_recon_playerid .. " ..не согласны с наказанием, напишите жалобу в VK: dmdriftgta")
							sampSendChat("/iban " .. control_recon_playerid .. " 7 Обход прошлого бана")
						end
						if imgui.Button(u8"Неадекватное поведение", btn_size) then
							sampSendChat("/ans " .. control_recon_playerid .. " Уважаемый игрок, вы нарушали правила сервера, и если вы..")
							sampSendChat("/ans " .. control_recon_playerid .. " ..не согласны с наказанием, напишите жалобу в VK: dmdriftgta")
							sampSendChat("/iban " .. control_recon_playerid .. " 3 Неадекватное поведение.")
						end
						if imgui.Button(u8"Плагиат никнейма администратора", btn_size) then
							sampSendChat("/ans " .. control_recon_playerid .. " Уважаемый игрок, вы нарушали правила сервера, и если вы..")
							sampSendChat("/ans " .. control_recon_playerid .. " ..не согласны с наказанием, напишите жалобу в VK: dmdriftgta")
							sampSendChat("/ban " .. control_recon_playerid .. " 7 Плагиат ника администратора.")
						end
						if imgui.Button("Nick 3/3", btn_size) then
							sampSendChat("/ans " .. control_recon_playerid .. " Уважаемый игрок, вы нарушали правила сервера, и если вы..")
							sampSendChat("/ans ".. control_recon_playerid .. " ..не согласны с наказанием, напишите жалобу в VK: dmdriftgta")
							sampSendChat("/ban " .. control_recon_playerid .. " 7 Ник, содержащий нецензурную лексику")
						end
						if imgui.Button(u8"Оск/Унижение/Мат в хелпере", btn_size) then
							sampSendChat("/ans " .. control_recon_playerid .. " Уважаемый игрок, вы нарушали правила сервера, и если вы..")
							sampSendChat("/ans " .. control_recon_playerid .. " ..не согласны с наказанием, напишите жалобу в VK: dmdriftgta")
							sampSendChat("/ban " .. control_recon_playerid .. " 3 Оскорбление/Унижение/Мат в хелпере")
						end
						imgui.Separator()
						if imgui.Button(u8"Назад. ##2", btn_size) then
							tool_re = 0
						end
					elseif tool_re == 3 then
						if imgui.Button("AFK in /arena", btn_size) then
							sampSendChat("/kick " .. control_recon_playerid .. " AFK in /arena")
						end
						if imgui.Button("DM in Jail", btn_size) then
							sampSendChat("/kick " .. control_recon_playerid .. " dm in jail")
						end
						if imgui.Button("Nick 1/3", btn_size) then
							sampSendChat("/kick " .. control_recon_playerid .. " Nick 1/3")
						end
						if imgui.Button("Nick 2/3", btn_size) then
							sampSendChat("/kick " .. control_recon_playerid .. " Nick 2/3")
						end
						imgui.Separator()
						if imgui.Button(u8"Назад. ##3", btn_size) then
							tool_re = 0
						end
					end
					imgui.End()
				end
			end
			
end