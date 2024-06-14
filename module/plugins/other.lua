-- ## Регистрация библиотек, плагинов и аддонов ## --
require 'lib.moonloader'
require 'resource.commands'
local inicfg = require 'inicfg' -- работа с ini
local imgui = require('imgui') -- интерфейс ImGUI
local sampev = require "lib.samp.events" -- подключение основных библиотек, связанные с потокам пакетов ивентов SA:MP, и их прямое соединение с LUA
local atlibs = require 'libsfor' -- библиотека для работы с АТ
local encoding = require 'encoding' -- работа с кодировками
local ffi = require 'ffi' -- работа с кодами GTA:SA
local memory = require 'memory' -- работа с памятью GTA SA
local ffi = require 'ffi' -- интеграция кодов, написанных на C++, специальная структурированная библиотека

local notf_res, notf = pcall(import, 'lib/imgui_notf.lua')  -- плагин уведомлений

local fai = require "fAwesome5" -- работа с иконками Font Awesome 5
local fa = require 'faicons' -- работа с иконками Font Awesome 4
-- ## Регистрация библиотек, плагинов и аддонов ## --

-- ## Блок текстовых переменных ## --
local tag = "{00BFFF} [AT] {FFFFFF}" -- тэг AT
local log = "{00BFFF} [AdminTool-Log] {FFFFFF}" -- тэг лога АТ
local ntag = "{00BFFF} Notf - AdminTool" -- тэг уведомлений АТ
encoding.default = 'CP1251' -- смена кодировки на CP1251
u8 = encoding.UTF8 -- переименовка стандтартного режима кодировки UTF8 - u8
-- ## Блок текстовых переменных ## --

-- ## Регистрация уведомлений ## --
function showNotification(text)
	notf.addNotify(ntag, text, 2, 1, 6)
end
-- ## Регистрация уведомлений ## --

-- ## Вводим переменные с помощью FFI для работы с InputHelper ## --
ffi.cdef[[
	short GetKeyState(int nVirtKey);
	bool GetKeyboardLayoutNameA(char* pwszKLID);
	int GetLocaleInfoA(int Locale, int LCType, char* lpLCData, int cchData);
]]
local BuffSize = 32
local KeyboardLayoutName = ffi.new("char[?]", BuffSize)
local LocalInfo = ffi.new("char[?]", BuffSize)

chars = {
	["й"] = "q", ["ц"] = "w", ["у"] = "e", ["к"] = "r", ["е"] = "t", ["н"] = "y", ["г"] = "u", ["ш"] = "i", ["щ"] = "o", ["з"] = "p", ["х"] = "[", ["ъ"] = "]", ["ф"] = "a",
	["ы"] = "s", ["в"] = "d", ["а"] = "f", ["п"] = "g", ["р"] = "h", ["о"] = "j", ["л"] = "k", ["д"] = "l", ["ж"] = ";", ["э"] = "'", ["я"] = "z", ["ч"] = "x", ["с"] = "c", ["м"] = "v",
	["и"] = "b", ["т"] = "n", ["ь"] = "m", ["б"] = ",", ["ю"] = ".", ["Й"] = "Q", ["Ц"] = "W", ["У"] = "E", ["К"] = "R", ["Е"] = "T", ["Н"] = "Y", ["Г"] = "U", ["Ш"] = "I",
	["Щ"] = "O", ["З"] = "P", ["Х"] = "{", ["Ъ"] = "}", ["Ф"] = "A", ["Ы"] = "S", ["В"] = "D", ["А"] = "F", ["П"] = "G", ["Р"] = "H", ["О"] = "J", ["Л"] = "K", ["Д"] = "L",
	["Ж"] = ":", ["Э"] = "\"", ["Я"] = "Z", ["Ч"] = "X", ["С"] = "C", ["М"] = "V", ["И"] = "B", ["Т"] = "N", ["Ь"] = "M", ["Б"] = "<", ["Ю"] = ">"
}
-- ## Вводим переменные с помощью FFI для работы с InputHelper ## --

-- ## Переменные C++ (C#) (FFI) для напрямую с переменными GTA:SA. Работа WallHack. Контролирование. ## --
local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280) -- захват позиции костей
local control_wallhack = false
-- ## Переменные C++ (C#) (FFI) для напрямую с переменными GTA:SA. Работа WallHack. Контролирование. ## --

-- ## Блок переменных связанных с конфигами и элементами взаимодействия с параметрами конфига ## --
local directIni = 'AdminTool\\specialsettings.ini'
local config = inicfg.load({
    settings = {
        translate_cmd = false,
        FontInput = 10,
        WallHack = false,
        inf_run = false,
		keysync = false,
		bullettrack = false,
    },
	position = {
		keyposX = 0,
		keyposY = 0,
	},
	bullet = {
        widthRenderLineOne = 1,
        widthRenderLineTwo = 1,
		secondToCloseTwo = 5,
		secondToClose = 5,
        sizeOffPolygon = 1,
        sizeOffPolygonTwo = 1,
        polygonNumber = 1,
        polygonNumberTwo = 1,
        rotationPolygonOne = 10,
        rotationPolygonTwo = 10,
        maxMyLines = 50,
        maxNotMyLines = 50,
		showMyBullet = false,
		cbEndMy = true,
        cbEnd = true,
		staticObjectMy = 2905604013,
        dinamicObjectMy = 9013962961,
        pedPMy = 1862972872,
        carPMy = 6282572962,
        staticObject = 2905604013,
        dinamicObject = 9013962961,
        pedP = 1862972872,
        carP = 6282572962,
	},
}, directIni)
inicfg.save(config, directIni) 

function save() 
    inicfg.save(config, directIni)
end

local elements = {
    boolean = {
        tcmd = imgui.ImBool(config.settings.translate_cmd),
        wh = imgui.ImBool(config.settings.WallHack),
        inf_run = imgui.ImBool(config.settings.inf_run),
		onfkey = imgui.ImBool(config.settings.keysync),
		skey = imgui.ImBool(false),
		bullettrack = imgui.ImBool(config.settings.bullettrack),
    },
    int = {
        FontInput = imgui.ImInt(config.settings.FontInput),
    },
	bullet = {
		showMyBullet = imgui.ImBool(config.bullet.showMyBullet),
		cbEnd = imgui.ImBool(config.bullet.cbEnd),
		cbEndMy = imgui.ImBool(config.bullet.cbEndMy),
		secondToClose = imgui.ImInt(config.bullet.secondToClose),
        secondToCloseTwo = imgui.ImInt(config.bullet.secondToCloseTwo),
        widthRenderLineOne = imgui.ImInt(config.bullet.widthRenderLineOne),
        widthRenderLineTwo = imgui.ImInt(config.bullet.widthRenderLineTwo),
        sizeOffPolygon = imgui.ImInt(config.bullet.sizeOffPolygon),
        sizeOffPolygonTwo = imgui.ImInt(config.bullet.sizeOffPolygonTwo),
        polygonNumber = imgui.ImInt(config.bullet.polygonNumber),
        polygonNumberTwo = imgui.ImInt(config.bullet.polygonNumberTwo),
        rotationPolygonOne = imgui.ImInt(config.bullet.rotationPolygonOne),
        rotationPolygonTwo = imgui.ImInt(config.bullet.rotationPolygonTwo),
        maxMyLines = imgui.ImInt(config.bullet.maxMyLines),
        maxNotMyLines = imgui.ImInt(config.bullet.maxNotMyLines),
	},
}
-- ## Блок переменных связанных с конфигами и элементами взаимодействия с параметрами конфига ## --

-- ## Блок переменных связанных с MoonImGUI ## --
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
imgui.Tooltip = require('imgui_addons').Tooltip

local key_helper = imgui.ImBool(false)
local changePosKey = false
local target = -1
local keys = {
	['onfoot'] = {},
	['vehicle'] = {}
}
-- ## Блок переменных связанных с MoonImGUI ## --

-- ## Блоки переменных взаимосвязанных на BulletTrack ## --
local bulletSyncMy = {lastId = 0, maxLines = elements.bullet.maxMyLines.v}
for i = 1, bulletSyncMy.maxLines do
    bulletSyncMy[i] = { my = {time = 0, t = {x,y,z}, o = {x,y,z}, type = 0, color = 0}}
end

local bulletSync = {lastId = 0, maxLines = elements.bullet.maxNotMyLines.v}
for i = 1, bulletSync.maxLines do
    bulletSync[i] = {other = {time = 0, t = {x,y,z}, o = {x,y,z}, type = 0, color = 0}}
end

local staticObject = imgui.ImFloat4( imgui.ImColor( atlibs.explode_argb(config.bullet.staticObject) ):GetFloat4() )    
local dinamicObject = imgui.ImFloat4( imgui.ImColor( atlibs.explode_argb(config.bullet.dinamicObject) ):GetFloat4() )   
local pedP = imgui.ImFloat4( imgui.ImColor( atlibs.explode_argb(config.bullet.pedP) ):GetFloat4() )   
local carP = imgui.ImFloat4( imgui.ImColor( atlibs.explode_argb(config.bullet.carP) ):GetFloat4() ) 
local staticObjectMy = imgui.ImFloat4( imgui.ImColor( atlibs.explode_argb(config.bullet.staticObjectMy) ):GetFloat4() )    
local dinamicObjectMy = imgui.ImFloat4( imgui.ImColor( atlibs.explode_argb(config.bullet.dinamicObjectMy) ):GetFloat4() )   
local pedPMy = imgui.ImFloat4( imgui.ImColor( atlibs.explode_argb(config.bullet.pedPMy) ):GetFloat4() )   
local carPMy = imgui.ImFloat4( imgui.ImColor( atlibs.explode_argb(config.bullet.carPMy) ):GetFloat4() )  
-- ## Блоки переменных взаимосвязанных на BulletTrack ## --

-- ## Ивенты SA:MP, перехват пакетов синхронизации клавиш onPlayerSync и onVehicleSync ## --
function sampev.onSendBulletSync(data)
    if elements.bullet.showMyBullet.v and elements.boolean.bullettrack.v then  
        if data.center.x ~= 0 then
            if data.center.y ~= 0 then
                if data.center.z ~= 0 then
                    bulletSyncMy.lastId = bulletSyncMy.lastId + 1
                    if bulletSyncMy.lastId < 1 or bulletSyncMy.lastId > bulletSyncMy.maxLines then
                        bulletSyncMy.lastId = 1
                    end
                    bulletSyncMy[bulletSyncMy.lastId].my.time = os.time() + elements.bullet.secondToCloseTwo.v
                    bulletSyncMy[bulletSyncMy.lastId].my.o.x, bulletSyncMy[bulletSyncMy.lastId].my.o.y, bulletSyncMy[bulletSyncMy.lastId].my.o.z = data.origin.x, data.origin.y, data.origin.z
                    bulletSyncMy[bulletSyncMy.lastId].my.t.x, bulletSyncMy[bulletSyncMy.lastId].my.t.y, bulletSyncMy[bulletSyncMy.lastId].my.t.z = data.target.x, data.target.y, data.target.z
                    if data.targetType == 0 then
                        bulletSyncMy[bulletSyncMy.lastId].my.color = atlibs.join_argb(255, staticObjectMy.v[1]*255, staticObjectMy.v[2]*255, staticObjectMy.v[3]*255)
                    elseif data.targetType == 1 then
                        bulletSyncMy[bulletSyncMy.lastId].my.color = atlibs.join_argb(255, pedPMy.v[1]*255, pedPMy.v[2]*255, pedPMy.v[3]*255)
                    elseif data.targetType == 2 then
                        bulletSyncMy[bulletSyncMy.lastId].my.color = atlibs.join_argb(255, carPMy.v[1]*255, carPMy.v[2]*255, carPMy.v[3]*255)
                    elseif data.targetType == 3 then
                        bulletSyncMy[bulletSyncMy.lastId].my.color = atlibs.join_argb(255, dinamicObjectMy.v[1]*255, dinamicObjectMy.v[2]*255, dinamicObjectMy.v[3]*255)
                    end
                end
            end 
        end
    end
end 

function sampev.onBulletSync(playerid, data)
    if elements.boolean.bullettrack.v then
        if data.center.x ~= 0 then
            if data.center.y ~= 0 then
                if data.center.z ~= 0 then
                    bulletSync.lastId = bulletSync.lastId + 1
                    if bulletSync.lastId < 1 or bulletSync.lastId > bulletSync.maxLines then
                        bulletSync.lastId = 1
                    end
                    bulletSync[bulletSync.lastId].other.time = os.time() + elements.bullet.secondToClose.v
                    bulletSync[bulletSync.lastId].other.o.x, bulletSync[bulletSync.lastId].other.o.y, bulletSync[bulletSync.lastId].other.o.z = data.origin.x, data.origin.y, data.origin.z
                    bulletSync[bulletSync.lastId].other.t.x, bulletSync[bulletSync.lastId].other.t.y, bulletSync[bulletSync.lastId].other.t.z = data.target.x, data.target.y, data.target.z
                    if data.targetType == 0 then
                        bulletSync[bulletSync.lastId].other.color = atlibs.join_argb(255, staticObject.v[1]*255, staticObject.v[2]*255, staticObject.v[3]*255)
                    elseif data.targetType == 1 then
                        bulletSync[bulletSync.lastId].other.color = atlibs.join_argb(255, pedP.v[1]*255, pedP.v[2]*255, pedP.v[3]*255)
                    elseif data.targetType == 2 then
                        bulletSync[bulletSync.lastId].other.color = atlibs.join_argb(255, carP.v[1]*255, carP.v[2]*255, carP.v[3]*255)
                    elseif data.targetType == 3 then
                        bulletSync[bulletSync.lastId].other.color = atlibs.join_argb(255, dinamicObject.v[1]*255, dinamicObject.v[2]*255, dinamicObject.v[3]*255)
                    end
                end
            end
        end
    end
end

function sampev.onPlayerSync(playerId, data)
	local result, id = sampGetPlayerIdByCharHandle(target)
	if result and id == playerId then
		keys["onfoot"] = {}

		keys["onfoot"]["W"] = (data.upDownKeys == 65408) or nil
		keys["onfoot"]["A"] = (data.leftRightKeys == 65408) or nil
		keys["onfoot"]["S"] = (data.upDownKeys == 00128) or nil
		keys["onfoot"]["D"] = (data.leftRightKeys == 00128) or nil
        keys["onfoot"]["R"] = (bit.band(data.keysData, 82) == 82) or nil

		keys["onfoot"]["Alt"] = (bit.band(data.keysData, 1024) == 1024) or nil
		keys["onfoot"]["Shift"] = (bit.band(data.keysData, 8) == 8) or nil
		keys["onfoot"]["Tab"] = (bit.band(data.keysData, 1) == 1) or nil
		keys["onfoot"]["Space"] = (bit.band(data.keysData, 32) == 32) or nil
		keys["onfoot"]["F"] = (bit.band(data.keysData, 16) == 16) or nil
		keys["onfoot"]["C"] = (bit.band(data.keysData, 2) == 2) or nil
        keys["onfoot"]["R"] = (bit.band(data.keysData, 82) == 82) or nil

		keys["onfoot"]["RKM"] = (bit.band(data.keysData, 4) == 4) or nil
		keys["onfoot"]["LKM"] = (bit.band(data.keysData, 128) == 128) or nil
	end
end

function sampev.onVehicleSync(playerId, vehicleId, data)
	local result, id = sampGetPlayerIdByCharHandle(target)
	if result and id == playerId then
		keys["vehicle"] = {}

		keys["vehicle"]["W"] = (bit.band(data.keysData, 8) == 8) or nil
		keys["vehicle"]["A"] = (data.leftRightKeys == 65408) or nil
		keys["vehicle"]["S"] = (bit.band(data.keysData, 32) == 32) or nil
		keys["vehicle"]["D"] = (data.leftRightKeys == 00128) or nil

		keys["vehicle"]["H"] = (bit.band(data.keysData, 2) == 2) or nil
        keys["onfoot"]["Shift"] = (bit.band(data.keysData, 8) == 8) or nil
		keys["vehicle"]["Space"] = (bit.band(data.keysData, 128) == 128) or nil
		keys["vehicle"]["Ctrl"] = (bit.band(data.keysData, 1) == 1) or nil
		keys["vehicle"]["Alt"] = (bit.band(data.keysData, 4) == 4) or nil
		keys["vehicle"]["Q"] = (bit.band(data.keysData, 256) == 256) or nil
		keys["vehicle"]["E"] = (bit.band(data.keysData, 64) == 64) or nil
		keys["vehicle"]["F"] = (bit.band(data.keysData, 16) == 16) or nil

		keys["vehicle"]["Up"] = (data.upDownKeys == 65408) or nil
		keys["vehicle"]["Down"] = (data.upDownKeys == 00128) or nil
	end
end

-- ## Ивенты SA:MP, перехват пакетов синхронизации клавиш onPlayerSync и onVehicleSync ## --

function main()
    while not isSampAvailable() do wait(0) end
    
    inputHelpText = renderCreateFont("Arial", tonumber(elements.int.FontInput.v), FCR_BORDER + FCR_BOLD) -- инициализация шрифта
    lua_thread.create(showInputHelper) -- рендер InputHelper
    lua_thread.create(translateCommands) -- фрейм переводчика команд
	wallhack_thread = lua_thread.create(drawWallhack) -- фрейм "Просмотр через стены", иначе WallHack
	sampRegisterChatCommand("wh", cmd_wh) -- регистрируемая команда для WH
	sampRegisterChatCommand('keysync', function(playerId)
		if elements.boolean.onfkey.v then 
			if playerId == 'off' then  
				sampAddChatMessage(tag .. 'Синхронизация клавиш отключена.', -1)
				target = -1 
				elements.boolean.skey.v = false  
				return  
			else 
				playerId = tonumber(playerId)
				if playerId ~= nil then
					local pedExist, ped = sampGetCharHandleBySampPlayerId(playerId)
					if pedExist then  
						sampAddChatMessage(tag .. 'Синхронизация клавиш для игрока с ID: ' .. ped .. ' активирована', -1)
						target = ped  
						elements.boolean.skey.v = true  
						imgui.Process = true  
						return true  
					end 
					return  
				else 
					sampAddChatMessage(tag .. 'Игрок не в сети/не в зоне стриминга. Не могу активироваться.', -1)
				end  
			end
		end
	end)

    sampfuncsLog(log .. " Инициализация сторонней плагиновой системы. Внимание! \nДля полноценной работоспособности, проверьте загруженность основного скрипта. \n       Иначе инициализации всего пакета АТ - не будет. \n       Исключение: внешняя подгрузка плагиновой системы через AdminTool-Load")

    while true do
        wait(0)

		imgui.Process = true

		if not elements.boolean.skey.v then  
			elements.boolean.skey.v = false  
			if not key_helper.v then  
				imgui.ShowCursor = false  
				imgui.Process = false  
			end 
		end

		change_pos_keysync()

        if sampIsChatInputActive() then
			if sampGetChatInputText():find("/") == 1 then
				key_helper.v = true
				imgui.Process = true
				if sampGetChatInputText():match("/(.+)") ~= nil then
					check_cmd_punis = sampGetChatInputText():match("/(.+)")
				else
					check_cmd_punis = nil
				end
			elseif sampGetChatInputText():find("/(.+)%(%D+)") == 1 then  
				key_helper.v = false
                --imgui.Process = false 
			end
		else
			key_helper.v = false
		end

		local oTime = os.time()

		if elements.boolean.bullettrack.v then
            for i = 1, bulletSync.maxLines do
                if bulletSync[i].other.time >= oTime then
                    local result, wX, wY, wZ, wW, wH = convert3DCoordsToScreenEx(bulletSync[i].other.o.x, bulletSync[i].other.o.y, bulletSync[i].other.o.z, true, true)
                    local resulti, pX, pY, pZ, pW, pH = convert3DCoordsToScreenEx(bulletSync[i].other.t.x, bulletSync[i].other.t.y, bulletSync[i].other.t.z, true, true)
                    if result and resulti then
                        local xResolution = memory.getuint32(0x00C17044)
                        if wZ < 1 then
                            wX = xResolution - wX
                        end
                        if pZ < 1 then
                            pZ = xResolution - pZ
                        end 
                        renderDrawLine(wX, wY, pX, pY, elements.bullet.widthRenderLineOne.v, bulletSync[i].other.color)
                        if elements.bullet.cbEnd.v then
                            renderDrawPolygon(pX, pY-1, 3 + elements.bullet.sizeOffPolygonTwo.v, 3 + elements.bullet.sizeOffPolygonTwo.v, 1 + elements.bullet.polygonNumberTwo.v, elements.bullet.rotationPolygonTwo.v, bulletSync[i].other.color)
                        end
                    end
                end
            end
        end
        if elements.bullet.showMyBullet.v then
            for i = 1, bulletSyncMy.maxLines do
                if bulletSyncMy[i].my.time >= oTime then
                    local result, wX, wY, wZ, wW, wH = convert3DCoordsToScreenEx(bulletSyncMy[i].my.o.x, bulletSyncMy[i].my.o.y, bulletSyncMy[i].my.o.z, true, true)
                    local resulti, pX, pY, pZ, pW, pH = convert3DCoordsToScreenEx(bulletSyncMy[i].my.t.x, bulletSyncMy[i].my.t.y, bulletSyncMy[i].my.t.z, true, true)
                    if result and resulti then
                        local xResolution = memory.getuint32(0x00C17044)
                        if wZ < 1 then
                            wX = xResolution - wX
                        end
                        if pZ < 1 then
                            pZ = xResolution - pZ
                        end 
                        renderDrawLine(wX, wY, pX, pY, elements.bullet.widthRenderLineTwo.v, bulletSyncMy[i].my.color)
                        if elements.bullet.cbEndMy.v then
                            renderDrawPolygon(pX, pY-1, 3 + elements.bullet.sizeOffPolygon.v, 3 + elements.bullet.sizeOffPolygon.v, 1 + elements.bullet.polygonNumber.v, elements.bullet.rotationPolygonOne.v, bulletSyncMy[i].my.color)
                        end
                    end
                end
            end
        end 

		memory.setint8(0xB7CEE4, 1)
        
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

-- ## Функции, предназначенные для KeySync ## --
function EXPORTS.ActivateKeySync(playerId) 
	if elements.boolean.onfkey.v then
		if playerId == "off" then  
			target = -1
			elements.boolean.skey.v = false  
			return  
		else 
			playerId = tonumber(playerId)
			if playerId ~= nil then  
				local pedExist, ped = sampGetCharHandleBySampPlayerId(playerId)
				if pedExist then  
					target = ped  
					elements.boolean.skey.v = true  
					imgui.Process = true  
					return true  
				end 
				return  
			end  
		end 
	end
end

function change_pos_keysync()
    if changePosKey then
        if elements.boolean.skey.v then  
            config.position.keyposX, config.position.keyposY = getCursorPos()
            if isKeyJustPressed(49) then  
                showNotification("Успешно сохранено")
                changePosKey = false 
                save()
                if target == -1 then  
                    elements.boolean.skey.v = false 
                    imgui.ShowCursor = false
                end    
            end 
        else
            elements.boolean.skey.v = true 
        end
    end
end  

function EXPORTS.KeySyncToggle()
	imgui.Text(fa.ICON_FA_KEYBOARD .. u8" Синхр.клавы"); imgui.Tooltip(u8'Показывает небольшое окошко с захватом нажимаемых клавиш игроком')
	imgui.SameLine()
	if imgui.ToggleButton('##KeySync', elements.boolean.onfkey) then  
		config.settings.keysync = elements.boolean.onfkey.v  
		save()  
	end 
	imgui.SameLine()
	if imgui.Button(fa.ICON_FA_COGS .. "##ChangePositionKeySync") then  
		changePosKey = true  
		sampAddChatMessage(tag .. ' Активация изменения позиции KeySync. Сохранение на клавишу <1>')
	end; imgui.Tooltip(u8'Изменение позиции KeySync.')
end
-- ## Функции, предназначенные для KeySync ## --

-- ## Функции, исключительно предназначенные для WallHack ## --
function nameTagOn()
	local pStSet = sampGetServerSettingsPtr();
	NTdist = memory.getfloat(pStSet + 39)
	NTwalls = memory.getint8(pStSet + 47)
	NTshow = memory.getint8(pStSet + 56)
	memory.setfloat(pStSet + 39, 1488.0)
	memory.setint8(pStSet + 47, 0)
	memory.setint8(pStSet + 56, 1)
	nameTag = true
end
function nameTagOff()
	local pStSet = sampGetServerSettingsPtr();
	memory.setfloat(pStSet + 39, NTdist)
	memory.setint8(pStSet + 47, NTwalls)
	memory.setint8(pStSet + 56, NTshow)
	nameTag = false
end

function cmd_wh()
    if control_wallhack then 
        showNotification("Выключен WallHack")
		nameTagOff()
        control_wallhack = false 
        elements.boolean.wh.v = false
		config.settings.WallHack = elements.boolean.wh.v  
		save()
    else 
        showNotification("Включен WallHack")
        nameTagOn()
        elements.boolean.wh.v = true
        control_wallhack = true
		config.settings.WallHack = elements.boolean.wh.v  
		save()
    end	 
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
		wait(0)
		for i = 0, sampGetMaxPlayerId() do
			if sampIsPlayerConnected(i) and (elements.boolean.wh.v or control_wallhack) then
				local result, cped = sampGetCharHandleBySampPlayerId(i)
				local color = sampGetPlayerColor(i)
				local aa, rr, gg, bb = atlibs.explode_argb(color)
				local color = atlibs.join_argb(255, rr, gg, bb)
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

-- ## Функции, исключительно предназначенные для WallHack ## --

-- ## Функции, предназначенные исключительно для InputHelper ## --
function translite(text)
	for k, v in pairs(chars) do
		text = string.gsub(text, k, v)
	end
	return text
end

function getStrByState(keyState)
	if keyState == 0 then
		return "{ffeeaa}Выкл{ffffff}"
	end
	return "{9EC73D}Вкл{ffffff}"
end

function showInputHelper()
    while true do  
        local chat = sampIsChatInputActive()
        if chat then  
			local in1 = sampGetInputInfoPtr()
			local in1 = getStructElement(in1, 0x8, 4)
			local in2 = getStructElement(in1, 0x8, 4)
			local in3 = getStructElement(in1, 0xC, 4)
			fib = in3 + 41
			fib2 = in2 + 10
			local _, pID = sampGetPlayerIdByCharHandle(playerPed)
			local name = sampGetPlayerNickname(pID)
			local color = sampGetPlayerColor(pID)
			local capsState = ffi.C.GetKeyState(20)
			local success = ffi.C.GetKeyboardLayoutNameA(KeyboardLayoutName)
			local errorCode = ffi.C.GetLocaleInfoA(tonumber(ffi.string(KeyboardLayoutName), 16), 0x00000002, LocalInfo, BuffSize)
			local localName = ffi.string(LocalInfo)
			local text = string.format(
				"%s :: {%0.6x}%s[%d] {ffffff}:: Капс: %s {FFFFFF}:: Язык: {ffeeaa}%s{ffffff}",
				os.date("%H:%M:%S"), bit.band(color,0xffffff), name, pID, getStrByState(capsState), string.match(localName, "([^%(]*)")
			)
			renderFontDrawText(inputHelpText, text, fib2, fib, 0xD7FFFFFF)
        end
        wait(0)
    end  
end

function translateCommands()
    while true do
        if(sampIsChatInputActive()) and elements.boolean.tcmd.v then
            local getInput = sampGetChatInputText()
            if(oldText ~= getInput and #getInput > 0)then
                local firstChar = string.sub(getInput, 1, 1)
                if(firstChar == "." or firstChar == "/")then
                    local cmd, text = string.match(getInput, "^([^ ]+)(.*)")
                    local nText = "/" .. translite(string.sub(cmd, 2)) .. text
                    local chatInfoPtr = sampGetInputInfoPtr()
                    local chatBoxInfo = getStructElement(chatInfoPtr, 0x8, 4)
                    local lastPos = memory.getint8(chatBoxInfo + 0x11E)
                    sampSetChatInputText(nText)
                    memory.setint8(chatBoxInfo + 0x11E, lastPos)
                    memory.setint8(chatBoxInfo + 0x119, lastPos)
                    oldText = nText
                end
            end
        end
        wait(0)
    end
end
-- ## Функции, предназначенные исключительно для InputHelper ## --

-- ## Эскортируемые функции для основного скрипта ## --
function EXPORTS.TranslateCmd()
    imgui.Text(fai.ICON_FA_LANGUAGE .. u8' Перевод команд'); imgui.Tooltip(u8'Если Вы забыли сменить язык, АТ подкорректирует вводимую команду автоматически.')
    imgui.SameLine()
    if imgui.ToggleButton('##TsCommand', elements.boolean.tcmd) then  
        config.settings.translate_cmd = elements.boolean.tcmd.v  
        save()  
    end
end

function EXPORTS.ChangeFontHelp()
    imgui.PushItemWidth(200)
    if imgui.InputInt('##ChangeFontHelp', elements.int.FontInput) then 
        inputHelpText = renderCreateFont("Arial", tonumber(elements.int.FontInput.v), FCR_BORDER + FCR_BOLD)
        config.settings.FontInput = elements.int.FontInput.v
        save()
    end; imgui.PopItemWidth(); imgui.SameLine(); imgui.Text(u8" - Редакция размера шрифта для InputHelper"); imgui.Tooltip(u8"InputHelper - вспомогательная строчка под вводом чата.")
end

function EXPORTS.ActiveWallHack()
	if control_wallhack then 
        showNotification("Выключен WallHack")
		nameTagOff()
        control_wallhack = false 
        elements.boolean.wh.v = false
    else 
        showNotification("Включен WallHack")
        nameTagOn()
        elements.boolean.wh.v = true
        control_wallhack = true
    end	 
end

function EXPORTS.ActiveGUIWH()
	imgui.Text(fai.ICON_FA_USER_TAG .. ' WallHack'); imgui.Tooltip(u8'Активация WallHack. Также есть команда /wh')
	imgui.SameLine()
	if imgui.ToggleButton('##WallHack', elements.boolean.wh) then  
		config.settings.WallHack = elements.boolean.wh.v  
		save()
		if control_wallhack then 
			showNotification("Выключен WallHack")
			nameTagOff()
			control_wallhack = false 
			elements.boolean.wh.v = false
		else 
			showNotification("Включен WallHack")
			nameTagOn()
			elements.boolean.wh.v = true
			control_wallhack = true
		end	 
	end
end

function EXPORTS.OffScript()
    thisScript():unload()
end

function EXPORTS.ActivatedBulletTrack()
    imgui.Text(fa.ICON_FA_CROSSHAIRS .. u8" Трейсера пуль")
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 350)
    if imgui.ToggleButton('##Tracers', elements.boolean.bullettrack) then 
        config.settings.bullettrack = elements.boolean.bullettrack.v
        save()
    end
    imgui.Separator()
    imgui.Text("")
    if imgui.Checkbox(u8"Отображать/Не отображать свои пули", elements.bullet.showMyBullet) then
        config.bullet.showMyBullet = elements.bullet.showMyBullet.v
        save()
    end 
    imgui.Separator()
    if elements.bullet.showMyBullet.v then
        if imgui.CollapsingHeader(u8"Настроить трейсер своих пуль") then


            imgui.Separator()
            imgui.PushItemWidth(175)
            if imgui.SliderInt("##bulletsMyTime", elements.bullet.secondToCloseTwo, 5, 15) then
                config.bullet.secondToCloseTwo = elements.bullet.secondToCloseTwo.v
                save()
            end imgui.SameLine() imgui.Text(u8"Время задержки трейсера")
            if imgui.SliderInt("##renderWidthLinesTwo", elements.bullet.widthRenderLineTwo, 1, 10) then
                config.bullet.widthRenderLineTwo = elements.bullet.widthRenderLineTwo.v
                save()
            end imgui.SameLine() imgui.Text(u8"Толщина линий")
            if imgui.SliderInt('##maxMyBullets', elements.bullet.maxMyLines, 10, 300) then
                bulletSyncMy.maxLines = elements.bullet.maxMyLines.v
                bulletSyncMy = {lastId = 0, maxLines = elements.bullet.maxMyLines.v}
                for i = 1, bulletSyncMy.maxLines do
                    bulletSyncMy[i] = { my = {time = 0, t = {x,y,z}, o = {x,y,z}, type = 0, color = 0}}
                end
                config.bullet.maxMyLines = elements.bullet.maxMyLines.v
                save()
            end imgui.SameLine() imgui.Text(u8"Максимальное количество линий")

            imgui.Separator()

            if imgui.Checkbox(u8"[Вкл/выкл] Окончания у трейсеров##1", elements.bullet.cbEndMy) then
                config.bullet.cbEndMy = elements.bullet.cbEndMy.v
                save()
            end

            if imgui.SliderInt('##sizeTraicerEnd', elements.bullet.sizeOffPolygon, 1, 10) then
                config.bullet.sizeOffPolygon = elements.bullet.sizeOffPolygon.v
                save()
            end  imgui.SameLine() imgui.Text(u8"Размер окончания трейсера")
            if imgui.SliderInt('##endNumbers', elements.bullet.polygonNumber, 2, 10) then
                config.bullet.polygonNumber = elements.bullet.polygonNumber.v 
                save()
            end imgui.SameLine() imgui.Text(u8"Количество углов на окончаниях")
            if imgui.SliderInt('##rotationOne', elements.bullet.rotationPolygonOne, 0, 360) then
                config.bullet.rotationPolygonOne = elements.bullet.rotationPolygonOne.v
                save()
            end imgui.SameLine() imgui.Text(u8"Градус поворота окончания")


            imgui.PopItemWidth()
            imgui.Separator()
            imgui.Text(u8"Укажите цвет трейсера, если вы попали в:")
            imgui.PushItemWidth(325)
            if imgui.ColorEdit4("##dinamicObjectMy", dinamicObjectMy) then
                config.bullet.dinamicObjectMy = atlibs.join_argb(dinamicObjectMy.v[1] * 255, dinamicObjectMy.v[2] * 255, dinamicObjectMy.v[3] * 255, dinamicObjectMy.v[4] * 255)
                save()
            end imgui.SameLine() imgui.Text(u8"Динамический объект")
            if imgui.ColorEdit4("##staticObjectMy", staticObjectMy) then
                config.bullet.staticObjectMy = atlibs.join_argb(staticObjectMy.v[1] * 255, staticObjectMy.v[2] * 255, staticObjectMy.v[3] * 255, staticObjectMy.v[4] * 255)
                save()
            end imgui.SameLine() imgui.Text(u8"Статический объект")
            if imgui.ColorEdit4("##pedMy", pedPMy) then
                config.bullet.pedPMy = atlibs.join_argb(pedPMy.v[1] * 255, pedPMy.v[2] * 255, pedPMy.v[3] * 255, pedPMy.v[4] * 255)
                save()
            end imgui.SameLine() imgui.Text(u8"Игрока")
            if imgui.ColorEdit4("##carMy", carPMy) then
                config.bullet.carPMy = atlibs.join_argb(carPMy.v[1] * 255, carPMy.v[2] * 255, carPMy.v[3] * 255, carPMy.v[4] * 255)
                save()
            end imgui.SameLine() imgui.Text(u8"Машину")
            imgui.PopItemWidth()
            imgui.Separator()
        end
    end 
    if imgui.CollapsingHeader(u8"Настроить трейсер чужих пуль") then
        imgui.Separator()
        imgui.PushItemWidth(175)
        if imgui.SliderInt("##secondsBullets", elements.bullet.secondToClose, 5, 15) then
            config.bullet.secondToClose = elements.bullet.secondToClose.v
            save()
        end imgui.SameLine() imgui.Text(u8"Время задержки трейсера")
        if imgui.SliderInt("##renderWidthLinesOne", elements.bullet.widthRenderLineOne, 1, 10) then
            config.bullet.widthRenderLineOne = elements.bullet.widthRenderLineOne.v
            save()
        end imgui.SameLine() imgui.Text(u8"Толщина линий")
        if imgui.SliderInt('##numberNotMyBullet', elements.bullet.maxNotMyLines, 10, 300) then
            bulletSync.maxNotMyLines = elements.bullet.maxNotMyLines.v
            bulletSync = {lastId = 0, maxLines = elements.bullet.maxNotMyLines.v}
            for i = 1, bulletSync.maxLines do
                bulletSync[i] = { other = {time = 0, t = {x,y,z}, o = {x,y,z}, type = 0, color = 0}}
            end
            config.bullet.maxNotMyLines = elements.bullet.maxNotMyLines.v
            save()
        end imgui.SameLine() imgui.Text(u8"Максимальное количество линий")

        imgui.Separator()

        if imgui.Checkbox(u8"[Вкл/выкл] Окончания у трейсеров##2", elements.bullet.cbEnd) then
            config.bullet.cbEnd = elements.bullet.cbEnd.v
            save()
        end

        if imgui.SliderInt('##sizeTraicerEndTwo', elements.bullet.sizeOffPolygonTwo, 1, 10) then
            config.bullet.sizeOffPolygonTwo = elements.bullet.sizeOffPolygonTwo.v
            save()
        end imgui.SameLine() imgui.Text(u8"Размер окончания трейсера")

        if imgui.SliderInt('##endNumbersTwo', elements.bullet.polygonNumberTwo, 2, 10) then
            config.bullet.polygonNumberTwo = elements.bullet.polygonNumberTwo.v 
            save()
        end imgui.SameLine() imgui.Text(u8"Количество углов на окончаниях")

        if imgui.SliderInt('##rotationTwo', elements.bullet.rotationPolygonTwo, 0, 360) then
            config.bullet.rotationPolygonTwo = elements.bullet.rotationPolygonTwo.v
            save() 
        end imgui.SameLine() imgui.Text(u8"Градус поворота окончания")

        imgui.PopItemWidth()
        imgui.Separator()
        imgui.Text(u8"Укажите цвет трейсера, если игрок попал в: ")
        imgui.PushItemWidth(325)
        if imgui.ColorEdit4("##dinamicObject", dinamicObject) then
            config.bullet.dinamicObject = atlibs.join_argb(dinamicObject.v[1] * 255, dinamicObject.v[2] * 255, dinamicObject.v[3] * 255, dinamicObject.v[4] * 255)
            save()
        end imgui.SameLine() imgui.Text(u8"Динамический объект")
        if imgui.ColorEdit4("##staticObject", staticObject) then
            config.bullet.staticObject = atlibs.join_argb(staticObject.v[1] * 255, staticObject.v[2] * 255, staticObject.v[3] * 255, staticObject.v[4] * 255)
            save()
        end imgui.SameLine() imgui.Text(u8"Статический объект")
        if imgui.ColorEdit4("##ped", pedP) then
            config.bullet.pedP = atlibs.join_argb(pedP.v[1] * 255, pedP.v[2] * 255, pedP.v[3] * 255, pedP.v[4] * 255)
            save()
        end imgui.SameLine() imgui.Text(u8"Игрока")
        if imgui.ColorEdit4("##car", carP) then
            config.bullet.carP = atlibs.join_argb(carP.v[1] * 255, carP.v[2] * 255, carP.v[3] * 255, carP.v[4] * 255)
            save()
        end imgui.SameLine() imgui.Text(u8"Машину")
        imgui.PopItemWidth()
        imgui.Separator()
    end 
end       
-- ## Эскортируемые функции для основного скрипта ## --

function imgui.OnDrawFrame()
	if elements.boolean.skey.v then  
		imgui.ShowCursor = false  

		imgui.SetNextWindowPos(imgui.ImVec2(config.position.keyposX, config.position.keyposY), imgui.Cond.Always, imgui.ImVec2(1, 1))
		imgui.Begin('##KeyingSync', nil, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar)
			if doesCharExist(target) then  
				local plState = (isCharOnFoot(target) and 'onfoot' or 'vehicle')

				imgui.BeginGroup()
					imgui.SetCursorPosX(10 + 30 + 44)
					KeyCap('W', (keys[plState]['W'] ~= nil), imgui.ImVec2(30,30))
					KeyCap("Tab", (keys[plState]["Tab"] ~= nil), imgui.ImVec2(30,30)); imgui.SameLine()
					KeyCap("A", (keys[plState]["A"] ~= nil), imgui.ImVec2(30, 30)); imgui.SameLine()
					KeyCap("S", (keys[plState]["S"] ~= nil), imgui.ImVec2(30, 30)); imgui.SameLine()
					KeyCap("D", (keys[plState]["D"] ~= nil), imgui.ImVec2(30, 30))
				imgui.EndGroup()
				imgui.SameLine(nil, 20)				
				
				if plState == "onfoot" then
					imgui.BeginGroup()
						KeyCap("Shift", (keys[plState]["Shift"] ~= nil), imgui.ImVec2(75, 30)); imgui.SameLine()
						KeyCap("Alt", (keys[plState]["Alt"] ~= nil), imgui.ImVec2(55, 30))
						KeyCap("Space", (keys[plState]["Space"] ~= nil), imgui.ImVec2(135, 30))
					imgui.EndGroup()
					imgui.SameLine()
					imgui.BeginGroup()
						KeyCap("C", (keys[plState]["C"] ~= nil), imgui.ImVec2(30, 30)); imgui.SameLine()
						KeyCap("F", (keys[plState]["F"] ~= nil), imgui.ImVec2(30, 30)); imgui.SameLine()
                        KeyCap("RM", (keys[plState]["RKM"] ~= nil), imgui.ImVec2(30, 30))
                        KeyCap("E", (keys[plState]["E"] ~= nil), imgui.ImVec2(30, 30)); imgui.SameLine()
                        KeyCap("Q", (keys[plState]["Q"] ~= nil), imgui.ImVec2(30, 30)); imgui.SameLine()
                        
						KeyCap("LM", (keys[plState]["LKM"] ~= nil), imgui.ImVec2(30, 30)); imgui.SameLine()
                        KeyCap("R", (keys[plState]["R"] ~= nil), imgui.ImVec2(30,30))	
					imgui.EndGroup()
				else
					imgui.BeginGroup()
                        KeyCap("Shift", (keys[plState]["Shift"] ~= nil), imgui.ImVec2(75,30)); imgui.SameLine()
						KeyCap("Ctrl", (keys[plState]["Ctrl"] ~= nil), imgui.ImVec2(65, 30)); imgui.SameLine()
						KeyCap("Alt", (keys[plState]["Alt"] ~= nil), imgui.ImVec2(65, 30))
						KeyCap("Space", (keys[plState]["Space"] ~= nil), imgui.ImVec2(210, 30))
					imgui.EndGroup()
					imgui.SameLine()
					imgui.BeginGroup()
						KeyCap("Up", (keys[plState]["Up"] ~= nil), imgui.ImVec2(40, 30))
						KeyCap("Down", (keys[plState]["Down"] ~= nil), imgui.ImVec2(40, 30))	
					imgui.EndGroup()
					imgui.SameLine()
					imgui.BeginGroup()
						KeyCap("H", (keys[plState]["H"] ~= nil), imgui.ImVec2(30, 30)); imgui.SameLine()
						KeyCap("F", (keys[plState]["F"] ~= nil), imgui.ImVec2(30, 30))
						KeyCap("Q", (keys[plState]["Q"] ~= nil), imgui.ImVec2(30, 30)); imgui.SameLine()
                        KeyCap("R", (keys[plState]["R"] ~= nil), imgui.ImVec2(30,30)); imgui.SameLine()
						KeyCap("E", (keys[plState]["E"] ~= nil), imgui.ImVec2(30, 30))
					imgui.EndGroup()
				end
			else 
				imgui.Text(u8'Игрок не захвачен AT. Скрипт сбросил значения.\nПопробуйте "Обновить" в Реконе.\n\nЕсли Вы находитесь в режиме изменения позиции - проигнорируйте.')
			end 
		imgui.End()
	end			
	
	if key_helper.v then  
		local in1 = sampGetInputInfoPtr()
		local in1 = getStructElement(in1, 0x8, 4)
		local in2 = getStructElement(in1, 0x8, 4)
		local in3 = getStructElement(in1, 0xC, 4)
		fib = in3 + 50
		fib2 = in2 + 10
		imgui.SetNextWindowPos(imgui.ImVec2(fib2, fib), imgui.Cond.FirstUseEver, imgui.ImVec2(0, -0.1))
		imgui.SetNextWindowSize(imgui.ImVec2(590, 120), imgui.Cond.FirstUseEver)
		imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.09, 0.09, 0.09, 0.80))
		imgui.Begin("##HelperCommands", key_helper, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse)
			if check_cmd_punis ~= nil then
				for key, v in pairs(cmd_massive) do  
					if key:find(string.lower(check_cmd_punis), 1, true) ~= nil or key == string.lower(check_cmd_punis):match("(.+) (.+)") or key == string.lower(check_cmd_punis):match("(.+)") then
						if cmd_massive[key].cmd == '/mute' then  
							imgui.Text('Mute: /' .. key .. u8" [ID игрока] - " .. u8:encode(cmd_massive[key].reason))
							if imgui.IsItemClicked() then  
								sampSetChatInputText("/" .. key)
							end
						end 
						if cmd_massive[key].cmd == '/rmute' then 
							imgui.Text('Report Mute: /' .. key .. u8" [ID игрока] - " .. u8:encode(cmd_massive[key].reason))
							if imgui.IsItemClicked() then  
								sampSetChatInputText("/" .. key)
							end
						end
						if cmd_massive[key].cmd == '/iban' or cmd_massive[key].cmd == '/ban' or cmd_massive[key].cmd == '/siban' or cmd_massive[key].cmd == '/sban' then  
							imgui.Text('Ban: /' .. key .. u8 " [ID игрока] - " .. u8:encode(cmd_massive[key].reason))
							if imgui.IsItemClicked() then  
								sampSetChatInputText("/" .. key)
							end
						end  
						if cmd_massive[key].cmd == '/jail' then  
							imgui.Text('Jail: /' .. key .. u8 " [ID игрока] - " .. u8:encode(cmd_massive[key].reason))
							if imgui.IsItemClicked() then  
								sampSetChatInputText("/" .. key)
							end
						end
						if cmd_massive[key].cmd == '/kick' then  
							imgui.Text('Kick: /' .. key .. u8 " [ID игрока] - " .. u8:encode(cmd_massive[key].reason))
							if imgui.IsItemClicked() then  
								sampSetChatInputText("/" .. key)
							end
						end
						if cmd_massive[key].cmd == '/muteakk' then  
							imgui.Text('Mute OffLine: /' .. key .. u8" [Ник игрока] - " .. u8:encode(cmd_massive[key].reason))
							if imgui.IsItemClicked() then  
								sampSetChatInputText("/" .. key)
							end
						end  
						if cmd_massive[key].cmd == '/rmuteakk' then
							imgui.Text('Report Mute OffLine: /' .. key .. u8" [Ник игрока] - " .. u8:encode(cmd_massive[key].reason))
							if imgui.IsItemClicked() then  
								sampSetChatInputText("/" .. key)
							end
						end
						if cmd_massive[key].cmd == '/jailakk' then
							imgui.Text('Jail OffLine: /' .. key .. u8" [Ник игрока] - " .. u8:encode(cmd_massive[key].reason))
							if imgui.IsItemClicked() then  
								sampSetChatInputText("/" .. key)
							end
						end 
						if cmd_massive[key].cmd == '/banakk' or cmd_massive[key].cmd == '/offban' then
							imgui.Text('Ban OffLine: /' .. key .. u8" [Ник игрока] - " .. u8:encode(cmd_massive[key].reason))
							if imgui.IsItemClicked() then  
								sampSetChatInputText("/" .. key)
							end
						end 
						if cmd_massive[key].cmd == '/banip' then
							imgui.Text('BanIP OffLine: /' .. key .. u8" [IP игрока] - " .. u8:encode(cmd_massive[key].reason))
							if imgui.IsItemClicked() then  
								sampSetChatInputText("/" .. key)
							end
						end 
					end
				end
				for key, v in pairs(cmd_helper_others) do  
					if key:find(string.lower(check_cmd_punis), 1, true) ~= nil or key == string.lower(check_cmd_punis):match("(.+) (.+)") or key == string.lower(check_cmd_punis):match("(.+)") then
						imgui.Text('/' .. key .. u8:encode(cmd_helper_others[key].reason))
						if imgui.IsItemClicked() then  
							sampSetChatInputText("/" .. key)
						end
					end 
				end
				for key, v in pairs(cmd_helper_answers) do  
					if key:find(string.lower(check_cmd_punis), 1, true) ~= nil or key == string.lower(check_cmd_punis):match("(.+) (.+)") or key == string.lower(check_cmd_punis):match("(.+)") then
						imgui.Text(u8'Ответ в чат: /' .. key .. u8:encode(cmd_helper_answers[key].reason))
						if imgui.IsItemClicked() then  
							sampSetChatInputText("/" .. key .. ' ID')
						end
					end 
				end
			else
				for key, v in pairs(cmd_massive) do 
					if cmd_massive[key].cmd == '/iban' or cmd_massive[key].cmd == '/ban' or cmd_massive[key].cmd == '/siban' or cmd_massive[key].cmd == '/sban' then  
						imgui.Text('Ban: /' .. key .. u8 " [ID игрока] - " .. u8:encode(cmd_massive[key].reason))
						if imgui.IsItemClicked() then  
							sampSetChatInputText("/" .. key)
						end
					end  
					if cmd_massive[key].cmd == '/mute' then  
						imgui.Text('Mute: /' .. key .. u8" [ID игрока] - " .. u8:encode(cmd_massive[key].reason))
						if imgui.IsItemClicked() then  
							sampSetChatInputText("/" .. key)
						end
					end 
					if cmd_massive[key].cmd == '/rmute' then 
						imgui.Text('Report Mute: /' .. key .. u8" [ID игрока] - " .. u8:encode(cmd_massive[key].reason))
						if imgui.IsItemClicked() then  
							sampSetChatInputText("/" .. key)
						end
					end
					if cmd_massive[key].cmd == '/jail' then  
						imgui.Text('Jail: /' .. key .. u8 " [ID игрока] - " .. u8:encode(cmd_massive[key].reason))
						if imgui.IsItemClicked() then  
							sampSetChatInputText("/" .. key)
						end
					end
					if cmd_massive[key].cmd == '/kick' then  
						imgui.Text('Kick: /' .. key .. u8 " [ID игрока] - " .. u8:encode(cmd_massive[key].reason))
						if imgui.IsItemClicked() then  
							sampSetChatInputText("/" .. key)
						end
					end
					if cmd_massive[key].cmd == '/muteakk' then  
						imgui.Text('Mute OffLine: /' .. key .. u8" [Ник игрока] - " .. u8:encode(cmd_massive[key].reason))
						if imgui.IsItemClicked() then  
							sampSetChatInputText("/" .. key)
						end
					end  
					if cmd_massive[key].cmd == '/jailakk' then
						imgui.Text('Jail OffLine: /' .. key .. u8" [Ник игрока] - " .. u8:encode(cmd_massive[key].reason))
						if imgui.IsItemClicked() then  
							sampSetChatInputText("/" .. key)
						end
					end 
					if cmd_massive[key].cmd == '/banakk' or cmd_massive[key].cmd == '/offban' then
						imgui.Text('Ban OffLine: /' .. key .. u8" [Ник игрока] - " .. u8:encode(cmd_massive[key].reason))
						if imgui.IsItemClicked() then  
							sampSetChatInputText("/" .. key)
						end
					end 
					if cmd_massive[key].cmd == '/banip' then
						imgui.Text('BanIP OffLine: /' .. key .. u8" [IP игрока] - " .. u8:encode(cmd_massive[key].reason))
						if imgui.IsItemClicked() then  
							sampSetChatInputText("/" .. key)
						end
					end 
					if cmd_massive[key].cmd == '/rmuteakk' then
						imgui.Text('Report Mute OffLine: /' .. key .. u8" [Ник игрока] - " .. u8:encode(cmd_massive[key].reason))
						if imgui.IsItemClicked() then  
							sampSetChatInputText("/" .. key)
						end
					end
				end
				for key, v in pairs(cmd_helper_others) do  
					imgui.Text('/' .. key .. u8:encode(cmd_helper_others[key].reason))
					if imgui.IsItemClicked() then  
						sampSetChatInputText("/" .. key)
					end
				end
				for key, v in pairs(cmd_helper_answers) do  
					imgui.Text(u8'Ответ в чат: /' .. key .. ' [ID] - ' .. u8:encode(cmd_helper_answers[key].reason))
					if imgui.IsItemClicked() then  
						sampSetChatInputText('/' .. key .. " ID")
					end 
				end
			end
		imgui.End()
		imgui.PopStyleColor()
	end	
end

function KeyCap(keyName, isPressed, size)
	u32 = imgui.ColorConvertFloat4ToU32
	local DL = imgui.GetWindowDrawList()
	local p = imgui.GetCursorScreenPos()
	local colors = {
		[true] = imgui.ImVec4(0.60, 0.60, 1.00, 1.00),
		[false] = imgui.ImVec4(0.60, 0.60, 1.00, 0.10)
	}

	if KEYCAP == nil then KEYCAP = {} end
	if KEYCAP[keyName] == nil then
		KEYCAP[keyName] = {
			status = isPressed,
			color = colors[isPressed],
			timer = nil
		}
	end

	local K = KEYCAP[keyName]
	if isPressed ~= K.status then
		K.status = isPressed
		K.timer = os.clock()
	end

	local rounding = 3.0
	local A = imgui.ImVec2(p.x, p.y)
	local B = imgui.ImVec2(p.x + size.x, p.y + size.y)
	if K.timer ~= nil then
		K.color = bringVec4To(colors[not isPressed], colors[isPressed], K.timer, 0.1)
	end
	local ts = imgui.CalcTextSize(keyName)
	local text_pos = imgui.ImVec2(p.x + (size.x / 2) - (ts.x / 2), p.y + (size.y / 2) - (ts.y / 2))

	imgui.Dummy(size)
	DL:AddRectFilled(A, B, u32(K.color), rounding)
	DL:AddRect(A, B, u32(colors[true]), rounding, _, 1)
	DL:AddText(text_pos, 0xFFFFFFFF, keyName)
end

function cyrillic(text)
    local convtbl = {
    	[230] = 155, [231] = 159, [247] = 164, [234] = 107, [250] = 144, [251] = 168,
    	[254] = 171, [253] = 170, [255] = 172, [224] = 097, [240] = 112, [241] = 099, 
    	[226] = 162, [228] = 154, [225] = 151, [227] = 153, [248] = 165, [243] = 121, 
    	[184] = 101, [235] = 158, [238] = 111, [245] = 120, [233] = 157, [242] = 166, 
    	[239] = 163, [244] = 063, [237] = 174, [229] = 101, [246] = 036, [236] = 175, 
    	[232] = 156, [249] = 161, [252] = 169, [215] = 141, [202] = 075, [204] = 077, 
    	[220] = 146, [221] = 147, [222] = 148, [192] = 065, [193] = 128, [209] = 067, 
    	[194] = 139, [195] = 130, [197] = 069, [206] = 079, [213] = 088, [168] = 069, 
    	[223] = 149, [207] = 140, [203] = 135, [201] = 133, [199] = 136, [196] = 131, 
    	[208] = 080, [200] = 133, [198] = 132, [210] = 143, [211] = 089, [216] = 142, 
    	[212] = 129, [214] = 137, [205] = 072, [217] = 138, [218] = 167, [219] = 145
    }
    local result = {}
    for i = 1, string.len(text) do
        local c = text:byte(i)
        result[i] = string.char(convtbl[c] or c)
    end
    return table.concat(result)
end

function bringVec4To(from, dest, start_time, duration)
    local timer = os.clock() - start_time
    if timer >= 0.00 and timer <= duration then
        local count = timer / (duration / 100)
        return imgui.ImVec4(
            from.x + (count * (dest.x - from.x) / 100),
            from.y + (count * (dest.y - from.y) / 100),
            from.z + (count * (dest.z - from.z) / 100),
            from.w + (count * (dest.w - from.w) / 100)
        ), true
    end
    return (timer > duration) and dest or from, false
end