script_name('AdminTool') -- имя скрипта
script_description('Скрипт, позволяющий отображать различный текст на экране. Рендеры.') -- описание
script_author('alfantasyz') -- автор

-- ## Регистрация библиотек, плагинов и аддонов ## --
require "lib.moonloader" -- интеграция основных функций.
local fflags = require("moonloader").font_flag -- работа с флагами для рендера текста
local inicfg = require 'inicfg' -- работа с INI файлами
local sampev = require 'lib.samp.events' -- работа с ивентами и пакетами SAMP
local encoding = require 'encoding' -- работа с кодировкой
local imgui = require 'imgui' -- MoonImGUI || Пользовательский интерфейс
local atlibs = require 'libsfor' -- библиотека для работы с АТ
local scoreboard = import (getWorkingDirectory() .. '\\lib\\scoreboard.lua') -- интеграция модифицированного кастомного ScoreBoard
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
local directIni = "AdminTool\\renders.ini" 

local ini_file_main = inicfg.load({
    main = {
        font = 10,
    }
}, 'AdminTool\\settings.ini')

local config = inicfg.load({
    settings = {
        dchat = false,
        pmchat = false,
        reportchat = false,
        warningchat = false,
        lquit = false,
        Font = 10,
    },
    dchat = {
        X = 0,
        Y = 0,
        lines = 10,
    },
    pmchat = {
        X = 0,
        Y = 0,
        lines = 10,
    },
    reportchat = {
        X = 0,
        Y = 0,
        lines = 10,
    },
    warningchat = {
        X = 0,
        Y = 0,
        lines = 10,
    },
    lquit = {
        X = 0,
        Y = 0,
        lines = 10,
    }
}, directIni)
inicfg.save(config, directIni)

function save() 
    inicfg.save(config, directIni)
end

local elements = {
    boolean = {
        dchat = imgui.ImBool(config.settings.dchat),
        pmchat = imgui.ImBool(config.settings.pmchat),
        reportchat = imgui.ImBool(config.settings.reportchat),
        warningchat = imgui.ImBool(config.settings.warningchat),
        lquit = imgui.ImBool(config.settings.lquit),
    },
    int = {
        Font = imgui.ImInt(config.settings.Font), 
    },
    dchat = {
        chat_lines = { },
        pos = false,
        X = 0,
        Y = 0,
        lines = imgui.ImInt(10),
    },
    pmchat = {
        chat_lines = { },
        pos = false,
        X = 0,
        Y = 0,
        lines = imgui.ImInt(10),
    },
    reportchat = {
        chat_lines = { },
        pos = false,
        X = 0,
        Y = 0,
        lines = imgui.ImInt(10),
    },
    warningchat = {
        chat_lines = { },
        pos = false,
        X = 0,
        Y = 0,
        lines = imgui.ImInt(10),
    },
    lquit = {
        chat_lines = { },
        pos = false,
        X = 0,
        Y = 0,
        lines = imgui.ImInt(10),
    }
}
-- ## Блок переменных связанных с конфигами и элементами взаимодействия с параметрами конфига ## --

-- ## Взаимодействие с интерфейсом ImGUI ## --
local sw, sh = getScreenResolution()

imgui.ToggleButton = require('imgui_addons').ToggleButton

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

local rbutton = imgui.ImInt(0)
local change_dest = 0
-- ## Взаимодействие с интерфейсом ImGUI ## --

-- ## Функции для прямых действий с рендером ## -- 
local font_render = renderCreateFont("Arial", tonumber(ini_file_main.main.font), fflags.BOLD + fflags.SHADOW)

local no_saved = {
	X = 0,
	Y = 0,
}

local report_checking = false

local quitReason = {
    "вылетел / краш",
    "вышел из игры",
    "кикнут / забанен"
  }
-- ## Функции для прямых действий с рендером ## -- 

-- ## Сохранение рендерных параметров ## --
function saveLQuit()
    config.lquit.X = elements.lquit.X
    config.lquit.Y = elements.lquit.Y
    config.lquit.lines = elements.lquit.lines.v
    save()
end

function loadLQuit()
    elements.lquit.X = config.lquit.X
    elements.lquit.Y = config.lquit.Y
    elements.lquit.lines.v = config.lquit.lines
end

function saveWarningChat()
    config.warningchat.X = elements.warningchat.X
    config.warningchat.Y = elements.warningchat.Y
    config.warningchat.lines = elements.warningchat.lines.v
    save()
end 

function loadWarningChat()
    elements.warningchat.X = config.warningchat.X
    elements.warningchat.Y = config.warningchat.Y
    elements.warningchat.lines.v = config.warningchat.lines
end

function saveDChat()
    config.dchat.X = elements.dchat.X 
    config.dchat.Y = elements.dchat.Y 
    config.dchat.lines = elements.dchat.lines.v  
    save()  
end  

function saveFAQ()
    config.reportchat.X = elements.reportchat.X 
    config.reportchat.Y = elements.reportchat.Y  
    config.reportchat.lines = elements.reportchat.lines.v  
    save()
end  

function savePM()
    config.pmchat.X = elements.pmchat.X  
    config.pmchat.Y = elements.pmchat.Y  
    config.pmchat.lines = elements.pmchat.lines.v
    save() 
end  

function loadDChat()
    elements.dchat.X = config.dchat.X  
    elements.dchat.Y = config.dchat.Y  
    elements.dchat.lines.v = config.dchat.lines  
end

function loadFAQ()
    elements.reportchat.X = config.reportchat.X  
    elements.reportchat.Y = config.reportchat.Y  
    elements.reportchat.lines.v = config.reportchat.lines  
end

function loadPM()
    elements.pmchat.X = config.pmchat.X  
    elements.pmchat.Y = config.pmchat.Y  
    elements.pmchat.lines.v = config.pmchat.lines  
end
-- ## Сохранение рендерных параметров ## --

function sampev.onServerMessage(color, text)
    time = os.date("%H:%M:%S")
    if text:find("%[A] SMS:") and elements.boolean.pmchat.v then  
        local pm_text = text:match("%[A] SMS: (.+)")
        for i = elements.pmchat.lines.v, 1, -1 do  
            if i ~= 1 then  
                elements.pmchat.chat_lines[i] = elements.pmchat.chat_lines[i-1]
            else 
                elements.pmchat.chat_lines[i] = "{00BFFF} [AT-PM] {FFFFFF}[" .. time .. "]: " .. pm_text
            end
        end 
        return false
    end
    if text:find("%[A] NEARBY CHAT: (.+)") and elements.boolean.dchat.v then  
        local d_text = text:match("%[A] NEARBY CHAT: (.+)")
        for i = elements.dchat.lines.v, 1, -1 do  
            if i ~= 1 then  
                elements.dchat.chat_lines[i] = elements.dchat.chat_lines[i-1]
            else  
                elements.dchat.chat_lines[i] = "{00BFFF} [AT-NEARBY] {FFFFFF}[" .. time .. "]: " .. d_text
            end 
        end
        return false
    end
    if text:find("Жалоба (.+) | {AFAFAF}(.+)%[(%d+)%]: (.+)") and elements.boolean.reportchat.v then  
        number_rep, nick, id, text = text:match("Жалоба (.+) | {AFAFAF}(.+)%[(%d+)%]: (.+)")
        report_full = 'Жалоба от ' .. nick .. ' [' .. id .. ']: ' .. text  
        for i = elements.reportchat.lines.v, 1, -1 do  
            if i ~= 1 then  
                elements.reportchat.chat_lines[i] = elements.reportchat.chat_lines[i-1]
            else  
                elements.reportchat.chat_lines[i] = report_full
            end  
        end  
        return false
    end
    local str = {}
    str = atlibs.string_split(text, " ")
    if elements.boolean.warningchat.v then
        if str[1] == "<AC-WARNING>" or str[1] == "<AC-KICK>" then  
            for i = elements.warningchat.lines.v, 1, -1 do
                if i ~= 1 then
                    elements.warningchat.chat_lines[i] = elements.warningchat.chat_lines[i-1]
                else
                    elements.warningchat.chat_lines[i] = text
                end
            end 
            return true
        end
    end
end

function sampev.onPlayerJoin(id, color, isNpc, nickname)
    for i = elements.lquit.lines.v, 1, -1 do
        if i ~= 1 then
            elements.lquit.chat_lines[i] = elements.lquit.chat_lines[i-1]
        else
            elements.lquit.chat_lines[i] = string.format("%s[%d] подключился", nickname, id)
        end 
    end
end

function sampev.onPlayerQuit(id, reason)
    for i = elements.lquit.lines.v, 1, -1 do
        if i ~= 1 then
            elements.lquit.chat_lines[i] = elements.lquit.chat_lines[i-1]
        else
            elements.lquit.chat_lines[i] = string.format("%s[%d] %s", sampGetPlayerNickname(id), id, quitReason[reason+1])
        end 
    end
end

function main()
    while not isSampAvailable() do wait(0) end
    
    sampfuncsLog(log .. "Скрипт для рендера отдельных строк чата инициализированы.")

    -- ## Инициализация поточных функций. Рендер ## --
    render_faq = lua_thread.create_suspended(drawFAQ)
    render_pm = lua_thread.create_suspended(drawPM)
    render_dchat = lua_thread.create_suspended(drawNearby)
    render_warning = lua_thread.create_suspended(drawWarning)
    render_lquit = lua_thread.create_suspended(drawLQuit)
    -- ## Инициализация поточных функций. Рендер ## --

    -- ## Подгрузка настроек рендеров ## --
    loadDChat()
    loadFAQ()
    loadPM()
    loadWarningChat()
    loadLQuit()
    -- ## Подгрузка настроек рендеров ## --

    -- ## Запуск поточных функций ## --
    render_faq:run()
    render_pm:run() 
    render_dchat:run()
    render_warning:run()
    render_lquit:run()
    -- ## Запуск поточных функций ## --
    while true do
        wait(0)

        if elements.dchat.pos then  
            change_dchat()
        end  

        if elements.pmchat.pos then  
            change_pmchat()
        end  

        if elements.reportchat.pos then  
            change_reportchat()
        end  

        if elements.warningchat.pos then
            change_warningchat()
        end

        if elements.lquit.pos then
            change_lquit()
        end
        
    end
end

-- ## Изменение позиций рендера ## --
function change_lquit()
    if isKeyJustPressed(0x02) then
        elements.lquit.X = no_saved.X
        elements.lquit.Y = no_saved.Y
        elements.lquit.pos = false
    elseif isKeyJustPressed(0x01) then
        sampAddChatMessage(tag .. 'Положение чата выставлено.', -1)
        elements.lquit.pos = false
    else
        elements.lquit.X, elements.lquit.Y = getCursorPos()
        saveLQuit()
    end
end

function change_warningchat()
    if isKeyJustPressed(0x02) then
        elements.warningchat.X = no_saved.X
        elements.warningchat.Y = no_saved.Y
        elements.warningchat.pos = false
    elseif isKeyJustPressed(0x01) then
        sampAddChatMessage(tag .. 'Положение чата выставлено.', -1)
        elements.warningchat.pos = false
    else
        elements.warningchat.X, elements.warningchat.Y = getCursorPos()
        saveWarningChat()
    end
end

function change_dchat()
    if isKeyJustPressed(0x02) then  
        elements.dchat.X = no_saved.X  
        elements.dchat.Y = no_saved.Y 
        elements.dchat.pos = false
    elseif isKeyJustPressed(0x01) then  
        sampAddChatMessage(tag .. 'Положение чата выставлено.', -1)
        elements.dchat.pos = false
    else 
        elements.dchat.X, elements.dchat.Y = getCursorPos()        
        saveDChat()
    end 
end

function change_pmchat()
    if isKeyJustPressed(0x02) then  
        elements.pmchat.X = no_saved.X  
        elements.pmchat.Y = no_saved.Y 
        elements.pmchat.pos = false
    elseif isKeyJustPressed(0x01) then  
        sampAddChatMessage(tag .. 'Положение чата выставлено.', -1)
        elements.pmchat.pos = false
    else 
        elements.pmchat.X, elements.pmchat.Y = getCursorPos()        
        savePM()
    end 
end

function change_reportchat()
    if isKeyJustPressed(0x02) then  
        elements.reportchat.X = no_saved.X  
        elements.reportchat.Y = no_saved.Y 
        elements.reportchat.pos = false
    elseif isKeyJustPressed(0x01) then  
        sampAddChatMessage(tag .. 'Положение чата выставлено.', -1)
        elements.reportchat.pos = false
    else 
        elements.reportchat.X, elements.reportchat.Y = getCursorPos()        
        saveFAQ()
    end 
end
-- ## Изменение позиций рендера ## --

-- ## Использование поточных функций, их активация и последовательная обработка ## --
function drawWarning()
    if elements.boolean.warningchat.v then
        while true do
            for i = elements.warningchat.lines.v, 1, -1 do
                if elements.warningchat.chat_lines[i] == nil then
                    elements.warningchat.chat_lines[i] = ' '
                end
                renderFontDrawText(font_render, elements.warningchat.chat_lines[i], elements.warningchat.X, elements.warningchat.Y+(ini_file_main.main.font+4)*(elements.warningchat.lines.v - i)+6, 0xFF9999FF)
            end
            wait(1)
        end
    end
end

function drawFAQ()
    if elements.boolean.reportchat.v then  
        while true do 
            for i = elements.reportchat.lines.v, 1, -1 do  
                if elements.reportchat.chat_lines[i] == nil then  
                    elements.reportchat.chat_lines[i] = ' '
                end 
                renderFontDrawText(font_render, elements.reportchat.chat_lines[i], elements.reportchat.X, elements.reportchat.Y+(ini_file_main.main.font+4)*(elements.reportchat.lines.v - i)+6, 0xFF9999FF) 
            end 
            wait(1)
        end 
    end 
end  

function drawPM()
    if elements.boolean.pmchat.v then  
        while true do 
            for i = elements.pmchat.lines.v, 1, -1 do  
                if elements.pmchat.chat_lines[i] == nil then  
                    elements.pmchat.chat_lines[i] = ' '
                end 
                renderFontDrawText(font_render, elements.pmchat.chat_lines[i], elements.pmchat.X, elements.pmchat.Y+(ini_file_main.main.font+4)*(elements.pmchat.lines.v - i)+6, 0xFF9999FF) 
            end 
            wait(1)
        end 
    end 
end  

function drawNearby()
    if elements.boolean.dchat.v then  
        while true do 
            for i = elements.dchat.lines.v, 1, -1 do  
                if elements.dchat.chat_lines[i] == nil then  
                    elements.dchat.chat_lines[i] = ' '
                end 
                renderFontDrawText(font_render, elements.dchat.chat_lines[i], elements.dchat.X, elements.dchat.Y+(ini_file_main.main.font+4)*(elements.dchat.lines.v - i)+6, 0xFF9999FF) 
            end 
            wait(1)
        end 
    end 
end

function drawLQuit()
    if elements.boolean.lquit.v then
        while true do
            for i = elements.lquit.lines.v, 1, -1 do
                if elements.lquit.chat_lines[i] == nil then
                    elements.lquit.chat_lines[i] = ' '
                end
                renderFontDrawText(font_render, elements.lquit.chat_lines[i], elements.lquit.X, elements.lquit.Y+(ini_file_main.main.font+4)*(elements.lquit.lines.v - i)+6, 0xFF9999FF)
            end
            wait(1)
        end
    end
end
-- ## Использование поточных функций, их активация и последовательная обработка ## --

function EXPORTS.ActiveChatRenders()
    if imgui.TreeNode(u8"Вывод отдельных строк чата") then
        if imgui.RadioButton(u8"/pm", rbutton, 1) then  
            change_dest = 1 
        end  
        if imgui.RadioButton(u8"/d", rbutton, 2) then  
            change_dest = 2
        end  
        if imgui.RadioButton(u8"/report", rbutton, 3) then  
            change_dest = 3
        end  
        if imgui.RadioButton(u8"WarningChat", rbutton, 4) then
            change_dest = 4
        end
        if imgui.RadioButton(u8"Вход/Выход", rbutton, 5) then
            change_dest = 5
        end
        if change_dest == 1 then  
            imgui.Text(u8"Включение рендера /pm")
            imgui.SameLine()
            if imgui.ToggleButton('##ActiveRenderPM', elements.boolean.pmchat) then  
                config.settings.pmchat = elements.boolean.pmchat.v 
                save()  
            end
            imgui.Text(u8'Количество строк: ')
            imgui.PushItemWidth(80)
            imgui.InputInt('##LinesPM', elements.pmchat.lines)
            imgui.PopItemWidth()
            if imgui.Button(u8'Положение чата') then
                no_saved.X = elements.pmchat.X; no_saved.Y = elements.pmchat.Y
                elements.pmchat.pos = true
            end
            if imgui.Button(u8'Сохранить') then  
                showNotification("Настройка рендера /pm сохранены")
                savePM()
            end
        end
        if change_dest == 2 then  
            imgui.Text(u8"Включение рендера /d")
            imgui.SameLine()
            if imgui.ToggleButton('##ActiveRenderNearby', elements.boolean.dchat) then  
                config.settings.dchat = elements.boolean.dchat.v 
                save()  
            end
            imgui.Text(u8'Количество строк: ')
            imgui.PushItemWidth(80)
            imgui.InputInt('##LinesNearby', elements.dchat.lines)
            imgui.PopItemWidth()
            if imgui.Button(u8'Положение чата') then
                no_saved.X = elements.dchat.X; no_saved.Y = elements.dchat.Y
                elements.dchat.pos = true
            end
            if imgui.Button(u8'Сохранить') then  
                showNotification("Настройка рендера /d сохранены")
                saveDChat()
            end
        end
        if change_dest == 3 then  
            imgui.Text(u8"Включение рендера /report")
            imgui.SameLine()
            if imgui.ToggleButton('##ActiveRenderANS', elements.boolean.reportchat) then  
                config.settings.reportchat = elements.boolean.reportchat.v 
                save()  
            end
            imgui.Text(u8'Количество строк: ')
            imgui.PushItemWidth(80)
            imgui.InputInt('##LinesReport', elements.reportchat.lines)
            imgui.PopItemWidth()
            if imgui.Button(u8'Положение чата') then
                no_saved.X = elements.reportchat.X; no_saved.Y = elements.reportchat.Y
                elements.reportchat.pos = true
            end
            if imgui.Button(u8'Сохранить') then  
                showNotification("Настройка рендера /report сохранены")
                saveFAQ()
            end
        end
        if change_dest == 4 then
            imgui.Text(u8"Включение рендера WarningChat")
            imgui.SameLine()
            if imgui.ToggleButton('##ActiveRenderWarningChat', elements.boolean.warningchat) then
                config.settings.warningchat = elements.boolean.warningchat.v
                save()
            end
            imgui.Text(u8'Количество строк: ')
            imgui.PushItemWidth(80)
            imgui.InputInt('##LinesWarningChat', elements.warningchat.lines)
            imgui.PopItemWidth()
            if imgui.Button(u8'Положение чата') then
                no_saved.X = elements.warningchat.X; no_saved.Y = elements.warningchat.Y
                elements.warningchat.pos = true
            end
            if imgui.Button(u8'Сохранить') then
                showNotification("Настройка рендера WarningChat сохранена")
                saveWarningChat()
            end
        end
        if change_dest == 5 then
            imgui.Text(u8"Включение рендера Вход/Выход")
            imgui.SameLine()
            if imgui.ToggleButton('##ActiveRenderLogin', elements.boolean.lquit) then
                config.settings.lquit = elements.boolean.lquit.v
                save()
            end
            imgui.Text(u8'Количество строк: ')
            imgui.PushItemWidth(80)
            imgui.InputInt('##LinesLogin', elements.lquit.lines)
            imgui.PopItemWidth()
            if imgui.Button(u8'Положение чата') then
                no_saved.X = elements.lquit.X; no_saved.Y = elements.lquit.Y
                elements.lquit.pos = true
            end
            if imgui.Button(u8'Сохранить') then
                showNotification("Настройка рендера Вход/Выход сохранена")
                saveLQuit()
            end
        end
        imgui.TreePop()
    end
end

function EXPORTS.OffScript()
    thisScript():unload()
end

function EXPORTS.ReportIsCheck(arguremt)
    if arguremt == '1' then  
        report_checking = false  
    else 
        report_checking = true
    end
    return report_checking
end