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

local config = inicfg.load({
    settings = {
        dchat = false,
        pmchat = false,
        reportchat = false,
        Font = 10,
    },
    render = {
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
    },
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
    },
    int = {
        Font = imgui.ImInt(config.settings.Font), 
    },
    render = {
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
    },
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
-- ## Взаимодействие с интерфейсом ImGUI ## --

-- ## Функции для прямых действий с рендером ## -- 
local font_render = renderCreateFont("Arial", tonumber(elements.int.Font.v), fflags.BOLD + fflags.SHADOW)
-- ## Функции для прямых действий с рендером ## -- 

-- ## Сохранение рендерных параметров ## --
function saveDChat()
    config.render.dchat.X = elements.render.dchat.X 
    config.render.dchat.Y = elements.render.dchat.Y 
    config.render.dchat.lines = elements.render.dchat.lines.v  
    save()  
end  

function saveFAQ()
    config.render.reportchat.X = elements.render.reportchat.X 
    config.render.reportchat.Y = elements.render.reportchat.Y  
    config.render.reportchat.lines = elements.render.reportchat.lines.v  
    save()
end  

function savePM()
    config.render.pmchat.X = elements.render.pmchat.X  
    config.render.pmchat.Y = elements.render.pmchat.Y  
    config.render.pmchat.lines = elements.render.pmchat.lines.v
    save() 
end  

function loadDChat()
    elements.render.dchat.X = config.render.dchat.X  
    elements.render.dchat.Y = config.render.dchat.Y  
    elements.render.dchat.lines.v = config.render.dchat.lines  
end

function loadFAQ()
    elements.render.reportchat.X = config.render.reportchat.X  
    elements.render.reportchat.Y = config.render.reportchat.Y  
    elements.render.reportchat.lines.v = config.render.reportchat.lines  
end

function loadPM()
    elements.render.pmchat.X = config.render.pmchat.X  
    elements.render.pmchat.Y = config.render.pmchat.Y  
    elements.render.pmchat.lines.v = config.render.pmchat.lines  
end
-- ## Сохранение рендерных параметров ## --

function sampev.onServerMessage(color, text)
    if text:find("%[A] SMS:") and elements.boolean.pmchat.v then  
        local pm_text = text:match("%[A] SMS: (.+)")
        for i = elements.render.pmchat.lines.v, 1, -1 do  
            if i ~= 1 then  
                elements.render.pmchat.chat_lines[i] = elements.render.pmchat.chat_lines[-1]
            else 
                elements.render.pmchat.chat_lines[i] = "{00BFFF} [AT-PM] {FFFFFF}: " .. pm_text
            end
        end 
        return false
    end
    if text:find("%[A] NEARBY CHAT: (.+)") and elements.boolean.dchat.v then  
        local d_text = text:match("%[A] NEARBY CHAT: (.+)")
        for i = elements.render.dchat.lines.v, 1, -1 do  
            if i ~= 1 then  
                elements.render.dchat.chat_lines[i] = elements.render.dchat.chat_lines[i-1]
            else  
                elements.render.dchat.chat_lines[i] = "{00BFFF} [AT-NEARBY]: {FFFFFF}" .. d_text
            end 
        end
    end
    if text:find("Жалоба (.+) | {AFAFAF}(.+)%[(%d+)%]: (.+)") and elements.boolean.reportchat.v then  
    end
end

function main()
    while not isSampAvailable() do wait(0) end
    
    sampfuncsLog(log .. "Скрипт для рендера отдельных строк чата инициализированы.")

    while true do
        wait(0)
        
    end
end