script_name('AdminTool ExtraFunctions')
script_description('����������� ������, ����������� ������������� ��������� ������� ������ � �������� �������� ��')
script_author('alfantasyz')

-- ## ����������� ���������, �������� � ������� ## --
require 'lib.moonloader'
local flags_font = require("moonloader").font_flag -- ��������� ������ ��� ��������� �������
local imgui = require('imgui') -- ����������� ������������ ���������� ImGUI
local inicfg = require 'inicfg' -- ������ � ini
local sampev = require "lib.samp.events" -- ����������� �������� ���������, ��������� � ������� ������� ������� SA:MP, � �� ������ ���������� � LUA
local atlibs = require 'libsfor' -- ���������� ��� ������ � ��
local encoding = require 'encoding' -- ������ � �����������
local notf_res, notf = pcall(import, 'lib/imgui_notf.lua')  -- ������ �����������

local fai = require "fAwesome5" -- ������ � �������� Font Awesome 5
local fa = require 'faicons' -- ������ � �������� Font Awesome 4
-- ## ����������� ���������, �������� � ������� ## --

-- ## ���� ��������� ���������� ## --
local tag = "{00BFFF} [AT] {FFFFFF}" -- ��� AT
local log = "{00BFFF} [AdminTool-Log] {FFFFFF}" -- ��� ���� ��
local ntag = "{00BFFF} Notf - AdminTool" -- ��� ����������� ��
encoding.default = 'CP1251' -- ����� ��������� �� CP1251
u8 = encoding.UTF8 -- ������������ ������������� ������ ��������� UTF8 - u8
-- ## ���� ��������� ���������� ## --

-- ## ����������� ����������� ## --
function showNotification(text)
	notf.addNotify(ntag, text, 2, 1, 6)
end
-- ## ����������� ����������� ## --

-- ## ���� ���������� ��������� � ��������� � ���������� �������������� � ����������� ������� ## --
local directIni = "AdminTool\\extraplugin.ini"
local config = inicfg.load({
    settings = {
        adminforms = false,
        adminchat = false,
        auto_adminforms = false,
        imgui_adminchat = false, 
    },
    achat = {
        X = 48,
        Y = 298, 
        centered = 0,
        color = -1,
        nick = 1,
        lines = 10,
        Font = 10, 
		lines_imgui = 10,
		X_imgui = 50,
		Y_imgui = 298,
        iFont = 10,
    }
}, directIni)

function save() 
    inicfg.save(config, directIni)
end

local elements = {
    boolean = {
        adminchat = imgui.ImBool(config.settings.adminchat),
        adminforms = imgui.ImBool(config.settings.adminforms),
        auto_adminforms = imgui.ImBool(config.settings.auto_adminforms),
        imgui_adminchat = imgui.ImBool(config.settings.imgui_adminchat),
    },
    int = {
        adminFont = imgui.ImInt(config.achat.Font),
        imguiFont = imgui.ImInt(config.achat.iFont),
    },
}

local every_settings = {
    admin_chat = {
        centered = imgui.ImInt(0),
        nick = imgui.ImInt(1),
        color = -1,
        render_lines = imgui.ImInt(10),
        X = 0,
        Y = 0,
        lines_imgui = imgui.ImInt(10)
    },
    no_saved_ac = {
        chat_lines = { },
        pos = false,
        chat_lines_imgui = { },
        X = 0,
        Y = 0,
    },
}

function saveAC()
    config.achat.X = every_settings.admin_chat.X 
    config.achat.Y = every_settings.admin_chat.Y 
    config.achat.centered = every_settings.admin_chat.centered.v  
    config.achat.nick = every_settings.admin_chat.nick.v  
    config.achat.color = every_settings.admin_chat.color  
    config.achat.lines = every_settings.admin_chat.render_lines.v  
    config.achat.lines_imgui = every_settings.admin_chat.lines_imgui.v  
    save()
end

function loadAC()
    every_settings.admin_chat.X = config.achat.X  
    every_settings.admin_chat.Y = config.chat.Y
    every_settings.admin_chat.centered.v = config.achat.centered
    every_settings.admin_chat.nick.v = config.achat.nick
    every_settings.admin_chat.color = config.achat.color
    every_settings.admin_chat.render_lines.v = config.achat.lines
    every_settings.admin_chat.lines_imgui.v = config.achat.lines_imgui
    save()
end
-- ## ���� ���������� ��������� � ��������� � ���������� �������������� � ����������� ������� ## --

-- ## ���� ���������� ��������� � ����������� ����������� ImGUI ## -- 
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
local fai_glyph_ranges = imgui.ImGlyphRanges({ fai.min_range, fai.max_range })

local fontsize = nil

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
    if fontsize == nil then
        fontsize = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\SegoeUI.ttf', elements.int.imguiFont.v, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) 
    end
end

imgui.ToggleButton = require('imgui_addons').ToggleButton

local changePosition_im = false
-- ## ���� ���������� ��������� � ����������� ����������� ImGUI ## -- 

-- ## ��������� ��������� ���������� ## -- 
local font_ac = renderCreateFont("Arial",tonumber(elements.int.adminFont.v), flags_font.BOLD + flags_font.SHADOW)
-- ## ��������� ��������� ���������� ## -- 

-- ## ����������, ����������� ��� ���������� ������ �������, ���������� �� ������ ������ ��������� ��������� ## --
local lc_lvl, lc_adm, lc_color, lc_nick, lc_id, lc_text

local reasons = { 
	"/mute", "/jail", "/iban", "/ban", "/kick", "/skick", "/sban", "/muteakk", "/offban", "/banakk"
}
-- ## ����������, ����������� ��� ���������� ������ �������, ���������� �� ������ ������ ��������� ��������� ## --


function sampev.onServerMessage(color, text)

    lc_lvl, lc_adm, lc_color, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] %((.+){(.+)}%) (.+)%[(%d+)%]: {FFFFFF}(.+)")

    local check_string = string.match(text, "[^%s]+")

    -- ## ������ � ����������������� ������� ## --
    if not isGamePaused() and not isPauseMenuActive() and isGameWindowForeground() then
        if elements.boolean.adminforms.v and lc_text ~= nil then  
            for k, v in ipairs(reasons) do  
                if lc_text:match(v) ~= nil then  
                    if lc_text:find(lc_nick) then
                        form = lc_text 
                    else   
                        form = lc_text .. " // " .. lc_nick
                    end  
                    showNotification("������ ���������������� �����! \n ���� � ��� �������� �������������� �������� ����, �������������� �����������\n /fac - ������� | /fn - ���������")
                    sampAddChatMessage(tag .. "�����: " .. adm_form, -1)
                    if elements.boolean.auto_adminforms.v then
                        lua_thread.create(function()
                            sampSendChat("/a [AT] ����� �������.")
                            wait(5)
                            sampSendChat(adm_form)
                            adm_form = ''
                        end)
                    else
                        start_forms()
                    end  
                end  
            end
        end
    end

    function start_forms()
        sampRegisterChatCommand('fac', function()
            sampSendChat("/a [AT] ����� �������.")
            wait(5)
            sampSendChat(adm_form)
            adm_form = ''
        end)
        sampRegisterChatCommand('fn', function()
            sampSendChat('/a [AT] ����� ���������.')
            adm_form = ''
        end)
    end
    -- ## ������ � ����������������� ������� ## --

    -- ## ������ � ���������������� �����. ������ � �������� ��� ������� � ���������� AC (AdminChat) � ImGUI## -- 
    if (elements.boolean.adminchat.v or elements.boolean.imgui_adminchat.v) and check_string ~= nil and string.find(check_string, "%[A%-(%d+)%]") ~= nil and string.find(text, "%[A%-(%d+)%] (.+) ����������") == nil then
		local lc_text_chat
		if elements.boolean.adminchat.v then  
			if every_settings.admin_chat.nick.v == 1 then
				if lc_adm == nil then
					lc_lvl, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)")
					lc_text_chat = lc_lvl .. " � " .. lc_nick .. "[" .. lc_id .. "] : {FFFFFF}" .. lc_text
				else
					every_settings.admin_chat.color = color
					lc_text_chat = lc_adm .. "{" .. (bit.tohex(join_argb(atlibs.explode_argb(color)))):sub(3, 8) .. "} � " .. lc_lvl .. " � " .. lc_nick .. "[" .. lc_id .. "] : {FFFFFF}" .. lc_text 
				end
			else
				if lc_adm == nil then
					lc_lvl, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)")
					lc_text_chat = "{FFFFFF}" .. lc_text .. " {" .. (bit.tohex(join_argb(atlibs.explode_argb(color)))):sub(3, 8) .. "}: " .. lc_nick .. "[" .. lc_id .. "] � " .. lc_lvl
				else
					lc_text_chat = "{FFFFFF}" .. lc_text .. "{" .. (bit.tohex(join_argb(atlibs.explode_argb(color)))):sub(3, 8) .. "} : " .. lc_nick .. "[" .. lc_id .. "] � " .. lc_lvl .. " � " .. lc_adm
					every_settings.admin_chat.color = color
				end
			end
		end
		if elements.boolean.imgui_adminchat.v then  
			if every_settings.admin_chat.nick.v == 1 then
				if lc_adm == nil then
					lc_lvl, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)")
					lc_text_chat = "[A-" .. lc_lvl .. "] " .. lc_nick .. "[" .. lc_id .. "] : {FFFFFF}" .. lc_text
				else
					every_settings.admin_chat.color = color
					lc_text_chat = lc_adm .. "{" .. (bit.tohex(join_argb(atlibs.explode_argb(color)))):sub(3, 8) .. "} *  " .. lc_lvl .. " *  " .. lc_nick .. "[" .. lc_id .. "] : {FFFFFF}" .. lc_text 
				end
			else
				if lc_adm == nil then
					lc_lvl, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)")
					lc_text_chat = "{FFFFFF}" .. lc_text .. " {" .. (bit.tohex(join_argb(atlibs.explode_argb(color)))):sub(3, 8) .. "}: " .. lc_nick .. "[" .. lc_id .. "] *  " .. lc_lvl
				else
					lc_text_chat = "{FFFFFF}" .. lc_text .. "{" .. (bit.tohex(join_argb(atlibs.explode_argb(color)))):sub(3, 8) .. "} : " .. lc_nick .. "[" .. lc_id .. "] *  " .. lc_lvl .. " *  " .. lc_adm
					every_settings.admin_chat.color = color
				end
			end
		end	
		if elements.boolean.adminchat.v then 
			for i =  every_settings.admin_chat.render_lines.v, 1, -1 do
				if i ~= 1 then
					every_settings.no_saved_ac.chat_lines[i] = every_settings.no_saved_ac.chat_lines[i-1]
				else
					every_settings.no_saved_ac.chat_lines[i] = lc_text_chat
				end
			end
		end	
		if elements.boolean.imgui_adminchat.v then 
			for i = every_settings.admin_chat.lines_imgui.v, 1, -1 do
				if i ~= 1 then
					every_settings.no_saved_ac.chat_lines_imgui[i] = every_settings.no_saved_ac.chat_lines_imgui[i-1]
				else
					every_settings.no_saved_ac.chat_lines_imgui[i] = lc_text_chat
				end
			end 
		end		
		return false
	end		

end

function main()
    while not isSampAvailable() do wait(0) end
    
    admin_chat = lua_thread.create_suspended(drawAdminChat)

    sampfuncsLog(log .. " ������������� ��������������� �������, ������������ ������������ ��������������� �������, ���������� ������ � ��. \n ��� ���������� ���������� ������� ������� ��������� ��� ���������� � ������, � ����� moonloader -> module ->  plugins -> plugin.lua")

    -- ## ������ ��������� �������, ���������� ��� ������ ������������ ����� ## --
    admin_chat:run()
    -- ## ������ ��������� �������, ���������� ��� ������ ������������ ����� ## --


    while true do
        wait(0)

        imgui.Process = true

        if every_settings.no_saved_ac.pos then  
            CPosition_Render()
        end

        if not elements.boolean.imgui_adminchat.v then  
            imgui.Process = false 
            imgui.ShowCursor = false
        end

        CPosition_ImGUI()
    end
end

function showCursor(toggle)
    if toggle then
        sampSetCursorMode(CMODE_LOCKCAM)
    else
        sampToggleCursor(false)
    end
    cursorEnabled = toggle
end

function CPosition_Render()
    if isKeyJustPressed(VK_RBUTTON) then  
        every_settings.admin_chat.X = every_settings.no_saved_ac.X 
        every_settings.admin_chat.Y = every_settings.no_saved_ac.Y
        every_settings.no_saved_ac.pos = false 
    elseif isKeyJustPressed(VK_LBUTTON) then  
        every_settings.no_saved_ac.pos = false 
    else 
        every_settings.admin_chat.X, every_settings.admin_chat.Y = getCursorPos()
    end
end

function CPosition_ImGUI()
    if changePosition_im then  
        showCursor(true, false)
        local mouseX, mouseY = getCursorPos()
        config.achat.X_imgui, config.achat.Y_imgui = mouseX, mouseY  
        if isKeyJustPressed(49) then  
            showCursor(false, false)
            showNotification("��������� ���� AC ���������!")
            changePosition_im = false  
            save() 
        end  
    end
end

function drawAdminChat()
    while true do
		if elements.boolean.adminchat.v then
			if every_settings.admin_chat.centered.v == 0 then
				for i = every_settings.admin_chat.render_lines.v, 1, -1 do
					if every_settings.no_saved_ac.chat_lines[i] == nil then
						every_settings.no_saved_ac.chat_lines[i] = " "
					end
					renderFontDrawText(font_ac, every_settings.no_saved_ac.chat_lines[i], every_settings.admin_chat.X, every_settings.admin_chat.Y+(elements.int.adminFont.v+4)*(every_settings.admin_chat.render_lines.v - i), atlibs.join_argb(atlibs.explode_argb(every_settings.admin_chat.color)))
				end
			elseif admin_chat_lines.centered.v == 1 then
				for i = every_settings.admin_chat.render_lines.v, 1, -1 do
					if every_settings.no_saved_ac.chat_lines[i] == nil then
						every_settings.no_saved_ac.chat_lines[i] = " "
					end
					renderFontDrawText(font_ac, every_settings.no_saved_ac.chat_lines[i], every_settings.admin_chat.X - renderGetFontDrawTextLength(font_ac, every_settings.no_saved_ac.chat_lines[i]) / 2, every_settings.admin_chat.Y+elements.int.adminFont.v*(every_settings.admin_chat.render_lines.v - i)+5, atlibs.join_argb(atlibs.explode_argb(every_settings.admin_chat.color)))
				end
			elseif admin_chat_lines.centered.v == 2 then
				for i = every_settings.admin_chat.render_lines.v, 1, -1 do
					if every_settings.no_saved_ac.chat_lines[i] == nil then
						every_settings.no_saved_ac.chat_lines[i] = " "
					end
					renderFontDrawText(font_ac, every_settings.no_saved_ac.chat_lines[i], every_settings.admin_chat.X - renderGetFontDrawTextLength(font_ac, every_settings.no_saved_ac.chat_lines[i]), every_settings.admin_chat.Y+elements.int.adminFont.v*(every_settings.admin_chat.render_lines.v - i), atlibs.join_argb(atlibs.explode_argb(every_settings.admin_chat.color)))
				end
			end
		end
        wait(1)
    end
end

function imgui.OnDrawFrame()

    if elements.boolean.imgui_adminchat.v then  
        imgui.SetNextWindowPos(imgui.ImVec2(config.achat.X_imgui, config.achat.Y_imgui), imgui.Cond.FirsUseEver, imgui.ImVec2(0.5, 0.5))

        imgui.ShowCursor = false  

        imgui.Begin("##AdminChat", nil, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize)

            for i = every_settings.admin_chat.lines_imgui.v, 1, -1 do  
                if every_settings.no_saved_ac.chat_lines_imgui[i] ~= nil then  
                    imgui.PushFont(fontsize)
                        atlibs.imgui_TextColoredRGB(every_settings.no_saved_ac.chat_lines_imgui[i])
                    imgui.PopFont()
                end  
            end  
        imgui.End()
    end

end

function EXPORTS.ActiveATChat()
    if imgui.TreeNode(u8"�����-��� � ����������") then  
        imgui.Text(fai.ICON_FA_TOGGLE_ON .. u8" ��������� ������")
        imgui.SameLine()
        if imgui.ToggleButton('##AC_IMGUI', elements.boolean.imgui_adminchat) then  
            config.settings.imgui_adminchat = elements.boolean.imgui_adminchat.v  
            save()
        end
        if imgui.Button(u8"��������� ��������� ����") then  
            sampAddChatMessage(tag .. "��� ���������� ��������� - ������� �� ���������� <1>")
            changePosition_im = true
        end 
        imgui.Text(u8"���-�� �����: ")
        imgui.PushItemWidth(80)
        if imgui.InputInt('##changeLinesImGUI', every_settings.admin_chat.lines_imgui) then  
            config.achat.lines_imgui = every_settings.admin_chat.lines_imgui.v  
            save()  
        end  
        imgui.PopItemWidth()
        imgui.Text(u8"������ ������: ")
        imgui.PushItemWidth(80)
        if imgui.SliderInt('##changeFontSize', elements.int.imguiFont, 1, 32) then  
            config.achat.iFont = elements.int.imguiFont.v  
            save() 
        end
        if imgui.Button(fai.ICON_FA_SAVE .. u8' ���������') then   
            showNotification('��������� ���� ������� ���������.')
            saveAC()
            save() 
        end
        imgui.PopItemWidth()
        imgui.TreePop()
    end
    if imgui.TreeNode(u8"�����-��� � ����� ������ (������)") then  
        imgui.Text(fai.ICON_FA_TOGGLE_ON .. u8" ��������� ������")
        imgui.SameLine()
        if imgui.ToggleButton('##AC_IMGUI', elements.boolean.adminchat) then  
            config.settings.adminchat = elements.boolean.adminchat.v  
            save()
        end
        if imgui.Button(u8"��������� ����") then  
            every_settings.no_saved_ac.X = every_settings.admin_chat.X; every_settings.no_saved_ac.Y = every_settings.admin_chat.Y 
            every_settings.no_saved_ac.pos = true  
        end
        imgui.Text(u8'������������ ����: ')
        imgui.PushItemWidth(120)
        imgui.Combo("##Position", every_settings.admin_chat.centered, {u8"����� ����", u8"�����", u8"������ ����"})
        imgui.PopItemWidth()
        imgui.Text(u8"������ ������: ")
        imgui.PushItemWidth(50)
        if imgui.SliderInt("##SizeACFont", elements.int.adminFont, 1, 32) then  
            font_ac = renderCreateFont("Arial",tonumber(elements.int.adminFont.v), flags_font.BOLD + flags_font.SHADOW)
            config.achat.Font = elements.int.adminFont.v  
            save()
        end
        imgui.PopItemWidth()
        imgui.Text(u8"��������� ���� + ������")
        imgui.PushItemWidth(120)
        imgui.Combo("##PositionRender", every_settings.admin_chat.nick, {u8"������", u8"�����"})
        imgui.PopItemWidth()
        imgui.Text(u8"���-�� �����: ")
        imgui.PushItemWidth(80)
        imgui.InputInt('##NumbersStrings', every_settings.admin_chat.render_lines)
        imgui.PopItemWidth()
        if imgui.Button(fai.ICON_FA_SAVE .. u8" ���������") then  
            showNotification('��������� ���� ������� ���������.')
            saveAC()
        end
        imgui.TreePop()
    end
end