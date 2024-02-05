require 'lib.moonloader'
local inicfg = require 'inicfg' -- ������ � ���������
local sampev = require "lib.samp.events" -- ����������� �������� ���������, ��������� � ������� ������� ������� SA:MP, � �� ������ ���������� � LUA
local atlibs = require 'libsfor' -- ���������� ��� ������ � ��
local encoding = require 'encoding' -- ������ � �����������
local imgui = require 'imgui' -- MoonImGUI || ���������������� ���������
local notf_res, notf = pcall(import, 'lib/imgui_notf.lua')  -- ������ �����������

local fa = require 'faicons' -- ������ � �������� Font Awesome 4

-- ## ���� ��������� ���������� ## --
local tag = "{00BFFF} [AT] {FFFFFF}" -- ��� AT
local log = "{00BFFF} [AdminTool-Log] {FFFFFF}" -- ��� ���� ��
local ntag = "{00BFFF} Notf - AdminTool" -- ��� ����������� ��
encoding.default = 'CP1251' -- ����� ��������� �� CP1251
u8 = encoding.UTF8 -- ������������ ������������� ������ ��������� UTF8 - u8
-- ## ���� ��������� ���������� ## --

-- ## ����� ��� ������ ## --
function imgui.BeforeDrawFrame()
    if fa_font == nil then
		local font_config = imgui.ImFontConfig()
		font_config.MergeMode = true 
		fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fontawesome-webfont.ttf', 14.0, font_config, fa_glyph_ranges)
	end	
end
-- ## ����� ��� ������ ## --

-- ## ����������� ����������� ## --
function showNotification(text)
	notf.addNotify(ntag, text, 2, 1, 6)
end
-- ## ����������� ����������� ## --

-- ## ���� ��� ������ � �������� � ��� ����������� ## --
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
-- ## ���� ��� ������ � �������� � ��� ����������� ## --

-- ## ������ � ���������� ������� ImGUI (���������� ��� ����������� ��������) ## --
imgui.ToggleButton = require('imgui_addons').ToggleButton
-- ## ������ � ���������� ������� ImGUI (���������� ��� ����������� ��������) ## --

-- ## ���� ����������, ���������� �� ������ �������� � ���������� ���� ## --
local onscene_mat = { 
    "�����", "����", "���", "�����" 
} 
local onscene_osk = { 
    "����", "���", "������", "�����" 
}
local onscene_upom = {
    "�������", "russian roleplay", "evolve", "������"
}
local onscene_rod = { 
    "���� ����", "mq", "���� � ������", "���� ���� �����", "���� ��� �����", "mqq", "mmq", 'mmqq', "matb v kanave",
}
local control_onscene_mat = false -- ��������������� ����� �������� "����������� �������"
local control_onscene_osk = false -- ��������������� ����� �������� "�����������/��������"
local control_onscene_upom = false -- ��������������� ����� �������� "���������� ����.��������"
local control_onscene_rod = false -- ��������������� ����� �������� "����������� ������"

-- ## �������, ����������� ��������� ������������ ����� � ������ ����������� ���������� ## -- 
function checkMessage(msg, arg) -- ��� ���������� �������������� ����� ������� mainstream (�� 1 �� 4); ��� 1 - ���, 2 - ���, 3 - ����.����.��������, 4 - ��� ���
    if msg ~= nil then -- ��������, ���������� �� ��������� � ������� ��� ������������ ������
        if arg == 1 then -- MainStream Automute-Report For "����������� �������"  
            for i, ph in ipairs(onscene_mat) do -- ������� ������� ������ � ������������ �������� �������, ���������� � ����
                nmsg = atlibs.string_split(msg, " ") -- �������� ��������� �� ������ �� ������
                for j, word in ipairs(nmsg) do -- ���� �������� �� ������ ������ �������
                    if ph == atlibs.string_rlower(word) then  -- ���� ����������� ����� ���� ������ �������, ��
                        return true, ph -- ������� True � ����������� �����
                    end  
                end  
            end  
        elseif arg == 2 then -- MainStream Automute-Report For "�����������/��������" 
            for i, ph in ipairs(onscene_osk) do -- ������� ������� ������ � ������������ �������� �������, ���������� � ����
                nmsg = atlibs.string_split(msg, " ") -- �������� ��������� �� ������ �� ������
                for j, word in ipairs(nmsg) do -- ���� �������� �� ������ ������ �������
                    if ph == atlibs.string_rlower(word) then  -- ���� ����������� ����� ���� ������ �������, ��
                        return true, ph -- ������� True � ����������� �����
                    end  
                end  
            end
        elseif arg == 3 then -- MainStream Automute-Report For "���������� ��������� ��������"  
            for i, ph in ipairs(onscene_upom) do -- ������ � ������������ �������� ������� �� �����
                if string.find(msg, ph, 1, true) then -- ����� ������� �� ������. ������ ����������� ������ �����? ������ ������ �� �����������, ������ ��� � ������ ���� 
                    return true, ph -- ���������� True � ����������� �����
                end 
            end
        elseif arg == 4 then -- MainStream Automute-Report For "����������� ������" 
            for i, ph in ipairs(onscene_rod) do -- ������ � ������������ �������� ������� �� �����
                if string.find(msg, ph, 1, true) then -- ����� ������� �� ������. ������ ����������� ������ �����? ������ ������ �� �����������, ������ ��� � ������ ���� 
                    return true, ph -- ���������� True � ����������� �����
                end 
            end 
        end  
    end
end 
-- ## ���� ����������, ���������� �� ������ �������� � ���������� ���� ## --

function sampev.onServerMessage(color, text)

    local check_nick, check_id, basic_color, check_text = string.match(text, "(.+)%((.+)%): {(.+)}(.+)") -- ������ �������� ������� ���� � �������� � �� �������

    -- ## �������, ��� mainframe - ������� ## --
    if not isGamePaused() and not isPauseMenuActive() and isGameWindowForeground() then  
        if text:find("������ (.+) | {AFAFAF}(.+)%[(%d+)%]: (.+)") then  
            local number_report, nick_rep, id_rep, text_rep = text:match("������ (.+) | {AFAFAF}(.+)%[(%d+)%]: (.+)") 
            sampAddChatMessage(tag .. "������ ������ " .. number_report .. " �� " .. nick_rep .. "[" .. id_rep .. "]: " .. text_rep, -1)
            if elements.settings.automute_mat.v or elements.settings.automute_osk.v or elements.settings.automute_rod.v or elements.settings.automute_rod.v then  
                local mat_text, _ = checkMessage(text_rep, 1)
                local osk_text, _ = checkMessage(text_rep, 2)
                local upom_text, _ = checkMessage(text_rep, 3)
                local rod_text, _ = checkMessage(text_rep, 4)
                if mat_text and elements.settings.automute_mat.v then  
                    sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                    sampAddChatMessage(tag .. " | ��� ID[" .. id_rep .. "] �� rep: " .. text_rep, -1)
                    sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                    sampSendChat("/rmute " .. id_rep .. " 300 ����������� �������")
                    showNotification("����������: " .. nick_rep .. "[" .. id_rep .. "] \n ������� �� '���'. \n ��� �����: " .. text_rep)
                end
                if osk_text and elements.settings.automute_osk.v then  
                    sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                    sampAddChatMessage(tag .. " | ��� ID[" .. id_rep .. "] �� rep: " .. text_rep, -1)
                    sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                    sampSendChat("/rmute " .. id_rep .. " 400 ���/����.")
                    showNotification("����������: " .. nick_rep .. "[" .. id_rep .. "] \n ������� �� '�����������/��������'. \n ��� �����: " .. text_rep)
                end
                if upom_text and elements.settings.automute_upom.v then  
                    sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                    sampAddChatMessage(tag .. " | ��� ID[" .. id_rep .. "] �� rep: " .. text_rep, -1)
                    sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                    sampSendChat("/rmute " .. id_rep .. " 1000 ����.����.��������")
                    showNotification("����������: " .. nick_rep .. "[" .. id_rep .. "] \n ������� �� '����.����.��������'. \n ��� �����: " .. text_rep)
                end
                if rod_text and elements.settings.automute_rod.v then  
                    sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                    sampAddChatMessage(tag .. " | ��� ID[" .. id_rep .. "] �� rep: " .. text_rep, -1)
                    sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                    sampSendChat("/rmute " .. id_rep .. " 5000 ���/����. ������")
                    showNotification("����������: " .. nick_rep .. "[" .. id_rep .. "] \n ������� �� '�����������/�������� ������'. \n ��� �����: " .. text_rep)
                end
            end  
            return true
        end
    end
    -- ## �������, ��� mainframe - ������� ## --

    -- ## �������, ��� mainframe - ��� ## --
    if not isGamePaused() and not isPauseMenuActive() and isGameWindowForeground() then  
        if check_text ~= nil and check_id ~= nil and (elements.settings.automute_mat.v or elements.settings.automute_osk.v or elements.settings.automute_upom.v or elements.settings.automute_rod.v) then  
            local mat_text, _ = checkMessage(check_text, 1)
            local osk_text, _ = checkMessage(check_text, 2)
            local upom_text, _ = checkMessage(check_text, 3)
            local rod_text, _ = checkMessage(check_text, 4)
            if mat_text and elements.settings.automute_mat.v then  
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                sampAddChatMessage(tag .. " | ��� ID[" .. check_id .. "] �� msg: " .. check_text, -1)
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                sampSendChat("/mute " .. check_id .. " 300 ����������� �������")
                showNotification("����������: " .. check_nick .. "[" .. check_id .. "] \n ������� �� '���'. \n ��� �����: " .. check_text)
            end
            if osk_text and elements.settings.automute_osk.v then  
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                sampAddChatMessage(tag .. " | ��� ID[" .. check_id .. "] �� msg: " .. check_text, -1)
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                sampSendChat("/mute " .. check_id .. " 400 ���/����.")
                showNotification("����������: " .. check_nick .. "[" .. check_id .. "] \n ������� �� '�����������/��������'. \n ��� �����: " .. check_text)
            end
            if upom_text and elements.settings.automute_upom.v then  
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                sampAddChatMessage(tag .. " | ��� ID[" .. check_id .. "] �� msg: " .. check_text, -1)
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                sampSendChat("/mute " .. check_id .. " 1000 ����.����.��������")
                showNotification("����������: " .. check_nick .. "[" .. check_id .. "] \n ������� �� '����.����.��������'. \n ��� �����: " .. check_text)
            end
            if rod_text and elements.settings.automute_rod.v then  
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                sampAddChatMessage(tag .. " | ��� ID[" .. check_id .. "] �� msg: " .. check_text, -1)
                sampAddChatMessage(tag .. " ======================= | [AT] Automute-Stream | ================== ")
                sampSendChat("/mute " .. check_id .. " 5000 ���/����. ������")
                showNotification("����������: " .. check_nick .. "[" .. check_id .. "] \n ������� �� '�����������/�������� ������'. \n ��� �����: " .. check_text)
            end
            return true
        end
    end 

    -- ## �������, ��� mainframe - ��� ## --
end

function main()
    while not isSampAvailable() do wait(0) end
    
    -- ## ���� �������� �� ���������� ������ ������ � ������� ����� ## --
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
    -- ## ���� �������� �� ���������� ������ ������ � ������� ����� ## --

    -- ## ���� �������������� ������� ��� ������ � ��������� (���� ����� ����/�������� ����) ## --
    
    sampRegisterChatCommand("s_rod", save_rod)
    sampRegisterChatCommand("d_rod", delete_rod)

    sampRegisterChatCommand("s_upom", save_upom)
    sampRegisterChatCommand("d_upom", delete_upom)

    sampRegisterChatCommand("s_osk", save_osk)
    sampRegisterChatCommand("d_osk", delete_osk)

    sampRegisterChatCommand("s_mat", save_mat)
    sampRegisterChatCommand("d_mat", delete_mat)

    -- ## ���� �������������� ������� ��� ������ � ��������� (���� ����� ����/�������� ����) ## --

    while true do
        wait(0)
        
    end
end

-- ## ���� �������, ���������� �� ��������� � ����� �������� �������. ����������� � �������� ## --
function save_rod(param)
    if param == nil then  
        return false  
    end 
    for _, val in ipairs(onscene_rod) do  
        if atlibs.string_rlower(param) == val then  
            sampAddChatMessage(tag .. " ����� \"" .. val .. "\" ��� ������������ � ������ ���� ����������� ������.")
            return false  
        end    
    end  
    local file_write, file_line = io.open(directoryAM.."\\rod.txt", 'w'), 1
    onscene_rod[#onscene_rod + 1] = atlibs.string_rlower(param)
    for _, val in ipairs(onscene_rod) do  
        file_write:write(val .. "\n")
    end  
    file_write:close() 
    sampAddChatMessage(tag .. " ����� \"" .. atlibs.string_rlower(param) .. "\" ������� ��������� � ������ ���� ����������� ������")
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
        sampAddChatMessage(tag .. " ����� \"" .. atlibs.string_rlower(param) .. "\" ���� ������� ������� �� ������ ���� ����������� ������")
        control_onscene_rod = false
    else
        sampAddChatMessage(tag .. " ����� \"" .. atlibs.string_rlower(param) .. "\" ��� � ������ ���� ����������� ������")
    end
end

function save_upom(param)
    if param == nil then  
        return false 
    end 
    for _, val in ipairs(onscene_upom) do 
        if atlibs.string_rlower(param) == val then  
            sampAddChatMessage(tag .. " ����� \"" .. val .. "\" ��� ������������ � ������ ���� ���������� ��������� ��������.")
            return false 
        end 
    end 
    local file_read, file_line = io.open(directoryAM.. "\\upom.txt", "w"), 1
    onscene_upom[#onscene_upom + 1] = atlibs.string_rlower(param)
    for _, val in ipairs(onscene_upom) do 
        file_read:write(val .. "\n")
    end 
    file_read:close() 
    sampAddChatMessage(tag .. " ����� \"" .. atlibs.string_rlower(param) .. "\" ������� ��������� � ������ ���� ���������� ��������� ��������.")
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
        sampAddChatMessage(tag .. " ����� \"" .. atlibs.string_rlower(param) .. "\" ���� ������� ������� �� ������ ���� ���������� ��������� ��������.")
        control_onscene_upom = false
    else
        sampAddChatMessage(tag .. " ����� \"" .. atlibs.string_rlower(param) .. "\" ��� � ������ ���� ���������� ��������� ��������.")
    end
end

function save_osk(param)
    if param == nil then
        return false
    end
    for _, val in ipairs(onscene_osk) do
        if atlibs.string_rlower(param) == val then
            sampAddChatMessage(tag .. " ����� \"" .. val .. "\" ��� ������������ � ������ �����������/��������.")
            return false
        end
    end
    local file_write, file_line = io.open(directoryAM.. "\\osk.txt", "w"), 1
    onscene_osk[#onscene_osk + 1] = atlibs.string_rlower(param)
    for _, val in ipairs(onscene_osk) do
        file_write:write(val .. "\n")
    end
    file_write:close()
    sampAddChatMessage(tag .. " ����� \"" .. atlibs.string_rlower(param) .. "\" ������� ��������� � ������ �����������/��������.")
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
        sampAddChatMessage(tag .. " ����� \"" .. atlibs.string_rlower(param) .. "\" ���� ������� ������� �� ������ �����������/��������.")
        control_onscene_osk = false
    else
        sampAddChatMessage(tag .. " ����� \"" .. atlibs.string_rlower(param) .. "\" ��� � ������ �����������/��������.")
    end
end

function save_mat(param)
    if param == nil then
        return false
    end
    for _, val in ipairs(onscene_mat) do
        if atlibs.string_rlower(param) == val then
            sampAddChatMessage(tag .. " ����� \"" .. val .. "\" ��� ������������ � ������ ����������� �����.")
            return false
        end
    end
    local file_write, file_line = io.open(directoryAM.. "\\mat.txt", "w"), 1
    onscene_mat[#onscene_mat + 1] = atlibs.string_rlower(param)
    for _, val in ipairs(onscene_mat) do
        file_write:write(val .. "\n")
    end
    file_write:close()
    sampAddChatMessage(tag .. " ����� \"" .. atlibs.string_rlower(param) .. "\" ������� ��������� � ������ ����������� �������.")
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
        sampAddChatMessage(tag .. " ����� \"" .. atlibs.string_rlower(param) .. "\" ���� ������� ������� �� ������ ����������� �����.")
        control_onscene_mat = false
    else
        sampAddChatMessage(tag .. " ����� \"" .. atlibs.string_rlower(param) .. "\" ��� � ������ ������������.")
    end
end
-- ## ���� �������, ���������� �� ��������� � ����� �������� �������. ����������� � �������� ## --

-- ## ���� �������-�������� ��� ���������� �� � �������� ������ ## --
function EXPORTS.ActiveAutoMute()
    if imgui.Button(fa.ICON_NEWSPAPER_O .. u8" �������") then  
        imgui.OpenPopup('SettingsAutoMute')
    end 
    if imgui.BeginPopup('SettingsAutoMute') then  
        if imgui.ToggleButton(u8'������� �� ���', elements.settings.automute_mat) then  
            config.settings.automute_mat = elements.settings.automute_mat.v  
            save()  
        end
        if imgui.ToggleButton(u8'������� �� ���', elements.settings.automute_osk) then  
            config.settings.automute_osk = elements.settings.automute_osk.v  
            save() 
        end  
        if imgui.ToggleButton(u8'������� �� ����.����.��������', elements.settings.automute_upom) then  
            config.settings.automute_upom = elements.settings.automute_upom.v  
            save()  
        end  
        if imgui.ToggleButton(u8'������� �� ��� ������', elements.settings.automute_rod) then  
            config.settings.automute_rod = elements.settings.automute_rod.v  
            save()  
        end
        imgui.EndPopup()
    end
end
-- ## ���� �������-�������� ��� ���������� �� � �������� ������ ## --