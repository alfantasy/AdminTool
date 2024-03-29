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
    },
    imgui = {
        selectable = 0,
        stream = imgui.ImBuffer(65536),
        input_word = imgui.ImBuffer(500),
    },
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

local russian_characters = {
    [168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я',
} 

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
                sampAddChatMessage('                                                                            ')
                sampAddChatMessage(tag .. " | Мут " .. check_nick .. "[" .. check_id .. "] за msg: " .. check_text, -1)
                sampAddChatMessage('                                                                            ')
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                sampSendChat("/mute " .. check_id .. " 300 Нецензурная лексика")
                showNotification("Нарушитель: " .. check_nick .. "[" .. check_id .. "] \n Замучен за 'мат'. \n Его текст: " .. check_text)
            end
            if osk_text and elements.settings.automute_osk.v then  
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                sampAddChatMessage('                                                                            ')
                sampAddChatMessage(tag .. " | Мут " .. check_nick .. "[" .. check_id .. "] за msg: " .. check_text, -1)
                sampAddChatMessage('                                                                            ')
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                sampSendChat("/mute " .. check_id .. " 400 Оск/Униж.")
                showNotification("Нарушитель: " .. check_nick .. "[" .. check_id .. "] \n Замучен за 'Оскорбление/Унижение'. \n Его текст: " .. check_text)
            end
            if upom_text and elements.settings.automute_upom.v then  
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                sampAddChatMessage('                                                                            ')
                sampAddChatMessage(tag .. " | Мут " .. check_nick .. "[" .. check_id .. "] за msg: " .. check_text, -1)
                sampAddChatMessage('                                                                            ')
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                sampSendChat("/mute " .. check_id .. " 1000 Упом.стор.проектов")
                showNotification("Нарушитель: " .. check_nick .. "[" .. check_id .. "] \n Замучен за 'Упом.стор.проектов'. \n Его текст: " .. check_text)
            end
            if rod_text and elements.settings.automute_rod.v then  
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                sampAddChatMessage('                                                                            ')
                sampAddChatMessage(tag .. " | Мут " .. check_nick .. "[" .. check_id .. "] за msg: " .. check_text, -1)
                sampAddChatMessage('                                                                            ')
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

    local file_read_mat, file_line_mat = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\mat.txt", "r"), -1
    if file_read_mat ~= nil then  
        file_read_mat:seek("set", 0)
        for line in file_read_mat:lines() do  
            onscene_mat[file_line_mat] = line  
            file_line_mat = file_line_mat + 1 
        end  
        file_read_mat:close()  
    else
        file_read_mat, file_line_mat = io.open(directoryAM.."\\mat.txt", 'w'), 1
        for _, v in ipairs(onscene_mat) do  
            file_read_mat:write(v .. "\n")
        end 
        file_read_mat:close()
    end

    local file_read_osk, file_line_osk = io.open(directoryAM.."\\osk.txt", 'r'), 1
    if file_read_osk ~= nil then  
        file_read_osk:seek("set", 0)
        for line in file_read_osk:lines() do  
            onscene_osk[file_line_osk] = line  
            file_line_osk = file_line_osk + 1 
        end  
        file_read_osk:close()  
    else 
        file_read_osk, file_line_osk = io.open(directoryAM.."\\osk.txt", 'w'), 1
        for _, v in ipairs(onscene_osk) do  
            file_read_osk:write(v .. "\n")
        end 
        file_read_osk:close()
    end

    local file_read_rod, file_line_rod = io.open(directoryAM.."\\rod.txt", 'r'), 1
    if file_read_rod ~= nil then  
        file_read_rod:seek("set", 0)
        for line in file_read_rod:lines() do  
            onscene_rod[file_line_rod] = line  
            file_line_rod = file_line_rod + 1 
        end  
        file_read_rod:close()  
    else
        file_read_rod, file_line_rod = io.open(directoryAM.."\\rod.txt", 'w'), 1
        for _, v in ipairs(onscene_rod) do  
            file_read_rod:write(v .. "\n")
        end 
        file_read_rod:close()
    end

    local file_read_upom, file_line_upom = io.open(directoryAM.."\\upom.txt", 'r'), 1
    if file_read_upom ~= nil then  
        file_read_upom:seek("set", 0)
        for line in file_read_upom:lines() do  
            onscene_upom[file_line_upom] = line  
            file_line_upom = file_line_upom + 1 
        end  
        file_read_upom:close()  
    else 
        file_read_upom, file_line_upom = io.open(directoryAM.."\\upom.txt", 'w'), 1
        for _, v in ipairs(onscene_upom) do  
            file_read_upom:write(v .. "\n")
        end 
        file_read_upom:close()
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
-- ## Блок функций, отвечающий на введенные в блоке регистра команды. Применяется к автомуту ## --

-- ## Блок функций, отвечающий за чтение файлов автомута для ввода необходимых слов ## --
function check_files_automute(param) 
    if param == "mat" then  
        local file_check = assert(io.open(getWorkingDirectory() .. '\\config\\AdminTool\\AutoMute\\mat.txt', 'r'))
        local t = file_check:read("*all")
        file_check:close()
            return t
    elseif param == "osk" then  
        local file_check = assert(io.open(getWorkingDirectory() .. '\\config\\AdminTool\\AutoMute\\osk.txt', 'r'))
        local t = file_check:read("*all")
        file_check:close()     
            return t   
    elseif param == "oskrod" then  
        local file_check = assert(io.open(getWorkingDirectory() .. '\\config\\AdminTool\\AutoMute\\rod.txt', 'r'))
        local t = file_check:read("*all")
        file_check:close()        
            return t
    elseif param == "upomproject" then  
        local file_check = assert(io.open(getWorkingDirectory() .. '\\config\\AdminTool\\AutoMute\\upom.txt', 'r'))
        local t = file_check:read("*all")
        file_check:close()        
            return t        
    end
end
-- ## Блок функций, отвечающий за чтение файлов автомута для ввода необходимых слов ## --


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

function EXPORTS.ReadWriteAM()
    if imgui.Button(u8"Редакция файлов автомута") then  
        imgui.OpenPopup('ReadWriteAutoMuteFiles')
    end 
    if imgui.BeginPopupModal('ReadWriteAutoMuteFiles', false, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize) then  
        imgui.BeginChild('##MenuRWAMF', imgui.ImVec2(165, 400), true)
            imgui.Text(u8"Ниже представлен список файлов \nв виде кнопок.\nДля выбора файла, \nнажмите на кнопку.")
            imgui.Text('')
            imgui.Separator()
            if imgui.Button(u8"Нецензурная лексика") then  
                elements.imgui.selectable = 1
            end  
            if imgui.Button(u8"Оскорбление/Унижение") then  
                elements.imgui.selectable = 2
            end  
            if imgui.Button(u8"Упом.стор.проектов") then  
                elements.imgui.selectable = 3
            end 
            if imgui.Button(u8"Оскорбление родных") then  
                elements.imgui.selectable = 4
            end
            imgui.SetCursorPosY(imgui.GetWindowHeight() - 25)
            if imgui.Button(u8"Закрыть редактор") then  
                imgui.CloseCurrentPopup()
            end
        imgui.EndChild()
        imgui.SameLine()
        imgui.BeginChild('##WindowRWAMF', imgui.ImVec2(500, 400), true)
            if elements.imgui.selectable == 0 then  
                imgui.Text(u8"Редактируйте файлы аккуратно. \nКаждое Вами введенное слово будет фиксироваться в файле при сохранении.")
                imgui.Text(u8"На данный момент ни один файл не приведен в чтение.")
            end  
            if elements.imgui.selectable == 1 then  
                imgui.Text(u8"Для добавления/удаление слов, используйте поле ввода ниже")
                imgui.InputText("##InputWord", elements.imgui.input_word)
                imgui.SameLine()
                if imgui.Button(fa.ICON_REFRESH) then  
                    elements.imgui.input_word.v = ""
                end  
                if #elements.imgui.input_word.v > 0 then
                    if imgui.Button(u8"Добавить") then  
                        save_mat(u8:decode(elements.imgui.input_word.v))
                    end  
                    if imgui.Button(u8"Удалить") then  
                        delete_mat(u8:decode(elements.imgui.input_word.v))
                    end
                end
                imgui.Separator()
                elements.imgui.stream.v = check_files_automute("mat")
                for line in elements.imgui.stream.v:gmatch("[^\r\n]+") do  
                    imgui.Text(u8(line))
                end
            end 
            if elements.imgui.selectable == 2 then  
                imgui.Text(u8"Для добавления/удаление слов, используйте поле ввода ниже")
                imgui.InputText("##InputWord", elements.imgui.input_word)
                imgui.SameLine()
                if imgui.Button(fa.ICON_REFRESH) then  
                    elements.imgui.input_word.v = ""
                end  
                if imgui.Button(u8"Добавить") then  
                    save_osk(u8:decode(elements.imgui.input_word.v))
                end  
                if imgui.Button(u8"Удалить") then  
                    delete_osk(u8:decode(elements.imgui.input_word.v))
                end
                imgui.Separator()
                elements.imgui.stream.v = check_files_automute("osk")
                for line in elements.imgui.stream.v:gmatch("[^\r\n]+") do  
                    imgui.Text(u8(line))
                end
            end 
            if elements.imgui.selectable == 3 then  
                imgui.Text(u8"Для добавления/удаление слов, используйте поле ввода ниже")
                imgui.InputText("##InputWord", elements.imgui.input_word)
                imgui.SameLine()
                if imgui.Button(fa.ICON_REFRESH) then  
                    elements.imgui.input_word.v = ""
                end  
                if imgui.Button(u8"Добавить") then  
                    save_upom(u8:decode(elements.imgui.input_word.v))
                end  
                if imgui.Button(u8"Удалить") then  
                    delete_upom(u8:decode(elements.imgui.input_word.v))
                end
                imgui.Separator()
                elements.imgui.stream.v = check_files_automute("upomproject")
                for line in elements.imgui.stream.v:gmatch("[^\r\n]+") do  
                    imgui.Text(u8(line))
                end
            end  
            if elements.imgui.selectable == 4 then  
                imgui.Text(u8"Для добавления/удаление слов, используйте поле ввода ниже")
                imgui.InputText("##InputWord", elements.imgui.input_word)
                imgui.SameLine()
                if imgui.Button(fa.ICON_REFRESH) then  
                    elements.imgui.input_word.v = ""
                end  
                if imgui.Button(u8"Добавить") then  
                    save_rod(u8:decode(elements.imgui.input_word.v))
                end  
                if imgui.Button(u8"Удалить") then  
                    delete_rod(u8:decode(elements.imgui.input_word.v))
                end
                imgui.Separator()
                elements.imgui.stream.v = check_files_automute("oskrod")
                for line in elements.imgui.stream.v:gmatch("[^\r\n]+") do  
                    imgui.Text(u8(line))
                end
            end
        imgui.EndChild()
        imgui.EndPopup()
    end
end
-- ## Блок функций-экспорта для интеграции их в основной скрипт ## --