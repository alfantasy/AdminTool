script_name('AdminTool')
script_description('����������� ���������������� ������ ��� ������� Russian Drift Server � SA:MP')
script_author('alfantasyz')

-- ## ����������� ���������, �������� � ������� ## --
require "lib.moonloader"
local fflags = require("moonloader").font_flag -- ������ � ������� ��� ������� ������
local dlstatus = require('moonloader').download_status -- ������ � ����������� ��������� ������ ��� ������ URL
local inicfg = require 'inicfg' -- ������ � INI �������
local sampev = require 'lib.samp.events' -- ������ � �������� � �������� SAMP
local encoding = require 'encoding' -- ������ � ����������
local imgui = require 'imgui' -- MoonImGUI || ���������������� ���������
local memory = require 'memory' -- ������ � ������� GTA SA
local atlibs = require 'libsfor' -- ���������� ��� ������ � ��
local scoreboard = import (getWorkingDirectory() .. '\\lib\\scoreboard.lua') -- ���������� ����������������� ���������� ScoreBoard
local notf_res, notf = pcall(import, 'lib/imgui_notf.lua')  -- ������ �����������
local ffi = require 'ffi' -- ���������� �����, ���������� �� C++, ����������� ����������������� ����������

local events_res, events = pcall(import, "events.lua") -- ������ ������������ ������� (�������), ��� ����� ����������� ������� ��� �������� � ������ � �������������
local other_res, pother = pcall(import, "module/plugins/other.lua") -- ������ ������������ ������� (�������), ��� ����� ����������� ���������, ����������� �� �� �������
local automute_res, automute = pcall(import, "module/plugins/automute.lua") -- ������ ������������ ������� (�������), ��� ����������� ������� ��� ��������
local plugins_main_res, plugin = pcall(import, "module/plugins/plugin.lua") -- ������ ������������ ������� (�������), ��� ����������� ������� ��� ������� ��������� ����� ����
 
local fai = require "fAwesome5" -- ������ � �������� Font Awesome 5
local fa = require 'faicons' -- ������ � �������� Font Awesome 4
-- ## ����������� ���������, �������� � ������� ## --

-- ## ���� �������, ������������� ������������ FFI ## -- 
ffi.cdef[[
struct stKillEntry
{
	char					szKiller[25];
	char					szVictim[25];
	uint32_t				clKillerColor; // D3DCOLOR
	uint32_t				clVictimColor; // D3DCOLOR
	uint8_t					byteType;
} __attribute__ ((packed));

struct stKillInfo
{
	int						iEnabled;
	struct stKillEntry		killEntry[5];
	int 					iLongestNickLength;
	int 					iOffsetX;
	int 					iOffsetY;
	void			    	*pD3DFont; // ID3DXFont
	void		    		*pWeaponFont1; // ID3DXFont
	void		   	    	*pWeaponFont2; // ID3DXFont
	void					*pSprite;
	void					*pD3DDevice;
	int 					iAuxFontInited;
	void 		    		*pAuxFont1; // ID3DXFont
	void 			    	*pAuxFont2; // ID3DXFont
} __attribute__ ((packed));
]]
-- ## ���� �������, ������������� ������������ FFI ## -- 

-- ## ����.�����, ������������ ���� SAMP ## --
colours = {
	-- The existing colours from San Andreas
	"0x080808FF", "0xF5F5F5FF", "0x2A77A1FF", "0x840410FF", "0x263739FF", "0x86446EFF", "0xD78E10FF", "0x4C75B7FF", "0xBDBEC6FF", "0x5E7072FF",
	"0x46597AFF", "0x656A79FF", "0x5D7E8DFF", "0x58595AFF", "0xD6DAD6FF", "0x9CA1A3FF", "0x335F3FFF", "0x730E1AFF", "0x7B0A2AFF", "0x9F9D94FF",
	"0x3B4E78FF", "0x732E3EFF", "0x691E3BFF", "0x96918CFF", "0x515459FF", "0x3F3E45FF", "0xA5A9A7FF", "0x635C5AFF", "0x3D4A68FF", "0x979592FF",
	"0x421F21FF", "0x5F272BFF", "0x8494ABFF", "0x767B7CFF", "0x646464FF", "0x5A5752FF", "0x252527FF", "0x2D3A35FF", "0x93A396FF", "0x6D7A88FF",
	"0x221918FF", "0x6F675FFF", "0x7C1C2AFF", "0x5F0A15FF", "0x193826FF", "0x5D1B20FF", "0x9D9872FF", "0x7A7560FF", "0x989586FF", "0xADB0B0FF",
	"0x848988FF", "0x304F45FF", "0x4D6268FF", "0x162248FF", "0x272F4BFF", "0x7D6256FF", "0x9EA4ABFF", "0x9C8D71FF", "0x6D1822FF", "0x4E6881FF",
	"0x9C9C98FF", "0x917347FF", "0x661C26FF", "0x949D9FFF", "0xA4A7A5FF", "0x8E8C46FF", "0x341A1EFF", "0x6A7A8CFF", "0xAAAD8EFF", "0xAB988FFF",
	"0x851F2EFF", "0x6F8297FF", "0x585853FF", "0x9AA790FF", "0x601A23FF", "0x20202CFF", "0xA4A096FF", "0xAA9D84FF", "0x78222BFF", "0x0E316DFF",
	"0x722A3FFF", "0x7B715EFF", "0x741D28FF", "0x1E2E32FF", "0x4D322FFF", "0x7C1B44FF", "0x2E5B20FF", "0x395A83FF", "0x6D2837FF", "0xA7A28FFF",
	"0xAFB1B1FF", "0x364155FF", "0x6D6C6EFF", "0x0F6A89FF", "0x204B6BFF", "0x2B3E57FF", "0x9B9F9DFF", "0x6C8495FF", "0x4D8495FF", "0xAE9B7FFF",
	"0x406C8FFF", "0x1F253BFF", "0xAB9276FF", "0x134573FF", "0x96816CFF", "0x64686AFF", "0x105082FF", "0xA19983FF", "0x385694FF", "0x525661FF",
	"0x7F6956FF", "0x8C929AFF", "0x596E87FF", "0x473532FF", "0x44624FFF", "0x730A27FF", "0x223457FF", "0x640D1BFF", "0xA3ADC6FF", "0x695853FF",
	"0x9B8B80FF", "0x620B1CFF", "0x5B5D5EFF", "0x624428FF", "0x731827FF", "0x1B376DFF", "0xEC6AAEFF", "0x000000FF",
	-- SA-MP extended colours (0.3x)
	"0x177517FF", "0x210606FF", "0x125478FF", "0x452A0DFF", "0x571E1EFF", "0x010701FF", "0x25225AFF", "0x2C89AAFF", "0x8A4DBDFF", "0x35963AFF",
	"0xB7B7B7FF", "0x464C8DFF", "0x84888CFF", "0x817867FF", "0x817A26FF", "0x6A506FFF", "0x583E6FFF", "0x8CB972FF", "0x824F78FF", "0x6D276AFF",
	"0x1E1D13FF", "0x1E1306FF", "0x1F2518FF", "0x2C4531FF", "0x1E4C99FF", "0x2E5F43FF", "0x1E9948FF", "0x1E9999FF", "0x999976FF", "0x7C8499FF",
	"0x992E1EFF", "0x2C1E08FF", "0x142407FF", "0x993E4DFF", "0x1E4C99FF", "0x198181FF", "0x1A292AFF", "0x16616FFF", "0x1B6687FF", "0x6C3F99FF",
	"0x481A0EFF", "0x7A7399FF", "0x746D99FF", "0x53387EFF", "0x222407FF", "0x3E190CFF", "0x46210EFF", "0x991E1EFF", "0x8D4C8DFF", "0x805B80FF",
	"0x7B3E7EFF", "0x3C1737FF", "0x733517FF", "0x781818FF", "0x83341AFF", "0x8E2F1CFF", "0x7E3E53FF", "0x7C6D7CFF", "0x020C02FF", "0x072407FF",
	"0x163012FF", "0x16301BFF", "0x642B4FFF", "0x368452FF", "0x999590FF", "0x818D96FF", "0x99991EFF", "0x7F994CFF", "0x839292FF", "0x788222FF",
	"0x2B3C99FF", "0x3A3A0BFF", "0x8A794EFF", "0x0E1F49FF", "0x15371CFF", "0x15273AFF", "0x375775FF", "0x060820FF", "0x071326FF", "0x20394BFF",
	"0x2C5089FF", "0x15426CFF", "0x103250FF", "0x241663FF", "0x692015FF", "0x8C8D94FF", "0x516013FF", "0x090F02FF", "0x8C573AFF", "0x52888EFF",
	"0x995C52FF", "0x99581EFF", "0x993A63FF", "0x998F4EFF", "0x99311EFF", "0x0D1842FF", "0x521E1EFF", "0x42420DFF", "0x4C991EFF", "0x082A1DFF",
	"0x96821DFF", "0x197F19FF", "0x3B141FFF", "0x745217FF", "0x893F8DFF", "0x7E1A6CFF", "0x0B370BFF", "0x27450DFF", "0x071F24FF", "0x784573FF",
	"0x8A653AFF", "0x732617FF", "0x319490FF", "0x56941DFF", "0x59163DFF", "0x1B8A2FFF", "0x38160BFF", "0x041804FF", "0x355D8EFF", "0x2E3F5BFF",
	"0x561A28FF", "0x4E0E27FF", "0x706C67FF", "0x3B3E42FF", "0x2E2D33FF", "0x7B7E7DFF", "0x4A4442FF", "0x28344EFF"
	}
-- ## ����.�����, ������������ ���� SAMP ## --

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

-- ## ����������� ������ ��� GitHub, ���������� ��� ���������� ## --
local urls = {
	["main"] = "",
	["pluginsAT"] = "",
	["otherAT"] = "",
	["libs"] = "",
	["pluginsSAT"] = "",
}
local paths = {
	["main"] = "",
	["pluginsAT"] = "",
	["otherAT"] = "",
	["libs"] = "",
	["pluginsSAT"] = "",
}

local script_version_text = "14.0"
-- ## ����������� ������ ��� GitHub, ���������� ��� ���������� ## --

-- ## ���� ���������� ��������� � ��������� � ���������� �������������� � ����������� ������� ## --
local directReports = "AdminTool\\settings_reports.ini"
local configReports = inicfg.load({
	main = {
        prefix_answer = false, 
        prefix_for_answer = " // �������� ���� �� ������� RDS <3",
    },
    bind_name = {},
    bind_text = {},
    bind_delay = {},
}, directReports)

local direct = "AdminTool\\settings.ini"
local config = inicfg.load({
    main = {
		aclist_alogin = false,
		ears_alogin = false,
		agm_alogin = false,
        push_report = false, 
        auto_login = false, 
        custom_tab = false, 
        render_admins = false,
		render_admins_imgui = false,
        password = "",
        recon_menu = false, 
        auto_online = false,
        styleImGUI = 0,
        font = 10,
    },
    colours = {
        render_admins = "{FFFFFF}",
    },
    keys = {
        WallHack = "None",
        GUI = "F3",
        OpenReport = "None",
        GiveOnline = "None",
    },
    position = {
        reX = 0,
        reY = 0,
        acX = 0,
        acY = 0,
    },
}, direct)
inicfg.save(config, direct)

function ConfigSave()
    inicfg.save(config, direct)
end

local elm = {
    boolean = {
		aclist_alogin = imgui.ImBool(config.main.aclist_alogin),
		ears_alogin = imgui.ImBool(config.main.ears_alogin),
		agm_alogin = imgui.ImBool(config.main.agm_alogin),
        push_report = imgui.ImBool(config.main.push_report),
        auto_login = imgui.ImBool(config.main.auto_login),
        custom_tab = imgui.ImBool(config.main.custom_tab),
        recon_menu = imgui.ImBool(config.main.recon_menu),
        render_admins = imgui.ImBool(config.main.render_admins),
		render_admins_imgui = imgui.ImBool(config.main.render_admins_imgui),
        auto_online = imgui.ImBool(config.main.auto_online),
    },
    int = {
        styleImGUI = imgui.ImInt(config.main.styleImGUI),
        font = imgui.ImInt(config.main.font),
    },
    input = {
        password = imgui.ImBuffer(tostring(config.main.password), 50),
        set_punish_in_recon = imgui.ImBuffer(100),
        set_time_punish_in_recon = imgui.ImBuffer(100),
    },
	binder = {
		prefix = imgui.ImBuffer(256),
		name = imgui.ImBuffer(256),
		text = imgui.ImBuffer(65536),
		delay = imgui.ImBuffer(2500),
	},
    position = {
        reX = config.position.reX, 
        reY = config.position.reY, 
        acX = config.position.acX, 
        acY = config.position.acY,
        change_recon = false,
    }
}
-- ## ���� ���������� ��������� � ��������� � ���������� �������������� � ����������� ������� ## --

-- ## ���� ���������� ��������� � MoonImGUI ## --
local sw, sh = getScreenResolution()
local ATMenu = imgui.ImBool(false)
local ATRecon = imgui.ImBool(false)
local ATAdmins = imgui.ImBool(false)
local ATPlayerStream = imgui.ImBool(false)
local menuSelect = 0 
local show_password = false

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

imgui.ToggleButton = require('imgui_addons').ToggleButton
imgui.Spinner = require('imgui_addons').Spinner
imgui.BufferingBar = require('imgui_addons').BufferingBar
imgui.Tooltip = require('imgui_addons').Tooltip

local colorsImGui = {
    u8"������", -- 0
    u8"����-������", -- 1
    u8"�����", -- 2
    u8"Sky Blue", -- 3
    u8"�����", -- 4
    u8"�����-�������", -- 5
    u8"�������", -- 6
    u8"�����-�������", -- 7
    u8"����������", -- 8
    u8"����������", -- 9
    u8"���������� v2", -- 10
    u8"���������", -- 11
    u8"����-�������", -- 12
    u8"Ƹ���-�����", -- 13
    u8"�������� ����" -- 14
} 

local set_color_float3 = imgui.ImFloat3(1.0, 1.0, 1.0)
-- ## ���� ���������� ��������� � MoonImGUI ## --

-- ## ���� ���������� ��������� � ��������� ������� ## --
local ids_recon = {437, 2056, 144, 146, 141, 2050, 155, 153, 152, 156, 154, 160, 157, 179, 165, 159, 164, 162, 161, 180, 178, 163, 169, 181, 161, 166, 170, 168, 174, 182, 172, 171, 175, 173, 150, 184, 147, 148, 151, 149, 142, 143, 184, 177, 145, 158, 167, 183, 176}
local info_to_player = {}
local recon_info = { "��������: ", "�����: ", "�� ������: ", "��������: ", "����: ", "�������: ", "�������: ", "������� ��������: ", "����� � ���: ", "P.Loss: ", "������� VIP: ", "��������� �����: ", "�����-�����: ", "��������: "}
local control_to_player = false
local select_recon = 0
local recon_punish = 0
local recon_id = -1
local right_recon = imgui.ImBool(true)
local accept_load_recon = false
-- ## ���� ���������� ��������� � ��������� ������� ## --

-- ## ���� ����������, ��������� � ������� ��������� ## --
local admins = {}
local render_admin = {
    set_position = false, 
    Y = 0,
    X, 0,
}

local render_font = renderCreateFont("Arial", tonumber(elm.int.font.v), fflags.BOLD + fflags.SHADOW)
-- ## ���� ����������, ��������� � ������� ��������� ## --

-- ## ����������� �������������� ����������� ��� ������� ## --
local control_spawn = false 
-- ## ����������� �������������� ����������� ��� ������� ## -- 

-- ## ���� ��������� ������ ## --

-- ## ���� ��������� ������ ## --

function main()
    while not isSampAvailable() do wait(0) end
    
    sampAddChatMessage(tag .. "������ ���������������. ��� �������� AT �������: /tool", -1)
    sampfuncsLog(log .. " ������������� ��������� �������. \n   ��������� ����������� �������� � ���������, ���������� � MoonLoader")
    
    -- ## ����������� ������� ## --
    load_recon = lua_thread.create_suspended(loadRecon)
    draw_admins = lua_thread.create_suspended(drawAdmins)
    send_online = lua_thread.create_suspended(drawOnline)
    -- ## ����������� ������� ## --

    -- ## ������ ������� ## -- 
    draw_admins:run()
    send_online:run()
    -- ## ������ ������� ## -- 

	-- ## ����������� WaterMark ������ ## --
	font_watermark = renderCreateFont("Arial", 10, fflags.BOLD)

	lua_thread.create(function()
		while true do 
			renderFontDrawText(font_watermark, " {6A5ACD}[AdminTool]{FFFFFF} version - " .. script_version_text .. "", 10, sh-20, 0xCCFFFFFF)

			wait(1)
		end	
	end)

	-- ## ����������� WaterMark ������ ## --

    -- ## ����������� �������� ������ ��� ������� �������������� � �� ## --
    sampRegisterChatCommand('tool', function()
        ATMenu.v = not ATMenu.v 
        imgui.Process = ATMenu.v
    end)
	sampRegisterChatCommand('rtl', function()
		ATPlayerStream.v = not ATPlayerStream.v  
		imgui.Process = ATPlayerStream.v
	end)
    -- ## ����������� �������� ������ ��� ������� �������������� � �� ## --

    -- ## ����������� ������ ��������� � ������� ������-��������� ���� ## --
    sampRegisterChatCommand("cp", cmd_cpfd)
    sampRegisterChatCommand("rpo", cmd_report_popr)
    sampRegisterChatCommand("rrz", cmd_rrz)
	sampRegisterChatCommand("roa", cmd_roa)
	sampRegisterChatCommand("ror", cmd_ror)
    sampRegisterChatCommand("rup", cmd_rup)
	sampRegisterChatCommand("rok", cmd_rok)
	sampRegisterChatCommand("rm", cmd_rm)
    sampRegisterChatCommand("rnm", cmd_report_neadekvat)
    -- ## ����������� ������ ��������� � ������� ������-��������� ���� ## --

    -- ## ����������� ������ ��������� � ������� offline-��������� ���� ## --
    sampRegisterChatCommand("am", cmd_am)
	sampRegisterChatCommand("aok", cmd_aok)
	sampRegisterChatCommand("afd", cmd_afd)
	sampRegisterChatCommand("apo", cmd_apo)
	sampRegisterChatCommand("aoa", cmd_aoa)
	sampRegisterChatCommand("aup", cmd_aup)
	sampRegisterChatCommand("anm", cmd_offline_neadekvat)
	sampRegisterChatCommand("aor", cmd_aor)
	sampRegisterChatCommand("aia", cmd_aia)
	sampRegisterChatCommand("akl", cmd_akl)
	sampRegisterChatCommand("arz", cmd_arz)
	sampRegisterChatCommand("azs", cmd_azs)
    -- ## ����������� ������ ��������� � ������� offline-��������� ���� ## --

	-- ## ����������� ������ ��������� � ������� offline-��������� ������ ## --
	sampRegisterChatCommand("ajcw", cmd_ajcw)
	sampRegisterChatCommand("ask", cmd_ask)
	sampRegisterChatCommand("adz", cmd_adz)
	sampRegisterChatCommand("afsh", cmd_afsh)
	sampRegisterChatCommand("atd", cmd_atd)
	sampRegisterChatCommand("abag", cmd_abag)
	sampRegisterChatCommand("apk", cmd_apk)
	sampRegisterChatCommand("azv", cmd_azv)
	sampRegisterChatCommand("askw", cmd_askw)
	sampRegisterChatCommand("angw", cmd_angw)
	sampRegisterChatCommand("adbgw", cmd_adbgw)
	sampRegisterChatCommand("adgw", cmd_adgw)
	sampRegisterChatCommand("ajch", cmd_ajch)
	sampRegisterChatCommand("apmx", cmd_apmx)
	sampRegisterChatCommand("asch", cmd_asch)
	-- ## ����������� ������ ��������� � ������� offline-��������� ������ ## --

    -- ## ����������� ������ ��������� � ������� ��������� ������ ## --
	sampRegisterChatCommand("sk", cmd_sk)
	sampRegisterChatCommand("dz", cmd_dz)
	sampRegisterChatCommand("jm", cmd_jm)
	sampRegisterChatCommand("td", cmd_td)
	sampRegisterChatCommand("skw", cmd_skw)
	sampRegisterChatCommand("ngw", cmd_ngw)
	sampRegisterChatCommand("dbgw", cmd_dbgw)
	sampRegisterChatCommand("fsh", cmd_fsh)
	sampRegisterChatCommand("bag", cmd_bag)
	sampRegisterChatCommand("pmx", cmd_pmx)
	sampRegisterChatCommand("pk", cmd_pk)
	sampRegisterChatCommand("zv", cmd_zv)
	sampRegisterChatCommand("jch", cmd_jch)
	sampRegisterChatCommand("dgw", cmd_dgw)
	sampRegisterChatCommand("sch", cmd_sch)
	sampRegisterChatCommand("jcw", cmd_jcw)
	sampRegisterChatCommand("tdbz", cmd_tdbz)
    -- ## ����������� ������ ��������� � ������� ��������� ������ ## --

    -- ## ����������� ������ ��������� � ������� ��������� ���� ## --
	sampRegisterChatCommand("pl", cmd_pl)
	sampRegisterChatCommand("ob", cmd_ob)
	sampRegisterChatCommand("hl", cmd_hl)
	sampRegisterChatCommand("nk", cmd_nk)
	sampRegisterChatCommand("menk", cmd_menk)
	sampRegisterChatCommand("gcnk", cmd_gcnk)
	sampRegisterChatCommand("bnm", cmd_bnm)
    -- ## ����������� ������ ��������� � ������� ��������� ���� ## --

    -- ## ����������� ������ ��������� � ������� offline-��������� ���� ## --
	sampRegisterChatCommand("aob", cmd_aob)
	sampRegisterChatCommand("ahl", cmd_ahl)
	sampRegisterChatCommand("ahli", cmd_ahli)
	sampRegisterChatCommand("apl", cmd_apl)
	sampRegisterChatCommand("ach", cmd_ach)
	sampRegisterChatCommand("achi", cmd_achi)
	sampRegisterChatCommand("ank", cmd_ank)
	sampRegisterChatCommand("amenk", cmd_amenk)
	sampRegisterChatCommand("agcnk", cmd_agcnk)
	sampRegisterChatCommand("agcnkip", cmd_agcnkip)
	sampRegisterChatCommand("rdsob", cmd_rdsob)
	sampRegisterChatCommand("rdsip", cmd_rdsip)
	sampRegisterChatCommand("abnm", cmd_abnm)
    -- ## ����������� ������ ��������� � ������� offline-��������� ���� ## --

	-- ## ����������� ������ ��������� � ������� ��������� ���� ## --
	sampRegisterChatCommand("dj", cmd_dj)
	sampRegisterChatCommand("gnk", cmd_gnk)
	sampRegisterChatCommand("cafk", cmd_cafk)
	-- ## ����������� ������ ��������� � ������� ��������� ���� ## --

    -- ## ����������� ��������������� ������ ## --

    sampRegisterChatCommand("u", cmd_u)
	sampRegisterChatCommand("uu", cmd_uu)
	sampRegisterChatCommand("uj", cmd_uj)
	sampRegisterChatCommand("as", cmd_as)
	sampRegisterChatCommand("stw", cmd_stw)
	sampRegisterChatCommand("ru", cmd_ru)

    sampRegisterChatCommand('rcl', function()
        showNotification("������� ���� ��������.")
        memory.fill(sampGetChatInfoPtr() + 306, 0x0, 25200)
        memory.write(sampGetChatInfoPtr() + 306, 25562, 4, 0x0)
        memory.write(sampGetChatInfoPtr() + 0x63DA, 1, 1)
    end)
    sampRegisterChatCommand('spp', function()
        local user_to_stream = playersToStreamZone()
        for _, v in pairs(user_to_stream) do 
            sampSendChat('/aspawn ' .. v)
        end
    end)
    sampRegisterChatCommand("aheal", function(id)
		lua_thread.create(function()
			sampSendClickPlayer(id, 0)
			wait(200)
			sampSendDialogResponse(500, 1, 4)
			wait(200)
			sampCloseCurrentDialogWithButton(0)
		end)
	end)
	sampRegisterChatCommand("akill", function(id)
		lua_thread.create(function()
			sampSendClickPlayer(id, 0)
			wait(200)
			sampSendDialogResponse(500, 1, 7)
			wait(200)
			sampSendDialogResponse(48, 1, _, "kill")
			wait(200)
			sampCloseCurrentDialogWithButton(0)
		end)
	end)
    -- ## ����������� ��������������� ������ ## --

    while true do
        wait(0)
        imgui.Process = true 

        if control_spawn and elm.boolean.auto_login.v then  
            wait(10000)
            sampSendChat("/alogin " .. u8:decode(elm.input.password.v))
			wait(100)
			if elm.boolean.aclist_alogin.v then  
				sampSendChat("/aclist")
			end 
			if elm.boolean.ears_alogin.v then  
				sampSendChat("/ears")
			end  
			if elm.boolean.agm_alogin.v then  
				sampSendChat("/agm")
			end
            control_spawn = false
        end

        if isKeyJustPressed(VK_RBUTTON) and not sampIsChatInputActive() and not sampIsDialogActive() and control_to_player then
			imgui.ShowCursor = not imgui.ShowCursor
			wait(600)
        end

        if isKeyJustPressed(VK_TAB) and elm.boolean.custom_tab.v then
			scoreboard.ActivetedScoreboard()
		end

        if atlibs.isKeysDown(atlibs.strToIdKeys(config.keys.WallHack)) then  
            sampAddChatMessage("ok", -1)
        end

        if atlibs.isKeysDown(atlibs.strToIdKeys("R")) and ATRecon.v then
            sampSendClickTextdraw(156)
        end

        if atlibs.isKeysDown(atlibs.strToIdKeys("Q")) and ATRecon.v and control_to_player == true then  
            sampSendChat("/reoff " )
            control_to_player = false
            imgui.ShowCursor = false 
        end

        if atlibs.isKeysDown(atlibs.strToIdKeys(config.keys.GUI)) then  
            ATMenu.v = not ATMenu.v 
            imgui.Process = ATMenu.v
        end
		
		if control_to_player then  
			load_recon:run()
			ATRecon.v = true  
			imgui.Process = true  
		else 
			ATRecon.v = false	
		end

		if elm.boolean.render_admins_imgui.v then  
			ATAdmins.v = true  
			imgui.ShowCursor = false  
		end

		if not sampIsPlayerConnected(recon_id) then
			ATRecon.v = false
			recon_id = -1
		end

        if not ATMenu.v and not ATRecon.v and not ATAdmins.v and not ATPlayerStream.v then  
            imgui.Process = false  
            imgui.ShowCursor = false 
        end 

        if sampGetDialogCaption() == "{ff8587}������������� ������� (������)" and (elm.boolean.render_admins.v or elm.boolean.render_admins_imgui.v) then 
			sampCloseCurrentDialogWithButton(0)
		end	 

        if render_admin.set_position then  
            change_position_admins()
        end

        if elm.position.change_recon then  
            change_position_recon() 
        end
    end
end

-- ## ���� ��������� �������, ��������� �� ������� � ����� ## -- 
function change_position_admins()
	if isKeyJustPressed(VK_RBUTTON) then
		elm.position.acX = render_admin.X
		elm.position.acY = render_admin.Y
		render_admin.set_position = false
	elseif isKeyJustPressed(VK_LBUTTON) then
		render_admin.set_position = false
		config.position.acX = elm.position.acX
		config.position.acY = elm.position.acY
		ConfigSave()
		showNotification("��������� ��������� �������")
	else
		elm.position.acX, elm.position.acY = getCursorPos()
	end
end
-- ## ���� ��������� �������, ��������� �� ������� � ����� ## -- 

-- ## ���� ��������� ������� � ������� SA:MP ## -- 
function sampev.onShowDialog(id, style, title, button1, button2, text)
	if title == "Mobile" then -- ���� ���� ������� �������
		if ATRecon.v then 
			if text:match(recon_nick) then
			t_online = "��������� �������"
			else
			t_online = "������ SAMP"
			end
			sampAddChatMessage("")
			sampAddChatMessage(tag .."����� {EE1010}".. recon_nick .. "["..recon_id.."] {CCCCCC}���������� {EE1010}".. t_online)
			sampAddChatMessage("")
		end  
		return false
    end

	if elm.boolean.render_admins.v then 
		if id == 0 and title:find("������������� �������") then
			admins = {}
			local j = 0
			text = text .. "\n"
			for i = 0, text:len()-1 do 
				local s = text:sub(i, i)
				if s == "\n" then 
					local line = text:sub(j, i)
					line = line:gsub("{......}", "")
					if line:match("(.+)%((%d+)%) %((.+)%)") then
						local nick, id, prefix, lvl, vig, rep = line:match("(.+)%((%d+)%) %((.+)%) | �������: (%d+) | ��������: (%d+) �� 3 | ���������: (%d+)")
						local admin = {
							nick = nick,
							id = id,
							prefix = prefix,
							lvl = lvl,
							vig = vig,
							rep = rep
						}
						table.insert(admins, admin)
					else
						local nick, id, lvl, vig, rep = line:match("(.+)%((%d+)%) | �������: (%d+) | ��������: (%d+) �� 3 | ���������: (%d+)")
						local admin = {
							nick = nick,
							id = id,
							lvl = lvl,
							vig = vig,
							rep = rep
						}
						table.insert(admins, admin)
					end
					j = i
				end
			end
			return true
		end
	end
end

function sampev.onServerMessage(color, text)
    local check_string = string.match(text, "[^%s]+")

    if text:find("����� �� � ����") then  
        control_to_player = false 
		sampSendChat("/reoff")
        return true
    end
    if text:find("�� ���������� �� (.+)") then  
        control_to_player = true 
        return true
    end
    if text:find("%[A%] ������������� (.+)%[(%d+)%] %(%d+ level%) ������������� � ����� ������") or text:find("%[A%-(%d+)%] (.+) ����������") then 
		sampAddChatMessage('{8B8B8B}' .. text, -1)
		if elm.boolean.render_admins.v or elm.boolean.render_admins_imgui.v then 
			sampSendChat("/admins ")
		end	
	return true 
	end	
    if text:find("�� ������� ��������������!") then  
		if elm.boolean.auto_login.v then 
        	control_spawn = true
		end
    	return true
    end
    if text:find("�� ��� ������������ ��� �������������") then  
		if elm.boolean.auto_login.v then 
			control_spawn = false   
		end
    	return true
    end
	if text:find("���������� ��������������!") then  
		if elm.boolean.auto_login.v then  
			control_spawn = true  
		end  
		return true  
	end 
    if check_string == '������' and not isGamePaused() and not isGameWindowForeground() then  
        if elm.boolean.push_report.v then 
            showNotification("�������� ����� ������.")
        end 
    	return true
    end
end

function sampev.onTextDrawSetString(id, text) 
    if id == 2056 and elm.boolean.recon_menu.v then  
        info_to_player = atlibs.textSplit(text, "~n~")
    end
end

function playersToStreamZone()
	local peds = getAllChars()
	local streaming_player = {}
	local _, pid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	for key, v in pairs(peds) do
		local result, id = sampGetPlayerIdByCharHandle(v)
		if result and id ~= pid and id ~= tonumber(recon_id) then
			streaming_player[key] = id
		end
	end
	return streaming_player
end

function sampev.onShowTextDraw(id, data)
    if elm.boolean.recon_menu.v then 
        for _, i in pairs(ids_recon) do  
            if id == i then  
                return false  
            end 
        end
    end
end

function sampev.onSendCommand(command)
    id = string.match(command, "/re (%d+)")
    if id ~= nil and elm.boolean.recon_menu.v then  
        control_to_player = true
        if control_to_player then 
            load_recon:run()
            ATRecon.v = true  
            imgui.Process = ATRecon.v 
        end 
        recon_id = id 
    end 
    if command == "/reoff" then  
        control_to_player = false
        ATRecon.v = false  
        imgui.Process = ATRecon.v
        imgui.ShowCursor = false  
        recon_id = -1
    end 
end
-- ## ���� ��������� ������� � ������� SA:MP ## -- 

-- ## ���� ������� � ������ ��������� ���� ## --
function cmd_flood(arg)
    if arg:find('(.+) (.+)') then
        arg1, arg2 = arg:match('(.+) (.+)')
        if arg2 == '1' then
		    sampSendChat("/mute " .. arg1 .. " 120 " .. " ����/���� ")
        elseif arg2 == '2' then  
            sampSendChat("/mute " .. arg1 .. " 240 " .. " ����/���� x2")
        elseif arg2 == '3' then  
            sampSendChat("/mute " .. arg1 .. " 360 " .. " ����/���� x3")
        elseif arg2 == '4' then  
            sampSendChat("/mute " .. arg1 .. " 480 " .. " ����/���� x4")
        elseif arg2 == '5' then  
            sampSendChat("/mute " .. arg1 .. " 600 " .. " ����/���� x5")
        elseif arg2 == '6' then  
            sampSendChat("/mute " .. arg1 .. " 720 " .. " ����/���� x6")
        elseif arg2 == '7' then  
            sampSendChat("/mute " .. arg1 .. " 840 " .. " ����/���� x7")
        elseif arg2 == '8' then  
            sampSendChat("/mute " .. arg1 .. " 960 " .. " ����/���� x8")
        elseif arg2 == '9' then  
            sampSendChat("/mute " .. arg1 .. " 1080 " .. " ����/���� x9")
        elseif arg2 == '10' then  
            sampSendChat("/mute " .. arg1 .. " 1200 " .. " ����/���� x10")
        end
	elseif arg:find('(.+)') then
        sampSendChat("/mute " .. arg .. " 120 " .. " ����/���� ")
    else
        sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
        sampAddChatMessage(tag .. " �����������: /fd [IDPlayer] [~��������� (�� 2 �� 10)]", -1)
	end
end


function cmd_popr(arg)
    if arg:find('(.+) (.+)') then
        arg1, arg2 = arg:match('(.+) (.+)')
        if arg2 == '1' then
		    sampSendChat("/mute " .. arg1 .. " 120 " .. " ���������������� ")
        elseif arg2 == '2' then  
            sampSendChat("/mute " .. arg1 .. " 240 " .. " ���������������� x2")
        elseif arg2 == '3' then  
            sampSendChat("/mute " .. arg1 .. " 360 " .. " ���������������� x3")
        elseif arg2 == '4' then  
            sampSendChat("/mute " .. arg1 .. " 480 " .. " ���������������� x4")
        elseif arg2 == '5' then  
            sampSendChat("/mute " .. arg1 .. " 600 " .. " ���������������� x5")
        elseif arg2 == '6' then  
            sampSendChat("/mute " .. arg1 .. " 720 " .. " ���������������� x6")
        elseif arg2 == '7' then  
            sampSendChat("/mute " .. arg1 .. " 840 " .. " ���������������� x7")
        elseif arg2 == '8' then  
            sampSendChat("/mute " .. arg1 .. " 960 " .. " ���������������� x8")
        elseif arg2 == '9' then  
            sampSendChat("/mute " .. arg1 .. " 1080 " .. " ���������������� x9")
        elseif arg2 == '10' then  
            sampSendChat("/mute " .. arg1 .. " 1200 " .. " ���������������� x10")
        end
	elseif arg:find('(.+)') then
        sampSendChat("/mute " .. arg .. " 120 " .. " ���������������� ")
    else
        sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
        sampAddChatMessage(tag .. " �����������: /po [IDPlayer] [~��������� (�� 2 �� 10)]", -1)
	end
end

-- ## ���� ������� � ������ ������-��������� ���� ## --
function cmd_rup(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 1000 " .. " ���������� ��������� ��������. ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
	end
end

function cmd_ror(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 5000 " .. " �����������/���������� ������ ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
	end
end

function cmd_cpfd(arg)
    if arg:find('(.+) (.+)') then
        arg1, arg2 = arg:match('(.+) (.+)')
        if arg2 == '1' then
		    sampSendChat("/rmute " .. arg1 .. " 120 " .. " caps/offtop ")
        elseif arg2 == '2' then  
            sampSendChat("/rmute " .. arg1 .. " 240 " .. " caps/offtop x2")
        elseif arg2 == '3' then  
            sampSendChat("/rmute " .. arg1 .. " 360 " .. " caps/offtop x3")
        elseif arg2 == '4' then  
            sampSendChat("/rmute " .. arg1 .. " 480 " .. " caps/offtop x4")
        elseif arg2 == '5' then  
            sampSendChat("/rmute " .. arg1 .. " 600 " .. " caps/offtop x5")
        elseif arg2 == '6' then  
            sampSendChat("/rmute " .. arg1 .. " 720 " .. " caps/offtop x6")
        elseif arg2 == '7' then  
            sampSendChat("/rmute " .. arg1 .. " 840 " .. " caps/offtop x7")
        elseif arg2 == '8' then  
            sampSendChat("/rmute " .. arg1 .. " 960 " .. " caps/offtop x8")
        elseif arg2 == '9' then  
            sampSendChat("/rmute " .. arg1 .. " 1080 " .. " caps/offtop x9")
        elseif arg2 == '10' then  
            sampSendChat("/rmute " .. arg1 .. " 1200 " .. " caps/offtop x10")
        end
	elseif arg:find('(.+)') then
        sampSendChat("/rmute " .. arg .. " 120 " .. " caps/offtop ")
    else
        sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
        sampAddChatMessage(tag .. " �����������: /cp [IDPlayer] [~��������� (�� 2 �� 10)]", -1)
	end
end

function cmd_report_popr(arg)
    if arg:find('(.+) (.+)') then
        arg1, arg2 = arg:match('(.+) (.+)')
        if arg2 == '1' then
		    sampSendChat("/rmute " .. arg1 .. " 120 " .. " ���������������� ")
        elseif arg2 == '2' then  
            sampSendChat("/rmute " .. arg1 .. " 240 " .. " ���������������� x2")
        elseif arg2 == '3' then  
            sampSendChat("/rmute " .. arg1 .. " 360 " .. " ���������������� x3")
        elseif arg2 == '4' then  
            sampSendChat("/rmute " .. arg1 .. " 480 " .. " ���������������� x4")
        elseif arg2 == '5' then  
            sampSendChat("/rmute " .. arg1 .. " 600 " .. " ���������������� x5")
        elseif arg2 == '6' then  
            sampSendChat("/rmute " .. arg1 .. " 720 " .. " ���������������� x6")
        elseif arg2 == '7' then  
            sampSendChat("/rmute " .. arg1 .. " 840 " .. " ���������������� x7")
        elseif arg2 == '8' then  
            sampSendChat("/rmute " .. arg1 .. " 960 " .. " ���������������� x8")
        elseif arg2 == '9' then  
            sampSendChat("/rmute " .. arg1 .. " 1080 " .. " ���������������� x9")
        elseif arg2 == '10' then  
            sampSendChat("/rmute " .. arg1 .. " 1200 " .. " ���������������� x10")
        end
	elseif arg:find('(.+)') then
        sampSendChat("/rmute " .. arg .. " 120 " .. " ���������������� ")
    else
        sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
        sampAddChatMessage(tag .. " �����������: /rpo [IDPlayer] [~��������� (�� 2 �� 10)]", -1)
	end
end

function cmd_rm(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 300 " .. " ����������� �������. ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
	end
end

function cmd_roa(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 2500 " .. " ���/����.�������������  ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
	end
end

function cmd_report_neadekvat(arg)
    if arg:find('(.+) (.+)') then
        arg1, arg2 = arg:match('(.+) (.+)')
        if arg2 == '2' then
		    sampSendChat("/rmute " .. arg1 .. " 1800 " .. " ������������ ��������� x2")
        elseif arg2 == '3' then  
            sampSendChat("/rmute " .. arg1 .. " 3000 " .. " ������������ ��������� x3")
        elseif arg2 == '1' then  
            sampSendChat("/rmute " .. arg1 .. " 900 " .. " ������������ ���������")
        end
	elseif arg:find('(.+)') then
        sampSendChat("/rmute " .. arg .. " 900 " .. " ������������ ���������")
    else
        sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
        sampAddChatMessage(tag .. " �����������: /rnm [IDPlayer] [~��������� (�� 2-3)]", -1)
	end
end

function cmd_rok(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 400 " .. " �����������/��������. ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
	end
end

function cmd_rrz(arg)
	if #arg > 0 then 
		sampSendChat("/rmute " .. arg .. " 5000 " .. " ������ ������. �����")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
	end
end	
-- ## ���� ������� � ������ ������-��������� ���� ## --

-- ## ���� ������� � ������ offline-��������� ���� ## --
function cmd_azs(arg)
	if #arg > 0 then  
		sampSendChat("/muteakk"  .. arg .. " 600 " .. " �����.���������")
	else  
		sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
	end 
end		

function cmd_afd(arg)
	if #arg > 0 then
		sampSendChat("/muteakk " .. arg .. " 120 " .. " ����/����")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
	end
end

function cmd_apo(arg)
	if #arg > 0 then
		sampSendChat("/muteakk " .. arg .. " 120 " .. " ���������������� ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
	end
end

function cmd_am(arg)
	if #arg > 0 then
		sampSendChat("/muteakk " .. arg .. " 300 " .. " ����������� �������.")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
	end
end

function cmd_aok(arg)
	if #arg > 0 then
		sampSendChat("/muteakk " .. arg .. " 400 " .. " �����������/��������. ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
	end
end

function cmd_offline_neadekvat(arg)
    if arg:find('(.+) (.+)') then
        arg1, arg2 = arg:match('(.+) (.+)')
        if arg2 == '2' then
		    sampSendChat("/muteakk " .. arg1 .. " 1800 " .. " ������������ ��������� x2")
        elseif arg2 == '3' then  
            sampSendChat("/muteakk " .. arg1 .. " 3000 " .. " ������������ ��������� x3")
        elseif arg2 == '1' then  
            sampSendChat("/muteakk " .. arg1 .. " 900 " .. " ������������ ���������")
        end
	elseif arg:find('(.+)') then
        sampSendChat("/muteakk " .. arg .. " 900 " .. " ������������ ���������")
    else
        sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
        sampAddChatMessage(tag .. " �����������: /anm [IDPlayer] [~��������� (�� 2-3)]", -1)
	end
end


function cmd_aoa(arg)
	if #arg > 0 then
		sampSendChat("/muteakk " .. arg .. " 2500 " .. " ���/����.������������� ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
	end
end

function cmd_aor(arg)
	if #arg > 0 then
		sampSendChat("/muteakk " .. arg .. " 5000 " .. " �����������/���������� ������ ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
	end
end

function cmd_aup(arg)
	if #arg > 0 then
		sampSendChat("/muteakk " .. arg .. " 1000 " .. " ���������� ����� ������� ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
	end
end 

function cmd_aia(arg)
	if #arg > 0 then
		sampSendChat("/muteakk " .. arg .. " 2500 " .. " ������ ���� �� �������������� ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
	end
end

function cmd_akl(arg)
	if #arg > 0 then
		sampSendChat("/muteakk " .. arg .. " 3000 " .. " ������� �� ������������� ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
	end
end

function cmd_arz(arg)
	if #arg > 0 then
		sampSendChat("/muteakk " .. arg .. " 5000 " .. " ������ ������. ����� ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
	end
end	
-- ## ���� ������� � ������ offline-��������� ���� ## --

-- ## ���� ������� � ������ ��������� ������ ## -- 
function cmd_sk(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 300 " .. " Spawn Kill")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
	end
end

function cmd_dz(arg)
    if arg:find('(.+) (.+)') then
        arg1, arg2 = arg:match('(.+) (.+)')
        if arg2 == '1' then
		    sampSendChat("/jail " .. arg1 .. " 300 " .. " DM/DB in zz ")
        elseif arg2 == '2' then  
            sampSendChat("/jail " .. arg1 .. " 600 " .. " DM/DB in zz x2")
        elseif arg2 == '3' then  
            sampSendChat("/jail " .. arg1 .. " 900 " .. " DM/DB in zz x3")
        elseif arg2 == '4' then  
            sampSendChat("/jail " .. arg1 .. " 1200 " .. " DM/DB in zz x4")
        elseif arg2 == '5' then  
            sampSendChat("/jail " .. arg1 .. " 1500 " .. " DM/DB in zz x5")
        elseif arg2 == '6' then  
            sampSendChat("/jail " .. arg1 .. " 1800 " .. " DM/DB in zz x6")
        elseif arg2 == '7' then  
            sampSendChat("/jail " .. arg1 .. " 2100 " .. " DM/DB in zz x7")
        elseif arg2 == '8' then  
            sampSendChat("/jail " .. arg1 .. " 2400 " .. " DM/DB in zz x8")
        elseif arg2 == '9' then  
            sampSendChat("/jail " .. arg1 .. " 2700 " .. " DM/DB in zz x9")
        elseif arg2 == '10' then  
            sampSendChat("/jail " .. arg1 .. " 3000 " .. " DM/DB in zz x10")
        end
	elseif arg:find('(.+)') then
        sampSendChat("/jail " .. arg .. " 120 " .. " DM/DB in zz ")
    else
        sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
        sampAddChatMessage(tag .. " �����������: /dz [IDPlayer] [~��������� (�� 2 �� 10)]", -1)
	end
end

function cmd_td(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 300 " .. " DB/car in trade ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
	end
end

function cmd_jm(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 300 " .. " ��������� ������ �� ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
	end
end

function cmd_pmx(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 300 " .. " ��������� ������ ������� ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
	end
end

function cmd_skw(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 600 " .. " SK in /gw ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
	end
end

function cmd_dgw(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 500 " .. " ������������� ���������� in /gw ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
	end
end

function cmd_ngw(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 600 " .. " ������������� ����������� ������ in /gw ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
	end
end

function cmd_dbgw(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 600 " .. " ������������� ��������� in /gw ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
	end
end

function cmd_fsh(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 900 " .. " ������������� SpeedHack/FlyCar ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
	end
end

function cmd_bag(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 300 " .. " ������� ������ (deagle in car)")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
	end
end

function cmd_pk(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 900 " .. " ������������� ������ ���� ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
	end
end

function cmd_jch(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 3000 " .. " ������������� ���������� �������/�� ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
	end
end

function cmd_zv(arg)
	if #arg > 0 then
		sampSendChat("/jail " ..  arg .. " 3000 " .. " ��������������� VIP`om ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
	end
end

function cmd_sch(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 900 " .. " ������������� ����������� �������� ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
	end
end

function cmd_jcw(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 900 " .. " ������������� ClickWarp/Metla (���)")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
	end
end

function cmd_tdbz(arg)
	if #arg > 0 then  
		sampSendChat("/jail " .. arg .. " 900 " .. " �� � ������ (zz)")
	else  
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)	
	end 
end	
-- ## ���� ������� � ������ ��������� ������ ## -- 

-- ## ���� ������� � ������ offline-��������� ������ ## -- 
function cmd_asch(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 900 " .. " ������������� ����������� �������� ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
	end
end

function cmd_ajch(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 3000 " .. " ������������� ���������� �������/�� ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
	end
end

function cmd_azv(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " ..  arg .. " 3000 " .. " ��������������� VIP`om ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
	end
end

function cmd_adgw(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 500 " .. " ������������� ���������� in /gw ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
	end
end

function cmd_ask(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 300 " .. " SpawnKill ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
	end
end

function cmd_adz(arg)
    if arg:find('(.+) (.+)') then
        arg1, arg2 = arg:match('(.+) (.+)')
        if arg2 == '1' then
		    sampSendChat("/prisonakk " .. arg1 .. " 300 " .. " DM/DB in zz ")
        elseif arg2 == '2' then  
            sampSendChat("/prisonakk " .. arg1 .. " 600 " .. " DM/DB in zz x2")
        elseif arg2 == '3' then  
            sampSendChat("/prisonakk " .. arg1 .. " 900 " .. " DM/DB in zz x3")
        elseif arg2 == '4' then  
            sampSendChat("/prisonakk " .. arg1 .. " 1200 " .. " DM/DB in zz x4")
        elseif arg2 == '5' then  
            sampSendChat("/prisonakk " .. arg1 .. " 1500 " .. " DM/DB in zz x5")
        elseif arg2 == '6' then  
            sampSendChat("/prisonakk " .. arg1 .. " 1800 " .. " DM/DB in zz x6")
        elseif arg2 == '7' then  
            sampSendChat("/prisonakk " .. arg1 .. " 2100 " .. " DM/DB in zz x7")
        elseif arg2 == '8' then  
            sampSendChat("/prisonakk " .. arg1 .. " 2400 " .. " DM/DB in zz x8")
        elseif arg2 == '9' then  
            sampSendChat("/prisonakk " .. arg1 .. " 2700 " .. " DM/DB in zz x9")
        elseif arg2 == '10' then  
            sampSendChat("/prisonakk " .. arg1 .. " 3000 " .. " DM/DB in zz x10")
        end
	elseif arg:find('(.+)') then
        sampSendChat("/prisonakk " .. arg .. " 120 " .. " DM/DB in zz ")
    else
        sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
        sampAddChatMessage(tag .. " �����������: /adz [IDPlayer] [~��������� (�� 2 �� 10)]", -1)
	end
end

function cmd_atd(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 300 " .. " DB/car in trade ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
	end
end

function cmd_ajm(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 300 " .. " ��������� ������ �� ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
	end
end

function cmd_apmx(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 300 " .. " ��������� ������ ������� ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
	end
end

function cmd_askw(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 600 " .. " SK in /gw ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
	end
end

function cmd_angw(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 600 " .. " ������������� ����������� ������ in /gw ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
	end
end

function cmd_adbgw(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 600 " .. " db-����, �������� � ���/����/����� in /gw ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
	end
end

function cmd_afsh(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 900 " .. " ������������� SpeedHack/FlyCar ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
	end
end

function cmd_abag(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 300 " .. " ������� ������ (deagle in car)")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
	end
end

function cmd_apk(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 900 " .. " ������������� ������ ���� ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
	end
end

function cmd_ajcw(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 900 " .. " ������������� ClickWarp/Metla (���)")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
	end
end
-- ## ���� ������� � ������ offline-��������� ������ ## -- 

-- ## ���� ������� � ������ ��������� ���� ## -- 
function cmd_hl(arg)
	if #arg > 0 then
		sampSendChat("/ans " .. arg .. " ��������� �����, �� �������� ������� �������, � ���� ��..")
		sampSendChat("/ans " .. arg .. " ..�� �������� � ����������, �������� ������ �� ����� https://forumrds.ru")
		sampSendChat("/iban " .. arg .. " 3 " .. " �����������/��������/��� � �������")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)	
	end
end

function cmd_pl(arg)
	if #arg > 0 then
		sampSendChat("/ans " .. arg .. " ��������� �����, �� �������� ������� �������, � ���� ��..")
		sampSendChat("/ans " .. arg .. " ..�� �������� � ����������, �������� ������ �� ����� https://forumrds.ru")
		sampSendChat("/ban " .. arg .. " 7 " .. " ������� ���� �������������� ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
	end
end

function cmd_ob(arg)
	if #arg > 0 then
		sampSendChat("/ans " .. arg .. " ��������� �����, �� �������� ������� �������, � ���� ��..")
		sampSendChat("/ans " .. arg .. " ..�� �������� � ����������, �������� ������ �� ����� https://forumrds.ru")
		sampSendChat("/iban " .. arg .. " 7 " .. " ����� �������� ���� ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
	end
end 	

function cmd_gcnk(arg)
	if #arg > 0 then
		sampSendChat("/ans " .. arg .. " ��������� �����, �� �������� ������� �������, � ���� ��..")
		sampSendChat("/ans " .. arg .. " ..�� �������� � ����������, �������� ������ �� ����� https://forumrds.ru")
		sampSendChat("/iban " .. arg .. " 7 " .. " �����, ���������� ����������� ������� ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
	end
end

function cmd_menk(arg)
	if #arg > 0 then
		sampSendChat("/ans " .. arg .. " ��������� �����, �� �������� ������� �������, � ���� ��..")
		sampSendChat("/ans " .. arg .. " ..�� �������� � ����������, �������� ������ �� ����� https://forumrds.ru")
		sampSendChat("/ban " .. arg .. " 7 " .. " ���, ����������� ����������� ����� ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
	end
end

function cmd_nk(arg)
	if #arg > 0 then
		sampSendChat("/ans " .. arg .. " ��������� �����, �� �������� ������� �������, � ���� ��..")
		sampSendChat("/ans " .. arg .. " ..�� �������� � ����������, �������� ������ �� ����� https://forumrds.ru")
		sampSendChat("/ban " .. arg .. " 7 " .. " ���, ���������� ����������� ������� ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
	end
end

function cmd_bnm(arg)
	if #arg > 0 then
		sampSendChat("/ans " .. arg .. " ��������� �����, �� �������� ������� �������, � ���� ��..")
		sampSendChat("/ans " .. arg .. " ..�� �������� � ����������, �������� ������ �� ����� https://forumrds.ru")
		sampSendChat("/iban " .. arg .. " 7 " .. " ������������ ���������")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
	end
end	
-- ## ���� ������� � ������ ��������� ���� ## -- 

-- ## ���� ������� � ������ offline-��������� ���� ## --
function cmd_amenk(arg)
	if #arg > 0 then
		sampSendChat("/banakk " .. arg .. " 7 " .. " ���, ����������� ����������� ����� ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NickName ����������! ", -1)
	end
end


function cmd_ahl(arg)
	if #arg > 0 then
		sampSendChat("/offban " .. arg .. " 3 " .. " ���/��������/��� � �������")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NickName ����������! ", -1)
	end
end

function cmd_ahli(arg)
	if #arg > 0 then
		sampSendChat("/banip " .. arg .. " 3 " .. " ���/��������/��� � �������")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ IP ����������! ", -1)
	end
end

function cmd_aob(arg)
	if #arg > 0 then
		sampSendChat("/offban " .. arg .. " 7 " .. " ����� ���� ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NickName ����������! ", -1)
	end
end

function cmd_apl(arg)
	if #arg > 0 then
		sampSendChat("/offban " .. arg .. " 7 " .. " ������� �������� ��������������")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NickName ����������! ", -1)
	end
end

function cmd_ach(arg)
	if #arg > 0 then
		sampSendChat("/offban " .. arg .. " 7 " .. "  ������������� ���������� �������/�� ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NickName ����������! ", -1)
	end
end

function cmd_achi(arg)
	if #arg > 0 then
		sampSendChat("/banip " .. arg .. " 7 " .. " ���/�� (ip) ") 
	else 
		sampAddChatMessage(tag .. "�� ������ ������ IP ����������! ", -1)
	end
end

function cmd_ank(arg)
	if #arg > 0 then
		sampSendChat("/banakk " .. arg .. " 7 " .. " ���, ���������� ������������ ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NickName ����������! ", -1)
	end
end

function cmd_agcnk(arg)
	if #arg > 0 then
		sampSendChat("/banakk " .. arg .. " 7 " .. " �����, �������� ������������")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NickName ����������! ", -1)
	end
end

function cmd_agcnkip(arg)
	if #arg > 0 then
		sampSendChat("/banip " .. arg .. " 7 "  .. " �����, �������� ������������ (ip)")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ IP ����������! ", -1)
	end
end

function cmd_rdsob(arg)
	if #arg > 0 then
		sampSendChat("/banakk " .. arg .. " 30 " .. " ����� �������������/�������")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ NickName ����������! ", -1)
	end
end	

function cmd_rdsip(arg)
	if #arg > 0 then
		sampSendChat("/banip " .. arg .. " 30 " .. " ����� �������������/�������")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ IP ����������! ", -1)
	end
end	

function cmd_abnm(arg)
	if #arg > 0 then
		sampSendChat("/banakk " .. arg .. " 7 " .. " ������������ ���������")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ IP ����������! ", -1)
	end
end	
-- ## ���� ������� � ������ offline-��������� ���� ## --

-- ## ���� ������� � ������ ��������� ���� ## --
function cmd_dj(arg)
	if #arg > 0 then
		sampSendChat("/kick " .. arg .. " DM in Jail ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
	end
end

function cmd_gnk(arg)
    if arg:find('(.+) (.+)') then
        arg1, arg2 = arg:match('(.+) (.+)')
        if arg2 == '1' then
		    sampSendChat("/kick " .. arg1 .. " ������� �������. 1/3 ")
        elseif arg2 == '2' then  
            sampSendChat("/kick " .. arg1 .. " ������� �������. 2/3")
        elseif arg2 == '3' then  
            sampSendChat("/kick " .. arg1 .. " ������� �������. 3/3")
        end
	elseif arg:find('(.+)') then
        sampSendChat("/kick " .. arg .. " ������� �������. 1/3 ")
    else
        sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
        sampAddChatMessage(tag .. " �����������: /gnk [IDPlayer] [~��������� (�� 2 �� 10)]", -1)
	end
end

function cmd_cafk(arg)
	if #arg > 0 then
		sampSendChat("/kick " .. arg .. " AFK in /arena ")
	else 
		sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
	end
end
-- ## ���� ������� � ������ ��������� ���� ## --

-- ## ���� ������� � ��������������� �������� ## --
function cmd_u(arg)
	sampSendChat("/unmute " .. arg)
end  

function cmd_uu(arg)
    lua_thread.create(function()
        sampSendChat("/unmute " .. arg)
        
        sampSendChat("/ans " .. arg .. " ���������� �� ������, ��������� �����. �������� ����")
    end)
end

function cmd_uj(arg)
    lua_thread.create(function()
        sampSendChat("/unjail " .. arg)
        
        sampSendChat("/ans " .. arg .. " ���������� �� ������, ��������� �����. �������� ����")
    end)
end

function cmd_stw(arg)
	sampSendChat("/setweap " .. arg .. " 38 5000 ")
end  

function cmd_as(arg)
	sampSendChat("/aspawn " .. arg)
end

function cmd_ru(arg)
    lua_thread.create(function()
	    sampSendChat("/rmute " .. arg .. " 5 " .. "  Mistake/������")
        
	    sampSendChat("/ans " .. arg .. " ���������� �� ������, ��������� �����. �������� ����.")
    end)
end
-- ## ���� ������� � ��������������� �������� ## --

-- ## ���� ������� ��������� � ������� ## --
function loadRecon() 
    wait(3000)
    accept_load_recon = true
end

function change_position_recon()
    if elm.position.change_recon then  
        showCursor(true, false)
        local X, Y = getCursorPos()
        config.position.reX, config.position.reY = X, Y  
        if isKeyJustPressed(49) then  
            showCursor(false, false)
            showNotification("������������ ���� ������ ��������� �������.")
            elm.position.change_recon = false
            ConfigSave()
        end  
    end
end
-- ## ���� ������� ��������� � ������� ## --

-- ## ����������� �������. ����� ���. ## --
function drawAdmins()
    if elm.boolean.render_admins.v then  
        while true do
                if #admins > 0 then
                    for i = 1, #admins do
                        local admin = admins[i]
                        local text
                        if admin.prefix then
                            text = string.format("%s[%s] %s | %s ������� | %s ��������� | %s ���������.", admin.nick, admin.id, admin.prefix, admin.lvl, admin.vig, admin.rep)
                        else
                            text = string.format("%s[%s] | %s ������� | %s ��������� | %s ���������.", admin.nick, admin.id, admin.lvl, admin.vig, admin.rep)
                        end
                        text = text:gsub("\n", "")
                        renderFontDrawText(render_font, config.colours.render_admins .. text, elm.position.acX, elm.position.acY+(18)*(i+13), 0xFF9999FF)
                    end
                end
            wait(1)
        end
    end
end
-- ## ����������� �������. ����� ���. ## --

local WelcomeText = [[
    ������� ������� �����. ������� �� ��������� ������� �������! 
	{00BFFF}AdminTool [AT] {FFFFFF}������������ ��� ����, ����� ��������� ������ �������������.
	���� ����������� �� ������ ���������� ����� �������� � ������ VK:
	https://vk.com/infsy
	����� ������� �������: ���� ��������, VK: {00BFFF}https://vk.com/alfantasy

    �������� ������. 

    (!) ������ ����������� ���� ��� ���������.
]]

-- ## ���� ����������� �������, ������������� �� ������ ������ ����� AT ## -- 
function onWindowMessage(msg, wparam, lparam)
	if(msg == 0x100 or msg == 0x101) and elm.boolean.custom_tab.v then
		if wparam == VK_TAB then
			consumeWindowMessage(true, false)
		end
	end
end

function drawOnline()
    if elm.boolean.auto_online.v then 
        while true do 
            if sampIsChatInputActive() == false then  
                sampAddChatMessage(tag .. "������ ���������� AutoOnline. �������� ������.")
                wait(62000)
                sampSendChat("/online")
                wait(100)
                local c = math.floor(sampGetPlayerCount(false) / 10)
                sampSendDialogResponse(1098, 1, c - 1)
                sampCloseCurrentDialogWithButton(0)
                wait(650)
            end
            wait(1)
        end	
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
-- ## ���� ����������� �������, ������������� �� ������ ������ ����� AT ## -- 

-- ## ��������� ������������ ���������� ImGUI ## --
function imgui.OnDrawFrame()

    if elm.int.styleImGUI.v == 0 then
		imgui.SwitchContext()
        atlibs.black()
    elseif elm.int.styleImGUI.v == 1 then
		imgui.SwitchContext()
        atlibs.grey_black()
	elseif elm.int.styleImGUI.v == 2 then
		imgui.SwitchContext()
		atlibs.white()
    elseif elm.int.styleImGUI.v == 3 then
		imgui.SwitchContext()
        atlibs.skyblue()
    elseif elm.int.styleImGUI.v == 4 then
		imgui.SwitchContext()
        atlibs.blue()
    elseif elm.int.styleImGUI.v == 5 then
		imgui.SwitchContext()
        atlibs.blackblue()
    elseif elm.int.styleImGUI.v == 6 then
		imgui.SwitchContext()
        atlibs.red()
	elseif elm.int.styleImGUI.v == 7 then 
		imgui.SwitchContext()
		atlibs.blackred()
	elseif elm.int.styleImGUI.v == 8 then 
		imgui.SwitchContext()
		atlibs.brown()
	elseif elm.int.styleImGUI.v == 9 then 
		imgui.SwitchContext()
		atlibs.violet()
	elseif elm.int.styleImGUI.v == 10 then  
		imgui.SwitchContext()
		atlibs.purple2()
	elseif elm.int.styleImGUI.v == 11 then 
		imgui.SwitchContext() 
		atlibs.salat()
	elseif elm.int.styleImGUI.v == 12 then  
		imgui.SwitchContext()
		atlibs.yellow_green()
	elseif elm.int.styleImGUI.v == 13 then  
		imgui.SwitchContext()
		atlibs.banana()
	elseif elm.int.styleImGUI.v == 14 then  
		imgui.SwitchContext()
		atlibs.royalblue()
	end

    if ATMenu.v then -- �������� ���������
        
        imgui.SetNextWindowSize(imgui.ImVec2(500, 400), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), (sh / 2)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

        imgui.ShowCursor = true  

        imgui.Begin(fa.ICON_SERVER .. " [AT] AdminTool", ATMenu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.MenuBar)

        imgui.BeginMenuBar()        
            imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
            imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 10) 
            if imgui.Button(fai.ICON_FA_USER_COG, imgui.ImVec2(27,0)) then  
                menuSelect = 1 
            end; imgui.Tooltip(u8"������� ��")
            if imgui.Button(fa.ICON_FA_KEYBOARD, imgui.ImVec2(27,0)) then  
                menuSelect = 2 
            end; imgui.Tooltip(u8"�������/������� �������")
            if imgui.Button(fai.ICON_FA_BAN, imgui.ImVec2(27,0)) then  
                menuSelect = 3
            end; imgui.Tooltip(u8"������� ������ ���������")
            if imgui.Button(fai.ICON_FA_TH_LIST, imgui.ImVec2(27,0)) then  
                menuSelect = 4 
            end; imgui.Tooltip(u8"������������� ������ ��")
			if imgui.Button(fa.ICON_CALCULATOR, imgui.ImVec2(27,0)) then  
				menuSelect = 5
			end; imgui.Tooltip(u8"������ ������� ��� �������� (/ans)")
			if imgui.Button(fai.ICON_FA_TOOLS, imgui.ImVec2(27,0)) then  
				menuSelect = 6
			end; imgui.Tooltip(u8"�������������� �������")
            if imgui.Button(fa.ICON_FA_COGS, imgui.ImVec2(27,0)) then  
                menuSelect = 15 
            end; imgui.Tooltip(u8"��������� AT")
            imgui.PopStyleVar(1)
            imgui.PopStyleVar(1)
        imgui.EndMenuBar()

        if menuSelect == 0 then  
            atlibs.imgui_TextColoredRGB(WelcomeText)
        end 

        if menuSelect == 1 then  
            imgui.Columns(3, "##Functions", false)
                if imgui.Button(fai.ICON_FA_SIGN_IN_ALT .. u8' �������� ��� �������') then  
                    imgui.OpenPopup('InputPassword')
                end
                if imgui.BeginPopup('InputPassword') then  
                    imgui.Text(fa.ICON_REPLY .. u8" ������") 
                    imgui.SameLine()
                    if not show_password then
                        if imgui.InputText('##PasswordAdmin', elm.input.password, imgui.InputTextFlags.Password) then  
                            config.main.password = elm.input.password.v  
                            ConfigSave() 
                        end  
                    else 
                        if imgui.InputText('##PasswordAdmin', elm.input.password) then  
                            config.main.password = elm.input.password.v  
                            ConfigSave() 
                        end  
                    end
                    imgui.SameLine()
                    if not show_password then
                        imgui.Text(fai.ICON_FA_EYE_SLASH) 
                        if imgui.IsItemClicked() then  
                            show_password = true
                        end
                    else 
                        imgui.Text(fai.ICON_FA_EYE) 
                        if imgui.IsItemClicked() then  
                            show_password = false
                        end
                    end
                    imgui.SameLine()
                    if imgui.Button(fa.ICON_REFRESH) then  
                        elm.input.password.v = ''
                        config.main.password = elm.input.password.v  
                        ConfigSave() 
                    end 
                    if imgui.ToggleButton(u8'��������� ������� ��������������� �����', elm.boolean.auto_login) then  
                        config.main.auto_login = elm.boolean.auto_login.v  
                        ConfigSave()
                    end; imgui.Tooltip(u8"��� ����� �� ������ � ������� 15-�� ������ ���������� ���� ��� �������.")
					if imgui.CollapsingHeader(u8'���� A.������ ��� �����') then 
						if imgui.ToggleButton('/aclist', elm.boolean.aclist_alogin) then  
							config.main.aclist_alogin = elm.boolean.aclist_alogin.v  
							ConfigSave()
						end  
						if imgui.ToggleButton('/ears', elm.boolean.ears_alogin) then  
							config.main.ears_alogin = elm.boolean.ears_alogin.v  
							ConfigSave()
						end  
						if imgui.ToggleButton('/agm', elm.boolean.agm_alogin) then  
							config.main.agm_alogin = elm.boolean.agm_alogin.v
							ConfigSave()
						end  
					end; imgui.Tooltip(u8"�������, ����������� �������� ������������ ���������������� ������� ����� ����� ��� �������.")
                    imgui.EndPopup()
                end
                if imgui.Button(fa.ICON_USER .. u8" ������ /admins") then  
                    imgui.OpenPopup('RenderAdmins')
                end  
                if imgui.BeginPopup('RenderAdmins') then  
                    imgui.Text(u8"��������� ������� �������")
                    imgui.SameLine()
                    if imgui.ToggleButton('##OnRenderAdmins', elm.boolean.render_admins) then  
                        config.main.render_admins = elm.boolean.render_admins.v 
                        ConfigSave()
                    end  
					imgui.Text(u8"��������� ������������� ������")
					imgui.SameLine()
					if imgui.ToggleButton('##Imgui', elm.boolean.render_admins_imgui) then  
						config.main.render_admins_imgui = elm.boolean.render_admins_imgui.v  
						ConfigSave()
					end
                    if imgui.Button(fa.ICON_FA_COGS  .. u8" ��������� ������� �������") then  
                        render_admin.X = elm.position.acX; render_admin.Y = elm.position.acY
                        render_admin.set_position = true 
                    end
                    imgui.Text(u8"�������� ����� ��� ������ /admins: ")
                    if imgui.ColorEdit3("##SetAdminColor", set_color_float3) then  
                        clr = atlibs.join_argb(0, set_color_float3.v[1] * 255, set_color_float3.v[2] * 255, set_color_float3.v[3] * 255)
                    end
                    if imgui.Button(u8"���������") then  
						if clr then 
                        	config.colours.render_admins = ('{%06X}'):format(clr)
						end
                        showNotification("��������� ����� ���� ���������.")
                        ConfigSave()
                    end
                    imgui.EndPopup()
                end 
				if automute_res then  
					automute.ActiveAutoMute()
				end
            imgui.NextColumn()
                imgui.Text(fa.ICON_BELL .. u8" ����.������"); imgui.Tooltip(u8"�������� ����������� �� ��������� �������")
                imgui.SameLine()
                if imgui.ToggleButton('##Push_Report', elm.boolean.push_report) then  
                    config.main.push_report = elm.boolean.push_report.v  
                    ConfigSave()  
                end
                imgui.Text(fai.ICON_FA_PLAY .. u8' ����-������'); imgui.Tooltip(u8"������������� ������ /online ������ 60 ������.")
                imgui.SameLine()
                if imgui.ToggleButton('##AutoOnline', elm.boolean.auto_online) then  
                    config.main.auto_online = elm.boolean.auto_online.v  
                    ConfigSave()
                    send_online:run()
                end
            imgui.NextColumn()
                imgui.Text(fa.ICON_OBJECT_GROUP .. u8" ��������� TAB"); imgui.Tooltip(u8"��������� TAB, ���������� �� ���� ImGUI.")
                imgui.SameLine()
                if imgui.ToggleButton('##CustomScoreboard', elm.boolean.custom_tab) then 
                    config.main.custom_tab = elm.boolean.custom_tab.v  
                    ConfigSave() 
                end
                imgui.Text(fa.ICON_ADDRESS_CARD .. u8" ��������� �����"); imgui.Tooltip(u8"��������� �����-����, ������������ �� ���������� ImGUI. \n ����� ���� ������������� �����, ��������������� �������")
                imgui.SameLine()
                if imgui.ToggleButton('##ReconMenu', elm.boolean.recon_menu) then  
                    config.main.recon_menu = elm.boolean.recon_menu.v  
                    ConfigSave()
                end
        end

        if menuSelect == 2 then  
            imgui.Text(u8"����� ����� ��������� ���� ������� ������� ��� �������� �������������� � �����, �� � �.�.")
            imgui.Text(u8"������� �������: ")
            imgui.SameLine()
            imgui.Text(atlibs.getDownKeysText())
            imgui.Separator()
            imgui.Text(u8"���������/���������� WallHack:  ")
            imgui.SameLine()
            if tonumber(config.keys.WallHack) then  
                imgui.Text(tostring(config.keys.WallHack))
            else
                imgui.Text(config.keys.WallHack)
            end
            imgui.SameLine()
            imgui.SetCursorPosX(imgui.GetWindowWidth() - 200)
            if imgui.Button(u8"�������� ##1", imgui.ImVec2(75,0)) then  
                config.keys.WallHack = atlibs.getDownKeysText()
                ConfigSave()
            end
            imgui.SameLine()
            if imgui.Button(u8"�������� ##1") then  
                config.keys.WallHack = "None"
                ConfigSave()
            end
            imgui.Separator()
            imgui.Text(u8"�������� ���������� AT:  ")
            imgui.SameLine()
            if tonumber(config.keys.GUI) then  
                imgui.Text(tostring(config.keys.GUI))
            else 
                imgui.Text(config.keys.GUI)
            end  
            imgui.SameLine()
            imgui.SetCursorPosX(imgui.GetWindowWidth() - 200)
            if imgui.Button(u8"�������� ##2", imgui.ImVec2(75,0)) then  
                config.keys.GUI = atlibs.getDownKeysText()
                ConfigSave()
            end  
            imgui.SameLine()
            if imgui.Button(u8"�������� ##2") then  
                config.keys.GUI = "None"
                ConfigSave()
            end
            imgui.Separator()
            imgui.Text(u8"�������� /ans:  ")
            imgui.SameLine()
            if tonumber(config.keys.OpenReport) then  
                imgui.Text(tostring(config.keys.OpenReport))
            else 
                imgui.Text(config.keys.OpenReport)
            end  
            imgui.SameLine()
            imgui.SetCursorPosX(imgui.GetWindowWidth() - 200)
            if imgui.Button(u8"�������� ##3", imgui.ImVec2(75,0)) then  
                config.keys.OpenReport = atlibs.getDownKeysText()
                ConfigSave()
            end  
            imgui.SameLine()
            if imgui.Button(u8"�������� ##3") then  
                config.keys.OpenReport = "None"
                ConfigSave()
            end
            imgui.Separator()
            imgui.Text(u8"������ /online:  ")
            imgui.SameLine()
            if tonumber(config.keys.GiveOnline) then  
                imgui.Text(tostring(config.keys.GiveOnline))
            else 
                imgui.Text(config.keys.GiveOnline)
            end  
            imgui.SameLine()
            imgui.SetCursorPosX(imgui.GetWindowWidth() - 200)
            if imgui.Button(u8"�������� ##4", imgui.ImVec2(75,0)) then  
                config.keys.GiveOnline = atlibs.getDownKeysText()
                ConfigSave()
            end  
            imgui.SameLine()
            if imgui.Button(u8"�������� ##4") then  
                config.keys.GiveOnline = "None"
                ConfigSave()
            end
        end

        if menuSelect == 3 then  
            imgui.Text(u8"����� ������� ������������ ������� ��� ���������� ������ ���������. \n������ ������� ����������� �� ������� �������� �������. \n����� �����, ����� ����������� ��� ��������� �������, ������������ � ��."); imgui.Separator();
            if imgui.TreeNode(u8"��������� � �������") then 
                if imgui.TreeNode("Ban") then  
					imgui.Text(u8"/ch [ID] - ��� �� ����")
					imgui.Text(u8"/pl [ID] - ��� �� ������� ���� ������ ")
					imgui.Text(u8"/nk [ID] - ��� �� ��� � �����/���������")
					imgui.Text(u8"/gcnk [ID] - ��� �� �������� ����� � �����/���������")
					imgui.Text(u8"/brekl [ID] - ��� �� ������� | for 18 lvl ")
					imgui.Text(u8"/hl [ID] - ��� �� ��� � �������")
					imgui.Text(u8"/ob [ID] - ��� �� ����� ����")
					imgui.Text(u8"/menk [ID] - ��� �� ������.����� � ����")
					imgui.Text(u8"/bnm [ID] - ��� �� ����������")
					imgui.Text(u8"/bosk [ID] - ��� �� ��� ������� | for 18 lvl ")
                    imgui.TreePop()
                end
                if imgui.TreeNode("Jail") then  
					imgui.Text(u8"/sk [ID] - jail �� SK in zz")
					imgui.Text(u8"/dz [ID] [��������� �� 2 �� 10] - jail �� DM/DB in zz")
					imgui.Text(u8"/td [ID] - jail �� DB/car in /trade")
					imgui.Text(u8"/tdbz [ID] - jail �� DB � ������ � ��")
					imgui.Text(u8"/fsh [ID] - /jail �� SH and FC")
					imgui.Text(u8"/jm [ID] - jail �� ��������� ������ �����������.")
					imgui.Text(u8"/bag [ID] - jail �� ������")
					imgui.Text(u8"/pk [ID] - jail �� ������ ���")
					imgui.Text(u8"/zv [ID] - jail �� �����.���")
					imgui.Text(u8"/skw [ID] - jail �� SK �� /gw")
					imgui.Text(u8"/ngw [ID] - jail �� ������������� ������.������ �� /gw")
					imgui.Text(u8"/dbgw [ID] - jail �� DB �������� �� /gw")
                    imgui.Text(u8"/jch [ID] - jail �� ����")
					imgui.Text(u8"/pmx [ID] - jail �� ��������� ������ �������")
					imgui.Text(u8"/dgw [ID] - jail �� ��������� �� /gw")
					imgui.Text(u8"/sch [ID] - jail �� ����������� �������")
                    imgui.TreePop()
                end
                if imgui.TreeNode("Mute") then  
					imgui.Text(u8"/m [ID] - ��� �� ��� | /rm - ��� �� ��� � ������ ")
					imgui.Text(u8"/ok [ID] - ��� �� �����������/��������")
					imgui.Text(u8"/fd [ID] [��������� �� 2 �� 10] - ��� �� ����/���� x1-x10")
					imgui.Text(u8"/po [ID] [��������� �� 2 �� 10]- ��� �� ���������� x1-x10")
					imgui.Text(u8"/oa [ID] - ��� �� ���.��� ")
					imgui.Text(u8"/roa [ID] - ��� �� ���.��� � ������")
					imgui.Text(u8"/up [ID] - ��� �� ����.�������")
					imgui.Text(u8"/rup [ID] - ��� �� ����.������� � ������")
					imgui.Text(u8"/ia [ID] - ��� �� ������ ���� �� ���")
					imgui.Text(u8"/kl [ID] - ��� �� ������� �� ���")
					imgui.Text(u8"/nm [ID] [��������� �� 2 �� 3] - ��� �� ���������. ")
					imgui.Text(u8"/rnm [ID] [��������� �� 2 �� 3] - ��� �� ��������� � ���.")
					imgui.Text(u8"/or [ID] - ��� �� ��� ���")
					imgui.Text(u8"/rz [ID] - ������ ������.�����")
					imgui.Text(u8"/zs [ID] - ��������������� ���������")
					imgui.Text(u8"/ror [ID] - ��� �� ��� ��� � ������")
					imgui.Text(u8"/cp [ID] [��������� �� 2 �� 10] - ����/������ � ������ x1-x10")
					imgui.Text(u8"/rpo [ID] [��������� �� 2 �� 10] - ���������� � ������ x1-x10")
					imgui.Text(u8"/rkl [ID] - ������� �� ��� � ������")
					imgui.Text(u8"/rrz [ID] - ������ ������.����� � ������")
                    imgui.TreePop()
                end
                if imgui.TreeNode("Kick") then  
                    imgui.Text(u8"/dj [ID] - ��� �� dm in jail")
					imgui.Text(u8"/gnk [ID] [�� 1 �� 3] - ��� �� ��������� � ����. \n     ������ �������� �������� �� ���������� ����� � ������������.")
					imgui.Text(u8"/cafk [ID] - ��� �� ��� �� �����")
                    imgui.TreePop()
                end
                imgui.TreePop()
            end

            if imgui.TreeNode(u8"��������� � ��������") then  
                if imgui.TreeNode("Ban") then  
					imgui.Text(u8"/apl [NickName] - ��� �� ������� ��� ������")
					imgui.Text(u8"/ach [NickName] (/achi [IP]) - ��� �� ���� (ip)")
					imgui.Text(u8"/ank [NickName] - ��� �� ��� � ���/����")
					imgui.Text(u8"/agcnk [NickName] - ��� �� �������� ����� � ���/����")
					imgui.Text(u8"/agcnkip [NickName] - ��� �� IP �� �������� ����� � ���/����")
					imgui.Text(u8"/okpr/ip [NickName] - ��� �������")
					imgui.Text(u8"/svoakk/ip [NickName] - ��� �� ���/IP �� �������")
					imgui.Text(u8"/ahl [NickName] (/achi) [IP] - ��� �� ��� � ������� (ip)")
					imgui.Text(u8"/aob [NickName] - ��� �� ����� ����")
					imgui.Text(u8"/rdsob [NickName] - ��� �� ����� ���/�������")
					imgui.Text(u8"/rdsip [NickName] - ��� �� IP �� ����� ���/�������")
					imgui.Text(u8"/amenk [NickName] - ��� �� ������.����� � ����")
					imgui.Text(u8"/abnm  [NickName] - ��� �� ����������")
                    imgui.TreePop()
                end
                if imgui.TreeNode("Jail") then  
					imgui.Text(u8"/ask [NickName] - jail �� SK in zz")
					imgui.Text(u8"/adz [NickName] [��������� �� 2 �� 10] - jail �� DM/DB in zz")
					imgui.Text(u8"/atd [NickName] - jail �� DB/CAR in trade")
					imgui.Text(u8"/afsh [NickName] - jail �� SH ans FC")
					imgui.Text(u8"/ajm [NickName] - jail �� �����.������ ��")
					imgui.Text(u8"/abag [NickName] - jail �� ������")
					imgui.Text(u8"/apk [NickName] - jail �� ������ ���")
					imgui.Text(u8"/azv [NickName] - jail �� �����.���")
					imgui.Text(u8"/askw [NickName] - jail �� SK �� /gw")
					imgui.Text(u8"/angw [NickName] - ���.������.������ �� /gw")
					imgui.Text(u8"/adbgw [NickName] - jail �� DB ���� �� /gw")
					imgui.Text(u8"/ajch [NickName] - jail �� ����")
					imgui.Text(u8"/apmx [NickName] - jail �� ������.������")
					imgui.Text(u8"/adgw [NickName] - jail �� ��������� �� /gw")
					imgui.Text(u8"/asch [NickName] - jail �� ����������� �������")
                    imgui.TreePop()
                end
                if imgui.TreeNode("Mute") then  
					imgui.Text(u8"/am [NickName] - ��� �� ��� ")
					imgui.Text(u8"/aok [NickName] - ��� �� ��� ")
					imgui.Text(u8"/afd [NickName] - ��� �� ����/����")
					imgui.Text(u8"/apo [NickName]  - ��� �� ����������")
					imgui.Text(u8"/aoa [NickName] - ��� �� ���.���")
					imgui.Text(u8"/aup [NickName] - ��� �� ���������� ��������")
					imgui.Text(u8"/anm [NickName] [��������� �� 2 �� 3]- ��� �� ����������")
					imgui.Text(u8"/aor [NickName] - ��� �� ���/���� ������")
					imgui.Text(u8"/aia [NickName] - ��� �� ������ ���� �� ���")
					imgui.Text(u8"/akl [NickName] - ��� �� ������� �� ���")
					imgui.Text(u8"/arz [NickName] - ��� �� ������ ������.�����")
                    imgui.TreePop()
                end
                imgui.TreePop()
            end

            if imgui.TreeNode(u8"�������������� ������� AT") then  
                imgui.Text(u8"/u [ID] - ������� ������")
                imgui.Text(u8"/uu [ID] - ������ � ���������� � /ans")
                imgui.Text(u8"/uj [ID] - ����������� ������")
                imgui.Text(u8"/as [ID] - ��������� ������")
                imgui.Text(u8"/ru [ID] - ������ �������")
                imgui.Text(u8"/rcl - ������� ���� (�� /cc, ��������� ��� ���)")
                imgui.Text(u8"/spp [ID] - ���������� ���� ������� � ���� ������ *")
                imgui.Text(u8"     * ���� ������ - ��� �������, � ������� ���� ����� �������")
                imgui.Text(u8"/aheal [ID] - �������� ������")
                imgui.Text(u8"/akill [ID] - ����� ������")
                imgui.TreePop()
            end
        end

        if menuSelect == 4 then  
            showFlood_ImGUI()
        end

		if menuSelect == 5 then  
			imgui.Text(u8"����� ����� ������� ������ ��� ������ �� �������.")
			imgui.Text(u8"� ������ ������, �������� '����������� ������' � ��� ��� �����.")
			imgui.Text(u8"����������. ����� ��������� �������� � ���������� ��� �������, \n���������� ������������� ������� :) (ALT+R)")
			imgui.Separator()
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 2)
			imgui.Text("  ")
			if imgui.Button(u8'�������') then
				imgui.OpenPopup(u8'OpenBinderReports')
			end
			imgui.Text("  ")

			if #configReports.bind_name > 0 then  
				for key_bind, name_bind in pairs(configReports.bind_name) do  
					imgui.Button(name_bind..'##'..key_bind)
					imgui.SameLine()
					if imgui.Button(fai.ICON_FA_EDIT.."##"..key_bind, imgui.ImVec2(27,0)) then  
						EditOldBind = true
						getpos = key_bind
						local returnwrapped = tostring(configReports.bind_text[key_bind]):gsub('~', '\n')
						elm.binder.text.v = returnwrapped
						elm.binder.name.v = tostring(configReports.bind_name[key_bind])
						elm.binder.delay.v = tostring(configReports.bind_delay[key_bind])
						imgui.OpenPopup(u8'OpenBinderReports')
					end 
					imgui.SameLine()
					if imgui.Button(fai.ICON_FA_TRASH.."##"..key_bind, imgui.ImVec2(27,0)) then  
						sampAddChatMessage(tag .. '���� "' ..u8:decode(configReports.bind_name[key_bind])..'" ������!', -1)
						table.remove(configReports.bind_name, key_bind)
						table.remove(configReports.bind_text, key_bind)
						table.remove(configReports.bind_delay, key_bind)
						inicfg.save(configReports, directReports)
					end  
				end  
			else  
				imgui.Text(u8('����� ���� ����� :( ��������� ���������, �������� �����...'))
			end  
			if imgui.BeginPopupModal(u8'OpenBinderReports', false, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
				imgui.BeginChild("##EditBinder", imgui.ImVec2(600, 225), true)
				imgui.Text(u8'�������� �����:'); imgui.SameLine()
				imgui.PushItemWidth(130)
				imgui.InputText("##binder_name", elm.binder.name)
				imgui.PopItemWidth()
				imgui.PushItemWidth(100)
				imgui.Separator()
				imgui.Text(u8'����� �����:')
				imgui.PushItemWidth(300)
				imgui.InputTextMultiline("##BinderS", elm.binder.text, imgui.ImVec2(-1, 110))
				imgui.PopItemWidth()
		
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 100)
				if imgui.Button(u8'�������##bind1', imgui.ImVec2(100,30)) then
					elm.binder.name.v, elm.binder.text.v, elm.binder.delay.v = '', '', "2500"
					imgui.CloseCurrentPopup()
				end
				imgui.SameLine()
				if #elm.binder.name.v > 0 and #elm.binder.text.v > 0 then
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 1.01)
					if imgui.Button(u8'���������##bind1', imgui.ImVec2(100,30)) then
						if not EditOldBind then
							local refresh_text = elm.binder.text.v:gsub("\n", "~")
							table.insert(configReports.bind_name, elm.binder.name.v)
							table.insert(configReports.bind_text, refresh_text)
							table.insert(configReports.bind_delay, elm.binder.delay.v)
							if inicfg.save(configReports, directReports) then
								sampAddChatMessage(tag .. '���� "' ..u8:decode(elm.binder.name.v).. '" ������� ������!', -1)
								elm.binder.name.v, elm.binder.text.v, elm.binder.delay.v = '', '', "0"
							end
								imgui.CloseCurrentPopup()
							else
								local refresh_text = elm.binder.text.v:gsub("\n", "~")
								table.insert(configReports.bind_name, getpos, elm.binder.name.v)
								table.insert(configReports.bind_text, getpos, refresh_text)
								table.insert(configReports.bind_delay, getpos, elm.binder.delay.v)
								table.remove(configReports.bind_name, getpos + 1)
								table.remove(configReports.bind_text, getpos + 1)
								table.remove(configReports.bind_delay, getpos + 1)
							if inicfg.save(configReports, directReports) then
								sampAddChatMessage(tag .. '���� "' ..u8:decode(elm.binder.name.v).. '" ������� ��������������!', -1)
								elm.binder.name.v, elm.binder.text.v, elm.binder.delay.v = '', '', "0"
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

		if menuSelect == 6 then  
			if plugins_main_res then  
				plugin.ActiveATChat()
			end
		end

        if menuSelect == 15 then  
            imgui.PushItemWidth(130) if imgui.Combo("##imguiStyle", elm.int.styleImGUI, colorsImGui) then config.main.styleImGUI = elm.int.styleImGUI.v ConfigSave() end imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8" - ����� ���� ") 
            imgui.Separator()
            imgui.PushItemWidth(200)
            if imgui.InputInt('##sizeFontForRenders', elm.int.font) then 
                render_font = renderCreateFont("Arial", tonumber(elm.int.font.v), fflags.BOLD + fflags.SHADOW)
                config.main.font = elm.int.font.v 
                ConfigSave()
            end; imgui.PopItemWidth(); imgui.SameLine(); imgui.Text(u8" - �������� ������� ������ ��������"); imgui.Tooltip(u8"������ ����� �� ���� �������� ������ ��� ������������ ��������.")
			elm.binder.prefix.v = configReports.main.prefix_for_answer 
			imgui.Separator()
			imgui.Text(u8"������� ��� ������ � /ans: ")
			if imgui.InputText("##EditPrefixForAnswer", elm.binder.prefix) then  
				configReports.main.prefix_for_answer = elm.binder.prefix.v  
				inicfg.save(configReports, directReports)
			end
        end
        
        imgui.End()
    end

	if ATAdmins.v then -- ������ /admins � ImGUI
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1))
		imgui.SetNextWindowSize(imgui.ImVec2(500, 500), imgui.Cond.FirstUseEver)

		imgui.Begin("##RenderAdmins", false, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize)

			if #admins > 0 then  
				for i = 1, #admins do 
					local admin = admins[i]
					local text  
					if admin.prefix then  
						text = string.format("%s[%s] %s | %s ������� | %s ��������� | %s ���������.", admin.nick, admin.id, admin.prefix, admin.lvl, admin.vig, admin.rep)
					else 
						text = string.format("%s[%s] | %s ������� | %s ��������� | %s ���������.", admin.nick, admin.id, admin.lvl, admin.vig, admin.rep)
					end  
					text = text:gsub("\n", "")
					imgui.Text(u8(text))
				end 
			end
		imgui.End()
	end 
    
    if ATRecon.v then -- Custom Recon-Menu
        if control_to_player then  
            imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 1.06), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1))
            imgui.SetNextWindowSize(imgui.ImVec2(580, 65), imgui.Cond.FirstUseEver)
            
            imgui.LockPlayer = false

            imgui.Begin("##ForRecon", false, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize)

            if imgui.Button(fa.ICON_ARROW_LEFT .. u8" BackID") then  
                lua_thread.create(function()
                    wait(1)
                    sampSetChatInputEnabled(true)
                    sampSetChatInputText("/re " .. recon_id-1)
                    setVirtualKeyDown(VK_RETURN)
                end)
            end
            imgui.SameLine()
            if imgui.Button(u8"����������") then  
                sampSendChat("/aspawn " .. recon_id)
            end 
            imgui.SameLine()
            if imgui.Button(u8"��������") then  
                sampSendClickTextdraw(156)
            end
            imgui.SameLine()
            if imgui.Button(u8"��������") then  
                sampSendChat("/slap " .. recon_id)
            end
            imgui.SameLine()
            if imgui.Button(u8"����������/�����������") then  
                sampSendChat("/freeze " .. recon_id)
            end
            imgui.SameLine()
            if imgui.Button(u8"�����") then
                sampSendChat("/reoff ")
                control_to_player = false
                ATRecon.v = false  
                imgui.Process = ATRecon.v
                imgui.ShowCursor = false  
            end
            imgui.SameLine()
            if imgui.Button(u8"NextID " .. fa.ICON_ARROW_RIGHT) then  
                lua_thread.create(function()
                    wait(1)
                    sampSetChatInputEnabled(true)
                    sampSetChatInputText("/re " .. recon_id+1)
                    setVirtualKeyDown(VK_RETURN)
                end)
            end
            imgui.SetCursorPosX(imgui.GetWindowWidth() - 400)
            if imgui.Button(u8"��������") then  
                select_recon = 1 
                recon_punish = 1
            end
            imgui.SameLine()
            if imgui.Button(u8"��������") then  
                select_recon = 1
                recon_punish = 2
            end
            imgui.SameLine()
            if imgui.Button(u8"�������") then  
                select_recon = 1
                recon_punish = 3
            end


            imgui.End()
            if right_recon.v then 
                imgui.SetNextWindowPos(imgui.ImVec2(config.position.reX, config.position.reY), imgui.Cond.FirsUseEver, imgui.ImVec2(0.5, 0.5))
                imgui.SetNextWindowSize(imgui.ImVec2(255, sh/2.15), imgui.Cond.FirstUseEver)

                imgui.Begin(u8"���������� �� ������", nil, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.MenuBar)
                if accept_load_recon then 
                        imgui.BeginMenuBar()
                            imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
                            imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 10) 
                            if imgui.Button(fai.ICON_FA_USER_CHECK, imgui.ImVec2(27,0)) then  
                                select_recon = 0
                            end
                            if imgui.Button(fai.ICON_FA_BAN, imgui.ImVec2(27,0)) then  
                                select_recon = 1 
                            end
                            if imgui.Button(u8"�������� �������") then  
                                elm.position.change_recon = true; sampAddChatMessage(tag .. "��� ���������� �������, ������� ������ <1> �� ����������.")
                            end 
                            imgui.PopStyleVar(1)
                            imgui.PopStyleVar(1)
                        imgui.EndMenuBar()
                            if select_recon == 0 then 
                                recon_nick = sampGetPlayerNickname(recon_id)
                                imgui.Text(u8"�����: ")
                                imgui.Text(recon_nick)
                                if imgui.IsItemClicked() then  
                                    imgui.LogToClipboard()
                                    imgui.LogText(recon_nick)
                                    imgui.LogFinish()
                                end
                                imgui.SameLine()
                                imgui.Text("[" .. recon_id .. "]")
                                imgui.Separator()
                                for key, v in pairs(info_to_player) do 
                                    if key == 1 then  
                                        imgui.Text(u8:encode(recon_info[1]) .. " " .. info_to_player[1])
                                        imgui.BufferingBar(tonumber(info_to_player[1])/100, imgui.ImVec2(imgui.GetWindowWidth()-10, 10), false)
                                    end
                                    if key == 2 and tonumber(info_to_player[2]) ~= 0 then
                                        imgui.Text(u8:encode(recon_info[2]) .. " " .. info_to_player[2])
                                        imgui.BufferingBar(tonumber(info_to_player[2])/100, imgui.ImVec2(imgui.GetWindowWidth()-10, 10), false)
                                    end
                                    if key == 3 and tonumber(info_to_player[3]) ~= -1 then
                                        imgui.Text(u8:encode(recon_info[3]) .. " " .. info_to_player[3])
                                        imgui.BufferingBar(tonumber(info_to_player[3])/1000, imgui.ImVec2(imgui.GetWindowWidth()-10, 10), false)
                                    end
                                    if key == 4 then
                                        imgui.Text(u8:encode(recon_info[4]) .. " " .. info_to_player[4])
                                        local speed, const = string.match(info_to_player[4], "(%d+) / (%d+)")
                                        if tonumber(speed) > tonumber(const) then
                                            speed = const
                                        end
                                        imgui.BufferingBar((tonumber(speed)*100/tonumber(const))/100, imgui.ImVec2(imgui.GetWindowWidth()-10, 10), false)
                                    end
                                    if key ~= 1 and key ~= 2 and key ~= 3 and key ~= 4 then
                                        imgui.Text(u8:encode(recon_info[key]) .. " " .. info_to_player[key])
                                    end
                                end
                                imgui.Separator()
                                imgui.Text(u8"������ � ���� ������: ")
                                local id_to_stream = playersToStreamZone()
                                if #id_to_stream > 0 then 
                                    for _, v in pairs(id_to_stream) do 
                                        if imgui.Button(" - " .. sampGetPlayerNickname(v) .. "[" .. v .. "]", imgui.ImVec2(-0.1, 0)) then  
                                            lua_thread.create(function()
                                                wait(1)
                                                sampSetChatInputEnabled(true)
                                                sampSetChatInputText("/re " .. v)
                                                setVirtualKeyDown(VK_RETURN)
                                            end)
                                        end
                                    end
                                else
                                    imgui.Text(u8"����� ������ ��� ������ �����...")
                                end
                            end 
                            if select_recon == 1 then 
                                if recon_punish == 0 then  
                                    imgui.Text(u8"�������� � ���� ��������\n������ ���������.")
                                end 
                                if recon_punish == 1 then  
                                    imgui.InputText(u8'�������', elm.input.set_punish_in_recon) 
                                    imgui.InputText(u8'�����', elm.input.set_time_punish_in_recon)
                                    if imgui.Button(u8"������ ���������") then 
                                        if #elm.input.set_punish_in_recon.v > 0 and #elm.input.set_time_punish_in_recon.v then 
                                            sampSendChat("/jail " .. recon_id .. " " .. elm.input.set_time_punish_in_recon.v .. " " .. elm.input.set_punish_in_recon.v)
                                            elm.input.set_time_punish_in_recon.v = ""
                                            elm.input.set_punish_in_recon.v = ""
                                            sampSendChat("/reoff ")
                                            recon_id = -1
                                        end
                                    end
                                end 
                                if recon_punish == 2 then  
                                    imgui.InputText(u8'�������', elm.input.set_punish_in_recon) 
                                    imgui.InputText(u8'�����', elm.input.set_time_punish_in_recon)
                                    if imgui.Button(u8"������ ���������") then 
                                        if #elm.input.set_punish_in_recon.v > 0 and #elm.input.set_time_punish_in_recon.v then 
                                            sampSendChat("/ban " .. recon_id .. " " .. elm.input.set_time_punish_in_recon.v .. " " .. elm.input.set_punish_in_recon.v)
                                            elm.input.set_time_punish_in_recon.v = ""
                                            elm.input.set_punish_in_recon.v = ""
                                            sampSendChat("/reoff ")
                                            recon_id = -1
                                        end
                                    end
                                end 
                                if recon_punish == 3 then  
                                    imgui.InputText(u8'�������', elm.input.set_punish_in_recon) 
                                    if imgui.Button(u8"������ ���������") then 
                                        if #elm.input.set_punish_in_recon.v > 0 then 
                                            sampSendChat("/kick " .. recon_id .. " " .. elm.input.set_punish_in_recon.v)
                                            elm.input.set_punish_in_recon.v = ""
                                            sampSendChat("/reoff ")
                                            recon_id = -1
                                        end
                                    end
                                end 
                            end
                else 
                    imgui.SetCursorPosX(imgui.GetWindowWidth()/2.3)
                    imgui.SetCursorPosY(imgui.GetWindowHeight()/2.3)
                    imgui.Spinner(20, 7)
                end
                imgui.End()
            end
        end 
    end
	if ATPlayerStream.v then  
		imgui.SetNextWindowPos(imgui.ImVec2(sh / 2, sw / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(300, 200), imgui.Cond.FirstUseEver)

		imgui.Begin("##Replace", ATPlayerStream, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
		if imgui.Button(u8"����� �������") then  
			
		end
		imgui.End()
	end
end
-- ## ��������� ������������ ���������� ImGUI ## --


-- ## ���� ���������� �� �������� ����������� KillChat ## --
function sampev.onPlayerDeathNotification(killerId, killedId, reason)
	local kill = ffi.cast('struct stKillInfo*', sampGetKillInfoPtr())
	local _, myid = sampGetPlayerIdByCharHandle(playerPed)

	killer,killed,reasonkill = killerId,killedId,reason

	local n_killer = ( sampIsPlayerConnected(killerId) or killerId == myid ) and sampGetPlayerNickname(killerId) or nil
	local n_killed = ( sampIsPlayerConnected(killedId) or killedId == myid ) and sampGetPlayerNickname(killedId) or nil
	lua_thread.create(function()
		wait(0)
		if n_killer then kill.killEntry[4].szKiller = ffi.new('char[25]', ( n_killer .. '[' .. killerId .. ']' ):sub(1, 24) ) end
		if n_killed then kill.killEntry[4].szVictim = ffi.new('char[25]', ( n_killed .. '[' .. killedId .. ']' ):sub(1, 24) ) end
	end)
end
-- ## ���� ���������� �� �������� ����������� KillChat ## --

-- ## ���� �������, ���������� �� ������������ ����� ������������ �������� ImGUI ��� ����������� �� ��������� ������ ## --
function showFlood_ImGUI()
    local colours_mess = [[
    0 - {FFFFFF}�����, {FFFFFF}1 - {000000}������, {FFFFFF}2 - {008000}�������, {FFFFFF}3 - {80FF00}������-�������
    4 - {FF0000}�������, {FFFFFF}5 - {0000FF}�����, {FFFFFF}6 - {FDFF00}������, {FFFFFF}7 - {FF9000}���������
    8 - {B313E7}����������, {FFFFFF}9 - {49E789}���������, {FFFFFF}10 - {139BEC}�������
    11 - {2C9197}�����-�������, {FFFFFF}12 - {DDB201}�������, {FFFFFF}13 - {B8B6B6}�����, {FFFFFF}14 - {FFEE8A}������-������
    15 - {FF9DB6}�������, {FFFFFF}16 - {BE8A01}����������, {FFFFFF}17 - {E6284E}�����-�������
    ]]
    imgui.Text(u8"����� ����� ������������ ����� � ��� /mess ��� �������.")
    imgui.Separator()
    if imgui.CollapsingHeader(u8'����������� ������ /mess') then  
        atlibs.imgui_TextColoredRGB(colours_mess) 
    end
    if imgui.Button(u8"�������� �����") then  
        imgui.OpenPopup('mainFloods')
    end
    if imgui.Button(u8"���� �� GangWar") then  
        imgui.OpenPopup('FloodsGangWar')
    end 
    if imgui.Button(u8"����������� /join") then  
        imgui.OpenPopup('FloodsJoinMP')
    end
    if imgui.BeginPopup('mainFloods') then  
        if imgui.Button(u8'���� ��� �������') then
			sampSendChat("/mess 4 ===================== | ������� | ====================")
			sampSendChat("/mess 0 �������� ������ ��� ����������?")
			sampSendChat("/mess 4 ������� /report, ������ ���� ID ����������/������!")
			sampSendChat("/mess 0 ���� �������������� ������� ��� � ���������� � ����. <3")
			sampSendChat("/mess 4 ===================== | ������� | ====================")
		end
		imgui.SameLine()
		if imgui.Button(u8'���� ��� VIP') then
			sampSendChat("/mess 2 ===================== | VIP | ====================")
			sampSendChat("/mess 3 ������ ����� �������� �� ����� �����?")
			sampSendChat("/mess 2 ����� ��������� �������? ������� ��� � ������� 10� �����.")
			sampSendChat("/mess 3 ����� ������� /sellvip � �� �������� VIP!")
			sampSendChat("/mess 2 ===================== | VIP | ====================")
		end
		if imgui.Button(u8'���� ��� ������ �������/����') then
			
			sampSendChat("/mess 5 ===================== | ���� | ====================")
			sampSendChat("/mess 10 ��� ��� ������ ����� ����������. ���? -> ..")
			sampSendChat("/mess 0 ��� ����� ����������, �������� /tp, ����� ������ -> ����...")
			sampSendChat("/mess 0 ...����� ����� ������ � ����, ������� ���� �..")
			sampSendChat("/mess 10 ..� �������� �� ������ ���� ��� ������ �������. �� ���� ���.")
			sampSendChat("/mess 5 ===================== | ���� | ====================")
		end
		if imgui.Button(u8'���� ��� /dt 0-990 (����� ����������)') then
			
			sampSendChat("/mess 6 =================== | ����������� ��� | ==================")
			sampSendChat("/mess 0 ����������� �������? ��������� ��, ������ ��������..")
			sampSendChat("/mess 0 ���� ������� ���������? ��� ����� ���������! <3")
			sampSendChat("/mess 0 ������ ����� /dt 0-990. ����� - ��� ����������� ���.")
			sampSendChat("/mess 0 �� �������� �������� ������� ���� ���. ������� ����. :3")
			sampSendChat("/mess 6 =================== | ����������� ���  | ==================")
			
		end
		if imgui.Button(u8'���� ��� /storm') then
			
			sampSendChat("/mess 2 ===================== | ����� | ====================")
			sampSendChat("/mess 3 ������ ������ ���������� ����� ? � ��� ���� �����������!")
			sampSendChat("/mess 2 ����� ������� /storm , ����� ���� ��������� � NPC ... ")
			sampSendChat("/mess 3 ...������� ������������� � ������.")
			sampSendChat("/mess 2 ����� �������� ������ ���������� ������� ����� �������.")
			sampSendChat("/mess 2 ===================== | ����� | ====================")
			
		end
		if imgui.Button(u8'���� ��� /arena') then
			
			sampSendChat("/mess 7 ===================== | ����� | ====================")
			sampSendChat("/mess 0 ������ �������� ���� ������ � ��������?")
			sampSendChat("/mess 7 ������ ����� /arena, ������ ���� ���� ���.")
			sampSendChat("/mess 0 ����������� ����, ������ ��. ������, ��� ����� �������� ����. <3")
			sampSendChat("/mess 7 ===================== | ����� | ====================")
			
		end
		imgui.SameLine()
		if imgui.Button(u8'���� ��� VK group') then
			
			sampSendChat("/mess 15 ===================== | ��������� | ====================")
			sampSendChat("/mess 0 ������ ����� ������������� � ��������?")
			sampSendChat("/mess 15 � ����� ������ ��������� �����, ��� �������� ������?")
			sampSendChat("/mess 0 ������ � ���� ������ ���������: https://vk.com/dmdriftgta")
			sampSendChat("/mess 15 ===================== | ��������� | ====================")
			
		end
		if imgui.Button(u8'���� ��� ���������') then
			
			sampSendChat("/mess 12 ===================== | ��������� | ====================")
			sampSendChat("/mess 0 � ���� ��������� �����? �� ������ ������ �����?")
			sampSendChat("/mess 12 ����� ������� /tp -> ������ -> ����������")
			sampSendChat("/mess 0 ������� ������ ���������, ���� ������ �� RDS �����. � ������� :3")
			sampSendChat("/mess 12 ===================== | ��������� | ====================")
			
		end
		if imgui.Button(u8'���� ��� ���� RDS') then
			
			sampSendChat("/mess 8 ===================== | ����� | ====================")
			sampSendChat("/mess 15 ������ ���������� �� ���� ������� ������ RDS? :> ")
			sampSendChat("/mess 15 �� ��� ������ ������� � ��������! ����: myrds.ru :3 ")
			sampSendChat("/mess 15 � ����� ����������: @empirerosso")
			sampSendChat("/mess 8 ===================== | ����� | ====================")
			
		end
		imgui.SameLine()
		if imgui.Button(u8'���� ��� /gw') then
			
			sampSendChat("/mess 10 ===================== | Capture | ====================")
			sampSendChat("/mess 5 ���� �������� ������ �� ����� � GTA:SA? ��� ��� ���� ����! :>")
			sampSendChat("/mess 5 ������ ��� � ������� /gw, ��� �� ���������� � ��������")
			sampSendChat("/mess 5 ����� ������ ������� �� ����������, ����� ������� /capture XD")
			sampSendChat("/mess 10 ===================== | Capture | ====================")
			
		end
		if imgui.Button(u8"���� ��� ������ ������ �� RDS") then
			
			sampSendChat("/mess 2 ================== | ��������� ������ RDS | =================")
			sampSendChat("/mess 11 ����� ������ ������� ���� ������, � �������� ������?")
			sampSendChat("/mess 2 ����������� ������� ���-������, �� � ���� ����� �� ����������?")
			sampSendChat("/mess 11 �� ������ �������� ��������� ������: https://vk.com/freerds")
			sampSendChat("/mess 2 ================== | ��������� ������ RDS | =================")
			
		end
		if imgui.Button(u8"���� ��� /gangwar") then 
			
			sampSendChat("/mess 16 ===================== | �������� | ====================")
			sampSendChat("/mess 13 ������ ��������� � ������� �������? ��������� ����?")
			sampSendChat("/mess 16 �� ������ ���� ��� ���������! ������ �������� ������ �����")
			sampSendChat("/mess 13 ������� /gangwar, ��������� ���������� � ���������� �� ��.")
			sampSendChat("/mess 16 ===================== | �������� | ====================")
			
		end 
		imgui.SameLine()
		if imgui.Button(u8"���� ��� ������") then
			
			sampSendChat("/mess 14 ===================== | ������ | ====================")
			sampSendChat("/mess 13 �� ������� ����� �� ������? �� ������� �� �������?")
			sampSendChat("/mess 13 ���� ����� ������ � ���������, ��������� ������ ��� �������")
			sampSendChat("/mess 13 ������ ���� ������, �������� /tp -> ������")
			sampSendChat("/mess 14 ===================== | ������ | ====================")
			
		end
		if imgui.Button(u8"���� � ����") then  
			
			sampSendChat("/mess 13 ===================== | ��� RDS | ====================")
			sampSendChat("/mess 0 ��������� ��� � ��� RDS. ������ �����, �� Drift Server")
			sampSendChat("/mess 13 ����� � ��� ���� ����������, ��� GangWar, DM � ���������� RPG")
			sampSendChat("/mess 0 ����������� ������ � ��� ��������� ������� � /help")
			sampSendChat("/mess 13 ===================== | ��� RDS | ====================")
			
		end
		imgui.SameLine()
		if imgui.Button(u8'���� ��� /trade') then
			
			sampSendChat("/mess 9 ===================== | ����� | ====================")
			sampSendChat("/mess 3 ������ ������ ����������, � ����� ������ �� ������� � ���� �����/����/�����/�����?")
			sampSendChat("/mess 9 ������� /trade, ��������� � ������� �����, �������� � �������� � ������ �������.")
			sampSendChat("/mess 3 �����, ������ �� ����� ���� NPC �����, � ���� ����� ����� ���-�� �����.")
			sampSendChat("/mess 9 ===================== | ����� | ====================")
			
		end
		if imgui.Button(u8'���� ��� �����') then 
			
			sampSendChat("/mess 4 ===================== | ����� | ====================")
			sampSendChat('/mess 0 ���� ������ �� �������/�������? ���� �������? ������ ������ � ��������?')
			sampSendChat('/mess 4 � ��� ���� ����� - https://forumrds.ru. ��� ���� �������� ���� :D')
			sampSendChat('/mess 0 ����� �����, ��� ���� ������� � �������. ����������, ������ <3')
			sampSendChat("/mess 4 ===================== | �����  | ====================")
			
		end	
		if imgui.Button(u8'���� ��� ����� ���') then 
			
			sampSendChat("/mess 15 ===================== | ����� | ====================")
			sampSendChat('/mess 17 ������� ������! �� ������ ������� ������ �������?')
			sampSendChat('/mess 15 ���� �� �����-�� ������ ����� �������, �� ��� ��� ����!')
			sampSendChat('/mess 17 ��� �� ������ ������� ������! ������� ������: https://forumrds.ru')
			sampSendChat("/mess 15 ===================== | ����� | ====================")
			
		end
		if imgui.Button(u8'����� ����� �� 15 ������') then
			
			sampSendChat("/mess 14 ��������� ������. ������ ����� ������� ����� ���������� ����������")
			sampSendChat("/mess 14 ������� ������������ �����, � ����������� ��������, ���� ������� :3")
			sampSendChat("/delcarall ")
			sampSendChat("/spawncars 15 ")
			showNotification("������� �/� �������")
			
		end
	    if imgui.Button(u8'������') then
			
		    sampSendChat("/mess 8 =================| ������ NPC |=================")
		    sampSendChat("/mess 0 �� ������ ����� NPC ������� ���� ������? :D")
		    sampSendChat("/mess 0 � ��� ��� �� �� ����� , - ALT(/mm) - ��������� - ...")
		    sampSendChat("/mess 0 ...������� �������, ������� �����, � �� ������ ������...")
		    sampSendChat("/mess 0 ...NPC ����. �������� ���� �� RDS <3")
		    sampSendChat("/mess 8 =================| ������ NPC |=================")
			
		end	
	    imgui.EndPopup()
    end
    if imgui.BeginPopup('FloodsGangWar') then  
        if imgui.Button(u8"Aztecas vs Ballas") then  
			
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			sampSendChat("/mess 3 ���� -  GangWar: /gw")
			sampSendChat("/mess 0 Varios Los Aztecas vs East Side Ballas ")
			sampSendChat("/mess 0 �������� ����� �������, �������� ����� /gw �� ������� �����")
			sampSendChat("/mess 3 ���� - GangWar: /gw")
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			
		end
		imgui.SameLine()
		if imgui.Button(u8"Aztecas vs Groove") then  
			
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			sampSendChat("/mess 2 ���� -  GangWar: /gw")
			sampSendChat("/mess 0 Varios Los Aztecas vs Groove Street ")
			sampSendChat("/mess 0 �������� ����� �������, �������� ����� /gw �� ������� �����")
			sampSendChat("/mess 2 ���� - GangWar: /gw")
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			
		end
		if imgui.Button(u8"Aztecas vs Vagos") then  
			
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			sampSendChat("/mess 4 ���� -  GangWar: /gw")
			sampSendChat("/mess 0 Varios Los Aztecas vs Los Santos Vagos ")
			sampSendChat("/mess 0 �������� ����� �������, �������� ����� /gw �� ������� �����")
			sampSendChat("/mess 4 ���� - GangWar: /gw")
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			
		end
		imgui.SameLine()
		if imgui.Button(u8"Aztecas vs Rifa") then  
			
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			sampSendChat("/mess 5 ���� -  GangWar: /gw")
			sampSendChat("/mess 0 Varios Los Aztecas vs The Rifa ")
			sampSendChat("/mess 0 �������� ����� �������, �������� ����� /gw �� ������� �����")
			sampSendChat("/mess 5 ���� - GangWar: /gw")
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			
		end
		if imgui.Button(u8"Ballas vs Groove") then  
			
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			sampSendChat("/mess 6 ���� -  GangWar: /gw")
			sampSendChat("/mess 0 East Side Ballas vs Groove Street  ")
			sampSendChat("/mess 0 �������� ����� �������, �������� ����� /gw �� ������� �����")
			sampSendChat("/mess 6 ���� - GangWar: /gw")
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			
		end
		imgui.SameLine()
		if imgui.Button(u8"Ballas vs Rifa") then  
			
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			sampSendChat("/mess 7 ���� -  GangWar: /gw")
			sampSendChat("/mess 0 East Side Ballas vs The Rifa ")
			sampSendChat("/mess 0 �������� ����� �������, �������� ����� /gw �� ������� �����")
			sampSendChat("/mess 7 ���� - GangWar: /gw")
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			
		end
		if imgui.Button(u8"Groove vs Rifa") then  
			
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			sampSendChat("/mess 8 ���� -  GangWar: /gw")
			sampSendChat("/mess 0 Groove Street  vs The Rifa ")
			sampSendChat("/mess 0 �������� ����� �������, �������� ����� /gw �� ������� �����")
			sampSendChat("/mess 8 ���� - GangWar: /gw")
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			
		end
		imgui.SameLine()
		if imgui.Button(u8"Groove vs Vagos") then  
			
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			sampSendChat("/mess 9 ���� -  GangWar: /gw")
			sampSendChat("/mess 0 Groove Street vs Los Santos Vagos ")
			sampSendChat("/mess 0 �������� ����� �������, �������� ����� /gw �� ������� �����")
			sampSendChat("/mess 9 ���� - GangWar: /gw")
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			
		end
		if imgui.Button(u8"Vagos vs Rifa") then  
			
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			sampSendChat("/mess 10 ���� -  GangWar: /gw")
			sampSendChat("/mess 0 Los Santos Vagos vs The Rifa ")
			sampSendChat("/mess 0 �������� ����� �������, �������� ����� /gw �� ������� �����")
			sampSendChat("/mess 10 ���� - GangWar: /gw")
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			
		end
		imgui.SameLine()
		if imgui.Button(u8"Ballas vs Vagos") then  
			
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			sampSendChat("/mess 11 ���� -  GangWar: /gw")
			sampSendChat("/mess 0 East Side Ballas vs Los Santos Vagos ")
			sampSendChat("/mess 0 �������� ����� �������, �������� ����� /gw �� ������� �����")
			sampSendChat("/mess 11 ���� - GangWar: /gw")
			sampSendChat("/mess 13 �------------------- GangWar -------------------�")
			
		end
        imgui.EndPopup()
    end
    if imgui.BeginPopup('FloodsJoinMP') then  
        if imgui.Button(u8'����������� "�����" ') then 
			
			sampSendChat("/mess 8 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� ������! ��������: /derby")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� ������! ��������: /derby")
			sampSendChat("/mess 8 ===================| [Event-Game-RDS] |==================")
			
		end	
		if imgui.Button(u8'����������� "������" ') then 
			
			sampSendChat("/mess 10 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� �������! ��������: /parkour")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� �������! ��������: /parkour")
			sampSendChat("/mess 10 ===================| [Event-Game-RDS] |==================")
			
		end	
		if imgui.Button(u8'����������� "PUBG" ') then 
			
			sampSendChat("/mess 9 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� �PUBG�! ��������: /pubg")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� �PUBG�! ��������: /pubg")
			sampSendChat("/mess 9 ===================| [Event-Game-RDS] |==================")
			
		end	
		if imgui.Button(u8'����������� "DAMAGE DM" ') then 
			
			sampSendChat("/mess 4 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� �DAMAGE DEATHMATCH�! ��������: /damagedm")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� �DAMAGE DEATHMATCH�! ��������: /damagedm")
			sampSendChat("/mess 4 ===================| [Event-Game-RDS] |==================")
			
		end	
		if imgui.Button(u8'����������� "KILL DM" ') then 
			
			sampSendChat("/mess 17 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� �KILL DEATHMATCH�! ��������: /killdm")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� �KILL DEATHMATCH�! ��������: /killdm")
			sampSendChat("/mess 17 ===================| [Event-Game-RDS] |==================")
			
		end	
		if imgui.Button(u8'����������� "����� �����" ') then 
			
			sampSendChat("/mess 7 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� ������ �����! ��������: /drace")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� ������ �����! ��������: /drace")
			sampSendChat("/mess 7 ===================| [Event-Game-RDS] |==================")
			
		end	
		if imgui.Button(u8'����������� "PaintBall" ') then 
			
			sampSendChat("/mess 12 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� �PaintBall�! ��������: /paintball")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� �PaintBall�! ��������: /paintball")
			sampSendChat("/mess 12 ===================| [Event-Game-RDS] |==================")
			
		end	
		if imgui.Button(u8'����������� "����� ������ �����" ') then 
			
			sampSendChat("/mess 13 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� ������ ������ �����! ��������: /zombie")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� ������ ������ �����! ��������: /zombie")
			sampSendChat("/mess 13 ===================| [Event-Game-RDS] |==================")
			
		end	
		if imgui.Button(u8'����������� "���������� ������" ') then 
			
			sampSendChat("/mess 3 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� ����������� ������! ��������: /ny")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� ����������� ������! ��������: /ny")
			sampSendChat("/mess 3 ===================| [Event-Game-RDS] |==================")
			
		end	
		if imgui.Button(u8'����������� "Capture Blocks" ') then 
			
			sampSendChat("/mess 16 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� �Capture Blocks�! ��������: /join -> 12")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� �Capture Blocks�! ��������: /join -> 12")
			sampSendChat("/mess 16 ===================| [Event-Game-RDS] |==================")
			
		end	
		if imgui.Button(u8'����������� "������" ') then 
			sampSendChat("/mess 11 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� �������! ��������: /join -> 10 �������")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� �������! ��������: /join -> 10 �������")
			sampSendChat("/mess 11 ===================| [Event-Game-RDS] |==================")
		end	
		if imgui.Button(u8'����������� "���������" ') then 
			sampSendChat("/mess 3 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� ����������! ��������: /catchup")
			sampSendChat("/mess 0 [MP-/join] ���������� ����������� ����������! ��������: /catchup")
			sampSendChat("/mess 3 ===================| [Event-Game-RDS] |==================")
		end
        imgui.EndPopup()
    end
end
-- ## ���� �������, ���������� �� ������������ ����� ������������ �������� ImGUI ��� ����������� �� ��������� ������ ## --