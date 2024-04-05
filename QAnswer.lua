script_name('AdminTool-Reports')
script_description('����� ������ AdminTool. �������� �������� ������� �� �������.')
script_author('alfantasyz')

-- ## ����������� ���������, �������� � ������� ## --
require 'lib.moonloader'
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
        prefix_answer = false, 
        prefix_for_answer = " // �������� ���� �� ������� RDS <3",
    },
    bind_name = {},
    bind_text = {},
    bind_delay = {},
}, directIni)
inicfg.save(config, directIni)

local elements = {
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
		[u8"IP RDS 02"] = "46.174.55.87:7777",
		[u8"IP RDS 03"] = "46.174.49.170:7777",
		[u8"IP RDS 04"] = "46.174.55.169:7777",
		[u8"IP RDS 05"] = "62.122.213.75:7777",
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
	sampRegisterChatCommand("tdd", cmd_tdd)
	sampRegisterChatCommand("gadm", cmd_gadm)
	sampRegisterChatCommand("enk", cmd_enk)
	sampRegisterChatCommand("gak", cmd_gak)
	sampRegisterChatCommand("ctun", cmd_ctun)
	sampRegisterChatCommand("gn", cmd_gn)
	sampRegisterChatCommand("pd", cmd_pd)
	sampRegisterChatCommand("dtl", cmd_dtl)
	sampRegisterChatCommand("nz", cmd_nz)
	sampRegisterChatCommand("yes", cmd_yes)
	sampRegisterChatCommand("net", cmd_net)
	sampRegisterChatCommand("nt", cmd_nt)
	sampRegisterChatCommand("fp", cmd_fp)
	sampRegisterChatCommand("mg", cmd_mg)
	sampRegisterChatCommand("pg", cmd_pg)
	sampRegisterChatCommand("krb", cmd_krb)
	sampRegisterChatCommand("kmd", cmd_kmd)
	sampRegisterChatCommand("gm", cmd_gm)
	sampRegisterChatCommand("plg", cmd_plg)
	sampRegisterChatCommand("vbg", cmd_vbg)
	sampRegisterChatCommand("en", cmd_en)
	sampRegisterChatCommand("of", cmd_of)
	sampRegisterChatCommand("nv", cmd_nv)
	sampRegisterChatCommand("bk", cmd_bk)
	sampRegisterChatCommand("h7", cmd_h7)
	sampRegisterChatCommand("h8", cmd_h8)
	sampRegisterChatCommand("h14", cmd_h14)
	sampRegisterChatCommand("zba", cmd_zba)
	sampRegisterChatCommand("zbp", cmd_zbp)
	sampRegisterChatCommand("int", cmd_int)
	sampRegisterChatCommand("og", cmd_og)
	sampRegisterChatCommand("dis", cmd_dis)
	sampRegisterChatCommand("avt", cmd_avt)
	sampRegisterChatCommand("avt1", cmd_avt1)
	sampRegisterChatCommand("pgf", cmd_pgf)
	sampRegisterChatCommand("igf", cmd_igf)
	sampRegisterChatCommand("msid", cmd_msid)
	sampRegisterChatCommand("al", cmd_al)
	sampRegisterChatCommand("c", cmd_c)
	sampRegisterChatCommand("cl", cmd_cl)
	sampRegisterChatCommand("yt", cmd_yt)
	sampRegisterChatCommand("n", cmd_n)
	sampRegisterChatCommand("nac", cmd_nac)
	sampRegisterChatCommand("hg", cmd_hg)
	sampRegisterChatCommand("tm", cmd_tm)
	sampRegisterChatCommand("cpt", cmd_cpt)
	sampRegisterChatCommand("psv", cmd_psv)
	sampRegisterChatCommand("drb", cmd_drb)
	sampRegisterChatCommand("prk", cmd_prk)
	sampRegisterChatCommand("zsk", cmd_zsk)
	sampRegisterChatCommand("vgf", cmd_vgf)
	sampRegisterChatCommand("stp", cmd_stp)
	sampRegisterChatCommand("rid", cmd_rid)
	sampRegisterChatCommand("gvs", cmd_gvs)
	sampRegisterChatCommand("gvm", cmd_gvm)
	sampRegisterChatCommand("msp", cmd_msp)
	sampRegisterChatCommand("chap", cmd_chap)
	sampRegisterChatCommand("lgf", cmd_lgf)
	sampRegisterChatCommand("trp", cmd_trp)
	sampRegisterChatCommand("cops", cmd_cops)
	sampRegisterChatCommand("bal", cmd_bal)
	sampRegisterChatCommand("cro", cmd_cro)
	sampRegisterChatCommand("vg", cmd_vg)
	sampRegisterChatCommand("rumf", cmd_rumf)
	sampRegisterChatCommand("var", cmd_var)
	sampRegisterChatCommand("triad", cmd_triad)
	sampRegisterChatCommand("mf", cmd_mf)
	sampRegisterChatCommand("smc", cmd_smc)
	sampRegisterChatCommand("html", cmd_html)
	sampRegisterChatCommand("ugf", cmd_ugf)
	sampRegisterChatCommand("vp1", cmd_vp1)
	sampRegisterChatCommand("vp2", cmd_vp2)
	sampRegisterChatCommand("vp3", cmd_vp3)
	sampRegisterChatCommand("vp4", cmd_vp4)
	sampRegisterChatCommand("ktp", cmd_ktp)
	sampRegisterChatCommand("tcm", cmd_tcm)
	sampRegisterChatCommand("gfi", cmd_gfi)
	sampRegisterChatCommand("hin", cmd_hin)
	sampRegisterChatCommand("smh", cmd_smh)
	sampRegisterChatCommand("cr", cmd_cr)
	sampRegisterChatCommand("hct", cmd_hct)
	sampRegisterChatCommand("gvr", cmd_gvr)
	sampRegisterChatCommand("gvc", cmd_gvc)
	sampRegisterChatCommand("ngm", cmd_ngm)
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

-- ## ���� ������� - ������� ������� � ���� ## --
function cmd_ngm(arg)
	sampSendChat("/ans " .. arg .. " ������ ����� ������� ����. // �������� ���� �� RDS <3")
end

function cmd_tcm(arg)
	sampSendChat("/ans " .. arg .. " ����� �������� ������, ������� /trade, � ��������� � NPC ������, ����� ������ ")
end 

function cmd_tm(arg)
	sampSendChat("/ans " .. arg .. " ��������. | ��������� ������������������� �� RDS <3 ")
end

function cmd_zsk(arg)
	sampSendChat("/ans " .. arg .. " ���� �� ��������, ������� /spawn | /kill, �� �� ����� ��� ������! ")
end

function cmd_vgf(arg)
	sampSendChat("/ans " .. arg .. " ����� ������ ������� ��������� �����, ���� �������: /gvig ")
end

function cmd_html(arg)
	sampSendChat("/ans ".. arg .. " https://colorscheme.ru/html-colors.html | �������� ����! ")
end

function cmd_ktp(arg)
	sampSendChat("/ans " .. arg .. " /tp (�� ��������), /g (/goto) id (� ������) � VIP (/help -> 7 �����) ")
end

function cmd_vp1(arg)
	sampSendChat("/ans " .. arg .. " ������ ����� � ����������� Premuim VIP (/help -> 7)  | �������� ����! <3 ")
end

function cmd_vp2(arg)
	sampSendChat("/ans " .. arg .. " ������ ����� � ����������� Diamond VIP (/help -> 7) | �������� ����! <3 ")
end

function cmd_vp3(arg)
	sampSendChat("/ans " .. arg .. " ������ ����� � ����������� Platinum VIP (/help -> 7) | �������� ����! <3 ")
end

function cmd_vp4(arg)
	sampSendChat("/ans " .. arg .. " ������ ����� � ����������� ������� VIP (/help -> 7) | �������� ����! <3 ")
end

function cmd_chap(arg)
	sampSendChat("/ans " .. arg .. " /mm -> �������� -> ������� ������ | �������� ����! <3 ")
end

function cmd_msp(arg)
	sampSendChat("/ans " .. arg .. " /mm -> ������������ �������� -> ��� ���������� | �������� ���� �� RDS. <3 ")
end

function cmd_trp(arg)
	sampSendChat("/ans " .. arg .. " /report | �������� ���� �� RDS. <3 ")
end

function cmd_rid(arg)
	sampSendChat("/ans " .. arg .. " �������� ID ����������/������ � /report | �������� �������������������. ")
end

function cmd_bk(arg)
	sampSendChat("/ans " .. arg .. " �������� ������/��� ����� � ������� /bank ��� /tp -> ������ -> ���� ")
end

function cmd_h7(arg)
	sampSendChat("/ans " .. arg .. " ���������� ���������� ����� � /help -> 7 �����. | �������� ���� �� RDS. <3 ")
end

function cmd_h8(arg)
	sampSendChat("/ans " .. arg .. " ������ ������ ���������� ����� � /help -> 8 �����. | �������� ���� �� RDS. <3 ")
end

function cmd_h14(arg)
	sampSendChat("/ans " .. arg .. " ������ ������ ���������� ����� � /help -> 14 �����. | �������� ���� �� RDS. <3 ")
end

function cmd_zba(arg)
	sampSendChat("/ans " .. arg .. " ����� ������� �� ���? ������ ������ �� ����� https://forumrds.ru")
end

function cmd_zbp(arg)
	sampSendChat("/ans " .. arg .. " ������ ������ �� ������ �� ����� https://forumrds.ru")
end

function cmd_avt(arg)
	sampSendChat("/ans " .. arg .. " /tp -> ������ -> ���������� | �������� ����!")
end

function cmd_avt1(arg)
	sampSendChat("/ans " .. arg .. " /tp -> ������ -> ���������� -> �������������� | �������� ����!")
end

function cmd_pgf(arg)
	sampSendChat("/ans " .. arg .. " /gleave (�����) || /fleave (�����)| �������� ���� �� RDS <3")
end

function cmd_lgf(arg)
	sampSendChat("/ans " .. arg .. " /leave (�������� �����) | �������� ���� �� RDS <3")
end

function cmd_igf(arg)
	sampSendChat("/ans " .. arg .. " /ginvite (�����) || /finvite (�����) | ������� ���� �� RDS <3" )
end

function cmd_ugf(arg)
	sampSendChat("/ans " .. arg .. " /guninvite (�����) || /funinvite (�����) | ������� ���� �� RDS <3 ")
end

function cmd_cops(arg)
	sampSendChat("/ans " .. arg .. " 265-267, 280-286, 288, 300-304, 306, 307, 309-311 | ������� ���� �� RDS <3")
end

function cmd_bal(arg)
	sampSendChat("/ans " .. arg .. "  102-104 | ������� ���� �� RDS <3")
end

function cmd_cro(arg)
	sampSendChat("/ans " .. arg .. " 105-107 | ������� ���� �� RDS <3")
end

function cmd_rumf(arg)
	sampSendChat("/ans " .. arg .. " 111-113 | ������� ���� �� RDS <3")
end

function cmd_vg(arg)
	sampSendChat("/ans " .. arg .. " 108-110 | ������� ���� �� RDS <3 ")
end

function cmd_var(arg)
	sampSendChat("/ans " .. arg .. " 114-116 | ������� ���� �� RDS <3")
end

function cmd_triad(arg)
	sampSendChat("/ans " .. arg .. " 117-118, 120  | ������� ���� �� RDS <3")
end

function cmd_mf(arg)
	sampSendChat("/ans " .. arg .. " 124-127 | ������� ���� �� RDS <3")
end

function cmd_gvm(arg)
	sampSendChat("/ans " .. arg .. " ��� �������� �����, ��������� ������ /givemoney IDPlayer ����� | �������� ����!' ")
end

function cmd_gvs(arg)
	sampSendChat("/ans " .. arg .. " ��� �������� �����, ���������� ������ /givescore IDPlayer ����� | � Diamond VIP. ")
end

function cmd_cpt(arg)
	sampSendChat("/ans " .. arg .. " ��� ����, ����� ������ ����, ����� ������ /capture | �������� ����! ")
end

function cmd_psv(arg)
	sampSendChat("/ans " .. arg .. " /passive - ��������� �����, ��� ����, ����� ��� �� ����� �����.  ")
end

function cmd_dis(arg)
	sampSendChat("/ans " ..  arg .. " ����� �� � ����. | �������� ���� �� RDS <3 ")
end

function cmd_nac(arg)
	sampSendChat("/ans " .. arg .. " ����� �������. | �������� ���� �� RDS <3")
end

function cmd_cl(arg)
	sampSendChat("/ans " .. arg .. " ������ ����� ����. | �������� ���� �� RDS <3")
end

function cmd_yt(arg)
	sampSendChat("/ans " .. arg .. " �������� ���� ������/������. | �������� ���� �� RDS <3")
end

function cmd_drb(arg)
	sampSendChat("/ans " .. arg .. " /derby - ��������� �� ����� | �������� ���� �� RDS 02 <3 ")
end

function cmd_smc(arg)
	sampSendChat("/ans " .. arg .. " /sellmycar IDPlayer ����(1-3) RDScoin (������), � ���: /car ")
end

function cmd_c(arg)
	lua_thread.create(function()
		sampSendChat("/ans " .. arg .. " �����(�) ������ �� ����� ������. | �������� ���� �� RDS <3")
		wait(1000)
		sampSetChatInputEnabled(true)
		sampSetChatInputText("/re " )
	end)
end

function cmd_stp(arg)
	sampSendChat("/ans " .. arg .. " ����� ���������� �����, �����, ����� � �.�. - /statpl ")
end

function cmd_prk(arg)
	sampSendChat("ans ".. arg .. " /parkour - ��������� �� ������ | �������� ���� �� RDS 02 <3 ")
end

function cmd_n(arg)
	sampSendChat("/ans " .. arg .. " �� ���� ��������� �� ������. | �������� ���� �� RDS <3")
end

function cmd_hg(arg)
	sampSendChat("/ans " .. arg .. " ������� ���. | ��������� ������������������� �� RDS <3 ")
end

function cmd_int(arg)
	sampSendChat("/ans " .. arg .. " ������ ���������� ����� ������ � ���������. �������� ����! ")
end

function cmd_og(arg)
	sampSendChat("/ans " .. arg ..  '������ �� ����� "���������� �����", ����� ����� ����� �������� �� ALT � ����� �� ������� ������ �� �����')
end

function cmd_msid(arg)
	lua_thread.create(function()
		sampSendChat("/ans " .. arg .. " ������������! ��������� ������ � ID! ��������� �����. ")
		sampSendChat("/ans " .. arg .. " ��������� ������������������� �� Russian Drift Server! ")
	end)
end

function cmd_al(arg)
	lua_thread.create(function()
		sampSendChat("/ans " .. arg .. " ������������! �� ������ ������ /alogin! ")
		sampSendChat("/ans " .. arg .. " ������� ������� /alogin � ���� ������, ����������.")
	end)
end

function cmd_gfi(arg)
	sampSendChat("/ans " .. arg .. " /funinvite id (� �����), /ginvite id (� �����) ")
end

function cmd_hin(arg)
	sampSendChat("/ans " .. arg .. ' /hpanel -> ����1-3 -> �������� -> ������ ���� | �������� ���� �� RDS <3 ')
end

function cmd_gn(arg)
	sampSendChat("/ans " .. arg .. " /menu (/mm) - ALT/Y -> ������ | �������� ������������������")
end

function cmd_pd(arg)
	sampSendChat("/ans " .. arg .. " /menu (/mm) - ALT/Y -> �������� | �������� ������������������")
end

function cmd_dtl(arg)
	sampSendChat("/ans " .. arg .. " ������ ���������� �� ���� �����. ����� ������������ �� /garage. | �������� ������������������")
end

function cmd_nz(arg)
	sampSendChat("/ans " .. arg .. " �� ���������. | �������� ������������������")
end

function cmd_y(arg)
	sampSendChat("/ans " .. arg .. " ��. | �������� ������������������")
end

function cmd_net(arg)
	sampSendChat("/ans " .. arg .. " ���. | �������� ������������������")
end

function cmd_gak(arg)
	sampSendChat("/ans" .. arg .. " ������� ����������, ��� ������ ����� �� /trade. ����� �������, F � ����� ")
end

function cmd_enk(arg)
	sampSendChat("/ans " .. arg .. " �����. | �������� ������������������")
end

function cmd_fp(arg)
	sampSendChat("/ans " .. arg .. " /familypanel | �������� ������������������")
end

function cmd_mg(arg)
	sampSendChat("/ans " .. arg .. " /menu (/mm) - ALT/Y -> ������� ���� | �������� ������������������")
end

function cmd_pg(arg)
	sampSendChat("/ans " .. arg .. " ��������. | �������� ������������������")
end

function cmd_krb(arg)
	sampSendChat("/ans " .. arg .. " ������, ������, ������. | �������� ������������������")
end

function cmd_kmd(arg)
	sampSendChat("/ans " .. arg .. " ������, ��, ����������, ������, ����� ����� �� �����(/trade) | �������� ���� �� RDS <3")
end

function cmd_gm(arg)
	sampSendChat("/ans " .. arg .. " GodMode (������) �� ������� �� ��������. | �������� ������������������")
end

function cmd_plg(arg)
	sampSendChat("/ans " .. arg .. " ���������� ���������. | �������� ������������������")
end

function cmd_nv(arg)
	sampSendChat("/ans " .. arg .. " �� ������. | �������� ������������������")
end

function cmd_of(arg)
	sampSendChat("/ans " .. arg .. " �� ���������. | �������� ������������������")
end

function cmd_en(arg)
	sampSendChat("/ans " .. arg .. " �� �����. | �������� ������������������")
end

function cmd_vbg(arg)
	sampSendChat("/ans " .. arg .. " ������ ����� - ��� ���. | �������� ������������������")
end

function cmd_ctun(arg)
	sampSendChat("/ans " .. arg .. ' /menu (/mm) - ALT/Y -> �/� -> ������ | �������� ���� �� RDS <3')
end

function cmd_cr(arg)
	sampSendChat("/ans " .. arg .. ' /car | �������� ���� �� ������� RDS <3 ')
end

function cmd_zsk(arg)
	sampSendChat("/ans " .. arg .. " ���� �� ��������, ������� /spawn | /kill | �������� ���� �� RDS <3")
end

function cmd_smh(arg)
	sampSendChat("/ans " .. arg .. " /sellmyhouse (������)  ||  /hpanel -> ���� -> �������� -> ������� ��� ����������� ")
end

function cmd_gadm(arg)
	sampSendChat("/ans " .. arg .. " ������� �����, ��� �� /help -> 18 �����. | �������� ���� �� RDS. <3")
end

function cmd_hct(arg)
	sampSendChat("/ans " .. arg .. " /count time || /dmcount time | �������� ���� �� RDS. <3 ")
end

function cmd_gvr(arg)
	sampSendChat("/ans " .. arg .. " /giverub IDPlayer rub | � ������� (/help -> 7) | �������� ����!")
end

function cmd_gvc(arg)
	sampSendChat("/ans " .. arg .. " /givecoin IDPlayer coin | � ������� (/help -> 7) | �������� ����!")
end

function cmd_tdd(arg)
	sampSendChat("/ans " .. arg .. " /dt 0-990 / ����������� ��� | �������� ����!")
end
-- ## ���� ������� - ������� ������� � ���� ## --


-- ## ���� ��������� ������� � ������� SA:MP ## -- 
function sampev.onServerMessage(color, text)
    if text:find("������������� ��� ��������� ������ ������") then  
        sampAddChatMessage(tag .. " �����-�� ������������� ��� ��������� ������. ���� ��������� �������, �� ��������� :(")
        ATReportShow.v = false
        imgui.Process = ATReportShow.v 
        return false
    end
end

function sampev.onShowDialog(id, style, title, button1, button2, text)
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

    if ATReportShow.v then  
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5)) 
        imgui.SetNextWindowSize(imgui.ImVec2(400, 300), imgui.Cond.FirstUseEver)

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
        imgui.EndMenuBar()

        if elements.select_menu == 0 then
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
            imgui.InputText('##�����', elements.text) 
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
            imgui.Separator()
            if imgui.Button(fa.ICON_FA_EYE .. u8" ������ �� ��") then  
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
            if imgui.Button(fa.ICON_BAN .. u8" �������") then
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
			if imgui.Button(fa.ICON_COMMENTING_O .. u8" �������� ID") then  
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
			if imgui.Button(fa.ICON_FA_EDIT .. u8" �������� ��") then  
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
			if imgui.Button(fa.ICON_CHECK .. u8" �������� ������ ##SEND") then  
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
            if imgui.Button(fai.ICON_FA_QUESTION_CIRCLE .. u8" ������ �� AT") then 
                elements.select_menu = 1
            end
            imgui.SameLine()
			if imgui.Button(fa.ICON_FA_SAVE .. u8" ����������� ������") then  
				elements.select_menu = 2
			end	
            imgui.Separator()
			-- imgui.Text(u8'����� ������:' .. (#elements.text.v))
			if imgui.Checkbox(u8"��������� � �����", elements.prefix_answer) then 
				config.main.prefix_answer = elements.prefix_answer.v
				inicfg.save(config, directIni)
			end; imgui.Tooltip(u8"������������� ��� ������ ����� �������� ����� ������ ��, ��� �� ���������������")
            elements.prefix_for_answer.v = config.main.prefix_for_answer
            if imgui.InputText(u8'���� ��������', elements.prefix_for_answer) then  
                config.main.prefix_for_answer = elements.prefix_for_answer.v
                inicfg.save(config, directIni)
            end
            imgui.SetCursorPosY(imgui.GetWindowWidth() - 135)
            imgui.Separator()
            imgui.SetCursorPosY(imgui.GetWindowWidth() - 125)
            if imgui.Button(u8" ��������") then
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
            if imgui.Button(fa.ICON_BAN .. u8" ���������") then  
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
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 80)
            if imgui.Button(fa.ICON_WINDOW_CLOSE .. u8" �������") then  
                lua_thread.create(function()
                    sampSendDialogResponse(2349, 0, 0)
                    wait(50)
                    sampSendDialogResponse(2348, 0, 0)
                    ATReportShow.v = false
                    imgui.Process = ATReportShow.v 
                    imgui.ShowCursor = ATReportShow.v
                end)
            end
            
            if imgui.BeginPopupModal(u8'Binder', false, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
                imgui.BeginChild("##EditBinder", imgui.ImVec2(600, 225), true)
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
            imgui.BeginChild("##menuSecond", imgui.ImVec2(150, 275), true)
			if imgui.Button(fa.ICON_OBJECT_GROUP .. u8" �� ����-��/���-��", imgui.ImVec2(135, 0)) then  -- reporton key
				elements.select_category = 1  
			end	
			if imgui.Button(fa.ICON_LIST .. u8" ������� (/help)", imgui.ImVec2(135, 0)) then  -- HelpCMD key
				elements.select_category = 2 
			end 	
			if imgui.Button(fa.ICON_USERS .. u8" �����/�����", imgui.ImVec2(135, 0)) then  -- HelpGangFamilyMafia key
				elements.select_category = 3
			end	
			if imgui.Button(fa.ICON_MAP_MARKER .. u8" ���������", imgui.ImVec2(135, 0)) then  -- HelpTP key
				elements.select_category = 4
			end	
			if imgui.Button(fa.ICON_SHOPPING_BAG .. u8" �������", imgui.ImVec2(135, 0)) then  -- HelpBuz key
				elements.select_category = 5 
			end	
			if imgui.Button(fa.ICON_MONEY .. u8" �������/�������", imgui.ImVec2(135, 0)) then  -- HelpSellBuy key
				elements.select_category = 6 
			end	
			if imgui.Button(fa.ICON_BOLT .. u8" ���������", imgui.ImVec2(135, 0)) then  -- HelpSettings key
				elements.select_category = 7
			end	
			if imgui.Button(fa.ICON_HOME .. u8" ����", imgui.ImVec2(135, 0)) then  -- HelpHouses key
				elements.select_category = 8 
			end	
			if imgui.Button(fa.ICON_MALE .. u8" �����", imgui.ImVec2(135, 0)) then  -- HelpSkins key
				elements.select_category = 9 
			end	
			if imgui.Button(fa.ICON_BARCODE .. u8" ��������� ������", imgui.ImVec2(135, 0)) then  -- HelpDefault key
				elements.select_category = 10
			end	
			imgui.Separator()
			if imgui.Button(fa.ICON_BACKWARD .. u8" �����") then  
				elements.select_menu = 0 
			end	
			imgui.EndChild()
			imgui.SameLine()
			imgui.BeginChild("##menuSelectable", imgui.ImVec2(390, 275), true)
			if elements.select_category == 0 then  
				imgui.Text(u8"�������������/����������� ������ \n������ ���� �������� \n������ ��������������")
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
					elements.binder_name.v, elements.binder_text.v, elements.binder_delay.v = '', '', 2500
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
							if save() then
								sampAddChatMessage(tag .. '����"' ..u8:decode(elements.binder_name.v).. '" ������� ������!', -1)
								elements.binder_name.v, elements.binder_text.v, elements.binder_delay.v = '', '', 2500
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
							if save() then
								sampAddChatMessage(tag .. '����"' ..u8:decode(elements.binder_name.v).. '" ������� ��������������!', -1)
								elements.binder_name.v, elements.binder_text.v, elements.binder_delay.v = '', '', 2500
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