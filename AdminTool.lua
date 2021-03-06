script_name('AdminTool') -- �������� �������
-- ���������, ������, �������� �������: alfantasy, Unite, Liquit, Natsuki, Shtormo., Yuri_Dan__, Yamada, Soulful., Lebedev
script_description('������ ��� ���������� ������ ���������������') -- �������� �������

------- ����������� ���� ������ ��������� ----------
require "lib.moonloader" -- ����������� �������� ���������� mooloader
local ffi = require "ffi" -- c��� ���������
local dlstatus = require('moonloader').download_status
local font_admin_chat = require ("moonloader").font_flag -- ����� ��� �����-����
local vkeys = require "vkeys" -- ������� ��� ������
local imgui = require 'imgui' -- ������� imgui ����
local encoding = require 'encoding' -- ���������� ��������
local inicfg = require 'inicfg' -- ������ � ini
local sampev = require "lib.samp.events" -- ����������� �������� ���������, ��������� � ������� ������� ������� SA:MP, � �� ������ ���������� � LUA
local mem = require "memory" -- ����������, ���������� �� ������ ������, � � �������
encoding.default = 'CP1251' -- ����� ��������� �� CP1251
u8 = encoding.UTF8 -- ������������ ������������� ������ ��������� UTF8 - u8
------- ����������� ���� ������ ��������� -----------

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
-- kill-list

-- �� ������ ����
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


local directIni = "AdminTool\\settings.ini" -- �������� ������������ �����, ����������� �� ���������.

local themes = import "config/AdminTool/imgui_themes.lua" -- ����������� ������� ���
local notify = import "module/lib_imgui_notf.lua" -- ����������� ������� �����������
local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280) -- ������ ������� ������
local control_wallhack = false -- �������������� ���������� ��� wallhack
local chat_logger_text = { } -- ����� �������
local accept_load_clog = false -- �������� ���������� �������

-------- �������� ��������� ����������, ���������� �� �������������� ----------

update_state = false -- �������� �������� ����������

local script_version = 16 -- �������� ������, ��������������� ������ � ��������
local script_version_text = "9.2" -- ��������� ������
local script_path = thisScript().path  -- ����
local script_url = "https://raw.githubusercontent.com/alfantasy/AdminTool/main/AdminTool.lua" -- �������� ������ �� github
local update_path = getWorkingDirectory() .. '/update.ini' -- �������� ����
local update_url = "https://raw.githubusercontent.com/alfantasy/AdminTool/main/update.ini" -- �������� �����
local config_url = "https://raw.githubusercontent.com/alfantasy/AdminTool/main/settings.ini" -- �������� ��������
local config_path = getWorkingDirectory() .. '\\config\\AdminTool\\settings.ini' -- ������������� ����� ��������
local themes_url = "https://raw.githubusercontent.com/alfantasy/AdminTool/main/imgui_themes.lua" -- ���� �� github
local themes_path = getWorkingDirectory() .. '\\config\\AdminTool\\imgui_themes.lua' -- �� ������������� � �����
-------- �������� ��������� ����������, ���������� �� �������������� ----------


----- ��������� ��������� ����������, ���������� �� ��������� ��� ---------
local font_size_ac = imgui.ImBuffer(16) -- ����� ��� ����� ������
local line_ac = imgui.ImInt(16) -- ����� ��� ����� �����
local font_ac -- �����

--------------- ��������� ���������� ���������� �� config -----------
local defTable = {
	setting = {
		Y = 300,
		Admin_chat = false,
		Push_Report = false,
		Chat_Logger = false,
		Chat_Logger_osk = false,
		ATALogin = false,
		ranremenu = false,
		anti_cheat = false,
		auto_mute_mat = false,
		translate_cmd = false,
		ATAdminPass = "",
		prefix_adm = "",
		prefix_STadm = "",
		prefix_Madm = "",
		prefix_ZGAadm = "",
		prefix_GAadm = "",
		AdminLevel = 0,
		-- new
	},
	keys = {
		ATWHkeys = "None",
		ATTool =  "None",
		ATOnline = "None",
		ATReportAns = "None",
		ATReportRP = "None",
		ATReportRP1 = "None",
		ATReportRP2 = "None",
		P_Log = "None",
		Re_menu = "None",
	},
	achat = {
		X = 48,
		Y = 298, 
		centered = 0,
		color = -1,
		nick = 1,
		lines = 10,
		Font = 10
	}
}

local setting_items = {
	Admin_chat = imgui.ImBool(false),
	Push_Report = imgui.ImBool(false),
	Chat_Logger = imgui.ImBool(false),
	Chat_Logger_osk = imgui.ImBool(false),
	ATAlogin = imgui.ImBool(false),
	ranremenu = imgui.ImBool(false),
	anti_cheat = imgui.ImBool(false),
	auto_mute_mat = imgui.ImBool(false),
	translate_cmd = imgui.ImBool(false),
	}

--------------- ��������� ���������� ���������� �� config -----------

local admin_chat_lines = { 
	centered = imgui.ImInt(0),
	nick = imgui.ImInt(1),
	color = -1,
	lines = imgui.ImInt(10),
	X = 0,
	Y = 0
}
-- ����� �����

local ac_no_saved = {
	chat_lines = { },
	pos = false,
	X = 0,
	Y = 0
}
-- �� �����������


function saveAdminChat()
	config.achat.X = admin_chat_lines.X
	config.achat.Y = admin_chat_lines.Y
	config.achat.centered = admin_chat_lines.centered.v
	config.achat.nick = admin_chat_lines.nick.v
	config.achat.color = admin_chat_lines.color
	config.achat.lines = admin_chat_lines.lines.v
	config.achat.Font = font_size_ac.v
	inicfg.save(config, directIni)
end
-- ���������� ���������
function loadAdminChat()
	admin_chat_lines.X = config.achat.X
	admin_chat_lines.Y = config.achat.Y
	admin_chat_lines.centered.v = config.achat.centered
	admin_chat_lines.nick.v = config.achat.nick
	admin_chat_lines.color = config.achat.color
	admin_chat_lines.lines.v = config.achat.lines
	font_size_ac.v = tostring(config.achat.Font)
end
-- �������� ���������

----- ��������� ��������� ����������, ���������� �� ��������� ��� ---------

local AdminLevel = imgui.ImInt(defTable.setting.AdminLevel) -- �������� �� ������ �������� ������

------ ��������� ��������� ����������, ���������� �� ���� ----------
local label = 0 -- ������
local main_color = 0xe01df2 -- �������� ����
local text_color = 0x4169E1 -- ���� ������
local main_color_text = "{6e73f0}" -- 2 ����
local white_color = "{FFFFFF}" -- ����� ����
local mcolor -- ��������� ���������� ��� ����������� ���������� �����
local tag = "{87CEEB}[AdminTool]  {4169E1}" -- ��������� ����������, ������� ������������ ��� AT
------ ��������� ��������� ����������, ���������� �� ���� ----------


------- ��������� ��������� ����������, ���������� �� ���� ������ -----------------
local player_info = {} -- ���� � ������
local player_to_streamed = {} -- ���� � ������������
local text_remenu = { "����:", "��������:", "�����:", "�� ������:", "��������:", "Ping:", "�������:", "��������:", "����� ���������:", "����� ���:", "P.Loss:", "VIP:", "Passive ���:", "Turbo:", "��������:" }
local control_recon_playerid = -1 -- �������������� ���������� �� �� ������
local control_tab_playerid = -1 -- � ����
local control_recon_playernick = nil -- ���
local next_recon_playerid = nil -- ��������� ��
local control_recon = false -- ��������������� ������
local control_info_load = false -- ��������������� �������� ����
local right_re_menu = true -- ������ ������
local check_mouse = false -- �������� ������� ����
local mouse_cursor = true -- ����� �� ������ ������
local check_cmd_re = false -- �������� ������� � ������
local accept_load = false -- �������� ������
local tool_re
------- ��������� ��������� ����������, ���������� �� ���� ������ -----------------

------ ��������� ��������� ����������, ���������� �� ������� ----------
local onscene = { "�����", "����", "���", "�����" } -- �������� ����� ����
local control_onscene = false -- ��������������� ����� ����
local log_onscene = { } -- ��� �����
local date_onscene = {} -- ���� �����
------ ��������� ��������� ����������, ���������� �� ������� ----------

----- ��������� ��������� ����������, ������� �������� �� imgui ���� �/��� ��������� � ���� -------



function imgui.TextColoredRGB(text, render_text)
    local max_float = imgui.GetWindowWidth()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text)
        for w in text:gmatch('[^\r\n]+') do
            local text, colors, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors[#colors + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end

            local length = imgui.CalcTextSize(w)
            if render_text == 2 then
                imgui.NewLine()
                imgui.SameLine(max_float / 2 - ( length.x / 2 ))
            elseif render_text == 3 then
                imgui.NewLine()
                imgui.SameLine(max_float - length.x - 5 )
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], text[i])
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(w) end


        end
    end

    render_text(text)
end


local ac_string = '' -- ������ ��������

function imgui.Link(link)
	if status_hovered then
		local p = imgui.GetCursorScreenPos()
		imgui.TextColored(imgui.ImVec4(0, 0.5, 1, 1), link)
		imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y + imgui.CalcTextSize(link).y), imgui.ImVec2(p.x + imgui.CalcTextSize(link).x, p.y + imgui.CalcTextSize(link).y), imgui.GetColorU32(imgui.ImVec4(0, 0.5, 1, 1)))
	else
		imgui.TextColored(imgui.ImVec4(0, 0.3, 0.8, 1), link)
	end
	if imgui.IsItemClicked() then os.execute('explorer '..link)
	elseif imgui.IsItemHovered() then
		status_hovered = true else status_hovered = false
	end
end
--- ��������������� ������ � ���� ��������� � ������������ ������.

imgui.ToggleButton = require('imgui_addons').ToggleButton
imgui.Spinner = require('imgui_addons').Spinner
imgui.BufferingBar = require('imgui_addons').BufferingBar
local one_window_state = imgui.ImBool(false)
local two_window_state = imgui.ImBool(false)
local three_window_state = imgui.ImBool(false)
local four_window_state = imgui.ImBool(false)
local five_window_state = imgui.ImBool(false)
local six_window_state = imgui.ImBool(false)
local seven_window_state = imgui.ImBool(false)
local ATChat = imgui.ImBool(false)
local ATChatLogger = imgui.ImBool(false)
local ATre_menu = imgui.ImBool(false)
local chat_logger = imgui.ImBuffer(10000)
local chat_find = imgui.ImBuffer(256)
local settings_keys = imgui.ImBool(false)
local btn_size = imgui.ImVec2(-0.1, 0)
local ATAdminPass = imgui.ImBuffer(214)
local ban_id = imgui.ImBuffer(50)
local ban_nick = imgui.ImBuffer(100)
local text_buffer_mp = imgui.ImBuffer(516)
local text_buffer_prize = imgui.ImBuffer(524)
local text_buffer_name = imgui.ImBuffer(256)
local text_buffer_sniat = imgui.ImBuffer(2048)
local text_buffer_kick = imgui.ImBuffer(1024)
local text_buffer_adm = imgui.ImBuffer(4096)
local text_buffer_ban = imgui.ImBuffer(1234)
local prefix_Madm = imgui.ImBuffer(4096)
local prefix_adm = imgui.ImBuffer(4096)
local prefix_STadm = imgui.ImBuffer(4096)
local prefix_ZGAadm = imgui.ImBuffer(4096)
local prefix_GAadm = imgui.ImBuffer(4096)

local arr_alvl = {u8"1 �������", 
					u8"2 �������", 
					u8"3 �������", 
					u8"4 �������", 
					u8"5 �������", 
					u8"6 �������", 
					u8"7 �������", 
					u8"8 �������", 
					u8"9 �������", 
					u8"10 �������", 
					u8"11 �������", 
					u8"12 �������", 
					u8"13 �������", 
					u8"14 �������", 
					u8"15 �������", 
					u8"16 �������", 
					u8"17 �������", 
					u8"18 �������" }

local arr_str = {u8"1 LVL", 
				u8"2 LVL", 
				u8"3 LVL", 
				u8"4 LVL", 
				u8"5 LVL", 
				u8"6 LVL", 
				u8"7 LVL", 
				u8"8 LVL", 
				u8"9 LVL", 
				u8"10 LVL", 
				u8"11 LVL", 
				u8"12 LVL", 
				u8"13 LVL", 
				u8"14 LVL", 
				u8"15 LVL", 
				u8"16 LVL", 
				u8"17 LVL", 
				u8"18 LVL" }

local ban_str = {u8" 7  ������������� ���������� ��",
				u8" 3  ������������ ���������. (3)",
				u8" 7  ������������ ���������. (7)",
				u8" 30  ����� �������������. ",
				u8" 30  ����� �������. ",
				u8" 7  �����, ����������� ����������� �������.",
				u8" 7  ����� �������� ����.",
				u8" 30  ����������� � ������� �������."}

local checked_test = imgui.ImBool(false) -- �������� �� �������
local checked_test_2 = imgui.ImBool(false) -- �������� �� ������ ��������� �������

local checked_radio = imgui.ImInt(1) -- �������� �� ������������

local combo_select = imgui.ImInt(0) -- �������� �� �����-������

local sw1, sh1 = getScreenResolution() -- �������� �� ������ � �����, ������ ������ - ������ ����.
local sw, sh = getScreenResolution() -- �������� �� �������������� ����� � ������ ����.

local ATadm_forms = '' -- ����������, ���������� �� ������ ������� �����

----- ��������� ��������� ����������, ������� �������� �� imgui ���� �/��� ��������� � ���� -------

------ ��������� ��������� ����������, ���������� �� ������� ��������, ��� ��������� ������� ���� -----------
local russian_characters = {
    [168] = '�', [184] = '�', [192] = '�', [193] = '�', [194] = '�', [195] = '�', [196] = '�', [197] = '�', [198] = '�', [199] = '�', [200] = '�', [201] = '�', [202] = '�', [203] = '�', [204] = '�', [205] = '�', [206] = '�', [207] = '�', [208] = '�', [209] = '�', [210] = '�', [211] = '�', [212] = '�', [213] = '�', [214] = '�', [215] = '�', [216] = '�', [217] = '�', [218] = '�', [219] = '�', [220] = '�', [221] = '�', [222] = '�', [223] = '�', [224] = '�', [225] = '�', [226] = '�', [227] = '�', [228] = '�', [229] = '�', [230] = '�', [231] = '�', [232] = '�', [233] = '�', [234] = '�', [235] = '�', [236] = '�', [237] = '�', [238] = '�', [239] = '�', [240] = '�', [241] = '�', [242] = '�', [243] = '�', [244] = '�', [245] = '�', [246] = '�', [247] = '�', [248] = '�', [249] = '�', [250] = '�', [251] = '�', [252] = '�', [253] = '�', [254] = '�', [255] = '�',
} 

local translate = {
	["�"] = "q",
	["�"] = "w",
	["�"] = "e",
	["�"] = "r",
	["�"] = "t",
	["�"] = "y",
	["�"] = "u",
	["�"] = "i",
	["�"] = "o",
	["�"] = "p",
	["�"] = "[",
	["�"] = "]",
	["�"] = "a",
	["�"] = "s",
	["�"] = "d",
	["�"] = "f",
	["�"] = "g",
	["�"] = "h",
	["�"] = "j",
	["�"] = "k",
	["�"] = "l",
	["�"] = ";",
	["�"] = "'",
	["�"] = "z",
	["�"] = "x",
	["�"] = "c",
	["�"] = "v",
	["�"] = "b",
	["�"] = "n",
	["�"] = "m",
	["�"] = ",",
	["�"] = "."
}
----- ��������� ���������� �������� �� ������� ������� ��������, ����� �� ��������� ����� ����.

------ ��������� ��������� ����������, ���������� �� ������� ��������, ��� ��������� ������� ���� -----------






function set_custom_theme()
	imgui.SwitchContext()
	local style  = imgui.GetStyle()
	local colors = style.Colors
	local clr    = imgui.Col
	local ImVec4 = imgui.ImVec4
	local ImVec2 = imgui.ImVec2

	style.WindowPadding       = ImVec2(4, 8)
	style.WindowRounding      = 16
	style.ChildWindowRounding = 16
	style.FramePadding        = ImVec2(8, 3)
	style.FrameRounding       = 16
	style.ItemSpacing         = ImVec2(6, 4)
	style.TouchExtraPadding   = ImVec2(0, 0)
	style.IndentSpacing       = 21
	style.ScrollbarSize       = 15
	style.ScrollbarRounding   = 16
	style.GrabMinSize         = 10
	style.GrabRounding        = 4
	style.WindowTitleAlign    = ImVec2(0.50, 0.50)
	style.ButtonTextAlign     = ImVec2(0, 0)

	colors[clr.Text]                 = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled]         = ImVec4(0.73, 0.75, 0.74, 1.00)
	colors[clr.WindowBg]             = ImVec4(0.09, 0.09, 0.09, 0.94)
	colors[clr.ChildWindowBg]        = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.Border]               = ImVec4(0.20, 0.20, 0.20, 0.50)
	colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.FrameBg]              = ImVec4(0.13, 0.37, 0.53, 0.37)
	colors[clr.FrameBgHovered]       = ImVec4(0.14, 0.21, 0.67, 0.00)
	colors[clr.FrameBgActive]        = ImVec4(0.84, 0.66, 0.66, 0.67)
	colors[clr.TitleBg]              = ImVec4(0.39, 0.33, 0.51, 0.00)
	colors[clr.TitleBgActive]        = ImVec4(0.26, 0.20, 0.53, 1.00)
	colors[clr.TitleBgCollapsed]     = ImVec4(0.47, 0.22, 0.59, 0.35)
	colors[clr.MenuBarBg]            = ImVec4(0.34, 0.16, 0.22, 0.00)
	colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.31, 0.64)
	colors[clr.ScrollbarGrab]        = ImVec4(0.31, 0.31, 0.31, 1.00)
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.ScrollbarGrabActive]  = ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.ComboBg]              = ImVec4(0.20, 0.20, 0.20, 0.99)
	colors[clr.CheckMark]            = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.SliderGrab]           = ImVec4(0.71, 0.39, 0.39, 1.00)
	colors[clr.SliderGrabActive]     = ImVec4(0.84, 0.66, 0.66, 1.00)
	colors[clr.Button]               = ImVec4(0.32, 0.20, 0.33, 0.59)
	colors[clr.ButtonHovered]        = ImVec4(0.71, 0.39, 0.39, 0.65)
	colors[clr.ButtonActive]         = ImVec4(0.20, 0.20, 0.20, 0.50)
	colors[clr.Header]               = ImVec4(0.71, 0.39, 0.39, 0.54)
	colors[clr.HeaderHovered]        = ImVec4(0.84, 0.66, 0.66, 0.65)
	colors[clr.HeaderActive]         = ImVec4(0.84, 0.66, 0.66, 0.00)
	colors[clr.Separator]            = ImVec4(0.43, 0.43, 0.50, 0.50)
	colors[clr.SeparatorHovered]     = ImVec4(0.71, 0.39, 0.39, 0.54)
	colors[clr.SeparatorActive]      = ImVec4(0.71, 0.39, 0.39, 0.54)
	colors[clr.ResizeGrip]           = ImVec4(0.71, 0.39, 0.39, 0.54)
	colors[clr.ResizeGripHovered]    = ImVec4(0.84, 0.66, 0.66, 0.66)
	colors[clr.ResizeGripActive]     = ImVec4(0.84, 0.66, 0.66, 0.66)
	colors[clr.CloseButton]          = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.CloseButtonHovered]   = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.CloseButtonActive]    = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered]     = ImVec4(1.00, 0.43, 0.35, 1.00)
	colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
	colors[clr.TextSelectedBg]       = ImVec4(0.26, 0.59, 0.98, 0.35)
	colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
end	
set_custom_theme()


function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end

	local file_read, c_line = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\mat.txt", "r"), 1
	if file_read ~= nil then
		file_read:seek("set", 0)
		for line in file_read:lines() do
			onscene[c_line] = line
			c_line = c_line + 1
		end
		file_read:close()
	end
	-- ������ �����

	sampRegisterChatCommand('s_mat', function(param) -- ���������� ����
		if param == nil then
			return false
		end
		for _, val in ipairs(onscene) do
			if string.rlower(param) == val then
				sampAddChatMessage(tag .. "����� \"" .. val .. "\" ��� ������������ � ������ ����������� �����.")
				return false
			end
		end
		local file_write, c_line = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\mat.txt", "w"), 1
		onscene[#onscene + 1] = string.rlower(param)
		for _, val in ipairs(onscene) do
			file_write:write(val .. "\n")
		end
		file_write:close()
		sampAddChatMessage(tag .. "����� \"" .. string.rlower(param) .. "\" ������� ��������� � ������ ����������� �������.")
	end)
	sampRegisterChatCommand('d_mat', function(param) -- �������� ����
		if param == nil then
			return false
		end
		local file_write, c_line = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\mat.txt", "w"), 1
		for i, val in ipairs(onscene) do
			if val == string.rlower(param) then
				onscene[i] = nil
				control_onscene = true
			else
				file_write:write(val .. "\n")
			end
		end
		file_write:close()
		if control_onscene then
			sampAddChatMessage(tag .. "����� \"" .. string.rlower(param) .. "\" ���� ������� ������� �� ������ ����������� �����.")
			control_onscene = false
		else
			sampAddChatMessage(tag .. "����� \"" .. string.rlower(param) .. "\" ��� � ������ ������������.")
		end
	end)

	_, watermark_id = sampGetPlayerIdByCharHandle(playerPed)
    watermark_nick = sampGetPlayerNickname(watermark_id)
	
	downloadUrlToFile(update_url, update_path, function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then  
			updateIni = inicfg.load(nil, update_path)
			if tonumber(updateIni.info.version) > script_version then 
				notify.addNotify("{87CEEB}[AdminTool]", '�� GitHub ����� ������ \nAdminTool �����������', 2, 1, 6)
				update_state = true
			end
			os.remove(update_path)
		end
	end)
	-- �������� ���������� � ���, ��� ����� ���������

	------------- ������ ChatLogger -----------------
	chatlogDirectory = getWorkingDirectory() .. "\\config\\AdminTool\\chatlog"
    if not doesDirectoryExist(chatlogDirectory) then
        createDirectory(getWorkingDirectory() .. "\\config\\AdminTool\\chatlog")
    end
	------------- ������ ChatLogger -----------------


	--------- ���������� ������� ��� �������� ---------
	config = inicfg.load(defTable, directIni)
	setting_items.Admin_chat.v = config.setting.Admin_chat
	setting_items.Push_Report.v = config.setting.Push_Report
	setting_items.Chat_Logger.v = config.setting.Chat_Logger
	setting_items.ATAlogin.v = config.setting.ATAlogin
	setting_items.ranremenu.v = config.setting.ranremenu
	setting_items.anti_cheat.v = config.setting.anti_cheat
	setting_items.auto_mute_mat.v = config.setting.auto_mute_mat
	setting_items.translate_cmd.v = config.setting.translate_cmd

	prefix_adm.v = config.setting.prefix_adm
	prefix_STadm.v = config.setting.prefix_STadm
	prefix_Madm.v = config.setting.prefix_Madm
	prefix_ZGAadm.v = config.setting.prefix_ZGAadm
	prefix_GAadm.v = config.setting.prefix_GAadm
	AdminLevel.v = config.setting.AdminLevel

	ATAdminPass.v = config.setting.ATAdminPass
	index_text_pos = config.setting.Y
	
	if not doesDirectoryExist(getWorkingDirectory() .. "/config/AdminTool") then
		createDirectory(getWorkingDirectory() .. "/config/AdminTool")
	end
	--------- ���������� ������� ��� �������� ---------


	--------- ������� ���������� ������ -------
	local an_tag = tag .. 'Anti-Cheat:'
	font_ac = renderCreateFont("Arial", config.setting.Font, font_admin_chat.BOLD + font_admin_chat.SHADOW)
		--------- �������, ���������� �� ����� ����������������� ���� ----------
	font_watermark = renderCreateFont("Arial", 10, font_admin_chat.BOLD)
	lua_thread.create(function()
		while true do
			renderFontDrawText(font_watermark, tag .. "v." .. script_version_text .. "{FFFFFF} | {AAAAAA}" .. watermark_nick .. " [" .. watermark_id .. "] " .. " | �����: " ..os.date("%H:%M:%S"), 10, sh-20, 0xCCFFFFFF)

			if setting_items.anti_cheat.v then 
				renderFontDrawText(font_watermark, an_tag.. '\n' ..ac_string, 20, sh-430, 0xCCFFFFFF)
				renderFontDrawText(font_watermark, an_tag.. '\n' ..ac_string, 20, sh-430, 0xCCFFFFFF)
				renderFontDrawText(font_watermark, an_tag.. '\n' ..ac_string, 20, sh-430, 0xCCFFFFFF)

				end
			   wait(1)
		end
	end)
	--------- ������� ���������� ������ -------


	------------- �������, ���������� �� ������������ ������� ---------
	admin_chat = lua_thread.create_suspended(drawAdminChat)
	wallhack = lua_thread.create(drawWallhack)
	load_chat_log = lua_thread.create_suspended(loadChatLog)
	load_info_player = lua_thread.create_suspended(loadPlayerInfo)
	draw_re_menu = lua_thread.create_suspended(drawRePlayerInfo)
	check_cmd = lua_thread.create_suspended(function()
		wait(1000)
		check_cmd_re = false
	end)
	------------- �������, ���������� �� ������������ ������� ---------


	--------- �������, ������������� ��� ������������� ��� ������������� �������� -----------
	sampRegisterChatCommand("update", update)
	sampRegisterChatCommand("tpcord", tpcord)
	sampRegisterChatCommand("iddialog", iddialog)
	sampRegisterChatCommand("delch", delch)
	sampRegisterChatCommand("tpad", tpad)
	--------- �������, ������������� ��� ������������� ��� ������������� �������� -----------
	
	--------------------------- ������� ��� ��������� -------------------
	sampRegisterChatCommand("pradm1", pradm1)
	sampRegisterChatCommand("pradm2", pradm2)
	sampRegisterChatCommand("pradm3", pradm3)
	sampRegisterChatCommand("pradm4", pradm4)
	sampRegisterChatCommand("pradm5", pradm5)
	--------------------------- ������� ��� ��������� -------------------

	------- ������� ��� ������� ���������� ------- 
	sampRegisterChatCommand("tool", cmd_tool)
	sampRegisterChatCommand("toolmp", cmd_toolmp)
	sampRegisterChatCommand("toolfd", cmd_toolfd)
	sampRegisterChatCommand("toolans", cmd_toolans)
	sampRegisterChatCommand("tooladm", cmd_tooladm)
	------- ������� ��� ������� ���������� ------- 

	------- ������� ������������� ��� ����� -------
	sampRegisterChatCommand("fd1", cmd_fd1)
	sampRegisterChatCommand("fd2", cmd_fd2)
	sampRegisterChatCommand("fd3", cmd_fd3)
	sampRegisterChatCommand("fd4", cmd_fd4)
	sampRegisterChatCommand("fd5", cmd_fd5)
	sampRegisterChatCommand("po1", cmd_po1)
	sampRegisterChatCommand("po2", cmd_po2)
	sampRegisterChatCommand("po3", cmd_po3)
	sampRegisterChatCommand("po4", cmd_po4)
	sampRegisterChatCommand("po5", cmd_po5)
	sampRegisterChatCommand("m", cmd_m)
	sampRegisterChatCommand("ok", cmd_ok)
	sampRegisterChatCommand("oa", cmd_oa)
	sampRegisterChatCommand("kl", cmd_kl)
	sampRegisterChatCommand("up", cmd_up)
	sampRegisterChatCommand("or", cmd_or)
	sampRegisterChatCommand("nm", cmd_nm)
	sampRegisterChatCommand("nm1", cmd_nm1)
	sampRegisterChatCommand("nm2", cmd_nm2)
	sampRegisterChatCommand("ia", cmd_ia)
	------- ������� ������������� ��� ����� -------

	------- ������� ������������� ��� ����� ������� -------
	sampRegisterChatCommand("roa", cmd_roa)
	sampRegisterChatCommand("ror", cmd_ror)
	sampRegisterChatCommand("rpo", cmd_rpo)
	sampRegisterChatCommand("cp", cmd_cp)
	sampRegisterChatCommand("rnm", cmd_rnm)
	sampRegisterChatCommand("rnm1", cmd_rnm1)
	sampRegisterChatCommand("rnm2", cmd_rnm2)
	sampRegisterChatCommand("rup", cmd_rup)
	sampRegisterChatCommand("rok", cmd_rok)
	sampRegisterChatCommand("rm", cmd_rm)
	------- ������� ������������� ��� ����� ������� -------

	------- ������� ������������� ��� ������� -------
	sampRegisterChatCommand("sk", cmd_sk)
	sampRegisterChatCommand("dz", cmd_dz)
	sampRegisterChatCommand("dz1", cmd_dz1)
	sampRegisterChatCommand("dz2", cmd_dz2)
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
	------- ������� ������������� ��� ������� -------

	------- ������� ������������� ��� ����� -------
	sampRegisterChatCommand("pl", cmd_pl)
	sampRegisterChatCommand("ch", cmd_ch)
	sampRegisterChatCommand("ob", cmd_ob)
	sampRegisterChatCommand("hl", cmd_hl)
	sampRegisterChatCommand("nk", cmd_nk)
	sampRegisterChatCommand("menk", cmd_menk)
	sampRegisterChatCommand("gcnk", cmd_gcnk)
	sampRegisterChatCommand("okpr", cmd_okpr)
	sampRegisterChatCommand("okprip", cmd_okprip)
	sampRegisterChatCommand("svocakk", cmd_svocakk)
	sampRegisterChatCommand("svocip", cmd_svocip)
	------- ������� ������������� ��� ����� -------

	------- ������� ������������� ��� ����� � �������� -------
	sampRegisterChatCommand("am", cmd_am)
	sampRegisterChatCommand("aok", cmd_aok)
	sampRegisterChatCommand("afd", cmd_afd)
	sampRegisterChatCommand("apo", cmd_apo)
	sampRegisterChatCommand("aoa", cmd_aoa)
	sampRegisterChatCommand("aup", cmd_aup)
	sampRegisterChatCommand("anm", cmd_anm)
	sampRegisterChatCommand("anm1", cmd_anm1)
	sampRegisterChatCommand("anm2", cmd_anm2)
	sampRegisterChatCommand("aor", cmd_aor)
	sampRegisterChatCommand("aia", cmd_aia)
	sampRegisterChatCommand("akl", cmd_akl)
	------- ������� ������������� ��� ����� � �������� -------


	------- ������� ������������� ��� ������� � �������� -------
	sampRegisterChatCommand("ajcw", cmd_ajcw)
	sampRegisterChatCommand("ask", cmd_ask)
	sampRegisterChatCommand("adz", cmd_adz)
	sampRegisterChatCommand("adz1", cmd_adz1)
	sampRegisterChatCommand("adz2", cmd_adz2)
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
	------- ������� ������������� ��� ������� � �������� -------


	------- ������� ������������� ��� ����� -------
	sampRegisterChatCommand("dj", cmd_dj)
	sampRegisterChatCommand("gnk1", cmd_gnk1)
	sampRegisterChatCommand("gnk2", cmd_gnk2)
	sampRegisterChatCommand("gnk3", cmd_gnk3)
	sampRegisterChatCommand("cafk", cmd_cafk)
	------- ������� ������������� ��� ����� -------


	------- ������� ������������� ��� ����� � �������� -------
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
	------- ������� ������������� ��� ����� � �������� -------
	

	------- ������� ������������� ��� ������� ������� -------
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
	sampRegisterChatCommand("h13", cmd_h13)
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
	------- ������� ������������� ��� ������� ������� -------

	------ �������, ������������ � ��������������� ������� -------
	sampRegisterChatCommand("u", cmd_u)
	sampRegisterChatCommand("uu", cmd_uu)
	sampRegisterChatCommand("uj", cmd_uj)
	sampRegisterChatCommand("as", cmd_as)
	sampRegisterChatCommand("stw", cmd_stw)
	sampRegisterChatCommand("ru", cmd_ru)
	------ �������, ������������ � ��������������� ������� -------


	----------------- ������ ���������� �� ����� ����������� -------------------------
	sampRegisterChatCommand("notify", cmd_notify)
	----------------- ������ ���������� �� ����� ����������� -------------------------
	
	----------------- ������� ������������� ��� �������� ������� ---------------------
	sampRegisterChatCommand("nba", cmd_nba)
	sampRegisterChatCommand("dpv", cmd_dpv)
	sampRegisterChatCommand("arep", cmd_arep)
	----------------- ������� ������������� ��� �������� ������� ---------------------
	
	----------------- ������� ������������� ��� ���������/���������� �� -----------------------
	sampRegisterChatCommand("wh", cmd_wh)
	----------------- ������� ������������� ��� ���������/���������� �� -----------------------
	--local fonte = renderCreateFont("Arial", 8, 5) --creating font
	--sampfuncsRegisterConsoleCommand("showtdid", show)   --registering command to sampfuncs console, this will call function that shows textdraw id's

	sampRegisterChatCommand('spp', function()
	local playerid_to_stream = playersToStreamZone()
	for _, v in pairs(playerid_to_stream) do
	sampSendChat('/aspawn ' .. v)
	end
	end)
	-- �������� ���� ������� ������

	sampRegisterChatCommand('cfind', function(param)
		if param == nil then
			ATChatLogger.v = not ATChatLogger.v
			imgui.Process = true
			chat_logger_text = readChatlog()
		else
			ATChatLogger.v = not ATChatLogger.v
			imgui.Process = true
			chat_find.v = param
			chat_logger_text = readChatlog()
		end
		load_chat_log:run()
	end)
	-- ��������� ���-�������

	------------------ ����� ������� �������, ���� ������ � ������� -------------------------
	sampAddChatMessage("{87CEEB}[AdminTool] {4169E1}����� ������� �������: ���� ��������, VK ID: alfantasy", 0xe01df2)
	sampAddChatMessage("{87CEEB}[AdminTool] {4169E1}����������� ����� ������� ����� �������, ��� ��� ������� �� ������������.", 0xe01df2)
	sampAddChatMessage("{87CEEB}[AdminTool] {4169E1}������ ������������ ���������������� ��� ���������� �� ������", 0xe01df2)
	sampAddChatMessage("{87CEEB}[AdminTool] {4169E1}��� ��������� ������ �� �������� AdminTool ������� /tool", 0xe01df2)
	sampAddChatMessage("{87CEEB}[AdminTool] {4169E1}�����, ��� ��������� ������ �� ��������, ������� F3. ��� �������", 0xe01df2)
	sampAddChatMessage("{87CEEB}[AdminTool] {4169E1}���� �� ����� ������, �������� � �� ������������.", 0xe01df2)
	sampAddChatMessage("{87CEEB}[AdminTool] {4169E1}������� ������ ���, �������! :3", 0x6e73f0)
	------------------ ����� ������� �������, ���� ������ � ������� -------------------------

	-- �������� ID -- 
	_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	nick = sampGetPlayerNickname(id)

	if nick == "Kintzel." then
		sampAddChatMessage("{87CEEB}��������, {FF69B4} ��������� {DB7093}<3", 0x87CEEB)
	end

	if nick == "Shtormo." then
		sampAddChatMessage("{87CEEB}����������, {008000} ������ {DB7093}<3", 0x87CEEB)
	end

	if nick == "index." then
		sampAddChatMessage("{87CEEB}������, {4169E1} ����� {DB7093}<3", 0x87CEEB)
	end

	if nick == "Langermann" then
		sampAddChatMessage("{87CEEB}��������, {FF69B4} ������ {DB7093}<3", 0x87CEEB)
	end

	if nick == "Unite." then
		sampAddChatMessage("{87CEEB}��������, {98FB98} ������ {DB7093}<3", 0x87CEEB)
	end

	if nick == "lxrdsavage.fedos" then
		sampAddChatMessage("{87CEEB}��������, {66CDAA} ������ {DB7093}<3", 0x87CEEB)
	end

	if nick == "Yuri_Dan__" then   
		sampAddChatMessage("{87CEEB}��������, {FA8072}������ {DB7093}<3", 0x87CEEB)
	end

	if nick == "Guardian." then   
		sampAddChatMessage("{87CEEB}��������, {7B68EE}������ {DB7093}<3", 0x87CEEB)
	end

	if nick == "Flike." then
		sampAddChatMessage("{87CEEB}������, {4169E1} ����� ������ {DB7093}<3", 0x87CEEB)
	end
		
	if nick == "ZXCMAGIC." then
		sampAddChatMessage("{87CEEB}��������, {7B68EE}Vladick {DB7093}<3", 0x87CEEB)
	end
		
	if nick == "David_Yan" then
		sampAddChatMessage("{87CEEB}��������, {7B68EE}������� {DB7093}<3", 0x87CEEB)
	end
		
	if nick == "Soldd." then
		sampAddChatMessage("{87CEEB}��������, {7B68EE}dungeon master {DB7093}<3", 0x87CEEB)
	end

	imgui.Process = false
	res = false

	thread = lua_thread.create_suspended(thread_function)
	-- �������� ����� ���� �� imgui ����.


	--------------- �������� ���������� ���� -------------
	loadAdminChat()
	admin_chat:run()
	--------------- �������� ���������� ���� -------------

	--sampAddChatMessage("������ imgui ������������", -1)

	while true do


		wait(0)


		--if toggle then --params that not declared has a nil value that same as false
		--	for a = 0, 2304	do --cycle trough all textdeaw id
		--		if sampTextdrawIsExists(a) then --if textdeaw exists then
		--			x, y = sampTextdrawGetPos(a) --we get it's position. value returns in game coords
		--			x1, y1 = convertGameScreenCoordsToWindowScreenCoords(x, y) --so we convert it to screen cuz render needs screen coords
		--			renderFontDrawText(fonte, a, x1, y1, 0xFFBEBEBE) --and then we draw it's id on textdeaw position
		--		end
		--	end
		--end





		if update_state then  
			downloadUrlToFile(script_url, script_path, function(id, status)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then  
					notify.addNotify("{87CEEB}[AdminTool]", 'AdminTool ��������. \n�������� ������!', 2, 1, 6)
					thisScript():reload()
				end
			end)
			break
		end
		if update_state then  
			downloadUrlToFile(config_url, config_path, function(id, status)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then  
					notify.addNotify("{87CEEB}[AdminTool]", '��������� ���������. \n��� ���������� �� ���������.', 2, 1, 6)
				end
			end)
			break
		end
		if update_state then  
			downloadUrlToFile(themes_url, themes_path, function(id, status)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then  
					notify.addNotify("{87CEEB}[AdminTool]", '���� ���������. \n������ ��� ����� ��������.', 2, 1, 6)
				end
			end)
			break
		end
		------ ���������� ����������
		
		--------- ��������� /remenu ---------------
		if control_recon and recon_to_player then
			if control_info_load then
				control_info_load = false
				load_info_player:run()
				ATre_menu.v = true
				imgui.Process = true
				tool_re = 0
			end
		else
			ATre_menu.v = false
		end
		if not sampIsPlayerConnected(control_recon_playerid) then
			ATre_menu.v = false
			control_recon_playerid = -1
		end
		if ATre_menu.v then
			check_mouse = true
		end

		if isKeyDown(VK_R) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) and control_recon and recon_to_player then
			sampSendClickTextdraw(48)
		end
		---------- ���������� ������ -----------

		if isKeyDown(VK_NumPad6) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) and control_recon and recon_to_player then
			sampSendChat("/re " .. control_recon_playerid+1)
		end
		---------- ��������� ����� -----------

		if isKeyDown(VK_NumPad4) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) and control_recon and recon_to_player then
			sampSendChat("/re " .. control_recon_playerid-1)
		end
		---------- ���������� ����� -----------

		if isKeyDown(VK_Q) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) and control_recon and recon_to_player then
			recon_to_player = false
			sampSendChat("/reoff ")
		end
		--------------- ����� �� ������ ------------

		if isKeysDown(strToIdKeys(config.keys.Re_menu)) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) and control_recon and recon_to_player then
			right_re_menu = not right_re_menu	
		end
		--------- ��������� /remenu ---------------


		--------------- �������� ���������� ���� -------------
		if ac_no_saved.pos then
			if isKeyJustPressed(VK_RBUTTON) then
				admin_chat_lines.X = ac_no_saved.X
				admin_chat_lines.Y = ac_no_saved.Y
				ac_no_saved.pos = false
			elseif isKeyJustPressed(VK_LBUTTON) then
				ac_no_saved.pos = false
			else
				admin_chat_lines.X, admin_chat_lines.Y = getCursorPos()
			end
		end
		--------------- �������� ���������� ���� -------------

		if setting_items.ATAlogin.v == true then
			if sampGetCurrentDialogId() == 1227 and ATAdminPass.v and sampIsDialogActive() then
        	    sampSendDialogResponse(1227, 1, _, ATAdminPass.v)
				sampCloseCurrentDialogWithButton(1227, 1)
			end
		end
		-- �������������� ���� ������

		if isKeyDown(strToIdKeys(config.keys.ATOnline)) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) then
			sampSendChat("/online")
			wait(100)
			local c = math.floor(sampGetPlayerCount(false) / 10)
			sampSendDialogResponse(1098, 1, c - 1)
			sampCloseCurrentDialogWithButton(0)
			wait(650)
		end
		-- ��������� ���� ������� �� ������ �� online

		if isKeyDown(strToIdKeys(config.keys.ATTool)) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) then
			wait(100)
			one_window_state.v = not one_window_state.v
			imgui.Process = one_window_state.v
		end
		-- ��������� ���� ������� �� /tool

		if isKeyDown(strToIdKeys(config.keys.ATReportRP)) and sampIsDialogActive() then 
			local string = string.sub(sampGetCurrentDialogEditboxText(), 0, string.len(sampGetCurrentDialogEditboxText()) - 1)
			sampSetCurrentDialogEditboxText(string .. color() .. " | �������� ���� �� RDS <3 ")
			wait(650)
		end 
		-- ��������� ���� ������� �� /ans
		
		if isKeyDown(strToIdKeys(config.keys.ATReportRP1)) and sampIsDialogActive() then 
			local string = string.sub(sampGetCurrentDialogEditboxText(), 0, string.len(sampGetCurrentDialogEditboxText()) - 1)
			sampSetCurrentDialogEditboxText(string .. color() .. " | �������� �������������������. ")
			wait(650)
		end
		-- ��������� ���� ������� �� NumPad / (/ans)

		if isKeyDown(109) and sampIsDialogActive() then 
			local string = string.sub(sampGetCurrentDialogEditboxText(), 0, string.len(sampGetCurrentDialogEditboxText()) - 1)
			sampSetCurrentDialogEditboxText(string .. color() .. "��������� ������������������� �� ������� RDS!")
			wait(650)
		end
		-- ��������� ���� ������� �� NumPad - (/ans)

		if sampGetCurrentDialogEditboxText() == '/gvk' then 
			local string = string.sub(sampGetCurrentDialogEditboxText(), 0, string.len(sampGetCurrentDialogEditboxText()) - 1)
			sampSetCurrentDialogEditboxText(string .. color() .. "https://vk.com/dmdriftgta")
		end

		if sampGetCurrentDialogEditboxText() == '.����' or sampGetCurrentDialogEditboxText() == '/cxtn' then  
			sampSetCurrentDialogEditboxText('/count time || /dmcount time' .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.�' or sampGetCurrentDialogEditboxText() == '/w' then  
			sampSetCurrentDialogEditboxText(color())
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/rfh' then 
			sampSetCurrentDialogEditboxText('/car' .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/rgf' then 
			sampSetCurrentDialogEditboxText(color() .. '������� ����������, ��� ������ ����� �� /trade. ����� �������, /sell ����� �����')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/n.y' then 
			sampSetCurrentDialogEditboxText('/menu (/mm) - ALT/Y -> �/� -> ������ ' .. color() .. ' | �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/ufy' then 
			sampSetCurrentDialogEditboxText('/menu (/mm) - ALT/Y -> ������ ' .. color() .. ' | �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/lnn' then 
			sampSetCurrentDialogEditboxText('/dt 0-990 / ����������� ��� ' .. color() .. ' | �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/gtl' then 
			sampSetCurrentDialogEditboxText('/menu (/mm) - ALT/Y -> �������� ' .. color() .. ' | �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/bcr' then 
			sampSetCurrentDialogEditboxText(color() .. '������ ���������� �� ���� �����. ����� ������������ �� /garage. ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/yp' then 
			sampSetCurrentDialogEditboxText('�� ���������. '  .. color() .. ' | �������� ��������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/;lf' then 
			sampSetCurrentDialogEditboxText('��. ' .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/;yt' then 
			sampSetCurrentDialogEditboxText('���. ' .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/yr' then 
			sampSetCurrentDialogEditboxText('�����. ' .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/jna' then 
			sampSetCurrentDialogEditboxText('/familypanel ' .. color() .. ' | �������� ������������������� ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/jn,' then 
			sampSetCurrentDialogEditboxText('/menu (/mm) - ALT/Y -> ������� ���� ' .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/gh' then 
			sampSetCurrentDialogEditboxText('��������. ' .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/rh,' then 
			sampSetCurrentDialogEditboxText('������, ������, ������. ' .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/rvl' then 
			sampSetCurrentDialogEditboxText('������, ��, ����������, ������, ����� ����� �� �����(/trade)' .. color() .. ' | �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/uv' then 
			sampSetCurrentDialogEditboxText('GodMode (������) �� ������� �� ��������. ' .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/hku' then 
			sampSetCurrentDialogEditboxText('���������� ���������. '  .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/ydl' then 
			sampSetCurrentDialogEditboxText('�� ������. ' .. color() .. ' | �������� �������������������� ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/jaa' then 
			sampSetCurrentDialogEditboxText('�� ���������. ' .. color() .. ' | �������� ��������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/ytp' then 
			sampSetCurrentDialogEditboxText('�� �����.' .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/,fu' then 
			sampSetCurrentDialogEditboxText('������ ����� - ��� ���. ' .. color() .. ' | �������� ������������������� ')
		end

		if sampGetCurrentDialogEditboxText() == '/smh' or sampGetCurrentDialogEditboxText() == '.���' then 
			sampSetCurrentDialogEditboxText('/sellmyhouse (������)  ||  /hpanel -> ���� -> �������� -> ������� ��� �����������')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/lxl' then 
			sampSetCurrentDialogEditboxText('/hpanel -> ����1-3 -> �������� -> ������ ���� | �������� ���� �� RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/j,v' then
			sampSetCurrentDialogEditboxText(color() .. '����� �������� ������, ������� /trade, � ��������� � NPC ������, ����� ������') 
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/rng' then
			sampSetCurrentDialogEditboxText(color() .. '/tp (�� ��������), /g (/goto) id (� ������) � VIP (/help -> 7 �����)') 
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/rgn' then
			sampSetCurrentDialogEditboxText('��� ����, ����� ������ ����, ����� ������ /capture | ' .. color() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.��1' or sampGetCurrentDialogEditboxText() == '/dg1' then
			sampSetCurrentDialogEditboxText('������ ����� � ����������� Premuim VIP (/help -> 7) | ' .. color() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.��2' or sampGetCurrentDialogEditboxText() == '/dg2' then
			sampSetCurrentDialogEditboxText('������ ����� � ����������� Diamond VIP (/help -> 7) | ' .. color() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.��3' or sampGetCurrentDialogEditboxText() == '/dg3' then
			sampSetCurrentDialogEditboxText('������ ����� � ����������� Platinum VIP (/help -> 7) | ' .. color() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.��4' or sampGetCurrentDialogEditboxText() == '/dg4' then
			sampSetCurrentDialogEditboxText('������ ����� � ����������� "������" VIP (/help -> 7) | ' .. color() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.����' or sampGetCurrentDialogEditboxText() == '/gflv' then
			sampSetCurrentDialogEditboxText('������� �����, ��� �� /help -> 17 �����. | ' .. color() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.����' or sampGetCurrentDialogEditboxText() == '/rjgs' then
			sampSetCurrentDialogEditboxText('265-267, 280-286, 288, 300-304, 306, 307, 309-311 | ' .. color() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/,fk' then
			sampSetCurrentDialogEditboxText('102-104| ' .. color() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.����' or sampGetCurrentDialogEditboxText() == '/uhed' then
			sampSetCurrentDialogEditboxText('105-107 | ' .. color() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.����' or sampGetCurrentDialogEditboxText() == '/heva' then
			sampSetCurrentDialogEditboxText('111-113 | ' .. color() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/dfh' then
			sampSetCurrentDialogEditboxText('114-116 | ' .. color() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.�����' or sampGetCurrentDialogEditboxText() == '/nhbfl' then
			sampSetCurrentDialogEditboxText('117-188, 120 | ' .. color() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/dfu' then
			sampSetCurrentDialogEditboxText('108-110 | ' .. color() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/va' then
			sampSetCurrentDialogEditboxText('124-127 | ' .. color() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/cgh' then
			sampSetCurrentDialogEditboxText('/mm -> �������� -> ������� ������ | ' .. color() .. '  �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/vcg' then
			sampSetCurrentDialogEditboxText('/mm -> ������������ �������� -> ��� ����������| ' .. color() .. '  �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/ebl' then
			sampSetCurrentDialogEditboxText('�������� ID ����������/������ � /report ' .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/cng' then
			sampSetCurrentDialogEditboxText(color() .. '����� ���������� �����, �����, ����� � �.�. - /statpl ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/udv' then
			sampSetCurrentDialogEditboxText('��� �������� �����, ��������� ������ /givemoney IDPlayer ����� | ' .. color() .. ' �������� ����!')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/udc' then
			sampSetCurrentDialogEditboxText('��� �������� �����, ���������� ������ /givescore IDPlayer ����� |' .. color() .. ' � Diamond VIP.')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/gv' then
			sampSetCurrentDialogEditboxText('/sellmycar IDPlayer ����(1-3) RDScoin (������), � ���: /car | ' .. color() .. ' �������� ����!')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/de,' then
			sampSetCurrentDialogEditboxText(color() .. '����� ������ ������� ��������� �����, ���� �������: /gvig ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/px' then
			sampSetCurrentDialogEditboxText('���� �� ��������, ������� /spawn | /kill, ' .. color() .. ' �� �� ����� ��� ������! ')
		end

		if sampGetCurrentDialogEditboxText() == '/prk' or sampGetCurrentDialogEditboxText() == '.���' then
			sampSetCurrentDialogEditboxText('/parkour - ��������� �� ������ | '  .. color() ..  ' �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '/drb' or sampGetCurrentDialogEditboxText() == '.���' then
			sampSetCurrentDialogEditboxText('/derby - ��������� �� ����� | '  .. color() ..  ' �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/gcd' then
			sampSetCurrentDialogEditboxText('/passive ' .. color() ..  ' �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/bya' then
			sampSetCurrentDialogEditboxText('������ ���������� ����� ������ � ���������. '  .. color() ..  ' �������� ����!')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/ju' then
			sampSetCurrentDialogEditboxText('������ �� ����� "���������� �����", ����� ����� ����� �������� �� ALT � ����� �� ������� ������ �� �����' .. color() ..  ' �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/j;' then
			sampSetCurrentDialogEditboxText('��������. '  .. color() ..  ' ��������� ������������������� �� RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.����' or sampGetCurrentDialogEditboxText() == '/wdtn' then 
			sampSetCurrentDialogEditboxText('https://colorscheme.ru/html-colors.html ' .. color() .. ' �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/;,f' then
			sampSetCurrentDialogEditboxText('������ ������ �� �������������� � VK: vk.com/dmdriftgta ')
		end

		if sampGetCurrentDialogEditboxText() == '.���'or sampGetCurrentDialogEditboxText() == '/;,b'  then
			sampSetCurrentDialogEditboxText('�� ������ �������� ������ �� ������ � VK: vk.com/dmdriftgta ')
		end

		lua_thread.create(function()
			if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/yx' then
				sampSetCurrentDialogEditboxText('�����(�) ������ �� ����� ������! ' .. color() .. ' �������� ���� �� ������� RDS. <3 ')
				wait(2000)
				sampSetChatInputEnabled(true)
				sampSetChatInputText("/re " )
			end
		end)

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/bx' then
			sampSetCurrentDialogEditboxText('������ ����� ����. ' .. color() .. ' �������� ���� �� ������� RDS. <3 ')
		end

		lua_thread.create(function()
			if sampGetCurrentDialogEditboxText() == '.��' then
				sampSetCurrentDialogEditboxText(color() .. ' ����� �� ������ �������, ��������. :3 ')
				wait(2000)
				sampSetChatInputEnabled(true)
				sampSetChatInputText("/re " )
			end
		end)

		if sampGetCurrentDialogEditboxText() == '.�7' or sampGetCurrentDialogEditboxText() == '/g7' then
			sampSetCurrentDialogEditboxText('������ ���������� ����� ����� � /help -> 7 �����. | '  .. color() ..  ' �������� ���� �� RDS. <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.�13' or sampGetCurrentDialogEditboxText() == '/g13' then
			sampSetCurrentDialogEditboxText('������ ���������� ����� ����� � /help -> 13 �����. | '  .. color() ..  ' �������� ���� �� RDS. <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.�8' or sampGetCurrentDialogEditboxText() == '/g8' then
			sampSetCurrentDialogEditboxText('������ ���������� ����� ����� � /help -> 8 �����. | '  .. color() ..  ' �������� ���� �� RDS. <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/yfr' then
			sampSetCurrentDialogEditboxText('������ ����� �������. | '  .. color() ..  '  �������� ���� �� RDS! <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/yy' then
			sampSetCurrentDialogEditboxText('�� ���� ��������� �� ������. | ' .. color() .. ' �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/yd' then
			sampSetCurrentDialogEditboxText('������ ����� �� � ����. | ' .. color() .. ' �������� ���� �� RDS. <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/,r' then
			sampSetCurrentDialogEditboxText('�������� ������/��� ����� � ������� /bank ��� /tp -> ������ -> ���� ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/nfc' then
			sampSetCurrentDialogEditboxText('/tp -> ������ -> ���������� |' .. color() .. '  �������� ���� �� RDS. <3')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/nfv' then
			sampSetCurrentDialogEditboxText('/tp -> ������ -> ���������� -> �������������� | ' .. color() .. ' �������� ���� �� RDS. <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/gua' then
			sampSetCurrentDialogEditboxText('/gleave (�����) || /fleave (�����)| ' .. color() .. ' �������� ���� �� RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/gkv' then
			sampSetCurrentDialogEditboxText('/leave (�������� �����)| ' .. color() .. ' �������� ���� �� RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/en' then
			sampSetCurrentDialogEditboxText('�������� ��� ������/������. ' .. color() .. ' ������� ���� <3')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/gu,' then
			sampSetCurrentDialogEditboxText('/ginvite (�����) || /finvite (�����) | ' .. color() .. ' ������� ���� �� RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/eu,' then
			sampSetCurrentDialogEditboxText('/guninvite (�����) || /funinvite (�����) | ' .. color() .. ' ������� ���� �� RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/udh' then
			sampSetCurrentDialogEditboxText('/giverub IDPlayer rub | � ������� (/help -> 7) | ' .. color() .. ' ������� ���� �� RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/udr' then
			sampSetCurrentDialogEditboxText('/givecoin IDPlayer coin | � ������� (/help -> 7) | ' .. color() .. ' ������� ���� �� RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/gd' then
			sampSetCurrentDialogEditboxText('������� ���. | ' .. color() .. ' ������� ���� �� RDS <3')
		end

		if string.find(sampGetChatInputText(), "%.��") then
			sampSetChatInputText(string.gsub(sampGetChatInputText(), ".��", "| �������� ���� �� RDS <3"))
		end

		if string.find(sampGetChatInputText(), "%/vrm") then
			sampSetChatInputText(string.gsub(sampGetChatInputText(), "/vrm", "��������� ������������������� �� Russian Drift Server!"))
		end

		if string.find(sampGetChatInputText(), "%/gvk") then
			sampSetChatInputText(string.gsub(sampGetChatInputText(), "/gvk", "https://vk.com/dmdriftgta"))
		end

		if isKeyDown(strToIdKeys(config.keys.ATReportRP2)) and sampIsChatInputActive() then
			local string = string.sub(sampGetChatInputText(), 0, string.len(sampGetChatInputText()) - 1)
			sampSetChatInputText(string .. " | �������� ���� �� RDS! <3")
			wait(650)
		end

		if isKeyJustPressed(strToIdKeys(config.keys.ATReportAns)) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) then
			sampSendChat("/ans ")
			sampSendDialogResponse (2348, 1, 0)
		end

		if isKeyDown(strToIdKeys(config.keys.ATWHkeys)) then  
			if control_wallhack then
				sampAddChatMessage(tag .."WallHack ��� ��������.")
				nameTagOff()
				control_wallhack = false
			else
				sampAddChatMessage(tag .."WallHack ��� �������.")
				nameTagOn()
				control_wallhack = true
			end
		end

		-- NumPad0 - ��������� /ans, isKeyJustPressed �������� ��������, ����� ������������ �������
		-- ������ ������ ����, �������� ������� � /ans (����.������ $)
		-- ���� ������������� ���������� (���� ���� �������)

	end
end

local lc_lvl, lc_adm, lc_color, lc_nick, lc_id, lc_text

-- ������ ��������� --
function pradm1(arg)
	sampSendChat("/prefix " .. arg .. " ��.������������� " .. prefix_Madm.v)
end

function pradm2(arg)
	sampSendChat("/prefix " .. arg .. " ������������� " .. prefix_adm.v)
end  

function pradm3(arg)
	sampSendChat("/prefix " .. arg .. " ��.������������� " .. prefix_STadm.v)
end  

function pradm4(arg)
	sampSendChat("/prefix " .. arg .. " ���.��.�������������� " .. prefix_ZGAadm.v)
end  

function pradm5(arg)
	sampSendChat("/prefix " .. arg .. " �������.������������� " .. prefix_GAadm.v)
end  
-- ������ ��������� --

function tpcord(coords)
	local x, y, z = coords:match('(.+) (.+) (.+)') 
	setCharCoordinates(PLAYER_PED, x, y, z)
end  
-- ������������ �� �����������

function tpad(arg)
	sampAddChatMessage(tag .. " ������������ �� ���������������� ������.. ")
	setCharCoordinates(PLAYER_PED,3321,2308,35)
end
-- ������������ �� �����-������

function iddialog(arg)
	iddea = sampGetCurrentDialogId()
	sampAddChatMessage(tag .. "������ � ID: " .. iddea)
end
-- ����� ID ����������/��������� �������

function delch(arg)
	notify.addNotify("{87CEEB}[AdminTool]", '���������� ������� ���� ��������', 2, 1, 6)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
end
-- �������, ���������� �� ������� ���� (������)

function cmd_tool(arg)
	one_window_state.v = not one_window_state.v
	imgui.Process = one_window_state.v
end
-- �������������� ��������� AdminTool

function cmd_toolmp(arg)
	two_window_state.v = not two_window_state.v
	imgui.Process = two_window_state.v
end
-- ��������������� ��������� AdminTool �� MP

function cmd_toolfd(arg)
	three_window_state.v = not three_window_state.v
	imgui.Process = three_window_state.v
end
-- ��������������� ��������� AdminTool �� flood

function cmd_toolans(arg)
	four_window_state.v = not four_window_state.v
	imgui.Process = four_window_state.v
end
-- ��������������� ��������� AdminTool �� /ans

function cmd_tooladm(arg)
	if AdminLevel.v >= 15 then
		five_window_state.v = not five_window_state.v	
		imgui.Process = five_window_state.v
	else 
		sampAddChatMessage(tag .. "��� ������� ���!") 
	end
end  
-- ��������������� ��������� AdminTool ��� ������� �������������

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

function cmd_nba(arg)
	thread:run("nba")
end
-- ������ �������� ������� ��� ������ ���������������

function cmd_dpv(arg)
	thread:run("dpv")
end  
-- ������ �������� ������� ��� ������ ��������� ��� �������� �� ����

function cmd_arep(arg) 
	thread:run("arep")
end  
-- ������ �������� ������� ��� ���������� �������

function thread_function(opt)
	if opt == "dpv" then  
		sampSendChat("/gethere " .. arg)
		wait(1000)
		sampSendChat("/freeze " .. arg)
		wait(3000)
		sampSendChat("/d �������� �� ��������� ��. ����� - ���.")
		wait(3000)
		sampSendChat("/d �������� �� ��������� ��. �� � /d ���.")
	end
	if opt == "nba" then 
		sampSendChat("/d ������������!")
		wait(3000)
		sampSendChat("/d �� ������� �� ����������� ���� � ���� ��������������?")
	end
	if AdminLevel.v >= 15 then
		if opt == "arep" then  
			sampSendChat("/a /ans -> �������� �� ������")
			wait(2500)
			sampSendChat("/a /ans -> �������� �� ������")
			wait(2500)
			sampSendChat("/a /ans -> �������� �� ������")
		end
	else 
		sampAddChatMessage(tag .. " ��� ������� ���! ")
	end
	-- ������ ������������/��������� ������� ��� ������ ���������������
end	


-- function sampev.onSendClickTextDraw(id)
	-- sampAddChatMessage(tag .. " ID TextDraw: " .. id)
-- end
------- �������, ����������� � ����� -------

function cmd_fd1(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then 
			sampSendChat("/mute " .. arg .. " 120 " .. " ����/����")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /mute " .. arg .. " 120 " .. " ����/���� ")
		end)
	end
end

function cmd_fd2(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then 
			sampSendChat("/mute " .. arg .. " 240 " .. " ����/���� - x2 ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /mute " .. arg .. " 240 " .. " ����/���� - x2 ")
		end)
	end
end

function cmd_fd3(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
	   		sampSendChat("/mute " .. arg .. " 360 " .. " ����/���� - x3 ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /mute " .. arg .. " 360 " .. " ����/���� - x3 ")
		end)
	end
end

function cmd_fd4(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then 
			sampSendChat("/mute " .. arg .. " 480 " .. " ����/���� - x4 ")
		else
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /mute " .. arg .. " 480 " .. " ����/���� - x4 ")
		end)
	end
end

function cmd_fd5(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then 
			sampSendChat("/mute " .. arg .. " 600 " .. " ����/���� - x5 ")
		else
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /mute " .. arg .. " 600 " .. " ����/���� - x5 ")
		end)
	end
end

function cmd_po1(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/mute "  .. arg .. " 120 " .. " ����������������")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /mute " .. arg .. " 120 " .. " ����������������")
		end)
	end
end

function cmd_po2(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/mute " .. arg .. " 240 " .. " ���������������� - x2")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /mute " .. arg .. " 240 " .. " ���������������� - x2")
		end)
	end
end

function cmd_po3(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/mute " .. arg .. " 360 " .. " ���������������� - x3")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /mute " .. arg .. " 360 " .. " ���������������� - x3")
		end)
	end
end

function cmd_po4(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/mute " .. arg .. " 480 " .. " ���������������� - x4")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /mute " .. arg .. " 480 " .. " ���������������� - x4")
		end)
	end
end

function cmd_po5(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/mute " .. arg .. " 600 " .. " ���������������� - x5")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /mute " .. arg .. " 600 " .. " ���������������� - x5")
		end)
	end
end

function cmd_m(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/mute " .. arg .. " 300 " .. " ����������� �������. ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /mute " .. arg .. " 300 " .. " ����������� �������. ")
		end)
	end
end

function cmd_ia(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/mute " ..  arg .. " 2500 " .. " ������ ���� �� ������������� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /mute " .. arg .. " 2500 " .. " ������ ���� �� ������������� ")
		end)
	end
end

function cmd_kl(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/mute " .. arg .. " 3000 " .. " ������� �� ������������� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /mute " .. arg .. " 3000 " .. " ������� �� ������������� ")
		end)
	end
end

function cmd_oa(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/mute " .. arg .. " 2500 " .. " �����������/�������� �������������� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /mute " .. arg .. " 2500 " .. " �����������/�������� �������������� ")
		end)
	end
end

function cmd_ok(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/mute " .. arg .. " 400 " .. " �����������/��������. ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /mute " .. arg .. " 400  " .. " �����������/��������. ")
		end)
	end
end

function cmd_nm1(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/mute " .. arg .. " 2500 " .. " ������������ ��������� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /mute " .. arg .. " 2500 " .. " ������������ ��������� ")
		end)
	end
end

function cmd_nm2(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/mute " .. arg .. " 5000 " ..  " ������������ ��������� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /mute " .. arg .. " 5000 " .. " ������������ ��������� ")
		end)
	end
end

function cmd_or(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/mute " .. arg .. " 5000 " .. " �����������/�������� ������ ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /mute " .. arg .. " 5000 " .. " �����������/�������� ������ ")
		end)
	end
end

function cmd_nm(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/mute " .. arg .. " 900 " .. " ������������ ��������� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /mute " .. arg .. " 900 " .. " ������������ ��������� ")
		end)
	end
end

function cmd_up(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/mute " .. arg .. " 1000 " .. " ���������� ��������� �������� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /mute " .. arg .. " 1000 " .. " ���������� ��������� �������� ")
		end)
	end
end
------- �������, ����������� � ����� -------


------- �������, ����������� � ����� �� ������ -------
function cmd_rup(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/rmute " .. arg .. " 1000 " .. " ���������� ��������� ��������. ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /rmute " .. arg .. " 1000 " .. " ���������� ��������� �������� ")
		end)
	end
end
 
function cmd_ror(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/rmute " .. arg .. " 5000 " .. " �����������/�������� ������ ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /rmute " .. arg .. " 5000 " .. " �����������/�������� ������ ")
		end)
	end
end
  
function cmd_cp(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/rmute " .. arg .. " 120 " .. " caps/offtop in report ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /rmute " .. arg .. " 120 " .. " caps/offtop in report ")
		end)
	end
end
  
function cmd_rpo(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/rmute " .. arg .. " 120 " .. " ���������������� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /rmute " .. arg .. " 120 " .. " ���������������� ")
		end)
	end
end

function cmd_rm(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/rmute " .. arg .. " 300 " .. " ����������� �������. ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /rmute " .. arg .. " 300 " .. " ����������� �������. ")
		end)
	end
end

function cmd_roa(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/rmute " .. arg .. " 2500 " .. " �����������/�������� ������������� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /rmute " .. arg .. " 2500 " .. " �����������/�������� ������������� ")
		end)
	end
end

function cmd_rnm(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/rmute " .. arg .. " 900 " .. " ������������ ��������� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /rmute " .. arg .. " 900  " .. " ������������ ��������� ")
		end)
	end
end

function cmd_rnm1(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/rmute " .. arg .. " 2500 " .. " ������������ ��������� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /rmute " .. arg .. " 2500 " .. " ������������ ��������� ")
		end)
	end
end

function cmd_rnm2(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/rmute " .. arg .. " 5000 " ..  " ������������ ��������� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /rmute " .. arg .. " 5000 " .. " ������������ ��������� ")
		end)
	end
end

function cmd_rok(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/rmute " .. arg .. " 400 " .. " �����������/��������. ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /rmute " .. arg .. " 400 " .. " �����������/��������. ")
		end)
	end
end
------- �������, ����������� � ����� �� ������ -------





------- �������, ����������� � ������� -------
function cmd_sk(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/jail " .. arg .. " 300 " .. " Spawn Kill")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /jail " .. arg .. " 300 " .. " SpawnKill ")
		end)
	end
end

function cmd_dz(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/jail " .. arg .. " 300 " .. " DM/DB in zz")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /jail " .. arg .. " 300 " .. " DM/DB in zz ")
		end)
	end
end

function cmd_dz1(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/jail " .. arg .. " 600 " .. " DM/DB in zz x2")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /jail " .. arg .. " 600 " .. " DM/DB in zz x2 ")
		end)
	end
end

function cmd_dz2(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/jail " .. arg .. " 900 " .. " DM/DB in zz x3")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /jail " .. arg .. " 900 " .. " DM/DB in zz x3 ")
		end)
	end
end

function cmd_dz3(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/jail " .. arg .. " 1200 " .. " DM/DB in zz x4")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /jail " .. arg .. " 1200 " .. " DM/DB in zz x4 ")
		end)
	end
end

function cmd_td(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/jail " .. arg .. " 300 " .. " DB/car in trade ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /jail " .. arg .. " 300 " .. " DB/car in trade ")
		end)
	end
end

function cmd_jm(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/jail " .. arg .. " 300 " .. " ��������� ������ �� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /jail " .. arg .. " 300 " .. " ��������� ������ �� ")
		end)
	end
end

function cmd_pmx(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/jail " .. arg .. " 300 " .. " ��������� ������ ������� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /jail " .. arg .. " 300 " .. " ��������� ������ ������� ")
		end)
	end
end

function cmd_skw(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/jail " .. arg .. " 600 " .. " SK in /gw ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /jail " .. arg .. " 600 " .. " SK in /gw ")
		end)
	end
end

function cmd_dgw(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/jail " .. arg .. " 500 " .. " ������������� ���������� in /gw ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /jail " .. arg .. " 500 " .. " ������������� ���������� in /gw ")
		end)
	end
end

function cmd_ngw(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/jail " .. arg .. " 600 " .. " ������������� ����������� ������ in /gw ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /jail " .. arg .. " 600 " .. " ������������� ����������� ������ in /gw ")
		end)
	end
end

function cmd_dbgw(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/jail " .. arg .. " 600 " .. " ������������� ��������� in /gw ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /jail " .. arg .. " 600 " .. " ������������� ��������� in /gw ")
		end)
	end
end

function cmd_fsh(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/jail " .. arg .. " 900 " .. " ������������� SpeedHack/FlyCar ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /jail " .. arg .. " 900 " .. " ������������� SpeedHack/FlyCar ")
		end)
	end
end

function cmd_bag(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/jail " .. arg .. " 300 " .. " ������� ������ (deagle in car)")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /jail " .. arg .. " 300 " .. " ������� ������ (deagle in car) ")
		end)
	end
end

function cmd_pk(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/jail " .. arg .. " 900 " .. " ������������� ������/����� ���� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /jail " .. arg .. " 900 " .. " ������������� ������/����� ���� ")
		end)
	end
end

function cmd_jch(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/jail " .. arg .. " 3000 " .. " ������������� ���������� �������/�� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /jail " .. arg .. " 3000 " .. " ������������� ���������� �������/�� ")
		end)
	end
end

function cmd_zv(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/jail " ..  arg .. " 3000 " .. " ��������������� VIP`om ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /jail " .. arg .. " 3000 " .. " �������������� VIP`om ")
		end)
	end
end

function cmd_sch(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/jail " .. arg .. " 900 " .. " ������������� ����������� �������� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /jail " .. arg .. " 900 " .. " ������������� ����������� �������� ")
		end)
	end
end

function cmd_jcw(arg)
	if AdminLevel.v >= 2 then 
		if #arg > 0 then
			sampSendChat("/jail " .. arg .. " 900 " .. " ������������� ClickWarp/Metla (���)")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /jail " .. arg .. " 900 " .. " ������������� ClickWarp/Metla (���) ")
		end)
	end
end
------- �������, ����������� � ������� -------


------- �������, ����������� � ����� -------
function cmd_hl(arg)
	if AdminLevel.v >= 6 then
		if #arg > 0 then
			sampSendChat("/ans " .. arg .. " ��������� �����, �� �������� ������� �������, � ���� ��..")
			sampSendChat("/ans " .. arg .. " ..�� �������� � ����������, �������� ������ � VK: dmdriftgta")
			sampSendChat("/iban " .. arg .. " 3 " .. " �����������/��������/��� � �������")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)	
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /iban " .. arg .. " 3 " .. " �����������/��������/��� � ������� ")
		end)
	end
end

function cmd_pl(arg)
	if AdminLevel.v >= 6 then
		if #arg > 0 then
			sampSendChat("/ans " .. arg .. " ��������� �����, �� �������� ������� �������, � ���� ��..")
			sampSendChat("/ans " .. arg .. " ..�� �������� � ����������, �������� ������ � VK: dmdriftgta")
			sampSendChat("/ban " .. arg .. " 7 " .. " ������� ���� �������������� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /ban " .. arg .. " 7 " .. " ������� ���� �������������� ")
		end)
	end	
end

function cmd_ob(arg)
	if AdminLevel.v >= 6 then
		if #arg > 0 then
			sampSendChat("/ans " .. arg .. " ��������� �����, �� �������� ������� �������, � ���� ��..")
			sampSendChat("/ans " .. arg .. " ..�� �������� � ����������, �������� ������ � VK: dmdriftgta")
			sampSendChat("/iban " .. arg .. " 7 " .. " ����� �������� ���� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /iban " .. arg .. " 7 " .. " ����� �������� ���� ")
		end)
	end	
end 	

function cmd_ch(arg)
	if AdminLevel.v >= 6 then
		if #arg > 0 then
			sampSendChat("/ans " .. arg .. " ��������� �����, �� �������� ������� �������, � ���� ��..")
			sampSendChat("/ans " .. arg .. " ..�� �������� � ����������, �������� ������ � VK: dmdriftgta")
			sampSendChat("/iban " .. arg .. " 7 " .. " ������������� ���������� �������/��. ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /ban " .. arg .. " 7 " .. " ������������� ���������� �������/��. ")
		end)
	end	
end

function cmd_gcnk(arg)
	if AdminLevel.v >= 6 then
		if #arg > 0 then
			sampSendChat("/ans " .. arg .. " ��������� �����, �� �������� ������� �������, � ���� ��..")
			sampSendChat("/ans " .. arg .. " ..�� �������� � ����������, �������� ������ � VK: dmdriftgta")
			sampSendChat("/iban " .. arg .. " 7 " .. " �����, ���������� ����������� ������� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /iban " .. arg .. " 7 " .. " �����, ���������� ����������� ������� ")
		end)
	end	
end

function cmd_menk(arg)
	if AdminLevel.v >= 6 then
		if #arg > 0 then
			sampSendChat("/ans " .. arg .. " ��������� �����, �� �������� ������� �������, � ���� ��..")
			sampSendChat("/ans " .. arg .. " ..�� �������� � ����������, �������� ������ � VK: dmdriftgta")
			sampSendChat("/ban " .. arg .. " 7 " .. " ���, ����������� ����������� ����� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /ban " .. arg .. " 7 " .. " ���, ����������� ����������� ����� ")
		end)
	end	
end

function cmd_nk(arg)
	if AdminLevel.v >= 6 then
		if #arg > 0 then
			sampSendChat("/ans " .. arg .. " ��������� �����, �� �������� ������� �������, � ���� ��..")
			sampSendChat("/ans " .. arg .. " ..�� �������� � ����������, �������� ������ � VK: dmdriftgta")
			sampSendChat("/ban " .. arg .. " 7 " .. " ���, ���������� ����������� ������� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /ban " .. arg .. " 7 " .. " ���, ���������� ����������� ������� ")
		end)
	end	
end


------- �������, ����������� � ����� -------

------- �������, ����������� � ������� � �������� -------

function cmd_asch(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/prisonakk " .. arg .. " 900 " .. " ������������� ����������� �������� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /prisonakk " .. arg .. " 900 " .. " ������������� ����������� �������� ")
		end)
	end	
end

function cmd_ajch(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/prisonakk " .. arg .. " 3000 " .. " ������������� ���������� �������/�� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /prisonakk " .. arg .. " 3000 " .. " ������������� ���������� �������/�� ")
		end)
	end	
end

function cmd_azv(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/prisonakk " ..  arg .. " 3000 " .. " ��������������� VIP`om ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /prisonakk " .. arg .. " 3000 " .. " ��������������� VIP`om ")
		end)
	end	
end

function cmd_adgw(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/prisonakk " .. arg .. " 500 " .. " ������������� ���������� in /gw ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /prisonakk " .. arg .. " 500 " .. " ������������� ���������� in /gw ")
		end)
	end	
end

function cmd_ask(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/prisonakk " .. arg .. " 300 " .. " SpawnKill ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /prisonakk " .. arg .. " 300 " .. " SpawnKill ")
		end)
	end	
end

function cmd_adz(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/prisonakk " .. arg .. " 300 " .. " DM/DB in zz ")	
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /prisonakk " .. arg .. " 300 " .. " DM/DB in zz ")
		end)
	end	
end

function cmd_adz1(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/prisonakk " .. arg .. " 600 " .. " DM/DB in zz x2")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /prisonakk " .. arg .. " 600 " .. " DM/DB in zz x2 ")
		end)
	end	
end

function cmd_adz2(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/prisonakk " .. arg .. " 900 " .. " DM/DB in zz x3")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /prisonakk " .. arg .. " 900 " .. " DM/DB in zz x3 ")
		end)
	end	
end

function cmd_adz3(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/prisonakk " .. arg .. " 1200 " .. " DM/DB in zz x4")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /prisonakk " .. arg .. " 1200 " .. " DM/DB in zz x4 ")
		end)
	end	
end

function cmd_atd(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/prisonakk " .. arg .. " 300 " .. " DB/car in trade ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /prisonakk " .. arg .. " 300 " .. " DB/car in trade ")
		end)
	end	
end

function cmd_ajm(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/prisonakk " .. arg .. " 300 " .. " ��������� ������ �� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /prisonakk " .. arg .. " 300 " .. " ��������� ������ �� ")
		end)
	end	
end

function cmd_apmx(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/prisonakk " .. arg .. " 300 " .. " ��������� ������ ������� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /prisonakk " .. arg .. " 300 " .. " ��������� ������ ������� ")
		end)
	end	
end

function cmd_askw(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/prisonakk " .. arg .. " 600 " .. " SK in /gw ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /prisonakk " .. arg .. " 600 " .. " SK in /gw ")
		end)
	end	
end

function cmd_angw(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/prisonakk " .. arg .. " 600 " .. " ������������� ����������� ������ in /gw ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /prisonakk " .. arg .. " 600 " .. " ������������� ����������� ������ in /gw ")
		end)
	end	
end

function cmd_adbgw(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/prisonakk " .. arg .. " 600 " .. " db-����, �������� � ���/����/����� in /gw ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /prisonakk " .. arg .. " 600 " .. " db-����, �������� � ���/����/����� in /gw ")
		end)
	end	
end

function cmd_afsh(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/prisonakk " .. arg .. " 900 " .. " ������������� SpeedHack/FlyCar ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /prisonakk " .. arg .. " 900 " .. " ������������� SpeedHack/FlyCar ")
		end)
	end	
end

function cmd_abag(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/prisonakk " .. arg .. " 300 " .. " ������� ������ (deagle in car)")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /prisonakk " .. arg .. " 300 " .. " ������� ������ (deagle in car) ")
		end)
	end	
end

function cmd_apk(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/prisonakk " .. arg .. " 900 " .. " ������������� ������/����� ���� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /prisonakk " .. arg .. " 900 " .. " ������������� ������/����� ���� ")
		end)
	end	
end

function cmd_ajcw(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/prisonakk " .. arg .. " 900 " .. " ������������� ClickWarp/Metla (���)")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /prisonakk " .. arg .. " 900 " .. " ������������� ClickWarp/Metla (���) ")
		end)
	end	
end
------- �������, ����������� � ������� � �������� -------


------- �������, ����������� � ����� � �������� -------
function cmd_afd(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/muteakk " .. arg .. " 120 " .. " ����/����")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /muteakk " .. arg .. " 120 " .. " ����/���� ")
		end)
	end	
end

function cmd_apo(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/muteakk " .. arg .. " 120 " .. " ���������������� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /muteakk " .. arg .. " 120 " .. " ���������������� ")
		end)
	end	
end

function cmd_am(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/muteakk " .. arg .. " 300 " .. " ����������� �������.")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /muteakk " .. arg .. " 300 " .. " ����������� �������. ")
		end)
	end	
end

function cmd_aok(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/muteakk " .. arg .. " 400 " .. " �����������/��������. ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /muteakk " .. arg .. " 400 " .. " �����������/��������. ")
		end)
	end	
end

function cmd_anm(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/muteakk " .. arg .. " 900 " .. " ������������ ��������� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /muteakk " .. arg .. " 900 " .. " ������������ ��������� ")
		end)
	end	
end

function cmd_anm1(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/muteakk " .. arg .. " 2500 " .. " ������������ ��������� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /muteakk " .. arg .. " 2500 " .. " ������������ ��������� ")
		end)
	end	
end

function cmd_anm2(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/muteakk " .. arg .. " 5000 " .. " ������������ ��������� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /muteakk " .. arg .. " 5000 " .. " ������������ ��������� ")
		end)
	end	
end

function cmd_aoa(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/muteakk " .. arg .. " 2500 " .. " �����������/�������� ������������� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /muteakk " .. arg .. " 2500 " .. " �����������/�������� ������������� ")
		end)
	end	
end

function cmd_aor(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/muteakk " .. arg .. " 5000 " .. " �����������/��������/���������� ������ ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /muteakk " .. arg .. " 5000 " .. " �����������/��������/���������� ������ ")
		end)
	end	
end

function cmd_aup(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/muteakk " .. arg .. " 1000 " .. " ���������� ����� ������� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /muteakk " .. arg .. " 1000 " .. " ���������� ����� ������� ")
		end)
	end	
end 

function cmd_aia(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/muteakk " .. arg .. " 2500 " .. " ������ ���� �� �������������� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /muteakk " .. arg .. " 2500 " .. " ������ ���� �� �������������� ")
		end)
	end	
end

function cmd_akl(arg)
	if AdminLevel.v >= 2 then
		if #arg > 0 then
			sampSendChat("/muteakk " .. arg .. " 3000 " .. " ������� �� ������������� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /muteakk " .. arg .. " 3000 " .. " ������� �� ������������� ")
		end)
	end	
end
------- �������, ����������� � ����� � �������� -------


------- �������, ����������� � ����� -------
function cmd_dj(arg)
	if AdminLevel.v >= 3 then
		if #arg > 0 then
			sampSendChat("/kick " .. arg .. " dm in jail ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /kick " .. arg .. " dm in jail ")
		end)
	end	
end

function cmd_gnk1(arg)
	if AdminLevel.v >= 3 then
		if #arg > 0 then
			sampSendChat("/kick " .. arg .. " ������� �������. 1/3 ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /kick " .. arg .. " ������� �������. 1/3 ")
		end)
	end	
end

function cmd_gnk2(arg)
	if AdminLevel.v >= 3 then
		if #arg > 0 then
			sampSendChat("/kick " .. arg .. " ������� �������. 2/3 ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /kick " .. arg .. " ������� �������. 2/3 ")
		end)
	end	
end

function cmd_gnk3(arg)
	if AdminLevel.v >= 3 then
		if #arg > 0 then
			sampSendChat("/kick " .. arg .. " ������� �������. 3/3 ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /kick " .. arg .. " ������� �������. 3/3 ")
		end)
	end	
end

function cmd_cafk(arg)
	if AdminLevel.v >= 3 then
		if #arg > 0 then
			sampSendChat("/kick " .. arg .. " AFK in /arena ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ ID ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /kick " .. arg .. " AFK in /arena ")
		end)
	end	
end
------- �������, ����������� � ����� -------


-------- �������, ����������� � ����� � �������� -----------

function cmd_amenk(arg)
	if AdminLevel.v >= 7 then
		if #arg > 0 then
			sampSendChat("/banakk " .. arg .. " 7 " .. " ���, ����������� ����������� ����� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /banakk " .. arg .. " 7 " .. " ���, ����������� ����������� �����")
		end)
	end	
end


function cmd_ahl(arg)
	if AdminLevel.v >= 7 then
		if #arg > 0 then
			sampSendChat("/offban " .. arg .. " 3 " .. " ���/��������/��� � �������")
			sampSendChat("/offstats " .. arg)
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /banakk " .. arg .. " 3 " .. " ���/��������/��� � �������")
		end)
	end	
end

function cmd_ahli(arg)
	if AdminLevel.v >= 12 then
		if #arg > 0 then
			sampSendChat("/banip " .. arg .. " 3 " .. " ���/��������/��� � �������")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ IP ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /banip " .. arg .. " 3 " .. " ���/��������/��� � �������")
		end)
	end	
end

function cmd_aob(arg)
	if AdminLevel.v >= 7 then
		if #arg > 0 then
			sampSendChat("/offban " .. arg .. " 7 " .. " ����� ���� ")
			sampSendChat("/offstats " .. arg)
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /banakk " .. arg .. " 7 " .. " ����� ����")
		end)
	end	
end

function cmd_apl(arg)
	if AdminLevel.v >= 7 then
		if #arg > 0 then
			sampSendChat("/offban " .. arg .. " 7 " .. " ������� �������� ��������������")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /banakk " .. arg .. " 7 " .. " ������� �������� ��������������")
		end)
	end	
end

function cmd_ach(arg)
	if AdminLevel.v >= 7 then
		if #arg > 0 then
			sampSendChat("/offban " .. arg .. " 7 " .. "  ������������� ���������� �������/�� ")
			sampSendChat("/offstats " .. arg)
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /banakk " .. arg .. " 7 " .. " ������������� ���������� �������/�� ")
		end)
	end	
end

function cmd_achi(arg)
	if AdminLevel.v >= 12 then
		if #arg > 0 then
			sampSendChat("/banip " .. arg .. " 7 " .. " ���/�� (ip) ") 
		else 
			sampAddChatMessage(tag .. "�� ������ ������ IP ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /banip " .. arg .. " 7 " .. " ���/�� (ip)")
		end)
	end	
end

function cmd_ank(arg)
	if AdminLevel.v >= 7 then
		if #arg > 0 then
			sampSendChat("/banakk " .. arg .. " 7 " .. " ���, ���������� ������������ ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /banakk " .. arg .. " 7 " .. " ���, ���������� ������������")
		end)
	end	
end

function cmd_agcnk(arg)
	if AdminLevel.v >= 7 then
		if #arg > 0 then
			sampSendChat("/banakk " .. arg .. " 7 " .. " �����, �������� ������������")
			sampSendChat("/offstats " .. arg)
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /banakk " .. arg .. " 7 " .. " �����, �������� ������������")
		end)
	end	
end

function cmd_agcnkip(arg)
	if AdminLevel.v >= 12 then
		if #arg > 0 then
			sampSendChat("/banip " .. arg .. " 7 "  .. " �����, �������� ������������ (ip)")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ IP ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /banip " .. arg .. " 7 " .. " �����, ���������� ������������ (ip)")
		end)
	end	
end

function cmd_okpr(arg)
	if AdminLevel.v >= 7 then
		if #arg > 0 then
			sampSendChat("/banakk " .. arg .. " 30 " .. " ����������� � ������� �������. ")
			sampSendChat("/offstats " .. arg)
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /banakk " .. arg .. " 30 " .. " ����������� � ������� �������. ")
		end)
	end	
end

function cmd_okprip(arg)
	if AdminLevel.v >= 12 then
		if #arg > 0 then
			sampSendChat("/banip " .. arg .. " 30 " .. " ����������� � ������� �������. ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ IP ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /banip " .. arg .. " 30 " .. " ����������� � ������� �������. ")
		end)
	end	
end

function cmd_svocakk(arg)
	if AdminLevel.v >= 7 then
		if #arg > 0 then
			sampSendChat("/banakk " .. arg .. " 999 " .. " ������� ����� �������/������� ")
			sampSendChat("/offstats " .. arg)
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /banakk " .. arg .. " 999 " .. " ������� ����� �������/�������")
		end)
	end	
end

function cmd_svocip(arg)
	if AdminLevel.v >= 12 then
		if #arg > 0 then
			sampSendChat("/banip " .. arg .. " 999 " .. " ������� ����� �������/������� ")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ IP ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /banip " .. arg .. " 999 " .. " ������� ����� �������/�������")
		end)
	end	
end

function cmd_rdsob(arg)
	if AdminLevel.v >= 7 then
		if #arg > 0 then
			sampSendChat("/banakk " .. arg .. " 30 " .. " ����� �������������/�������")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ NICK ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /banakk " .. arg .. " 30 " .. " ����� �������������/�������")
		end)
	end	
end	
function cmd_rdsip(arg)
	if AdminLevel.v >= 12 then
		if #arg > 0 then
			sampSendChat("/banip " .. arg .. " 30 " .. " ����� �������������/�������")
		else 
			sampAddChatMessage(tag .. "�� ������ ������ IP ����������! ", -1)
		end
	else 
		lua_thread.create(function()
		sampAddChatMessage(tag .. " ��� ������� ���! ��������� �����.")
		wait(1000)
		sampSendChat("/a /banip " .. arg .. " 30 " .. " ����� �������������/�������")
		end)
	end	
end	
-------- �������, ����������� � ����� � �������� -----------


------- �������, ����������� � ������� ������� -------
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

function cmd_h13(arg)
	sampSendChat("/ans " .. arg .. " ������ ������ ���������� ����� � /help -> 13 �����. | �������� ���� �� RDS. <3 ")
end

function cmd_zba(arg)
	sampSendChat("/ans " .. arg .. " ����� ������� �� ���? ������ ������ � ������ https://vk.com/dmdriftgta")
end

function cmd_zbp(arg)
	sampSendChat("/ans " .. arg .. " ������ ������ �� ������ � ������ https://vk.com/dmdriftgta")
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
	sampSendChat("/ans " .. arg .. " �������� ��� ������/������. | �������� ���� �� RDS <3")
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
	sampSendChat("/ans " .. arg .. " ������������! ��������� ������ � ID! ��������� �����. ")
	sampSendChat("/ans " .. arg .. " ��������� ������������������� �� Russian Drift Server! ")
end

function cmd_al(arg)
	sampSendChat("/ans " .. arg .. " ������������! �� ������ ������ /alogin! ")
	sampSendChat("/ans " .. arg .. " ������� ������� /alogin � ���� ������, ����������.")
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
	sampSendChat("/ans" .. arg .. " ������� ����������, ��� ������ ����� �� /trade. ����� �������, /sell ����� ����� ")
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
	sampSendChat("/ans " .. arg .. " ������� �����, ��� �� /help -> 17 �����. | �������� ���� �� RDS. <3")
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
------- �������, ����������� � ������� ������� -------


------ �������, ������������ � ��������������� ������� -------

function cmd_u(arg)
	sampSendChat("/unmute " .. arg)
end  

function cmd_uu(arg)
	sampSendChat("/unmute " .. arg)
	sampSendChat("/ans " .. arg .. " ���������� �� ������, ��������� �����. �������� ����")
end

function cmd_uj(arg)
	sampSendChat("/unjail ")
	sampSendChat("/ans " .. arg .. " ���������� �� ������, ��������� �����. �������� ����")
end

function cmd_stw(arg)
	sampSendChat("/setweap " .. arg .. " 38 5000 ")
end  

function cmd_as(arg)
	sampSendChat("/aspawn " .. arg)
end

function cmd_ru(arg)
	sampSendChat("/rmute " .. arg .. " 5 " .. "  Mistake/������")
	sampSendChat("/ans " .. arg .. " ���������� �� ������, ��������� �����. �������� ����.")
end

------ �������, ������������ � ��������������� ������� -------


----------------- ������ ���������� �� ����� ����������� -------------------------
	function cmd_notify(arg)
		notify.addNotify("{87CEEB}[AdminTool]", '������ \n ��� �������', 2, 1, 6)
	end 
----------------- ������ ���������� �� ����� ����������� -------------------------


------------------- ������ ���������� �� ������/������ ChatLogger ------------------------
function readChatlog()
	local file_check = assert(io.open(getWorkingDirectory() .. "\\config\\AdminTool\\chatlog\\" .. os.date("!*t").day .. "-" .. os.date("!*t").month .. "-" .. os.date("!*t").year .. ".txt", "r"))
	local t = file_check:read("*all")
	sampAddChatMessage(tag .. " ������ �����. ", -1)
	file_check:close()
	t = t:gsub("{......}", "")
	local final_text = {}
	final_text = string.split(t, "\n")
	sampAddChatMessage(tag .. " ���� ��������. ", -1)
		return final_text
end

function loadChatLog()
	wait(6000)
	accept_load_clog = true
end

function  getFileName()
    if not doesFileExist(getWorkingDirectory() .. "\\config\\AdminTool\\chatlog\\" .. os.date("!*t").day .. "-" .. os.date("!*t").month .. "-" .. os.date("!*t").year .. ".txt") then
        f = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\chatlog\\" .. os.date("!*t").day .. "-" .. os.date("!*t").month .. "-" .. os.date("!*t").year .. ".txt","w")
        f:close()
        file = string.format(getWorkingDirectory() .. "\\config\\AdminTool\\chatlog\\" .. os.date("!*t").day .. "-" .. os.date("!*t").month .. "-" .. os.date("!*t").year .. ".txt")
        return file
    else
        file = string.format(getWorkingDirectory() .. "\\config\\AdminTool\\chatlog\\" .. os.date("!*t").day .. "-" .. os.date("!*t").month .. "-" .. os.date("!*t").year .. ".txt")
        return file  
    end
end
------------------- ������ ���������� �� ������/������ ChatLogger ------------------------


----------------- �������, ���������� �� ���������������� ��� ----------------------------------
function sampev.onServerMessage(color, text)
	chatlog = io.open(getFileName(), "r+")
    chatlog:seek("end", 0);
	chatTime = "[" .. os.date("*t").hour .. ":" .. os.date("*t").min .. ":" .. os.date("*t").sec .. "] "
    chatlog:write(chatTime .. text .. "\n")
    chatlog:flush()
	chatlog:close()
	lc_lvl, lc_adm, lc_color, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] %((.+){(.+)}%) (.+)%[(%d+)%]: {FFFFFF}(.+)")

	

	local check_string = string.match(text, "[^%s]+")
	local check_string_2 = string.match(text, "[^%s]+")
	local _, check_mat_id, _, check_mat = string.match(text, "(.+)%((.+)%): {(.+)}(.+)")
	local reasons = {"/mute","/jail","/iban","/ban","/mpwin","/kick","/muteakk","/prisonakk","/banakk","/aspawn","/banip","/rmute","/unban","/unbanip","/unmute","/unjail"}
	if lc_text ~= nil then
   		for k, v in ipairs(reasons) do
			if lc_text:match(v) ~= nil then
				ATadm_forms = lc_text .. " | " .. lc_nick
				notify.addNotify("{87CEEB}[AdminTool]", '���������� �����-�����\n��� ��������: /faccept ', 2, 1, 6)
				sampAddChatMessage(tag .. "���������������� �����: ".. ATadm_forms)
				sampAddChatMessage(tag .. "��� �������� ����� �������� /faccept")
				start_forms()
			break
			end
		end
    end	

	function start_forms()
			sampRegisterChatCommand('faccept', function()
				lua_thread.create(function()
				sampSendChat("/a [AT] ����� ������� AdminTool`��.")
				wait(900)
				sampSendChat("".. ATadm_forms)
				end)
			end)
	end


	if text:sub(1, 13) == '<AC-WARNING> ' then -- ����������, ����� ���������� ������ ��������
		ac_string = text
	  end


	if setting_items.auto_mute_mat.v then
		if check_mat ~= nil and check_mat_id ~= nil and not isGamePaused() and not isPauseMenuActive() then
			local string_os = string.split(check_mat, " ")
			for i, value in ipairs(onscene) do
				for j, val in ipairs(string_os) do
					val = val:match("(%P+)")
					if val ~= nil then
						if value == string.rlower(val) then
							sampAddChatMessage("{87CEEB}[AutoMute] {FFFF00}" .. text)
							if not isGamePaused() and not isPauseMenuActive() then
								sampSendChat("/mute " .. check_mat_id .. " 300 " .. " ����������� �������.")
								notify.addNotify("{87CEEB}[AdminTool]", '���������� ����������� �������!\n������ ����� ���.\n����������� �����: {FFFFFF}' .. value .. '\n{FFFFFF}��� ����������: {FFFFFF}' .. sampGetPlayerNickname(tonumber(check_mat_id)), 2, 1, 6)
							end
							break
							break
						end
					end
				end
			end
			return true
		end
	end
	
	if setting_items.Admin_chat.v and check_string ~= nil and string.find(check_string, "%[A%-(%d+)%]") ~= nil and string.find(text, "%[A%-(%d+)%] (.+) ����������") == nil then
		local lc_text_chat
		if admin_chat_lines.nick.v == 1 then
			if lc_adm == nil then
				lc_lvl, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)")
				lc_text_chat = lc_lvl .. " � " .. lc_nick .. "[" .. lc_id .. "] : {FFFFFF}" .. lc_text
			else
				admin_chat_lines.color = color
				lc_text_chat = lc_adm .. "{" .. (bit.tohex(join_argb(explode_samp_rgba(color)))):sub(3, 8) .. "} � " .. lc_lvl .. " � " .. lc_nick .. "[" .. lc_id .. "] : {FFFFFF}" .. lc_text 
			end
		else
			if lc_adm == nil then
				lc_lvl, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)")
				lc_text_chat = "{FFFFFF}" .. lc_text .. " {" .. (bit.tohex(join_argb(explode_samp_rgba(color)))):sub(3, 8) .. "}: " .. lc_nick .. "[" .. lc_id .. "] � " .. lc_lvl
			else
				lc_text_chat = "{FFFFFF}" .. lc_text .. "{" .. (bit.tohex(join_argb(explode_samp_rgba(color)))):sub(3, 8) .. "} : " .. lc_nick .. "[" .. lc_id .. "] � " .. lc_lvl .. " � " .. lc_adm
				admin_chat_lines.color = color
			end
		end
		for i = admin_chat_lines.lines.v, 1, -1 do
			if i ~= 1 then
				ac_no_saved.chat_lines[i] = ac_no_saved.chat_lines[i-1]
			else
				ac_no_saved.chat_lines[i] = lc_text_chat
			end
		end
		return false
	elseif check_string == '(������/������)' and setting_items.Push_Report.v then
		notify.addNotify("{87CEEB}[AdminTool]", '�������� ����� ������.', 2, 1, 6)
		return true
	end
	if text == "�� ��������� ���� ��� ����������" and setting_items.ranremenu.v then
		sampSendChat("/remenu")
		return false
	end
	if text == "�� �������� ���� ��� ����������" then
		control_recon = true
		if recon_to_player then
			control_info_load = true
			accept_load = false
		end
		return false
	end
	if text == "�� ��������� ���� ��� ����������" and not setting_items.ranremenu.v then
		control_recon = false
		return false
	end
	if text == "����� �� � ����" and recon_to_player then
		recon_to_player = false
		notify.addNotify("{87CEEB}[AdminTool]", '����� �� � ����', 2, 1, 6)
		sampSendChat("/reoff")
	end
end
	function drawAdminChat()
		while true do
			if setting_items.Admin_chat.v then
				if admin_chat_lines.centered.v == 0 then
					for i = admin_chat_lines.lines.v, 1, -1 do
						if ac_no_saved.chat_lines[i] == nil then
							ac_no_saved.chat_lines[i] = " "
						end
						renderFontDrawText(font_ac, ac_no_saved.chat_lines[i], admin_chat_lines.X, admin_chat_lines.Y+((tonumber(font_size_ac.v) or 10)+5)*(admin_chat_lines.lines.v - i), join_argb(explode_samp_rgba(admin_chat_lines.color)))
					end
				elseif admin_chat_lines.centered.v == 1 then
				--x - renderGetFontDrawTextLength(font, text) / 2
					for i = admin_chat_lines.lines.v, 1, -1 do
						if ac_no_saved.chat_lines[i] == nil then
							ac_no_saved.chat_lines[i] = " "
						end
						renderFontDrawText(font_ac, ac_no_saved.chat_lines[i], admin_chat_lines.X - renderGetFontDrawTextLength(font_ac, ac_no_saved.chat_lines[i]) / 2, admin_chat_lines.Y+((tonumber(font_size_ac.v) or 10)+5)*(admin_chat_lines.lines.v - i), join_argb(explode_samp_rgba(admin_chat_lines.color)))
					end
				elseif admin_chat_lines.centered.v == 2 then
					for i = admin_chat_lines.lines.v, 1, -1 do
						if ac_no_saved.chat_lines[i] == nil then
							ac_no_saved.chat_lines[i] = " "
						end
						renderFontDrawText(font_ac, ac_no_saved.chat_lines[i], admin_chat_lines.X - renderGetFontDrawTextLength(font_ac, ac_no_saved.chat_lines[i]), admin_chat_lines.Y+((tonumber(font_size_ac.v) or 10)+5)*(admin_chat_lines.lines.v - i), join_argb(explode_samp_rgba(admin_chat_lines.color)))
					end
				end
			end
			wait(1)
		end
	end
----------------- �������, ���������� �� ���������������� ��� ----------------------------------



------------------ �������, ���������� �� ������� �������� --------------------------------

function sampev.onSendChat(message)


	local id; trans_cmd = message:match("[^%s]+")
	if setting_items.translate_cmd.v then
		if trans_cmd:find("%.(.+)") ~= nil  then
			trans_cmd = message:match("%.(.+)")
			sampSendChat("/" .. RusToEng(trans_cmd))
		end
	end

end

function RusToEng(text)
    result = text == '' and nil or ''
    if result then
        for i = 0, #text do
            letter = string.sub(text, i, i)
            if letter then
                result = (letter:find('[�-�/{/}/</>]') and string.upper(translate[string.rlower(letter)]) or letter:find('[�-�/,]') and translate[letter] or letter)..result
            end
        end
    end
    return result and result:reverse() or result
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
        elseif ch == 168 then -- �
            output = output .. russian_characters[184]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end

function string.rupper(s)
    s = s:upper()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:upper()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 224 and ch <= 255 then -- lower russian characters
            output = output .. russian_characters[ch - 32]
        elseif ch == 184 then -- �
            output = output .. russian_characters[168]
        else
            output = output .. string.char(ch)
        end
    end
    return output
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
------------------ �������, ���������� �� ������� �������� --------------------------------


------ �������, ���������� �� RGB-color ----------
	function join_argb(a, r, g, b)
		local argb = b  -- b
		argb = bit.bor(argb, bit.lshift(g, 8))  -- g
		argb = bit.bor(argb, bit.lshift(r, 16)) -- r
		argb = bit.bor(argb, bit.lshift(a, 24)) -- a
		return argb
	end
	  function explode_argb(argb)
		local a = bit.band(bit.rshift(argb, 24), 0xFF)
		local r = bit.band(bit.rshift(argb, 16), 0xFF)
		local g = bit.band(bit.rshift(argb, 8), 0xFF)
		local b = bit.band(argb, 0xFF)
		return a, r, g, b
	end
	  function explode_samp_rgba(rgba)
		local b = bit.band(bit.rshift(rgba, 24), 0xFF)
		local r = bit.band(bit.rshift(rgba, 16), 0xFF)
		local g = bit.band(bit.rshift(rgba, 8), 0xFF)
		local a = bit.band(rgba, 0xFF)
		return a, r, g, b
	end
------ �������, ���������� �� RGB-color ----------


-------------- �������, ���������� �� WH ----------------

function cmd_wh()
	if control_wallhack then
		sampAddChatMessage(tag .."WallHack ��� ��������.")
		nameTagOff()
		control_wallhack = false
	else
		sampAddChatMessage(tag .."WallHack ��� �������.")
		nameTagOn()
		control_wallhack = true
	end
end


function convert3Dto2D(x, y, z)
	local result, wposX, wposY, wposZ, w, h = convert3DCoordsToScreenEx(x, y, z, true, true)
	local fullX = readMemory(0xC17044, 4, false)
	local fullY = readMemory(0xC17048, 4, false)
	wposX = wposX * (640.0 / fullX)
	wposY = wposY * (448.0 / fullY)
	return result, wposX, wposY
end

function getBodyPartCoordinates(id, handle)
	local pedptr = getCharPointer(handle)
	local vec = ffi.new("float[3]")
	getBonePosition(ffi.cast("void*", pedptr), vec, id, true)
	return vec[0], vec[1], vec[2]
  end

function drawWallhack()
	local peds = getAllChars()
	local _, pid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	while true do
		wait(10)
		for i = 0, sampGetMaxPlayerId() do
			if sampIsPlayerConnected(i) and control_wallhack then
				local result, cped = sampGetCharHandleBySampPlayerId(i)
				local color = sampGetPlayerColor(i)
				local aa, rr, gg, bb = explode_argb(color)
				local color = join_argb(255, rr, gg, bb)
				if result then
					if doesCharExist(cped) and isCharOnScreen(cped) then
						local t = {3, 4, 5, 51, 52, 41, 42, 31, 32, 33, 21, 22, 23, 2}
						for v = 1, #t do
							pos1X, pos1Y, pos1Z = getBodyPartCoordinates(t[v], cped)
							pos2X, pos2Y, pos2Z = getBodyPartCoordinates(t[v] + 1, cped)
							pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
							pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
							renderDrawLine(pos1, pos2, pos3, pos4, 1, color)
						end
						for v = 4, 5 do
							pos2X, pos2Y, pos2Z = getBodyPartCoordinates(v * 10 + 1, cped)
							pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
							renderDrawLine(pos1, pos2, pos3, pos4, 1, color)
						end
						local t = {53, 43, 24, 34, 6}
						for v = 1, #t do
							posX, posY, posZ = getBodyPartCoordinates(t[v], cped)
							pos1, pos2 = convert3DCoordsToScreen(posX, posY, posZ)
						end
					end
				end
			end
		end
	end
end

function nameTagOn()
	local pStSet = sampGetServerSettingsPtr();
	NTdist = mem.getfloat(pStSet + 39)
	NTwalls = mem.getint8(pStSet + 47)
	NTshow = mem.getint8(pStSet + 56)
	mem.setfloat(pStSet + 39, 1488.0)
	mem.setint8(pStSet + 47, 0)
	mem.setint8(pStSet + 56, 1)
	nameTag = true
end
function nameTagOff()
	local pStSet = sampGetServerSettingsPtr();
	mem.setfloat(pStSet + 39, NTdist)
	mem.setint8(pStSet + 47, NTwalls)
	mem.setint8(pStSet + 56, NTshow)
	nameTag = false
end

-------------- �������, ���������� �� WH ----------------


------------- �������, ���������� �� RE_MENU ---------------
function sampev.onTextDrawSetString(id, text)
	if id == 2078 and setting_items.ranremenu.v then
		player_info = textSplit(text, "~n~")
	end
end

--function show()
--	toggle = not toggle
--end

function sampev.onShowTextDraw(id, data)
	if (id >= 3 and id <= 54 or id == 228 or id == 2078 or id == 266 or id == 2050 or id == 21) and setting_items.ranremenu.v then
		return false
	end
end
function loadPlayerInfo()
	wait(3000)
	accept_load = true
end
------------- �������, ���������� �� RE_MENU ---------------


-------------- �������, ���������� �� �������� ID ------------------
function playersToStreamZone()
	local peds = getAllChars()
	local streaming_player = {}
	local _, pid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	for key, v in pairs(peds) do
		local result, id = sampGetPlayerIdByCharHandle(v)
		if result and id ~= pid and id ~= tonumber(control_recon_playerid) then
			streaming_player[key] = id
		end
	end
	return streaming_player
end

function sampev.onSendCommand(command)
	local id = string.match(command, "/re (%d+)")
	if id ~= nil and not check_cmd_re and setting_items.ranremenu.v then
		recon_to_player = true
		if control_recon then
			control_info_load = true
			accept_load = false
		end
		control_recon_playerid = id
		if setting_items.ranremenu.v then
			check_cmd_re = true
			sampSendChat("/re " .. id)
			check_cmd:run()
			sampSendChat("/remenu")
		end
	end
	if command == "/reoff" then
		recon_to_player = false
		check_mouse = false
		control_recon_playerid = -1
	end
end

function textSplit(str, delim, plain)
    local tokens, pos, plain = {}, 1, not (plain == false) --[[ delimiter is plain text by default ]]
    repeat
        local npos, epos = string.find(str, delim, pos, plain)
        table.insert(tokens, string.sub(str, pos, npos and npos - 1))
        pos = epos and epos + 1
    until not pos
    return tokens
end
-------------- �������, ���������� �� �������� ID ------------------


------------- �������, ���������� �� ��������/������� ������ -----------------
function getDownKeys()
    local curkeys = ""
    local bool = false
    for k, v in pairs(vkeys) do
        if isKeyDown(v) and (v == VK_MENU or v == VK_CONTROL or v == VK_SHIFT or v == VK_LMENU or v == VK_RMENU or v == VK_RCONTROL or v == VK_LCONTROL or v == VK_LSHIFT or v == VK_RSHIFT) then
            if v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT then
                curkeys = v
            end
        end
    end
    for k, v in pairs(vkeys) do
        if isKeyDown(v) and (v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT and v ~= VK_LMENU and v ~= VK_RMENU and v ~= VK_RCONTROL and v ~= VK_LCONTROL and v ~= VK_LSHIFT and v ~= VK_RSHIFT) then
            if tostring(curkeys):len() == 0 then
                curkeys = v
            else
                curkeys = curkeys .. " " .. v
            end
            bool = true
        end
    end
    return curkeys, bool
end

function getDownKeysText()
	tKeys = string.split(getDownKeys(), " ")
	if #tKeys ~= 0 then
		for i = 1, #tKeys do
			if i == 1 then
				str = vkeys.id_to_name(tonumber(tKeys[i]))
			else
				str = str .. "+" .. vkeys.id_to_name(tonumber(tKeys[i]))
			end
		end
		return str
	else
		return "None"
	end
end

function strToIdKeys(str)
	tKeys = string.split(str, "+")
	if #tKeys ~= 0 then
		for i = 1, #tKeys do
			if i == 1 then
				str = vkeys.name_to_id(tKeys[i], false)
			else
				str = str .. " " .. vkeys.name_to_id(tKeys[i], false)
			end
		end
		return tostring(str)
	else
		return "(("
	end
end

function isKeysDown(keylist, pressed)
    local tKeys = string.split(keylist, " ")
    if pressed == nil then
        pressed = false
    end
    if tKeys[1] == nil then
        return false
    end
    local bool = false
    local key = #tKeys < 2 and tonumber(tKeys[1]) or tonumber(tKeys[2])
    local modified = tonumber(tKeys[1])
    if #tKeys < 2 then
        if not isKeyDown(VK_RMENU) and not isKeyDown(VK_LMENU) and not isKeyDown(VK_LSHIFT) and not isKeyDown(VK_RSHIFT) and not isKeyDown(VK_LCONTROL) and not isKeyDown(VK_RCONTROL) then
            if wasKeyPressed(key) and not pressed then
                bool = true
            elseif isKeyDown(key) and pressed then
                bool = true
            end
        end
    else
        if isKeyDown(modified) and not wasKeyReleased(modified) then
            if wasKeyPressed(key) and not pressed then
                bool = true
            elseif isKeyDown(key) and pressed then
                bool = true
            end
        end
    end
    if nextLockKey == keylist then
        if pressed and not wasKeyReleased(key) then
            bool = false
        else
            bool = false
            nextLockKey = ""
        end
    end
    return bool
end
------------- �������, ���������� �� ��������/������� ������ -----------------

function imgui.TextQuestion(label, description)
    imgui.TextDisabled(label)

    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
            imgui.PushTextWrapPos(600)
                imgui.TextUnformatted(description)
            imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function imgui.OnDrawFrame()
	
	if not one_window_state.v and 
	not two_window_state.v and 
	not three_window_state.v and 
	not four_window_state.v and 
	not five_window_state.v and 
	not six_window_state.v and 
	not seven_window_state.v and
	not ATChat.v and 
	not settings_keys.v and
	not ATre_menu.v and
	not ATChatLogger.v then
		imgui.Process = false
	end

	if one_window_state.v then

		imgui.SetNextWindowSize(imgui.ImVec2(655, 400), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw1 / 2), sh1 / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

		imgui.ShowCursor = true

		imgui.Begin(u8"������ � ���������, � �����", one_window_state)
		imgui.Text(u8"��� ������ ���������, ����� �������� �������, ������� ������ � ID ����������")
		imgui.Text(u8"��� ��������� ������� �������, /h7 � �.�., ����� ������� ID: /h13 ID, � �������� ��������..")
		imgui.Text(u8".. �� ���������� � ���������� �� /ans, ������� � ������� $, ����� �������� ��� ����� � ���� /ans")
		imgui.Text(" ")
		imgui.Separator()
			imgui.Text(u8"���� ����� ��������� ���������� ���������.")
			psX, psY, psZ = getCharCoordinates(PLAYER_PED)
			imgui.Text(u8"������� �� X:" .. psX .. u8" | ������� �� Y:" .. psY .. u8" | ������� �� Z: " .. psZ)
		imgui.Separator()
		if imgui.CollapsingHeader(u8"�������������� �������") then
			imgui.Text(u8"������� ��� �����������: /toolmp | ������ �� ��������: /tool (�����������)")
			imgui.Text(u8"������ �� ������: /toolfd | ������ �� /ans: /toolans")
			imgui.Text(u8"������� �� NumPad0 ��������� /ans � ������ ������.")
			imgui.Text(u8"/u id - ��������� ������; /uu id - ��������� � ��������� ��������")
			imgui.Text(u8"/ru id - ������ �������, /uj id - ����������� ������")
			imgui.Text(u8"/stw id - ������ ������� ����-��; /as id - ���������� ������")
			imgui.Text(u8"/wh - ���������/���������� ��")
			imgui.Text(u8"/delch - ���������� ������� ����; /cfind - ���-������")
			imgui.Text(u8"/tpad - �������� �� ���-������")
		end
		imgui.Separator()
				imgui.BeginChild("##Punish.", imgui.ImVec2(350, 200), true)
					if imgui.Selectable(u8"��������� � �������", beginchild == 1) then beginchild = 1 end
					if imgui.Selectable(u8"��������� � ��������", beginchild == 2) then beginchild = 2 end
					imgui.Separator()
					if imgui.CollapsingHeader(u8"��� � ������") then
						imgui.Text(u8"����� �������")
						imgui.Combo(u8"�������", combo_select, ban_str, #ban_str)
						imgui.Separator()
						imgui.Text(u8"�������� ID")
						imgui.InputText(u8"ID", ban_id)
						if imgui.Button(u8"Ban") then  
							sampSendChat("/iban " .. u8:decode(ban_id.v) .. "" .. u8:decode(ban_str[combo_select.v +1]))
						end 
						imgui.SameLine()
						imgui.TextQuestion("(?)", u8"��� � �������")
						imgui.Separator()	
						imgui.Text(u8"�������� ���")
						imgui.InputText(u8"Nick", ban_nick)
						if imgui.Button(u8"Ban#2") then  
							sampSendChat("/banakk " .. u8:decode(ban_nick.v) .. "" .. u8:decode(ban_str[combo_select.v +1]))
						end	
						imgui.SameLine()
						imgui.TextQuestion("(?)", u8"��� � ��������")
					end	

					if beginchild == 1 then  
						imgui.BeginChild("##PunishInOnline", imgui.ImVec2(325, 200), true)
							if imgui.CollapsingHeader(u8"Ban") then  
								imgui.Text(u8"/pl - ��� �� ������� ���� ������ \n/ch - ��� �� ����")
								imgui.Text(u8"/nk - ��� �� ��� � �����/���������")
								imgui.Text(u8"/gcnk - ��� �� �������� ����� � �����/���������")
								imgui.Text(u8"/okpr/ip - ��� ������� \n(���������� ������ ���/ip)") 
								imgui.Text(u8"/svocakk/ip - ��� �� ���/�� �� �������")
								imgui.Text(u8"/hl - ��� �� ��� � �������")
								imgui.Text(u8"/ob - ��� �� ����� ����")
								imgui.Text(u8"/menk  - ��� �� ������.����� � ����")
							end
							imgui.Separator()
							if imgui.CollapsingHeader(u8"Jail") then  
								imgui.Text(u8"/sk - jail �� SK in zz")
								imgui.Text(u8"/dz - jail �� DM/DB in zz")
								imgui.Text(u8"/dz1 - /dz3 - jail DM/DB in zz (x2-x4)")
								imgui.Text(u8"/td - jail �� DB/car in /trade")
								imgui.Text(u8"/fsh - /jail �� SH and FC")
								imgui.Text(u8"/jm - jail �� ��������� ������ �����������.")
								imgui.Text(u8"/bag - jail �� ������")
								imgui.Text(u8"/pk - jail �� �����/������ ���")
								imgui.Text(u8"/zv - jail �� �����.���")
								imgui.Text(u8"/skw - jail �� SK �� /gw")
								imgui.Text(u8"/ngw - jail �� ������������� ������.������ �� /gw")
								imgui.Text(u8"/dbgw - jail �� DB ���� �� /gw | /jch - jail �� ����")
								imgui.Text(u8"/pmx - jail �� ��������� ������ �������")
								imgui.Text(u8"/dgw - jail �� ��������� �� /gw")
								imgui.Text(u8"/sch - jail �� ����������� �������")
							end
							imgui.Separator()
							if imgui.CollapsingHeader(u8"Kick") then  
								imgui.Text(u8"/dj - ��� �� dm in jail")
								imgui.Text(u8"/gnk1 -- /gnk3 - ��� �� ��������� � ����.")
								imgui.Text(u8"/cafk - ��� �� ��� �� �����")
							end  
							imgui.Separator()
							if imgui.CollapsingHeader(u8"Mute") then  
								imgui.Text(u8"/m - ��� �� ��� | /rm - ��� �� ��� � ������ ")
								imgui.Text(u8"/ok - ��� �� ��� ")
								imgui.Text(u8"/fd1 - /fd5 - ��� �� ����/���� x1-x5")
								imgui.Text(u8"/po1 - /po5 - ��� �� ���������� x1-x5")
								imgui.Text(u8"/oa - ��� �� ��� ��� ")
								imgui.Text(u8"/roa - ��� �� ��� ��� � ������")
								imgui.Text(u8"/up - ��� �� ����.������")
								imgui.Text(u8"/rup - ��� �� �.� � ������")
								imgui.Text(u8"/ia - ��� �� ������ ���� �� ���")
								imgui.Text(u8"/kl - ��� �� ������� �� ���")
								imgui.Text(u8"/nm(900), /nm1(2500), /nm2(5000) - ��� �� ���������. ")
								imgui.Text(u8"/rnm(900), /rnm1(2500), /rnm2(5000) - ��� �� ��������� � ���.")
								imgui.Text(u8"/or - ��� �� ��� ���")
								imgui.Text(u8"/ror - ��� �� ��� ��� � ������")
								imgui.Text(u8"/cp - ����/������ � ������")
								imgui.Text(u8"/rpo - ���������� � ������")
								imgui.Text(u8"/rkl - ������� �� ��� � ������")
							end
						imgui.EndChild()
					end
					if beginchild == 2 then  
						imgui.BeginChild("##PunishInOffline", imgui.ImVec2(325,200), true)
							if imgui.CollapsingHeader(u8"Ban") then  
								imgui.Text(u8"/apl - ��� �� ������� ��� ������")
								imgui.Text(u8"/ach (/achi) - ��� �� ���� (ip)")
								imgui.Text(u8"/ank - ��� �� ��� � ���/����")
								imgui.Text(u8"/agcnk - ��� �� �������� ����� � ���/����")
								imgui.Text(u8"/agcnkip - ��� �� IP �� �������� ����� � ���/����")
								imgui.Text(u8"/okpr/ip - ��� �������")
								imgui.Text(u8"/svoakk/ip - ��� �� ���/IP �� �������")
								imgui.Text(u8"/ahl (/achi) - ��� �� ��� � ������� (ip)")
								imgui.Text(u8"/aob - ��� �� ����� ����")
								imgui.Text(u8"/rdsob - ��� �� ����� ���/�������")
								imgui.Text(u8"/rdsip - ��� �� IP �� ����� ���/�������")
								imgui.Text(u8"/amenk - ��� �� ������.����� � ����")
							end
							imgui.Separator()
							if imgui.CollapsingHeader(u8"Jail") then  
								imgui.Text(u8"/ask - jail �� SK in zz")
								imgui.Text(u8"/adz - jail �� DM/DB in zz")
								imgui.Text(u8"/adz1 - /adz3 - jail DM/DB in zz (x2-x4)")
								imgui.Text(u8"/atd - jail �� DB/CAR in trade")
								imgui.Text(u8"/afsh - jail �� SH ans FC")
								imgui.Text(u8"/ajm - jail �� �����.������ ��")
								imgui.Text(u8"/abag - jail �� ������")
								imgui.Text(u8"/apk - jail �� �����/������ ���")
								imgui.Text(u8"/azv - jail �� �����.���")
								imgui.Text(u8"/askw - jail �� SK �� /gw")
								imgui.Text(u8"/angw - ���.������.������ �� /gw")
								imgui.Text(u8"/adbgw - jail �� DB ���� �� /gw")
								imgui.Text(u8"/ajch - jail �� ����")
								imgui.Text(u8"/apmx - jail �� ������.������")
								imgui.Text(u8"/adgw - jail �� ��������� �� /gw")
								imgui.Text(u8"/asch - jail �� ����������� �������")
							end
							imgui.Separator()
							if imgui.CollapsingHeader(u8"Mute") then  
								imgui.Text(u8"/am - ��� �� ��� ")
								imgui.Text(u8"/aok - ��� �� ��� ")
								imgui.Text(u8"/afd - ��� �� ����/����")
								imgui.Text(u8"/apo  - ��� �� ����������")
								imgui.Text(u8"/aoa - ��� �� ���.���")
								imgui.Text(u8"/aup - ��� �� ���������� ��������")
								imgui.Text(u8"/anm(900) /anm1(2500) /anm2(5000) - ��� �� ����������")
								imgui.Text(u8"/aor - ��� �� ���/���� ������")
								imgui.Text(u8"/aia - ��� �� ������ ���� �� ���")
								imgui.Text(u8"/akl - ��� �� ������� �� ���")
							end
						imgui.EndChild()
					end
				imgui.EndChild()
			imgui.SameLine()
			imgui.BeginChild("##Interface", imgui.ImVec2(250, 200), true)
				if imgui.Button(u8'������ �� ������������ (���������)') then
					two_window_state.v = not two_window_state.v
					imgui.Process = two_window_state.v
				end
				if imgui.Button(u8'������ �� ������ (���������)') then
					three_window_state.v = not three_window_state.v
					imgui.Process = three_window_state.v
				end
				if imgui.Button(u8'������ �� /ans (���������)') then
					four_window_state.v = not four_window_state.v
					imgui.Process = four_window_state.v
				end
				if imgui.Button(u8'������ ������� ���������������') then 
					five_window_state.v = not five_window_state.v	
					imgui.Process = five_window_state.v
				end
				if imgui.Button(u8"���������") then  
					six_window_state.v = not six_window_state.v
					imgui.Process = six_window_state.v 
				end
				if imgui.Button(u8"������ �� ID Guns") then  
					seven_window_state.v = not seven_window_state.v
					imgui.Process = seven_window_state
				end
			imgui.EndChild()
		imgui.Separator()

		--���� one_window_state �������� �� ������ �� ��������
		--sampAddChatMessage(u8:decode(text_buffer_name.v), -1)


		imgui.End()
	end

	if two_window_state.v then

		set_custom_theme()

		imgui.SetNextWindowSize(imgui.ImVec2(550, 350), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw1 / 2), sh1 / 6), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

		imgui.ShowCursor = true

		imgui.Begin(u8"�������� �� ��", two_window_state)
		imgui.Text(u8"������ ������ ���������� ���������� ��������� � /mess �����.")
		imgui.Text(u8"�������� ����������, ���� ���� ���, ������ ��� ������� �� ���.")
		imgui.Text(u8"���� ������ ���� ������� ��������, ������ ������ � ������ ��.")
		imgui.Text(u8"��� �������� ��������� ������������ ������� /mp")
		imgui.Text(u8"/jm - jail �� ��������� ������ �����������.")
		imgui.Separator()

		imgui.BeginChild("##SelectWorkingMP", imgui.ImVec2(195, 225), true)
			if imgui.Selectable(u8"��������������� ������", beginchild == 50) then beginchild = 50 end
			if imgui.Selectable(u8"���� ��", beginchild == 51) then beginchild = 51 end
			if imgui.Selectable(u8"��������� ��", beginchild == 52) then beginchild = 52 end
			if imgui.Selectable(u8"�������� �����", beginchild == 53) then beginchild = 53 end
		imgui.EndChild()
		imgui.SameLine()

		if beginchild == 50 then   
			imgui.BeginChild("##CheckingMP", imgui.ImVec2(335, 225), true)
					imgui.Text(u8"������ �����:")
					imgui.InputText(u8'������� ID', text_buffer_prize)
					if imgui.Button(u8'�����') then 
						sampSendChat("/mess 10 � ��� ���� ���������� � �����������!")
						sampSendChat("/mess 10 � ��� ����� � ID: " .. u8:decode(text_buffer_prize.v))
						sampSendChat("/mpwin " .. text_buffer_prize.v)
						notify.addNotify("{87CEEB}[AdminTool]", "�� ������ ���� ������ � ID " .. u8:decode(text_buffer_prize.v) .. ", ���\n������ ��������", 2, 1, 6)
						sampSendChat("/spp")
					end
					imgui.Separator()
				if imgui.Button(u8'������ �������� ������ ����') then
					sampSendChat("/setweap " .. id .. " 38 " .. " 5000 ")
				end
				if imgui.Button(u8"������ � ������������") then  
					sampSendChat("/mess 10 ������� ������, �������� ��� ��� ������! /tpmp")
					sampSendChat("/mess 10 �������, �� ������ �����������!")
				end
			imgui.EndChild()
		end
		if beginchild == 51 then   
			imgui.BeginChild("##YouCreateMP?", imgui.ImVec2(335, 225), true)
				imgui.Text(u8"�������� ������ �����������:")
				imgui.InputText(u8'', text_buffer_mp)
				if imgui.Button(u8'�����') then 
					sampSendChat("/mess 10 ��������� ������! �������� �����������: " .. u8:decode(text_buffer_mp.v))
					sampSendChat("/mp")
					sampSendDialogResponse(5343, 1, 0)
					sampSendDialogResponse(5344, 1, 0, u8:decode(text_buffer_mp.v))
					sampSendChat("/mess 10 ����� ������� �� �����������, ������� /tpmp")
					notify.addNotify("{87CEEB}[AdminTool]", "����������� ������� �������\n������������ �������", 2, 1, 6)
				end
				imgui.Separator()
				if imgui.Button(u8'��������.�������') then  
					sampSendChat("/mess 6 �������: ������ ������������ /passive, /fly, /r - /s, ����, /flycar")
					sampSendChat("/mess 6 ������� �������� ��������������, �� ���������, ����..")
					sampSendChat("/mess 6 ..��� �� ������������� ������������. ��������!")
				end
			imgui.EndChild()
		end
		if beginchild == 52 then 
			imgui.BeginChild("##ZagotovkiMP", imgui.ImVec2(335, 225), true)
				if imgui.Button(u8'����������� "������"') then
					lua_thread.create(function()
						setCharCoordinates(PLAYER_PED,-2315,1545,18)
						wait(2500)
						sampSendChat("/mess 10 ��������� ������! �������� �����������: ������. �������� /tpmp")
						sampSendChat("/mp")
						sampSendDialogResponse(5343, 1, 0)
						sampSendDialogResponse(5344, 1, 0, "������")
						sampSendChat("/mess 10 �������� /tpmp, ������ ����� � ������� �������")
						notify.addNotify("{87CEEB}[AdminTool]", '����������� "������" ������� �������\n������������ �������', 2, 1, 6)
					end)
				end
				if imgui.Button(u8'������� �� "������"') then
					sampSendChat("/mess 6 �������: ������ ������������ /passive, /fly, /r - /s � ����. �� ���������.")
					sampSendChat("/mess 6 ������� �����, ������ � ��� ���� ������, ����� ����������")
				end
				imgui.Separator()
				if imgui.Button(u8'����������� "������ �����"') then
					lua_thread.create(function()
						setCharCoordinates(PLAYER_PED,1753,2072,1955)
						wait(2500)
						sampSendChat("/mess 10 ��������� ������! �������� �����������: ������ �����. �������� /tpmp")
						sampSendChat("/mp")
						sampSendDialogResponse(5343, 1, 0)
						sampSendDialogResponse(5344, 1, 0, "��")
						sampSendChat("/mess 10 �������� /tpmp, ������ ����� � ������� �������")
						notify.addNotify("{87CEEB}[AdminTool]", '����������� "������ �����" \n������� �������\n������������ �������', 2, 1, 6)
					end)
				end
				if imgui.Button(u8'������� �� "������ �����"') then
					sampSendChat("/mess 6 �������: ������ ������������ /passive, /fly, /r - /s � ����. �� ���������.")
					sampSendChat("/mess 6 � ���� �������� ����� �������, ����� ����� ������ �� ���� ������.")
				end
				imgui.Separator()
				if imgui.Button(u8'����������� "������� �������"') then
					lua_thread.create(function()
						setCharCoordinates(PLAYER_PED,1973,-978,1371)
						wait(2500)
						sampSendChat("/mess 10 ��������� ������! �������� �����������: ������� �������. �������� /tpmp")
						sampSendChat("/mp")
						sampSendDialogResponse(5343, 1, 0)
						sampSendDialogResponse(5344, 1, 0, "��")
						sampSendChat("/mess 10 �������� /tpmp, ������ ����� � ������� �������")
						notify.addNotify("{87CEEB}[AdminTool]", '����������� "������� �������" \n������� �������\n������������ �������', 2, 1, 6)
					end)
				end
				if imgui.Button(u8'������� �� "������� �������"') then
					sampSendChat("/mess 6 �������: ������ ������������ /passive, /fly, /r - /s � ����. �� ���������.")
					sampSendChat("/mess 6 � ���� ����������� � ������� ������� /try - ����. ������ - �����. �������� - ����.")
				end
				imgui.Separator()
				if imgui.Button(u8'����������� "���������"') then
					lua_thread.create(function()
						setCharCoordinates(PLAYER_PED,-2304,872,59)
						wait(2500)
						sampSendChat("/mess 10 ��������� ������! �������� �����������: ���������. ��������: /tpmp")
						sampSendChat("/mp")
						sampSendDialogResponse(5343, 1, 0)
						sampSendDialogResponse(5344, 1, 0, "���������")
						sampSendChat("/mess 10 �������� /tpmp, ������ ����� � ������� �������")
						notify.addNotify("{87CEEB}[AdminTool]", '����������� "���������" \n������� �������\n������������ �������', 2, 1, 6)
					end)
				end
				if imgui.Button(u8'������� �� "���������"') then
					sampSendChat("/mess 6 �������: ������ ������������ /passive, /fly, /r - /s � ����. �� ���������.")
					sampSendChat("/mess 6 � ���� ������������ Swat Tank, � ���� ������� ��� � ���������� �����.")
					sampSendChat("/mess 6 ���������, ��� �������� - ����������.")
				end
				imgui.Separator()
				if imgui.Button(u8'����������� "������ ������"') then
					lua_thread.create(function()
						setCharCoordinates(PLAYER_PED,2027,-2434,13)
						wait(2500)
						sampSendChat("/mess 10 ��������� ������! �������� �����������: ������ ������. ��������: /tpmp")
						sampSendChat("/mp")
						sampSendDialogResponse(5343, 1, 0)
						sampSendDialogResponse(5344, 1, 0, "������ ������")
						sampSendChat("/mess 10 �������� /tpmp, ������ ����� � ������� �������")
						notify.addNotify("{87CEEB}[AdminTool]", '����������� "������ ������" \n������� �������\n������������ �������', 2, 1, 6)
					end)
				end
				if imgui.Button(u8'������� �� "������ ������"') then
					sampSendChat("/mess 6 �������: ������ ������������ /passive, /fly, /r - /s � ����. �� ���������.")
					sampSendChat("/mess 6 � ���� ������������ ������� Shamal, � ���� ������ ������� �� ������")
					sampSendChat("/mess 6 ���� ����������� ������ �� ������, � � ���� ��������� �����.")
					sampSendChat("/mess 6 ���, ��� ��������� ��������� �� �������� - ����������")
				end
				imgui.Separator()
				if imgui.Button(u8'����������� "��������"') then
					sampSendChat("/mess 10 ��������� ������! �������� �����������: ���������! ��������� �� �����")
					sampSendChat("/mess 10 ������, � ������� ������� ����, � ��, ��� ��������� �������, ��� � /pm +")
					notify.addNotify("{87CEEB}[AdminTool]", '����������� "���������" \n��������\n�������� �������', 2, 1, 6)
				end
				if imgui.Button(u8'������� �� "���������"') then
					sampSendChat("/mess 6 � ����� ������ �� ����� ���������, � ��� ������.")
					sampSendChat("/mess 6 ������, ��� �������� - �������� ���� ����")
					sampSendChat("/mess 6 ����� ������ - 5. ���������� ���������� ��� � /pm ������ +")
				end
				imgui.Separator()
				if imgui.Button(u8'����������� "���� ��� ����') then  
					lua_thread.create(function()
						setCharCoordinates(PLAYER_PED,1547,-1359,329)
						wait(2500)
						sampSendChat("/mess 10 ��������� ������! �������� �����������: ���� ��� ����. ��������: /tpmp")
						sampSendChat("/mp")
						sampSendDialogResponse(5343, 1, 0)
						sampSendDialogResponse(5344, 1, 0, "�����")
						sampSendChat("/mess 10 �������� /tpmp, ������ ����� � ������� �������")
						notify.addNotify("{87CEEB}[AdminTool]", '����������� "���� ��� ����" \n������� �������\n������������ �������', 2, 1, 6)
					end)
				end
				if imgui.Button(u8'������� �� "���� ��� ����"') then  
					sampSendChat("/mess 6 �������: ������ ������������ /passive, /fly, /r - /s � ����. �� ���������.")
					sampSendChat("/mess 6 � ���� ������������ �������. ��� ������ - ������ ���")
					sampSendChat("/mess 6 ���� ������ - ����������� � �����, � ��������.")
					sampSendChat("/mess 6 ���, ��� ����� ��������� - ����������")
				end
				imgui.Separator()
				if imgui.Button(u8'����������� "�����������"') then  
					lua_thread.create(function()
						setCharCoordinates(PLAYER_PED,626,-1891,3)
						wait(2500)
						sampSendChat("/mess 10 ��������� ������! �������� �����������: �����������. ��������: /tpmp")
						sampSendChat("/mp")
						sampSendDialogResponse(5343, 1, 0)
						sampSendDialogResponse(5344, 1, 0, "��������������� ��")
						sampSendChat("/mess 10 �������� /tpmp, ������ ����� � ������� �������")
						notify.addNotify("{87CEEB}[AdminTool]", '����������� "�����������" \n������� �������\n������������ �������', 2, 1, 6)
					end)
				end
				if imgui.Button(u8'������� �� "�����������"') then  
					sampSendChat("/mess 6 �������: ������ ������������ /passive, /fly, /r - /s � ����. �� ���������.")
					sampSendChat("/mess 6 � ��� ������ ����� �������, ������� �������. � ������� 10 �����..")
					sampSendChat("/mess 6 ...�� �������� ����������! ���� ������ ����������� - ������� ������!")
				end
				imgui.Separator()
				if imgui.Button(u8'����������� "���� �����"') then  
					lua_thread.create(function()
						sampSendChat("/mess 10 ��������� ������! �������� �����������: ���� �����! ��������� �� �����")
						sampSendChat("/mess 10 ������, � ������� ������� ����, � ��, ��� ��������� �������, ��� � /pm +")
						notify.addNotify("{87CEEB}[AdminTool]", '����������� "���� �����" \n��������\n�������� �����', 2, 1, 6)
					end)
				end
				if imgui.Button(u8'������� �� "���� �����"') then
					sampSendChat("/mess 6 � ��������� �����, ������ ��� ��������� ��������")  
					sampSendChat("/mess 6 ���� ������ - ������� �����, ��������� �����")
					sampSendChat("/mess 6 ���, ��� �������� ����� - ����������")
					sampSendChat("/mess 6 ���� ����� = ���� ����. ���� ���� - 1�� ������.")
				end
				imgui.Text(u8"Swat Tank - 601 ID, Shamal - 519 ID.") 
				imgui.Text(u8"������� - 532 ID")
				imgui.Text(u8"����� ���������� ������,")
				imgui.Text(u8"������� /veh ID 1 1")
				imgui.Text(u8"������� ��� ���������,")
				imgui.Text(u8"�� ������ ����������� ����")
			imgui.EndChild()
		end
		if beginchild == 53 then 
			imgui.BeginChild("##WriteOnMP", imgui.ImVec2(340, 225), true)
				if imgui.CollapsingHeader(u8"������") then 
					imgui.Text(u8"������������� ���������� �����. \n�������������� �������.")
					imgui.Text(u8"���� �����������. \n������������� �������� ������")
					imgui.Text(u8"������������� ������ � ��������� � \n������� �������, ���� ������")
					imgui.Text(u8"���, ��� �������� ��������� - ���������")
				end 
				imgui.Separator()
				if imgui.CollapsingHeader(u8"������ �����") then
					imgui.Text(u8"���������� �����, �������������� ������� ����.")
					imgui.Text(u8"������ ��������������� ��������, ����� Desert Eagle.")
					imgui.Text(u8"������������� �������� ���� ������� ������ �����")
					imgui.Text(u8"���������� - ��������, \n���������� - ��������.")
					imgui.Text(u8"���������� � ��������� ������ �������� ����")
				end 
				imgui.Separator()
				if imgui.CollapsingHeader(u8"������� �������") then  
					imgui.Text(u8"�������� �����, �������������� �������")
					imgui.Text(u8"������������� ����� �������, � ���������� ������� �������")
					imgui.Text(u8'��� �������� � ������� ������� "/try ����"')
					imgui.Text(u8'���� "������" - ����� ��������. \n���� "��������" - ���')
					imgui.Text(u8'���, ��� �������� ��������� ���������')
				end 
				imgui.Separator()
				if imgui.CollapsingHeader(u8"������ ������") then  
					imgui.Text(u8"������� �������� �����, �������������� �������")
					imgui.Text(u8"������������� ������� ������� Shamal")
					imgui.Text(u8"������ ����������� �� ������ ��������")
					imgui.Text(u8"������������� �������� ����� � �����")
					imgui.Text(u8"���, ��� ��������� ��������� \n �� �������� ���������")
				end 
				imgui.Separator()
				if imgui.CollapsingHeader(u8"���������") then  
					imgui.Text(u8"������������� ��������� � ������ ���������")
					imgui.Text(u8"��� ��������, ������������ �� ��������")
					imgui.Text(u8"����� = 1 ����. ���, ��� ������ 5 ������ - ����������")
					imgui.Text(u8"����� �������� ����� �������. \n����, ���� ��� �� ��������� � ����� �������")
				end 
				imgui.Separator()
				if imgui.CollapsingHeader(u8"���������") then  
					imgui.Text(u8"�������� �����, ������������� ������������ �������")
					imgui.Text(u8"�� ������� Swat Tank, � �������� �������� �������")
					imgui.Text(u8"���������, ��� ������� �� ��������� - ����������")
				end 
				imgui.Separator()
				if imgui.CollapsingHeader(u8"���� ��� ����") then  
					imgui.Text(u8"�������� �����, �������������� �������")
					imgui.Text(u8"������������� ������� ������� �� ��������")
					imgui.Text(u8"���, ��� ������� ��������� - �������")
				end 
				imgui.Separator()
				if imgui.CollapsingHeader(u8"��������������� ��") then  
					imgui.Text(u8"�������� �����, �������������� �������� �������")
					imgui.Text(u8"�� ����� �� ����������� �������� ������� (/object)")
					imgui.Text(u8"������� ������, � ���������� ��������..\n � ������� 10 �����")
					imgui.Text(u8"������� �������! \n����� ����������� ������� �������")
				end 
				imgui.Separator()
				if imgui.CollapsingHeader(u8"���� �����") then  
					imgui.Text(u8"����������� � ������.. ���� �����, �� ����")
					imgui.Text(u8"�������������� �������, ������������ �����")
					imgui.Text(u8"������ �������� ����� � ��, �� ���..")
					imgui.Text(u8"�� �������� ��� ��������, � ��� �������� .. \n���� - ������")
					imgui.Text(u8"������, ��� ������� �������, ��� ������� �����������")
					imgui.Text(u8"���, ��� ������� ����� ����������.")
					imgui.Text(u8"��, ���������� �������� �����. ���� ����� = 1 ����")
					imgui.Text(u8"1 ���� - 1��.")
				end
			imgui.EndChild()
		end
		imgui.End()
	end
  	-- ���� two_window_state �������� �� ��������� �� ������������

 		if three_window_state.v then

			set_custom_theme()

			imgui.SetNextWindowSize(imgui.ImVec2(650, 350), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2((sw1 / 3), sh1 / 6), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

			imgui.ShowCursor = true

			imgui.Begin(u8"�������� �� ������", three_window_state)
			imgui.Text(u8"������ ������ �������� �� ���������� ������� �����. �������� ����� ������ 1-5 �����.")
			imgui.Text(u8"�������, ��� �������������, ������ ���� ���� ��� �� ������.")
			imgui.Text(u8"�����������: ������������ ������� /online ��� ������ ������ � ����� �� ������!")
			imgui.Text(u8"��, ���� ���������� �� /online, ������� NumPad3 � ���������� ������ �� ������")
			imgui.Text("  ")
			imgui.Separator()

			imgui.BeginChild("##SelectFlood", imgui.ImVec2(150, 220), true)

			if imgui.Selectable(u8"�����", beginchild == 100) then beginchild = 100 end
			if imgui.Selectable(u8"������ � /gw", beginchild == 101) then beginchild = 101 end
			if imgui.Selectable(u8"���������", beginchild == 102) then beginchild = 102 end

			imgui.EndChild()
			imgui.SameLine()


			if beginchild == 100 then  
				imgui.BeginChild("##Floods", imgui.ImVec2(480, 220), true)
					if imgui.Button(u8'���� ��� �������') then
						sampSendChat("/mess 7 ���������� �� Russian Drift Server!")
						sampSendChat("/mess 10 �� �������� ������? ��� ������� ���������?")
						sampSendChat("/mess 10 �������� /report, � ��� ID ������/����������")
						sampSendChat("/mess 10 �������������� ������� ��� � ����������� � ��������! :D")
						sampSendChat("/mess 7 �� ����������, ��� ������ :D. ������� ����! :3")
					end
					imgui.SameLine()
					if imgui.Button(u8'���� ��� VIP') then
						sampSendChat("/mess 7 ���������� �� Russian Drift Server!")
						sampSendChat("/mess 10 �� ����� ������ �������� �� ����� �����?")
						sampSendChat("/mess 10 � ��� ���� ������ 10.000 �����?")
						sampSendChat("/mess 10 ����� ������� /sellvip � �� �������� VIP!")
						sampSendChat("/mess 7 �� ����������, ��� ������ :D. ������� ����! :3")
					end
					imgui.SameLine()
					if imgui.Button(u8'���� ��� ������ �������/����') then
						sampSendChat("/mess 7 ���������� �� Russian Drift Server!")
						sampSendChat("/mess 10 ������ ��� ��� ������? ��� ����������� ����� ��������.")
						sampSendChat("/mess 10 ��� ����� ����������, �������� /tp, ����� ������ -> ����...")
						sampSendChat("/mess 10 ...����� ����� ������ � ����, ������� ���� �..")
						sampSendChat("/mess 10 ..� �������� �� ������ ���� ��� ������ �������. �� ���� ���.")
						sampSendChat("/mess 7 �� ����������, ��� ������ :D. ������� ����! :3")
					end
					if imgui.Button(u8'���� ��� /dt 0-990 (����� ����������)') then
						sampSendChat("/mess 7 ���������� �� Russian Drift Server!")
						sampSendChat("/mess 10 ������ �� �����������? ������ �� ����������� �������?")
						sampSendChat("/mess 10 ������� ��������� � �������� ��������? � ��� ���� ������.")
						sampSendChat("/mess 10 ������� ������� /dt 0-990 � ��������� �� ��������.")
						sampSendChat("/mess 10 �� �������� �������� ������� ���� ���. ������� ����. :3")
						sampSendChat("/mess 7 �� ����������, ��� ������ :D. ������� ����! :3")
					end
					imgui.SameLine()
					if imgui.Button(u8'���� ��� /arena') then
						sampSendChat("/mess 7 ���������� �� Russian Drift Server!")
						sampSendChat("/mess 10 ������� ������������?")
						sampSendChat("/mess 10 ����� /arena ��� /tp -> Deatchmatch-�����. �� �����.")
						sampSendChat("/mess 10 ������, ��� � ���� - ����. :3")
						sampSendChat("/mess 7 �� ����������, ��� ������ :D. ������� ����! :3")
					end
					if imgui.Button(u8'���� ��� VK group') then
						sampSendChat("/mess 7 ���������� �� Russian Drift Server!")
						sampSendChat("/mess 10 ������ ����������� � ���������?")
						sampSendChat("/mess 10 ��� ������ �������� �����������/��������� � �������?")
						sampSendChat("/mess 10 ������ � ���� ������ ���������: https://vk.com/dmdriftgta")
						sampSendChat("/mess 7 �� ����������, ��� ������ :D. ������� ����! :3")
					end
					imgui.SameLine()
					if imgui.Button(u8'���� ��� ���������') then
						sampSendChat("/mess 7 ���������� �� Russian Drift Server!")
						sampSendChat("/mess 10 ������ �������� �� ������ ����������, ����� �� ��� � ����?")
						sampSendChat("/mess 10 ����� ������� /tp -> ������ -> ����������")
						sampSendChat("/mess 10 ������� ������ ���������, ���� ������ �� RDS �����. � ������� :3")
						sampSendChat("/mess 7 �� ����������, ��� ������ :D. ������� ����! :3")
					end
					if imgui.Button(u8'���� ��� ���� RDS') then
						sampSendChat("/mess 7 ���������� �� Russian Drift Server!")
						sampSendChat("/mess 8 ����� ����� ���������� �� ������� ������ RDS?")
						sampSendChat("/mess 8 �� ��� ������ ������� � ��������!")
						sampSendChat("/mess 8 ������ ��� ����� ����: myrds.ru")
						sampSendChat("/mess 7 �� ����������, ��� ������ :D. ������� ����! :3")
					end
					imgui.SameLine()
					if imgui.Button(u8'���� ��� /gw') then
						sampSendChat("/mess 7 ���������� �� Russian Drift Server!")
						sampSendChat("/mess 10 ����� �������� �� ���� ������� ������� �����?")
						sampSendChat("/mess 10 ������ ��� � ������� /gw, ��� �� ���������� � ��������")
						sampSendChat("/mess 10 ����� ������ ������� �� ����������, ����� ������� /capture")
						sampSendChat("/mess 7 �� ����������, ��� ������ :D. ������� ����! :3")
					end
					imgui.SameLine()
					if imgui.Button(u8"���� ��� ������ ������ �� RDS") then
						sampSendChat("/mess 7 ���������� �� Russian Drift Server!")
						sampSendChat("/mess 10 ����� ������ ������� ���� ������, � �������� ������?")
						sampSendChat("/mess 10 ����������� ������� ���-������, �� � ���� ����� �� ����������?")
						sampSendChat("/mess 10 �� ������ �������� ��������� ������: https://vk.com/freerds")
						sampSendChat("/mess 7 �� ����������, ��� ������ :D. ������� ����! :3")
					end
					if imgui.Button(u8"���� ��� /gangwar") then 
						sampSendChat("/mess 7 ���������� �� Russian Drift Server!")
						sampSendChat("/mess 10 ������ ��������� � ������� �������? ��������� ����?")
						sampSendChat("/mess 10 �� ������ ���� ��� ���������! ������ �������� ������ �����")
						sampSendChat("/mess 10 ������� /gangwar, ��������� ���������� � ���������� �� ��.")
						sampSendChat("/mess 7 �� ����������, ��� ������ :D. ������� ����! :3")
					end 
					imgui.SameLine()
					if imgui.Button(u8"���� ��� ������") then
						sampSendChat("/mess 7 ���������� �� Russian Drift Server!")
						sampSendChat("/mess 10 �� ������� ����� �� ������? �� ������� �� �������?")
						sampSendChat("/mess 10 ���� ����� ������ � ���������, ��������� ������ ��� �������")
						sampSendChat("/mess 10 ������ ���� ������, �������� /tp -> ������ -> ������")
						sampSendChat("/mess 7 �� ����������, ��� ������ :D. ������� ����! :3")
					end
					imgui.SameLine()
					if imgui.Button(u8"���� � ����") then  
						sampSendChat("/mess 7 ���������� �� Russian Drift Server!")
						sampSendChat("/mess 10 ��������� ��� � ��� RDS. ������ �����, �� Drift Server")
						sampSendChat("/mess 10 ����� � ��� ���� ����������, ��� GangWar, DM")
						sampSendChat("/mess 10 ����������� ������ � ��� ��������� ������� � /help")
						sampSendChat("/mess 7 �� ����������, ��� ������ :D. ������� ����! :3")
					end
					imgui.SameLine()
					if imgui.Button(u8'���� ��� /trade') then
						sampSendChat("/mess 7 ���������� �� Russian Drift Server!")
						sampSendChat("/mess 10 ������ ������ ����������, � ����� ������ �� ������� � ���� �����/����/�����/�����?")
						sampSendChat("/mess 10 ������� /trade, ��������� � ������� �����, �������� � �������� � ������ �������.")
						sampSendChat("/mess 10 �����, ������ �� ����� ���� NPC �����, � ���� ����� ����� ���-�� �����.")
						sampSendChat("/mess 7 �� ����������, ��� ������ :D. ������� ����! :3")
					end
				imgui.EndChild()
			end

			if beginchild == 101 then  
				imgui.BeginChild("##GangWar", imgui.ImVec2(480, 220), true)
					if imgui.Button(u8"Aztecas vs Ballas") then  
						sampSendChat("/mess 7 ���� -  GangWar: /gw")
						sampSendChat("/mess 10 Varios Los Aztecas vs East Side Ballas ")
						sampSendChat("/mess 10 �������� ����� �������, �������� ����� /gw �� ������� �����")
						sampSendChat("/mess 7 ���� - GangWar: /gw")
					end
					imgui.SameLine()
					if imgui.Button(u8"Aztecas vs Groove") then  
						sampSendChat("/mess 7 ���� -  GangWar: /gw")
						sampSendChat("/mess 10 Varios Los Aztecas vs Groove Street ")
						sampSendChat("/mess 10 �������� ����� �������, �������� ����� /gw �� ������� �����")
						sampSendChat("/mess 7 ���� - GangWar: /gw")
					end
					imgui.SameLine()
					if imgui.Button(u8"Aztecas vs Vagos") then  
						sampSendChat("/mess 7 ���� -  GangWar: /gw")
						sampSendChat("/mess 10 Varios Los Aztecas vs Los Santos Vagos ")
						sampSendChat("/mess 10 �������� ����� �������, �������� ����� /gw �� ������� �����")
						sampSendChat("/mess 7 ���� - GangWar: /gw")
					end
					imgui.SameLine()
					if imgui.Button(u8"Aztecas vs Rifa") then  
						sampSendChat("/mess 7 ���� -  GangWar: /gw")
						sampSendChat("/mess 10 Varios Los Aztecas vs The Rifa ")
						sampSendChat("/mess 10 �������� ����� �������, �������� ����� /gw �� ������� �����")
						sampSendChat("/mess 7 ���� - GangWar: /gw")
					end
					if imgui.Button(u8"Ballas vs Groove") then  
						sampSendChat("/mess 7 ���� -  GangWar: /gw")
						sampSendChat("/mess 10 East Side Ballas vs Groove Street  ")
						sampSendChat("/mess 10 �������� ����� �������, �������� ����� /gw �� ������� �����")
						sampSendChat("/mess 7 ���� - GangWar: /gw")
					end
					imgui.SameLine()
					if imgui.Button(u8"Ballas vs Rifa") then  
						sampSendChat("/mess 7 ���� -  GangWar: /gw")
						sampSendChat("/mess 10 East Side Ballas vs The Rifa ")
						sampSendChat("/mess 10 �������� ����� �������, �������� ����� /gw �� ������� �����")
						sampSendChat("/mess 7 ���� - GangWar: /gw")
					end
					imgui.SameLine()
					if imgui.Button(u8"Groove vs Rifa") then  
						sampSendChat("/mess 7 ���� -  GangWar: /gw")
						sampSendChat("/mess 10 Groove Street  vs The Rifa ")
						sampSendChat("/mess 10 �������� ����� �������, �������� ����� /gw �� ������� �����")
						sampSendChat("/mess 7 ���� - GangWar: /gw")
					end
					imgui.SameLine()
					if imgui.Button(u8"Groove vs Vagos") then  
						sampSendChat("/mess 7 ���� -  GangWar: /gw")
						sampSendChat("/mess 10 Groove Street vs Los Santos Vagos ")
						sampSendChat("/mess 10 �������� ����� �������, �������� ����� /gw �� ������� �����")
						sampSendChat("/mess 7 ���� - GangWar: /gw")
					end
					imgui.SameLine()
					if imgui.Button(u8"Vagos vs Rifa") then  
						sampSendChat("/mess 7 ���� -  GangWar: /gw")
						sampSendChat("/mess 10 Los Santos Vagos vs The Rifa ")
						sampSendChat("/mess 10 �������� ����� �������, �������� ����� /gw �� ������� �����")
						sampSendChat("/mess 7 ���� - GangWar: /gw")
					end
					if imgui.Button(u8"Ballas vs Vagos") then  
						sampSendChat("/mess 7 ���� -  GangWar: /gw")
						sampSendChat("/mess 10 East Side Ballas vs Los Santos Vagos ")
						sampSendChat("/mess 10 �������� ����� �������, �������� ����� /gw �� ������� �����")
						sampSendChat("/mess 7 ���� - GangWar: /gw")
					end
				imgui.EndChild()
			end
			if beginchild == 102 then  
				imgui.BeginChild("##Other", imgui.ImVec2(480, 220), true)
					if imgui.Button(u8'����� ����� �� 15 ������') then
						sampSendChat("/mess 14 ��������� ������. ������ ����� ������� ����� ���������� ����������")
						sampSendChat("/mess 14 ������� ������������ �����, � ����������� ��������, ���� ������� :3")
						sampSendChat("/delcarall ")
						sampSendChat("/spawncars 15 ")
						notify.addNotify("{87CEEB}[AdminTool]", '�� ��������� ������� �����, \n��������', 2, 1, 6)
					end
					if imgui.Button(u8'����������� ������ � /mess') then
						sampAddChatMessage("{87CEEB}[AdminTool] {4169E1}0 - �����, 1 - ������, 2 - �������, 3 - ������-�������", main_color)
						sampAddChatMessage("{87CEEB}[AdminTool] {4169E1}4 - �������, 5 - �����, 6 - ������, 7 - ���������", main_color)
						sampAddChatMessage("{87CEEB}[AdminTool] {4169E1}8 - ����������, 9 - ���������, 10 - �������", main_color)
						sampAddChatMessage("{87CEEB}[AdminTool] {4169E1}11 - �����-�������, 12 - �������, 13 - �����, 14 - ������-������", main_color)
						sampAddChatMessage("{87CEEB}[AdminTool] {4169E1}15 - �������, 16 - ����������, 17 - �����-�������", main_color)
						sampAddChatMessage("{87CEEB}[AdminTool] {4169E1}������ ��������� �������� ���� ���...", main_color)
					end
				imgui.EndChild()
			end
			imgui.End()
		end
			-- ���� three_window_state �������� �� ��������� �� ������

			if four_window_state.v  then

				set_custom_theme()

				imgui.SetNextWindowSize(imgui.ImVec2(600, 350), imgui.Cond.FirstUseEver)
				imgui.SetNextWindowPos(imgui.ImVec2(sw1 / 4, (sh1 / 6)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

				imgui.ShowCursor = true

				imgui.Begin(u8'�������� �� �������� /ans', four_window_state)
				if imgui.CollapsingHeader(u8"����������") then
					imgui.Text(u8"��� ��������� ������� �������, /h7 � �.�., ����� ������� ID: /h13 ID, � �������� ��������")
					imgui.Text(u8"�� ���������� � ���������� �� /ans, ������� � ������� $, ����� �������� ��� ����� � ���� /ans")
					imgui.Text(u8"����� �������� �������, ���������� ������ ������!")
					imgui.Text(u8"������� �� NumPad0 ��������� /ans � ������ ������.")
					imgui.Text(u8"������� �������� �� ���������� �����: ������������ ���� �� ���")
					imgui.Text(u8"� ��, ������� �� ������� � � ������� ����� ������ $ ������� � ���� /ans")
					imgui.Text(u8"���� �������� �������� .�� �� ����������, �.�. /yx - ��� ����� ���������. ������ �������")
					imgui.Text(u8".� (/w) - ����� ���������� �����, ��� ����� �������")
				end
				imgui.Separator()
					imgui.BeginChild("##QuestionSelect", imgui.ImVec2(205, 225), true)
					if imgui.Selectable(u8"������ �� ���-��/����-��", beginchild == 103) then beginchild = 103 end
					if imgui.Selectable(u8"������� �� ��������, /help", beginchild == 104) then beginchild = 104 end
					if imgui.Selectable(u8"������ �� �����/�����", beginchild == 105) then beginchild = 105 end
					if imgui.Selectable(u8"������ �� ������������", beginchild == 106) then beginchild = 106 end
					if imgui.Selectable(u8"������ �� �������/�������", beginchild == 107) then beginchild = 107 end
					if imgui.Selectable(u8"������ �� �������� ����-��", beginchild == 108) then beginchild = 108 end
					if imgui.Selectable(u8"��������� ����������� �������", beginchild == 109) then beginchild = 109 end
					if imgui.Selectable(u8"�����", beginchild == 110) then beginchild = 110 end
					if imgui.Selectable(u8"������� ������� ��� /ans", beginchild == 111) then beginchild = 111 end
					imgui.EndChild()
					
					imgui.SameLine()

					if beginchild == 103 then  
						imgui.BeginChild("##2Reports", imgui.ImVec2(480, 225), true)
							imgui.Text(u8"/c - �����(�) �������� �� ������ ($ .�� ) | /hg - ������� ��� ")
							imgui.Text(u8" .�� - ����� �� ������� (������������� $)  \n/tm - �������� ($ .�� )")
							imgui.Text(u8"/zba - ������ �� �������������� ($ .��� ) \n/zbp - ������ �� ������ ($ .��� )")
							imgui.Text(u8"/vrm - ��������� ������������������� (no ID) \n/cl - ����� ���� ")
							imgui.Text(u8".�� - �������� ���� (no ID) | /dis - ����� �� � ���� ($ .�� )")
							imgui.Text(u8"/yt - �������� ��� ������/������ ($ .��) \n/n - ��� ��������� � ������ ($ .�� )")
							imgui.Text(u8"/rid - ��������� ID ($.��� ) | /nac - ����� ������� ($ .��� )")
							imgui.Text(u8"/msid - ������ � ID | /pg - �������� ($ .�� ) \n/gm - �� �� ����� ($ .�� )")
							imgui.Text(u8"/enk - ����� ($ .�� ) | /nz - �� ��������� ($ .�� ) \n/en - �� ����� ($ .��� )")
							imgui.Text(u8"/yes - �� ($ .��� ) | /net - ��� ($ .��� ) \n/of - �� ��������� ($ .��� ) | /nv - �� ������ ($ .���")
							imgui.Text(u8"/vbg - ������ ����� - ��� ($ .��� ) | /plg - ����������� ($ .��� )")
							imgui.Text(u8"/trp - ������ � /report")
						imgui.EndChild()
					end
					if beginchild == 104 then   
						imgui.BeginChild("##2QuestionsHelp", imgui.ImVec2(480, 225), true)
							imgui.Text(u8"/h7 - vip ($ .�7 ), /h8 - ��� �� ������� ($ .�8 )\n/h13 - ��������� ($ .�13 ) ")
							imgui.Text(u8"/int - ���� � ����� ($ .��� ) \n/vp1 - /vp4 - ���������� �� Premuim �� ������� ($ .��1 - .��4)")
							imgui.Text(u8"/gadm - ��������� ��� ($ .����)")
						imgui.EndChild()
					end
					if beginchild == 105 then   
						imgui.BeginChild("##2QuestionGangFamily", imgui.ImVec2(480, 225), true)
							imgui.Text(u8"/fp - ��� ������� ���� ����� ($ .��� )\n/mg - ��� ������� ���� ����� ($ .��� )")
							imgui.Text(u8"/ugf - ��� ��������� �������� �� �����/����� ($ .��� )")
							imgui.Text(u8"/igf - ��� ���������� ������� � �����/����� ($ .��� )")
							imgui.Text(u8"/lgf - �������� ����� ($ .��� ) \n/pgf - ����� �� �����/����� ($ .��� )")
							imgui.Text(u8"/vgf - ������� ��������� ����� ($ .��� ) ")
						imgui.EndChild()
					end
					if beginchild == 106 then   
						imgui.BeginChild("##2QuestionsTP", imgui.ImVec2(480, 225), true)
							imgui.Text(u8"/avt - /tp ��������� ($ .��� ) | ")
							imgui.Text(u8"/avt1 - /tp �������������� ($ .��� ) | /bk - tp in bank ($ .�� ) ")
							imgui.Text(u8"/ktp - ��� ����������������� ($ .��� ) \n/og - �����.����� ($ .�� )")
						imgui.EndChild()
					end
					if beginchild == 107 then  
						imgui.BeginChild("##2SellBuy", imgui.ImVec2(480, 225), true)
							imgui.Text(u8"/gak - ��� ������� ���������� ($ .��� )")
							imgui.Text(u8"/tcm - ����� �����/������/������ ($ .��� )")
							imgui.Text(u8"/smc - ������� ������ ($ .�� ) | /smh - ������� ���� ($ .�� )")
						imgui.EndChild()
					end
					if beginchild == 108 then  
						imgui.BeginChild('##2GiveEveryone', imgui.ImVec2(480, 225), true)
							imgui.Text(u8"/gvm - �������� ����� ($ .��� ) | /gvs - �������� ����� ($ .��� )")
							imgui.Text(u8"/gvr - �������� ������ ($ .���) | /gvc - �������� ������ ($ .���)")
						imgui.EndChild()
					end
					if beginchild == 109 then  
						imgui.BeginChild("##2OtherQuestions2", imgui.ImVec2(480, 225), true)
							imgui.Text(u8"/html - ����� ($ .���� ) | /cr - /car ($ .��� ) ")
							imgui.Text(u8"/gn - ��� ����� ������ ($ .��� ) \n/pd - ��� ����� �������� ($ .��� )")
							imgui.Text(u8"/dtl - ��� ������ ������ ($ .��� ) \n/krb - �����, ������, � ������ ($ .��� )  ")
							imgui.Text(u8"/kmd - �����, ��, ����� �� trade, ���������� ($ .��� )")
							imgui.Text(u8"/gvk - (no id)")
							imgui.Text(u8"/cpt - ������ ���� ($ .��� ) | /psv - ��������� ����� ($ .��� )")
							imgui.Text(u8"/stp - /statpl (����� ������, ������) ($ .��� )")
							imgui.Text(u8"/msp - ��� �������� ������ ($ .��� ) \n/chap - ����� ������ ($ .��� )")
							imgui.Text(u8"/hin - ��� �������� �������� � ��� ($ .��� )")
							imgui.Text(u8"/ctun - ��� ��������� ������ ($ .��� )\n /zsk - ������� ������� ($ .�� )")
							imgui.Text(u8"/tdd - ����������� ��� ($ .��� )")
						imgui.EndChild()
					end
					if beginchild == 110 then  
						imgui.BeginChild("##2KakSkins", imgui.ImVec2(480, 225), true)	
							imgui.Text(u8"/cops - ���� ($ .���� ) \n/bal - ������� ($ .��� ) | /cro - ���� ($ .���� ) ")
							imgui.Text(u8"/vg - ������ ($ .��� ) \n/rumf - ru.����� ($ .���� ) | /var - ������� ($ .��� )")
							imgui.Text(u8"/triad - ������ ($ .����� ) \n/mf - ����� ($ .�� )")
						imgui.EndChild()
					end 
					if beginchild == 111 then 
						imgui.BeginChild("##ForAnsKeys", imgui.ImVec2(480, 225), true)
							imgui.Text(u8"������ HOME - ������ � ��� �������� ����")
							imgui.Text(u8"���� ��� ������� ����� �������! // � ����������.")
							imgui.Text(u8"Numpad {.} - ����� �������� ���� � ������ \nNumpad {/} - ����� ��������.. ")
							imgui.Text(u8"..������������������� � ������ ")
							imgui.Text(u8"Numpad {-} - ����� ��������� �������������������.. \n�� ������� � ������.")
							imgui.Text(u8"����� ������ �������������... \n��� ������ ����� ������ � ���������� ���� /ans, ")
							imgui.Text(u8"�� ������� Numpad {.} � � ��� ���������:\n�������� ���� �� RDS � ������.")
						imgui.EndChild()
					end
				imgui.End()
			end
			-- ���� four_window_state �������� �� ��������� �� /ans

			if five_window_state.v then
				if AdminLevel.v >= 15 then
					set_custom_theme()

					imgui.SetNextWindowSize(imgui.ImVec2(600, 350), imgui.Cond.FirstUseEver)
					imgui.SetNextWindowPos(imgui.ImVec2((sw1 / 4.5), sh1 / 4), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

					imgui.ShowCursor = true
					imgui.LockPlayer = true

					imgui.Begin(u8'������ ������� ���������������', five_window_state) 
					imgui.Text(u8"������ ��������� ������������ ��� ����������� ������� ������..")
					imgui.Text(u8"..������� ���������������.")
						imgui.BeginChild('��������� �� �������, ���������������', imgui.ImVec2(300, 200), true)
							if imgui.CollapsingHeader(u8"��� ������ ��������������� � �.�.") then
								imgui.Text(u8"������� ��� ��� ����, ����� ����� ������")
								imgui.InputText(u8'Nick and sniat', text_buffer_sniat)
								if imgui.Button(u8'�����') then 
									sampSendChat("/makeadmin " .. u8:decode(text_buffer_sniat.v) .. " 0 ")
									notify.addNotify("{87CEEB}[AdminTool]", "�� ����� �������������� � �����:\n " .. u8:decode(text_buffer_sniat.v) .. "", 2, 1, 6)
								end 
								imgui.Separator()
								imgui.Text(u8"������� ID, ����� ���� ������� ���/������")
								imgui.InputText(u8'ID and kick', text_buffer_kick)
								if imgui.Button(u8"���") then
									sampSendChat("/skick " .. text_buffer_kick.v)
									notify.addNotify("{87CEEB}[AdminTool]", "�� ���� ������� ������/��� ID: " .. u8:decode(text_buffer_kick.v) .. "", 2, 1, 6)
								end
							end
							if imgui.CollapsingHeader(u8'��� ����, ����� ��������� ��������������') then 
								imgui.Text(u8"��� �������������, ���������� ������� LVL,")
								imgui.Text(u8"����� ������ ���, ������ �� ������")
								imgui.Text(u8"� ��� �������� LVL")
								imgui.PushItemWidth(100)
								imgui.Combo(u8"����� LVL", combo_select, arr_str, #arr_str)
								imgui.PushItemWidth(175)
								imgui.InputText(u8"������� ���", text_buffer_adm)
								if imgui.Button(u8"���������") then 
									sampSendChat("/makeadmin " .. u8:decode(text_buffer_adm.v) .. " " .. u8:decode(arr_str[combo_select.v + 1]))
									notify.addNotify("{87CEEB}[AdminTool]", "�� ��������� �������������� �� LVL:" .. u8:decode(arr_str[combo_select.v +1]) .. "\nNick: " .. u8:decode(text_buffer_adm.v), 2, 1, 6)
								end	
							end 
							if imgui.CollapsingHeader(u8"��������� ������") then  
								imgui.Text(u8"����� ��������� ������, ������� ��� ���")
								imgui.Text(u8"� ����� ����� ������� �� ������.")
								imgui.InputText(u8"������� ���", text_buffer_ban)
								if imgui.Button(u8"������") then  
									sampSendChat("/iunban " .. u8:decode(text_buffer_ban.v))
									notify.addNotify("{87CEEB}[AdminTool]", "�� ��������� ������.\nNick: " .. u8:decode(text_buffer_ban.v), 2, 1, 6)
								end
							end
						imgui.EndChild()
						imgui.SameLine()
						imgui.BeginChild('���������', imgui.ImVec2(270, 200), true)
							if imgui.CollapsingHeader(u8"������� ��� ������� ���������������") then
								imgui.Text(u8"/al id - ���� ��� /alogin ��������������")
								imgui.Text(u8"/dpv - �������� �� ����")
								imgui.Text(u8"/arep - ������ ������� � /a ��� \n��� ������ �� ������")
							end
							imgui.Separator()
							imgui.Text(u8"����� �����.������ (/tr, /ears)")
							if imgui.Button(u8"����") then
								sampSendChat("/tr")
								sampSendChat("/ears")
								notify.addNotify("{87CEEB}[AdminTool]", '�� �������� �������� /pm, \n� ��������� ��������', 2, 1, 6)
							end
						imgui.EndChild()
						imgui.BeginChild('��������', imgui.ImVec2(400, 200), true)
							if imgui.CollapsingHeader(u8"���� ������ ��� ���������") then  
								imgui.InputText(u8"������� ��.���", prefix_Madm)
								imgui.InputText(u8"������� ���", prefix_adm)
								imgui.InputText(u8"������� ��.���", prefix_STadm)
								imgui.InputText(u8"������� ���", prefix_ZGAadm)
								imgui.InputText(u8"������� ��", prefix_GAadm)
								if imgui.Button(u8"��������� ��������") then
									config.setting.prefix_adm = prefix_adm.v
									config.setting.prefix_Madm = prefix_Madm.v
									config.setting.prefix_STadm = prefix_STadm.v
									config.setting.prefix_ZGAadm = prefix_ZGAadm.v
									config.setting.prefix_GAadm = prefix_GAadm.v
									inicfg.save(config, directIni)
									notify.addNotify("{87CEEB}[AdminTool]", '���������� ������ �������.', 2, 1, 6)
								end
							end
							imgui.Text(u8"/pradm1 id - ������� ��.����� | /pradm2 id - ������� �����")
							imgui.Text(u8"/pradm3 id - ������� ��.����� | /pradm4 id - ������� ���")
							imgui.Text(u8"/pradm5 id - ������� ��")
						imgui.EndChild()
					imgui.End()
				else
					imgui.SetNextWindowSize(imgui.ImVec2(600, 350), imgui.Cond.FirstUseEver)
					imgui.SetNextWindowPos(imgui.ImVec2((sw1 / 4.5), sh1 / 4), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

					imgui.ShowCursor = true
					imgui.LockPlayer = true
					
					imgui.Begin(u8'������ ������� ���������������', five_window_state) 


					imgui.Text(u8"��� ������� ���. ������ �������� ������ ������� ���������������.")

					imgui.End()
				end
			end
 			-- ���� five_window_state �������� �� ������ ������� ���������������

			if six_window_state.v then  -- ��������� AT

				set_custom_theme()

				imgui.SetNextWindowSize(imgui.ImVec2(425, 350), imgui.Cond.FirstUseEver)
				imgui.SetNextWindowPos(imgui.ImVec2((sw1 / 2), sh1 / 6), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

				imgui.ShowCursor = true
				imgui.LockPlayer = true

				imgui.Begin(u8"��������� AdminTool", six_window_state)
				if imgui.CollapsingHeader(u8"���������������� �������") then  
					if imgui.Combo(u8'����� �������', AdminLevel, arr_alvl) then
							if AdminLevel.v == 0 then
							config.setting.AdminLevel = AdminLevel.v
							inicfg.save(config, directIni)
							end
							if AdminLevel.v == 1 then
							config.setting.AdminLevel = AdminLevel.v
							inicfg.save(config, directIni)
							end
							if AdminLevel.v == 2 then
							config.setting.AdminLevel = AdminLevel.v
							inicfg.save(config, directIni)
							end
							if AdminLevel.v == 3 then
							config.setting.AdminLevel = AdminLevel.v
							inicfg.save(config, directIni)
							end
							if AdminLevel.v == 4 then
							config.setting.AdminLevel = AdminLevel.v
							inicfg.save(config, directIni)
							end
							if AdminLevel.v == 5 then
							config.setting.AdminLevel = AdminLevel.v
							inicfg.save(config, directIni)
							end
							if AdminLevel.v == 6 then
							config.setting.AdminLevel = AdminLevel.v
							inicfg.save(config, directIni)
							end
							if AdminLevel.v == 7 then
							config.setting.AdminLevel = AdminLevel.v
							inicfg.save(config, directIni)
							end
							if AdminLevel.v == 8 then
							config.setting.AdminLevel = AdminLevel.v
							inicfg.save(config, directIni)
							end
							if AdminLevel.v == 9 then
							config.setting.AdminLevel = AdminLevel.v
							inicfg.save(config, directIni)
							end
							if AdminLevel.v == 10 then
							config.setting.AdminLevel = AdminLevel.v
							inicfg.save(config, directIni)
							end
							if AdminLevel.v == 11 then
							config.setting.AdminLevel = AdminLevel.v
							inicfg.save(config, directIni)
							end
							if AdminLevel.v == 12 then
							config.setting.AdminLevel = AdminLevel.v
							inicfg.save(config, directIni)
							end
							if AdminLevel.v == 13 then
							config.setting.AdminLevel = AdminLevel.v
							inicfg.save(config, directIni)
							end
							if AdminLevel.v == 14 then
							config.setting.AdminLevel = AdminLevel.v
							inicfg.save(config, directIni)
							end
							if AdminLevel.v == 15 then
							config.setting.AdminLevel = AdminLevel.v
							inicfg.save(config, directIni)
							end
							if AdminLevel.v == 16 then
							config.setting.AdminLevel = AdminLevel.v
							inicfg.save(config, directIni)
							end
							if AdminLevel.v == 17 then
								config.setting.AdminLevel = AdminLevel.v
								inicfg.save(config, directIni)
							end
							if AdminLevel.v == 18 then
								config.setting.AdminLevel = AdminLevel.v
								inicfg.save(config, directIni)
							end
					end
				end
				imgui.BeginChild('��������', imgui.ImVec2(400, 60), true)
					imgui.Text(u8"���������������� ���")
					imgui.SameLine()
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
					imgui.ToggleButton("##1", setting_items.Admin_chat)
					if setting_items.Admin_chat.v then
						if imgui.Button(u8'��������� ����� ����.', btn_size) then
							ATChat.v = not ATChat.v
						end
					end
				imgui.EndChild()
				imgui.Text(u8"��������� ���� ���������� �� �������")
				imgui.SameLine()
				imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
				imgui.ToggleButton("##3", setting_items.ranremenu)
				imgui.Text(u8"����������� � ����� ��������")
				imgui.SameLine()
				imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
				imgui.ToggleButton("##Push_Report", setting_items.Push_Report)
				imgui.Text(u8"���-������")
				imgui.SameLine()
				imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
				imgui.ToggleButton("##2", setting_items.Chat_Logger)
				imgui.Text(u8"���������� �������")
				imgui.SameLine()
				imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
				imgui.ToggleButton("##4", setting_items.anti_cheat)
				imgui.Text(u8"����-��� �� ���")
				imgui.SameLine()
				imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
				imgui.ToggleButton("##5", setting_items.auto_mute_mat)
				imgui.Text(u8"������� ������")
				imgui.SameLine()
				imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
				imgui.ToggleButton("##6", setting_items.translate_cmd)
				imgui.Separator()
					if imgui.Button(u8"�������� ������", btn_size) then  
						settings_keys.v = not settings_keys.v
					end
					imgui.Separator()
					if imgui.Button("WallHack", btn_size) then
						if control_wallhack then
							sampAddChatMessage(tag .."WallHack ��� ��������.")
							nameTagOff()
							control_wallhack = false
						else
							sampAddChatMessage(tag .."WallHack ��� �������.")
							nameTagOn()
							control_wallhack = true
						end
					end
				imgui.Separator()
				imgui.Text(u8"AutoALogin")
				imgui.SameLine()
				imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
				imgui.ToggleButton("##AutoALogin", setting_items.ATAlogin)
				imgui.Text(u8"���� ������ ��� /alogin")
				imgui.InputText(u8"Password for Admin", ATAdminPass)
				imgui.Separator()
				if imgui.Button(u8"���������.") then
					config.setting.Admin_chat = setting_items.Admin_chat.v
					config.setting.Chat_Logger = setting_items.Chat_Logger.v
					config.setting.Chat_Logger_osk = setting_items.Chat_Logger_osk.v
					config.setting.Push_Report = setting_items.Push_Report.v
					config.setting.ATAlogin = setting_items.ATAlogin.v
					config.setting.ranremenu = setting_items.ranremenu.v
					config.setting.anti_cheat = setting_items.anti_cheat.v
					config.setting.AdminLevel = AdminLevel.v
					config.setting.auto_mute_mat = setting_items.auto_mute_mat.v
					config.setting.translate_cmd = setting_items.translate_cmd.v 
					config.setting.ATAdminPass = ATAdminPass.v
					inicfg.save(config, directIni)
					notify.addNotify("{87CEEB}[AdminTool]", '���������� ������ �������.', 2, 1, 6)
				end
				imgui.SameLine()
				imgui.Text(u8"��������� ����� ���������� � config/AdminTool")
				imgui.Separator()
				if imgui.Button(u8"���������� �������") then  
						lua_thread.create(function()
							imgui.Process = false
							wait(200)
							sampAddChatMessage(tag .. "�������� ������� �� �������� MoonLoader...")
							sampAddChatMessage(tag .. "���� ������� ������ ����, �� �������� ������� SAMPFUNCS � ��������.")
							sampAddChatMessage(tag .. "������� ����������� �� �������: ������ (�)")
							wait(200)
							imgui.ShowCursor = false
							thisScript():unload()
						end)
				end  
				imgui.Text(u8"��� ����, ����� ����� ��������� ������: ALT+R \n(������������ ���� ��������)")
				imgui.Separator()
				imgui.End()
			end

			if seven_window_state.v then  

				set_custom_theme()

				imgui.SetNextWindowSize(imgui.ImVec2(650, 350), imgui.Cond.FirstUseEver)
				imgui.SetNextWindowPos(imgui.ImVec2((sw1 / 3), sh1 / 6), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

				imgui.ShowCursor = true  

				imgui.Begin(u8"ID ������", seven_window_state)
					
					imgui.Text(u8"��� ID ����������� � ����������! ������� ��������.")
					imgui.Text(u8"��� �������������, ���� ����� ��������� ������ ��� ��������:")
					imgui.Text(u8"https://gtaxmods.com/skins-id.html - �����")
					imgui.Text(u8"https://samp-mods.com/id-vehicles-samp.html - ������")
					
					if imgui.CollapsingHeader(u8"ID guns") then  
						imgui.Text(u8"1 ID - ������ | 2 ID - ������ | 3 ID - �������")
						imgui.Text(u8"4 ID - ��� | 5 ID - ���� | 6 ID - ������")
						imgui.Text(u8"7 ID - ��� | 8 ID - ������ | 9 ID - ���������")
						imgui.Text(u8"10 ID - ������������� | 11-13 ID - ���������")
						imgui.Text(u8"14 ID - ����� ������ | 15 ID - ������")
						imgui.Text(u8"16 ID - ������� | 17 ID - ���/��� �������")
						imgui.Text(u8"18 ID - ������� | 22 ID - Colt 45 (��������)")
						imgui.Text(u8"23 ID - Colt 45 � ���������� | 24 ID - Deagle")
						imgui.Text(u8"25 ID - ShotGun | 26 ID - �����������")
						imgui.Text(u8"27 ID - Combat ShotGun | 28 ID - ���")
						imgui.Text(u8"29 ID - MP5 | 30 ID - AK-47 | 31 ID - M4")
						imgui.Text(u8"32 ID - Tec-9 | 33 ID - Rifle | 34 ID - Sniper")
						imgui.Text(u8"35 ID - RPG | 36 ID - ���������")
						imgui.Text(u8"37 ID - ������� | 38 ID - minigun | 39-40 ID - C4")
						imgui.Text(u8"41 ID - ���������� | 42 ID - ������������")
						imgui.Text(u8"43 ID - ����������� | 44-45 ID - ���� ������� �������")
						imgui.Text(u8"46 ID - �������")
					end
				imgui.End()

			end
			-- ������� ������

			if ATChat.v then

				set_custom_theme()

				imgui.LockPlayer = true
				imgui.ShowCursor = true

				imgui.SetNextWindowPos(imgui.ImVec2(10, 10), imgui.Cond.FirstUseEver, imgui.ImVec2(0, 0))
				imgui.SetNextWindowSize(imgui.ImVec2(300, -0.1), imgui.Cond.FirstUseEver)
				local btn_size = imgui.ImVec2(-0.1, 0)
				imgui.Begin(u8"��������� ����� ����.", ATChat)
				if imgui.Button(u8'��������� ����.', btn_size) then
					ac_no_saved.X = admin_chat_lines.X; ac_no_saved.Y = admin_chat_lines.Y
					ac_no_saved.pos = true
				end
				imgui.Text(u8'������������ ����.')
				imgui.Combo("##Position", admin_chat_lines.centered, {u8"�� ����� ����.", u8"�� ������.", u8"�� ������ ����."})
				imgui.PushItemWidth(50)
				if imgui.InputText(u8"������ ����.", font_size_ac) then
					font_ac = renderCreateFont("Arial", tonumber(font_size_ac.v) or 10, font_admin_chat.BOLD + font_admin_chat.SHADOW)
				end
				imgui.PopItemWidth()
				imgui.Text(u8'��������� ���� � ������.')
				imgui.Combo("##Pos", admin_chat_lines.nick, {u8"������.", u8"�����."})
				imgui.Text(u8'���������� �����.')
				imgui.PushItemWidth(80)
				imgui.InputInt(' ', admin_chat_lines.lines)
				imgui.PopItemWidth()
				if imgui.Button(u8'���������.', btn_size) then
					sampAddChatMessage(tag .. " ������������ ����������������� ���� ���������.")
					saveAdminChat()
				end
				imgui.End()
			end
			-- ��������� ���-����

			if settings_keys.v then  

				set_custom_theme()

				imgui.LockPlayer = true  
				imgui.ShowCursor = true

				imgui.SetNextWindowSize(imgui.ImVec2(425, 350), imgui.Cond.FirstUseEver)
				imgui.SetNextWindowPos(imgui.ImVec2((sw1 / 6), sh1 / 6), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
				imgui.Begin(u8"��������� ������", settings_keys)
					imgui.Text(u8"������� ������: ")
					imgui.SameLine()
					imgui.Text(getDownKeysText())
					imgui.Separator()
					imgui.Text(u8"�������� ���������� (/tool): ")
					imgui.SameLine()
					imgui.Text(config.keys.ATTool)
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 84)
					if imgui.Button(u8"��������. ## 1", imgui.ImVec2(75, 0)) then
						config.keys.ATTool = getDownKeysText()
						inicfg.save(config, directIni)
					end
					imgui.Separator()
					imgui.Text(u8"������ �� ������: ")
					imgui.SameLine()
					imgui.Text(config.keys.ATOnline)
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 84)
					if imgui.Button(u8"��������. ## 2", imgui.ImVec2(75, 0)) then
						config.keys.ATOnline = getDownKeysText()
						inicfg.save(config, directIni)
					end
					imgui.Separator()
					imgui.Text(u8"�������� /ans: ")
					imgui.SameLine()
					imgui.Text(config.keys.ATReportAns)
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 84)
					if imgui.Button(u8"��������. ## 3", imgui.ImVec2(75, 0)) then
						config.keys.ATReportAns = getDownKeysText()
						inicfg.save(config, directIni)
					end
					imgui.Separator()
					imgui.Text(u8'����� "�������� ����" � /ans: ' )
					imgui.SameLine()
					imgui.Text(config.keys.ATReportRP)
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 84)
					if imgui.Button(u8"��������. ## 4", imgui.ImVec2(75, 0)) then
						config.keys.ATReportRP = getDownKeysText()
						inicfg.save(config, directIni)
					end
					imgui.Separator()
					imgui.Text(u8"���������� ������ ��� ������: ")
					imgui.SameLine()
					imgui.Text(config.keys.Re_menu)
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 84)
					if imgui.Button(u8"��������. ## 5", imgui.ImVec2(75, 0)) then
						config.keys.Re_menu = getDownKeysText()
						inicfg.save(config, directIni)
					end
					imgui.Separator()
					imgui.Text(u8'����� "��������� �������������������" � /ans: ' )
					imgui.SameLine()
					imgui.Text(config.keys.ATReportRP1)
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 84)
					if imgui.Button(u8"��������. ## 6", imgui.ImVec2(75, 0)) then
						config.keys.ATReportRP1 = getDownKeysText()
						inicfg.save(config, directIni)
					end
					imgui.Separator()
					imgui.Text(u8'����� "�������� ����" � ���: ' )
					imgui.SameLine()
					imgui.Text(config.keys.ATReportRP2)
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 84)
					if imgui.Button(u8"��������. ## 7", imgui.ImVec2(75, 0)) then
						config.keys.ATReportRP2 = getDownKeysText()
						inicfg.save(config, directIni)
					end
					imgui.Separator()
					imgui.Text(u8'���������/���������� WallHack: ' )
					imgui.SameLine()
					imgui.Text(config.keys.ATWHkeys)
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 84)
					if imgui.Button(u8"��������. ## 8", imgui.ImVec2(75, 0)) then
						config.keys.ATWHkeys = getDownKeysText()
						inicfg.save(config, directIni)
					end
				imgui.End()
			end
			-- �������� ������

			if ATChatLogger.v then

				set_custom_theme()

				imgui.LockPlayer = true
				imgui.ShowCursor = true

				imgui.SetNextWindowSize(imgui.ImVec2(600, 350), imgui.Cond.FirstUseEver)
				imgui.SetNextWindowPos(imgui.ImVec2((sw1 / 4.5), sh1 / 4), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
				imgui.Begin(u8"���-������", ATChatLogger)
				if setting_items.Chat_Logger.v then
					if accept_load_clog then
						imgui.InputText(u8"�����.", chat_find)
						if chat_find.v == "" then
							imgui.Text(u8'������� ������� �����\n')
						else
							for key, v in pairs(chat_logger_text) do
								if v:find(chat_find.v) ~= nil then
									imgui.Text(u8:encode(v))
								end
							end
						end
					else
						imgui.SetCursorPosX(imgui.GetWindowWidth()/2.3)
						imgui.SetCursorPosY(imgui.GetWindowHeight()/2.3)
						imgui.Spinner(20, 7)
					end
				else 
					imgui.Text(u8"������������ ���-������� �� ���� ��������.")
					imgui.Text(u8"Q: ��� ��� ��������?")
					imgui.Text(u8"A: ��� ������! ������ � /tool. ����� ������ �� < ��������� >")
					imgui.Text(u8"A: �������? ������� �� ������������� < ���-������ > � ������ ��� ���")
				end
				imgui.End()
			end
			-- ���-������

			if ATre_menu.v and control_recon and recon_to_player and setting_items.ranremenu.v then -- �����

				set_custom_theme()

				imgui.LockPlayer = false
				if isKeyJustPressed(VK_RBUTTON) and not sampIsChatInputActive() and not sampIsDialogActive() then
					imgui.ShowCursor = not imgui.ShowCursor
				end

				imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/1.06), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1))
				imgui.SetNextWindowSize(imgui.ImVec2(660, 80), imgui.Cond.FirstUseEver)
				imgui.Begin(u8"��������� ������", false, 2+4+32)
					if imgui.Button(u8"Back Player") then  
						sampSendChat("/re " .. control_recon_playerid-1)
					end
					imgui.SameLine()
					if imgui.Button(u8"����������") then
						sampSendChat("/aspawn " .. control_recon_playerid)
					end
					imgui.SameLine()
					if imgui.Button(u8"��������") then
						sampSendClickTextdraw(48)
					end
					imgui.SameLine()
					if imgui.Button(u8"��������") then  
						sampSendChat("/slap " .. control_recon_playerid)
					end
					imgui.SameLine()
					if imgui.Button(u8"����������") then  
						sampSendChat("/freeze " .. control_recon_playerid)
					end
					imgui.SameLine()
					if imgui.Button(u8"�����������") then  
						sampSendChat("/freeze " .. control_recon_playerid)
					end
					imgui.SameLine()
					if imgui.Button(u8"�����") then
						sampSendChat("/reoff")
						control_recon_playerid = -1
					end
					imgui.SameLine()
					if imgui.Button(u8"Next Player") then  
						sampSendChat("/re " .. control_recon_playerid+1)
					end
					imgui.Separator()
					imgui.SetCursorPosX(imgui.GetWindowWidth()/2.43-80)
					if imgui.Button(u8"��������") then
						tool_re = 1
					end
					imgui.SameLine()
					imgui.SetCursorPosX(imgui.GetWindowWidth()/2.41)
					if imgui.Button(u8"��������") then
						tool_re = 2
					end
					imgui.SameLine()
					imgui.SetCursorPosX(imgui.GetWindowWidth()/2.43+80)
					if imgui.Button(u8"�������") then
						tool_re = 3
					end
				imgui.End()
				imgui.SetNextWindowPos(imgui.ImVec2(sw-10, 10), imgui.Cond.FirstUseEver, imgui.ImVec2(1, 0.5))
				imgui.SetNextWindowSize(imgui.ImVec2(250, sh/1.15), imgui.Cond.FirstUseEver)

				if right_re_menu then -- �����

					set_custom_theme()

					imgui.Begin(u8"���������� �� ������", false, 2+4+32)
					if accept_load then
						if not sampIsPlayerConnected(control_recon_playerid) then
							control_recon_playernick = "-"
						else
							control_recon_playernick = sampGetPlayerNickname(control_recon_playerid)
						end
						imgui.Text(u8"�����: " .. control_recon_playernick .. "[" .. control_recon_playerid .. "]")
						imgui.Separator()
						for key, v in pairs(player_info) do
							if key == 2 then
								imgui.Text(u8:encode(text_remenu[2]) .. " " .. player_info[2])
								imgui.BufferingBar(tonumber(player_info[2])/100, imgui.ImVec2(imgui.GetWindowWidth()-10, 10), false)
							end
							if key == 3 and tonumber(player_info[3]) ~= 0 then
								imgui.Text(u8:encode(text_remenu[3]) .. " " .. player_info[3])
								imgui.BufferingBar(tonumber(player_info[3])/100, imgui.ImVec2(imgui.GetWindowWidth()-10, 10), false)
							end
							if key == 4 and tonumber(player_info[4]) ~= -1 then
								imgui.Text(u8:encode(text_remenu[4]) .. " " .. player_info[4])
								imgui.BufferingBar(tonumber(player_info[4])/1000, imgui.ImVec2(imgui.GetWindowWidth()-10, 10), false)
							end
							if key == 5 then
								imgui.Text(u8:encode(text_remenu[5]) .. " " .. player_info[5])
								local speed, const = string.match(player_info[5], "(%d+) / (%d+)")
								if tonumber(speed) > tonumber(const) then
									speed = const
								end
								imgui.BufferingBar((tonumber(speed)*100/tonumber(const))/100, imgui.ImVec2(imgui.GetWindowWidth()-10, 10), false)
							end
							if key ~= 2 and key ~= 3 and key ~= 4 and key ~= 5 then
								imgui.Text(u8:encode(text_remenu[key]) .. " " .. player_info[key])
							end
						end
						imgui.Separator()
						if imgui.Button("WallHack") then
							if control_wallhack then
								nameTagOff()
								control_wallhack = false
							else
								nameTagOn()
								control_wallhack = true
							end
						end
						imgui.SameLine()
						imgui.TextQuestion("(?)", u8"���������/���������� WH")
						if imgui.Button(u8"���������� ������� ������") then  
							sampSendChat("/statpl " .. control_recon_playerid)
						end	
						imgui.SameLine()
						imgui.TextQuestion("(?)", u8"/statpl\n�����������")
						if imgui.Button(u8"������ ���������� ������") then  
							sampSendChat("/offstats " .. control_recon_playernick)
						end
						imgui.SameLine()
						imgui.TextQuestion("(?)", u8"����� Reg/Last IP, /offstats\n�����������")
						if imgui.Button(u8"������ ������") then  
							sampSendChat("/iwep " .. control_recon_playerid)
						end 
						imgui.SameLine()
						imgui.TextQuestion("(?)", u8"����� ����� ������, /iwep\n�����������")
						if imgui.Button(u8"�������� ������") then  
							sampSendChat("/tweap " .. control_recon_playerid)
						end  
						imgui.SameLine()
						imgui.TextQuestion("(?)", u8"/tweap\n�����������")
						imgui.Separator()
						imgui.Text(u8"������ �����:")
						local playerid_to_stream = playersToStreamZone()
						for _, v in pairs(playerid_to_stream) do
							if imgui.Button(" - " .. sampGetPlayerNickname(v) .. "[" .. v .. "] - ", imgui.ImVec2(-0.1, 0)) then
								sampSendChat("/re " .. v)
							end
						end
						imgui.Separator()
						imgui.Text(u8"��� �� ������ ������ ���\n ������� �������: ������� ���.")
						imgui.Text(u8"�������: R - �������� �����. \n�������: Q - ����� �� ������")
						imgui.Text(u8"NumPad4 - ���������� ����� \nNumPad6 - ��������� �����")

					else
						imgui.SetCursorPosX(imgui.GetWindowWidth()/2.3)
						imgui.SetCursorPosY(imgui.GetWindowHeight()/2.3)
						imgui.Spinner(20, 7)
					end
					imgui.End()
				end

				if tool_re > 0 then -- ��������� �� ���������� � ������

					set_custom_theme()

						imgui.LockPlayer = true
					imgui.SetNextWindowPos(imgui.ImVec2(10, 10), imgui.Cond.FirstUseEver, imgui.ImVec2(1, 0.5))
					imgui.SetNextWindowSize(imgui.ImVec2(250, sh/1.15), imgui.Cond.FirstUseEver)
					imgui.Begin(u8"��������� ������. ##Nak", false, 2+4+32)
					if tool_re == 1 then
						if imgui.Button("Cheat", btn_size) then
							sampSendChat("/jail " .. control_recon_playerid .. " 3000 ������������� ���������� �������/��")
						end
						if imgui.Button(u8"���.����������� ��������", btn_size) then  
							sampSendChat("/jail " .. control_recon_playerid .. " 900 ������������� ClickWarp/Metla (���)")
						end	
						if imgui.Button(u8"��������������� VIP", btn_size) then
							sampSendChat("/jail " .. control_recon_playerid .. " 3000 ��������������� VIP")
						end
						if imgui.Button("Speed Hack/Fly", btn_size) then
							sampSendChat("/jail " .. control_recon_playerid .. " 900 SpeedHack/Fly/Flycar")
						end
						if imgui.Button(u8"������ MP", btn_size) then
							sampSendChat("/jail " .. control_recon_playerid .. " 300 ��������� ������ MP.")
						end
						if imgui.Button("Spawn Kill", btn_size) then
							sampSendChat("/jail " .. control_recon_playerid .. " 300 Spawn Kill")
						end
						if imgui.Button("DM in ZZ", btn_size) then  
							sampSendChat("/jail " .. control_recon_playerid .. " 300 DM/DB in ZZ")
						end
						if imgui.Button(u8"������ �������", btn_size) then  
							sampSendChat("/jail " .. control_recon_playerid .. " 300 ��������� ������ �������")
						end
						if imgui.Button(u8"������/����� ���", btn_size) then  
							sampSendChat("/jail " .. control_recon_playerid .. " 900 ������������� ������/����� ����")
						end
						if imgui.Button(u8"Car in /trade", btn_size) then  
							sampSendChat("/jail " .. control_recon_playerid .. " 300 DB/Car in /trade")
						end
						if imgui.Button(u8"������� ������ (���� � ������)", btn_size) then  
							sampSendChat("/jail " .. control_recon_playerid .. " 300 ������� ������ (deagle in car)")
						end
						if imgui.Button(u8"������������� ��������� �� /gw", btn_size) then  
							sampSendChat("/jail " .. control_recon_playerid .. " 600 ���. ��������� �� /gw")
						end
						if imgui.Button(u8"SpawnKill �� /gw", btn_size) then  
							sampSendChat("/jail " .. control_recon_playerid .. " 500 SK in /gw")
						end
						if imgui.Button(u8"������������� ������.������ �� /gw", btn_size) then  
							sampSendChat("/jail " .. control_recon_playerid .. " 600 ���. ����������� ������ �� /gw")
						end
						imgui.Separator()
						if imgui.Button(u8"�����. ##1", btn_size) then
							tool_re = 0
						end
					elseif tool_re == 2 then
						if imgui.Button("Cheat", btn_size) then
							sampSendChat("/ans " .. control_recon_playerid .. " ��������� �����, �� �������� ������� �������, � ���� ��..")
							sampSendChat("/ans " .. control_recon_playerid .. " ..�� �������� � ����������, �������� ������ � VK: dmdriftgta")
							sampSendChat("/iban " .. control_recon_playerid .. " 7 ������������� ���������� �������/��")
						end
						if imgui.Button(u8"����� ����", btn_size) then
							sampSendChat("/ans " .. control_recon_playerid .. " ��������� �����, �� �������� ������� �������, � ���� ��..")
							sampSendChat("/ans " .. control_recon_playerid .. " ..�� �������� � ����������, �������� ������ � VK: dmdriftgta")
							sampSendChat("/iban " .. control_recon_playerid .. " 7 ����� �������� ����")
						end
						if imgui.Button(u8"������������ ���������", btn_size) then
							sampSendChat("/ans " .. control_recon_playerid .. " ��������� �����, �� �������� ������� �������, � ���� ��..")
							sampSendChat("/ans " .. control_recon_playerid .. " ..�� �������� � ����������, �������� ������ � VK: dmdriftgta")
							sampSendChat("/iban " .. control_recon_playerid .. " 3 ������������ ���������.")
						end
						if imgui.Button(u8"������� �������� ��������������", btn_size) then
							sampSendChat("/ans " .. control_recon_playerid .. " ��������� �����, �� �������� ������� �������, � ���� ��..")
							sampSendChat("/ans " .. control_recon_playerid .. " ..�� �������� � ����������, �������� ������ � VK: dmdriftgta")
							sampSendChat("/ban " .. control_recon_playerid .. " 7 ������� ���� ��������������.")
						end
						if imgui.Button("Nick 3/3", btn_size) then
							sampSendChat("/ans " .. control_recon_playerid .. " ��������� �����, �� �������� ������� �������, � ���� ��..")
							sampSendChat("/ans ".. control_recon_playerid .. " ..�� �������� � ����������, �������� ������ � VK: dmdriftgta")
							sampSendChat("/ban " .. control_recon_playerid .. " 7 ���, ���������� ����������� �������")
						end
						if imgui.Button(u8"���/��������/��� � �������", btn_size) then
							sampSendChat("/ans " .. control_recon_playerid .. " ��������� �����, �� �������� ������� �������, � ���� ��..")
							sampSendChat("/ans " .. control_recon_playerid .. " ..�� �������� � ����������, �������� ������ � VK: dmdriftgta")
							sampSendChat("/ban " .. control_recon_playerid .. " 3 �����������/��������/��� � �������")
						end
						imgui.Separator()
						if imgui.Button(u8"�����. ##2", btn_size) then
							tool_re = 0
						end
					elseif tool_re == 3 then
						if imgui.Button("AFK in /arena", btn_size) then
							sampSendChat("/kick " .. control_recon_playerid .. " AFK in /arena")
						end
						if imgui.Button("DM in Jail", btn_size) then
							sampSendChat("/kick " .. control_recon_playerid .. " dm in jail")
						end
						if imgui.Button("Nick 1/3", btn_size) then
							sampSendChat("/kick " .. control_recon_playerid .. " Nick 1/3")
						end
						if imgui.Button("Nick 2/3", btn_size) then
							sampSendChat("/kick " .. control_recon_playerid .. " Nick 2/3")
						end
						imgui.Separator()
						if imgui.Button(u8"�����. ##3", btn_size) then
							tool_re = 0
						end
					end
					imgui.End()
				end
			end
			
end

function sampev.onPlayerDeathNotification(killerId, killedId, reason)
	local kill = ffi.cast('struct stKillInfo*', sampGetKillInfoPtr())
	local _, myid = sampGetPlayerIdByCharHandle(playerPed)

	local n_killer = ( sampIsPlayerConnected(killerId) or killerId == myid ) and sampGetPlayerNickname(killerId) or nil
	local n_killed = ( sampIsPlayerConnected(killedId) or killedId == myid ) and sampGetPlayerNickname(killedId) or nil
	lua_thread.create(function()
		wait(0)
		if n_killer then kill.killEntry[4].szKiller = ffi.new('char[25]', ( n_killer .. '[' .. killerId .. ']' ):sub(1, 24) ) end
		if n_killed then kill.killEntry[4].szVictim = ffi.new('char[25]', ( n_killed .. '[' .. killedId .. ']' ):sub(1, 24) ) end
	end)
end