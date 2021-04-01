script_name('AdminTool') -- название скрипта
script_author('FedoseevEgor, aka. alfantasy, feat. Unite, Liquit, Natsuki, Shtormo, Yuri_Dan__') -- автор скрипта
script_description('Скрипт для облегчения работы администраторам') -- описание скрипта

require "lib.moonloader" -- подключение основной библиотеки mooloader
local keys = require "vkeys" -- регистр для кнопок
local imgui = require 'imgui' -- регистр imgui окон
local dlstatus = require('moonloader').download_status
local encoding = require 'encoding' -- дешифровка форматов
local inicfg = require 'inicfg' -- работа с ini
local sampev = require "lib.samp.events" -- поключение основных библиотек, связанные с потокам пакетов ивентов SA:MP, и их прямое соединение с LUA
encoding.default = 'CP1251' -- смена кодировки на CP1251
u8 = encoding.UTF8 -- переименовка стандтартного режима кодировки UTF8 - u8
local mcolor -- локальная переменная для регистрации рандомного цвета

local themes = import "module/imgui_themes.lua" -- подключение плагина тем
local notify = import "module/lib_imgui_notf.lua" -- подключение плагина уведомлений

local tag = "{87CEEB}[AdminTool]  {4169E1}" -- локальная переменная, которая регистрирует тэг AT
local label = 0
local main_color = 0xe01df2
local text_color = 0x4169E1
local main_color_text = "{6e73f0}"
local white_color = "{FFFFFF}"

local ans_imgui = imgui.ImBool(false)
local good_game_prefix = imgui.ImBool(false)
local ans_text = imgui.ImBuffer(4096)
local ans_report = imgui.ImBool(false)

-------- Введение локальные переменные, отвечающие за автообновление ----------

update_state = false

local script_version_ans = 4
local script_version_ans_text = "3.0"
local script_path = thisScript().path 
local script_url = "https://raw.githubusercontent.com/alfantasy/AdminTool/main/AdminToolAns.lua"
local update_path = getWorkingDirectory() .. '/ANSupdate.ini'
local update_url = "https://raw.githubusercontent.com/alfantasy/AdminTool/main/ANSupdate.ini"
-------- Введение локальные переменные, отвечающие за автообновление ----------

local questions = {
    ["reporton"] = {
        [u8"Начало работы по жалобе"] = "Начал(а) работу по вашей жалобе!",
		[u8"Жалоба на админа"] = "Пишите жалобу на администратора в VK: vk.com/dmdriftgta",
		[u8"Жалоба на игрока"] = "Вы можете оставить жалобу на игрока в VK: vk.com/dmdriftgta",
		[u8"Помогли вам"] = "Помогли вам.",
		[u8"Ожидайте"] = "Ожидайте.",
		[u8"Приятного времяпрепровождения"] = "Приятного времяпрепровождения на Russian Drift Server!",
		[u8"Игрок чист"] = " Данный игрок чист.",
		[u8"Игрок не в сети"] = "Данный игрок не в сети.",
		[u8"Уточнение вопрос/запрос"] = "Уточните ваш вопрос/запрос.",
		[u8"Уточнение ID"] = "Уточните ID нарушителя/читера в /report",
		[u8"Игрок наказан"] = "Данный игрок наказан.",
		[u8"Проверим"] = "'Проверим. ",
		[u8"ГМ не работает"] = "GodMode (ГодМод) на сервере не работает.",
		[u8"Никак"] = "Никак.",
		[u8"Да"] = "Да.",
		[u8"Нет"] = "Нет.",
		[u8"Не запрещено"] = "Не запрещено.",
		[u8"Не знаем"] = "Не знаем.",
		[u8"Нельзя оффтопить"] = "Не оффтопьте.",
		[u8"Не выдаем"] = "Не выдаем.",
		[u8"Это баг"] = "Скорей всего - это баг.",
		[u8"Перезайдите"] = "Попробуйте перезайти."
    },
	["HelpCmd"] = {
		[u8"Команды VIP`а"] = "Данную информацию можно найти в /help -> 7 пункт.",
		[u8"Команды для свадьбы"] = "Данную информацию можно найти в /help -> 8 пункт.",
		[u8"Как заработать валюту"] = "Данную информацию можно найти в /help -> 13 пункт.",
		[u8"Информация в инете"] = "Данную информацию можно узнать в интернете.",
		[u8"Привелегия Premuim"] = "Данный игрок с привелегией Premuim VIP (/help -> 7)",
		[u8"Привелегия Diamond"] = "Данный игрок с привелегией Diamond VIP (/help -> 7) ",
		[u8"Привелегия Platinum"] = "Данный игрок с привелегией Platinum VIP (/help -> 7)",
		[u8"Привелегия Личный"] = "Данный игрок с привелегией «Личный» VIP (/help -> 7)",
		[u8"Как получать админку"] = "Ожидать набор, или же /help -> 17 пункт."
	},
	["HelpGangFamilyMafia"] = {
		[u8"Как открыть меню семьи"] = "/menu (/mm) - ALT/Y -> Система банд",
		[u8"Как открыть меню банды"] = "/familypanel",
		[u8"Как исключить игрока"] = "/guninvite (банда) || /funinvite (семья)",
		[u8"Как пригласить игрока"] = "/ginvite (банда) || /finvite (семья)",
		[u8"Как покинуть банду/семью"] = "/gleave (банда) || /fleave (семья)",
		[u8"Как покинуть мафию"] = "/leave",
		[u8"Как выдать выговор"] = "/gvig // Должна быть лидерка"
	},
	["HelpTP"] = {
		[u8"Как тп в автосалон"] = "tp -> Разное -> Автосалоны",
		[u8"Как тп в автомастерскую"] = "/tp -> Разное -> Автосалоны -> Автомастерская",
		[u8"Как тп в банк"] = "Оплатить бизнес/дом можно с помощью /bank или /tp -> Разное -> Банк",
		[u8"Как ваще тп"] = "/tp (по локациям), /g (/goto) id (к игроку) с VIP (/help -> 7 пункт)"

	},
	["HelpSellBuy"] = {
		[u8"Как продать аксы"] = "Продать аксессуары, или купить можно на /trade. Чтобы продать, /sell около лавки",
		[u8"Как обменять валюту"] = "Чтобы обменять валюту, введите /trade, и подойдите к NPC Арману, стоит справа",
		[u8"А как продать тачку"] = "/sellmycar IDPlayer Слот1-3 Сумма || /car -> Слот1-3 -> Продать государству",
		[u8"А домик как продать"] = "/hpanel -> Слот1-3 -> Изменить -> Продать дом государству || /sellmyhouse (игроку)"
	},
	["HelpGiveEveryone"] = {
		[u8"Как передать деньги"] = "/givemoney IDPlayer money",
		[u8"Как передать очки"] = "/givescore IDPlayer score",
		[u8"Как передать рубли"] = "/giverub IDPlayer rub | С Личного (/help -> 7)",
		[u8"Как передать коины"] = "/givecoin IDPlayer coin | С Личного (/help -> 7)"
	},
	["HelpDefault"] = {
		[u8"А как цвет поставить"] = "Перед словом/буквой цвет в HTML. Цвет в {} - https://colorscheme.ru/html-colors.html",
		[u8"Машина"] = "/car",
		[u8"Как ограбить банк"] = 'Встать на пикап "Ограбление банка", после около ячеек нажимать на ALT и ехать на красный маркер на карте',
		[u8"Как взять оружие"] = "/menu (/mm) - ALT/Y -> Оружие",
		[u8"Как взять предметы"] = "/menu (/mm) - ALT/Y -> Предметы",
		[u8"Как детальки искать"] = "Детали разбросаны по всей карте. Обмен происходится на /garage. ",
		[u8"Казино, работы и бизнес"] = "Казино, работы, бизнес. ",
		[u8"Казик, мп, обмен на /trade и т.д."] = "Казино, МП, достижения, работы, обмен очков на коины(/trade)",
		[u8"Ссылка на офф.группу"] = "https://vk.com/dmdriftgta | Официальная группа.",
		[u8"Как начать капт"] = "Для того, чтобы начать капт, нужно ввести /capture",
		[u8"Как пассив вкл"] = "/passive",
		[u8"/statpl"] = "Чтобы посмотреть детали, очки, коины, рубли, вирты - /statpl",
		[u8"Смена пароля"] = "/mm -> Действия -> Сменить пароль",
		[u8"Спавн тачки"] = "/mm -> Транспортное средство -> Тип транспорта",
		[u8"Как добавить игрока в аренду"] = "/hpanel -> Слот1-3 -> Изменить -> Аренда дома",
		[u8"Как тюнить тачку"] = "/menu (/mm) - ALT/Y -> Т/С -> Тюнинг",
		[u8"Ну застрял игрок"] = "/kill | /tp | /spawn",
		[u8"Как попасть на дерби/пабг"] = "/join | Есть внутриигровые команды, следите за чатом",
		[u8"Виртуальный мир"] = "/dt 0-990 / Виртуальный мир"
	},
	["HelpSkins"] = {
		[u8"Копы"] = "65-267, 280-286, 288, 300-304, 306, 307, 309-311",
		[u8"Балласы"] = "102-104",
		[u8"Грув"] = "105-107",
		[u8"Триад"] = "117-118, 120",
		[u8"Вагосы"] = "108-110",
		[u8"Ру.Мафия"] = "111-113",
		[u8"Вариосы"] = "114-116",
		[u8"Мафия"] = "124-127"
	}
}

-- for CHECKBOX
	local checked_test = imgui.ImBool(false)
	local checked_test_2 = imgui.ImBool(false)
--

-- for RADIO
	local checked_radio = imgui.ImInt(1)
--

-- for COMBO
	local combo_select = imgui.ImInt(0)
--

local sw2, sh2 = getScreenResolution()

function SetStyle()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	style.ScrollbarSize = 13.0
	style.ScrollbarRounding = 0
	style.ChildWindowRounding = 4.0
	colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.ComboBg]                = colors[clr.PopupBg]
	colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
	colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
	colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
	colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
	colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
	colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)-- (0.1, 0.9, 0.1, 1.0)
	colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
	colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
	colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
	colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
	colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
	colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
	colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
	colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
	colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
end
SetStyle()


function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end

	downloadUrlToFile(update_url, update_path, function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then  
			updateIni = inicfg.load(nil, update_path)
			if tonumber(updateIni.info.version_ans) > script_version_ans then 
				sampAddChatMessage(tag .. "Есть обновление! Версия: " .. updateIni.info.version_text_ans, -1)
				update_state = true
			end
			os.remove(update_path)
		end
	end)

	------------------ Показ запуска скрипта, указ автора и функций -------------------------
	sampAddChatMessage("{87CEEB}[AdminTool] {4169E1} Подгрузка дополнительного скрипта для репортов", 0xe01df2)
	sampAddChatMessage("{87CEEB}[AdminTool] {4169E1} Подгрузка произошла успешно!", 0xe01df2)
	------------------ Показ запуска скрипта, указ автора и функций -------------------------

	-- просмотр ID -- 
	_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	nick = sampGetPlayerNickname(id)

	imgui.Process = false
	res = false

	thread = lua_thread.create_suspended(thread_function)

	imgui.SwitchContext()
	themes.SwitchColorTheme()
	-- введение смены темы на imgui окно.

	--sampAddChatMessage("Скрипт imgui перезагружен", -1)

	while true do
		wait(0)

		if sampGetCurrentDialogId() ~= 2351 then
			ans_imgui.v = false
			imgui.Process = false
		end
		if sampGetCurrentDialogId() == 2351 then
			ans_imgui.v = true
			imgui.Process = true
		end
	end
end

function color1() -- функция, выполняющая рандомнизацию и вывод рандомного цвета с помощью специального os.time()
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

function closeAnsWithText(text)
	lua_thread.create(function()
	sampSendDialogResponse(2349, 1, 0)
	sampSendDialogResponse(2350, 1, 0)
	wait(200)
	sampSendDialogResponse(2351, 1, 0, text)
	wait(200)
	sampCloseCurrentDialogWithButton(13)
	main_window_state.v = false
	imgui.Process = false
end)
end


local W_Win = sw2/1.280
local H_Win = 1
function imgui.OnDrawFrame()
    if ans_imgui.v then 
        imgui.SetNextWindowPos(imgui.ImVec2(sw2 / 2, (sh2 / 2) + 320), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(550, 285), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"Ответы на репорты", ans_imgui)
        local btn_size = imgui.ImVec2(-0.1, 0)

        imgui.Checkbox(u8"Пожелание в ответе", good_game_prefix)
		imgui.BeginChild('##Select Setting', imgui.ImVec2(230, 225), true)

		if imgui.Selectable(u8"Свой ответ") then ans_report.v = true end

        if imgui.Selectable(u8"Жалобы на что-то/кого-то", beginchild == 1) then beginchild = 1 end
		if imgui.Selectable(u8"Вопросы по командам, /help", beginchild == 2) then beginchild = 2 end
		if imgui.Selectable(u8"Помощь по банде/семье", beginchild == 3) then beginchild = 3 end
		if imgui.Selectable(u8"Помощь по телепортации", beginchild == 4) then beginchild = 4 end
		if imgui.Selectable(u8"Помощь по продаже/покупке", beginchild == 5) then beginchild = 5 end
		if imgui.Selectable(u8"Помощь по передаче чего-то", beginchild == 6) then beginchild = 6 end
		if imgui.Selectable(u8"Остальные независимые вопросы", beginchild == 7) then beginchild = 7 end
		if imgui.Selectable(u8"Скины", beginchild == 8) then beginchild = 8 end


		imgui.EndChild()

		imgui.SameLine()


		if ans_report.v then   
			imgui.SetNextWindowPos(imgui.ImVec2(sw2 / 2, (sh2 / 2) - 320), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.SetNextWindowSize(imgui.ImVec2(400, 285), imgui.Cond.FirstUseEver)
				imgui.Begin(u8"Собственный ответ в /ans", ans_report)
					imgui.Text(u8"Введите свой ответ")

						imgui.InputText(u8"##Ответ", ans_text)
						imgui.Separator()
						if imgui.Button(u8"Ответить") then  
								local settext2 = '{FFFFFF}' .. ans_text.v
								sampSendDialogResponse(2351, 1, 0, u8:decode(settext2))	
								sampCloseCurrentDialogWithButton(13)
								ans_report.v = false	
						end
						imgui.Separator()
						if imgui.Button(u8"Очистить текст") then  
							ans_text.v = ""
						end
				imgui.End()
		end

    	if beginchild == 1 then
           imgui.BeginChild("##Reports", imgui.ImVec2(280, 225), true)
         for key, v in pairs(questions) do
			if key == "reporton" then
				for key_2, v_2 in pairs(questions[key]) do
					if imgui.Button(key_2, btn_size) then
						if not good_game_prefix.v then
							local settext = '{FFFFFF}' .. v_2
							sampSendDialogResponse(2351, 1, 0, settext)
							sampCloseCurrentDialogWithButton(13)
						else
							local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // Приятной игры на сервере RDS <3'
							sampSendDialogResponse(2351, 1, 0, settext)
							sampCloseCurrentDialogWithButton(13)
						end
					end
				end
				end
				end
            imgui.EndChild()
			end
			if beginchild == 2 then
				imgui.BeginChild("##HelpCmd", imgui.ImVec2(280, 225), true)
			  	for key, v in pairs(questions) do
					if key == "HelpCmd" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2, btn_size) then
								if not good_game_prefix.v then
									local settext = '{FFFFFF}' .. v_2
										sampSendDialogResponse(2351, 1, 0, settext)
										sampCloseCurrentDialogWithButton(13)
								else
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // Приятной игры на сервере RDS <3'
										sampSendDialogResponse(2351, 1, 0, settext)
										sampCloseCurrentDialogWithButton(13)
								end
						 	end
					 	end
					end
				end
				imgui.EndChild()
			end
			if beginchild == 3 then
				imgui.BeginChild("##HelpGangFamilyMafia", imgui.ImVec2(280, 225), true)
			  	for key, v in pairs(questions) do
					if key == "HelpGangFamilyMafia" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2, btn_size) then
								if not good_game_prefix.v then
									local settext = '{FFFFFF}' .. v_2
										sampSendDialogResponse(2351, 1, 0, settext)
										sampCloseCurrentDialogWithButton(13)
								else
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // Приятной игры на сервере RDS <3'
										sampSendDialogResponse(2351, 1, 0, settext)
										sampCloseCurrentDialogWithButton(13)
								end
						 	end
					 	end
					end
				end
				imgui.EndChild()
			end
			if beginchild == 4 then
				imgui.BeginChild("##HelpTP", imgui.ImVec2(280, 225), true)
			  	for key, v in pairs(questions) do
					if key == "HelpTP" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2, btn_size) then
								if not good_game_prefix.v then
									local settext = '{FFFFFF}' .. v_2
										sampSendDialogResponse(2351, 1, 0, settext)
										sampCloseCurrentDialogWithButton(13)
								else
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // Приятной игры на сервере RDS <3'
										sampSendDialogResponse(2351, 1, 0, settext)
										sampCloseCurrentDialogWithButton(13)
								end
						 	end
					 	end
					end
				end
				imgui.EndChild()
			end
			if beginchild == 5 then
				imgui.BeginChild("##HelpSellBuy", imgui.ImVec2(280, 225), true)
			  	for key, v in pairs(questions) do
					if key == "HelpSellBuy" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2, btn_size) then
								if not good_game_prefix.v then
									local settext = '{FFFFFF}' .. v_2
										sampSendDialogResponse(2351, 1, 0, settext)
										sampCloseCurrentDialogWithButton(13)
								else
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // Приятной игры на сервере RDS <3'
										sampSendDialogResponse(2351, 1, 0, settext)
										sampCloseCurrentDialogWithButton(13)
								end
						 	end
					 	end
					end
				end
				imgui.EndChild()
			end
			if beginchild == 6 then
				imgui.BeginChild("##HelpGiveEveryone", imgui.ImVec2(280, 225), true)
			  	for key, v in pairs(questions) do
					if key == "HelpGiveEveryone" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2, btn_size) then
								if not good_game_prefix.v then
									local settext = '{FFFFFF}' .. v_2
										sampSendDialogResponse(2351, 1, 0, settext)
										sampCloseCurrentDialogWithButton(13)
								else
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // Приятной игры на сервере RDS <3'
										sampSendDialogResponse(2351, 1, 0, settext)
										sampCloseCurrentDialogWithButton(13)
								end
						 	end
					 	end
					end
				end
				imgui.EndChild()
			end
			if beginchild == 7 then
				imgui.BeginChild("##HelpDefault", imgui.ImVec2(280, 225), true)
			  	for key, v in pairs(questions) do
					if key == "HelpDefault" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2, btn_size) then
								if not good_game_prefix.v then
									local settext = '{FFFFFF}' .. v_2
										sampSendDialogResponse(2351, 1, 0, settext)
										sampCloseCurrentDialogWithButton(13)
								else
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // Приятной игры на сервере RDS <3'
										sampSendDialogResponse(2351, 1, 0, settext)
										sampCloseCurrentDialogWithButton(13)
								end
						 	end
					 	end
					end
				end
				imgui.EndChild()
			end
			if beginchild == 8 then
				imgui.BeginChild("##HelpSkins", imgui.ImVec2(280, 225), true)
			  	for key, v in pairs(questions) do
					if key == "HelpSkins" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2, btn_size) then
								if not good_game_prefix.v then
									local settext = '{FFFFFF}' .. v_2
										sampSendDialogResponse(2351, 1, 0, settext)
										sampCloseCurrentDialogWithButton(13)
								else
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // Приятной игры на сервере RDS <3'
										sampSendDialogResponse(2351, 1, 0, settext)
										sampCloseCurrentDialogWithButton(13)
								end
						 	end
					 	end
					end
				end
				imgui.EndChild()
			end
        imgui.End()
    end
end
