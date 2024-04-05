script_name('AdminTool-Reports')
script_description('Часть пакета AdminTool. Является системой ответов на репорты.')
script_author('alfantasyz')

-- ## Регистрация библиотек, плагинов и аддонов ## --
require 'lib.moonloader'
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
        prefix_answer = false, 
        prefix_for_answer = " // Приятной игры на сервере RDS <3",
    },
    bind_name = {},
    bind_text = {},
    bind_delay = {},
}, directIni)
inicfg.save(config, directIni)

local elements = {
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
		[u8"IP RDS 02"] = "46.174.55.87:7777",
		[u8"IP RDS 03"] = "46.174.49.170:7777",
		[u8"IP RDS 04"] = "46.174.55.169:7777",
		[u8"IP RDS 05"] = "62.122.213.75:7777",
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
	sampRegisterChatCommand("h14", cmd_h14)
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
	sampRegisterChatCommand("ngm", cmd_ngm)
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

-- ## Блок функций - быстрых ответов в чате ## --
function cmd_ngm(arg)
	sampSendChat("/ans " .. arg .. " Данный игрок покинул игру. // Приятной игры на RDS <3")
end

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

function cmd_h14(arg)
	sampSendChat("/ans " .. arg .. " Узнать данную информацию можно в /help -> 14 пункт. | Приятной игры на RDS. <3 ")
end

function cmd_zba(arg)
	sampSendChat("/ans " .. arg .. " Админ наказал не так? Пишите жалобу на форум https://forumrds.ru")
end

function cmd_zbp(arg)
	sampSendChat("/ans " .. arg .. " Пишите жалобу на игрока на форум https://forumrds.ru")
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
	sampSendChat("/ans " .. arg .. " Уточните вашу жалобу/вопрос. | Приятной игры на RDS <3")
end

function cmd_drb(arg)
	sampSendChat("/ans " .. arg .. " /derby - записатся на дерби | Приятной игры на RDS 02 <3 ")
end

function cmd_smc(arg)
	sampSendChat("/ans " .. arg .. " /sellmycar IDPlayer Слот(1-3) RDScoin (игроку), в гос: /car ")
end

function cmd_c(arg)
	lua_thread.create(function()
		sampSendChat("/ans " .. arg .. " Начал(а) работу по вашей жалобе. | Приятной игры на RDS <3")
		wait(1000)
		sampSetChatInputEnabled(true)
		sampSetChatInputText("/re " )
	end)
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
	lua_thread.create(function()
		sampSendChat("/ans " .. arg .. " Здравствуйте! Произошла ошибка в ID! Наказание снято. ")
		sampSendChat("/ans " .. arg .. " Приятного времяпрепровождения на Russian Drift Server! ")
	end)
end

function cmd_al(arg)
	lua_thread.create(function()
		sampSendChat("/ans " .. arg .. " Здравствуйте! Вы забыли ввести /alogin! ")
		sampSendChat("/ans " .. arg .. " Введите команду /alogin и свой пароль, пожалуйста.")
	end)
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
	sampSendChat("/ans" .. arg .. " Продать аксессуары, или купить можно на /trade. Чтобы продать, F у лавки ")
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
	sampSendChat("/ans " .. arg .. " Ожидать набор, или же /help -> 18 пункт. | Приятной игры на RDS. <3")
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
-- ## Блок функций - быстрых ответов в чате ## --


-- ## Блок обработки ивентов и пакетов SA:MP ## -- 
function sampev.onServerMessage(color, text)
    if text:find("Администратор уже проверяет данную жалобу") then  
        sampAddChatMessage(tag .. " Какой-то администратор уже проверяет жалобу. Если интерфейс включен, он закроется :(")
        ATReportShow.v = false
        imgui.Process = ATReportShow.v 
        return false
    end
end

function sampev.onShowDialog(id, style, title, button1, button2, text)
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

    if ATReportShow.v then  
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5)) 
        imgui.SetNextWindowSize(imgui.ImVec2(400, 300), imgui.Cond.FirstUseEver)

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
        imgui.EndMenuBar()

        if elements.select_menu == 0 then
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
            imgui.InputText('##Ответ', elements.text) 
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
            imgui.Separator()
            if imgui.Button(fa.ICON_FA_EYE .. u8" Работа по жб") then  
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
            if imgui.Button(fa.ICON_BAN .. u8" Наказан") then
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
			if imgui.Button(fa.ICON_COMMENTING_O .. u8" Уточните ID") then  
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
			if imgui.Button(fa.ICON_FA_EDIT .. u8" Уточните жб") then  
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
			if imgui.Button(fa.ICON_CHECK .. u8" Передать жалобу ##SEND") then  
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
            if imgui.Button(fai.ICON_FA_QUESTION_CIRCLE .. u8" Ответы от AT") then 
                elements.select_menu = 1
            end
            imgui.SameLine()
			if imgui.Button(fa.ICON_FA_SAVE .. u8" Сохраненные ответы") then  
				elements.select_menu = 2
			end	
            imgui.Separator()
			-- imgui.Text(u8'Длина текста:' .. (#elements.text.v))
			if imgui.Checkbox(u8"Пожелание в ответ", elements.prefix_answer) then 
				config.main.prefix_answer = elements.prefix_answer.v
				inicfg.save(config, directIni)
			end; imgui.Tooltip(u8"Автоматически при ответе через кнопочки будет желать то, что вы зарегистрируете")
            elements.prefix_for_answer.v = config.main.prefix_for_answer
            if imgui.InputText(u8'Ввод префикса', elements.prefix_for_answer) then  
                config.main.prefix_for_answer = elements.prefix_for_answer.v
                inicfg.save(config, directIni)
            end
            imgui.SetCursorPosY(imgui.GetWindowWidth() - 135)
            imgui.Separator()
            imgui.SetCursorPosY(imgui.GetWindowWidth() - 125)
            if imgui.Button(u8" Ответить") then
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
            if imgui.Button(fa.ICON_BAN .. u8" Отклонить") then  
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
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 80)
            if imgui.Button(fa.ICON_WINDOW_CLOSE .. u8" Закрыть") then  
                lua_thread.create(function()
                    sampSendDialogResponse(2349, 0, 0)
                    wait(50)
                    sampSendDialogResponse(2348, 0, 0)
                    ATReportShow.v = false
                    imgui.Process = ATReportShow.v 
                    imgui.ShowCursor = ATReportShow.v
                end)
            end
            
            if imgui.BeginPopupModal(u8'Binder', false, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
                imgui.BeginChild("##EditBinder", imgui.ImVec2(600, 225), true)
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
            imgui.BeginChild("##menuSecond", imgui.ImVec2(150, 275), true)
			if imgui.Button(fa.ICON_OBJECT_GROUP .. u8" На кого-то/что-то", imgui.ImVec2(135, 0)) then  -- reporton key
				elements.select_category = 1  
			end	
			if imgui.Button(fa.ICON_LIST .. u8" Команды (/help)", imgui.ImVec2(135, 0)) then  -- HelpCMD key
				elements.select_category = 2 
			end 	
			if imgui.Button(fa.ICON_USERS .. u8" Банде/семья", imgui.ImVec2(135, 0)) then  -- HelpGangFamilyMafia key
				elements.select_category = 3
			end	
			if imgui.Button(fa.ICON_MAP_MARKER .. u8" Телепорты", imgui.ImVec2(135, 0)) then  -- HelpTP key
				elements.select_category = 4
			end	
			if imgui.Button(fa.ICON_SHOPPING_BAG .. u8" Бизнесы", imgui.ImVec2(135, 0)) then  -- HelpBuz key
				elements.select_category = 5 
			end	
			if imgui.Button(fa.ICON_MONEY .. u8" Продажа/Покупка", imgui.ImVec2(135, 0)) then  -- HelpSellBuy key
				elements.select_category = 6 
			end	
			if imgui.Button(fa.ICON_BOLT .. u8" Настройки", imgui.ImVec2(135, 0)) then  -- HelpSettings key
				elements.select_category = 7
			end	
			if imgui.Button(fa.ICON_HOME .. u8" Дома", imgui.ImVec2(135, 0)) then  -- HelpHouses key
				elements.select_category = 8 
			end	
			if imgui.Button(fa.ICON_MALE .. u8" Скины", imgui.ImVec2(135, 0)) then  -- HelpSkins key
				elements.select_category = 9 
			end	
			if imgui.Button(fa.ICON_BARCODE .. u8" Остальные ответы", imgui.ImVec2(135, 0)) then  -- HelpDefault key
				elements.select_category = 10
			end	
			imgui.Separator()
			if imgui.Button(fa.ICON_BACKWARD .. u8" Назад") then  
				elements.select_menu = 0 
			end	
			imgui.EndChild()
			imgui.SameLine()
			imgui.BeginChild("##menuSelectable", imgui.ImVec2(390, 275), true)
			if elements.select_category == 0 then  
				imgui.Text(u8"Заготовленные/сохраненные ответы \nтакого типа меняются \nтолько разработчиками")
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
					elements.binder_name.v, elements.binder_text.v, elements.binder_delay.v = '', '', 2500
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
							if save() then
								sampAddChatMessage(tag .. 'Бинд"' ..u8:decode(elements.binder_name.v).. '" успешно создан!', -1)
								elements.binder_name.v, elements.binder_text.v, elements.binder_delay.v = '', '', 2500
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
							if save() then
								sampAddChatMessage(tag .. 'Бинд"' ..u8:decode(elements.binder_name.v).. '" успешно отредактирован!', -1)
								elements.binder_name.v, elements.binder_text.v, elements.binder_delay.v = '', '', 2500
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