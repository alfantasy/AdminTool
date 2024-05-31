script_name('AdminTool-Reports')
script_description('Часть пакета AdminTool. Является системой ответов на репорты.')
script_author('alfantasyz')

-- ## Регистрация библиотек, плагинов и аддонов ## --
require 'lib.moonloader'
require 'resource.commands' -- импортирование массива с командами.
local inicfg = require 'inicfg' -- работа с INI файлами
local sampev = require 'lib.samp.events' -- работа с ивентами и пакетами SAMP
local encoding = require 'encoding' -- работа с кодировкой
local atlibs = require 'libsfor' -- библиотека для работы с АТ
local imgui = require 'imgui' -- MoonImGUI || Пользовательский интерфейс
local notf_res, notf = pcall(import, 'lib/imgui_notf.lua')  -- плагин уведомлений

local fai = require "fAwesome5" -- работа с иконками Font Awesome 5
local fa = require 'faicons' -- работа с иконками Font Awesome 4
-- ## Регистрация библиотек, плагинов и аддонов ## --

-- ## Регистрация уведомлений ## --
function showNotification(text)
	notf.addNotify(ntag, text, 2, 1, 6)
end
-- ## Регистрация уведомлений ## --

-- ## Блок текстовых переменных ## --
local tag = "{00BFFF} [AT] {FFFFFF}" -- тэг AT
local log = "{00BFFF} [AdminTool-Log] {FFFFFF}" -- тэг лога АТ
local ntag = "{00BFFF} Notf - AdminTool" -- тэг уведомлений АТ
encoding.default = 'CP1251' -- смена кодировки на CP1251
u8 = encoding.UTF8 -- переименовка стандтартного режима кодировки UTF8 - u8
-- ## Блок текстовых переменных ## --

-- ## Блок переменных связанных с конфигами и элементами взаимодействия с параметрами конфига ## --

local ATMainConfig = inicfg.load({
    main = {
        styleImGUI = 0,
    },
    keys = {
        OpenReport = "None",
    },
}, "AdminTool\\settings.ini")

local directIni = "AdminTool\\settings_reports.ini"

local config = inicfg.load({
    main = {
		interface = true,
        prefix_answer = false, 
        prefix_for_answer = " // Приятной игры на сервере RDS <3",
    },
    bind_name = {},
    bind_text = {},
    bind_delay = {},
}, directIni)
inicfg.save(config, directIni)

local elements = {
	interface = imgui.ImBool(config.main.interface),
    text = imgui.ImBuffer(4096),
    prefix_answer = imgui.ImBool(config.main.prefix_answer),
    prefix_for_answer = imgui.ImBuffer(256),
    binder_name = imgui.ImBuffer(256),
    binder_text = imgui.ImBuffer(65536),
    binder_delay = imgui.ImBuffer(2500),
    select_menu = 0,
    select_category = 0,
}

-- ## Блок переменных связанных с конфигами и элементами взаимодействия с параметрами конфига ## --

-- ## Блок переменных связанных с MoonImGUI ## --
local sw, sh = getScreenResolution()
local ATReportShow = imgui.ImBool(false)
local sender = false

local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
local fai_glyph_ranges = imgui.ImGlyphRanges({ fai.min_range, fai.max_range })

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
end

imgui.ToClipboard = require('imgui_addons').ToClipboard
imgui.Tooltip = require('imgui_addons').Tooltip
-- ## Блок переменных связанных с MoonImGUI ## --

-- ## Блок с ответами ## --
local questions = {
    ["reporton"] = {
		[u8"Игрок вышел"] = "Данный игрок покинул игру.",
        [u8"Начало работы по жалобе"] = "Начал(а) работу по вашей жалобе!",
		[u8"Иду помогать"] = "Уважаемый игрок, сейчас помогу вам!",
		[u8"Нет такой инфы у админов"] = "Данную информацию узнавайте в интернете.",
		[u8"Жалоба на админа"] = "Пишите жалобу на администратора на форум https://forumrds.ru",
		[u8"Жалоба на игрока"] = "Вы можете оставить жалобу на игрока на форум https://forumrds.ru",
        [u8"Жалоба на что-либо"] = "Вы можете оставить жалобу на форум https://forumrds.ru",
		[u8"Помогли вам"] = "Помогли вам",
		[u8"Ожидайте"] = "Ожидайте",
		[u8"Приятного времяпрепровождения"] = "Приятного времяпрепровождения на Russian Drift Server!",
		[u8"Игрок ничего не сделал"] = "Не вижу нарушений со стороны игрока",
		[u8"Игрок чист"] = " Данный игрок чист",
		[u8"Игрок не в сети"] = "Данный игрок не в сети",
		[u8"Уточнение вопрос/репорт"] = "Уточните вашу жалобу/вопрос",
		[u8"Уточнение ID"] = "Уточните ID нарушителя/читера в /report",
		[u8"Игрок наказан"] = "Данный игрок наказан",
		[u8"Проверим"] = "Проверим",
		[u8"ГМ не работает"] = "GodMode (ГодМод) на сервере не работает",
		[u8"Нет набора"] = "В данный момент набор в администрацию не проходит.",
		[u8"Сейчас сниму наказание"] = "Сейчас сниму вам наказание.",
		[u8"Баг будет исправлен"] = "Данный баг скоро будет исправлен.",
		[u8"Ошибка будет исправлена"] = "Данный ошибка скоро будет исправлена.",
		[u8"Приветствие"] = "Добрый день, уважаемый игрок.",
        [u8"Разрешено"] = "Разрешено",
		[u8"Никак"] = "Никак",
		[u8"Да"] = "Да",
		[u8"Нет"] = "Нет",
		[u8"Не запрещено"] = "Не запрещено",
		[u8"Не знаем"] = "Не знаем",
		[u8"Нельзя оффтопить"] = "Не оффтопьте",
		[u8"Не выдаем"] = "Не выдаем",
		[u8"Это баг"] = "Скорей всего - это баг",
		[u8"Перезайдите"] = "Попробуйте перезайти"

    },
	["HelpHouses"] = {
		[u8"Как добавить игрока в аренду"] = "/hpanel -> Слот1-3 -> Изменить -> Аренда дома -> Подселить соседа",
		[u8"А домик как продать"] = "/hpanel -> Слот1-3 -> Изменить -> Продать дом государству || /sellmyhouse (игроку)",
		[u8"Как купить дом"] = "Встаньте на пикап (зеленый, не красный) и нажмите F.",
        [u8"Как открыть меню дома"] = "/hpanel"
	},
	["HelpCmd"] = {
		[u8"Команды VIP`а"] = "Данную информацию можно найти в /help -> 7 пункт",
        [u8"Информация в инете"] = "Данную информацию можно узнать в интернете",
		[u8"Привелегия Premuim"] = "Данный игрок с привелегией Premuim VIP (/help -> 7)",
		[u8"Привелегия Diamond"] = "Данный игрок с привелегией Diamond VIP (/help -> 7) ",
		[u8"Привелегия Platinum"] = "Данный игрок с привелегией Platinum VIP (/help -> 7)",
		[u8"Привелегия Личный"] = "Данный игрок с привелегией «Личный» VIP (/help -> 7)",
		[u8"Команды для свадьбы"] = "Данную информацию можно найти в /help -> 8 пункт",
        [u8"Как заработать валюту"] = "Данную информацию можно найти в /help -> 14 пункт",
		[u8"Как получать админку"] = "Ожидать набор, или же /help -> 18 пункт"
	},
	["HelpGangFamilyMafia"] = {
		[u8"Как открыть меню банды"] = "/menu (/mm) - ALT/Y -> Система банд",
		[u8"Как открыть меню семьи"] = "/fpanel ",
		[u8"Как исключить игрока"] = "/guninvite (банда) || /funinvite (семья)",
		[u8"Как пригласить игрока"] = "/ginvite (банда) || /finvite (семья)",
		[u8"Как покинуть банду/семью"] = "/gleave (банда) || /fleave (семья)",
        [u8"Как выдать ранг"] = "/grank IDPlayer Ранг",
		[u8"Как покинуть мафию"] = "/leave",
		[u8"Как выдать выговор"] = "/gvig // Должна быть лидерка",
	},
	["HelpTP"] = {
		[u8"Как тп в автосалон"] = "tp -> Разное -> Автосалоны",
		[u8"Как тп в автомастерскую"] = "/tp -> Разное -> Автосалоны -> Автомастерская",
		[u8"Как тп в банк"] = "/bank || /tp -> Разное -> Банк",
		[u8"Как ваще тп"] = "/tp (по локациям), /g (/goto) id (к игроку) с VIP (/help -> 7 пункт)",
        [u8"Как тп на работы"] = "/tp -> Работы"
	},
	["HelpSellBuy"] = {
		[u8"Как продать аксы"] = "Продать аксессуары или купить можно на /trade. Чтобы продать, нажмите F около лавки",
		[u8"Как обменять валюту"] = "Чтобы обменять валюту, введите /trade, и подойдите к NPC Арману, стоит справа",
		[u8"А как продать тачку"] = "/sellmycar IDPlayer Слот1-5 Сумма || /car -> Слот1-5 -> Продать государству",
        [u8"А как продать бизнес"] = "/biz > Продать бизнес государству",
		[u8"Как передать деньги"] = "/givemoney IDPlayer money",
		[u8"Как передать очки"] = "/givescore IDPlayer score",
		[u8"Как передать рубли"] = "/giverub IDPlayer rub | С Личного VIP (/help -> 7)",
		[u8"Как передать коины"] = "/givecoin IDPlayer coin | С Личного VIP (/help -> 7)",
        [u8"Как заработать валюту"] = "Данную информацию можно найти в /help -> 14 пункт",
	},
	["HelpBuz"] = {
		[u8"Меню казино"] = "Введите /cpanel ", 
		[u8"Продать бизнес"] = "/biz > Продать бизнес государству",
		[u8"Меню бизнесмена"] = "Введите /biz ",
		[u8"Меню клуба"] = "Введите /clubpanel ",
		[u8"Управление бизнесами"] = "Введите /help -> 9",
	},
	["HelpDefault"] = {
		[u8"IP RDS 01"] = "46.174.52.246:7777",
		[u8"IP RDS 02"] = "46.174.49.170:7777",
		[u8"Сайт с цветами HTML"] = "https://colorscheme.ru/html-colors.html",
		[u8"Сайт с цветами HTML 2"] = "https://htmlcolorcodes.com",
		[u8"Как поставить цвет"] = "Цвет в коде HTML {RRGGBB}. Зеленый - 008000. Берем {} и ставим цвет перед словом {008000}Зеленый",
		[u8"Ссылка на офф.группу"] = "https://vk.com/dmdriftgta | Группа проекта",
        [u8"Ссылка на форум"] = "https://forumrds.ru | Форум проекта",
        [u8"Как оплатить дом/бизнес"] = "Оплатить бизнес/дом можно с помощью /bank или /tp -> Разное -> Банк",
		[u8"Где взять купленную машину"] = "Используйте команду /car",
		[u8"Как ограбить банк"] = 'Встать на пикап "Ограбление банка", после около ячеек нажимать на ALT и ехать на красный маркер на карте',
		[u8"Как детальки искать"] = "Детали разбросаны по всей карте. Обмен происходится на /garage",
		[u8"Как начать капт"] = "Для того, чтобы начать капт, нужно ввести /capture",
		[u8"Как пассив вкл/выкл"] = "/passive ",
		[u8"/statpl"] = "Чтобы посмотреть детали, очки, коины, рубли, вирты - /statpl",
		[u8"Смена пароля"] = "/mm -> Действия -> Сменить пароль",
		[u8"Спавн тачки"] = "/mm -> Транспортное средство -> Тип транспорта",
        [u8"Как взять оружие"] = "/menu (/mm) - ALT/Y -> Оружие",
		[u8"Как взять предметы"] = "/menu (/mm) - ALT/Y -> Предметы",
        [u8"Как открыть меню"] = "/mm (/mn) || Alt/Y",
		[u8"Как тюнить тачку"] = "/menu (/mm) - ALT/Y -> Т/С -> Тюнинг",
		[u8"Если игрок застрял"] = "/kill | /tp | /spawn",
		[u8"Как попасть на дерби/пабг"] = "/join | Есть внутриигровые команды, следите за чатом",
		[u8"Виртуальный мир"] = "/dt 0-990 / Виртуальный мир",
        [u8"Прогресс миссий/квестов"] = "/quests | /dquest | /bquest",
		[u8"Спросите у игроков"] = "Спросите у игроков."
	},
	["HelpSkins"] = {
		[u8"Сайт со скинами"] = " https://gtaxmods.com/skins-id.html.",
		[u8"Копы"] = "65-267, 280-286, 288, 300-304, 306, 307, 309-311",
		[u8"Балласы"] = "102-104",
		[u8"Грув"] = "105-107",
		[u8"Триад"] = "117-118, 120",
		[u8"Вагосы"] = "108-110",
		[u8"Ру.Мафия"] = "111-113",
		[u8"Вариосы"] = "114-116",
		[u8"Мафия"] = "124-127"
	},
	["HelpSettings"] = {
		[u8"Входы/Выходы игроков"] = "/menu (ALT/Y) -> Настройки -> 1 пункт.",
		[u8"Разрешение вызывать на дуель"] = "/menu (ALT/Y) -> Настройки -> 2 пункт.",
		[u8"On/Off Личные сообщения"] = "/menu (ALT/Y) -> Настройки -> 3 пункт.",
		[u8"Запросы на телепорт"] = "/menu (ALT/Y) -> Настройки -> 4 пункт.",
		[u8"Разрешение показывать DM Stats"] = "/menu (ALT/Y) -> Настройки -> 5 пункт.",
		[u8"Эффект при телепортации"] = "/menu (ALT/Y) -> Настройки -> 6 пункт.",
		[u8"Показывать спидометр"] = "/menu (ALT/Y) -> Настройки -> 7 пункт.",
		[u8"Показывать Drift Lvl"] = "/menu (ALT/Y) -> Настройки -> 8 пункт.",
		[u8"Спавн в доме/доме семью"] = "/menu (ALT/Y) -> Настройки -> 9 пункт.",
		[u8"Вызов главного меню"] = "/menu (ALT/Y) -> Настройки -> 10 пункт.",
		[u8"On/Off приглашение в банду"] = "/menu (ALT/Y) -> Настройки -> 11 пункт.",
		[u8"Выбор ТС на TextDraw"] = "/menu (ALT/Y) -> Настройки -> 12 пункт.",
		[u8"On/Off кейс"] = "/menu -> Настройки (ALT/Y) -> 13 пункт.",
		[u8"On/Off FPS показатель"] = "/menu (ALT/Y) -> Настройки -> 15 пункт.",
		[u8"On/Off Уведомления"] = "/menu (ALT/Y) -> Настройки -> 16 пункт",
		[u8"On/Off Уведы.акции"] = "/menu (ALT/Y) -> Настройки -> 17 пункт",
		[u8"On/Off Авто.Автор"] = "/menu (ALT/Y) -> Настройки -> 18 пункт",
		[u8"On/Off Фон.музыка при входе"] = "/menu (ALT/Y) -> Настройки -> 19 пункт",
		[u8"Кнопка гс.чата"] = "/menu (ALT/Y) -> Настройки -> 20 пункт",
	}
}
-- ## Блок с ответами ## --

function main()
    while not isSampAvailable() do wait(0) end
    
    sampfuncsLog(log .. " Инициализация системы ответов на репорты. \n  Просьба, проверьте целостность библиотек, дабы избежать ошибок!")

	-- ## Ответы на репорты для чата (/ans id text || /ot id text) ## --
	for key in pairs(cmd_helper_answers) do  
		sampRegisterChatCommand(key, function(arg)
			if #arg > 0 then  
				sampSendChat("/ans " .. arg .. cmd_helper_answers[key].reason .. ' // Приятной игры на сервере RDS. <3 ')
			else 
				sampAddChatMessage(tag .. 'Вы не ввели ID игрока', -1)
			end
		end)
	end
	-- ## Ответы на репорты для чата (/ans id text || /ot id text) ## --

    while true do
        wait(0)

        imgui.Process = true

        if atlibs.isKeysDown(atlibs.strToIdKeys(ATMainConfig.keys.OpenReport)) and not sampIsDialogActive() and not sampIsChatInputActive() then  
			lua_thread.create(function()
				sampSendChat("/ans ")
				sampSendDialogResponse(2348, 1, 0)
				wait(50)
			end)
		end

		lua_thread.create(function()
			if sampGetCurrentDialogEditboxText() == '.нч' or sampGetCurrentDialogEditboxText() == '/yx' then
				sampSetCurrentDialogEditboxText('{FFFFFF}Начал(а) работу по вашей жалобе! ' .. color() .. ' Приятной игры на сервере RDS. <3 ')
				wait(2000)
				if tonumber(id_punish) ~= nil then 
					sampSendChat("/re " .. id_punish)
				else 	
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/re " )
				end	
			end
		end)

		if sampGetCurrentDialogEditboxText() == '.ич' or sampGetCurrentDialogEditboxText() == '/bx' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Данный игрок чист. ' .. color() .. ' Приятной игры на сервере RDS. <3 ')
		end

		lua_thread.create(function()
			if sampGetCurrentDialogEditboxText() == '.сл' then
				sampSetCurrentDialogEditboxText('{FFFFFF}Слежу за данным игроком, ожидайте. :3 ')
				wait(2000)
				if tonumber(id_punish) ~= nil then 
					sampSendChat("/re " .. id_punish)
				else 	
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/re " )
				end	
			end
		end)

		if sampGetCurrentDialogEditboxText() == '/gvk' then 
			local string = string.sub(sampGetCurrentDialogEditboxText(), 0, string.len(sampGetCurrentDialogEditboxText()) - 1)
			sampSetCurrentDialogEditboxText(string .. color() .. "https://vk.com/dmdriftgta")
		end

		if sampGetCurrentDialogEditboxText() == '.жда' or sampGetCurrentDialogEditboxText() == '/;lf' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}Да. ' .. color() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.жне' or sampGetCurrentDialogEditboxText() == '/;yt' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}Нет. ' .. color() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.нк' or sampGetCurrentDialogEditboxText() == '/yr' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}Никак. ' .. color() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.пр' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}Проверим. ' .. color() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.рлг' or sampGetCurrentDialogEditboxText() == '/hku' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}Попробуйте перезайти. '  .. color() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.нвд' or sampGetCurrentDialogEditboxText() == '/ydl' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}Не выдаем. ' .. color() .. ' | Удачного времяпрепровожодения ')
		end

		if sampGetCurrentDialogEditboxText() == '.офф' or sampGetCurrentDialogEditboxText() == '/jaa' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}Не оффтопьте. ' .. color() .. ' | Удачного времяпрепровожодения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.нез' or sampGetCurrentDialogEditboxText() == '/ytp' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}Не знаем.' .. color() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.баг' or sampGetCurrentDialogEditboxText() == '/,fu' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}Скорей всего - это баг. ' .. color() .. ' | Удачного времяпрепровождения ')
		end
		
		if sampGetCurrentDialogEditboxText() == '.ож' or sampGetCurrentDialogEditboxText() == '/j;' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Ожидайте. '  .. color() ..  ' Приятного времяпрепровождения на RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.жба' or sampGetCurrentDialogEditboxText() == '/;,f' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Пишите жалобу на администратора на форум https://forumrds.ru')
		end

		if sampGetCurrentDialogEditboxText() == '.жби'or sampGetCurrentDialogEditboxText() == '/;,b'  then
			sampSetCurrentDialogEditboxText('{FFFFFF}Вы можете оставить жалобу на игрока на форум https://forumrds.ru')
		end

		if string.find(sampGetChatInputText(), "%-пр") then
			sampSetChatInputText(string.gsub(sampGetChatInputText(), "-пр", "| Приятной игры на RDS <3"))
		end

		if string.find(sampGetChatInputText(), "%/vrm") then
			sampSetChatInputText(string.gsub(sampGetChatInputText(), "/vrm", "Приятного времяпрепровождения на Russian Drift Server!"))
		end
		
		if sampGetCurrentDialogEditboxText() == '.нак' or sampGetCurrentDialogEditboxText() == '/yfr' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Данный игрок наказан. | '  .. color() ..  '  Приятной игры на RDS! <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.нн' or sampGetCurrentDialogEditboxText() == '/yy' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Не вижу нарушений от игрока. | ' .. color() .. ' Приятной игры на RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.нв' or sampGetCurrentDialogEditboxText() == '/yd' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Данный игрок не в сети. | ' .. color() .. ' Приятной игры на RDS. <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.пв' or sampGetCurrentDialogEditboxText() == '/gd' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Помогли вам. | ' .. color() .. ' Удачной игры на RDS <3')
		end

		if string.find(sampGetChatInputText(), "%/gvk") then
			sampSetChatInputText(string.gsub(sampGetChatInputText(), "/gvk", "https://vk.com/dmdriftgta"))
		end
        
    end
end

-- ## Блок обработки ивентов и пакетов SA:MP ## -- 
function sampev.onServerMessage(color, text)
	if elements.interface.v then
		if text:find("Администратор уже проверяет данную жалобу") then  
			sampAddChatMessage(tag .. " Какой-то администратор уже проверяет жалобу. Если интерфейс включен, он закроется :(")
			ATReportShow.v = false
			imgui.Process = ATReportShow.v 
			return false
		end
	end
end

function sampev.onShowDialog(id, style, title, button1, button2, text)
	if elements.interface.v then 
		if id == 2349 then  
			if text:match("Игрок: {......}(%S+)") and text:match("Жалоба:\n{......}(.*)\n\n{......}") then
				nick_rep = text:match("Игрок: {......}(%S+)")
				text_rep = text:match("Жалоба:\n{......}(.*)\n\n{......}")	
				pid_rep = atlibs.playernickname(nick_rep)
				if pid_rep == nil then  
					pid_rep = "None"
				end
				rep_text = u8:encode(text_rep)
				id_punish = rep_text:match("(%d+)")
			end
			if not ATReportShow.v then 
				ATReportShow.v = true  
				imgui.Process = true 
			end
			return false
		else 
			ATReportShow.v = false  
			imgui.Process = false  
			imgui.ShowCursor = false
		end
		if id == 2350 then  
			return false  
		end  
		if id == 2351 then  
			return false 
		end
	end
end
-- ## Блок обработки ивентов и пакетов SA:MP ## -- 

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

function imgui.OnDrawFrame()  

    if ATMainConfig.main.styleImGUI == 0 then
		imgui.SwitchContext()
        atlibs.black()
    elseif ATMainConfig.main.styleImGUI == 1 then
		imgui.SwitchContext()
        atlibs.grey_black()
	elseif ATMainConfig.main.styleImGUI == 2 then
		imgui.SwitchContext()
		atlibs.white()
    elseif ATMainConfig.main.styleImGUI == 3 then
		imgui.SwitchContext()
        atlibs.skyblue()
    elseif ATMainConfig.main.styleImGUI == 4 then
		imgui.SwitchContext()
        atlibs.blue()
    elseif ATMainConfig.main.styleImGUI == 5 then
		imgui.SwitchContext()
        atlibs.blackblue()
    elseif ATMainConfig.main.styleImGUI == 6 then
		imgui.SwitchContext()
        atlibs.red()
	elseif ATMainConfig.main.styleImGUI == 7 then 
		imgui.SwitchContext()
		atlibs.blackred()
	elseif ATMainConfig.main.styleImGUI == 8 then 
		imgui.SwitchContext()
		atlibs.brown()
	elseif ATMainConfig.main.styleImGUI == 9 then 
		imgui.SwitchContext()
		atlibs.violet()
	elseif ATMainConfig.main.styleImGUI == 10 then  
		imgui.SwitchContext()
		atlibs.purple2()
	elseif ATMainConfig.main.styleImGUI == 11 then 
		imgui.SwitchContext() 
		atlibs.salat()
	elseif ATMainConfig.main.styleImGUI == 12 then  
		imgui.SwitchContext()
		atlibs.yellow_green()
	elseif ATMainConfig.main.styleImGUI == 13 then  
		imgui.SwitchContext()
		atlibs.banana()
	elseif ATMainConfig.main.styleImGUI == 14 then  
		imgui.SwitchContext()
		atlibs.royalblue()
	end

    if not ATReportShow.v then  
        imgui.Process = false  
        imgui.ShowCursor = false  
    end

    if ATReportShow.v and elements.interface.v then  
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5)) 
        imgui.SetNextWindowSize(imgui.ImVec2(430, 250), imgui.Cond.FirstUseEver)

        imgui.ShowCursor = true

        imgui.Begin("##ReportShow", ATReportShow, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.MenuBar)

        imgui.BeginMenuBar()        
            imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
            imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 10) 
            if imgui.Button(fai.ICON_FA_BELL, imgui.ImVec2(27,0)) then  
                elements.select_menu = 0
            end; imgui.Tooltip(u8"Окно с репортом")
            imgui.Spacing()
            imgui.Text(u8("     Текст репорта: " .. u8:decode(rep_text)))
            imgui.PopStyleVar(1)
            imgui.PopStyleVar(1)
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
			if elements.select_menu == 1 or elements.select_menu == 2 then  
				if imgui.Button(fai.ICON_FA_ARROW_LEFT .. '##BackButton', imgui.ImVec2(27,0)) then
					elements.select_menu = 0
				end
			end
        imgui.EndMenuBar()

        if elements.select_menu == 0 then
			imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(0.5, 0.5))
            if (nick_rep and pid_rep and rep_text) then  
				imgui.Text(u8"Жалоба от: "); imgui.SameLine()
                imgui.Text(nick_rep); imgui.ToClipboard(nick_rep); imgui.SameLine();
				imgui.Text("[" .. pid_rep .. "]"); imgui.ToClipboard(pid_rep)
                imgui.Separator()
                imgui.Text(u8(u8:decode(rep_text)))
                imgui.Separator()
            elseif (nick_rep == nil or pid_rep == nil or rep_text == nil or text_rep == nil) then
                imgui.Text(u8"Жалоба не существует.")
            end	
			imgui.PushItemWidth(310)
            imgui.InputText('##Ответ', elements.text) 
			imgui.PopItemWidth()
            imgui.SameLine()
            if imgui.Button(fa.ICON_REFRESH .. ("##RefreshText//RemoveText")) then  
                elements.text.v = ""
            end; imgui.Tooltip(u8"Обновляет/Удаляет содержимое текстового поля сразу.")
            if #elements.text.v > 0 then  
                imgui.SameLine()
                if imgui.Button(fa.ICON_FA_SAVE .. "##SaveReport") then  
                    imgui.OpenPopup('Binder')
                end  
            end; imgui.Tooltip(u8"Открывает сохранение ответа. \nВ окне будет необходимо подтверждение.")
            imgui.SameLine()
            if imgui.Button(fa.ICON_FA_TEXT_HEIGHT .. ("##SendColor")) then  
                elements.text.v = color()
			end; imgui.Tooltip(u8"Ставит рандомный цвет перед ответом.")
			imgui.SameLine()
			if imgui.Checkbox(u8"##PrefixAnswer", elements.prefix_answer) then 
				config.main.prefix_answer = elements.prefix_answer.v
				inicfg.save(config, directIni)
			end; imgui.Tooltip(u8"Автоматически при ответе подставляет пожелание из зарегистрированного текста.\nЗарегистрировать можно в настройках АТ.\n/tool (F3) -> Настройки (иконка 'Шестеренки')")
            imgui.Separator()
            if imgui.Button(fa.ICON_FA_EYE .. u8" Работа по жб", imgui.ImVec2(135,20)) then  
				lua_thread.create(function()
					sampSendDialogResponse(2349, 1, 0)
					wait(50)
					sampSendDialogResponse(2350, 1, 0)
					wait(50)
					if elements.prefix_answer.v then  
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} Начал(а) работу по вашей жалобе! ' .. u8:decode(config.main.prefix_for_answer))	
					else 
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} Начал(а) работу по вашей жалобе! ')	
					end
					wait(50)
					sampCloseCurrentDialogWithButton(13)
					ATReportShow.v = false  
					imgui.ShowCursor = false
					wait(50)
					if tonumber(id_punish) ~= nil and id_punish ~= nil then 
						sampSendChat("/re " .. id_punish)
					end	
				end)
			end	
			imgui.SameLine()
            if imgui.Button(fa.ICON_BAN .. u8" Наказан", imgui.ImVec2(135,20)) then
				lua_thread.create(function() 
					sampSendDialogResponse(2349, 1, 0)
					wait(50)
					sampSendDialogResponse(2350, 1, 0)
					wait(50)
					if elements.prefix_answer.v then  
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} Данный игрок наказан! ' .. u8:decode(config.main.prefix_for_answer))	
					else 
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} Данный игрок наказан! ')	
					end
					wait(50)
					sampCloseCurrentDialogWithButton(13)
					ATReportShow.v = false  
					imgui.ShowCursor = false
				end)
			end
			imgui.SameLine()
			if imgui.Button(fa.ICON_COMMENTING_O .. u8" Уточните ID", imgui.ImVec2(135,20)) then  
				lua_thread.create(function()
					sampSendDialogResponse(2349, 1, 0)
					wait(50)
					sampSendDialogResponse(2350, 1, 0)
					wait(50)
					if elements.prefix_answer.v then  
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} Уточните ID нарушителя/читера в /report ' .. u8:decode(config.main.prefix_for_answer))	
					else 
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} Уточните ID нарушителя/читера в /report ')	
					end
					wait(50)
					sampCloseCurrentDialogWithButton(13)
					ATReportShow.v = false  
					imgui.ShowCursor = false
				end)
			end	
			if imgui.Button(fa.ICON_FA_EDIT .. u8" Уточните жб", imgui.ImVec2(135,20)) then  
				lua_thread.create(function()
					sampSendDialogResponse(2349, 1, 0)
					wait(50)
					sampSendDialogResponse(2350, 1, 0)
					wait(50)
					if elements.prefix_answer.v then  
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} Уточните вашу жалобу/вопрос ' .. u8:decode(config.main.prefix_for_answer))	
					else 
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} Уточните вашу жалобу/вопрос ')	
					end
					wait(50)
					sampCloseCurrentDialogWithButton(13)
					ATReportShow.v = false  
					imgui.ShowCursor = false
				end)
			end	
			imgui.SameLine()
			if imgui.Button(fai.ICON_FA_SHARE .. u8" Жб на админа", imgui.ImVec2(135,20)) then
				lua_thread.create(function()
					sampSendDialogResponse(2349, 1, 0)
					wait(50)
					sampSendDialogResponse(2350, 1, 0)
					wait(50)
					if elements.prefix_answer.v then
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} Пишите жалобу на администратора на форум https://forumrds.ru '.. u8:decode(config.main.prefix_for_answer))
					else
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} Пишите жалобу на администратора на форум https://forumrds.ru ')
					end
					wait(50)
					sampCloseCurrentDialogWithButton(13)
					ATReportShow.v = false
					imgui.ShowCursor = false
				end)
			end
			imgui.SameLine()
			if imgui.Button(fai.ICON_FA_SHARE .. u8" Жб на игрока", imgui.ImVec2(135,20)) then
				lua_thread.create(function()
					sampSendDialogResponse(2349, 1, 0)
					wait(50)
					sampSendDialogResponse(2350, 1, 0)
					wait(50)
					if elements.prefix_answer.v then
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} Пишите жалобу на игрока на форум https://forumrds.ru '.. u8:decode(config.main.prefix_for_answer))
					else
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} Пишите жалобу на игрока на форум https://forumrds.ru ')
					end
					wait(50)
					sampCloseCurrentDialogWithButton(13)
					ATReportShow.v = false
					imgui.ShowCursor = false
				end) 
			end
			if imgui.Button(fai.ICON_FA_INFO_CIRCLE .. u8' Баг на сервере', imgui.ImVec2(135,20)) then
				lua_thread.create(function()
					sampSendDialogResponse(2349, 1, 0)
					wait(50)
					sampSendDialogResponse(2350, 1, 0)
					wait(50)
					if elements.prefix_answer.v then
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} Напишите в тех.раздел на форуме https://forumrds.ru '.. u8:decode(config.main.prefix_for_answer))
					else
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} Напишите в тех.раздел на форуме https://forumrds.ru')
					end
					wait(50)
					sampCloseCurrentDialogWithButton(13)
					ATReportShow.v = false
					imgui.ShowCursor = false
				end)
			end
			imgui.SameLine()
			if imgui.Button(fai.ICON_FA_TOGGLE_OFF .. u8' Не в сети', imgui.ImVec2(135,20)) then
				lua_thread.create(function()
					sampSendDialogResponse(2349, 1, 0)
					wait(50)
					sampSendDialogResponse(2350, 1, 0)
					wait(50)
					if elements.prefix_answer.v then
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} Игрок не в сети. '.. u8:decode(config.main.prefix_for_answer))
					else
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} Игрок не в сети. ')
					end
					wait(50)
					sampCloseCurrentDialogWithButton(13)
					ATReportShow.v = false
					imgui.ShowCursor = false
				end)
			end
			imgui.SameLine()
			if imgui.Button(fai.ICON_FA_CLOCK .. u8' Чист/нет наруш.', imgui.ImVec2(135,20)) then  
				lua_thread.create(function()
					sampSendDialogResponse(2349, 1, 0)
					wait(50)
					sampSendDialogResponse(2350, 1, 0)
					wait(50)
					if elements.prefix_answer.v then
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} Не вижу нарушений со стороны игрока. '.. u8:decode(config.main.prefix_for_answer))
					else
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} Не вижу нарушений со стороны игрока. ')
					end
					wait(50)
					sampCloseCurrentDialogWithButton(13)
					ATReportShow.v = false
					imgui.ShowCursor = false
				end)
			end
			imgui.Separator()
            if imgui.Button(fai.ICON_FA_QUESTION_CIRCLE .. u8" Ответы от AT", imgui.ImVec2(135,20)) then 
                elements.select_menu = 1
            end
            imgui.SameLine()
			if imgui.Button(fa.ICON_FA_SAVE .. u8" Сохр. ответы", imgui.ImVec2(135,20)) then  
				elements.select_menu = 2
			end	
			imgui.SameLine()
			if imgui.Button(fa.ICON_CHECK .. u8" Передать жб ##SEND", imgui.ImVec2(135,20)) then  
				lua_thread.create(function()
					sampSendDialogResponse(2349, 1, 0)
					wait(50)
					sampSendDialogResponse(2350, 1, 0)
					wait(50)
					if elements.prefix_answer.v then  
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} Передам ваш репорт! '.. u8:decode(config.main.prefix_for_answer))	
					else 
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} Передам ваш репорт! ')	
					end
					wait(50)
					sampCloseCurrentDialogWithButton(13)
					sampSendChat("/a " .. nick_rep .. "[" .. pid_rep .. "] | " .. text_rep)
                    ATReportShow.v = false  
					imgui.ShowCursor = false
				end)	
			end
			-- imgui.Text(u8'Длина текста:' .. (#elements.text.v))
            elements.prefix_for_answer.v = config.main.prefix_for_answer
            -- if imgui.InputText(u8'Ввод префикса', elements.prefix_for_answer) then  
            --     config.main.prefix_for_answer = elements.prefix_for_answer.v
            --     inicfg.save(config, directIni)
            -- end
            imgui.Separator()
            if imgui.Button(fai.ICON_FA_SMS .. u8" Ответить", imgui.ImVec2(110,20)) then
				if #elements.text.v < 70 then 
					lua_thread.create(function()
						sampSendDialogResponse(2349, 1, 0)
						wait(50)
						sampSendDialogResponse(2350, 1, 0)
						wait(50)
						if elements.prefix_answer.v then 
							local settext = '{FFFFFF}' .. elements.text.v .. ' ' .. color() .. config.main.prefix_for_answer
							sampSendDialogResponse(2351, 1, 0, u8:decode(settext))	
						else 
							local settext = '{FFFFFF}' .. elements.text.v
							sampSendDialogResponse(2351, 1, 0, u8:decode(settext))	
						end
						wait(50)
						sampCloseCurrentDialogWithButton(13)
						wait(50)
						elements.text.v = " "
					end)
					ATReportShow.v = false
				else 
					if (#elements.text.v + #config.main.prefix_for_answer) > 110 then 
						sampAddChatMessage(tag .. ' Длина вашего текста превышает ограничения. Измените текст. Либо уберите пожелание для ответа', -1)
					end
				end
            end  
            imgui.SameLine()
            if imgui.Button(fa.ICON_BAN .. u8" Отклонить", imgui.ImVec2(110,20)) then  
                lua_thread.create(function()
                    sampSendDialogResponse(2349, 1, 0)
                    wait(50)
                    sampSendDialogResponse(2350, 1, 1)
                    wait(50)
                    sampSendDialogResponse(2351, 0, 0)
                    ATReportShow.v = false
                    imgui.Process = ATReportShow.v 
                    imgui.ShowCursor = ATReportShow.v
                end)
            end
            imgui.SameLine()
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 115)
            if imgui.Button(fa.ICON_WINDOW_CLOSE .. u8" Закрыть", imgui.ImVec2(110,20)) then  
                lua_thread.create(function()
                    sampSendDialogResponse(2349, 0, 0)
                    wait(50)
                    sampSendDialogResponse(2348, 0, 0)
                    ATReportShow.v = false
                    imgui.Process = ATReportShow.v 
                    imgui.ShowCursor = ATReportShow.v
                end)
            end
			imgui.PopStyleVar(1)
            
            if imgui.BeginPopupModal(u8'Binder', false, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
                imgui.BeginChild("##EditBinder", imgui.ImVec2(600, 210), true)
                imgui.Text(u8'Название бинда:'); imgui.SameLine()
                imgui.PushItemWidth(130)
                imgui.InputText("##elements.binder_name", elements.binder_name)
                imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 100)
                if imgui.Button(u8'Закрыть##bind1', imgui.ImVec2(100,30)) then
                    elements.binder_name.v = ''
                    imgui.CloseCurrentPopup()
                end
                imgui.SameLine()
                if #elements.binder_name.v > 0 then
                    imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 1.01)
                    if imgui.Button(u8'Сохранить##bind1', imgui.ImVec2(100,30)) then
                        if not EditOldBind then
                            local refresh_text = elements.text.v:gsub("\n", "~")
                            table.insert(config.bind_name, elements.binder_name.v)
                            table.insert(config.bind_text, refresh_text)
                            if inicfg.save(config, directIni) then
                                sampAddChatMessage(tag .. 'Бинд"' ..u8:decode(elements.binder_name.v).. '" успешно создан!', -1)
                                elements.binder_name.v, elements.text.v = '', ''
                            end
                                imgui.CloseCurrentPopup()
                            else
                                local refresh_text = elements.text.v:gsub("\n", "~")
                                table.insert(config.bind_name, getpos, elements.binder_name.v)
                                table.insert(config.bind_text, getpos, refresh_text)
                                table.remove(config.bind_name, getpos + 1)
                                table.remove(config.bind_text, getpos + 1)
                            if inicfg.save(config, directIni) then
                                sampAddChatMessage(tag .. 'Бинд"' ..u8:decode(elements.binder_name.v).. '" успешно отредактирован!', -1)
                                elements.binder_name.v, elements.text.v = '', ''
                            end
                            EditOldBind = false
                            imgui.CloseCurrentPopup()
                        end
                    end
                end
                imgui.EndChild()
                imgui.EndPopup()
            end	
        end

        if elements.select_menu == 1 then  
            imgui.BeginChild("##menuSecond", imgui.ImVec2(155, 215), true)
			if imgui.Button(fa.ICON_OBJECT_GROUP .. u8" На кого-то/что-то", imgui.ImVec2(130, 0)) then  -- reporton key
				elements.select_category = 1  
			end; imgui.Tooltip(u8'Базовые ответы на простой репорт (читеры, или прочие простые вопросы не требующие особых ответов)')
			if imgui.Button(fa.ICON_LIST .. u8" Команды (/help)", imgui.ImVec2(130, 0)) then  -- HelpCMD key
				elements.select_category = 2 
			end; imgui.Tooltip(u8'Ответы по вопросам команд /help')
			if imgui.Button(fa.ICON_USERS .. u8" Банде/семья", imgui.ImVec2(130, 0)) then  -- HelpGangFamilyMafia key
				elements.select_category = 3
			end; imgui.Tooltip(u8'Ответы по вопросам организаций')
			if imgui.Button(fa.ICON_MAP_MARKER .. u8" Телепорты", imgui.ImVec2(130, 0)) then  -- HelpTP key
				elements.select_category = 4
			end; imgui.Tooltip(u8'Ответы по вопросам телепортаций.')
			if imgui.Button(fa.ICON_SHOPPING_BAG .. u8" Бизнесы", imgui.ImVec2(130, 0)) then  -- HelpBuz key
				elements.select_category = 5 
			end; imgui.Tooltip(u8'Ответы по вопросам бизнесов.')
			if imgui.Button(fa.ICON_MONEY .. u8" Продажа/Покупка", imgui.ImVec2(130, 0)) then  -- HelpSellBuy key
				elements.select_category = 6 
			end; imgui.Tooltip(u8'Ответы по вопросам продажи/покупки валюты.')
			if imgui.Button(fa.ICON_BOLT .. u8" Настройки", imgui.ImVec2(130, 0)) then  -- HelpSettings key
				elements.select_category = 7
			end; imgui.Tooltip(u8'Ответы по вопросам настроек (/settings)')
			if imgui.Button(fa.ICON_HOME .. u8" Дома", imgui.ImVec2(130, 0)) then  -- HelpHouses key
				elements.select_category = 8 
			end; imgui.Tooltip(u8'Ответы по вопросам недвижимости (дом)')
			if imgui.Button(fa.ICON_MALE .. u8" Скины", imgui.ImVec2(130, 0)) then  -- HelpSkins key
				elements.select_category = 9 
			end; imgui.Tooltip(u8'Ответы по вопросам скинов.')
			if imgui.Button(fa.ICON_BARCODE .. u8" Остальные ответы", imgui.ImVec2(130, 0)) then  -- HelpDefault key
				elements.select_category = 10
			end; imgui.Tooltip(u8'Ответы по вопросам, которые не входят ни в одну категорию')
			imgui.EndChild()
			imgui.SameLine()
			imgui.BeginChild("##menuSelectable", imgui.ImVec2(235, 215), true)
			if elements.select_category == 0 then  
				imgui.TextWrapped(u8"Ответы отсюда меняются только разработчиком.")
			end	
			if elements.select_category == 1 then  
				for key, v in pairs(questions) do
					if key == "reporton" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
								if not elements.prefix_answer.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								elements.select_category = 0
								elements.select_menu = 0 
							end
						end
					end
				end
			end	
			if elements.select_category == 2 then 
				for key, v in pairs(questions) do
					if key == "HelpCmd" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
								if not elements.prefix_answer.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								report_ans = 0
							end
						end
					end
				end
			end	
			if elements.select_category == 3 then  
				for key, v in pairs(questions) do
					if key == "HelpGangFamilyMafia" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
								if not elements.prefix_answer.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								report_ans = 0
							end
						end
					end
				end
			end	
			if elements.select_category == 4 then  
				for key, v in pairs(questions) do
					if key == "HelpTP" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
								if not elements.prefix_answer.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								report_ans = 0
							end
						end
					end
				end
			end	
			if elements.select_category == 6 then  
				for key, v in pairs(questions) do
					if key == "HelpSellBuy" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
								if not elements.prefix_answer.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								report_ans = 0
							end
						end
					end
				end
			end	
			if elements.select_category == 10 then  
				for key, v in pairs(questions) do
					if key == "HelpDefault" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
								if not elements.prefix_answer.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								report_ans = 0
							end
						end
					end
				end
			end	
			if elements.select_category == 9 then  
				for key, v in pairs(questions) do
					if key == "HelpSkins" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
								if not elements.prefix_answer.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								report_ans = 0
							 end
						 end
					end
				end
			end	
			if elements.select_category == 7 then  
				for key, v in pairs(questions) do
					if key == "HelpSettings" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
								if not elements.prefix_answer.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								report_ans = 0
							end
						end
					end
				end
			end	
			if elements.select_category == 8 then  
				for key, v in pairs(questions) do
					if key == "HelpHouses" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
								if not elements.prefix_answer.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								report_ans = 0
							end
						end
					end
				end
			end	
			if elements.select_category == 5 then  
				for key, v in pairs(questions) do
					if key == "HelpBuz" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
								if not elements.prefix_answer.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								report_ans = 0
							end
						end
					end
				end
			end	
			imgui.EndChild()
        end

        if elements.select_menu == 2 then   
            if #config.bind_name > 0 then  
				for key_bind, name_bind in pairs(config.bind_name) do  
					if imgui.Button(name_bind.. '##'..key_bind) then  
                        elements.select_menu = 0
						SendBind_Report(key_bind)
					end	
				end	
			else 
				imgui.Text(u8"Пусто!")
				if imgui.Button(u8"Создать!") then  
					imgui.OpenPopup(u8'Биндер')	 
				end	
			end	
			if imgui.BeginPopupModal(u8'Биндер', false, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
				imgui.BeginChild("##EditBinder", imgui.ImVec2(600, 225), true)
				imgui.Text(u8'Название бинда:'); imgui.SameLine()
				imgui.PushItemWidth(130)
				imgui.InputText("##elements.binder_name", elements.binder_name)
				imgui.PopItemWidth()
				imgui.PushItemWidth(100)
				imgui.Separator()
				imgui.Text(u8'Текст бинда:')
				imgui.PushItemWidth(300)
				imgui.InputTextMultiline("##elements.binder_text", elements.binder_text, imgui.ImVec2(-1, 110))
				imgui.PopItemWidth()
	
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 100)
				if imgui.Button(u8'Закрыть##bind1', imgui.ImVec2(100,30)) then
					elements.binder_name.v, elements.binder_text.v, elements.binder_delay.v = '', '', "2500"
					imgui.CloseCurrentPopup()
				end
				imgui.SameLine()
				if #elements.binder_name.v > 0 and #elements.binder_text.v > 0 then
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 1.01)
					if imgui.Button(u8'Сохранить##bind1', imgui.ImVec2(100,30)) then
						if not EditOldBind then
							local refresh_text = elements.binder_text.v:gsub("\n", "~")
							table.insert(config.bind_name, elements.binder_name.v)
							table.insert(config.bind_text, refresh_text)
							table.insert(config.bind_delay, elements.binder_delay.v)
							if inicfg.save(config, directIni) then
								sampAddChatMessage(tag .. 'Бинд"' ..u8:decode(elements.binder_name.v).. '" успешно создан!', -1)
								elements.binder_name.v, elements.binder_text.v, elements.binder_delay.v = '', '', "2500"
							end
								imgui.CloseCurrentPopup()
							else
								local refresh_text = elements.binder_text.v:gsub("\n", "~")
								table.insert(config.bind_name, getpos, elements.binder_name.v)
								table.insert(config.bind_text, getpos, refresh_text)
								table.insert(config.bind_delay, getpos, elements.binder_delay.v)
								table.remove(config.bind_name, getpos + 1)
								table.remove(config.bind_text, getpos + 1)
								table.remove(config.bind_delay, getpos + 1)
							if inicfg.save(config, directIni) then
								sampAddChatMessage(tag .. 'Бинд"' ..u8:decode(elements.binder_name.v).. '" успешно отредактирован!', -1)
								elements.binder_name.v, elements.binder_text.v, elements.binder_delay.v = '', '', "2500"
							end
							EditOldBind = false
							imgui.CloseCurrentPopup()
						end
					end
	
				end
				imgui.EndChild()
				imgui.EndPopup()
			end
			imgui.Separator()
			if imgui.Button(fa.ICON_BACKWARD .. u8" Назад") then  
				elements.select_menu = 0 
			end	
        end

        imgui.End()
    end
end

function SendBind_Report(num)
	lua_thread.create(function()
		if num ~= -1 then
			for bp in config.bind_text[num]:gmatch('[^~]+') do
				sampSendDialogResponse(2349, 1, 0)
				sampSendDialogResponse(2350, 1, 0)
				wait(50)
				sampSendDialogResponse(2351, 1, 0, u8:decode(tostring(bp)))
				wait(50)
				sampCloseCurrentDialogWithButton(13)
				-- sampAddChatMessage(u8:decode(tostring(bp)), -1)
			end
			num = -1
		end
	end)
end