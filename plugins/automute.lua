require 'lib.moonloader'
local inicfg = require 'inicfg' -- работа с конфигами
local sampev = require "lib.samp.events" -- подключение основных библиотек, связанные с потокам пакетов ивентов SA:MP, и их прямое соединение с LUA
local atlibs = require 'libsfor' -- библиотека для работы с АТ
local encoding = require 'encoding' -- работа с кодировками
local imgui = require 'imgui' -- MoonImGUI || Пользовательский интерфейс
local notf_res, notf = pcall(import, 'lib/imgui_notf.lua')  -- плагин уведомлений

local fa = require 'faicons' -- работа с иконками Font Awesome 4

-- ## Блок текстовых переменных ## --
local tag = "{00BFFF} [AT] {FFFFFF}" -- тэг AT
local log = "{00BFFF} [AdminTool-Log] {FFFFFF}" -- тэг лога АТ
local ntag = "{00BFFF} Notf - AdminTool" -- тэг уведомлений АТ
encoding.default = 'CP1251' -- смена кодировки на CP1251
u8 = encoding.UTF8 -- переименовка стандтартного режима кодировки UTF8 - u8
-- ## Блок текстовых переменных ## --

-- ## Шрифт для иконок ## --
function imgui.BeforeDrawFrame()
    if fa_font == nil then
		local font_config = imgui.ImFontConfig()
		font_config.MergeMode = true 
		fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fontawesome-webfont.ttf', 14.0, font_config, fa_glyph_ranges)
	end	
end
-- ## Шрифт для иконок ## --

-- ## Регистрация уведомлений ## --
function showNotification(text)
	notf.addNotify(ntag, text, 2, 1, 6)
end
-- ## Регистрация уведомлений ## --

-- ## Блок для работы с конфигом и его переменными ## --
local directoryAM = getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute"
local directIni = "AdminTool\\amsettings.ini"
local config = inicfg.load({
    settings = {
        automute_mat = false,
        automute_osk = false,
        automute_rod = false, 
        automute_upom = false, 
    },
}, directIni)
inicfg.save(config, directIni)

local elements = {
    settings = {
        automute_mat = imgui.ImBool(config.settings.automute_mat),
        automute_osk = imgui.ImBool(config.settings.automute_osk),
        automute_rod = imgui.ImBool(config.settings.automute_rod),
        automute_upom = imgui.ImBool(config.settings.automute_upom),
    }
}

function save() 
    inicfg.save(config, directIni)
end
-- ## Блок для работы с конфигом и его переменными ## --

-- ## Работа с элементами аддонов ImGUI (необходимо для корректного экспорта) ## --
imgui.ToggleButton = require('imgui_addons').ToggleButton
-- ## Работа с элементами аддонов ImGUI (необходимо для корректного экспорта) ## --

-- ## Блок переменных, отвечающих за работу автомута и интеграции сцен ## --
local onscene_mat = { 
    "блять", "сука", "хуй", "нахуй" 
} 
local onscene_osk = { 
    "пидр", "лох", "гандон", "уебан" 
}
local onscene_upom = {
    "аризона", "russian roleplay", "evolve", "эвольв"
}
local onscene_rod = { 
    "мать ебал", "mq", "мать в канаве", "твоя мать шлюха", "твой рот шатал", "mqq", "mmq", 'mmqq', "matb v kanave",
}
local control_onscene_mat = false -- контролирование сцены автомута "Нецензурная лексика"
local control_onscene_osk = false -- контролирование сцены автомута "Оскорбление/унижение"
local control_onscene_upom = false -- контролирование сцены автомута "Упоминание стор.проектов"
local control_onscene_rod = false -- контролирование сцены автомута "Оскорбление родных"

-- ## Функция, позволяющая правильно распределять слова и искать полноценные совпадения ## -- 
function checkMessage(msg, arg) -- под аргументом воспринимается номер нужного mainstream (от 1 до 4); Где 1 - мат, 2 - оск, 3 - упом.стор.проектов, 4 - оск род
    if msg ~= nil then -- проверка, передается ли сообщение в функцию для правильности поиска
        if arg == 1 then -- MainStream Automute-Report For "Нецензурная лексика"  
            for i, ph in ipairs(onscene_mat) do -- берется сначала массив с заполненными скриптом словами, внесенными в файл
                nmsg = atlibs.string_split(msg, " ") -- разбитие сообщения на массив по словам
                for j, word in ipairs(nmsg) do -- цикл хождения по словам внутри массива
                    if ph == atlibs.string_rlower(word) then  -- если запрещенное слово есть внутри массива, то
                        return true, ph -- возврат True и запрещенное слово
                    end  
                end  
            end  
        elseif arg == 2 then -- MainStream Automute-Report For "Оскорбление/Унижение" 
            for i, ph in ipairs(onscene_osk) do -- берется сначала массив с заполненными скриптом словами, внесенными в файл
                nmsg = atlibs.string_split(msg, " ") -- разбитие сообщения на массив по словам
                for j, word in ipairs(nmsg) do -- цикл хождения по словам внутри массива
                    if ph == atlibs.string_rlower(word) then  -- если запрещенное слово есть внутри массива, то
                        return true, ph -- возврат True и запрещенное слово
                    end  
                end  
            end
        elseif arg == 3 then -- MainStream Automute-Report For "Упоминание сторонних проектов"  
            for i, ph in ipairs(onscene_upom) do -- массив с заполненными скриптом словами из файла
                if string.find(msg, ph, 1, true) then -- поиск целиком по строке. Почему применяется данный метод? Акцент больше на предложения, нежели как в циклах выше 
                    return true, ph -- возвращаем True и запрещенное слово
                end 
            end
        elseif arg == 4 then -- MainStream Automute-Report For "Оскорбление родных" 
            for i, ph in ipairs(onscene_rod) do -- массив с заполненными скриптом словами из файла
                if string.find(msg, ph, 1, true) then -- поиск целиком по строке. Почему применяется данный метод? Акцент больше на предложения, нежели как в циклах выше 
                    return true, ph -- возвращаем True и запрещенное слово
                end 
            end 
        end  
    end
end 
-- ## Блок переменных, отвечающих за работу автомута и интеграции сцен ## --

function sampev.onServerMessage(color, text)

    local check_nick, check_id, basic_color, check_text = string.match(text, "(.+)%((.+)%): {(.+)}(.+)") -- захват основной строчки чата и разбития её на объекты

    -- ## Автомут, чей mainframe - репорты ## --
    if not isGamePaused() and not isPauseMenuActive() and isGameWindowForeground() then  
        if text:find("Жалоба (.+) | {AFAFAF}(.+)%[(%d+)%]: (.+)") then  
            local number_report, nick_rep, id_rep, text_rep = text:match("Жалоба (.+) | {AFAFAF}(.+)%[(%d+)%]: (.+)") 
            sampAddChatMessage(tag .. "Пришел репорт " .. number_report .. " от " .. nick_rep .. "[" .. id_rep .. "]: " .. text_rep, -1)
            if elements.settings.automute_mat.v or elements.settings.automute_osk.v or elements.settings.automute_rod.v or elements.settings.automute_rod.v then  
                local mat_text, _ = checkMessage(text_rep, 1)
                local osk_text, _ = checkMessage(text_rep, 2)
                local upom_text, _ = checkMessage(text_rep, 3)
                local rod_text, _ = checkMessage(text_rep, 4)
                if mat_text and elements.settings.automute_mat.v then  
                    sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                    sampAddChatMessage(tag .. " | Мут ID[" .. id_rep .. "] за rep: " .. text_rep, -1)
                    sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                    sampSendChat("/rmute " .. id_rep .. " 300 Нецензурная лексика")
                    showNotification("Нарушитель: " .. nick_rep .. "[" .. id_rep .. "] \n Замучен за 'мат'. \n Его текст: " .. text_rep)
                end
                if osk_text and elements.settings.automute_osk.v then  
                    sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                    sampAddChatMessage(tag .. " | Мут ID[" .. id_rep .. "] за rep: " .. text_rep, -1)
                    sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                    sampSendChat("/rmute " .. id_rep .. " 400 Оск/Униж.")
                    showNotification("Нарушитель: " .. nick_rep .. "[" .. id_rep .. "] \n Замучен за 'Оскорбление/Унижение'. \n Его текст: " .. text_rep)
                end
                if upom_text and elements.settings.automute_upom.v then  
                    sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                    sampAddChatMessage(tag .. " | Мут ID[" .. id_rep .. "] за rep: " .. text_rep, -1)
                    sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                    sampSendChat("/rmute " .. id_rep .. " 1000 Упом.стор.проектов")
                    showNotification("Нарушитель: " .. nick_rep .. "[" .. id_rep .. "] \n Замучен за 'Упом.стор.проектов'. \n Его текст: " .. text_rep)
                end
                if rod_text and elements.settings.automute_rod.v then  
                    sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                    sampAddChatMessage(tag .. " | Мут ID[" .. id_rep .. "] за rep: " .. text_rep, -1)
                    sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                    sampSendChat("/rmute " .. id_rep .. " 5000 Оск/Униж. родных")
                    showNotification("Нарушитель: " .. nick_rep .. "[" .. id_rep .. "] \n Замучен за 'Оскорбление/Унижение родных'. \n Его текст: " .. text_rep)
                end
            end  
            return true
        end
    end
    -- ## Автомут, чей mainframe - репорты ## --

    -- ## Автомут, чей mainframe - чат ## --
    if not isGamePaused() and not isPauseMenuActive() and isGameWindowForeground() then  
        if check_text ~= nil and check_id ~= nil and (elements.settings.automute_mat.v or elements.settings.automute_osk.v or elements.settings.automute_upom.v or elements.settings.automute_rod.v) then  
            local mat_text, _ = checkMessage(check_text, 1)
            local osk_text, _ = checkMessage(check_text, 2)
            local upom_text, _ = checkMessage(check_text, 3)
            local rod_text, _ = checkMessage(check_text, 4)
            if mat_text and elements.settings.automute_mat.v then  
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                sampAddChatMessage(tag .. " | Мут ID[" .. check_id .. "] за msg: " .. check_text, -1)
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                sampSendChat("/mute " .. check_id .. " 300 Нецензурная лексика")
                showNotification("Нарушитель: " .. check_nick .. "[" .. check_id .. "] \n Замучен за 'мат'. \n Его текст: " .. check_text)
            end
            if osk_text and elements.settings.automute_osk.v then  
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                sampAddChatMessage(tag .. " | Мут ID[" .. check_id .. "] за msg: " .. check_text, -1)
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                sampSendChat("/mute " .. check_id .. " 400 Оск/Униж.")
                showNotification("Нарушитель: " .. check_nick .. "[" .. check_id .. "] \n Замучен за 'Оскорбление/Унижение'. \n Его текст: " .. check_text)
            end
            if upom_text and elements.settings.automute_upom.v then  
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                sampAddChatMessage(tag .. " | Мут ID[" .. check_id .. "] за msg: " .. check_text, -1)
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                sampSendChat("/mute " .. check_id .. " 1000 Упом.стор.проектов")
                showNotification("Нарушитель: " .. check_nick .. "[" .. check_id .. "] \n Замучен за 'Упом.стор.проектов'. \n Его текст: " .. check_text)
            end
            if rod_text and elements.settings.automute_rod.v then  
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                sampAddChatMessage(tag .. " | Мут ID[" .. check_id .. "] за msg: " .. check_text, -1)
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                sampSendChat("/mute " .. check_id .. " 5000 Оск/Униж. родных")
                showNotification("Нарушитель: " .. check_nick .. "[" .. check_id .. "] \n Замучен за 'Оскорбление/Унижение родных'. \n Его текст: " .. check_text)
            end
            return true
        end
    end 

    -- ## Автомут, чей mainframe - чат ## --
end

function main()
    while not isSampAvailable() do wait(0) end
    
    -- ## Блок проверки на нахождение нужных файлов в рабочей папке ## --
    if not doesDirectoryExist(directoryAM) then  
        createDirectory(directoryAM)
    end

    local file_read, file_line = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\mat.txt", "r"), -1
    if file_read ~= nil then  
        file_read:seek("set", 0)
        for line in file_read:lines() do  
            onscene_mat[file_line] = line  
            file_line = file_line + 1 
        end  
        file_read:close()  
    else
        file_read, file_line = io.open(directoryAM.."\\mat.txt", 'w'), 1
        for _, v in ipairs(onscene_mat) do  
            file_read:write(v .. "\n")
        end 
        file_read:close()
    end

    local file_read, file_line = io.open(directoryAM.."\\osk.txt", 'r'), 1
    if file_read ~= nil then  
        file_read:seek("set", 0)
        for line in file_read:lines() do  
            onscene_osk[file_line] = line  
            file_line = file_line + 1 
        end  
        file_read:close()  
    else 
        file_read, file_line = io.open(directoryAM.."\\osk.txt", 'w'), 1
        for _, v in ipairs(onscene_osk) do  
            file_read:write(v .. "\n")
        end 
        file_read:close()
    end

    local file_read, file_line = io.open(directoryAM.."\\rod.txt", 'r'), 1
    if file_read ~= nil then  
        file_read:seek("set", 0)
        for line in file_read:lines() do  
            onscene_rod[file_line] = line  
            file_line = file_line + 1 
        end  
        file_read:close()  
    else
        file_read, file_line = io.open(directoryAM.."\\rod.txt", 'w'), 1
        for _, v in ipairs(onscene_rod) do  
            file_read:write(v .. "\n")
        end 
        file_read:close()
    end

    local file_read, file_line = io.open(directoryAM.."\\upom.txt", 'r'), 1
    if file_read ~= nil then  
        file_read:seek("set", 0)
        for line in file_read:lines() do  
            onscene_upom[file_line] = line  
            file_line = file_line + 1 
        end  
        file_read:close()  
    else 
        file_read, file_line = io.open(directoryAM.."\\upom.txt", 'w'), 1
        for _, v in ipairs(onscene_upom) do  
            file_read:write(v .. "\n")
        end 
        file_read:close()
    end
    -- ## Блок проверки на нахождение нужных файлов в рабочей папке ## --

    -- ## Блок регистрирующий команды для работы с автомутом (ввод своих слов/удаление слов) ## --
    
    sampRegisterChatCommand("s_rod", save_rod)
    sampRegisterChatCommand("d_rod", delete_rod)

    sampRegisterChatCommand("s_upom", save_upom)
    sampRegisterChatCommand("d_upom", delete_upom)

    sampRegisterChatCommand("s_osk", save_osk)
    sampRegisterChatCommand("d_osk", delete_osk)

    sampRegisterChatCommand("s_mat", save_mat)
    sampRegisterChatCommand("d_mat", delete_mat)

    -- ## Блок регистрирующий команды для работы с автомутом (ввод своих слов/удаление слов) ## --

    while true do
        wait(0)
        
    end
end

-- ## Блок функций, отвечающий на введенные в блоке регистра команды. Применяется к автомуту ## --
function save_rod(param)
    if param == nil then  
        return false  
    end 
    for _, val in ipairs(onscene_rod) do  
        if atlibs.string_rlower(param) == val then  
            sampAddChatMessage(tag .. " Фраза \"" .. val .. "\" уже присутствует в списке фраз оскорбления родных.")
            return false  
        end    
    end  
    local file_write, file_line = io.open(directoryAM.."\\rod.txt", 'w'), 1
    onscene_rod[#onscene_rod + 1] = atlibs.string_rlower(param)
    for _, val in ipairs(onscene_rod) do  
        file_write:write(val .. "\n")
    end  
    file_write:close() 
    sampAddChatMessage(tag .. " Фраза \"" .. atlibs.string_rlower(param) .. "\" успешно добавлена в список фраз оскорблений родных")
end

function delete_rod(param)
    if param == nil then  
        return false  
    end  
    local file_write, file_line = io.open(directoryAM.. "\\rod.txt", "w"), 1
    for i, val in ipairs(onscene_rod) do
        if val == atlibs.string_rlower(param) then
            onscene_rod[i] = nil
            control_onscene_rod = true
        else
            file_write:write(val .. "\n")
        end
    end
    file_write:close()
    if control_onscene_rod then
        sampAddChatMessage(tag .. " Фраза \"" .. atlibs.string_rlower(param) .. "\" была успешно удалено из списка фраз оскорблений родных")
        control_onscene_rod = false
    else
        sampAddChatMessage(tag .. " Фразы \"" .. atlibs.string_rlower(param) .. "\" нет в списке фраз оскорблений родных")
    end
end

function save_upom(param)
    if param == nil then  
        return false 
    end 
    for _, val in ipairs(onscene_upom) do 
        if atlibs.string_rlower(param) == val then  
            sampAddChatMessage(tag .. " Фраза \"" .. val .. "\" уже присутствует в списке фраз упоминаний сторонних проектов.")
            return false 
        end 
    end 
    local file_read, file_line = io.open(directoryAM.. "\\upom.txt", "w"), 1
    onscene_upom[#onscene_upom + 1] = atlibs.string_rlower(param)
    for _, val in ipairs(onscene_upom) do 
        file_read:write(val .. "\n")
    end 
    file_read:close() 
    sampAddChatMessage(tag .. " Фраза \"" .. atlibs.string_rlower(param) .. "\" успешно добавлена в список фраз упоминаний сторонних проектов.")
end

function delete_upom(param)
    if param == nil then
        return false
    end
    local file_read, file_read = io.open(directoryAM.. "\\upom.txt", "w"), 1
    for i, val in ipairs(onscene_upom) do
        if val == atlibs.string_rlower(param) then
            onscene_upom[i] = nil
            control_onscene_upom = true
        else
            file_read:write(val .. "\n")
        end
    end
    file_read:close()
    if control_onscene_upom then
        sampAddChatMessage(tag .. " Фраза \"" .. atlibs.string_rlower(param) .. "\" была успешно удалено из списка фраз упоминаний сторонних проектов.")
        control_onscene_upom = false
    else
        sampAddChatMessage(tag .. " Фразы \"" .. atlibs.string_rlower(param) .. "\" нет в списке фраз упоминаний сторонних проектов.")
    end
end

function save_osk(param)
    if param == nil then
        return false
    end
    for _, val in ipairs(onscene_osk) do
        if atlibs.string_rlower(param) == val then
            sampAddChatMessage(tag .. " Слово \"" .. val .. "\" уже присутствует в списке оскорблений/унижений.")
            return false
        end
    end
    local file_write, file_line = io.open(directoryAM.. "\\osk.txt", "w"), 1
    onscene_osk[#onscene_osk + 1] = atlibs.string_rlower(param)
    for _, val in ipairs(onscene_osk) do
        file_write:write(val .. "\n")
    end
    file_write:close()
    sampAddChatMessage(tag .. " Слово \"" .. atlibs.string_rlower(param) .. "\" успешно добавлено в список оскорблений/унижений.")
end

function delete_osk(param)
    if param == nil then
        return false
    end
    local file_write, file_line = io.open(directoryAM.. "\\osk.txt", "w"), 1
    for i, val in ipairs(onscene_osk) do
        if val == atlibs.string_rlower(param) then
            onscene_osk[i] = nil
            control_onscene_osk = true
        else
            file_write:write(val .. "\n")
        end
    end
    file_write:close()
    if control_onscene_osk then
        sampAddChatMessage(tag .. " Слово \"" .. atlibs.string_rlower(param) .. "\" было успешно удалено из списка оскорблений/унижений.")
        control_onscene_osk = false
    else
        sampAddChatMessage(tag .. " Слова \"" .. atlibs.string_rlower(param) .. "\" нет в списке оскорблений/унижений.")
    end
end

function save_mat(param)
    if param == nil then
        return false
    end
    for _, val in ipairs(onscene_mat) do
        if atlibs.string_rlower(param) == val then
            sampAddChatMessage(tag .. " Слово \"" .. val .. "\" уже присутствует в списке нецензурной брани.")
            return false
        end
    end
    local file_write, file_line = io.open(directoryAM.. "\\mat.txt", "w"), 1
    onscene_mat[#onscene_mat + 1] = atlibs.string_rlower(param)
    for _, val in ipairs(onscene_mat) do
        file_write:write(val .. "\n")
    end
    file_write:close()
    sampAddChatMessage(tag .. " Слово \"" .. atlibs.string_rlower(param) .. "\" успешно добавлено в список нецензурной лексики.")
end

function delete_mat(param)
    if param == nil then
        return false
    end
    local file_write, file_line = io.open(directoryAM.. "\\mat.txt", "w"), 1
    for i, val in ipairs(onscene_mat) do
        if val == atlibs.string_rlower(param) then
            onscene_mat[i] = nil
            control_onscene_mat = true
        else
            file_write:write(val .. "\n")
        end
    end
    file_write:close()
    if control_onscene_mat then
        sampAddChatMessage(tag .. " Слово \"" .. atlibs.string_rlower(param) .. "\" было успешно удалено из списка нецензурной брани.")
        control_onscene_mat = false
    else
        sampAddChatMessage(tag .. " Слова \"" .. atlibs.string_rlower(param) .. "\" нет в списке нецензурщины.")
    end
end
-- ## Блок функций, отвечающий на введенные в блоке регистра команды. Применяется к автомуту ## --

-- ## Блок функций-экспорта для интеграции их в основной скрипт ## --
function EXPORTS.ActiveAutoMute()
    if imgui.Button(fa.ICON_NEWSPAPER_O .. u8" Автомут") then  
        imgui.OpenPopup('SettingsAutoMute')
    end 
    if imgui.BeginPopup('SettingsAutoMute') then  
        if imgui.ToggleButton(u8'Автомут за мат', elements.settings.automute_mat) then  
            config.settings.automute_mat = elements.settings.automute_mat.v  
            save()  
        end
        if imgui.ToggleButton(u8'Автомут за оск', elements.settings.automute_osk) then  
            config.settings.automute_osk = elements.settings.automute_osk.v  
            save() 
        end  
        if imgui.ToggleButton(u8'Автомут за упом.стор.проектов', elements.settings.automute_upom) then  
            config.settings.automute_upom = elements.settings.automute_upom.v  
            save()  
        end  
        if imgui.ToggleButton(u8'Автомут за оск родных', elements.settings.automute_rod) then  
            config.settings.automute_rod = elements.settings.automute_rod.v  
            save()  
        end
        imgui.EndPopup()
    end
end
-- ## Блок функций-экспорта для интеграции их в основной скрипт ## --