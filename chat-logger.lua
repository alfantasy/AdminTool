require 'lib.moonloader'
script_author('alfantasyz')

local tag = "{FFC900}[Chat-Logger] {FFFFFF}"

local sampev = require 'lib.samp.events'
local inicfg = require 'inicfg'
local lfs = require 'lfs'
local imgui = require 'imgui' -- регистр imgui окон
local encoding = require 'encoding' -- дешифровка форматов
local chat_logger_text = { } -- текст логгера
local text_ru = { } -- текст русского лога
local accept_load_clog = false -- принятие переменной логгера
local chat_log_custom = imgui.ImBool(false)
local chat_find = imgui.ImBuffer(65536)

local directIni = "clog.ini"

local configLog = inicfg.load({
    settings = {
        clearFiles = false, 
        days_for_clear = 3,
    },
}, directIni)
inicfg.save(configLog, directIni)

local elements = {
    clearFiles = imgui.ImBool(configLog.settings.clearFiles),
    days_for_clear = imgui.ImInt(configLog.settings.days_for_clear),
}

script_properties('work-in-pause')

encoding.default = 'CP1251' -- смена кодировки на CP1251
u8 = encoding.UTF8 -- переименовка стандтартного режима кодировки UTF8 - u8

local sw, sh = getScreenResolution() -- отвечает за второстепенную длину и ширину окон.

local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' -- You will need this for encoding/decoding
-- encoding
function enc(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

-- decoding
function dec(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
    end))
end

function sampev.onServerMessage(color, text)
    chatlog = io.open(getFileName(), "r+")
    chatlog:seek("end", 0);
	chatTime = "[" .. os.date("*t").hour .. ":" .. os.date("*t").min .. ":" .. os.date("*t").sec .. "] "
    chatlog:write(enc(chatTime .. text) .. "\n")
    chatlog:flush()
	chatlog:close()
end

function theme()
    imgui.SwitchContext()
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

    colors[clr.Text] = ImVec4(0.95, 0.96, 0.98, 1.00);
    colors[clr.TextDisabled] = ImVec4(0.29, 0.29, 0.29, 1.00);
    colors[clr.WindowBg] = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.ChildWindowBg] = ImVec4(0.12, 0.12, 0.12, 1.00);
    colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94);
    colors[clr.Border] = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.BorderShadow] = ImVec4(1.00, 1.00, 1.00, 0.10);
    colors[clr.FrameBg] = ImVec4(0.22, 0.22, 0.22, 1.00);
    colors[clr.FrameBgHovered] = ImVec4(0.18, 0.18, 0.18, 1.00);
    colors[clr.FrameBgActive] = ImVec4(0.09, 0.12, 0.14, 1.00);
    colors[clr.TitleBg] = ImVec4(0.14, 0.14, 0.14, 0.81);
    colors[clr.TitleBgActive] = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51);
    colors[clr.MenuBarBg] = ImVec4(0.20, 0.20, 0.20, 1.00);
    colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.39);
    colors[clr.ScrollbarGrab] = ImVec4(0.36, 0.36, 0.36, 1.00);
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00);
    colors[clr.ScrollbarGrabActive] = ImVec4(0.24, 0.24, 0.24, 1.00);
    colors[clr.ComboBg] = ImVec4(0.24, 0.24, 0.24, 1.00);
    colors[clr.CheckMark] = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.SliderGrab] = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.SliderGrabActive] = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.Button] = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.ButtonHovered] = ImVec4(1.00, 0.39, 0.39, 1.00);
    colors[clr.ButtonActive] = ImVec4(1.00, 0.21, 0.21, 1.00);
    colors[clr.Header] = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.HeaderHovered] = ImVec4(1.00, 0.39, 0.39, 1.00);
    colors[clr.HeaderActive] = ImVec4(1.00, 0.21, 0.21, 1.00);
    colors[clr.ResizeGrip] = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.ResizeGripHovered] = ImVec4(1.00, 0.39, 0.39, 1.00);
    colors[clr.ResizeGripActive] = ImVec4(1.00, 0.19, 0.19, 1.00);
    colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16);
    colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39);
    colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00);
    colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00);
    colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00);
    colors[clr.PlotHistogram] = ImVec4(1.00, 0.21, 0.21, 1.00);
    colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.18, 0.18, 1.00);
    colors[clr.TextSelectedBg] = ImVec4(1.00, 0.32, 0.32, 1.00);
    colors[clr.ModalWindowDarkening] = ImVec4(0.26, 0.26, 0.26, 0.60);
end

local logs_file = { }
local logs_value = { }
local name_log_select = ""
local read_file = false
local update_files = false
local combo_select = imgui.ImInt(0)

function scan_logs_file()
    for line in lfs.dir(getWorkingDirectory().."\\config\\chatlog\\") do
        if line == nil then
        elseif line:match(".+%.txt") then
            table.insert(logs_file,line:match("(.+)%.txt"))
        end
    end
end    

function main()
    while not isSampAvailable() do wait(0) end
    
    load_chat_log = lua_thread.create_suspended(loadChatLog)

    chatlogDirectory = getWorkingDirectory() .. "\\config\\chatlog"
    if not doesDirectoryExist(chatlogDirectory) then
        createDirectory(getWorkingDirectory() .. "\\config\\chatlog")
    end

    sampAddChatMessage(tag .. 'Чат-логгер успешно запущен. Обо всех ошибках писать @alfantasy (VK)', -1)
    sampAddChatMessage(tag .. 'Помощь по чат-логгеру (/chelp)', -1)

    sampRegisterChatCommand('chelp', function()
        sampShowDialog(0, "{FFC900}Chat-Logger","{FFFFFF}Использование чат-логгера /clog","ОК", false)
    end)

    sampRegisterChatCommand("clog", function()
        chat_log_custom.v = not chat_log_custom.v  
        imgui.Process = chat_log_custom.v
        scan_logs_file()
    end)

    if elements.clearFiles.v then  
        scan_logs_file()
        for key, v in pairs(logs_file) do
            if v:find("(%d+)-(%d+)-(%d+)") then
                local day, month, year = v:match("(%d+)-(%d+)-(%d+)")
                for i = 0, elements.days_for_clear.v do
                    if i ~= elements.days_for_clear.v then 
                        day = tonumber(day) - 1
                        if os.remove(getWorkingDirectory() .. "\\config\\chatlog\\" .. day .. "-" .. month .. "-" .. year .. ".txt") then  
                            sampfuncsLog(tag .. "Удалил лог-файл " .. day .. "-" .. month .. "-" .. year .. ".txt")
                        end
                    end
                end
            end
        end        
    end
    
    theme()

    while true do
        wait(0)

        local result, button, _, input = sampHasDialogRespond(65)
        if result then 
            if button == 1 then  
                os.remove(getWorkingDirectory() .. "\\config\\chatlog\\" .. name_log_select)
                sampAddChatMessage(tag .. " Файл " .. name_log_select .. " был удален", -1)
                sampAddChatMessage(tag .. " Автоматически обновлю список файлов.", -1)
                logs_file = {}
                scan_logs_file()
            else 
                sampAddChatMessage(tag .. " Вы отказались от удаления файла " .. name_log_select, -1) 
            end    
        end
    end
end

function string.split(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            t[i] = str
            i = i + 1
    end
    return t
end

function readRussian()
    for key,v in pairs(chat_logger_text) do 
        local text = u8:encode(dec(v))
        table.insert(text_ru, text)
    end 
end        

function readChatlog_select()
    local file_check = assert(io.open(getWorkingDirectory() .. "\\config\\chatlog\\" .. name_log_select, "r"))
    local t = file_check:read("*all")
    sampAddChatMessage(tag .. " Чтение выбранного файла.", -1)
    file_check:close() 
    t = t:gsub("{......}", "")
    local final_text = {}
    final_text = string.split(t, "\n")
    sampAddChatMessage(tag .. " Файл прочитан.", -1)
        return final_text
end

function readChatlog()
	local file_check = assert(io.open(getWorkingDirectory() .. "\\config\\chatlog\\" .. os.date("!*t").day .. "-" .. os.date("!*t").month .. "-" .. os.date("!*t").year .. ".txt", "r"))
	local t = file_check:read("*all")
	sampAddChatMessage(tag .. " Чтение файла. ", -1)
	file_check:close()
	t = t:gsub("{......}", "")
	local final_text = {}
	final_text = string.split(t, "\n")
	sampAddChatMessage(tag .. " Файл прочитан. ", -1)
		return final_text
end

function loadChatLog()
	wait(6000)
	accept_load_clog = true
end

function getFileName()
    if not doesFileExist(getWorkingDirectory() .. "\\config\\chatlog\\" .. os.date("!*t").day .. "-" .. os.date("!*t").month .. "-" .. os.date("!*t").year .. ".txt") then
        f = io.open(getWorkingDirectory() .. "\\config\\chatlog\\" .. os.date("!*t").day .. "-" .. os.date("!*t").month .. "-" .. os.date("!*t").year .. ".txt","w")
        f:close()
        file = string.format(getWorkingDirectory() .. "\\config\\chatlog\\" .. os.date("!*t").day .. "-" .. os.date("!*t").month .. "-" .. os.date("!*t").year .. ".txt")
        return file
    else
        file = string.format(getWorkingDirectory() .. "\\config\\chatlog\\" .. os.date("!*t").day .. "-" .. os.date("!*t").month .. "-" .. os.date("!*t").year .. ".txt")
        return file  
    end
end

function imgui.OnDrawFrame()
    if not chat_log_custom.v then 
        imgui.Process = false
        text_ru = {}
        read_file = false
    end 

    if chat_log_custom.v then  
        imgui.LockPlayer = true
        imgui.ShowCursor = true

        imgui.SetNextWindowSize(imgui.ImVec2(600, 350), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw / 4.5), sh / 4), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"Чат-логгер", chat_log_custom)
        if update_files == false then 
            imgui.Combo(u8'Выбор файла', combo_select, logs_file)
        else  
            imgui.Text(u8"Обновление списка...")
        end    
        imgui.Text(u8"Выбранным файлом является:")
        imgui.SameLine()
        for key,v in pairs(logs_file) do
            if combo_select.v == key-1 then   
                name_log_select = v .. ".txt"
                imgui.Text(name_log_select)
            end 
        end        
        if imgui.Button(u8"Прочитать") then  
            sampAddChatMessage(tag .. "Начинается чтение файла....", -1)
            chat_logger_text = readChatlog_select()
            readRussian()
            read_file = true
        end        
        imgui.SameLine()
        if imgui.Button(u8"Почистить") then  
            sampAddChatMessage(tag .. " Текст чат-логгера очищен.", -1)
            text_ru = {}
            read_file = false
        end    
        imgui.SameLine()
        if imgui.Button(u8"Удалить файл") then  
            sampShowDialog(65, "{FFC900}[Chat-Logger]", "Вы уверены в удалении файла: " .. name_log_select .. "?", "Удалить", "Отмена")
        end    
        imgui.SameLine()
        if imgui.Button(u8"Обновить список файлов") then  
            lua_thread.create(function()
                update_files = true
                sampAddChatMessage(tag .. " Список файлов обновлен", -1)
                wait(500)
                logs_file = {}
                scan_logs_file()
                wait(1000)
                update_files = false
            end)
        end    
        imgui.SameLine()
        if imgui.Button("Settings") then  
            imgui.OpenPopup('settings')
        end
        if imgui.BeginPopup('settings') then  
            if imgui.Checkbox(u8'Очистка файлов', elements.clearFiles) then  
                configLog.settings.clearFiles = elements.clearFiles.v  
                if inicfg.save(configLog, directIni) then  
                    sampfuncsLog(tag .. " Сохранение настроек")
                end
            end 
            if imgui.SliderInt(u8'Кол-во дней', elements.days_for_clear, 1, 10) then  
                configLog.settings.days_for_clear = elements.days_for_clear.v  
                if inicfg.save(configLog, directIni) then  
                    sampfuncsLog(tag .. " Сохранение настроек")
                end
            end 
            imgui.EndPopup()
        end
        imgui.Separator()
        if read_file == true then  
            imgui.InputText(u8"Поиск по файлу", chat_find)
            if chat_find.v == "" then  
                imgui.Text(u8"Введите текст для поиска \n")
                imgui.Separator()
                for key,v in pairs(text_ru) do 
                    imgui.Text(v)
                    if imgui.IsItemClicked() then
                        imgui.LogToClipboard()
                        imgui.LogText(v) -- копирование текста
                        imgui.LogFinish()
                    end
                end 
            else 
                for key,v in pairs(text_ru) do 
                    if v:find(chat_find.v, 1, true) ~= nil then  
                        imgui.Text(v)
                        if imgui.IsItemClicked() then
                            imgui.LogToClipboard()
                            imgui.LogText(v) -- копирование текста
                            imgui.LogFinish()
                        end
                    end 
                end 
            end
        end    
        imgui.End()
    end    

end 
