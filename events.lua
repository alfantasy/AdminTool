
-- ## ����������� ���������, �������� � ������� ## --
require 'lib.moonloader'
local encoding = require 'encoding' -- ������ � ����������
local inicfg = require 'inicfg' -- ������ � INI �������
local imgui = require 'imgui' -- MoonImGUI || ���������������� ���������
local atlibs = require 'libsfor' -- ���������� ��� ������ � ��
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

-- ## ���� ���������� ��������� � ��������� � ���������� �������������� � ����������� ������� ## --
local ATMainDirect = "AdminTool\\settings.ini"
local ATMainConfig = inicfg.load({
    main = {
        styleImGUI = 0,
    },
}, ATMainDirect)

local directIni = "AdminTool\\events.ini"

local config = inicfg.load({
    main = {
        auto_tp = false,
    },
}, directIni)
inicfg.save(config, directIni)

function save() 
    inicfg.save(config, directIni)
end

local elements = {
    main = {
        auto_tp = imgui.ImBool(config.main.auto_tp),
    },
}
-- ## ���� ���������� ��������� � ��������� � ���������� �������������� � ����������� ������� ## --

-- ## ���� ���������� ��������� � MoonImGUI ## --

local sw, sh = getScreenResolution()

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
imgui.TextQuestion = require('imgui_addons').TextQuestion
imgui.CenterText = require('imgui_addons').CenterText
imgui.Tooltip = require('imgui_addons').Tooltip

local ATEvent = imgui.ImBool(false)
local menuSelect = 0 
-- ## ���� ���������� ��������� � MoonImGUI ## --

-- ## ����������� ����������� ## --
function showNotification(text)
	notf.addNotify(ntag, text, 2, 1, 6)
end
-- ## ����������� ����������� ## --

function main()
    while not isSampAvailable() do wait(0) end
    
    sampfuncsLog(log .. " ������������� �������, � ������� �������� ����� ����������������� � �������������.")

    sampRegisterChatCommand("amp", function()
        ATEvent.v = not ATEvent.v  
        imgui.Process = ATEvent.v
    end)

    while true do
        wait(0)

        imgui.Process = true
            
    end
end

function imgui.OnDrawFrame()
    if not ATEvent.v then  
        imgui.Process = false  
        imgui.ShowCursor = false  
    end

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

    if ATEvent.v then   

        imgui.SetNextWindowSize(imgui.ImVec2(400, 200), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

        imgui.ShowCursor = true

        imgui.Begin(fai.ICON_FA_NEWSPAPER .. " AT Events", ATEvent, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.MenuBar)
        
        imgui.BeginMenuBar()
            imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
            imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 10)
            if imgui.Button(fai.ICON_FA_MAP_MARKED, imgui.ImVec2(27,0)) then  
                menuSelect = 1
            end
            imgui.PopStyleVar(1)
            imgui.PopStyleVar(1)
        imgui.EndMenuBar()
       
        if menuSelect == 0 then  
            imgui.Text(u8"������ ���� �������� ����� �� ��� ����� ���")
        end

        if menuSelect == 1 then  
            imgui.Text(u8'������ ������ �������� �� �������� �����������.')
        end

        imgui.End()

    end

    -- if EventStream.v then   

    --     imgui.SetNextWindowSize(imgui.ImVec2(400, 200), imgui.Cond.FirstUseEver)
    --     imgui.SetNextWindowPos(imgui.ImVec2(sw / 4, sh / 4), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

    --     imgui.Begin()

    --     imgui.End()
    -- end
end