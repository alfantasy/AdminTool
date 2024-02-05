require 'lib.moonloader'
local encoding = require 'encoding' -- работа с кодировкой
local dlstatus = require('moonloader').download_status -- работа с скачиванием различных файлов при помощи URL
local notf_res, notf = pcall(import, 'lib/imgui_notf.lua')  -- плагин уведомлений
local imgui = require 'imgui' -- MoonImGUI || Пользовательский интерфейс
local inicfg = require 'inicfg' -- работа с INI файлами
local atlibs = require 'libsfor' -- библиотека для работы с АТ

local fai = require "fAwesome5" -- работа с иконками Font Awesome 5
local fa = require 'faicons' -- работа с иконками Font Awesome 4

-- ## Блок текстовых переменных ## --
local tag = "{00BFFF} [AT] {FFFFFF}" -- тэг AT
local log = "{00BFFF} [AdminTool-Log] {FFFFFF}" -- тэг лога АТ
local ntag = "{00BFFF} Notf - AdminTool" -- тэг уведомлений АТ
encoding.default = 'CP1251' -- смена кодировки на CP1251
u8 = encoding.UTF8 -- переименовка стандтартного режима кодировки UTF8 - u8
-- ## Блок текстовых переменных ## --

-- ## Блок работы с конфигом и переменными ## --
local directIni = "AdminTool\\binsettings.ini"

local configB = inicfg.load({
    bind_name = {},
    bind_int = {},
    bind_delay = {},
    bind_argument = {},
}, directIni)
inicfg.save(configB,directIni)

function BinderSave() 
    inicfg.save(configB,directIni)
    return true
end

local elements = {
    buff = {
        name = imgui.ImBuffer(256),
        int = imgui.ImBuffer(65536),
        delay = imgui.ImBuffer(2500),
        argument = imgui.ImBool(false),
    },
    boolean = {
        CreateOrEditCommand = false,
    },
}
-- ## Блок работы с конфигом и переменными ## --

-- ## Блок переменных связанных с MoonImGUI ## --
imgui.Tooltip = require('imgui_addons').Tooltip
imgui.CenterText = require('imgui_addons').CenterText
local sw, sh = getScreenResolution()
local MenuBinder = imgui.ImBool(false)
local menuSelect = 0

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
-- ## Блок переменных связанных с MoonImGUI ## --

function main()
    while not isSampAvailable() do wait(0) end
    
    sampfuncsLog(log .. " Проводится инициализация биндера и регистрация команд. \nВ случае, если почему-то команда не зарегистрировалась, перезагрузите скрипты.")

    sampAddChatMessage(tag .. " Инициализация биндера. Регистрирую команды.")

    waiting_function = lua_thread.create_suspended(InjectWaitFunction)

    for key, cmd in pairs(configB.bind_name) do  
        if cmd:find("/(.+)") then  
            new_cmd = cmd:match("/(.+)")
            sampRegisterChatCommand(new_cmd, function(arg)
                if #configB.bind_int[key] > 0 then  
                    if tonumber(configB.bind_delay[key]) > 0 and configB.bind_delay[key] ~= nil then
                        local full_input_to_cmd = atlibs.string_split(configB.bind_int[key], "~")
                        if configB.bind_argument[key] then 
                            waiting_function:run(full_input_to_cmd, key, arg)
                        else 
                            waiting_function:run(full_input_to_cmd, key)
                        end
                    else 
                        local full_input_to_cmd = atlibs.string_split(configB.bind_int[key], "~")
                        for _, input in pairs(full_input_to_cmd) do
                            sampSendChat(u8:decode(tostring(input)))
                        end                         
                    end
                end 
            end)
        else 
            sampRegisterChatCommand(cmd, function(arg)
                if #configB.bind_int[key] > 0 then  
                    if tonumber(configB.bind_delay[key]) > 0 and configB.bind_delay[key] ~= nil then
                        local full_input_to_cmd = atlibs.string_split(configB.bind_int[key], "~")
                        if configB.bind_argument[key] then 
                            waiting_function:run(full_input_to_cmd, key, arg)
                        else 
                            waiting_function:run(full_input_to_cmd, key)
                        end
                    else 
                        local full_input_to_cmd = atlibs.string_split(configB.bind_int[key], "~")
                        for _, input in pairs(full_input_to_cmd) do
                            if configB.bind_argument[key] then  
                                if arg ~= nil then
                                    input = input:gsub("arg", arg)
                                    sampSendChat(u8:decode(tostring(input)))
                                end
                            else 
                                sampSendChat(u8:decode(tostring(input)))
                            end 
                        end                         
                    end
                end 
            end)
        end  
    end

    sampRegisterChatCommand("btool", function()
        MenuBinder.v = not MenuBinder.v 
        imgui.Process = MenuBinder.v
    end)

    while true do
        wait(0)
        
        imgui.Process = true 

        if not MenuBinder.v then  
            imgui.Process = false  
            imgui.ShowCursor = false  
        end

    end
end

function InjectWaitFunction(cmd, key_cmd, arg)
    if arg ~= nil then 
        for _, input in pairs(cmd) do  
            if input:find("arg") then  
                input = input:gsub("arg", arg)
            end
            sampSendChat(u8:decode(tostring(input)))
            wait(tonumber(configB.bind_delay[key_cmd]))
        end
    else 
        for _, input in pairs(cmd) do  
            sampSendChat(u8:decode(tostring(input)))
            wait(tonumber(configB.bind_delay[key_cmd]))
        end
    end
end

function imgui.OnDrawFrame()

    blackred()
    imgui.SwitchContext()

    if MenuBinder.v then   

        imgui.SetNextWindowSize(imgui.ImVec2(600, 300), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), (sh / 2)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

        imgui.ShowCursor = true

        imgui.Begin(fai.ICON_FA_SITEMAP .. " [AT] Binder", MenuBinder, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.MenuBar)

        imgui.BeginMenuBar()
            imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
            imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 10) 
            if imgui.Button(fai.ICON_FA_HOME, imgui.ImVec2(27,0)) then  
                menuSelect = 0 
            end
            if imgui.Button(fai.ICON_FA_EDIT, imgui.ImVec2(27,0)) then  
                menuSelect = 1 
            end
            imgui.PopStyleVar(1)
            imgui.PopStyleVar(1)
        imgui.EndMenuBar()

        if menuSelect == 0 then
            imgui.Text(u8"Данное окно является биндером команд. Вы сможете добавить все свои необходимые команды, \nили даже забиндить команды AT на свои собственные.")
            imgui.Text(u8"Это вспомогательный скрипт, работающее отдельно от пакета АТ.\nОбновляется отдельно, но есть возможность обновлять и в основном скрипте.")
            imgui.Text(u8"Ввод команд осуществляется с легкостью и ненужно никаких особенных знаний.")
            imgui.Text(u8"Интерфейс довольно прост, интуитивно понятен и описан.")
            imgui.Text(u8"Warning! При редактировании команды или введении новых, нужно будет перезагрузить скрипты \n(ALT+R)")
            imgui.Text(u8"Ну, или для особо ленивых, нажать кнопку ниже <3")
            if imgui.Button(u8"Перезагрузить все скрипты MoonLoader") then  
                lua_thread.create(function()
                    sampAddChatMessage(tag .. "Выполняю перезагрузку всех скриптов. Ожидайте.")
                    MenuBinder.v = false; imgui.Process = MenuBinder.v; imgui.ShowCursor = MenuBinder.v
                    wait(500)
                    reloadScripts()
                end)
            end
        end

        if menuSelect == 1 then  
            imgui.BeginChild('##ListCommands', imgui.ImVec2(200, 250), true)
            if imgui.Button(u8"Создать команду") then  
                elements.boolean.CreateOrEditCommand = true
                -- ## Ниже автоматическая чистка буфера для предотвращения появления текста из существующей команды.
                elements.buff.name.v, elements.buff.int.v, elements.buff.delay.v, elements.buff.argument.v = "", "", "0", false 
                getpos = nil -- предотвращение изменения уже существующей команды
                EditOldBind = false -- безопасная и автоматическая деактивация возможного редактирования другой команды
            end
            if #configB.bind_name > 0 then  
                for key, name in pairs(configB.bind_name) do  
                    if imgui.Button(name .. '##' ..key) then  
                        elements.boolean.CreateOrEditCommand = true
                        EditOldBind = true 
                        getpos = key  
                        local returnwrapped = tostring(configB.bind_int[key]):gsub("~", "\n")
                        elements.buff.int.v = returnwrapped
                        elements.buff.name.v = tostring(configB.bind_name[key])
                        elements.buff.delay.v = tostring(configB.bind_delay[key])
                        if configB.bind_argument[key] ~= nil then 
                            elements.buff.argument.v = configB.bind_argument[key]
                        end
                    end
                    imgui.SameLine()
                    if imgui.Button(fai.ICON_FA_TRASH.."##"..key, imgui.ImVec2(27,0)) then 
                        sampAddChatMessage(tag .. 'Команда "' ..u8:decode(configB.bind_name[key]).. '" удалена.') 
                        table.remove(configB.bind_name, key)
                        table.remove(configB.bind_int, key)
                        table.remove(configB.bind_delay, key)
                        table.remove(configB.bind_argument, key)
                        BinderSave()
                    end
                end
            else 
                imgui.Text(u8"Команд не создано.")
            end 
            imgui.EndChild()
            imgui.SameLine()
            imgui.BeginChild('##EditCommands', imgui.ImVec2(370, 250), true)
                if elements.boolean.CreateOrEditCommand then  
                    imgui.Text(u8"Команда: ")
                    imgui.Tooltip(u8"Желательно вводить без '/' для правильного чтения команды скриптом.")
                    imgui.SameLine()
                    imgui.PushItemWidth(130)
                    imgui.InputText("##command_name", elements.buff.name) 
                    imgui.PopItemWidth()
                    imgui.Text(u8"Задержка между выполняемыми действиями: ")
                    imgui.Tooltip(u8"Если у Вас несколько выполняемых действий в одной команде (искл. /mess), то рекомендуется поставить задержку от 500 до 5000 (измерение в миллисекундах)")
                    imgui.SameLine()
                    imgui.PushItemWidth(50)
                    imgui.InputText("##wait_command", elements.buff.delay)
                    imgui.PopItemWidth()
                    imgui.Checkbox(u8'Работа с аргументом', elements.buff.argument)
                    imgui.Tooltip(u8'Если Ваша команда предназначена для выдачи наказаний и тому подобное, то включите данную настройку для ввода ID с командой.')
                    imgui.CenterText(u8"Выполняемые действия")
                    imgui.Tooltip(u8"Не забывайте про Enter, если Ваша команда выполняет несколько действий одновременно. \n Для работы с аргументом, необходимо также в команде написать arg, если вместо этого должно быть в команде Ваше значение. \n Пример: /mute arg 400 Оскобрление/Унижение \nГде в данном случае, arg - ID игрока")
                    imgui.PushItemWidth(120)
                    imgui.InputTextMultiline("##command_input", elements.buff.int, imgui.ImVec2(-1,100))
                    imgui.PopItemWidth()
                    if imgui.Button(u8'Закрыть##bind') then  
                        elements.boolean.CreateOrEditCommand = false  
                    end  
                    imgui.SameLine()
                    if imgui.Button(u8'Сохранить##bind') then  
                        if not EditOldBind then  
                            local refresh_text = elements.buff.int.v:gsub("\n", "~")
                            table.insert(configB.bind_name, elements.buff.name.v)
                            table.insert(configB.bind_int, refresh_text)
                            table.insert(configB.bind_delay, elements.buff.delay.v)
                            table.insert(configB.bind_argument, elements.buff.argument.v)
                            if inicfg.save(configB, directIni) then  
                                sampAddChatMessage(tag .. 'Команда "' ..u8:decode(elements.buff.name.v).. '" создана.')
                                elements.buff.name.v, elements.buff.int.v, elements.buff.delay.v, elements.buff.argument.v = "", "", "0", false
                            end
                            elements.boolean.CreateOrEditCommand = false  
                        else 
                            local refresh_text = elements.buff.int.v:gsub("\n", "~")
                            table.insert(configB.bind_name, getpos, elements.buff.name.v)
                            table.insert(configB.bind_int, getpos, refresh_text)
                            table.insert(configB.bind_delay, getpos, elements.buff.delay.v)
                            table.insert(configB.bind_argument, getpos, elements.buff.argument.v)
                            table.remove(configB.bind_name, getpos + 1)
                            table.remove(configB.bind_int, getpos + 1)
                            table.remove(configB.bind_delay, getpos + 1)
                            table.remove(configB.bind_argument, getpos + 1)
                            if inicfg.save(configB, directIni) then  
                                sampAddChatMessage(tag .. 'Команда "' ..u8:decode(elements.buff.name.v).. '" отредактирована.')
                                elements.buff.name.v, elements.buff.int.v, elements.buff.delay.v, elements.buff.argument.v = "", "", "0", false
                            end  
                            EditOldBind = false
                            elements.boolean.CreateOrEditCommand = false  
                        end
                    end
                end
            imgui.EndChild()
        end

        imgui.End()
    end
end

function blackred()
    
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2

    style.WindowPadding = imgui.ImVec2(8, 8)
    style.WindowRounding = 6
    style.ChildWindowRounding = 5
    style.FramePadding = imgui.ImVec2(5, 3)
    style.FrameRounding = 3.0
    style.ItemSpacing = imgui.ImVec2(5, 4)
    style.ItemInnerSpacing = imgui.ImVec2(4, 4)
    style.IndentSpacing = 21
    style.ScrollbarSize = 10.0
    style.ScrollbarRounding = 13
    style.GrabMinSize = 8
    style.GrabRounding = 1
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

    colors[clr.Text]                   = ImVec4(0.95, 0.96, 0.98, 1.00);
    colors[clr.TextDisabled]           = ImVec4(0.29, 0.29, 0.29, 1.00);
    colors[clr.WindowBg]               = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.ChildWindowBg]          = ImVec4(0.12, 0.12, 0.12, 1.00);
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94);
    colors[clr.Border]                 = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.BorderShadow]           = ImVec4(1.00, 1.00, 1.00, 0.10);
    colors[clr.FrameBg]                = ImVec4(0.22, 0.22, 0.22, 1.00);
    colors[clr.FrameBgHovered]         = ImVec4(0.18, 0.18, 0.18, 1.00);
    colors[clr.FrameBgActive]          = ImVec4(0.09, 0.12, 0.14, 1.00);
    colors[clr.TitleBg]                = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.TitleBgActive]          = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.TitleBgCollapsed]       = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.MenuBarBg]              = ImVec4(0.20, 0.20, 0.20, 1.00);
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.39);
    colors[clr.ScrollbarGrab]          = ImVec4(0.36, 0.36, 0.36, 1.00);
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.18, 0.22, 0.25, 1.00);
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.24, 0.24, 0.24, 1.00);
    colors[clr.ComboBg]                = ImVec4(0.24, 0.24, 0.24, 1.00);
    colors[clr.CheckMark]              = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.SliderGrab]             = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.SliderGrabActive]       = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.Button]                 = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.ButtonHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00);
    colors[clr.ButtonActive]           = ImVec4(1.00, 0.21, 0.21, 1.00);
    colors[clr.Header]                 = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.HeaderHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00);
    colors[clr.HeaderActive]           = ImVec4(1.00, 0.21, 0.21, 1.00);
    colors[clr.ResizeGrip]             = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.ResizeGripHovered]      = ImVec4(1.00, 0.39, 0.39, 1.00);
    colors[clr.ResizeGripActive]       = ImVec4(1.00, 0.19, 0.19, 1.00);
    colors[clr.CloseButton]            = ImVec4(0.40, 0.39, 0.38, 0.16);
    colors[clr.CloseButtonHovered]     = ImVec4(0.40, 0.39, 0.38, 0.39);
    colors[clr.CloseButtonActive]      = ImVec4(0.40, 0.39, 0.38, 1.00);
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00);
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00);
    colors[clr.PlotHistogram]          = ImVec4(1.00, 0.21, 0.21, 1.00);
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.18, 0.18, 1.00);
    colors[clr.TextSelectedBg]         = ImVec4(1.00, 0.32, 0.32, 1.00);
    colors[clr.ModalWindowDarkening]   = ImVec4(0.26, 0.26, 0.26, 0.60);
end