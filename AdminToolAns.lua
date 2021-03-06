script_name('PluginATAns') -- �������� �������
script_description('������ ��� ���������� ������ ���������������') -- �������� �������

require "lib.moonloader" -- ����������� �������� ���������� mooloader
local keys = require "vkeys" -- ������� ��� ������
local imgui = require 'imgui' -- ������� imgui ����
local dlstatus = require('moonloader').download_status
local encoding = require 'encoding' -- ���������� ��������
local inicfg = require 'inicfg' -- ������ � ini
local sampev = require "lib.samp.events" -- ���������� �������� ���������, ��������� � ������� ������� ������� SA:MP, � �� ������ ���������� � LUA
encoding.default = 'CP1251' -- ����� ��������� �� CP1251
u8 = encoding.UTF8 -- ������������ ������������� ������ ��������� UTF8 - u8
local mcolor -- ��������� ���������� ��� ����������� ���������� �����

local themes = import "module/imgui_themes.lua" -- ����������� ������� ���
local notify = import "module/lib_imgui_notf.lua" -- ����������� ������� �����������

local tag = "{87CEEB}[AdminTool]  {4169E1}" -- ��������� ����������, ������� ������������ ��� AT
local label = 0
local main_color = 0xe01df2
local text_color = 0x4169E1
local main_color_text = "{6e73f0}"
local white_color = "{FFFFFF}"

local ans_imgui = imgui.ImBool(false)
local good_game_prefix = imgui.ImBool(false)
local ans_text = imgui.ImBuffer(4096)
local ans_report = imgui.ImBool(false)

-------- �������� ��������� ����������, ���������� �� �������������� ----------

update_state = false

local script_version_ans = 6
local script_version_text_ans = "3.2 + Fix"
local script_path = thisScript().path 
local script_url = "https://raw.githubusercontent.com/alfantasy/AdminTool/main/AdminToolAns.lua"
local update_path = getWorkingDirectory() .. '/ANSupdate.ini'
local update_url = "https://raw.githubusercontent.com/alfantasy/AdminTool/main/ANSupdate.ini"
-------- �������� ��������� ����������, ���������� �� �������������� ----------

local questions = {
    ["reporton"] = {
        [u8"������ ������ �� ������"] = "�����(�) ������ �� ����� ������!",
		[u8"������ �� ������"] = "������ ������ �� �������������� � VK: vk.com/dmdriftgta",
		[u8"������ �� ������"] = "�� ������ �������� ������ �� ������ � VK: vk.com/dmdriftgta",
		[u8"������� ���"] = "������� ���",
		[u8"��������"] = "��������",
		[u8"��������� �������������������"] = "��������� ������������������� �� Russian Drift Server!",
		[u8"����� ����"] = " ������ ����� ����",
		[u8"����� �� � ����"] = "������ ����� �� � ����",
		[u8"��������� ������/������"] = "�������� ��� ������/������",
		[u8"��������� ID"] = "�������� ID ����������/������ � /report",
		[u8"����� �������"] = "������ ����� �������",
		[u8"��������"] = "��������",
		[u8"�� �� ��������"] = "GodMode (������) �� ������� �� ��������",
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
	["HelpCmd"] = {
		[u8"������� VIP`�"] = "������ ���������� ����� ����� � /help -> 7 �����",
		[u8"������� ��� �������"] = "������ ���������� ����� ����� � /help -> 8 �����",
		[u8"��� ���������� ������"] = "������ ���������� ����� ����� � /help -> 13 �����",
		[u8"���������� � �����"] = "������ ���������� ����� ������ � ���������",
		[u8"���������� Premuim"] = "������ ����� � ����������� Premuim VIP (/help -> 7)",
		[u8"���������� Diamond"] = "������ ����� � ����������� Diamond VIP (/help -> 7) ",
		[u8"���������� Platinum"] = "������ ����� � ����������� Platinum VIP (/help -> 7)",
		[u8"���������� ������"] = "������ ����� � ����������� ������� VIP (/help -> 7)",
		[u8"��� �������� �������"] = "������� �����, ��� �� /help -> 17 �����"
	},
	["HelpGangFamilyMafia"] = {
		[u8"��� ������� ���� �����"] = "/menu (/mm) - ALT/Y -> ������� ����",
		[u8"��� ������� ���� �����"] = "/familypanel",
		[u8"��� ��������� ������"] = "/guninvite (�����) || /funinvite (�����)",
		[u8"��� ���������� ������"] = "/ginvite (�����) || /finvite (�����)",
		[u8"��� �������� �����/�����"] = "/gleave (�����) || /fleave (�����)",
		[u8"��� �������� �����"] = "/leave",
		[u8"��� ������ �������"] = "/gvig // ������ ���� �������"
	},
	["HelpTP"] = {
		[u8"��� �� � ���������"] = "tp -> ������ -> ����������",
		[u8"��� �� � ��������������"] = "/tp -> ������ -> ���������� -> ��������������",
		[u8"��� �� � ����"] = "�������� ������/��� ����� � ������� /bank ��� /tp -> ������ -> ����",
		[u8"��� ���� ��"] = "/tp (�� ��������), /g (/goto) id (� ������) � VIP (/help -> 7 �����)"

	},
	["HelpSellBuy"] = {
		[u8"��� ������� ����"] = "������� ����������, ��� ������ ����� �� /trade. ����� �������, /sell ����� �����",
		[u8"��� �������� ������"] = "����� �������� ������, ������� /trade, � ��������� � NPC ������, ����� ������",
		[u8"� ��� ������� �����"] = "/sellmycar IDPlayer ����1-3 ����� || /car -> ����1-3 -> ������� �����������",
		[u8"� ����� ��� �������"] = "/hpanel -> ����1-3 -> �������� -> ������� ��� ����������� || /sellmyhouse (������)"
	},
	["HelpGiveEveryone"] = {
		[u8"��� �������� ������"] = "/givemoney IDPlayer money",
		[u8"��� �������� ����"] = "/givescore IDPlayer score",
		[u8"��� �������� �����"] = "/giverub IDPlayer rub | � ������� (/help -> 7)",
		[u8"��� �������� �����"] = "/givecoin IDPlayer coin | � ������� (/help -> 7)"
	},
	["HelpDefault"] = {
		[u8"� ��� ���� ���������"] = "����� ������/������ ���� � HTML. ���� � {} - https://colorscheme.ru/html-colors.html",
		[u8"������"] = "/car",
		[u8"��� �������� ����"] = '������ �� ����� "���������� �����", ����� ����� ����� �������� �� ALT � ����� �� ������� ������ �� �����',
		[u8"��� ����� ������"] = "/menu (/mm) - ALT/Y -> ������",
		[u8"��� ����� ��������"] = "/menu (/mm) - ALT/Y -> ��������",
		[u8"��� �������� ������"] = "������ ���������� �� ���� �����. ����� ������������ �� /garage",
		[u8"������, ������ � ������"] = "������, ������, ������",
		[u8"�����, ��, ����� �� /trade � �.�."] = "������, ��, ����������, ������, ����� ����� �� �����(/trade)",
		[u8"������ �� ���.������"] = "https://vk.com/dmdriftgta | ����������� ������",
		[u8"��� ������ ����"] = "��� ����, ����� ������ ����, ����� ������ /capture",
		[u8"��� ������ ���"] = "/passive",
		[u8"/statpl"] = "����� ���������� ������, ����, �����, �����, ����� - /statpl",
		[u8"����� ������"] = "/mm -> �������� -> ������� ������",
		[u8"����� �����"] = "/mm -> ������������ �������� -> ��� ����������",
		[u8"��� �������� ������ � ������"] = "/hpanel -> ����1-3 -> �������� -> ������ ����",
		[u8"��� ������ �����"] = "/menu (/mm) - ALT/Y -> �/� -> ������",
		[u8"�� ������� �����"] = "/kill | /tp | /spawn",
		[u8"��� ������� �� �����/����"] = "/join | ���� ������������� �������, ������� �� �����",
		[u8"����������� ���"] = "/dt 0-990 / ����������� ���"
	},
	["HelpSkins"] = {
		[u8"����"] = "65-267, 280-286, 288, 300-304, 306, 307, 309-311",
		[u8"�������"] = "102-104",
		[u8"����"] = "105-107",
		[u8"�����"] = "117-118, 120",
		[u8"������"] = "108-110",
		[u8"��.�����"] = "111-113",
		[u8"�������"] = "114-116",
		[u8"�����"] = "124-127"
	}
}

-- for CHECKBOX
	local checked_test = imgui.ImBool(false)
	local checked_test_2 = imgui.ImBool(false)
--

-- for RADIO
	local checked_radio = imgui.ImInt(1)
--

-- for COMBO
	local combo_select = imgui.ImInt(0)
--

local sw2, sh2 = getScreenResolution()

function set_custom_style()
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
set_custom_style()


function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end

	downloadUrlToFile(update_url, update_path, function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then  
			updateIni = inicfg.load(nil, update_path)
			if tonumber(updateIni.info.version_ans) > script_version_ans then 
				sampAddChatMessage(tag .. "���� ����������! ������: " .. updateIni.info.version_text_ans, -1)
				update_state = true
			end
			os.remove(update_path)
		end
	end)

	------------------ ����� ������� �������, ���� ������ � ������� -------------------------
	sampAddChatMessage("{87CEEB}[AdminTool] {4169E1} ��������� ��������������� ������� ��� ��������", 0xe01df2)
	sampAddChatMessage("{87CEEB}[AdminTool] {4169E1} ��������� ��������� �������!", 0xe01df2)
	------------------ ����� ������� �������, ���� ������ � ������� -------------------------

	-- �������� ID -- 
	_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	nick = sampGetPlayerNickname(id)

	imgui.Process = false
	res = false

	thread = lua_thread.create_suspended(thread_function)

	imgui.SwitchContext()
	themes.SwitchColorTheme()
	-- �������� ����� ���� �� imgui ����.

	--sampAddChatMessage("������ imgui ������������", -1)

	while true do
		wait(0)

		if sampGetCurrentDialogId() ~= 2349 then
			ans_imgui.v = false
			imgui.Process = false
		end
		if sampGetCurrentDialogId() == 2349 then
			ans_imgui.v = true
			imgui.Process = true
		end
	end
end

function color1() -- �������, ����������� ������������� � ����� ���������� ����� � ������� ������������ os.time()
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

function closeAnsWithText(text)
	lua_thread.create(function()
	sampSendDialogResponse(2349, 1, 0)
	sampSendDialogResponse(2350, 1, 0)
	wait(200)
	sampSendDialogResponse(2351, 1, 0, text)
	wait(200)
	sampCloseCurrentDialogWithButton(13)
	main_window_state.v = false
	imgui.Process = false
end)
end


local W_Win = sw2/1.280
local H_Win = 1
function imgui.OnDrawFrame()
    if ans_imgui.v then 

		set_custom_style()

        imgui.SetNextWindowPos(imgui.ImVec2(sw2 / 2, (sh2 / 2) + 320), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(550, 285), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"������ �� �������", ans_imgui)
        local btn_size = imgui.ImVec2(-0.1, 0)

        imgui.Checkbox(u8"��������� � ������", good_game_prefix)
		imgui.BeginChild('##Select Setting', imgui.ImVec2(230, 225), true)

		if imgui.Selectable(u8"���� �����") then ans_report.v = true end

        if imgui.Selectable(u8"������ �� ���-��/����-��", beginchild == 1) then beginchild = 1 end
		if imgui.Selectable(u8"������� �� ��������, /help", beginchild == 2) then beginchild = 2 end
		if imgui.Selectable(u8"������ �� �����/�����", beginchild == 3) then beginchild = 3 end
		if imgui.Selectable(u8"������ �� ������������", beginchild == 4) then beginchild = 4 end
		if imgui.Selectable(u8"������ �� �������/�������", beginchild == 5) then beginchild = 5 end
		if imgui.Selectable(u8"������ �� �������� ����-��", beginchild == 6) then beginchild = 6 end
		if imgui.Selectable(u8"��������� ����������� �������", beginchild == 7) then beginchild = 7 end
		if imgui.Selectable(u8"�����", beginchild == 8) then beginchild = 8 end


		imgui.EndChild()

		imgui.SameLine()


		if ans_report.v then   
			imgui.SetNextWindowPos(imgui.ImVec2(sw2 / 2, (sh2 / 2) - 320), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.SetNextWindowSize(imgui.ImVec2(400, 285), imgui.Cond.FirstUseEver)
				imgui.Begin(u8"����������� ����� � /ans", ans_report)
					imgui.Text(u8"������� ���� �����")

						imgui.InputText(u8"##�����", ans_text)
						imgui.Separator()
						if imgui.Button(u8"��������") then  
								lua_thread.create(function()
								sampSendDialogResponse(2349, 1, 0)
								sampSendDialogResponse(2350, 1, 0)
								wait(200)
								local settext2 = '{FFFFFF}' .. ans_text.v
								sampSendDialogResponse(2351, 1, 0, u8:decode(settext2))	
								sampCloseCurrentDialogWithButton(13)
								ans_report.v = false	
								end)
						end
						imgui.Separator()
						if imgui.Button(u8"�������� �����") then  
							ans_text.v = ""
						end
				imgui.End()
		end

    	if beginchild == 1 then
           imgui.BeginChild("##Reports", imgui.ImVec2(280, 225), true)
         for key, v in pairs(questions) do
			if key == "reporton" then
				for key_2, v_2 in pairs(questions[key]) do
					if imgui.Button(key_2, btn_size) then
						if not good_game_prefix.v then
							lua_thread.create(function()
							local settext = '{FFFFFF}' .. v_2
							sampSendDialogResponse(2349, 1, 0)
							sampSendDialogResponse(2350, 1, 0)
							wait(200)
							sampSendDialogResponse(2351, 1, 0, settext)
							sampCloseCurrentDialogWithButton(13)
							end)
						else
							lua_thread.create(function()
							local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // �������� ���� �� ������� RDS <3'
							sampSendDialogResponse(2349, 1, 0)
							sampSendDialogResponse(2350, 1, 0)
							wait(200)
							sampSendDialogResponse(2351, 1, 0, settext)
							sampCloseCurrentDialogWithButton(13)
							end)
						end
					end
				end
				end
				end
            imgui.EndChild()
			end
			if beginchild == 2 then
				imgui.BeginChild("##HelpCmd", imgui.ImVec2(280, 225), true)
			  	for key, v in pairs(questions) do
					if key == "HelpCmd" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2, btn_size) then
								if not good_game_prefix.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // �������� ���� �� ������� RDS <3'
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
						 	end
					 	end
					end
				end
				imgui.EndChild()
			end
			if beginchild == 3 then
				imgui.BeginChild("##HelpGangFamilyMafia", imgui.ImVec2(280, 225), true)
			  	for key, v in pairs(questions) do
					if key == "HelpGangFamilyMafia" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2, btn_size) then
								if not good_game_prefix.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // �������� ���� �� ������� RDS <3'
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
						 	end
					 	end
					end
				end
				imgui.EndChild()
			end
			if beginchild == 4 then
				imgui.BeginChild("##HelpTP", imgui.ImVec2(280, 225), true)
			  	for key, v in pairs(questions) do
					if key == "HelpTP" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2, btn_size) then
								if not good_game_prefix.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // �������� ���� �� ������� RDS <3'
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
						 	end
					 	end
					end
				end
				imgui.EndChild()
			end
			if beginchild == 5 then
				imgui.BeginChild("##HelpSellBuy", imgui.ImVec2(280, 225), true)
			  	for key, v in pairs(questions) do
					if key == "HelpSellBuy" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2, btn_size) then
								if not good_game_prefix.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // �������� ���� �� ������� RDS <3'
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
						 	end
					 	end
					end
				end
				imgui.EndChild()
			end
			if beginchild == 6 then
				imgui.BeginChild("##HelpGiveEveryone", imgui.ImVec2(280, 225), true)
			  	for key, v in pairs(questions) do
					if key == "HelpGiveEveryone" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2, btn_size) then
								if not good_game_prefix.v then
									lua_thread.create(function()
										local settext = '{FFFFFF}' .. v_2
										sampSendDialogResponse(2349, 1, 0)
										sampSendDialogResponse(2350, 1, 0)
										wait(200)
										sampSendDialogResponse(2351, 1, 0, settext)
										sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // �������� ���� �� ������� RDS <3'
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
						 	end
					 	end
					end
				end
				imgui.EndChild()
			end
			if beginchild == 7 then
				imgui.BeginChild("##HelpDefault", imgui.ImVec2(280, 225), true)
			  	for key, v in pairs(questions) do
					if key == "HelpDefault" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2, btn_size) then
								if not good_game_prefix.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // �������� ���� �� ������� RDS <3'
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
						 	end
					 	end
					end
				end
				imgui.EndChild()
			end
			if beginchild == 8 then
				imgui.BeginChild("##HelpSkins", imgui.ImVec2(280, 225), true)
			  	for key, v in pairs(questions) do
					if key == "HelpSkins" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2, btn_size) then
								if not good_game_prefix.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // �������� ���� �� ������� RDS <3'
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
						 	end
					 	end
					end
				end
				imgui.EndChild()
			end
        imgui.End()
    end
end
