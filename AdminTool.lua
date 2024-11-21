script_name('AdminTool') -- ��� �������
script_description('����������� ���������������� ������ ��� ������� Russian Drift Server � SA:MP') -- ��������
script_author('alfantasyz') -- �����

-- ## ����������� ���������, �������� � ������� ## --
require "lib.moonloader" -- ���������� �������� �������.
require 'resource.commands' -- �������������� ������� � ���������.
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

local events_res, events = pcall(import, "ATEvents.lua") -- ������ ������������ ������� (�������), ��� ����� ����������� ������� ��� �������� � ������ � �������������
local other_res, pother = pcall(import, "module/plugins/other.lua") -- ������ ������������ ������� (�������), ��� ����� ����������� ���������, ����������� �� �� �������
local automute_res, automute = pcall(import, "module/plugins/automute.lua") -- ������ ������������ ������� (�������), ��� ����������� ������� ��� ��������
local plugins_main_res, plugin = pcall(import, "module/plugins/plugin.lua") -- ������ ������������ ������� (�������), ��� ����������� ������� ��� ������� ��������� ����� ����
local adminstate_res, admst = pcall(import, 'module/plugins/adminstate.lua') -- ������ ������������ ������� (�������), ��� ���������� ���� ���������������� ����������.
local renders_res, prender = pcall(import, 'module/plugins/renders.lua') -- ������ ������������ ������� (�������), ��� ���������� ������� ��������� ����� ����

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
	['updater'] = 'https://raw.githubusercontent.com/alfantasy/AdminTool/main/updateAT.ini',
	["main"] = "https://raw.githubusercontent.com/alfantasy/AdminTool/main/AdminTool.lua",
	["pluginsAT"] = "https://raw.githubusercontent.com/alfantasy/AdminTool/main/module/plugins/plugin.lua",
	["otherAT"] = "https://raw.githubusercontent.com/alfantasy/AdminTool/main/module/plugins/other.lua",
	["libs"] = "https://raw.githubusercontent.com/alfantasy/AdminTool/main/lib/libsfor.lua",
	["adminstate"] = "https://raw.githubusercontent.com/alfantasy/AdminTool/main/module/plugins/adminstate.lua",
	['renders'] = "https://raw.githubusercontent.com/alfantasy/AdminTool/main/module/plugins/renders.lua",
	['notf'] = "https://raw.githubusercontent.com/alfantasy/AdminTool/main/lib/imgui_notf.lua",
	['addons'] = "https://raw.githubusercontent.com/alfantasy/AdminTool/main/lib/imgui_addons.lua",
	['scoreboard'] = "https://raw.githubusercontent.com/alfantasy/AdminTool/main/lib/scoreboard.lua",
	['answers'] = "https://raw.githubusercontent.com/alfantasy/AdminTool/main/QAnswer.lua",
	['commands'] = "https://raw.githubusercontent.com/alfantasy/AdminTool/main/resource/commands.lua",
	['chatlogger'] = "https://raw.githubusercontent.com/alfantasy/AdminTool/main/chat-logger.lua",
	['events'] = "https://raw.githubusercontent.com/alfantasy/AdminTool/main/ATEvents.lua",
	['eventsForOwn'] = "https://raw.githubusercontent.com/alfantasy/AdminTool/main/config/AdminTool/evbinder.ini",
}

local paths = {
	['updater'] = getWorkingDirectory() .. "/updateAT.ini",
	["main"] = getWorkingDirectory() .. "/AdminTool.lua",
	["pluginsAT"] = getWorkingDirectory() .. "/module/plugins/plugin.lua",
	["otherAT"] = getWorkingDirectory() .. "/module/plugins/other.lua",
	["libs"] = getWorkingDirectory() .. "/lib/libsfor.lua",
	["adminstate"] = getWorkingDirectory() .. "/module/plugins/adminstate.lua",
	['renders'] = getWorkingDirectory() .. "/module/plugins/renders.lua",
	['notf'] = getWorkingDirectory() .. "/lib/imgui_notf.lua",
	['addons'] = getWorkingDirectory() .. "/lib/imgui_addons.lua",
	['scoreboard'] = getWorkingDirectory() .. "/lib/scoreboard.lua",
	['answers'] = getWorkingDirectory() .. '/QAnswer.lua',
	['commands'] = getWorkingDirectory() .. '/resource/commands.lua',
	['chatlogger'] = getWorkingDirectory() .. '/chat-logger.lua',
	['events'] = getWorkingDirectory() .. '/ATEvents.lua',
	['eventsForOwn'] = getWorkingDirectory() .. '/config/AdminTool/evbinder.ini',
}

local function downloadAll() -- ������� ��� ���������� ��������
	lua_thread.create(function()
		for i, v in pairs(urls) do  
			downloadUrlToFile(v, paths[i], function(id, status)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then  
					sampfuncsLog(log .. '���� ������� ������. ����������� ������ ��������� :D')
				end
			end)
		end

		wait(10000)
		sampAddChatMessage(tag .. '����� AdminTool ������� ��������. ������������� �������.')
		reloadScripts()
	end)
end

local upd_upvalue = { -- ������ ��� ����������� ����������� ����������
	main = imgui.ImBool(false),
	pluginsAT = imgui.ImBool(false),
	otherAT = imgui.ImBool(false),
	libs = imgui.ImBool(false),
	adminstate = imgui.ImBool(false),
	renders = imgui.ImBool(false),
	notf = imgui.ImBool(false),
	addons = imgui.ImBool(false),
	scoreboard = imgui.ImBool(false),
	answers = imgui.ImBool(false),
	commands = imgui.ImBool(false),
	chatlogger = imgui.ImBool(false),
	events = imgui.ImBool(false),
} 

local script_stream = 8
local script_version_text = "14.6.1"
local check_update = false
-- ## ����������� ������ ��� GitHub, ���������� ��� ���������� ## --

-- ## ���� ���������� ��������� � ��������� � ���������� �������������� � ����������� ������� ## --
local directReports = "AdminTool\\settings_reports.ini"
local configReports = inicfg.load({
	main = {
		interface = true,
        prefix_answer = false, 
        prefix_for_answer = " // �������� ���� �� ������� RDS <3",
    },
    bind_name = {},
    bind_text = {},
    bind_delay = {},
}, directReports)

local directIniText = 'AdminTool\\texts.ini'
local configText = inicfg.load({
	flood_text = {},
	flood_name = {},
}, directIniText)
inicfg.save(configText, directIniText)

local direct = "AdminTool\\settings.ini"
local config = inicfg.load({
    main = {
		autoupdate = false,
		aclist_alogin = false,
		ears_alogin = false,
		agm_alogin = false,
        push_report = false, 
        auto_login = false, 
        custom_tab = false, 
		render_admins_imgui = false,
        password = "",
        recon_menu = false, 
        auto_online = false,
		takereport = false,
        styleImGUI = 0,
        font = 10,
		auto_prefix = false,
		automultiply = false,
    },
    colours = {
        render_admins = "{FFFFFF}",
		prefix_MA = "{FFFFFF}",
		prefix_ADM = "{FFFFFF}",
		prefix_STA = "{FFFFFF}",
		prefix_ZGA = "{FFFFFF}",
		prefix_GA = "{FFFFFF}",
    },
    keys = {
        WallHack = "None",
        GUI = "F3",
        OpenReport = "None",
        GiveOnline = "None",
		NextReconID = 'None',
		BackReconID = 'None',
		SendRP = 'None',
		SendRecon = 'None',
		AgreeMute = 'Enter',
    },
    position = {
        reX = 0,
        reY = 0,
        acX = 0,
        acY = 0,
    },
	settings_start = {
		plugins_main = true,
		others = true,
		automute = true,
		renders = true,
		adminstate = true,
	},
	access = {
		scaning = true,
		ban = false,
		mute = false,
		jail = false,
	}
}, direct)
inicfg.save(config, direct)

function TextSave()
	inicfg.save(configText, directIniText)
	return true
end

function ConfigSave()
    inicfg.save(config, direct)
	return true
end

local elm = {
    boolean = {
		autoupdate = imgui.ImBool(config.main.autoupdate),
		aclist_alogin = imgui.ImBool(config.main.aclist_alogin),
		ears_alogin = imgui.ImBool(config.main.ears_alogin),
		agm_alogin = imgui.ImBool(config.main.agm_alogin),
        push_report = imgui.ImBool(config.main.push_report),
		takereport = imgui.ImBool(config.main.takereport),
        auto_login = imgui.ImBool(config.main.auto_login),
        custom_tab = imgui.ImBool(config.main.custom_tab),
        recon_menu = imgui.ImBool(config.main.recon_menu),
		render_admins_imgui = imgui.ImBool(config.main.render_admins_imgui),
        auto_online = imgui.ImBool(config.main.auto_online),
		auto_prefix = imgui.ImBool(config.main.auto_prefix),
		automultiply = imgui.ImBool(config.main.automultiply),

		-- ## ��������� ������� �������� ## --
		access_scan = imgui.ImBool(config.access.scaning),
		-- ## ��������� ������� �������� ## --

		-- ## ������� �������� ���������������� �������� ## --
		prefix_answer = imgui.ImBool(configReports.main.prefix_answer),
		-- ## ������� �������� ���������������� �������� ## --
    },
    int = {
        styleImGUI = imgui.ImInt(config.main.styleImGUI),
        font = imgui.ImInt(config.main.font),
    },
    input = {
        password = imgui.ImBuffer(tostring(config.main.password), 50),
        set_punish_in_recon = imgui.ImBuffer(100),
        set_time_punish_in_recon = imgui.ImBuffer(100),
		prefix_MA = imgui.ImBuffer(tostring(config.colours.prefix_MA), 50),
		prefix_ADM = imgui.ImBuffer(tostring(config.colours.prefix_ADM), 50),
		prefix_STA = imgui.ImBuffer(tostring(config.colours.prefix_STA), 50),
		prefix_ZGA = imgui.ImBuffer(tostring(config.colours.prefix_ZGA), 50),
		prefix_GA = imgui.ImBuffer(tostring(config.colours.prefix_GA), 50),
    },
	binder = {
		reports = {
			prefix = imgui.ImBuffer(256),
			name = imgui.ImBuffer(256),
			text = imgui.ImBuffer(65536),
			delay = imgui.ImBuffer(2500),
		},
		flood = {
			text = imgui.ImBuffer(65536),
			name = imgui.ImBuffer(256),
		},
	},
    position = {
        reX = config.position.reX, 
        reY = config.position.reY, 
        acX = config.position.acX, 
        acY = config.position.acY,
        change_recon = false,
    },
	settings_start = {
		plugins_main = imgui.ImBool(config.settings_start.plugins_main),
		others = imgui.ImBool(config.settings_start.others),
		automute = imgui.ImBool(config.settings_start.automute),
		renders = imgui.ImBool(config.settings_start.renders),
		adminstate = imgui.ImBool(config.settings_start.adminstate),
	},
}
-- ## ���� ���������� ��������� � ��������� � ���������� �������������� � ����������� ������� ## --

-- ## ���� ���������� ��������� � MoonImGUI ## --
local sw, sh = getScreenResolution()
local ATMenu = imgui.ImBool(false)
local ATRecon = imgui.ImBool(false)
local ATAdmins = imgui.ImBool(false)
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
imgui.CenterText = require('imgui_addons').CenterText

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
local ids_recon = {}
local text_recon = {'STATS', 'MUTE', 'KICK', 'BAN', 'JAIL', 'CLOSE'}
for i = 190, 236 do 
	table.insert(ids_recon, i, #ids_recon+1) 
end
local refresh_button_textdraw = 0
local info_textdraw_recon = 0
local info_to_player = {}
local recon_info = { "��������: ", "�����: ", "�� ������: ", "��������: ", "����: ", "�������: ", "�������: ", "������� ��������: ", "����� � ���: ", "P.Loss: ", "������� VIP: ", "��������� �����: ", "�����-�����: ", "��������: ", '�����-���: '}
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

-- ## ���������� ��� ������� ������ ��������� ## -- 
local multiply_punish_frame = {}
-- ## ���������� ��� ������� ������ ��������� ## -- 

-- ## ���������� ��� ��������������� �����/������ ������ ## --
local quitlogin_control = true 
local players_control_frame = {}
-- ## ���������� ��� ��������������� �����/������ ������ ## --

-- ## ��������� ���������� ## --
local param_for_chgn, param_for_chgn2
-- ## ��������� ���������� ## --

function main()
    while not isSampAvailable() do wait(0) end

	downloadUrlToFile(urls['updater'], paths['updater'], function(id, status)
		upd = inicfg.load(nil, paths['updater'])
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then  
			if tonumber(upd.info.version) > script_stream then  
				if elm.boolean.autoupdate.v then  
					lua_thread.create(function()
						if notf_res then  
							showNotification('� ��� ����������� ������������ ������. �������� ��������������.')
						end
						sampAddChatMessage(tag .. '�������� ����������. AT �������� ��������������!', -1)
						sampAddChatMessage(tag .. '�������, �� ���������������� � �����, ���� AT �� �������� ����������', -1)
						check_update = true
					end)
				else 
					sampAddChatMessage(tag .. '�������� ����������. ���� �������������� ���������, ���������� � ���������� (/tool -> ���������)')
				end 
			else 
				if notf_res then  
					showNotification('� ��� ����������� ���������� ������. \n������: ' .. script_version_text)
				else 
					sampfuncsLog(log .. '�������� � �������� �����������. ���������� ������� ����� ���������.')
					sampAddChatMessage(tag .. '����������� ���������� ������. ���������� �� ���������.')
				end 
			end 
		end
	end)
    
	other_res = elm.settings_start.others.v 
	automute_res = elm.settings_start.automute.v  
	plugins_main_res = elm.settings_start.plugins_main.v  
	adminstate_res = elm.settings_start.adminstate.v  
	renders_res = elm.settings_start.renders.v 
	if elm.settings_start.others.v == false then  
		pother.OffScript()
	end
	if elm.settings_start.automute.v == false then  
		automute.OffScript()
	end
	if elm.settings_start.plugins_main.v == false then
		plugin.OffScript()
	end 
	if elm.settings_start.adminstate.v == false then  
		admst.OffScript()
	end 
	if elm.settings_start.renders.v == false then
		prender.OffScript()
	end

    sampAddChatMessage(tag .. "������ ���������������. ��� �������� AT �������: /tool", -1)
    sampfuncsLog(log .. " ������������� ��������� �������. \n   ��������� ����������� �������� � ���������, ���������� � MoonLoader")
    
    -- ## ����������� ������� ## --
    load_recon = lua_thread.create_suspended(loadRecon)
    send_online = lua_thread.create_suspended(drawOnline)
    -- ## ����������� ������� ## --

    -- ## ������ ������� ## -- 
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
    -- ## ����������� �������� ������ ��� ������� �������������� � �� ## --

	-- ## ����������� ������ ��� ������ ��������� ## --
	for key in pairs(cmd_massive) do  
		sampRegisterChatCommand(key, function(arg)
			reason_send = nil  
			time_send = nil
			if #arg > 0 then  
				if cmd_massive[key].cmd == "/iban" or cmd_massive[key].cmd == "/ban" then
					if config.access.ban then
						sampSendChat("/ans " .. arg .. " ��������� �����, �� �������� ������� �������, � ���� ��..")
						sampSendChat("/ans " .. arg .. " ..�� �������� � ����������, �������� ������ �� ����� https://forumrds.ru")
						sampSendChat(cmd_massive[key].cmd .. " " .. arg .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
					else 
						sampSendChat('/a ' .. cmd_massive[key].cmd .. " " .. arg .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
					end
				end
				if cmd_massive[key].cmd == '/siban' or cmd_massive[key].cmd == '/sban' then
					if config.access.ban then
						sampSendChat(cmd_massive[key].cmd .. ' ' .. arg .. ' ' .. cmd_massive[key].time .. ' ' .. cmd_massive[key].reason)
					else
						sampSendChat('/a ' .. cmd_massive[key].cmd .. ' ' .. arg .. ' ' .. cmd_massive[key].time .. ' ' .. cmd_massive[key].reason)
					end
				end
				if cmd_massive[key].cmd == "/mute" then  
					if elm.boolean.automultiply.v then
						current_time_hour, current_time_min, current_time_sec = string.match(os.date("%H:%M:%S"), "(%d+):(%d+):(%d+)")
						current_time_full = tonumber(current_time_hour) * 3600 + tonumber(current_time_min) * 60 + tonumber(current_time_sec)
						if #multiply_punish_frame > 0 then 
							for i, v in pairs(multiply_punish_frame) do  
								if v:find(cmd_massive[key].reason) then  
									if v:find(sampGetPlayerNickname(arg)) then  
										splited = atlibs.textSplit(v, "~")
										time_stamp_send = splited[4]
										hour, min, sec = string.match(time_stamp_send, "(%d+):(%d+):(%d+)")
										fulltimestamp = tonumber(hour) * 3600 + tonumber(min) * 60 + tonumber(sec)
										if current_time_full - fulltimestamp >= 30 and splited[5] == 'basemute' then  
											time_send = splited[3]
											reason_send = splited[2]
										else 
											sampAddChatMessage(tag .. '�� ����� ����� �� ��������� 30 ������ ���� ����� ������������.', -1)
											sampAddChatMessage(tag .. '��� �� ��������� �������� ������ 30 ������.')
										end 
									end  
								end  
							end
						end
					end
					if time_send and reason_send and elm.boolean.automultiply.v then
						if config.access.mute then 
							sampSendChat(cmd_massive[key].cmd .. " " .. arg .. " " .. time_send .. " " .. reason_send .. ' x' .. tostring(tonumber(time_send)/cmd_massive[key].time))
						else 
							sampSendChat('/a ' .. cmd_massive[key].cmd .. " " .. arg .. " " .. time_send .. " " .. reason_send .. ' x' .. tostring(tonumber(time_send)/cmd_massive[key].time))
						end
					else 
						if config.access.mute then 
							if arg:find('(%d+) (%d+)') then
								ids_punising, multiply_value = arg:match('(%d+) (%d+)')
								if cmd_massive[key].multi then  
									sampSendChat(cmd_massive[key].cmd .. " " .. arg .. " " .. tostring(tonumber(cmd_massive[key].time)*tonumber(multiply_value)) .. " " .. cmd_massive[key].reason .. ' x' .. multiply_value)
								else 
									sampAddChatMessage(tag .. '� ��������� ���� ������� "' .. cmd_massive[key].cmd .. '" �� ���������� ���������. ����� ����������� ���������.', -1)
									sampSendChat(cmd_massive[key].cmd .. " " .. arg .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
								end
							else
								sampSendChat(cmd_massive[key].cmd .. " " .. arg .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
							end
						else
							sampSendChat('/a ' .. cmd_massive[key].cmd .. " " .. arg .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
						end
					end						
				end
				if cmd_massive[key].cmd == '/rmute' then  
					if elm.boolean.automultiply.v then 
						current_time_hour, current_time_min, current_time_sec = string.match(os.date("%H:%M:%S"), "(%d+):(%d+):(%d+)")
						current_time_full = tonumber(current_time_hour) * 3600 + tonumber(current_time_min) * 60 + tonumber(current_time_sec)
						if #multiply_punish_frame > 0 then 
							for i, v in pairs(multiply_punish_frame) do  
								if v:find(cmd_massive[key].reason) then  
									if v:find(sampGetPlayerNickname(arg)) then  
										splited = atlibs.textSplit(v, "~")
										time_stamp_send = splited[4]
										hour, min, sec = string.match(time_stamp_send, "(%d+):(%d+):(%d+)")
										fulltimestamp = tonumber(hour) * 3600 + tonumber(min) * 60 + tonumber(sec)
										if current_time_full - fulltimestamp >= 30 and splited[5] == 'report' then  
											time_send = splited[3]
											reason_send = splited[2]
										else 
											sampAddChatMessage(tag .. '�� ����� ����� �� ��������� 30 ������ ���� ����� ������������.', -1)
											sampAddChatMessage(tag .. '��� �� ��������� �������� ������ 30 ������. ���� �� �� ���������, �������� ����������� ���������', -1)
										end 
									end  
								end  
							end
						end
					end
					if time_send and reason_send and elm.boolean.automultiply.v then
						if config.access.mute then 
							sampSendChat(cmd_massive[key].cmd .. " " .. arg .. " " .. time_send .. " " .. reason_send .. ' x' .. tostring(tonumber(time_send)/cmd_massive[key].time))
						else 
							sampSendChat('/a ' .. cmd_massive[key].cmd .. " " .. arg .. " " .. time_send .. " " .. reason_send .. ' x' .. tostring(tonumber(time_send)/cmd_massive[key].time))
						end
					else 
						if config.access.mute then 
							if arg:find('(%d+) (%d+)') then
								ids_punising, multiply_value = arg:match('(%d+) (%d+)')
								if cmd_massive[key].multi then  
									sampSendChat(cmd_massive[key].cmd .. " " .. arg .. " " .. tostring(tonumber(cmd_massive[key].time)*tonumber(multiply_value)) .. " " .. cmd_massive[key].reason .. ' x' .. multiply_value)
								else 
									sampAddChatMessage(tag .. '� ��������� ���� ������� "' .. cmd_massive[key].cmd .. '" �� ���������� ���������. ����� ����������� ���������.', -1)
									sampSendChat(cmd_massive[key].cmd .. " " .. arg .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
								end
							else
								sampSendChat(cmd_massive[key].cmd .. " " .. arg .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
							end
						else
							sampSendChat('/a ' .. cmd_massive[key].cmd .. " " .. arg .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
						end
					end		
				end
				if cmd_massive[key].cmd == '/kick' then 
					sampSendChat(cmd_massive[key].cmd .. " " .. arg .. " " .. cmd_massive[key].reason)
				end 
				if cmd_massive[key].cmd == '/jail' then  
					if elm.boolean.automultiply.v then
						current_time_hour, current_time_min, current_time_sec = string.match(os.date("%H:%M:%S"), "(%d+):(%d+):(%d+)")
						current_time_full = tonumber(current_time_hour) * 3600 + tonumber(current_time_min) * 60 + tonumber(current_time_sec)
						if #multiply_punish_frame > 0 then 
							for i, v in pairs(multiply_punish_frame) do  
								if v:find(cmd_massive[key].reason) then  
									if v:find(sampGetPlayerNickname(arg)) then  
										splited = atlibs.textSplit(v, "~")
										time_stamp_send = splited[4]
										hour, min, sec = string.match(time_stamp_send, "(%d+):(%d+):(%d+)")
										fulltimestamp = tonumber(hour) * 3600 + tonumber(min) * 60 + tonumber(sec)
										if current_time_full - fulltimestamp >= 30 then  
											time_send = splited[3]
											reason_send = splited[2]
										else 
											sampAddChatMessage(tag .. '�� ����� ����� �� ��������� 30 ������ ���� ����� ������������.', -1)
											sampAddChatMessage(tag .. '��� �� ��������� �������� ������ 30 ������.')
										end 
									end  
								end  
							end
						end
					end
					if time_send and reason_send and elm.boolean.automultiply.v then
						if config.access.jail then 
							sampSendChat(cmd_massive[key].cmd .. " " .. arg .. " " .. time_send .. " " .. reason_send .. ' x' .. tostring(tonumber(time_send)/cmd_massive[key].time))
						else 
							sampSendChat('/a ' .. cmd_massive[key].cmd .. " " .. arg .. " " .. time_send .. " " .. reason_send .. ' x' .. tostring(tonumber(time_send)/cmd_massive[key].time))
						end
					else 
						if config.access.jail then 
							if arg:find('(%d+) (%d+)') then
								ids_punising, multiply_value = arg:match('(%d+) (%d+)')
								if cmd_massive[key].multi then  
									sampSendChat(cmd_massive[key].cmd .. " " .. arg .. " " .. tostring(tonumber(cmd_massive[key].time)*tonumber(multiply_value)) .. " " .. cmd_massive[key].reason .. ' x' .. multiply_value)
								else 
									sampAddChatMessage(tag .. '� ��������� ���� ������� "' .. cmd_massive[key].cmd .. '" �� ���������� ���������. ����� ����������� ���������.', -1)
									sampSendChat(cmd_massive[key].cmd .. " " .. arg .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
								end
							else
								sampSendChat(cmd_massive[key].cmd .. " " .. arg .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
							end
						else
							sampSendChat('/a ' .. cmd_massive[key].cmd .. " " .. arg .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
						end
					end		
				end
				if cmd_massive[key].cmd == '/jailakk' or cmd_massive[key].cmd == '/offban' or cmd_massive[key].cmd == '/muteakk' or cmd_massive[key].cmd == '/rmuteakk' then  
					sampSendChat(cmd_massive[key].cmd .. " " .. arg .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
				end
			else 
				sampAddChatMessage(tag .. "�� ������ ������ ID/Nick ����������! ", -1)
			end
		end)
	end
	-- ## ����������� ������ ��� ������ ��������� ## --
    -- ## ����������� ��������������� ������ ## --

	sampRegisterChatCommand('chgn', function(id, text)
		if #id > 0 then
			if text ~= nil then
				param_for_chgn = id
				if tonumber(id) == nil then
					id = sampGetPlayerIdByNickname(id)
				end
				lua_thread.create(function()
					sampSendClickPlayer(id, 0)
					wait(200)
					sampSendDialogResponse(500, 1, 10)
					wait(200)
				end)
				sampSendChat('/changegname ' .. param_for_chgn2 .. ' ' .. text)
			else
				sampAddChatMessage(tag .. "�� ������ ������ ����� �������� �����!", -1)
			end
		else
			sampAddChatMessage(tag .. "�� ������ ������ ID/Nick/ID �����!", -1)
		end
	end)

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
	sampRegisterChatCommand('sl', function(id)
		sampSendChat('/slap ' .. id)
	end)
	sampRegisterChatCommand('gh', function(id)
		sampSendChat('/gethere ' .. id)
	end)
	sampRegisterChatCommand('ib', function(id)
		sampSendChat('/iunban ' .. id)
	end)
	sampRegisterChatCommand('ubi', function(id)
		sampSendChat('/unbanip ' .. id)
	end)
	sampRegisterChatCommand('auj', function(nick)
		sampSendChat('/jailakk ' .. nick .. ' 5 ������/��������')
	end)
	sampRegisterChatCommand('au', function(nick)
		sampSendChat('/muteakk ' .. nick .. ' 5 ������/������')
	end)
	sampRegisterChatCommand('aru', function(nick)
		sampSendChat('/rmuteakk ' .. nick .. ' 5 ������/������')
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

	sampRegisterChatCommand('prfm', function(arg)
		prefix = tostring(config.colours.prefix_MA):match("{(.+)}")
		sampSendChat('/prefix ' .. arg .. ' ��.������������� ' .. prefix)
	end)
	sampRegisterChatCommand('prfad', function(arg)
		prefix = tostring(config.colours.prefix_ADM):match("{(.+)}")
		sampSendChat('/prefix ' .. arg .. ' ������������� ' .. prefix)
	end)
	sampRegisterChatCommand('prfst', function(arg)
		prefix = tostring(config.colours.prefix_STA):match("{(.+)}")
		sampSendChat('/prefix ' .. arg .. ' ��.������������� ' .. prefix)
	end)
	sampRegisterChatCommand('prfzga', function(arg)
		prefix = tostring(config.colours.prefix_ZGA):match("{(.+)}")
		sampSendChat('/prefix ' .. arg .. ' ���.��.�������������� ' .. prefix)
	end)
	sampRegisterChatCommand('prfga', function(arg)
		prefix = tostring(config.colours.prefix_GA):match("{(.+)}")
		sampSendChat('/prefix ' .. arg .. ' ��.������������� ' .. prefix)
	end)

	sampRegisterChatCommand('checkoff', function(arg)
		checking_control_on_frame = false
		if #arg > 0 then  
			if #players_control_frame > 0 then
				for i, v in pairs(players_control_frame) do
					if v:find(arg) then  
						checking_control_on_frame = true
						table.remove(players_control_frame, i)
						sampAddChatMessage(tag .. '����� ' .. arg .. ' ����� �� �������� �� ����.', -1)
					end 
				end 
			end
			if checking_control_on_frame == false then
				id_player = sampGetPlayerIdByNickname(arg)
				if id_player ~= nil and sampIsPlayerConnected(id_player) then 
					sampAddChatMessage(tag .. '������ ����� � ����! ��� ID: ' .. id_player, -1)
				else
					sampAddChatMessage(tag .. '�� �������� ' .. arg .. ' � ������ �������� �� ����.', -1)
					table.insert(players_control_frame, arg)
				end
			end
		else 
			sampAddChatMessage(tag .. "�� ������ ������ Nick ������! ", -1)
		end
	end)

    -- ## ����������� ��������������� ������ ## --

    while true do
        wait(0)
        imgui.Process = true 

		if check_update then  
			downloadAll()
		end

        if control_spawn and elm.boolean.auto_login.v and not sampIsDialogActive() then  
            wait(10000)
            sampSendChat("/alogin " .. u8:decode(elm.input.password.v))
			wait(100)
			if elm.boolean.aclist_alogin.v then
				wait(1000)  
				sampSendChat("/aclist")
			end 
			if elm.boolean.ears_alogin.v then  
				wait(1000)
				sampSendChat("/ears")
				
			end  
			if elm.boolean.agm_alogin.v then  
				wait(1000)
				sampSendChat("/agm")
			end
            control_spawn = false
			wait(100)
			sampSendChat('/access')
        end

        if isKeyJustPressed(VK_RBUTTON) and not sampIsChatInputActive() and not sampIsDialogActive() and control_to_player and ATRecon.v then
			imgui.ShowCursor = not imgui.ShowCursor
			wait(600)
        end

		if atlibs.isKeysJustPressed(atlibs.strToIdKeys(config.keys.GiveOnline)) and not sampIsChatInputActive() and not sampIsDialogActive() and not ATMenu.v then 
			sampSendChat("/online")
			wait(100)
			local c = math.floor(sampGetPlayerCount(false) / 10)
			sampSendDialogResponse(1098, 1, c - 1)
			wait(1)
			sampCloseCurrentDialogWithButton(0)
			wait(650)
		end

        if isKeyJustPressed(VK_TAB) and elm.boolean.custom_tab.v then
			scoreboard.ActivetedScoreboard()
		end

		if atlibs.isKeysJustPressed(atlibs.strToIdKeys(config.keys.OpenReport)) and not sampIsChatInputActive() and not sampIsDialogActive() and not ATMenu.v then  
			lua_thread.create(function()
				sampSendChat("/ans ")
				sampSendDialogResponse(2348, 1, 0)
				wait(200)
			end)
		end

        if atlibs.isKeysJustPressed(atlibs.strToIdKeys(config.keys.WallHack)) and not ATMenu.v and not sampIsChatInputActive() and not sampIsDialogActive() then  
			pother.ActiveWallHack()
        end

        if atlibs.isKeysJustPressed(atlibs.strToIdKeys("R")) and ATRecon.v and not ATMenu.v and not sampIsChatInputActive() and not sampIsDialogActive() then
            sampSendClickTextdraw(refresh_button_textdraw)
			if other_res then  
				pother.ActivateKeySync(recon_id) 
			end
        end

        if atlibs.isKeysJustPressed(atlibs.strToIdKeys("Q")) and ATRecon.v and control_to_player and not ATMenu.v and not sampIsChatInputActive() and not sampIsDialogActive() then  
            sampSendChat("/reoff " )
            control_to_player = false
            imgui.ShowCursor = false 
			if other_res then  
				pother.ActivateKeySync("off") 
				recon_id = -1
			end
        end

		if atlibs.isKeysJustPressed(atlibs.strToIdKeys(config.keys.NextReconID)) and ATRecon.v and control_to_player and not ATMenu.v and not sampIsChatInputActive() and not sampIsDialogActive() then  
			sampSendChat('/re ' .. recon_id+1)
		end

		if atlibs.isKeysJustPressed(atlibs.strToIdKeys(config.keys.BackReconID)) and ATRecon.v and control_to_player and not ATMenu.v and not sampIsChatInputActive() and not sampIsDialogActive()then  
			sampSendChat('/re ' .. recon_id-1)
		end

		if atlibs.isKeysJustPressed(atlibs.strToIdKeys(config.keys.SendRP)) and sampIsChatInputActive() and not ATMenu.v then  
			local string = string.sub(sampGetChatInputText(), 0, string.len(sampGetChatInputText()) - 1)
			sampSetChatInputText(string .. " | �������� ���� �� RDS! <3")
			wait(650)
		end

		if atlibs.isKeysJustPressed(atlibs.strToIdKeys(config.keys.SendRecon)) and not ATMenu.v then  
			if sampIsChatInputActive() then  
				sampSetChatInputText("/re ")
			else
				lua_thread.create(function()
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/re " )
				end)
			end
		end

        if atlibs.isKeysJustPressed(atlibs.strToIdKeys(config.keys.GUI)) then  
            ATMenu.v = not ATMenu.v 
            imgui.Process = ATMenu.v
        end

		if elm.boolean.render_admins_imgui.v then  
			ATAdmins.v = true  
			if not control_to_player then  
				imgui.ShowCursor = false  
			end
		end

		if not sampIsPlayerConnected(recon_id) then
			ATRecon.v = false
			recon_id = -1
			control_to_player = false
			if other_res then
				pother.ActivateKeySync("off")
			end
		end

        if not ATMenu.v and not ATRecon.v and not ATAdmins.v then  
            imgui.Process = false  
            imgui.ShowCursor = false 
        end 

		if sampGetDialogCaption() == "{ff8587}������������� ������� (������)" and (elm.boolean.render_admins_imgui.v) then 
			sampCloseCurrentDialogWithButton(0)
		end	 

		if sampGetDialogCaption() == 'Mobile' and elm.boolean.recon_menu.v then  
			sampCloseCurrentDialogWithButton(1)
		end

        change_position_admins()

        if elm.position.change_recon then  
            change_position_recon() 
        end
    end
end

-- ## ���� ��������� �������, ��������� �� ������� � ����� ## -- 
function change_position_admins()
	if render_admin.set_position then  
		showCursor(true, false)
		local X, Y = getCursorPos()
		elm.position.acX, elm.position.acY = X, Y
		if isKeyJustPressed(49) then  
			showCursor(false, false)
			showNotification("��������� ���� ���������!")
			render_admin.set_position = false 
			config.position.acX, config.position.acY = elm.position.acX, elm.position.acY
			ConfigSave()
		end  
	end
end
-- ## ���� ��������� �������, ��������� �� ������� � ����� ## -- 

-- ## ���� ��������� ������� � ������� SA:MP ## --
function sampev.onPlayerJoin(id, color, npc, nickname)
	if #players_control_frame > 0 then
		for i, v in pairs(players_control_frame) do
			if v == nickname then  
				sampAddChatMessage(tag .. '����� � ����� ' .. v .. ' ����� � ����! ��� ID: ' .. id, -1)
			end 
		end
	end
end

function sampev.onShowDialog(id, style, title, button1, button2, text)
	if title == '{9980cc}���������� ���������' then
		if param_for_chgn ~= nil then
			local this_option = false
			sampAddChatMessage('test', -1)
			sampAddChatMessage("����.�����: " .. param_for_chgn, -1)
			dialog_text = atlibs.string_split(text, '\n')
			if tostring(param_for_chgn) then
				this_option = false
			elseif tonumber(param_for_chgn) then
				this_option = true
				name = sampGetPlayerNickname(tonumber(param_for_chgn))
			end
			for dialog_text_key, dialog_text_value in pairs(dialog_text) do
				if this_option == false then
					if dialog_text_value:match("{ffffff}ID:(.+)") then
						id_gang = dialog_text_value:match("ID:(.+)")
						id_gang = id_gang:gsub("{......}", "")
						param_for_chgn2 = id_gang
					end
				elseif this_option == true then
					if #name > 0 then
						if dialog_text_value:match("{ffffff}ID:(.+)") then
							id_gang = dialog_text_value:match("{ffffff}ID:(.+)")
							id_gang = id_gang:gsub("{......}", "")
							param_for_chgn2 = id_gang
						end
					else
						if dialog_text_value:match("{ffffff}ID:(.+)") then
							id_gang = dialog_text_value:match("{ffffff}ID:(.+)")
							id_gang = id_gang:gsub("{......}", "")
							param_for_chgn2 = id_gang
						end
					end
				end
			end
		end
	end
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
		return true  
	end

	if elm.boolean.access_scan.v then  
		if title:find(atlibs.getMyNick()) and id == 8991 then  
			lua_thread.create(function()
				text = atlibs.textSplit(text, '\n')
				for i, v in ipairs(text) do  
					if v:find('��� ���� �����') and v:find('�������') then  
						config.access.ban = true
						ConfigSave()
					elseif v:find('������ ����') and v:find('�������') then  
						config.access.mute = true
						ConfigSave()
					elseif v:find('������ ������') and v:find('�������') then  
						config.access.jail = true
						ConfigSave()
					end
					if v:find('��� ���� �����') and v:find('�����������') then  
						config.access.ban = false
						ConfigSave()
					elseif v:find('������ ����') and v:find('�����������') then  
						config.access.mute = false
						ConfigSave()
					elseif v:find('������ ������') and v:find('�����������') then  
						config.access.jail = false
						ConfigSave()
					end
				end
				sampAddChatMessage(tag .. '/access �������������. ��� ��������� ����� /access, ��������� ��������� ������� � ����������.', -1)
				wait(10)
				sampCloseCurrentDialogWithButton(0)
				elm.boolean.access_scan.v = false  
				config.access.scaning = elm.boolean.access_scan.v
				ConfigSave()
			end)
		end
	end

	if elm.boolean.render_admins_imgui.v then 
		if id == 0 and title:find("������������� �������") then
			admins = {}
			local j = 0
			text = text .. "\n"
			for i = 0, text:len()-1 do 
				local s = text:sub(i, i)
				if s == "\n" then 
					local line = text:sub(j, i)
					if line:find('(.+)%((%d+)%) %(%{(%x+)%}(.+)%)') then
						--sampAddChatMessage(nick .. " " .. id .. " " .. "{" .. color_prefix .. "}" .. " " .. prefix .. " " .. lvl_adm .. " " .. vig .. " " .. rep .. " " .. afk, -1)
						if line:find("AFK:") then
							local color_prefix, prefix = line:match('%(%{(%x+)%}(.+)%)')
							line = line:gsub("{......}", "")
							local nick, id, _, lvl, vig, rep, afk = line:match('(.+)%((%d+)%) %((.+)%) | �������: (%d+) | ��������: (%d+) �� 3 | ���������: (%d+) | AFK: (.+)')
							local admin = {
								nick = nick, 
								id = id, 
								color_prefix = color_prefix, 
								prefix = prefix, 
								lvl = lvl,
								vig = vig, 
								rep = rep,
								afk = afk
							}
							--sampAddChatMessage(nick .. " " .. id .. " " .. "{" .. color_prefix .. "}" .. " " .. prefix .. " " .. lvl .. " " .. vig .. " " .. rep .. " " .. afk, -1)
							-- sampAddChatMessage(nick .. id .. prefix .. lvl .. afk)
							table.insert(admins, admin)
						else
							local color_prefix, prefix = line:match('%(%{(%x+)%}(.+)%)')
							line = line:gsub("{......}", "")
							local nick, id, _, lvl, vig, rep = line:match("(.+)%((%d+)%) %((.+)%) | �������: (%d+) | ��������: (%d+) �� 3 | ���������: (%d+)")
							local admin = {
								nick = nick, 
								id = id, 
								color_prefix = color_prefix, 
								prefix = prefix, 
								lvl = lvl,
								rep = rep
							}
							--sampAddChatMessage(nick .. " " .. id .. " " .. "{" .. color_prefix .. "}" .. " " .. prefix .. " " .. lvl .. " " .. vig .. " " .. rep, -1)
							-- sampAddChatMessage(nick .. id .. prefix .. lvl)
							table.insert(admins, admin)
						end
					else 
						line = line:gsub("{......}", "")
						if line:find("AFK: (.+)") then
							local nick, id, lvl, vig, rep, afk = line:match("(.+)%((%d+)%) | �������: (%d+) | ��������: (%d+) �� 3 | ���������: (%d+) | AFK: (.+)")
							local admin = {
								nick = nick,
								id = id,
								lvl = lvl,
								vig = vig,
								rep = rep,
								afk = afk
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
		ATRecon.v = false
		sampSendChat("/reoff")
		pother.ActivateKeySync("off") 
        return true
    end
    if text:find("%[A%] ������������� (.+)%[(%d+)%] %(%d+ level%) ������������� � ����� ������") or text:find("%[A%-(%d+)%] (.+) ����������") then 
		sampAddChatMessage('{8B8B8B}' .. text, -1)
		if elm.boolean.render_admins_imgui.v then 
			sampSendChat("/admins ")
		end	
		return true 
	end	
	if elm.boolean.automultiply.v then
		if text:find("������������� .+ �������%(.+%) ������ .+ �� .+ ������. �������: .+") or text:find("������������� .+ �������%(.+%) ������ .+ � ������ �� .+ ������. �������: .+") or text:find("������������� .+ ������%(.+%) ������ � ������� ������ .+ �� .+ ������. �������: .+") then  
			if text:find('�������') then  
				_, nick_player, time, m_reason = text:match("������������� (.+) �������%(.+%) ������ (.+) �� (.+) ������. �������: (.+)")
			elseif text:find('�������') then  
				_, nick_player, time, m_reason = text:match("������������� (.+) �������%(.+%) ������ (.+) � ������ �� (.+) ������. �������: (.+)")
			elseif text:find('������%(.+%) ������ � ������� ������') then
				_, nick_player, time, m_reason = text:match("������������� (.+) ������%(.+%) ������ � ������� ������ (.+) �� (.+) ������. �������: (.+)")
			end
			lua_thread.create(function()
				for key in pairs(cmd_massive) do
					if m_reason:find(cmd_massive[key].reason) and cmd_massive[key].multi == true then   
						found = false
						changed = false
						current_time_hour, current_time_min, current_time_sec = string.match(os.date("%H:%M:%S"), "(%d+):(%d+):(%d+)")
						current_time_full = tonumber(current_time_hour) * 3600 + tonumber(current_time_min) * 60 + tonumber(current_time_sec)
						if #multiply_punish_frame > 0 then  
							for i, v in pairs(multiply_punish_frame) do  
								if v:find(nick_player) and m_reason:find("(.+) x(%d+)") then  
									if v:find("%d+:%d+:%d+") then
										time_stamp = v:match("%d+:%d+:%d+")
										hour, min, sec = string.match(time_stamp, "(%d+):(%d+):(%d+)")
										fulltimestamp = tonumber(hour) * 3600 + tonumber(min) * 60 + tonumber(sec)
										if current_time_full - fulltimestamp >= 30 then 
											keying = i
											if not changed then 
												sampAddChatMessage(tag .. '������������� �������� ��������� ��������� �� ��������� ��� ������: ' .. nick_player, -1)
												changed = true
											end 
											if text:find('������ %(.+%) ������ � ������� ������') then
												multiply_punish_frame[i] = nick_player .. "~" .. cmd_massive[key].reason .. "~" .. tonumber(time)+tonumber(cmd_massive[key].time) .. "~" .. os.date("%H:%M:%S") .. '~' .. 'report'
											elseif text:find('�������%(.+%)') then
												multiply_punish_frame[i] = nick_player .. "~" .. cmd_massive[key].reason .. "~" .. tonumber(time)+tonumber(cmd_massive[key].time) .. "~" .. os.date("%H:%M:%S") .. '~' .. 'basemute'
											else 
												multiply_punish_frame[i] = nick_player .. "~" .. cmd_massive[key].reason .. "~" .. tonumber(time)+tonumber(cmd_massive[key].time) .. "~" .. os.date("%H:%M:%S")
											end
											found = true
											break
										else 
											found = true  
											break
										end
									end
								end 
							end 
							if not found then  
								if text:find('������ %(.+%) ������ � ������� ������') then
									table.insert(multiply_punish_frame, nick_player .. "~" .. cmd_massive[key].reason .. "~" .. tonumber(time)+tonumber(cmd_massive[key].time) .. "~" .. os.date("%H:%M:%S") .. '~' .. 'report')
								elseif text:find('�������%(.+%)') then
									table.insert(multiply_punish_frame, nick_player .. "~" .. cmd_massive[key].reason .. "~" .. tonumber(time)+tonumber(cmd_massive[key].time) .. "~" .. os.date("%H:%M:%S") .. '~' .. 'basemute')
								else
									table.insert(multiply_punish_frame, nick_player .. "~" .. cmd_massive[key].reason .. "~" .. tonumber(time)+tonumber(cmd_massive[key].time) .. "~" .. os.date("%H:%M:%S"))
								end
								if not changed then  
									sampAddChatMessage(tag .. '������������� �������� ��������� ��������� �� ��������� ��� ������: ' .. nick_player, -1)
									changed = true  
								end
								break
							end
						else 
							sampAddChatMessage(tag .. '������������� �������� ��������� ��������� �� ��������� ��� ������: ' .. nick_player, -1)				
							if text:find('������ %(.+%) ������ � ������� ������') then	
								table.insert(multiply_punish_frame, nick_player .. "~" .. cmd_massive[key].reason .. "~" .. tonumber(time)+tonumber(cmd_massive[key].time) .. "~" .. os.date("%H:%M:%S") .. '~' .. 'report')
							elseif text:find('�������%(.+%)') then
								table.insert(multiply_punish_frame, nick_player .. "~" .. cmd_massive[key].reason .. "~" .. tonumber(time)+tonumber(cmd_massive[key].time) .. "~" .. os.date("%H:%M:%S") .. '~' .. 'basemute')
							else
								table.insert(multiply_punish_frame, nick_player .. "~" .. cmd_massive[key].reason .. "~" .. tonumber(time)+tonumber(cmd_massive[key].time) .. "~" .. os.date("%H:%M:%S"))
							end
						end
						break
					end
				end  
			end)
		end
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
end

function sampev.onDisplayGameText(style, time, text)
	if text == "~w~RECON ~r~OFF" and elm.boolean.recon_menu.v then  
		control_to_player = false
        ATRecon.v = false  
        imgui.Process = ATRecon.v
        imgui.ShowCursor = false  
		if other_res then
			pother.ActivateKeySync("off") 
		end
        recon_id = -1
	end
	if text == "~y~REPORT++" then  
		if elm.boolean.push_report.v then  
			showNotification('�������� ����� ������.\n\n���� TakeReport �������, \n�� �� ������� ��������.')
		end  
		if elm.boolean.takereport.v then  
			sampAddChatMessage(tag .. '������������� ���� ������.')
			sampSendChat("/ans")
			sampSendDialogResponse(2348, 1, 0)
		end  
		return true
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
		if data.text:find('~g~::Health:~n~') then  
			return false
		end
		if data.text:find('REFRESH') then  
			refresh_button_textdraw = id  
			return false  
		end
		if data.text:find('(%d+) : (%d+)') then  
			info_textdraw_recon = id  
			return false
		end
		for _, v in pairs(text_recon) do  
			if data.text:find(v) then  
				if id ~= 244 then 
					return false  
				end
			end 
		end
		if data.text:find("(%d+)") then  
			if id == 2052 then  
				return false  
			end  
		end
		if ids_recon[id] then  
			return false 
		end
		if data.text:find('CLOSE') or id == 244 then  
			return true  
		end
    end
end

function sampev.onTextDrawSetString(id, text) 
    if id == info_textdraw_recon and elm.boolean.recon_menu.v then  
        info_to_player = atlibs.textSplit(text, "~n~")
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
			lua_thread.create(function()
				wait(500)
				if other_res then  
					pother.ActivateKeySync(tonumber(id))
				end
			end)
        end 
        recon_id = id 
    end 
    if command == "/reoff" then  
        control_to_player = false
        ATRecon.v = false  
        imgui.Process = ATRecon.v
        imgui.ShowCursor = false  
        recon_id = -1
		pother.ActivateKeySync("off")
    end 
	if elm.boolean.access_scan.v and not elm.boolean.auto_login.v then  
		if string.find(command, '/alogin (.+)') then  
			sampSendChat('/access')
		end 
	end
	if elm.boolean.auto_prefix.v then  
		if command == '/admins' then  
			lua_thread.create(function()
				wait(1000)
				if #admins > 0 then  
					for i = 1, #admins do  
						local admin = admins[i]
						if tonumber(admin.lvl) < 10 then  
							prefix_send = tostring(config.colours.prefix_MA):match("{(.+)}")
							sampSendChat("/prefix " .. admin.id .. " ��.������������� " .. prefix_send)
						elseif tonumber(admin.lvl) < 15 then  
							prefix_send = tostring(config.colours.prefix_ADM):match("{(.+)}")
							sampSendChat("/prefix " .. admin.id .. " ������������� " .. prefix_send)
						elseif tonumber(admin.lvl) <= 18 then  
							prefix_send = tostring(config.colours.prefix_STA):match("{(.+)}")
							sampSendChat("/prefix " .. admin.id .. " ��.������������� " .. prefix_send)
						end 
					end  
				end  
			end)
		end
	end
end
-- ## ���� ��������� ������� � ������� SA:MP ## -- 

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
	    sampSendChat("/unrmute " .. arg)
	    sampSendChat("/ans " .. arg .. " ���������� �� ������, ��������� �����. �������� ����.")
    end)
end
-- ## ���� ������� � ��������������� �������� ## --

-- ## ���� ������� ��������� � ������� ## --
function loadRecon() 
    wait(1000)
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
			if imgui.Button(fai.ICON_FA_HOME, imgui.ImVec2(27,0)) then  
				menuSelect = 0 
			end; imgui.Tooltip(u8'��������� ����')
            if imgui.Button(fai.ICON_FA_USER_COG, imgui.ImVec2(27,0)) then  
                menuSelect = 1 
            end; imgui.Tooltip(u8"������� ��")
            if imgui.Button(fa.ICON_FA_KEYBOARD, imgui.ImVec2(27,0)) then  
                menuSelect = 2 
            end; imgui.Tooltip(u8"�������/������� �������")
            if imgui.Button(fai.ICON_FA_BAN, imgui.ImVec2(27,0)) then  
                menuSelect = 3
            end; imgui.Tooltip(u8"������� ������ ���������")
			if imgui.Button(fai.ICON_FA_LIST_OL, imgui.ImVec2(27,0)) then  
				menuSelect = 7 
			end; imgui.Tooltip(u8'���������������� ����������')
            if imgui.Button(fai.ICON_FA_TH_LIST, imgui.ImVec2(27,0)) then  
                menuSelect = 4 
            end; imgui.Tooltip(u8"������������� ������ ��")
			if imgui.Button(fa.ICON_CALCULATOR, imgui.ImVec2(27,0)) then  
				menuSelect = 5
			end; imgui.Tooltip(u8"������ ������� ��� �������� (/ans)")
			if imgui.Button(fa.ICON_FA_CROSSHAIRS, imgui.ImVec2(27,0)) then  
				menuSelect = 8
			end; imgui.Tooltip(u8'�������� ����')
			if imgui.Button(fai.ICON_FA_TOOLS, imgui.ImVec2(27,0)) then  
				menuSelect = 6
			end; imgui.Tooltip(u8"�������������� �������")
            if imgui.Button(fa.ICON_FA_COGS, imgui.ImVec2(27,0)) then  
                menuSelect = 15 
            end; imgui.Tooltip(u8"��������� AT")
			if imgui.Button(fai.ICON_FA_POWER_OFF, imgui.ImVec2(27,0)) then  
				showNotification('���������� �������� ��������. ����������!')
				if plugins_main_res then  
					plugin.OffScript()
				end  
				if adminstate_res then  
					admst.OffScript()
				end  
				if renders_res then  
					prender.OffScript()
				end
				thisScript():unload()
			end; imgui.Tooltip(u8'���������� ������ �������� ��.')
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
					imgui.Text(u8"��������� ������������� ������")
					imgui.SameLine()
					if imgui.ToggleButton('##Imgui', elm.boolean.render_admins_imgui) then  
						config.main.render_admins_imgui = elm.boolean.render_admins_imgui.v  
						ConfigSave()
					end
                    if imgui.Button(fa.ICON_FA_COGS  .. u8" ��������� ������� �������") then  
						showNotification('��� ���������� ������� ����, \n������� ����� �� ��������� <1>')
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
				if plugins_main_res then
					plugin.ActiveForms()
				end
				imgui.Text(fai.ICON_FA_PLUS .. ' AutoTakeReport'); imgui.Tooltip(u8'��������� ������������������ ������ AutoTakeReport �� ��.')
				imgui.SameLine()
				if imgui.ToggleButton('##AutoTakeReport', elm.boolean.takereport) then  
					config.main.takereport = elm.boolean.takereport.v  
					ConfigSave()
				end
				imgui.Text(fai.ICON_FA_USER_MINUS .. u8' ����-�������'); imgui.Tooltip(u8'������������� ������ �������� ���� ���, � ���� �� ���. ��� ������, ������� /admins\n\n����� ��������� � ���������� � ������ � ������� {RRGGBB}. ������: {FF00FF}')
				imgui.SameLine()
				if imgui.ToggleButton('##AutoPrefixGive', elm.boolean.auto_prefix) then  
					config.main.auto_prefix = elm.boolean.auto_prefix.v  
					ConfigSave()
				end
				imgui.Text(fai.ICON_FA_USER_TIMES .. u8' ����-���������'); imgui.Tooltip(u8'������������� ������� ��������� ��� ������ ������ � ���� �� ��������� ������ � ���� �� ������������.')
				imgui.SameLine()
				if imgui.ToggleButton('##AutoMultiplier', elm.boolean.automultiply) then
					config.main.automultiply = elm.boolean.automultiply.v
					ConfigSave()
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
				if other_res then  
					pother.TranslateCmd()
					pother.ActiveGUIWH()
					pother.KeySyncToggle()
				end
        end

        if menuSelect == 2 then  
            imgui.TextWrapped(u8"����� ����� ��������� ���� ������� ������� ��� �������� �������������� � �����, �� � �.�.")
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
			imgui.Separator()
            imgui.Text(u8"��������� ����� � ������:  ")
            imgui.SameLine()
            if tonumber(config.keys.NextReconID) then  
                imgui.Text(tostring(config.keys.NextReconID))
            else 
                imgui.Text(config.keys.NextReconID)
            end  
            imgui.SameLine()
            imgui.SetCursorPosX(imgui.GetWindowWidth() - 200)
            if imgui.Button(u8"�������� ##5", imgui.ImVec2(75,0)) then  
                config.keys.NextReconID = atlibs.getDownKeysText()
                ConfigSave()
            end  
            imgui.SameLine()
            if imgui.Button(u8"�������� ##5") then  
                config.keys.NextReconID = "None"
                ConfigSave()
            end
			imgui.Separator()
			imgui.Text(u8"���������� ����� � ������:  ")
            imgui.SameLine()
            if tonumber(config.keys.BackReconID) then  
                imgui.Text(tostring(config.keys.BackReconID))
            else 
                imgui.Text(config.keys.BackReconID)
            end  
            imgui.SameLine()
            imgui.SetCursorPosX(imgui.GetWindowWidth() - 200)
            if imgui.Button(u8"�������� ##6", imgui.ImVec2(75,0)) then  
                config.keys.BackReconID = atlibs.getDownKeysText()
                ConfigSave()
            end  
            imgui.SameLine()
            if imgui.Button(u8"�������� ##6") then  
                config.keys.BackReconID = "None"
                ConfigSave()
            end
			imgui.Separator()
			imgui.Text(u8"�������� �������� ����:  ")
            imgui.SameLine()
            if tonumber(config.keys.SendRP) then  
                imgui.Text(tostring(config.keys.SendRP))
            else 
                imgui.Text(config.keys.SendRP)
            end  
            imgui.SameLine()
            imgui.SetCursorPosX(imgui.GetWindowWidth() - 200)
            if imgui.Button(u8"�������� ##7", imgui.ImVec2(75,0)) then  
                config.keys.SendRP = atlibs.getDownKeysText()
                ConfigSave()
            end  
            imgui.SameLine()
            if imgui.Button(u8"�������� ##7") then  
                config.keys.SendRP = "None"
                ConfigSave()
            end
			imgui.Separator()
			imgui.Text(u8"�������������� ���� /re � ���:  ")
            imgui.SameLine()
            if tonumber(config.keys.SendRecon) then  
                imgui.Text(tostring(config.keys.SendRecon))
            else 
                imgui.Text(config.keys.SendRecon)
            end  
            imgui.SameLine()
            imgui.SetCursorPosX(imgui.GetWindowWidth() - 200)
            if imgui.Button(u8"�������� ##8", imgui.ImVec2(75,0)) then  
                config.keys.SendRecon = atlibs.getDownKeysText()
                ConfigSave()
            end  
            imgui.SameLine()
            if imgui.Button(u8"�������� ##8") then  
                config.keys.SendRecon = "None"
                ConfigSave()
            end
			imgui.Separator()
			imgui.Text(u8'������������� ��������:  ')
			imgui.SameLine()
			if tonumber(config.keys.AgreeMute) then  
				imgui.Text(tostring(config.keys.AgreeMute))
			else 
				imgui.Text(config.keys.AgreeMute)
			end  
			imgui.SameLine()
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 200)
			if imgui.Button(u8"�������� ##9", imgui.ImVec2(75,0)) then  
				config.keys.AgreeMute = atlibs.getDownKeysText()
				ConfigSave()
			end  
			imgui.SameLine()
			if imgui.Button(u8"�������� ##9") then  
				config.keys.AgreeMute = "None"
				ConfigSave()
			end
			imgui.Separator()
        end

        if menuSelect == 3 then  
            imgui.TextWrapped(u8"����� ������� ������������ ������� ��� ���������� ������ ���������. ������ ������� ����������� �� ������� �������� �������. ����� �����, ����� ����������� ��� ��������� �������, ������������ � ��.")
			imgui.TextWrapped(u8'����� ��� ������� ��� ����� ���������� ���������� � �� �������, �������������� ������� ��� �� ����� � ���.')
			imgui.TextWrapped(u8'��� ������� �� ������� � ������� �����, ��� ���������� � ���')
			imgui.Separator()
            if imgui.TreeNode(u8"��������� � �������") then 
                if imgui.TreeNode("Ban") then  
					for key in pairs(cmd_massive) do  
						if cmd_massive[key].cmd == '/iban' or cmd_massive[key].cmd == '/ban' or cmd_massive[key].cmd == '/siban' or cmd_massive[key].cmd == '/sban'then  
							imgui.TextWrapped(u8'/'..key..u8' [ID] - ' .. u8(cmd_massive[key].reason))
							if cmd_massive[key].tip then  
								imgui.TextWrapped(u8('		' ..cmd_massive[key].tip))
							end
						end 
					end 
                    imgui.TreePop()
                end
                if imgui.TreeNode("Jail") then  
					for key in pairs(cmd_massive) do
						if cmd_massive[key].cmd == "/jail" then
							imgui.TextWrapped(u8'/'..key..u8' [ID] - ' .. u8(cmd_massive[key].reason))
						end
					end

                    imgui.TreePop()
                end
                if imgui.TreeNode(u8"Mute �� ������� ���") then  
					for key in pairs(cmd_massive) do
						if cmd_massive[key].cmd == "/mute" then
							imgui.TextWrapped(u8'/'..key..u8' [ID] - ' .. u8(cmd_massive[key].reason))
						end
					end
                    imgui.TreePop()
                end
				if imgui.TreeNode(u8'Mute �� ������') then  
					for key in pairs(cmd_massive) do  
						if cmd_massive[key].cmd == "/rmute" then  
							imgui.TextWrapped(u8'/'..key..u8' [ID] - ' .. u8(cmd_massive[key].reason))
						end 
					end 
					imgui.TreePop()
				end
                if imgui.TreeNode("Kick") then  
					for key in pairs(cmd_massive) do
						if cmd_massive[key].cmd == "/kick" then
							imgui.TextWrapped(u8'/'..key..u8' [ID] - ' .. u8(cmd_massive[key].reason))
						end
					end
                    imgui.TreePop()
                end
                imgui.TreePop()
            end

            if imgui.TreeNode(u8"��������� � ��������") then  
                if imgui.TreeNode("Ban") then  
					for key in pairs(cmd_massive) do
						if cmd_massive[key].cmd == "/banakk" or cmd_massive[key].cmd == '/offban' or cmd_massive[key].cmd == '/banip' then
							imgui.TextWrapped(u8'/'..key..u8' [NickName] - ' .. u8(cmd_massive[key].reason))
						end
					end
                    imgui.TreePop()
                end
                if imgui.TreeNode("Jail") then  
					for key in pairs(cmd_massive) do
						if cmd_massive[key].cmd == "/jailakk" or cmd_massive[key].cmd == '/jailoff' then
							imgui.TextWrapped(u8'/'..key..u8' [NickName] - ' .. u8(cmd_massive[key].reason))
						end
					end
                    imgui.TreePop()
                end
                if imgui.TreeNode(u8"Mute �� ������� ���") then  
					for key in pairs(cmd_massive) do
						if cmd_massive[key].cmd == "/muteakk" then
							imgui.TextWrapped(u8'/'..key..u8' [NickName] - ' .. u8(cmd_massive[key].reason))
						end
					end
                    imgui.TreePop()
                end
				if imgui.TreeNode(u8"Mute �� ������") then  
					for key in pairs(cmd_massive) do
						if cmd_massive[key].cmd == "/rmuteakk" then
							imgui.TextWrapped(u8'/'..key..u8' [NickName] - ' .. u8(cmd_massive[key].reason))
						end
					end
					imgui.TreePop()
				end
                imgui.TreePop()
            end

			if imgui.TreeNode(u8"������� ������ (����.)") then  
				for key in pairs(cmd_helper_answers) do  
					imgui.TextWrapped(u8'/'..key..u8' [ID] - ' .. u8(cmd_helper_answers[key].reason))
				end
				imgui.TreePop()
			end

            if imgui.TreeNode(u8"�������������� ������� AT") then  
				for key in pairs(cmd_helper_others) do 
					imgui.TextWrapped(u8'/'..key..u8' ' .. u8(cmd_helper_others[key].reason))
					if cmd_helper_others[key].tip then  
						imgui.TextWrapped(u8(cmd_helper_others[key].tip))
					end
				end
                imgui.TreePop()
            end
        end

        if menuSelect == 4 then  
            showFlood_ImGUI()
        end

		if menuSelect == 5 then  
			elem_temp = imgui.ImBool(configReports.main.interface)
			if imgui.ToggleButton(u8'��������� ���������� ��� ������ �� �������', elem_temp) then  
				configReports.main.interface = elem_temp.v
				inicfg.save(configReports, directReports)
			end; imgui.Tooltip(u8"��������� �������� GUI ��� ������� �� ������� (���������� ����������� ������)")
			imgui.Separator()
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
						elm.binder.reports.text.v = returnwrapped
						elm.binder.reports.name.v = tostring(configReports.bind_name[key_bind])
						elm.binder.reports.delay.v = tostring(configReports.bind_delay[key_bind])
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
				imgui.InputText("##binder_name", elm.binder.reports.name)
				imgui.PopItemWidth()
				imgui.PushItemWidth(100)
				imgui.Separator()
				imgui.Text(u8'����� �����:')
				imgui.PushItemWidth(300)
				imgui.InputTextMultiline("##BinderS", elm.binder.reports.text, imgui.ImVec2(-1, 110))
				imgui.PopItemWidth()
		
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 100)
				if imgui.Button(u8'�������##bind1', imgui.ImVec2(100,30)) then
					elm.binder.reports.name.v, elm.binder.reports.text.v, elm.binder.reports.delay.v = '', '', "2500"
					imgui.CloseCurrentPopup()
				end
				imgui.SameLine()
				if #elm.binder.reports.name.v > 0 and #elm.binder.reports.text.v > 0 then
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 1.01)
					if imgui.Button(u8'���������##bind1', imgui.ImVec2(100,30)) then
						if not EditOldBind then
							local refresh_text = elm.binder.reports.text.v:gsub("\n", "~")
							table.insert(configReports.bind_name, elm.binder.reports.name.v)
							table.insert(configReports.bind_text, refresh_text)
							table.insert(configReports.bind_delay, elm.binder.reports.delay.v)
							if inicfg.save(configReports, directReports) then
								sampAddChatMessage(tag .. '���� "' ..u8:decode(elm.binder.reports.name.v).. '" ������� ������!', -1)
								elm.binder.reports.name.v, elm.binder.reports.text.v, elm.binder.reports.delay.v = '', '', "0"
							end
								imgui.CloseCurrentPopup()
							else
								local refresh_text = elm.binder.reports.text.v:gsub("\n", "~")
								table.insert(configReports.bind_name, getpos, elm.binder.reports.name.v)
								table.insert(configReports.bind_text, getpos, refresh_text)
								table.insert(configReports.bind_delay, getpos, elm.binder.reports.delay.v)
								table.remove(configReports.bind_name, getpos + 1)
								table.remove(configReports.bind_text, getpos + 1)
								table.remove(configReports.bind_delay, getpos + 1)
							if inicfg.save(configReports, directReports) then
								sampAddChatMessage(tag .. '���� "' ..u8:decode(elm.binder.reports.name.v).. '" ������� ��������������!', -1)
								elm.binder.reports.name.v, elm.binder.reports.text.v, elm.binder.reports.delay.v = '', '', "0"
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
			if not plugins_main_res and not renders_res then
				imgui.TextWrapped(u8'�� ��������� ������ ������ � ���������� �������. ���� �����, �������� ���. ��������� (������ "����������") -> ��������� �������')
			else
				if plugins_main_res then  
					plugin.ActiveATChat()
				end
				if renders_res then  
					prender.ActiveChatRenders()
				end
			end
		end

		if menuSelect == 7 then  
			if adminstate_res then  
				admst.AdminStateMenu()
			else
				imgui.TextWrapped(u8'�� ��������� ������ ������ � ���������� �������. ���� �����, �������� ���. ��������� (������ "����������") -> ��������� �������')
			end  
		end

		if menuSelect == 8 then  
			if other_res then  
				pother.ActivatedBulletTrack()
			else 
				imgui.TextWrapped(u8'�� ��������� ������ ������ � ���������� �������. ���� �����, �������� ���. ��������� (������ "����������") -> ��������� �������')
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
			if other_res then  
				pother.ChangeFontHelp()
			end
			elm.binder.reports.prefix.v = configReports.main.prefix_for_answer 
			imgui.Separator()
			imgui.Text(u8"������� ��� ������ � /ans: ")
			if imgui.InputText("##EditPrefixForAnswer", elm.binder.reports.prefix) then  
				configReports.main.prefix_for_answer = elm.binder.reports.prefix.v  
				inicfg.save(configReports, directReports)
			end
			imgui.Text(u8'���������/���������� ����������� �������� � /ans')
			imgui.SameLine()
			if imgui.ToggleButton('##PrefixForAnswer', elm.boolean.prefix_answer) then
				configReports.main.prefix_answer = elm.boolean.prefix_answer.v 
				inicfg.save(configReports, directReports)
			end
			imgui.Separator()
			imgui.Text(u8'������������ /access'); imgui.Tooltip(u8'���������/�������� ������������ ��� ������ ����� /access. ����� ������������ ��� /alogin')
			imgui.SameLine()
			if imgui.ToggleButton('##AccessScaning', elm.boolean.access_scan) then  
				config.access.scaning = elm.boolean.access_scan.v  
				ConfigSave()
			end
			imgui.Separator()
			imgui.Text(u8'�������������� AdminTool')
			imgui.SameLine()
			if imgui.ToggleButton('##AutoUpdateAT', elm.boolean.autoupdate) then  
				config.main.autoupdate = elm.boolean.autoupdate.v  
				ConfigSave()
			end
			imgui.Separator()
			if automute_res then  
				automute.ReadWriteAM()
			end
			if imgui.Button(fai.ICON_FA_UPLOAD .. u8" ���������� AdminTool") then  
				imgui.OpenPopup('Update AT')
			end
			imgui.SameLine()
			if imgui.Button(fai.ICON_FA_FILE_CODE .. u8" ��������� �������") then  
				imgui.OpenPopup('Settings Start')
			end
			if imgui.Button(u8' ������� ������������� �����������') then  
				downloadUrlToFile(urls['eventsForOwn'], paths['eventsForOwn'], function(id, status)
					if status == dlstatus.STATUS_ENDDOWNLOADDATA then
						sampAddChatMessage(tag .. '���� � �������������� ������������� ����������.')
						reloadScripts()
					end
				end)
			end; imgui.Tooltip(u8'�����! ��� ���� ��������� ����������� ����� �������! ���� �������� �������� ������!\n\n��������� �����������, ���� �� �� ��������\n\n���� ��������� �� ���� ������ ���� -> moonloader -> config -> AdminTool -> evbinder.ini')
			if imgui.TreeNode(u8'������ ���������������� ���������') then  
				if imgui.InputText(u8'��.�������������', elm.input.prefix_MA) then  
					config.colours.prefix_MA = elm.input.prefix_MA.v  
					ConfigSave()
				end
				if imgui.InputText(u8'�������������', elm.input.prefix_ADM) then  
					config.colours.prefix_ADM = elm.input.prefix_ADM.v  
					ConfigSave()
				end
				if imgui.InputText(u8'��.�������������', elm.input.prefix_STA) then  
					config.colours.prefix_STA = elm.input.prefix_STA.v  
					ConfigSave()
				end
				if imgui.InputText(u8'���.��.��������������', elm.input.prefix_ZGA) then  
					config.colours.prefix_ZGA = elm.input.prefix_ZGA.v  
					ConfigSave()
				end
				if imgui.InputText(u8'��.�������������', elm.input.prefix_GA) then  
					config.colours.prefix_GA = elm.input.prefix_GA.v  
					ConfigSave()
				end
				imgui.TreePop()
			end
			if imgui.BeginPopupModal('Update AT', false, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then  
				imgui.BeginChild('##FrameUpdateAdminTool', imgui.ImVec2(400, 200), true)
				imgui.Checkbox(u8'�������� ������', upd_upvalue.main) 
				imgui.Checkbox(u8'�������� ������ ��������������� �������', upd_upvalue.pluginsAT)
				imgui.Checkbox(u8'������ ��������� �������', upd_upvalue.otherAT)
				imgui.Checkbox(u8'���������� AdminTool', upd_upvalue.libs)
				imgui.Checkbox(u8'���������������� ����������', upd_upvalue.adminstate)
				imgui.Checkbox(u8'������ ������� ���.����� ����', upd_upvalue.renders)
				imgui.Checkbox(u8'������� �����������', upd_upvalue.notf)
				imgui.Checkbox(u8'������ ����������', upd_upvalue.addons)
				imgui.Checkbox(u8'��������� ����������', upd_upvalue.scoreboard)
				imgui.Checkbox(u8'������ ��� ������� �� �������', upd_upvalue.answers)
				imgui.Checkbox(u8'������ ������', upd_upvalue.commands)
				imgui.Checkbox(u8'���-������', upd_upvalue.chatlogger)
				imgui.Checkbox(u8'������� �����������', upd_upvalue.events)
				imgui.EndChild()
				if imgui.Button(u8'�������� ���������') then  
					lua_thread.create(function()
						for i, param in pairs(upd_upvalue) do  
							if param.v then  
								downloadUrlToFile(urls[i], paths[i], function(id, status)
									if status == dlstatus.STATUS_ENDDOWNLOADDATA then  
										sampfuncsLog(log .. '���� ������� ������. ����������� ������ ��������� :D')
									end
								end)
							end 
						end  
						sampAddChatMessage(tag .. '������� ��������������� ����, �� ����� ������� ������������ ������ 10 ������.', -1)
						wait(10000)
						sampAddChatMessage(tag .. '������������� �������', -1)
						reloadScripts()
					end)
				end
				imgui.SameLine()
				if imgui.Button(u8'�������� ���') then  
					sampAddChatMessage(tag .. '�������� ��������� ��������� ���� ����� ��. ��������!', -1)
					downloadAll()
				end 
				imgui.SameLine()
				imgui.SetCursorPosX(350)
				if imgui.Button(u8'�������') then  
					imgui.CloseCurrentPopup()
				end
				imgui.EndPopup()
			end
			if imgui.BeginPopupModal('Settings Start', false, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then  
				imgui.BeginChild('##FrameSettingsStart', imgui.ImVec2(300, 300), true)
				imgui.TextWrapped(u8'��� �������� ������� ������ ����� ������������ ��� �������.')
				if imgui.Checkbox(u8'�������� ������ ��������������� �������', elm.settings_start.plugins_main) then  
					config.settings_start.plugins_main = elm.settings_start.plugins_main.v  
					ConfigSave()  
				end; imgui.Tooltip(u8'������ � ���� ��������:\n1. ���������������� �����\n2. ����� ���������� ����������������� ����')
				if imgui.Checkbox(u8'������ ������� ��������� ����� ����', elm.settings_start.renders) then  
					config.settings_start.renders = elm.settings_start.renders.v 
					ConfigSave()
				end; imgui.Tooltip(u8"������ � ���� ��������:\n1. ����� ��������� �����, ����� ���: /pm, /report � /d")
				if imgui.Checkbox(u8'������ - �����.�����', elm.settings_start.adminstate) then  
					config.settings_start.adminstate = elm.settings_start.adminstate.v  
					ConfigSave()
				end; imgui.Tooltip(u8'������ � ���� ��������:\n1. ����� ���������������� ����������.')
				if imgui.Checkbox(u8'������ - �������', elm.settings_start.automute) then  
					config.settings_start.automute = elm.settings_start.automute.v 
					ConfigSave()
				end; imgui.Tooltip(u8'������ � ���� ��������:\n1. ������� �� ���, ���, ��� ������ � ����.����.��������')
				if imgui.Checkbox(u8'������ ��������� �������', elm.settings_start.others) then  
					config.settings_start.others = elm.settings_start.others.v  
					ConfigSave()
				end; imgui.Tooltip(u8'������ � ���� ��������:\n1. ������� ������\n2. InputHelper\n3. WallHack \n4. BulletTrack')
				imgui.EndChild()
				if imgui.Button(u8'������������� �������') then  
					reloadScripts()
				end; imgui.Tooltip(u8'��� ������ ��������, ��������� ������� ������������ �� �����.')
				imgui.SameLine()
				imgui.SetCursorPosX(250)
				if imgui.Button(u8'�������') then  
					imgui.CloseCurrentPopup()
				end
				imgui.EndPopup()
			end
        end
        
        imgui.End()
    end

	if ATAdmins.v then -- ������ /admins � ImGUI
		imgui.SetNextWindowPos(imgui.ImVec2(elm.position.acX, elm.position.acY), imgui.Cond.FirsUseEver, imgui.ImVec2(0.5, 1))

		imgui.Begin("##RenderAdmins", false, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize)

			if #admins > 0 then  
				for i = 1, #admins do 
					local admin = admins[i]
					local text  
					if admin.prefix then  
						if admin.afk then
							text = string.format("%s[%s] {%s}%s | A-%s | AFK: %s ", admin.nick, admin.id, admin.color_prefix, admin.prefix, admin.lvl, admin.afk)
						else 
							text = string.format("%s[%s] {%s}%s | A-%s", admin.nick, admin.id, admin.color_prefix, admin.prefix, admin.lvl)							
						end
					else 
						if admin.afk then
							text = string.format("%s[%s] | A-%s | AFK: %s", admin.nick, admin.id, admin.lvl, admin.afk)
						else
							text = string.format("%s[%s] | A-%s", admin.nick, admin.id, admin.lvl)
						end
					end  
					text = text:gsub("\n", "")
					atlibs.imgui_TextColoredRGB(text)
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
                sampSendClickTextdraw(refresh_button_textdraw)
				if other_res then  
					pother.ActivateKeySync(recon_id)
				end
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
				if other_res then  
					pother.ActivateKeySync("off") 
				end
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
								if not sampIsPlayerConnected(recon_id) then
                                	recon_nick = '-'
								else 
									recon_nick = sampGetPlayerNickname(recon_id)
								end
                                imgui.Text(u8"�����: ")
                                imgui.Text(recon_nick); imgui.Tooltip(u8'��� �������, ��� ������ �����������.')
                                if imgui.IsItemClicked() then  
                                    imgui.LogToClipboard()
                                    imgui.LogText(recon_nick)
                                    imgui.LogFinish()
                                end
                                imgui.SameLine()
                                imgui.Text("[" .. recon_id .. "]")
								id_spectator = "" .. recon_id
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
										if key == 11 then  
											local lvl = string.match(info_to_player[11], "(%d+)")
											local str_lvl = ''
											if tonumber(lvl) == 0 then
												str_lvl = u8'�� �������.'
											elseif tonumber(lvl) == 1 then
												str_lvl = u8'�������'
											elseif tonumber(lvl) == 2 then
												str_lvl = u8'�������'
											elseif tonumber(lvl) == 3 then
												str_lvl = u8'Diamond'
											elseif tonumber(lvl) == 4 then
												str_lvl = u8'Platinum'
											elseif tonumber(lvl) == 5 then
												str_lvl = u8'Personal'
											end
											imgui.Text(u8:encode(recon_info[key]) .. " " .. str_lvl)
										elseif key == 15 then  
											local chkdrv = string.match(info_to_player[15], '(.+)')
											if chkdrv == 'DISABLED' then  
												imgui.Text(u8:encode(recon_info[key]) .. " " .. u8'���������')
											elseif chkdrv == 'ENABLED' then
												imgui.Text(u8:encode(recon_info[key]) .. " " .. u8'��������')
											end
										else 
											imgui.Text(u8:encode(recon_info[key]) .. " " .. info_to_player[key])
										end
                                    end
                                end
								imgui.Separator()
								if imgui.Button(u8'�������������� � �������') then  
									imgui.OpenPopup('ReconWithSpecterPlayer')
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
								imgui.Separator()
								imgui.TextWrapped(u8'��� ��������� �������: ��� (F).')
								imgui.TextWrapped(u8'R - �������� �����. \nQ - ����� �� ������.')
								if imgui.BeginPopup('ReconWithSpecterPlayer') then  
									if imgui.Button(u8'����������') then  
										sampSendChat('/statpl ' .. recon_id)
									end; imgui.Tooltip(u8'��������� �������� ������� ���������� - /statpl')
									if imgui.Button(u8'���-���� ����������') then  
										sampSendChat('/offstats ' .. recon_nick)
										lua_thread.create(function()
											wait(200)
											sampSendDialogResponse(16213, 1, 0)
										end)
									end; imgui.Tooltip(u8'��������� ������� ������������� OffLine ���������� - /offstats')
									if imgui.Button(u8'���-�����') then  
										lua_thread.create(function()
											sampSendClickPlayer(recon_id, 0)
											wait(200)
											sampSendDialogResponse(500, 1, 10)
										end)
									end; imgui.Tooltip(u8'��������������� � TAB �����������. ��������� TAB � ���������� ����������.')
									if imgui.Button(u8'IP-�����') then  
										sampSendChat('/getip ' .. recon_id)
									end; imgui.Tooltip(u8'��������� ������� /getip ������������� � ID ������.')
									if imgui.Button(u8'������ ������') then  
										sampSendChat('/iwep ' .. recon_id)
									end; imgui.Tooltip(u8'��������� ��������� ���� � ��������� �������� � ������')
									if imgui.Button(u8'�������� ������') then  
										sampSendChat('/tweap ' .. recon_id)
									end  
									if imgui.Button(u8'�� � ������') then  
										lua_thread.create(function()
											sampSendChat('/reoff')
											pother.ActivateKeySync("off") 
											wait(200)
											sampSendChat('/agt ' ..id_spectator)
										end)
									end
									if imgui.Button(u8'�� ������ � ����') then  
										lua_thread.create(function()
											sampSendChat('/reoff')
											pother.ActivateKeySync("off") 
											wait(1000)
											sampSendChat('/gethere ' ..id_spectator)
										end)
									end 
									if imgui.Button(u8'������ ������') then  
										lua_thread.create(function()
											sampSendChat('/tonline')
											wait(100)
											sampCloseCurrentDialogWithButton(0)
											wait(100)
										end)
									end; imgui.Tooltip(u8'�������� � ������ ���������� ������ �� ������ ������ �����������.')
									imgui.EndPopup()
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
											if config.access.jail then
                                            	sampSendChat("/jail " .. recon_id .. " " .. elm.input.set_time_punish_in_recon.v .. " " .. elm.input.set_punish_in_recon.v)
                                            	elm.input.set_time_punish_in_recon.v = ""
                                            	elm.input.set_punish_in_recon.v = ""
											else 
												sampSendChat('/a /jail ' .. recon_id .. " " .. elm.input.set_time_punish_in_recon.v .. " " .. elm.input.set_punish_in_recon.v)
												elm.input.set_time_punish_in_recon.v = ""
                                            	elm.input.set_punish_in_recon.v = ""
											end
                                            sampSendChat("/reoff ")
											pother.ActivateKeySync("off") 
                                            recon_id = -1
                                        end
                                    end
									imgui.Separator()
									imgui.CenterText(u8'������������������ ���������')
									for key in pairs(cmd_massive) do  
										if cmd_massive[key].cmd == "/jail" then  
											if imgui.Button(u8(cmd_massive[key].reason)) then  
												if config.access.jail then
													sampSendChat(cmd_massive[key].cmd .. " " .. recon_id .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
												else 
													sampSendChat('/a ' .. cmd_massive[key].cmd .. " " .. recon_id .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
												end
											end 
										end 
									end
                                end 
                                if recon_punish == 2 then  
                                    imgui.InputText(u8'�������', elm.input.set_punish_in_recon) 
                                    imgui.InputText(u8'�����', elm.input.set_time_punish_in_recon)
                                    if imgui.Button(u8"������ ���������") then 
                                        if #elm.input.set_punish_in_recon.v > 0 and #elm.input.set_time_punish_in_recon.v then 
											if config.access.ban then
												sampSendChat("/ban " .. recon_id .. " " .. elm.input.set_time_punish_in_recon.v .. " " .. elm.input.set_punish_in_recon.v)
												elm.input.set_time_punish_in_recon.v = ""
												elm.input.set_punish_in_recon.v = ""
											else 
												sampSendChat("/a /ban " .. recon_id .. " " .. elm.input.set_time_punish_in_recon.v .. " " .. elm.input.set_punish_in_recon.v)
											end
                                            sampSendChat("/reoff ")
											pother.ActivateKeySync("off") 
                                            recon_id = -1
                                        end
                                    end
									imgui.Separator()
									imgui.CenterText(u8'������������������ ���������')
									for key in pairs(cmd_massive) do  
										if cmd_massive[key].cmd == "/ban" or cmd_massive[key].cmd == '/iban' then  
											if imgui.Button(u8(cmd_massive[key].reason)) then  
												if config.access.ban then
													sampSendChat("/ans " .. recon_id .. " ��������� �����, �� �������� ������� �������, � ���� ��..")
													sampSendChat("/ans " .. recon_id .. " ..�� �������� � ����������, �������� ������ �� ����� https://forumrds.ru")
													sampSendChat(cmd_massive[key].cmd .. " " .. recon_id .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
												else 
													sampSendChat('/a ' .. cmd_massive[key].cmd .. " " .. recon_id .. " " .. cmd_massive[key].time .. " " .. cmd_massive[key].reason)
												end
												pother.ActivateKeySync("off")
												recon_id = -1
											end 
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
											pother.ActivateKeySync("off") 
                                            recon_id = -1
                                        end
                                    end
									imgui.Separator()
									imgui.CenterText(u8'������������������ ���������')
									for key in pairs(cmd_massive) do  
										if cmd_massive[key].cmd == "/kick" then  
											if imgui.Button(u8(cmd_massive[key].reason)) then  
												sampSendChat(cmd_massive[key].cmd .. " " .. recon_id .. " " .. cmd_massive[key].reason)
												pother.ActivateKeySync("off") 
												recon_id = -1
											end 
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
	imgui.SameLine()
    if imgui.Button(u8"���� �� GangWar") then  
        imgui.OpenPopup('FloodsGangWar')
    end 
	imgui.SameLine()
    if imgui.Button(u8"����������� /join") then  
        imgui.OpenPopup('FloodsJoinMP')
    end
	imgui.SameLine()
	if imgui.Button(u8'���� �����') then  
		imgui.OpenPopup('CustomsFloods')
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
	if imgui.BeginPopup('CustomsFloods') then  
		if #configText.flood_name > 0 then  
			for key, name in pairs(configText.flood_name) do 
				if imgui.Button(name .. '##'..key) then  
					ActivateFlood(key) 
				end  
				imgui.SameLine()
				if imgui.Button(fai.ICON_FA_EDIT .. '##'..key..'CreatorFlood') then  
					EditOldBind = true  
					getpos = key 
					local returnwrapped = tostring(configText.flood_text[key]):gsub('~', '\n')
					elm.binder.flood.text.v = returnwrapped
					elm.binder.flood.name.v = tostring(configText.flood_name[key])
					imgui.OpenPopup('CreateFloodFrame')
				end 
				imgui.SameLine()
				if imgui.Button(fai.ICON_FA_TRASH .. '##'..key..'CreatorFlood') then  
					sampAddChatMessage(tag .. '���� "' .. u8:decode(configText.flood_name[key])..'" ������!', -1)
					table.remove(configText.flood_name, key)
					table.remove(configText.flood_text, key) 
					TextSave()
				end
			end 
			imgui.Separator()
			if imgui.Button(u8'������� ����') then  
				imgui.OpenPopup('CreateFloodFrame')
			end
		else 
			imgui.Text(u8'����� �����. ��� ������. �������� ����� <3') 
			if imgui.Button(u8'������� ����') then  
				imgui.OpenPopup('CreateFloodFrame')
			end
		end
		if imgui.BeginPopupModal('CreateFloodFrame', false, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then  
			imgui.BeginChild('##FloodCreateOrEdit', imgui.ImVec2(600, 225), true)
				imgui.Text(u8'�������� �����:'); imgui.SameLine(); imgui.PushItemWidth(130)
				imgui.InputText('##Flood_Name', elm.binder.flood.name)
				imgui.PopItemWidth(); imgui.PushItemWidth(100); imgui.Separator()
				imgui.Text(u8'����� �����:'); imgui.PushItemWidth(300)
				imgui.InputTextMultiline('##Flood_Text',elm.binder.flood.text, imgui.ImVec2(-1, 110))
				imgui.PopItemWidth()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 100)
				if imgui.Button(u8'�������##FloodCreator', imgui.ImVec2(100,30)) then  
					elm.binder.flood.name.v, elm.binder.flood.text.v = '', ''
					imgui.CloseCurrentPopup()
				end  
				imgui.SameLine()
				if #elm.binder.flood.name.v > 0 and #elm.binder.flood.text.v > 0 then  
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 1.01)
					if imgui.Button(u8"���������##FloodCreator", imgui.ImVec2(100,30)) then  
						if not EditOldBind then  
							local refresh_text = elm.binder.flood.text.v:gsub('\n', "~")
							table.insert(configText.flood_name, elm.binder.flood.name.v)
							table.insert(configText.flood_text, refresh_text)
							if TextSave() then 
								sampAddChatMessage(tag .. '���� "' .. u8:decode(elm.binder.flood.name.v) .. '" ������� ������!', -1)
								elm.binder.flood.name.v, elm.binder.flood.text.v = '', ''
							end  
							imgui.CloseCurrentPopup()
						else 
							local refresh_text = elm.binder.flood.text.v:gsub('\n', "~")
							table.insert(configText.flood_name, getpos, elm.binder.flood.name.v)
							table.insert(configText.flood_text, getpos, refresh_text)
							table.remove(configText.flood_name, getpos + 1)
							table.remove(configText.flood_text, getpos + 1)
							if TextSave() then  
								sampAddChatMessage(tag .. '���� "' .. u8:decode(elm.binder.flood.name.v) .. '" ������� ��������������!', -1)
								elm.binder.flood.name.v, elm.binder.flood.text.v = '', ''
							end 
							EditOldBind = false 
							imgui.CloseCurrentPopup()
						end 
					end
				end
			imgui.EndChild()
			imgui.EndPopup()
		end
		imgui.EndPopup()
	end
end
-- ## ���� �������, ���������� �� ������������ ����� ������������ �������� ImGUI ��� ����������� �� ��������� ������ ## --

-- ## ���� �������������� ������� � �������� ������� � ��������� �������������� � ��� ## --
function ActivateFlood(num)
	lua_thread.create(function()
		if num ~= -1 then  
			for stream_text_flood in configText.flood_text[num]:gmatch('[^~]+') do  
				sampSendChat('/mess ' .. u8:decode(tostring(stream_text_flood))) 
				--sampAddChatMessage('/mess ' .. u8:decode(tostring(stream_text_flood)), -1)
			end  
			num = -1
		end
	end)
end

function sampGetPlayerIdByNickname(nick)
	nick = tostring(nick)
	local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	if nick == sampGetPlayerNickname(myid) then return myid end
	for i = 0, 1003 do
	  if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == nick then
		return i
	  end
	end
end
-- ## ���� �������������� ������� � �������� ������� � ��������� �������������� � ��� ## --
