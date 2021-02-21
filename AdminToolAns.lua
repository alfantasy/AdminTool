script_name('AdminTool') -- название скрипта
script_author('FedoseevEgor, aka. alfantasy, feat. Unite, Liquit, Natsuki, Shtormo, Yuri_Dan__') -- автор скрипта
script_description('Скрипт для облегчения работы администраторам') -- описание скрипта

require "lib.moonloader" -- подключение основной библиотеки mooloader
local keys = require "vkeys" -- регистр для кнопок
local imgui = require 'imgui' -- регистр imgui окон
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

local main_window_state = imgui.ImBool(false)

-------- Введение локальные переменные, отвечающие за автообновление ----------

update_state = false

local script_version_ans = 2
local script_version_ans_text = "2.0"
local script_path = thisScript().path 
local script_url = "https://raw.githubusercontent.com/alfantasy/AdminTool/main/AdminToolAns.lua"
local update_path = getWorkingDirectory() .. '/ATANSupdate.ini'
local update_url = "https://raw.githubusercontent.com/alfantasy/AdminTool/main/ANSupdate.ini"
-------- Введение локальные переменные, отвечающие за автообновление ----------

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

	------- Команды для запуска интерфейса ------- 
    sampRegisterChatCommand("ant", cmd_ant)

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

		if update_state then  
			downloadUrlToFile(script_url, script_path, function(id, status)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then  
					sampAddChatMessage(tag .. "AdminTool обновлен.", -1)
					thisScript():reload()
				end
			end)
			break
		end

        if sampGetCurrentDialogId() ~= 2349 then
			main_window_state.v = false
			imgui.Process = false
		end
		if sampGetCurrentDialogId() == 2349 then
			main_window_state.v = true
			imgui.Process = true
		end
	end
end

function cmd_ant(arg)
    main_window_state.v = not main_window_state.v
    imgui.Process = main_window_state.v
end
-- первоначальный интерфейс AdminTool

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

function imgui.OnDrawFrame()
	if main_window_state.v == true then
        imgui.SetNextWindowPos(imgui.ImVec2(sw2 / 2, (sh2 / 2) + 320), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(600, 400), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'Ответы', main_window_state)
		if imgui.CollapsingHeader(u8"Вывод текстовых команд") then
			imgui.Text(u8"Команды введение на английском языке: используются лишь на чат")
			imgui.Text(u8"А те, которые на русском и в скобках после значка $ пишутся в окне /ans")
			imgui.Text(u8"Если случайно написали .нч на английском, т.е. /yx - все равно выведится. Введен перевод")
			imgui.Text(u8".ц (/w) - вывод рандомного цвета, для своих ответов")
			imgui.Text(u8"")
			imgui.Separator()
			imgui.Text("  ")
			if imgui.CollapsingHeader(u8"Быстрые ответы /ans") then
				imgui.Separator()
				if imgui.CollapsingHeader(u8"Жалобы на кого-то/что-то") then
					imgui.Text(u8".нч - начал(а) работать по жалобе")
					imgui.Text(u8" .сл - слежу за игроком | .ож - ожидайте")
					imgui.Text(u8".жба - жалоба на администратора | .жби - жалоба на игрока ")
					imgui.Text(u8".нв - игрок не в сети |  .нвд - не выдаем ")
					imgui.Text(u8".ут - уточните ваш вопрос/запрос  | .нн - нет нарушений у игрока ")
					imgui.Text(u8".уид - уточнение ID  | .нак - игрок наказан")
					imgui.Text(u8".пр - проверим | .гм - гм не робит")
					imgui.Text(u8".нк - никак  | .нз - не запрещено | .нез - не знаем")
					imgui.Text(u8".жда - да | .жне - нет| .офф - не оффтопить ")
					imgui.Text(u8".баг - скорей всего - баг | .рлг - перезайдите")
				end
				imgui.Separator()
				imgui.Text("")
				if imgui.CollapsingHeader(u8"Ответы на вопросы и т.д.") then
					imgui.Separator()
					if imgui.CollapsingHeader(u8"Вопросы по командам, /help") then  
						imgui.Text(u8".п7 - vip, .п8 - кмд на свадьбы,  .п13 - заработок")
						imgui.Text(u8".инф - Инфа в инете ($ .инф ) | .вп1- .вп4 - привелегии от Premuim до Личного ")
					end
					imgui.Separator()
					if imgui.CollapsingHeader(u8"Вопросы по банде, семье, мафии") then   
						imgui.Text(u8".отф - как открыть меню семьи | .отб - как открыть меню банды ")
						imgui.Text(u8".угб - как исключить человека из банды/семьи ")
						imgui.Text(u8".пгб - как пригласить игроков в банду/семью ")
						imgui.Text(u8".плм - покинуть мафию | .пгф - выйти из банды/семьи ")
						imgui.Text(u8".вуб - выговор участнику банды ")
					end
					imgui.Separator()
					if imgui.CollapsingHeader(u8"Вопросы по телепортации") then  
						imgui.Text(u8".тас - /tp автосалон ")
						imgui.Text(u8".там - /tp автомастерская | .бк - tp in bank ")
						imgui.Text(u8".ктп - как телепортироваться |  .ог - ограб.банка ")
					end
					imgui.Separator()
					if imgui.CollapsingHeader(u8"Вопросы по продаже/купить что-либо") then   
						imgui.Text(u8".кпа - как продать аксессуары ")
						imgui.Text(u8".обм - обмен очков/коинов/рублей ")
						imgui.Text(u8".пм - продажа машины  | .пд - продажа дома ")
					end
					imgui.Separator()
					if imgui.CollapsingHeader(u8"Вопросы по передачам чего-то кому-то") then  
						imgui.Text(u8".гвм - передача денег | .гвс - передача очков ")
					end
					imgui.Separator()
					if imgui.CollapsingHeader(u8"По остальным вопросам")  then
						imgui.Text(u8".цвет - цвета ($ .цвет ) | .кар - /car ")
						imgui.Text(u8".ган - как взять оружие | .пед - как взять предметы ")
						imgui.Text(u8".иск - как искать детали | .крб - казик, работы, и бизнес ")
						imgui.Text(u8".кмд - казик, мп, обмен на trade, достижения ")
						imgui.Text(u8"/gvk - (no id)")
						imgui.Text(u8".кпт - начать капт | .псв - пассивный режим ")
						imgui.Text(u8".стп - /statpl (показ коинов, виртов) ")
						imgui.Text(u8".мсп - как спавнить машину | .спр - смена пароля ")
						imgui.Text(u8".дчд - как добавить человека в дом ")
						imgui.Text(u8".тюн - как протюнить машину | .зч - застрял человек ")
					end
				end
				imgui.Text("")
				imgui.Separator()
					if imgui.CollapsingHeader(u8"Скины") then
						imgui.Text(u8".копы - копы | .бал - балласы | .грув - грув ")
						imgui.Text(u8".ваг- вагосы | .румф - ru.мафия | .вар - вариосы ")
						imgui.Text(u8".триад - триада | .мф - мафия")
					end 
			end
			imgui.Separator()
			imgui.Text("")
			if imgui.CollapsingHeader(u8"Горячие клавиши по ответам") then
				imgui.Text(u8"Кнопка HOME - желает в чат приятной игры")
				imgui.Text(u8"Numpad {.} - вывод приятной игры с цветом | Numpad {/} - вывод удачного.. ")
				imgui.Text(u8"..времяпрепровождения с цветом ")
				imgui.Text(u8"Numpad {-} - вывод приятного времяпрепровождения на сервере с цветом.")
				imgui.Text(u8"Яркий пример использования. При ручном вводе ответа в диалоговом окне /ans, ")
				imgui.Text(u8"вы тыкаете Numpad {.} и у вас выведется Приятной игры на RDS с цветом.")
			end
		end
            if imgui.CollapsingHeader(u8"Жалобы на кого-то/что-то") then  
				if imgui.Button(u8"Жалоба на администратора") then  
					closeAnsWithText(color1() .. 'Пишите жалобу на администратора в VK: vk.com/dmdriftgta')
				end
				imgui.SameLine()
				if imgui.Button(u8"Жалоба на игрока") then  
					closeAnsWithText(color1() .. 'Вы можете оставить жалобу на игрока в VK: vk.com/dmdriftgta ')
				end
                if imgui.Button(u8"Начало слежки за игроком") then  
                    closeAnsWithText(' Начал(а) работу по вашей жалобе! ' .. color1() .. ' Приятной игры на сервере RDS. <3 ')
				end
				imgui.SameLine()
				if imgui.Button(u8"Помогли вам") then  
					closeAnsWithText(' Помогли вам. | ' .. color1() .. 'Приятного времяпрепровождения на RDS <3')
				end
				imgui.SameLine()
				if imgui.Button(u8"Ожидание") then  
					closeAnsWithText(' Ожидайте. '  .. color1() ..  ' Приятного времяпрепровождения на RDS <3')
				end
				imgui.SameLine()
				if imgui.Button(u8"Приятного времяпрепровождения") then  
					closeAnsWithText(color1() .. 'Приятного времяпрепровождения на Russian Drift Server!')
				end
				if imgui.Button(u8"Игрок чист") then  
					closeAnsWithText(' Данный игрок чист. ' .. color1() .. ' Приятной игры на RDS. <3 ')
				end
				imgui.SameLine()
				if imgui.Button(u8"Пожелания приятной игры") then  
					closeAnsWithText(color1() .. 'Приятной игры на сервере RDS!')
				end
				if imgui.Button(u8"Игрок не в сети") then  
					closeAnsWithText(' Данный игрок не в сети. | ' .. color1() .. ' Приятной игры на RDS. <3')
				end
				imgui.SameLine()
				if imgui.Button(u8"Уточнение вопрос/запроса/жалобы") then  
					closeAnsWithText(' Уточните ваш вопрос/запрос. ' .. color1() .. ' Удачной игры <3')
				end
				imgui.SameLine()
				if imgui.Button(u8"Уточнение ID") then  
					closeAnsWithText(' Уточните ID нарушителя/читера в /report ' .. color1() .. ' | Удачного времяпрепровождения.')
				end
				if imgui.Button(u8"Игрок наказан") then  
					closeAnsWithText(' Данный игрок наказан.' .. color1() .. ' | Удачного времяпрепровождения.')
				end
				imgui.SameLine()
				if imgui.Button(u8"Проверим") then  
					closeAnsWithText('Проверим. ' .. color1() .. ' | Удачного времяпрепровождения. ')
				end
				imgui.SameLine()
				if imgui.Button(u8"ГМ не робит") then  
					closeAnsWithText('GodMode (ГодМод) на сервере не работает. ' .. color1() .. ' | Удачного времяпрепровождения. ')
				end
				if imgui.Button(u8"Никак") then  
					closeAnsWithText('Никак. ' .. color1() .. ' | Удачного времяпрепровождения. ')
				end
				imgui.SameLine()
				if imgui.Button(u8"Да") then  
					closeAnsWithText('Да. ' .. color1() .. ' | Удачного времяпрепровождения. ')
				end
				imgui.SameLine()
				if imgui.Button(u8"Нет") then  
					closeAnsWithText('Нет. ' .. color1() .. ' | Удачного времяпрепровождения. ')
				end
				imgui.SameLine()
				if imgui.Button(u8"Не запрещено") then  
					closeAnsWithText('Не запрещено. '  .. color1() .. ' | Удачного времяпрепровожодения. ')
				end
				imgui.SameLine()
				if imgui.Button(u8"Не знаем") then  
					closeAnsWithText('Не знаем.' .. color1() .. ' | Удачного времяпрепровождения. ')
				end
				imgui.SameLine()
				if imgui.Button(u8"Нельзя оффтоп") then  
					closeAnsWithText('Не оффтопьте. ' .. color1() .. ' | Удачного времяпрепровожодения. ')
				end
				if imgui.Button(u8"Не выдаем") then  
					closeAnsWithText('Не выдаем. ' .. color1() .. ' | Удачного времяпрепровожодения ')
				end
				imgui.SameLine()
				if imgui.Button(u8"Это баг") then  
					closeAnsWithText('Скорей всего - это баг. ' .. color1() .. ' | Удачного времяпрепровождения ')
				end
				imgui.SameLine()
				if imgui.Button(u8"Перезайдите") then  
					closeAnsWithText('Попробуйте перезайти. '  .. color1() .. ' | Удачного времяпрепровождения. ')
				end
			end  
			imgui.Separator()
			if imgui.CollapsingHeader(u8"Ответы на вопросы") then
					if imgui.CollapsingHeader(u8"Вопросы по командам, /help") then
						if imgui.Button(u8"Команды VIP`a") then  
							closeAnsWithText(' Данную информацию можно найти в /help -> 7 пункт. ' .. color1() .. ' | Приятной игры на RDS. <3')
						end
						if imgui.Button(u8"Команды для свадьбы") then  
							closeAnsWithText(' Данную информацию можно найти в /help -> 8 пункт. ' .. color1() .. '| Приятной игры на RDS. <3')
						end
						imgui.SameLine()
						if imgui.Button(u8"Как заработать что-то либо") then  
							closeAnsWithText(' Данную информацию можно найти в /help -> 13 пункт. ' .. color1() .. ' | Приятной игры на RDS. <3')
						end
						if imgui.Button(u8"Инфу можно узнать в инете") then  
							closeAnsWithText(' Данную информацию можно узнать в интернете. ' .. color1() .. ' | Приятной игры на RDS <3')
						end
						imgui.SameLine()
						if imgui.Button(u8"Это привелегии Premuim`а") then  
							closeAnsWithText(' Данный игрок с привелегией Premuim VIP (/help -> 7) ' .. color1() .. ' | Приятной игры на RDS <3 ')
						end
						if imgui.Button(u8"А Это привелегии Diamonda`а") then  
							closeAnsWithText(' Данный игрок с привелегией Diamond VIP (/help -> 7) ' .. color1() .. ' | Приятной игры на RDS <3 ')
						end
						imgui.SameLine()
						if imgui.Button(u8"И Это привелегии Platunum`а") then  
							closeAnsWithText(' Данный игрок с привелегией Platinum VIP (/help -> 7)' .. color1() .. ' | Приятной игры на RDS <3 ')
						end
						if imgui.Button(u8"Это привелегии Личного випа") then  
							closeAnsWithText(' Данный игрок с привелегией «Личный» VIP (/help -> 7)' .. color1() .. ' | Приятной игры на RDS <3 ')
						end
					end
					imgui.Separator()
					imgui.Text("")
					if imgui.CollapsingHeader(u8"Вопросы по банде, семье, мафии") then  
						if imgui.Button(u8"Как выйти из банды/семьи") then  
							closeAnsWithText(' /gleave (банда) || /fleave (семья) ' .. color1() .. ' | Приятной игры на RDS <3 ')
						end
						imgui.SameLine()
						if imgui.Button(u8"Как пригласить в банду/семью") then  
							closeAnsWithText(' /ginvite (банда), /finvite (семья) ' .. color1() .. ' | Удачной игры на RDS <3')
						end
						if imgui.Button(u8"Как выдать выговор в банде") then  
							closeAnsWithText(' /gvig // Должна быть лидерка' .. color1() .. ' | Приятной игры на RDS <3 ')
						end
						if imgui.Button(u8"Как исключить человека из банды/семьи") then  
							closeAnsWithText(' /guninvite (банда) || /funinvite (семья)' .. color1() .. ' | Приятной игры на RDS <3 ')
						end
						imgui.SameLine()
						if imgui.Button(u8"Как пригласить игрока в банду/семью") then  
							closeAnsWithText(' /ginvite (банда) ||  /finvite (семья)' .. color1() .. ' | Приятной игры на RDS <3 ' )
						end
						if imgui.Button(u8"Как открыть меню семьи") then   
							closeAnsWithText('/familypanel ' .. color1() .. ' | Удачного времяпрепровождения ')
						end
						if imgui.Button(u8"Как открыть меню банды") then   
							closeAnsWithText('/menu (/mm) - ALT/Y -> Система банд ' .. color1() .. ' | Удачного времяпрепровождения. ')
						end
					end
					imgui.Separator()
					imgui.Text("")
					if imgui.CollapsingHeader(u8"Вопросы по телепортации") then   
						if imgui.Button(u8"Как тпхнуться на автосалон") then  
							closeAnsWithText(' tp -> Разное -> Автосалоны ' .. color1() .. ' | Приятной игры на RDS <3 ')
						end
						imgui.SameLine()
						if imgui.Button(u8"Как тпхнуться на автомастерскую") then  
							closeAnsWithText(' /tp -> Разное -> Автосалоны -> Автомастерская ' .. color1() .. ' | Приятной игры на RDS <3 ')
						end
						if imgui.Button(u8"Как тпхнуться в банк") then  
							closeAnsWithText(' Оплатить бизнес/дом можно с помощью /bank или /tp -> Разное -> Банк ' .. color1() .. ' | Удачной игры на RDS <3')
						end
						imgui.SameLine()
						if imgui.Button(u8"Как тпхаться") then  
							closeAnsWithText(' /tp (по локациям), /g (/goto) id (к игроку) с VIP (/help -> 7 пункт)'.. color1() .. ' | Приятной игры на RDS <3 ')
						end
					end
					imgui.Separator()
					imgui.Text("")
					if imgui.CollapsingHeader(u8"Как продать/обменять что-то либо") then  
						if imgui.Button(u8"Как продать машину") then  
							closeAnsWithText(' /sellmycar IDPlayer Слот1-3 Сумма || /car -> Слот1-3 -> Продать государству' )
						end
						if imgui.Button(u8"Как продать дом") then  
							closeAnsWithText(' /hpanel -> Слот1-3 -> Изменить -> Продать дом государству || /sellmyhouse (игроку)')
						end
						imgui.SameLine()
						if imgui.Button(u8"Где обменять рубли/коины/очки") then  
							closeAnsWithText(' Чтобы обменять валюту, введите /trade, и подойдите к NPC Арману, стоит справа')
						end
						if imgui.Button(u8"Купить/продать аксы") then  
							closeAnsWithText('Продать аксессуары, или купить можно на /trade. Чтобы продать, /sell около лавки')
						end
					end
					imgui.Separator()
					imgui.Text("")
					if imgui.CollapsingHeader(u8"Вопросы по передачам чего-то кому-то") then  
						if imgui.Button(u8"Как передать деньги игроку") then  
							closeAnsWithText(' /givemoney IDPlayer money ' .. color1() .. ' | Приятной игры на RDS <3 ')
						end
						imgui.SameLine()
						if imgui.Button(u8"Как передать очки игроку") then  
							closeAnsWithText(' /givescore IDPlayer score ' .. color1() .. ' | Удачной игры на RDS <3 ')
						end
					end
				imgui.Separator()
				imgui.Text("")
				if imgui.CollapsingHeader(u8"По остальным вопросам") then
					if imgui.Button(u8"Как открыть меню личной машины (/car)") then   
						closeAnsWithText(' /car ' ..color1() .. ' | Приятной игры на сервере RDS <3')
					end  
					if imgui.Button(u8"Как взять оружие") then   
						closeAnsWithText('/menu (/mm) - ALT/Y -> Оружие ' .. color1() .. ' | Приятной игры на RDS <3 ')
					end
					imgui.SameLine()
					if imgui.Button(u8"Как взять предметы") then   
						closeAnsWithText('/menu (/mm) - ALT/Y -> Предметы ' .. color1() .. ' | Приятной игры на RDS <3 ')
					end
					if imgui.Button(u8"Как искать детали") then   
						closeAnsWithText(color1() .. 'Детали разбросаны по всей карте. Обмен происходится на /garage. ')
					end
					if imgui.Button(u8"Казик, работы и бизнес") then   
						closeAnsWithText('Казино, работы, бизнес. ' .. color1() .. ' | Удачного времяпрепровождения. ')
					end
					imgui.SameLine()
					if imgui.Button(u8"Казик, мп, работы, достяги и тд") then   
						closeAnsWithText('Казино, МП, достижения, работы, обмен очков на коины(/trade)' .. color1() .. ' | Приятной игры на RDS <3 ')
					end
					imgui.SameLine()
					if imgui.Button(u8"Как протюнить машину") then   
						closeAnsWithText('/menu (/mm) - ALT/Y -> Т/С -> Тюнинг ' .. color1() .. ' | Приятной игры на RDS <3 ')
					end
					if imgui.Button(u8"Как начать капт") then  
						closeAnsWithText(' Для того, чтобы начать капт, нужно ввести /capture ' .. color1() .. ' | Удачной игры на RDS <3 ')
					end
					imgui.SameLine()
					if imgui.Button(u8"Как ограбить банк") then  
						closeAnsWithText(' Встать на пикап "Ограбление банка", после около ячеек нажимать на ALT и ехать на красный маркер на карте')
					end
					imgui.SameLine()
					if imgui.Button(u8"Как включить пассивку") then  
						closeAnsWithText(' /passive ' .. color1() .. ' | Приятной игры на RDS <3 ')
					end
					imgui.SameLine()
					if imgui.Button(u8"Как попасть на дерби/паб и т.д.") then  
						closeAnsWithText(' /join // Но, можно написать /derby, /pubg. Все команды пишутся в чате при начале')
					end
					if imgui.Button(u8"Как заспавнить машину") then  
						closeAnsWithText(' /mm -> Транспортное средство -> Тип транспорта ' .. color1() .. ' | Удачной игры на RDS <3 ')
					end
					imgui.SameLine()
					if imgui.Button(u8"Как сменить пароль") then  
						closeAnsWithText(' /mm -> Действия -> Сменить пароль '.. color1() .. ' Удачной игры на RDS <3 ')
					end
					if imgui.Button(u8"Как покинуть мафию") then  
						closeAnsWithText(' /leave ' .. color1() .. ' Удачной игры на RDS <3 ')
					end
					imgui.SameLine()
					if imgui.Button(u8"Где можно узнать цвета") then  
						closeAnsWithText(' https://colorscheme.ru/html-colors.html' .. color1() .. ' | Приятной игры на RDS <3 ')
					end
					imgui.SameLine()
					if imgui.Button(u8"Как добавить игрока в аренду") then  
						closeAnsWithText(' /hpanel -> Слот1-3 -> Изменить -> Аренда дома ' .. color1() .. ' | Приятной игры на RDS <3')
					end
					if imgui.Button(u8"Как узнать статистику, кониы, рубли, очки") then   
						closeAnsWithText('Чтобы посмотреть коины, вирты, рубли и т.д. - /statpl ' .. color1() .. ' | Приятной игры на RDS <3')
					end   
				end
				imgui.Separator()
				if imgui.CollapsingHeader(u8"Скины") then  
					if imgui.Button(u8"Копы") then  
						closeAnsWithText(' 265-267, 280-286, 288, 300-304, 306, 307, 309-311' .. color1() .. ' | Приятной игры на RDS <3')
					end
					imgui.SameLine()
					if imgui.Button(u8"Балласы") then  
						closeAnsWithText(' 102-104' .. color1() .. ' | Приятной игры на RDS <3')
					end				
					imgui.SameLine()
					if imgui.Button(u8"Грув") then  
						closeAnsWithText(' 105-107' .. color1() .. ' | Приятной игры на RDS <3')
					end
					imgui.SameLine()
					if imgui.Button(u8"Русская мафия") then  
						closeAnsWithText(' 111-113' .. color1() .. ' | Приятной игры на RDS <3')
					end
					if imgui.Button(u8"Триада") then  
						closeAnsWithText(' 117-118, 120' .. color1() .. ' | Приятной игры на RDS <3')
					end
					imgui.SameLine()
					if imgui.Button(u8"Вариосы") then  
						closeAnsWithText(' 114-116' .. color1() .. ' | Приятной игры на RDS <3')
					end  
					imgui.SameLine()
					if imgui.Button(u8"Вагосы") then
						closeAnsWithText(' 108-110' .. color1() .. ' | Приятной игры на RDS <3')
					end
					imgui.SameLine()
					if imgui.Button(u8"Да просто мафия") then  
						closeAnsWithText(' 124-127 ' .. color1() .. ' | Приятной игры на RDS <3')
					end
				end
			end
		imgui.End()
    end
end
