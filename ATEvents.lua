-- ## Регистрация библиотек, плагинов и аддонов ## --
require 'lib.moonloader'
local encoding = require 'encoding' -- работа с кодировкой
local inicfg = require 'inicfg' -- работа с INI файлами
local imgui = require 'imgui' -- MoonImGUI || Пользовательский интерфейс
local sampev = require 'lib.samp.events' -- работа с ивентами и пакетами SAMP
local atlibs = require 'libsfor' -- библиотека для работы с АТ
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

-- ## Блок переменных связанных с конфигами и элементами взаимодействия с параметрами конфига ## --
local ATMainDirect = "AdminTool\\settings.ini"
local ATMainConfig = inicfg.load({
    main = {
        styleImGUI = 0,
    },
}, ATMainDirect)

local directIni = "AdminTool\\events.ini"

local config = inicfg.load({
    main = {
        auto_tp = false,
        stream_window = false,
    },
}, directIni)
inicfg.save(config, directIni)

local BinderMP = "AdminTool\\evbinder.ini"
local BinderMPcfg = inicfg.load({
    bind_name = {},
    bind_text = {},
    bind_delay = {},
    bind_vdt = {},
    bind_coords = {}
}, BinderMP)
inicfg.save(BinderMPcfg, BinderMP)

function save() 
    inicfg.save(config, directIni)
end

local elements = {
    main = {
        auto_tp = imgui.ImBool(config.main.auto_tp),
        stream_window = imgui.ImBool(config.main.stream_window),
    },
    buffers = {
        name = imgui.ImBuffer(128),
        dt_vt = imgui.ImBuffer(32),
        rules = imgui.ImBuffer(65536),
        win_player = imgui.ImBuffer(32),
        bin_name = imgui.ImBuffer(256),
        bin_text = imgui.ImBuffer(65536),
		bin_delay = imgui.ImBuffer(2500),
        bin_vdt = imgui.ImBuffer(32),
        bin_coord = imgui.ImBuffer(2048),
        gun_player = imgui.ImBuffer(64),
    },
}
-- ## Блок переменных связанных с конфигами и элементами взаимодействия с параметрами конфига ## --

-- ## Блок переменных связанных с MoonImGUI ## --

local sw, sh = getScreenResolution()

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

imgui.ToggleButton = require('imgui_addons').ToggleButton
imgui.VerticalSeparator = require('imgui_addons').VerticalSeparator
imgui.Spinner = require('imgui_addons').Spinner
imgui.BufferingBar = require('imgui_addons').BufferingBar
imgui.TextQuestion = require('imgui_addons').TextQuestion
imgui.CenterText = require('imgui_addons').CenterText
imgui.Tooltip = require('imgui_addons').Tooltip

local ATEvent = imgui.ImBool(false)
local EventStream = imgui.ImBool(false)
local menuSelect = 0 

local Stream_Text
-- ## Блок переменных связанных с MoonImGUI ## --

-- ## Регистрация уведомлений ## --
function showNotification(text)
	notf.addNotify(ntag, text, 2, 1, 6)
end
-- ## Регистрация уведомлений ## --

function main()
    while not isSampAvailable() do wait(0) end
    
    sampfuncsLog(log .. " Инициализация скрипта, с помощью которого можно взаимодействовать с мероприятиями.")

    sampRegisterChatCommand("amp", function()
        ATEvent.v = not ATEvent.v  
        imgui.Process = ATEvent.v
        imgui.ShowCursor = ATEvent.v
    end)

    while true do
        wait(0)

        imgui.Process = true
        if not ATEvent.v and not EventStream.v then  
            imgui.Process = false  
            imgui.ShowCursor = false  
        end
        if isKeyJustPressed(VK_RBUTTON) and not sampIsChatInputActive() and EventStream.v and not sampIsDialogActive() then  
            imgui.ShowCursor = not imgui.ShowCursor 
            wait(600)
        end
    end
end

-- ## Блок обработки ивентов и пакетов SA:MP ## -- 
function sampev.onServerMessage(color, text)

    if text:find("Администратор " .. atlibs.getMyNick() .. "%[(%d+)%] создал мероприятие") then  
        sampAddChatMessage(tag .. " Мероприятие было открыто.")
        if elements.main.stream_window.v then  
            sampAddChatMessage(tag .. " Интерфейс для управления MP запущено.")
            EventStream.v = true  
        end
    end

end

function playersToStreamZone()
	local peds = getAllChars()
	local streaming_player = {}
	local _, pid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	for key, v in pairs(peds) do
		local result, id = sampGetPlayerIdByCharHandle(v)
		if result and id ~= pid and id ~= tonumber(recon_id) then
			streaming_player[key] = id
		end
	end
	return streaming_player
end

-- ## Блок обработки ивентов и пакетов SA:MP ## -- 

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

    if ATEvent.v then   

        imgui.SetNextWindowSize(imgui.ImVec2(400, 300), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

        imgui.Begin(fai.ICON_FA_NEWSPAPER .. " AT Events", ATEvent, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.MenuBar)
        
        imgui.BeginMenuBar()
            imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
            imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 10)
            if imgui.Button(fai.ICON_FA_WAREHOUSE, imgui.ImVec2(27,0)) then  
                menuSelect = 0 
            end; imgui.Tooltip(u8"Настройки скрипта AT Events")
            if imgui.Button(fai.ICON_FA_MAP_MARKED, imgui.ImVec2(27,0)) then  
                menuSelect = 1
            end; imgui.Tooltip(u8"Создание своего мероприятия\n Ручное создание не предусматривает его сохранение.")
            if imgui.Button(fai.ICON_FA_TERMINAL, imgui.ImVec2(27,0)) then  
                menuSelect = 2 
            end; imgui.Tooltip(u8"Использование заготовленных мероприятий | создание новых заготовок. \nПредусматривает использование введенных мероприятий разработчиком, их модернизация и добавление своих.")
            imgui.PopStyleVar(1)
            imgui.PopStyleVar(1)
        imgui.EndMenuBar()
       
        if menuSelect == 0 then  
            positionX, positionY, positionZ = getCharCoordinates(playerPed)
            imgui.Text(u8"Здесь Вы можете создать мероприятие и управлять им.")
            imgui.Text(u8"Содержание окна меняется в зависимости от выбранного меню.")
            imgui.Text(u8"Кроме этого, интеграция данного окна также присутствует \nв открытии мероприятия.")
            imgui.Text(u8"AT Events обладает функциями управления мероприятиям \nв режиме RealTime.")
            imgui.Text(u8"AT Events предполагает создание своего мероприятия \nс нуля или использования заготовленных разработчиком.")
            imgui.Text("")
            imgui.Text(u8"Ваши координаты: \nX: " .. positionX .. " | Y: " .. positionY .. " | Z: " .. positionZ)
            if imgui.IsItemClicked() then  
                imgui.LogToClipboard()
                imgui.LogText(positionX .. " " .. positionY .. " " .. positionZ)
                imgui.LogFinish()
            end
            imgui.Tooltip(u8"Кликнув на координаты, Вы их можете скопировать. Это поможет в создании мероприятия.")
            imgui.Separator()

            if imgui.ToggleButton(fai.ICON_FA_CAMERA .. u8' Управление MP', elements.main.stream_window) then  
                config.main.stream_window = elements.main.stream_window.v 
                showNotification("Сохранение настроек AT Events")
                inicfg.save(config,directIni)
            end 

            if imgui.Button(u8"Ручное открытие управления МП") then  
                ATEvent.v = false
                EventStream.v = not EventStream.v  
            end; imgui.Tooltip(u8"Используйте, если Вы случайно во время МП его закрыли.")
        end

        if menuSelect == 1 then  
            imgui.Text(u8'Данный раздел позволяет создать свое мероприятие.')
            imgui.Text(u8"Создание мероприятия через данное окно \nпредусматривает его сохранение через кнопочку. ")
            imgui.Text(u8"Правила создаются по принципу флудов.");
            imgui.Tooltip(u8"Текст в правилах/описание следует следующему правилу:\n1. Вводится по принципу флудов, т.е. номер цвета mess и текст. Пример: \n 6 Участие в МП могут принять все! \n 6 Запрещено пользоваться /heal, /r и /s\n2. Каждая строчка делается отдельно для правильного вывода. ")
            imgui.Separator()
            imgui.PushItemWidth(130)
            imgui.InputText(u8"Имя MP", elements.buffers.name)  
            imgui.PopItemWidth()
            imgui.SameLine()
            imgui.SetCursorPosX(imgui.GetWindowWidth() - 170)
            imgui.PushItemWidth(30)
            imgui.InputText(u8"/dt", elements.buffers.dt_vt); imgui.Tooltip(u8"Если сюда ничего не вводить, то виртуальный мир введется рандомно.")
            imgui.PopItemWidth()
            imgui.Separator()
            imgui.CenterText(u8"Правила мероприятия")
            imgui.PushItemWidth(400)
            imgui.InputTextMultiline("##RulesForEvent", elements.buffers.rules)
            imgui.PopItemWidth()
            if imgui.Button(u8"Вывод правил") then  
                text = atlibs.string_split(elements.buffers.rules.v:gsub("\n", "~"), "~")
                Stream_Text = text
                for _, i in pairs(text) do  
                    sampSendChat("/mess " .. u8:decode(i))
                end
            end; imgui.Tooltip(u8"Кликать после начала МП для правильности проведения.")
            imgui.SameLine()
            imgui.SetCursorPosX(imgui.GetWindowWidth() - 270)
            if imgui.Button(u8"Станд.правила") then  
                sampSendChat("/mess 6 На мероприятии нельзя: /passive, /anim, /r - /s, DM, нарушать прочие правила проекта")
                sampSendChat("/mess 6 При нарушении правил, Вы будете посажены в Jail.")
            end; imgui.Tooltip(u8"Кликать после начала МП для правильности проведения.")
            imgui.SameLine()
            imgui.SetCursorPosX(imgui.GetWindowWidth() - 130)
            if imgui.Button(u8"Начать МП") then  
                lua_thread.create(function()
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 15)
                    wait(1)
                    sampSendDialogResponse(16069, 1, 1)
                    if #elements.buffers.dt_vt.v > 0 then  
                        sampSendDialogResponse(16070, 1, 0, u8:decode(tostring(elements.buffers.dt_vt.v)))
                    else
                        math.randomseed(os.clock())
                        local dt = math.random(500, 999)
                        sampSendDialogResponse(16070, 1, 0, tostring(dt))
                    end
                    sampSendDialogResponse(16069, 1, 2)
                    sampSendDialogResponse(16071, 1, 0, "0")
                    sampSendDialogResponse(16069, 0, 0)
                    sampSendDialogResponse(5343, 1, 0)
                    wait(200)
                    sampSendDialogResponse(5344, 1, 0, u8:decode(tostring(elements.buffers.name.v)))
                    sampSendChat("/mess 6 Уважаемые игроки! Проходит меропряитие: " .. u8:decode(tostring(elements.buffers.name.v)) .. ". Желающие: /tpmp")
                    sampSendChat("/mess 6 Уважаемые игроки! Проходит меропряитие: " .. u8:decode(tostring(elements.buffers.name.v)) .. ". Желающие: /tpmp")
                    sampCloseCurrentDialogWithButton(0)
                end)
            end
            imgui.SameLine()
            if imgui.Button(fai.ICON_FA_SAVE) then  
                elements.buffers.bin_delay.v = "0"
                positionX, positionY, positionZ = getCharCoordinates(playerPed)
                positionX = string.sub(tostring(positionX), 1, string.find(tostring(positionX), ".")+6)
                positionY = string.sub(tostring(positionY), 1, string.find(tostring(positionY), ".")+6)
                positionZ = string.sub(tostring(positionZ), 1, string.find(tostring(positionZ), ".")+6)
                elements.buffers.bin_coord.v = tostring(positionX) .. "," .. tostring(positionY) .. "," .. tostring(positionZ)
                local refresh_text = elements.buffers.rules.v:gsub("\n", "~")
                table.insert(BinderMPcfg.bind_name, elements.buffers.name.v)
                table.insert(BinderMPcfg.bind_text, refresh_text)
                table.insert(BinderMPcfg.bind_delay, elements.buffers.bin_delay.v)
                table.insert(BinderMPcfg.bind_vdt, elements.buffers.dt_vt.v)
                table.insert(BinderMPcfg.bind_coords, elements.buffers.bin_coord.v)
                if inicfg.save(BinderMPcfg, BinderMP) then  
                    sampAddChatMessage(tag .. 'МП "' ..u8:decode(elements.buffers.name.v).. '" успешно добавлено в Биндер!', -1)
                    elements.buffers.name.v, elements.buffers.rules.v, elements.buffers.bin_delay.v, elements.buffers.dt_vt.v,elements.buffers.bin_coord.v  = '', '', "2500", "0", "0"
                end  
            end; imgui.Tooltip(u8"Функция позволяет сохранить данное мероприятия в Биндере. \nВыставляется местоположение, откуда Вы его начали, где Вы на данный момент стоите.")
        end

        if menuSelect == 2 then  
            imgui.Text(u8"В данном разделе можно использовать мероприятия от \nразработчика, либо создать свои и использовать их \nв дальнейшем.")

            imgui.Text(u8"Помощник по созданию. Наведите мышкой! \nЯ могу показывать Вам сообщение помощника :D");
            imgui.Tooltip(u8"И так. Легкое объяснение по созданию своего мероприятия. \nТекст в правилах/описание следует следующему правилу:\n1. Вводится по принципу флудов, т.е. номер цвета mess и текст. Пример: \n 6 Участие в МП могут принять все! \n 6 Запрещено пользоваться /heal, /r и /s\n2. Каждая строчка делается отдельно для правильного вывода. \n\n Координаты лучше брать из домашней страницы, либо выбирать 'Моя позиция' \n Виртуальный мир рекомендуется выбирать рандомно, при помощи кнопки скрипта \n Мероприятия стабильно редактируются, поэтому Вы все можете подстроить под себя.")
            imgui.Separator()

            if imgui.Button(u8"Создать мероприятие") then  
                elements.buffers.bin_name.v, elements.buffers.bin_text.v, elements.buffers.bin_delay.v, elements.buffers.bin_vdt.v = '', '', "2500", "0"
                getpos = nil 
                EditOldBind = false
                imgui.OpenPopup('EventsBinder')
            end

            if #BinderMPcfg.bind_name > 0 then  
                for key_bind, name_bind in pairs(BinderMPcfg.bind_name) do  
                    if imgui.Button(name_bind .. '##' ..key_bind) then  
                        sampAddChatMessage(tag  .. ' Реализую запуск Вашего МП "' .. u8:decode(name_bind) .. '"', -1)
                        lua_thread.create(function()
                            if #BinderMPcfg.bind_coords > 5 then  
                                coords = atlibs.string_split(BinderMPcfg.bind_coords[key_bind], ",")
                                setCharCoordinates(PLAYER_PED,coords[1],coords[2],coords[3]) -- где coords[1] - x, coords[2] - y, coords[3] - z
                            end
                            Stream_Text = atlibs.string_split(BinderMPcfg.bind_text[key_bind], "~")
                            wait(500)
                            sampSendChat("/mp")
                            sampSendDialogResponse(5343, 1, 15)
                            wait(1)
                            sampSendDialogResponse(16069, 1, 1)
                            sampSendDialogResponse(16070, 1, 0, BinderMPcfg.bind_vdt[key_bind])
                            sampSendDialogResponse(16069, 1, 2)
                            sampSendDialogResponse(16071, 1, 0, "0")
                            sampSendDialogResponse(16069, 0, 0)
                            sampSendDialogResponse(5343, 1, 0)
                            wait(200)
                            sampSendDialogResponse(5344, 1, 0, u8:decode(tostring(BinderMPcfg.bind_name[key_bind])))
                            sampSendChat("/mess 6 Уважаемые игроки! Проходит меропряитие: " .. u8:decode(tostring(BinderMPcfg.bind_name[key_bind])) .. ". Желающие: /tpmp")
                            sampSendChat("/mess 6 Уважаемые игроки! Проходит меропряитие: " .. u8:decode(tostring(BinderMPcfg.bind_name[key_bind])) .. ". Желающие: /tpmp")
                            sampCloseCurrentDialogWithButton(0)
                        end)
                    end
                    imgui.SameLine()
                    if imgui.Button(fai.ICON_FA_EDIT .. '##'..key_bind, imgui.ImVec2(27,0)) then  
                        EditOldBind = true  
                        getpos = key_bind 
						local returnwrapped = tostring(BinderMPcfg.bind_text[key_bind]):gsub('~', '\n')
						elements.buffers.bin_text.v = returnwrapped
						elements.buffers.bin_name.v = tostring(BinderMPcfg.bind_name[key_bind])
						elements.buffers.bin_delay.v = tostring(BinderMPcfg.bind_delay[key_bind])
                        elements.buffers.bin_coord.v = tostring(BinderMPcfg.bind_coords[key_bind])
                        elements.buffers.bin_vdt.v = tostring(BinderMPcfg.bind_vdt[key_bind])
						imgui.OpenPopup('EventsBinder')
                    end  
                    imgui.SameLine()
                    if imgui.Button(fai.ICON_FA_TRASH.."##"..key_bind, imgui.ImVec2(27,0)) then  
						sampAddChatMessage(tag .. 'МП "' ..u8:decode(BinderMPcfg.bind_name[key_bind])..'" удалено!', -1)
						table.remove(BinderMPcfg.bind_name, key_bind)
						table.remove(BinderMPcfg.bind_text, key_bind)
						table.remove(BinderMPcfg.bind_delay, key_bind)
						inicfg.save(BinderMPcfg, BinderMP)
					end  
                end  
            else
                imgui.Text(u8('Ни одно мероприятие не зарегистрировано. Может, создадим?'))
            end

            if imgui.BeginPopupModal('EventsBinder', false, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then  
                imgui.BeginChild('##CreateEdit', imgui.ImVec2(600, 225), true)
                    imgui.Text(u8"Название МП: "); imgui.SameLine()
                    imgui.PushItemWidth(130)
                    imgui.InputText('##name_events', elements.buffers.bin_name)
                    imgui.PopItemWidth()
                    imgui.Text(u8"Виртуальный мир: "); imgui.Tooltip(u8"Сейчас указание виртуального мира (отличное от 0) необходимо для создания своего мероприятия \nЛично рекомендую: указывайте от 500 до 999 рандомными значениями.\nПрименяйте в каждом своем мероприятии усредненное значение, чтобы самому не путаться.")
                    imgui.SameLine()
                    imgui.PushItemWidth(30)
                    imgui.InputText('##dt_event', elements.buffers.bin_vdt)
                    imgui.PopItemWidth()
                    imgui.SameLine()
                    if imgui.Button(u8"Рандом") then  
                        math.randomseed(os.clock())
                        local dt = math.random(500, 999)
                        elements.buffers.bin_vdt.v = tostring(dt)
                    end; imgui.Tooltip(u8"Скрипт сам вставляет рандомный номер виртуального мира (/dt)")
                    imgui.Text(u8"Координаты начала МП: ")
                    imgui.SameLine()
                    imgui.PushItemWidth(250)
                    imgui.InputText("##CoordsEvent", elements.buffers.bin_coord)
                    imgui.PopItemWidth()
                    imgui.SameLine()
                    if imgui.Button(u8"Моя позиция") then  
                        positionX, positionY, positionZ = getCharCoordinates(playerPed)
                        positionX = string.sub(tostring(positionX), 1, string.find(tostring(positionX), ".")+6)
                        positionY = string.sub(tostring(positionY), 1, string.find(tostring(positionY), ".")+6)
                        positionZ = string.sub(tostring(positionZ), 1, string.find(tostring(positionZ), ".")+6)
                        elements.buffers.bin_coord.v = tostring(positionX) .. "," .. tostring(positionY) .. "," .. tostring(positionZ)
                    end; imgui.Tooltip(u8"Выбирает координаты, на которых Вы сейчас находитесь. \nКоординаты укорочены приблизительно до 2-4 знаков после запятой.")
                    imgui.Separator()
                    imgui.Text(u8"Правила/описание МП:")
                    imgui.PushItemWidth(300)
                    imgui.InputTextMultiline("##EventText", elements.buffers.bin_text, imgui.ImVec2(-1, 100))
                    imgui.PopItemWidth()
                    imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 100)
                    if imgui.Button(u8'Закрыть##bind', imgui.ImVec2(100,30)) then  
                        elements.buffers.bin_name.v, elements.buffers.bin_text.v, elements.buffers.bin_delay.v, elements.buffers.bin_vdt.v = '', '', "2500", "0"
                        imgui.CloseCurrentPopup()
                    end  
                    imgui.SameLine()
                    if #elements.buffers.bin_name.v > 0 and #elements.buffers.bin_text.v > 0 then  
                        imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 1.01)
                        if imgui.Button(u8'Сохранить##bind', imgui.ImVec2(100,30)) then  
                            if not EditOldBind then  
                                local refresh_text = elements.buffers.bin_text.v:gsub("\n", "~")
                                table.insert(BinderMPcfg.bind_name, elements.buffers.bin_name.v)
                                table.insert(BinderMPcfg.bind_text, refresh_text)
                                table.insert(BinderMPcfg.bind_delay, elements.buffers.bin_delay.v)
                                table.insert(BinderMPcfg.bind_vdt, elements.buffers.bin_vdt.v)
                                table.insert(BinderMPcfg.bind_coords, elements.buffers.bin_coord.v)
                                if inicfg.save(BinderMPcfg, BinderMP) then  
                                    sampAddChatMessage(tag .. 'МП "' ..u8:decode(elements.buffers.bin_name.v).. '" успешно создано!', -1)
                                    elements.buffers.bin_name.v, elements.buffers.bin_text.v, elements.buffers.bin_delay.v, elements.buffers.bin_vdt.v,elements.buffers.bin_coord.v  = '', '', "2500", "0", "0"
                                end  
                                imgui.CloseCurrentPopup()
                                else 
                                local refresh_text = elements.buffers.bin_text.v:gsub("\n", "~")
                                table.insert(BinderMPcfg.bind_name, getpos, elements.buffers.bin_name.v)
                                table.insert(BinderMPcfg.bind_text, getpos, refresh_text)
                                table.insert(BinderMPcfg.bind_delay, getpos, elements.buffers.bin_delay.v)
                                table.insert(BinderMPcfg.bind_vdt, getpos, elements.buffers.bin_vdt.v)
                                table.insert(BinderMPcfg.bind_coords, getpos, elements.buffers.bin_coord.v)
                                table.remove(BinderMPcfg.bind_name, getpos + 1)
                                table.remove(BinderMPcfg.bind_text, getpos + 1)
                                table.remove(BinderMPcfg.bind_delay, getpos + 1)
                                table.remove(BinderMPcfg.bind_vdt, getpos + 1)
                                table.remove(BinderMPcfg.bind_coords, getpos + 1)
                                if inicfg.save(BinderMPcfg, BinderMP) then
                                    sampAddChatMessage(tag .. 'МП "' ..u8:decode(elements.buffers.bin_name.v).. '" успешно отредактировано!', -1)
                                    elements.buffers.bin_name.v, elements.buffers.bin_text.v, elements.buffers.bin_delay.v, elements.buffers.bin_vdt.v, elements.buffers.bin_coord.v = '', '', "2500", "0", "0"
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
        imgui.End()

    end

    if EventStream.v then   

        local id_to_stream = playersToStreamZone()

        imgui.SetNextWindowSize(imgui.ImVec2(400, 200), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(sw - 250, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin("Event Stream")
        if imgui.Button(u8"Закрыть окно <Управление MP>") then EventStream.v = false end; imgui.Tooltip(u8"Использовать в том случае, когда данное окно не является необходимым для проведения мероприятия; \nЛибо же мероприятие закончилось, а окно автоматически не закрылось")
        if imgui.Button(u8"Закрыть /tpmp") then
            lua_thread.create(function()  
                sampSendChat("/mp")
                wait(10)
                sampSendDialogResponse(5343, 1, 0)
                wait(100)
                sampCloseCurrentDialogWithButton(0)
            end)
        end
        imgui.SameLine()
        if imgui.Button(u8"Правила текущего МП") then  
            for _, input in pairs(Stream_Text) do  
                sampSendChat("/mess " .. u8:decode(tostring(input)))
            end 
        end
        imgui.SameLine()
        if imgui.Button(u8"Призыв к /tpmp") then  
            sampSendChat("/mess 6 Дорогие игроки, телепорт все ещё открыт! /tpmp")
            sampSendChat("/mess 6 Успейте, до начала мероприятия!")
        end

        if imgui.Button(u8"Удачно/Неудачно (/try)") then  
            sampSendChat("/try застрелил")
        end
        imgui.SameLine()
        if imgui.Button(u8"Выдать себе миниган") then  
            sampSendChat("/setweap " .. atlibs.getMyId() .. " 38 5000")
        end
        imgui.Separator()
        imgui.Text(u8"Введите ID победителя")
        imgui.PushItemWidth(30)
        imgui.InputText('##WinPlayerEndEvent', elements.buffers.win_player)
        imgui.PopItemWidth()
        imgui.SameLine()
        if imgui.Button(u8"Выдать приз") then  
            sampAddChatMessage(tag .. "Выдаем приз игроку с ID [" .. elements.buffers.win_player.v .. "]", -1)
            sampSendChat("/mess 6 В мероприятии победил игрок " .. sampGetPlayerNickname(tonumber(elements.buffers.win_player.v)) .. '[' .. elements.buffer.win_player.v .. "]")
            sampSendChat("/mess 6 Поздравим его с победой. <3") 
            sampSendChat("/mpwin " .. elements.buffers.win_player.v)
        end
        imgui.Text(u8'Выдать оружия участникам МП'); imgui.Tooltip(u8'Если нужно выдать одно оружие, введите просто его ID. Если нужно выдать несколько, введите список через запятую.\nПример: 24,38,23')
        imgui.PushItemWidth(75)
        imgui.InputText('##GunPlayerEvent', elements.buffers.gun_player)
        imgui.PopItemWidth()
        imgui.SameLine()
        if imgui.Button(u8"Выдать оружие") then  
            gun_ids = atlibs.string_split(elements.buffers.gun_player.v, ",")
            if #id_to_stream > 0 then 
                for _, v in pairs(id_to_stream) do 
                    for _, vid in pairs(gun_ids) do
                        sampSendChat("/setweap " .. v .. " " .. vid .. " 5000")
                    end
                end 
            end
        end
        
        imgui.Separator()

        if imgui.Button(u8"Отобрать у всех оружия") then  
            lua_thread.create(function()
                sampSendChat("/mp ")
                sampSendDialogResponse(5343,1,3)
                wait(100)
                sampCloseCurrentDialogWithButton(0)
            end)
        end
        imgui.SameLine()
        if imgui.Button(u8"Заспавнить всех") then  
            if #id_to_stream > 0 then 
                for _, v in pairs(id_to_stream) do 
                    sampSendChat("/aspawn " .. v)
                end
            end
        end
        imgui.Tooltip(u8"При клике - всех игроков заспавнит в зоне стрима")

        imgui.Separator()
        
        if #id_to_stream > 0 then 
            for _, v in pairs(id_to_stream) do 
                if imgui.Button(" - " .. sampGetPlayerNickname(v) .. "[" .. v .. "]", imgui.ImVec2(250,0)) then  
                    sampSendChat("/aspawn " .. v)
                end; imgui.Tooltip(u8"При клике - игрока заспавнит")
                imgui.SameLine()
                if imgui.Button(fai.ICON_FA_USER_LOCK) then  
                    sampSendChat("/jail " .. v .. " 300 Нарушение правил МП")
                end; imgui.Tooltip(u8"При нажатии, кинет игрока в /jail за нарушение правил МП")
                
            end
        else
            imgui.Text(u8"Кроме Вас нет никого рядом...")
        end

        imgui.End()
    end
end