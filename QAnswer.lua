script_name('AdminTool-Reports')
script_description('����� ������ AdminTool. �������� �������� ������� �� �������.')
script_author('alfantasyz')

-- ## ����������� ���������, �������� � ������� ## --
require 'lib.moonloader'
require 'resource.commands' -- �������������� ������� � ���������.
local inicfg = require 'inicfg' -- ������ � INI �������
local sampev = require 'lib.samp.events' -- ������ � �������� � �������� SAMP
local encoding = require 'encoding' -- ������ � ����������
local atlibs = require 'libsfor' -- ���������� ��� ������ � ��
local imgui = require 'imgui' -- MoonImGUI || ���������������� ���������
local notf_res, notf = pcall(import, 'lib/imgui_notf.lua')  -- ������ �����������

local fai = require "fAwesome5" -- ������ � �������� Font Awesome 5
local fa = require 'faicons' -- ������ � �������� Font Awesome 4
-- ## ����������� ���������, �������� � ������� ## --

-- ## ����������� ����������� ## --
function showNotification(text)
	notf.addNotify(ntag, text, 2, 1, 6)
end
-- ## ����������� ����������� ## --

-- ## ���� ��������� ���������� ## --
local tag = "{00BFFF} [AT] {FFFFFF}" -- ��� AT
local log = "{00BFFF} [AdminTool-Log] {FFFFFF}" -- ��� ���� ��
local ntag = "{00BFFF} Notf - AdminTool" -- ��� ����������� ��
encoding.default = 'CP1251' -- ����� ��������� �� CP1251
u8 = encoding.UTF8 -- ������������ ������������� ������ ��������� UTF8 - u8
-- ## ���� ��������� ���������� ## --

-- ## ���� ���������� ��������� � ��������� � ���������� �������������� � ����������� ������� ## --

local ATMainConfig = inicfg.load({
    main = {
        styleImGUI = 0,
    },
    keys = {
        OpenReport = "None",
    },
}, "AdminTool\\settings.ini")

local directIni = "AdminTool\\settings_reports.ini"

local config = inicfg.load({
    main = {
		interface = true,
        prefix_answer = false, 
        prefix_for_answer = " // �������� ���� �� ������� RDS <3",
    },
    bind_name = {},
    bind_text = {},
    bind_delay = {},
}, directIni)
inicfg.save(config, directIni)

local elements = {
	interface = imgui.ImBool(config.main.interface),
    text = imgui.ImBuffer(4096),
    prefix_answer = imgui.ImBool(config.main.prefix_answer),
    prefix_for_answer = imgui.ImBuffer(256),
    binder_name = imgui.ImBuffer(256),
    binder_text = imgui.ImBuffer(65536),
    binder_delay = imgui.ImBuffer(2500),
    select_menu = 0,
    select_category = 0,
}

-- ## ���� ���������� ��������� � ��������� � ���������� �������������� � ����������� ������� ## --

-- ## ���� ���������� ��������� � MoonImGUI ## --
local sw, sh = getScreenResolution()
local ATReportShow = imgui.ImBool(false)
local sender = false

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

imgui.ToClipboard = require('imgui_addons').ToClipboard
imgui.Tooltip = require('imgui_addons').Tooltip
-- ## ���� ���������� ��������� � MoonImGUI ## --

-- ## ���� � �������� ## --
local questions = {
    ["reporton"] = {
		[u8"����� �����"] = "������ ����� ������� ����.",
        [u8"������ ������ �� ������"] = "�����(�) ������ �� ����� ������!",
		[u8"��� ��������"] = "��������� �����, ������ ������ ���!",
		[u8"��� ����� ���� � �������"] = "������ ���������� ��������� � ���������.",
		[u8"������ �� ������"] = "������ ������ �� �������������� �� ����� https://forumrds.ru",
		[u8"������ �� ������"] = "�� ������ �������� ������ �� ������ �� ����� https://forumrds.ru",
        [u8"������ �� ���-����"] = "�� ������ �������� ������ �� ����� https://forumrds.ru",
		[u8"������� ���"] = "������� ���",
		[u8"��������"] = "��������",
		[u8"��������� �������������������"] = "��������� ������������������� �� Russian Drift Server!",
		[u8"����� ������ �� ������"] = "�� ���� ��������� �� ������� ������",
		[u8"����� ����"] = " ������ ����� ����",
		[u8"����� �� � ����"] = "������ ����� �� � ����",
		[u8"��������� ������/������"] = "�������� ���� ������/������",
		[u8"��������� ID"] = "�������� ID ����������/������ � /report",
		[u8"����� �������"] = "������ ����� �������",
		[u8"��������"] = "��������",
		[u8"�� �� ��������"] = "GodMode (������) �� ������� �� ��������",
		[u8"��� ������"] = "� ������ ������ ����� � ������������� �� ��������.",
		[u8"������ ����� ���������"] = "������ ����� ��� ���������.",
		[u8"��� ����� ���������"] = "������ ��� ����� ����� ���������.",
		[u8"������ ����� ����������"] = "������ ������ ����� ����� ����������.",
		[u8"�����������"] = "������ ����, ��������� �����.",
        [u8"���������"] = "���������",
		[u8"�����"] = "�����",
		[u8"��"] = "��",
		[u8"���"] = "���",
		[u8"�� ���������"] = "�� ���������",
		[u8"�� �����"] = "�� �����",
		[u8"������ ���������"] = "�� ���������",
		[u8"�� ������"] = "�� ������",
		[u8"��� ���"] = "������ ����� - ��� ���",
		[u8"�����������"] = "���������� ���������"

    },
	["HelpHouses"] = {
		[u8"��� �������� ������ � ������"] = "/hpanel -> ����1-3 -> �������� -> ������ ���� -> ��������� ������",
		[u8"� ����� ��� �������"] = "/hpanel -> ����1-3 -> �������� -> ������� ��� ����������� || /sellmyhouse (������)",
		[u8"��� ������ ���"] = "�������� �� ����� (�������, �� �������) � ������� F.",
        [u8"��� ������� ���� ����"] = "/hpanel"
	},
	["HelpCmd"] = {
		[u8"������� VIP`�"] = "������ ���������� ����� ����� � /help -> 7 �����",
        [u8"���������� � �����"] = "������ ���������� ����� ������ � ���������",
		[u8"���������� Premuim"] = "������ ����� � ����������� Premuim VIP (/help -> 7)",
		[u8"���������� Diamond"] = "������ ����� � ����������� Diamond VIP (/help -> 7) ",
		[u8"���������� Platinum"] = "������ ����� � ����������� Platinum VIP (/help -> 7)",
		[u8"���������� ������"] = "������ ����� � ����������� ������� VIP (/help -> 7)",
		[u8"������� ��� �������"] = "������ ���������� ����� ����� � /help -> 8 �����",
        [u8"��� ���������� ������"] = "������ ���������� ����� ����� � /help -> 14 �����",
		[u8"��� �������� �������"] = "������� �����, ��� �� /help -> 18 �����"
	},
	["HelpGangFamilyMafia"] = {
		[u8"��� ������� ���� �����"] = "/menu (/mm) - ALT/Y -> ������� ����",
		[u8"��� ������� ���� �����"] = "/fpanel ",
		[u8"��� ��������� ������"] = "/guninvite (�����) || /funinvite (�����)",
		[u8"��� ���������� ������"] = "/ginvite (�����) || /finvite (�����)",
		[u8"��� �������� �����/�����"] = "/gleave (�����) || /fleave (�����)",
        [u8"��� ������ ����"] = "/grank IDPlayer ����",
		[u8"��� �������� �����"] = "/leave",
		[u8"��� ������ �������"] = "/gvig // ������ ���� �������",
	},
	["HelpTP"] = {
		[u8"��� �� � ���������"] = "tp -> ������ -> ����������",
		[u8"��� �� � ��������������"] = "/tp -> ������ -> ���������� -> ��������������",
		[u8"��� �� � ����"] = "/bank || /tp -> ������ -> ����",
		[u8"��� ���� ��"] = "/tp (�� ��������), /g (/goto) id (� ������) � VIP (/help -> 7 �����)",
        [u8"��� �� �� ������"] = "/tp -> ������"
	},
	["HelpSellBuy"] = {
		[u8"��� ������� ����"] = "������� ���������� ��� ������ ����� �� /trade. ����� �������, ������� F ����� �����",
		[u8"��� �������� ������"] = "����� �������� ������, ������� /trade, � ��������� � NPC ������, ����� ������",
		[u8"� ��� ������� �����"] = "/sellmycar IDPlayer ����1-5 ����� || /car -> ����1-5 -> ������� �����������",
        [u8"� ��� ������� ������"] = "/biz > ������� ������ �����������",
		[u8"��� �������� ������"] = "/givemoney IDPlayer money",
		[u8"��� �������� ����"] = "/givescore IDPlayer score",
		[u8"��� �������� �����"] = "/giverub IDPlayer rub | � ������� VIP (/help -> 7)",
		[u8"��� �������� �����"] = "/givecoin IDPlayer coin | � ������� VIP (/help -> 7)",
        [u8"��� ���������� ������"] = "������ ���������� ����� ����� � /help -> 14 �����",
	},
	["HelpBuz"] = {
		[u8"���� ������"] = "������� /cpanel ", 
		[u8"������� ������"] = "/biz > ������� ������ �����������",
		[u8"���� ����������"] = "������� /biz ",
		[u8"���� �����"] = "������� /clubpanel ",
		[u8"���������� ���������"] = "������� /help -> 9",
	},
	["HelpDefault"] = {
		[u8"IP RDS 01"] = "46.174.52.246:7777",
		[u8"IP RDS 02"] = "46.174.49.170:7777",
		[u8"���� � ������� HTML"] = "https://colorscheme.ru/html-colors.html",
		[u8"���� � ������� HTML 2"] = "https://htmlcolorcodes.com",
		[u8"��� ��������� ����"] = "���� � ���� HTML {RRGGBB}. ������� - 008000. ����� {} � ������ ���� ����� ������ {008000}�������",
		[u8"������ �� ���.������"] = "https://vk.com/dmdriftgta | ������ �������",
        [u8"������ �� �����"] = "https://forumrds.ru | ����� �������",
        [u8"��� �������� ���/������"] = "�������� ������/��� ����� � ������� /bank ��� /tp -> ������ -> ����",
		[u8"��� ����� ��������� ������"] = "����������� ������� /car",
		[u8"��� �������� ����"] = '������ �� ����� "���������� �����", ����� ����� ����� �������� �� ALT � ����� �� ������� ������ �� �����',
		[u8"��� �������� ������"] = "������ ���������� �� ���� �����. ����� ������������ �� /garage",
		[u8"��� ������ ����"] = "��� ����, ����� ������ ����, ����� ������ /capture",
		[u8"��� ������ ���/����"] = "/passive ",
		[u8"/statpl"] = "����� ���������� ������, ����, �����, �����, ����� - /statpl",
		[u8"����� ������"] = "/mm -> �������� -> ������� ������",
		[u8"����� �����"] = "/mm -> ������������ �������� -> ��� ����������",
        [u8"��� ����� ������"] = "/menu (/mm) - ALT/Y -> ������",
		[u8"��� ����� ��������"] = "/menu (/mm) - ALT/Y -> ��������",
        [u8"��� ������� ����"] = "/mm (/mn) || Alt/Y",
		[u8"��� ������ �����"] = "/menu (/mm) - ALT/Y -> �/� -> ������",
		[u8"���� ����� �������"] = "/kill | /tp | /spawn",
		[u8"��� ������� �� �����/����"] = "/join | ���� ������������� �������, ������� �� �����",
		[u8"����������� ���"] = "/dt 0-990 / ����������� ���",
        [u8"�������� ������/�������"] = "/quests | /dquest | /bquest",
		[u8"�������� � �������"] = "�������� � �������."
	},
	["HelpSkins"] = {
		[u8"���� �� �������"] = " https://gtaxmods.com/skins-id.html.",
		[u8"����"] = "65-267, 280-286, 288, 300-304, 306, 307, 309-311",
		[u8"�������"] = "102-104",
		[u8"����"] = "105-107",
		[u8"�����"] = "117-118, 120",
		[u8"������"] = "108-110",
		[u8"��.�����"] = "111-113",
		[u8"�������"] = "114-116",
		[u8"�����"] = "124-127"
	},
	["HelpSettings"] = {
		[u8"�����/������ �������"] = "/menu (ALT/Y) -> ��������� -> 1 �����.",
		[u8"���������� �������� �� �����"] = "/menu (ALT/Y) -> ��������� -> 2 �����.",
		[u8"On/Off ������ ���������"] = "/menu (ALT/Y) -> ��������� -> 3 �����.",
		[u8"������� �� ��������"] = "/menu (ALT/Y) -> ��������� -> 4 �����.",
		[u8"���������� ���������� DM Stats"] = "/menu (ALT/Y) -> ��������� -> 5 �����.",
		[u8"������ ��� ������������"] = "/menu (ALT/Y) -> ��������� -> 6 �����.",
		[u8"���������� ���������"] = "/menu (ALT/Y) -> ��������� -> 7 �����.",
		[u8"���������� Drift Lvl"] = "/menu (ALT/Y) -> ��������� -> 8 �����.",
		[u8"����� � ����/���� �����"] = "/menu (ALT/Y) -> ��������� -> 9 �����.",
		[u8"����� �������� ����"] = "/menu (ALT/Y) -> ��������� -> 10 �����.",
		[u8"On/Off ����������� � �����"] = "/menu (ALT/Y) -> ��������� -> 11 �����.",
		[u8"����� �� �� TextDraw"] = "/menu (ALT/Y) -> ��������� -> 12 �����.",
		[u8"On/Off ����"] = "/menu -> ��������� (ALT/Y) -> 13 �����.",
		[u8"On/Off FPS ����������"] = "/menu (ALT/Y) -> ��������� -> 15 �����.",
		[u8"On/Off �����������"] = "/menu (ALT/Y) -> ��������� -> 16 �����",
		[u8"On/Off �����.�����"] = "/menu (ALT/Y) -> ��������� -> 17 �����",
		[u8"On/Off ����.�����"] = "/menu (ALT/Y) -> ��������� -> 18 �����",
		[u8"On/Off ���.������ ��� �����"] = "/menu (ALT/Y) -> ��������� -> 19 �����",
		[u8"������ ��.����"] = "/menu (ALT/Y) -> ��������� -> 20 �����",
	}
}
-- ## ���� � �������� ## --

function main()
    while not isSampAvailable() do wait(0) end
    
    sampfuncsLog(log .. " ������������� ������� ������� �� �������. \n  �������, ��������� ����������� ���������, ���� �������� ������!")

	-- ## ������ �� ������� ��� ���� (/ans id text || /ot id text) ## --
	for key in pairs(cmd_helper_answers) do  
		sampRegisterChatCommand(key, function(arg)
			if #arg > 0 then  
				sampSendChat("/ans " .. arg .. cmd_helper_answers[key].reason .. ' // �������� ���� �� ������� RDS. <3 ')
			else 
				sampAddChatMessage(tag .. '�� �� ����� ID ������', -1)
			end
		end)
	end
	-- ## ������ �� ������� ��� ���� (/ans id text || /ot id text) ## --

    while true do
        wait(0)

        imgui.Process = true

        if atlibs.isKeysDown(atlibs.strToIdKeys(ATMainConfig.keys.OpenReport)) and not sampIsDialogActive() and not sampIsChatInputActive() then  
			lua_thread.create(function()
				sampSendChat("/ans ")
				sampSendDialogResponse(2348, 1, 0)
				wait(50)
			end)
		end

		lua_thread.create(function()
			if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/yx' then
				sampSetCurrentDialogEditboxText('{FFFFFF}�����(�) ������ �� ����� ������! ' .. color() .. ' �������� ���� �� ������� RDS. <3 ')
				wait(2000)
				if tonumber(id_punish) ~= nil then 
					sampSendChat("/re " .. id_punish)
				else 	
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/re " )
				end	
			end
		end)

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/bx' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ����� ����. ' .. color() .. ' �������� ���� �� ������� RDS. <3 ')
		end

		lua_thread.create(function()
			if sampGetCurrentDialogEditboxText() == '.��' then
				sampSetCurrentDialogEditboxText('{FFFFFF}����� �� ������ �������, ��������. :3 ')
				wait(2000)
				if tonumber(id_punish) ~= nil then 
					sampSendChat("/re " .. id_punish)
				else 	
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/re " )
				end	
			end
		end)

		if sampGetCurrentDialogEditboxText() == '/gvk' then 
			local string = string.sub(sampGetCurrentDialogEditboxText(), 0, string.len(sampGetCurrentDialogEditboxText()) - 1)
			sampSetCurrentDialogEditboxText(string .. color() .. "https://vk.com/dmdriftgta")
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/;lf' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}��. ' .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/;yt' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}���. ' .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/yr' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}�����. ' .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}��������. ' .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/hku' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}���������� ���������. '  .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/ydl' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}�� ������. ' .. color() .. ' | �������� �������������������� ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/jaa' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}�� ���������. ' .. color() .. ' | �������� ��������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/ytp' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}�� �����.' .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/,fu' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ����� - ��� ���. ' .. color() .. ' | �������� ������������������� ')
		end
		
		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/j;' then
			sampSetCurrentDialogEditboxText('{FFFFFF}��������. '  .. color() ..  ' ��������� ������������������� �� RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/;,f' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ������ �� �������������� �� ����� https://forumrds.ru')
		end

		if sampGetCurrentDialogEditboxText() == '.���'or sampGetCurrentDialogEditboxText() == '/;,b'  then
			sampSetCurrentDialogEditboxText('{FFFFFF}�� ������ �������� ������ �� ������ �� ����� https://forumrds.ru')
		end

		if string.find(sampGetChatInputText(), "%-��") then
			sampSetChatInputText(string.gsub(sampGetChatInputText(), "-��", "| �������� ���� �� RDS <3"))
		end

		if string.find(sampGetChatInputText(), "%/vrm") then
			sampSetChatInputText(string.gsub(sampGetChatInputText(), "/vrm", "��������� ������������������� �� Russian Drift Server!"))
		end
		
		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/yfr' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ����� �������. | '  .. color() ..  '  �������� ���� �� RDS! <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/yy' then
			sampSetCurrentDialogEditboxText('{FFFFFF}�� ���� ��������� �� ������. | ' .. color() .. ' �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/yd' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ����� �� � ����. | ' .. color() .. ' �������� ���� �� RDS. <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/gd' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������� ���. | ' .. color() .. ' ������� ���� �� RDS <3')
		end

		if string.find(sampGetChatInputText(), "%/gvk") then
			sampSetChatInputText(string.gsub(sampGetChatInputText(), "/gvk", "https://vk.com/dmdriftgta"))
		end
        
    end
end

-- ## ���� ��������� ������� � ������� SA:MP ## -- 
function sampev.onServerMessage(color, text)
	if elements.interface.v then
		if text:find("������������� ��� ��������� ������ ������") then  
			sampAddChatMessage(tag .. " �����-�� ������������� ��� ��������� ������. ���� ��������� �������, �� ��������� :(")
			ATReportShow.v = false
			imgui.Process = ATReportShow.v 
			return false
		end
	end
end

function sampev.onShowDialog(id, style, title, button1, button2, text)
	if elements.interface.v then 
		if id == 2349 then  
			if text:match("�����: {......}(%S+)") and text:match("������:\n{......}(.*)\n\n{......}") then
				nick_rep = text:match("�����: {......}(%S+)")
				text_rep = text:match("������:\n{......}(.*)\n\n{......}")	
				pid_rep = atlibs.playernickname(nick_rep)
				if pid_rep == nil then  
					pid_rep = "None"
				end
				rep_text = u8:encode(text_rep)
				id_punish = rep_text:match("(%d+)")
			end
			if not ATReportShow.v then 
				ATReportShow.v = true  
				imgui.Process = true 
			end
			return false
		else 
			ATReportShow.v = false  
			imgui.Process = false  
			imgui.ShowCursor = false
		end
		if id == 2350 then  
			return false  
		end  
		if id == 2351 then  
			return false 
		end
	end
end
-- ## ���� ��������� ������� � ������� SA:MP ## -- 

function color() -- �������, ����������� ������������� � ����� ���������� ����� � ������� ������������ os.time()
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

    if not ATReportShow.v then  
        imgui.Process = false  
        imgui.ShowCursor = false  
    end

    if ATReportShow.v and elements.interface.v then  
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5)) 
        imgui.SetNextWindowSize(imgui.ImVec2(430, 250), imgui.Cond.FirstUseEver)

        imgui.ShowCursor = true

        imgui.Begin("##ReportShow", ATReportShow, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.MenuBar)

        imgui.BeginMenuBar()        
            imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
            imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 10) 
            if imgui.Button(fai.ICON_FA_BELL, imgui.ImVec2(27,0)) then  
                elements.select_menu = 0
            end; imgui.Tooltip(u8"���� � ��������")
            imgui.Spacing()
            imgui.Text(u8("     ����� �������: " .. u8:decode(rep_text)))
            imgui.PopStyleVar(1)
            imgui.PopStyleVar(1)
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
			if elements.select_menu == 1 or elements.select_menu == 2 then  
				if imgui.Button(fai.ICON_FA_ARROW_LEFT .. '##BackButton', imgui.ImVec2(27,0)) then
					elements.select_menu = 0
				end
			end
        imgui.EndMenuBar()

        if elements.select_menu == 0 then
			imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign , imgui.ImVec2(0.5, 0.5))
            if (nick_rep and pid_rep and rep_text) then  
				imgui.Text(u8"������ ��: "); imgui.SameLine()
                imgui.Text(nick_rep); imgui.ToClipboard(nick_rep); imgui.SameLine();
				imgui.Text("[" .. pid_rep .. "]"); imgui.ToClipboard(pid_rep)
                imgui.Separator()
                imgui.Text(u8(u8:decode(rep_text)))
                imgui.Separator()
            elseif (nick_rep == nil or pid_rep == nil or rep_text == nil or text_rep == nil) then
                imgui.Text(u8"������ �� ����������.")
            end	
			imgui.PushItemWidth(310)
            imgui.InputText('##�����', elements.text) 
			imgui.PopItemWidth()
            imgui.SameLine()
            if imgui.Button(fa.ICON_REFRESH .. ("##RefreshText//RemoveText")) then  
                elements.text.v = ""
            end; imgui.Tooltip(u8"���������/������� ���������� ���������� ���� �����.")
            if #elements.text.v > 0 then  
                imgui.SameLine()
                if imgui.Button(fa.ICON_FA_SAVE .. "##SaveReport") then  
                    imgui.OpenPopup('Binder')
                end  
            end; imgui.Tooltip(u8"��������� ���������� ������. \n� ���� ����� ���������� �������������.")
            imgui.SameLine()
            if imgui.Button(fa.ICON_FA_TEXT_HEIGHT .. ("##SendColor")) then  
                elements.text.v = color()
			end; imgui.Tooltip(u8"������ ��������� ���� ����� �������.")
			imgui.SameLine()
			if imgui.Checkbox(u8"##PrefixAnswer", elements.prefix_answer) then 
				config.main.prefix_answer = elements.prefix_answer.v
				inicfg.save(config, directIni)
			end; imgui.Tooltip(u8"������������� ��� ������ ����������� ��������� �� ������������������� ������.\n���������������� ����� � ���������� ��.\n/tool (F3) -> ��������� (������ '����������')")
            imgui.Separator()
            if imgui.Button(fa.ICON_FA_EYE .. u8" ������ �� ��", imgui.ImVec2(135,20)) then  
				lua_thread.create(function()
					sampSendDialogResponse(2349, 1, 0)
					wait(50)
					sampSendDialogResponse(2350, 1, 0)
					wait(50)
					if elements.prefix_answer.v then  
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} �����(�) ������ �� ����� ������! ' .. u8:decode(config.main.prefix_for_answer))	
					else 
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} �����(�) ������ �� ����� ������! ')	
					end
					wait(50)
					sampCloseCurrentDialogWithButton(13)
					ATReportShow.v = false  
					imgui.ShowCursor = false
					wait(50)
					if tonumber(id_punish) ~= nil and id_punish ~= nil then 
						sampSendChat("/re " .. id_punish)
					end	
				end)
			end	
			imgui.SameLine()
            if imgui.Button(fa.ICON_BAN .. u8" �������", imgui.ImVec2(135,20)) then
				lua_thread.create(function() 
					sampSendDialogResponse(2349, 1, 0)
					wait(50)
					sampSendDialogResponse(2350, 1, 0)
					wait(50)
					if elements.prefix_answer.v then  
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} ������ ����� �������! ' .. u8:decode(config.main.prefix_for_answer))	
					else 
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} ������ ����� �������! ')	
					end
					wait(50)
					sampCloseCurrentDialogWithButton(13)
					ATReportShow.v = false  
					imgui.ShowCursor = false
				end)
			end
			imgui.SameLine()
			if imgui.Button(fa.ICON_COMMENTING_O .. u8" �������� ID", imgui.ImVec2(135,20)) then  
				lua_thread.create(function()
					sampSendDialogResponse(2349, 1, 0)
					wait(50)
					sampSendDialogResponse(2350, 1, 0)
					wait(50)
					if elements.prefix_answer.v then  
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} �������� ID ����������/������ � /report ' .. u8:decode(config.main.prefix_for_answer))	
					else 
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} �������� ID ����������/������ � /report ')	
					end
					wait(50)
					sampCloseCurrentDialogWithButton(13)
					ATReportShow.v = false  
					imgui.ShowCursor = false
				end)
			end	
			if imgui.Button(fa.ICON_FA_EDIT .. u8" �������� ��", imgui.ImVec2(135,20)) then  
				lua_thread.create(function()
					sampSendDialogResponse(2349, 1, 0)
					wait(50)
					sampSendDialogResponse(2350, 1, 0)
					wait(50)
					if elements.prefix_answer.v then  
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} �������� ���� ������/������ ' .. u8:decode(config.main.prefix_for_answer))	
					else 
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} �������� ���� ������/������ ')	
					end
					wait(50)
					sampCloseCurrentDialogWithButton(13)
					ATReportShow.v = false  
					imgui.ShowCursor = false
				end)
			end	
			imgui.SameLine()
			if imgui.Button(fai.ICON_FA_SHARE .. u8" �� �� ������", imgui.ImVec2(135,20)) then
				lua_thread.create(function()
					sampSendDialogResponse(2349, 1, 0)
					wait(50)
					sampSendDialogResponse(2350, 1, 0)
					wait(50)
					if elements.prefix_answer.v then
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} ������ ������ �� �������������� �� ����� https://forumrds.ru '.. u8:decode(config.main.prefix_for_answer))
					else
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} ������ ������ �� �������������� �� ����� https://forumrds.ru ')
					end
					wait(50)
					sampCloseCurrentDialogWithButton(13)
					ATReportShow.v = false
					imgui.ShowCursor = false
				end)
			end
			imgui.SameLine()
			if imgui.Button(fai.ICON_FA_SHARE .. u8" �� �� ������", imgui.ImVec2(135,20)) then
				lua_thread.create(function()
					sampSendDialogResponse(2349, 1, 0)
					wait(50)
					sampSendDialogResponse(2350, 1, 0)
					wait(50)
					if elements.prefix_answer.v then
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} ������ ������ �� ������ �� ����� https://forumrds.ru '.. u8:decode(config.main.prefix_for_answer))
					else
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} ������ ������ �� ������ �� ����� https://forumrds.ru ')
					end
					wait(50)
					sampCloseCurrentDialogWithButton(13)
					ATReportShow.v = false
					imgui.ShowCursor = false
				end) 
			end
			if imgui.Button(fai.ICON_FA_INFO_CIRCLE .. u8' ��� �� �������', imgui.ImVec2(135,20)) then
				lua_thread.create(function()
					sampSendDialogResponse(2349, 1, 0)
					wait(50)
					sampSendDialogResponse(2350, 1, 0)
					wait(50)
					if elements.prefix_answer.v then
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} �������� � ���.������ �� ������ https://forumrds.ru '.. u8:decode(config.main.prefix_for_answer))
					else
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} �������� � ���.������ �� ������ https://forumrds.ru')
					end
					wait(50)
					sampCloseCurrentDialogWithButton(13)
					ATReportShow.v = false
					imgui.ShowCursor = false
				end)
			end
			imgui.SameLine()
			if imgui.Button(fai.ICON_FA_TOGGLE_OFF .. u8' �� � ����', imgui.ImVec2(135,20)) then
				lua_thread.create(function()
					sampSendDialogResponse(2349, 1, 0)
					wait(50)
					sampSendDialogResponse(2350, 1, 0)
					wait(50)
					if elements.prefix_answer.v then
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} ����� �� � ����. '.. u8:decode(config.main.prefix_for_answer))
					else
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} ����� �� � ����. ')
					end
					wait(50)
					sampCloseCurrentDialogWithButton(13)
					ATReportShow.v = false
					imgui.ShowCursor = false
				end)
			end
			imgui.SameLine()
			if imgui.Button(fai.ICON_FA_CLOCK .. u8' ����/��� �����.', imgui.ImVec2(135,20)) then  
				lua_thread.create(function()
					sampSendDialogResponse(2349, 1, 0)
					wait(50)
					sampSendDialogResponse(2350, 1, 0)
					wait(50)
					if elements.prefix_answer.v then
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} �� ���� ��������� �� ������� ������. '.. u8:decode(config.main.prefix_for_answer))
					else
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} �� ���� ��������� �� ������� ������. ')
					end
					wait(50)
					sampCloseCurrentDialogWithButton(13)
					ATReportShow.v = false
					imgui.ShowCursor = false
				end)
			end
			imgui.Separator()
            if imgui.Button(fai.ICON_FA_QUESTION_CIRCLE .. u8" ������ �� AT", imgui.ImVec2(135,20)) then 
                elements.select_menu = 1
            end
            imgui.SameLine()
			if imgui.Button(fa.ICON_FA_SAVE .. u8" ����. ������", imgui.ImVec2(135,20)) then  
				elements.select_menu = 2
			end	
			imgui.SameLine()
			if imgui.Button(fa.ICON_CHECK .. u8" �������� �� ##SEND", imgui.ImVec2(135,20)) then  
				lua_thread.create(function()
					sampSendDialogResponse(2349, 1, 0)
					wait(50)
					sampSendDialogResponse(2350, 1, 0)
					wait(50)
					if elements.prefix_answer.v then  
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} ������� ��� ������! '.. u8:decode(config.main.prefix_for_answer))	
					else 
						sampSendDialogResponse(2351, 1, 0, '{FFFFFF} ������� ��� ������! ')	
					end
					wait(50)
					sampCloseCurrentDialogWithButton(13)
					sampSendChat("/a " .. nick_rep .. "[" .. pid_rep .. "] | " .. text_rep)
                    ATReportShow.v = false  
					imgui.ShowCursor = false
				end)	
			end
			-- imgui.Text(u8'����� ������:' .. (#elements.text.v))
            elements.prefix_for_answer.v = config.main.prefix_for_answer
            -- if imgui.InputText(u8'���� ��������', elements.prefix_for_answer) then  
            --     config.main.prefix_for_answer = elements.prefix_for_answer.v
            --     inicfg.save(config, directIni)
            -- end
            imgui.Separator()
            if imgui.Button(fai.ICON_FA_SMS .. u8" ��������", imgui.ImVec2(110,20)) then
				if #elements.text.v < 70 then 
					lua_thread.create(function()
						sampSendDialogResponse(2349, 1, 0)
						wait(50)
						sampSendDialogResponse(2350, 1, 0)
						wait(50)
						if elements.prefix_answer.v then 
							local settext = '{FFFFFF}' .. elements.text.v .. ' ' .. color() .. config.main.prefix_for_answer
							sampSendDialogResponse(2351, 1, 0, u8:decode(settext))	
						else 
							local settext = '{FFFFFF}' .. elements.text.v
							sampSendDialogResponse(2351, 1, 0, u8:decode(settext))	
						end
						wait(50)
						sampCloseCurrentDialogWithButton(13)
						wait(50)
						elements.text.v = " "
					end)
					ATReportShow.v = false
				else 
					if (#elements.text.v + #config.main.prefix_for_answer) > 110 then 
						sampAddChatMessage(tag .. ' ����� ������ ������ ��������� �����������. �������� �����. ���� ������� ��������� ��� ������', -1)
					end
				end
            end  
            imgui.SameLine()
            if imgui.Button(fa.ICON_BAN .. u8" ���������", imgui.ImVec2(110,20)) then  
                lua_thread.create(function()
                    sampSendDialogResponse(2349, 1, 0)
                    wait(50)
                    sampSendDialogResponse(2350, 1, 1)
                    wait(50)
                    sampSendDialogResponse(2351, 0, 0)
                    ATReportShow.v = false
                    imgui.Process = ATReportShow.v 
                    imgui.ShowCursor = ATReportShow.v
                end)
            end
            imgui.SameLine()
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 115)
            if imgui.Button(fa.ICON_WINDOW_CLOSE .. u8" �������", imgui.ImVec2(110,20)) then  
                lua_thread.create(function()
                    sampSendDialogResponse(2349, 0, 0)
                    wait(50)
                    sampSendDialogResponse(2348, 0, 0)
                    ATReportShow.v = false
                    imgui.Process = ATReportShow.v 
                    imgui.ShowCursor = ATReportShow.v
                end)
            end
			imgui.PopStyleVar(1)
            
            if imgui.BeginPopupModal(u8'Binder', false, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
                imgui.BeginChild("##EditBinder", imgui.ImVec2(600, 210), true)
                imgui.Text(u8'�������� �����:'); imgui.SameLine()
                imgui.PushItemWidth(130)
                imgui.InputText("##elements.binder_name", elements.binder_name)
                imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 100)
                if imgui.Button(u8'�������##bind1', imgui.ImVec2(100,30)) then
                    elements.binder_name.v = ''
                    imgui.CloseCurrentPopup()
                end
                imgui.SameLine()
                if #elements.binder_name.v > 0 then
                    imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 1.01)
                    if imgui.Button(u8'���������##bind1', imgui.ImVec2(100,30)) then
                        if not EditOldBind then
                            local refresh_text = elements.text.v:gsub("\n", "~")
                            table.insert(config.bind_name, elements.binder_name.v)
                            table.insert(config.bind_text, refresh_text)
                            if inicfg.save(config, directIni) then
                                sampAddChatMessage(tag .. '����"' ..u8:decode(elements.binder_name.v).. '" ������� ������!', -1)
                                elements.binder_name.v, elements.text.v = '', ''
                            end
                                imgui.CloseCurrentPopup()
                            else
                                local refresh_text = elements.text.v:gsub("\n", "~")
                                table.insert(config.bind_name, getpos, elements.binder_name.v)
                                table.insert(config.bind_text, getpos, refresh_text)
                                table.remove(config.bind_name, getpos + 1)
                                table.remove(config.bind_text, getpos + 1)
                            if inicfg.save(config, directIni) then
                                sampAddChatMessage(tag .. '����"' ..u8:decode(elements.binder_name.v).. '" ������� ��������������!', -1)
                                elements.binder_name.v, elements.text.v = '', ''
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

        if elements.select_menu == 1 then  
            imgui.BeginChild("##menuSecond", imgui.ImVec2(155, 215), true)
			if imgui.Button(fa.ICON_OBJECT_GROUP .. u8" �� ����-��/���-��", imgui.ImVec2(130, 0)) then  -- reporton key
				elements.select_category = 1  
			end; imgui.Tooltip(u8'������� ������ �� ������� ������ (������, ��� ������ ������� ������� �� ��������� ������ �������)')
			if imgui.Button(fa.ICON_LIST .. u8" ������� (/help)", imgui.ImVec2(130, 0)) then  -- HelpCMD key
				elements.select_category = 2 
			end; imgui.Tooltip(u8'������ �� �������� ������ /help')
			if imgui.Button(fa.ICON_USERS .. u8" �����/�����", imgui.ImVec2(130, 0)) then  -- HelpGangFamilyMafia key
				elements.select_category = 3
			end; imgui.Tooltip(u8'������ �� �������� �����������')
			if imgui.Button(fa.ICON_MAP_MARKER .. u8" ���������", imgui.ImVec2(130, 0)) then  -- HelpTP key
				elements.select_category = 4
			end; imgui.Tooltip(u8'������ �� �������� ������������.')
			if imgui.Button(fa.ICON_SHOPPING_BAG .. u8" �������", imgui.ImVec2(130, 0)) then  -- HelpBuz key
				elements.select_category = 5 
			end; imgui.Tooltip(u8'������ �� �������� ��������.')
			if imgui.Button(fa.ICON_MONEY .. u8" �������/�������", imgui.ImVec2(130, 0)) then  -- HelpSellBuy key
				elements.select_category = 6 
			end; imgui.Tooltip(u8'������ �� �������� �������/������� ������.')
			if imgui.Button(fa.ICON_BOLT .. u8" ���������", imgui.ImVec2(130, 0)) then  -- HelpSettings key
				elements.select_category = 7
			end; imgui.Tooltip(u8'������ �� �������� �������� (/settings)')
			if imgui.Button(fa.ICON_HOME .. u8" ����", imgui.ImVec2(130, 0)) then  -- HelpHouses key
				elements.select_category = 8 
			end; imgui.Tooltip(u8'������ �� �������� ������������ (���)')
			if imgui.Button(fa.ICON_MALE .. u8" �����", imgui.ImVec2(130, 0)) then  -- HelpSkins key
				elements.select_category = 9 
			end; imgui.Tooltip(u8'������ �� �������� ������.')
			if imgui.Button(fa.ICON_BARCODE .. u8" ��������� ������", imgui.ImVec2(130, 0)) then  -- HelpDefault key
				elements.select_category = 10
			end; imgui.Tooltip(u8'������ �� ��������, ������� �� ������ �� � ���� ���������')
			imgui.EndChild()
			imgui.SameLine()
			imgui.BeginChild("##menuSelectable", imgui.ImVec2(235, 215), true)
			if elements.select_category == 0 then  
				imgui.TextWrapped(u8"������ ������ �������� ������ �������������.")
			end	
			if elements.select_category == 1 then  
				for key, v in pairs(questions) do
					if key == "reporton" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
								if not elements.prefix_answer.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								elements.select_category = 0
								elements.select_menu = 0 
							end
						end
					end
				end
			end	
			if elements.select_category == 2 then 
				for key, v in pairs(questions) do
					if key == "HelpCmd" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
								if not elements.prefix_answer.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								report_ans = 0
							end
						end
					end
				end
			end	
			if elements.select_category == 3 then  
				for key, v in pairs(questions) do
					if key == "HelpGangFamilyMafia" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
								if not elements.prefix_answer.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								report_ans = 0
							end
						end
					end
				end
			end	
			if elements.select_category == 4 then  
				for key, v in pairs(questions) do
					if key == "HelpTP" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
								if not elements.prefix_answer.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								report_ans = 0
							end
						end
					end
				end
			end	
			if elements.select_category == 6 then  
				for key, v in pairs(questions) do
					if key == "HelpSellBuy" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
								if not elements.prefix_answer.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								report_ans = 0
							end
						end
					end
				end
			end	
			if elements.select_category == 10 then  
				for key, v in pairs(questions) do
					if key == "HelpDefault" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
								if not elements.prefix_answer.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								report_ans = 0
							end
						end
					end
				end
			end	
			if elements.select_category == 9 then  
				for key, v in pairs(questions) do
					if key == "HelpSkins" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
								if not elements.prefix_answer.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								report_ans = 0
							 end
						 end
					end
				end
			end	
			if elements.select_category == 7 then  
				for key, v in pairs(questions) do
					if key == "HelpSettings" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
								if not elements.prefix_answer.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								report_ans = 0
							end
						end
					end
				end
			end	
			if elements.select_category == 8 then  
				for key, v in pairs(questions) do
					if key == "HelpHouses" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
								if not elements.prefix_answer.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								report_ans = 0
							end
						end
					end
				end
			end	
			if elements.select_category == 5 then  
				for key, v in pairs(questions) do
					if key == "HelpBuz" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
								if not elements.prefix_answer.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. ' ' .. color() .. u8:decode(config.main.prefix_for_answer)
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(50)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(50)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								report_ans = 0
							end
						end
					end
				end
			end	
			imgui.EndChild()
        end

        if elements.select_menu == 2 then   
            if #config.bind_name > 0 then  
				for key_bind, name_bind in pairs(config.bind_name) do  
					if imgui.Button(name_bind.. '##'..key_bind) then  
                        elements.select_menu = 0
						SendBind_Report(key_bind)
					end	
				end	
			else 
				imgui.Text(u8"�����!")
				if imgui.Button(u8"�������!") then  
					imgui.OpenPopup(u8'������')	 
				end	
			end	
			if imgui.BeginPopupModal(u8'������', false, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
				imgui.BeginChild("##EditBinder", imgui.ImVec2(600, 225), true)
				imgui.Text(u8'�������� �����:'); imgui.SameLine()
				imgui.PushItemWidth(130)
				imgui.InputText("##elements.binder_name", elements.binder_name)
				imgui.PopItemWidth()
				imgui.PushItemWidth(100)
				imgui.Separator()
				imgui.Text(u8'����� �����:')
				imgui.PushItemWidth(300)
				imgui.InputTextMultiline("##elements.binder_text", elements.binder_text, imgui.ImVec2(-1, 110))
				imgui.PopItemWidth()
	
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 100)
				if imgui.Button(u8'�������##bind1', imgui.ImVec2(100,30)) then
					elements.binder_name.v, elements.binder_text.v, elements.binder_delay.v = '', '', "2500"
					imgui.CloseCurrentPopup()
				end
				imgui.SameLine()
				if #elements.binder_name.v > 0 and #elements.binder_text.v > 0 then
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 1.01)
					if imgui.Button(u8'���������##bind1', imgui.ImVec2(100,30)) then
						if not EditOldBind then
							local refresh_text = elements.binder_text.v:gsub("\n", "~")
							table.insert(config.bind_name, elements.binder_name.v)
							table.insert(config.bind_text, refresh_text)
							table.insert(config.bind_delay, elements.binder_delay.v)
							if inicfg.save(config, directIni) then
								sampAddChatMessage(tag .. '����"' ..u8:decode(elements.binder_name.v).. '" ������� ������!', -1)
								elements.binder_name.v, elements.binder_text.v, elements.binder_delay.v = '', '', "2500"
							end
								imgui.CloseCurrentPopup()
							else
								local refresh_text = elements.binder_text.v:gsub("\n", "~")
								table.insert(config.bind_name, getpos, elements.binder_name.v)
								table.insert(config.bind_text, getpos, refresh_text)
								table.insert(config.bind_delay, getpos, elements.binder_delay.v)
								table.remove(config.bind_name, getpos + 1)
								table.remove(config.bind_text, getpos + 1)
								table.remove(config.bind_delay, getpos + 1)
							if inicfg.save(config, directIni) then
								sampAddChatMessage(tag .. '����"' ..u8:decode(elements.binder_name.v).. '" ������� ��������������!', -1)
								elements.binder_name.v, elements.binder_text.v, elements.binder_delay.v = '', '', "2500"
							end
							EditOldBind = false
							imgui.CloseCurrentPopup()
						end
					end
	
				end
				imgui.EndChild()
				imgui.EndPopup()
			end
			imgui.Separator()
			if imgui.Button(fa.ICON_BACKWARD .. u8" �����") then  
				elements.select_menu = 0 
			end	
        end

        imgui.End()
    end
end

function SendBind_Report(num)
	lua_thread.create(function()
		if num ~= -1 then
			for bp in config.bind_text[num]:gmatch('[^~]+') do
				sampSendDialogResponse(2349, 1, 0)
				sampSendDialogResponse(2350, 1, 0)
				wait(50)
				sampSendDialogResponse(2351, 1, 0, u8:decode(tostring(bp)))
				wait(50)
				sampCloseCurrentDialogWithButton(13)
				-- sampAddChatMessage(u8:decode(tostring(bp)), -1)
			end
			num = -1
		end
	end)
end