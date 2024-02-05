require "lib.moonloader" -- подключение основной библиотеки mooloader
local ffi = require "ffi" -- cпец структура
local dlstatus = require('moonloader').download_status
local font_admin_chat = require ("moonloader").font_flag -- шрифт для админ-чата
local vkeys = require "vkeys" -- регистр для кнопок
local imgui = require 'imgui' -- регистр imgui окон
local encoding = require 'encoding' -- дешифровка форматов
local inicfg = require 'inicfg' -- работа с ini
local sampev = require "lib.samp.events" -- подключение основных библиотек, связанные с потокам пакетов ивентов SA:MP, и их прямое соединение с LUA
local memory = require "memory" -- библиотека, отвечающие за чтение памяти, и её факторы
local tab_board	=  import ('lib/scoreboard.lua') -- регистр для scoreboard
encoding.default = 'CP1251' -- смена кодировки на CP1251
u8 = encoding.UTF8
script_properties('work-in-pause')

local window_main = imgui.ImBool(false)
local window_key = imgui.ImBool(false)
local toggle = imgui.ImBool(false)
local check_cmd_punis = nil
local tag = "{87CEEB}[AT-Dev] {4169E1}" -- локальная переменная, которая регистрирует тэг AT
local fontsize = nil
local fai_font = nil 
local fa_font = nil   
local fai = require "fAwesome5" -- работа с иконками Font Awesome 5
local fa = require 'faicons' -- работа с иконками Font Awesome 4

local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
local fai_glyph_ranges = imgui.ImGlyphRanges({ fai.min_range, fai.max_range })

function imgui.BeforeDrawFrame()
    -- if fontsize == nil then
    --     fontsize = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\Arial.ttf', 30.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
    -- end
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

local notfy	= import 'lib/libsfor.lua' -- библиотека, отвечающая за уведомления
function showNotification(handle, text_not)
	notfy.addNotify("{87CEEB}" .. handle, text_not, 2, 1, 6)
end

local font_render = renderCreateFont("Arial", 12, font_admin_chat.BOLD + font_admin_chat.SHADOW)

local id_scan, nick_scan
local ip_last, ip_reg

local onscene23 = { "блять", "сука", "хуй", "нахуй" } -- основная сцена мата
function checkMessage(msg)
	if msg ~= nil then  
		for i, ph in ipairs(onscene23) do  
			if string.find(msg, ph, 1, true) then  
				return true, ph  
			end  
		end  
	end
end

local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' -- You will need this for encoding/decoding
function enc(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

-- decoding
function dec(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
    end))
end

local punishments = {
	["ch"] = {
		reason = "Использование читерского скрипта/ПО."
	},
	["bnm"] = {
		reason = "Неадекватное поведение"
	},
	["gnck"] = {
		reason = "Банда, содержащая нецензурную лексику"
	},
	["menk"] = {
		reason = "Ник, содержающий запрещенные слова"
	},
	["nk"] = {
		reason = "Ник, содержащий нецензурную лексику"
	},
	["hl"] = {
		reason = "Оскорбление/Унижение/Мат в хелпере"
	},
	["ob"] = {
		reason = "Обход прошлого бана"
	},
	["pl"] = {
		reason = "Плагиат ника администратора"
	},
	["brekl"] = {
		reason = "Реклама иного проекта"
	},
	["bosk"] = {
		reason = "Оскорбление проекта"
	},
	["bn"] = {
		reason = "Неадекватное поведение."
	},
	["ach"] = {
		reason = "Использование читерского скрипта/ПО || Offline"
	},
	["abnm"] = {
		reason = "Неадекватное поведение || Offline"
	},
	["agnck"] = {
		reason = "Банда, содержащая нецензурную лексику || Offline"
	},
	["amenk"] = {
		reason = "Ник, содержающий запрещенные слова || Offline"
	},
	["ank"] = {
		reason = "Ник, содержащий нецензурную лексику || Offline"
	},
	["ahl"] = {
		reason = "Оскорбление/Унижение/Мат в хелпере || Offline"
	},
	["aob"] = {
		reason = "Обход прошлого бана || Offline"
	},
	["apl"] = {
		reason = "Плагиат ника администратора || Offline"
	},
	["abrekl"] = {
		reason = "Реклама иного проекта || Offline"
	},
	["abosk"] = {
		reason = "Оскорбление проекта || Offline"
	},
	["abn"] = {
		reason = "Неадекватное поведение. || Offline"
	},
	-- [x] -- Муты -- [x] --
	["cp"] = {
			reason = "Caps/Offtop в /report"
	},
	["cp2"] = {
			reason = "Caps/Offtop в /report - x2"
	},
	["cp3"] = {
			reason = "Caps/Offtop в /report - x3"
	},
	["cp4"] = {
			reason = "Caps/Offtop в /report - x4"
	},
	["cp5"] = {
			reason = "Caps/Offtop в /report - x5"
	},
	["cp6"] = {
			reason = "Caps/Offtop в /report - x6"
	},
	["cp7"] = {
			reason = "Caps/Offtop в /report - x7"
	},
	["cp8"] = {
			reason = "Caps/Offtop в /report - x8"
	},
	["cp9"] = {
			reason = "Caps/Offtop в /report - x9"
	},
	["cp10"] = {
			reason = "Caps/Offtop в /report - x10"
	},
	["rpo1"] = {
			reason = "Попрошайничество в /report"
	},
	["rpo2"] = {
			reason = "Попрошайничество в /report - x2"
	},
	["rpo3"] = {
			reason = "Попрошайничество в /report - x3"
	},
	["rpo4"] = {
			reason = "Попрошайничество в /report - x4"
	},
	["rpo5"] = {
			reason = "Попрошайничество в /report - x5"
	},
	["rpo6"] = {
			reason = "Попрошайничество в /report - x6"
	},
	["rpo7"] = {
		reason = "Попрошайничество в /report - x7"
	},
	["rpo8"] = {
		reason = "Попрошайничество в /report - x8"
	},
	["rpo9"] = {
		reason = "Попрошайничество в /report - x9"
	},
	["rpo10"] = {
		reason = "Попрошайничество в /report - x10"
	},
	["rok"] = {
		reason = "Оскорбление/Унижение игрока в /report"
	},
	["ror"] = {
		reason = "Оскорбление/Упоминание родни /report."
	},
	["rm"] = {
		reason = "Нецензурная лексика в /report"
	},
	["roa"] = {
		reason = "Оскорбление/Унижение администрации в /report"
	},
	["ria"] = {
		reason = "Выдача себя за администрацию"
	},
	["rnm"] = {
		reason = "Неадекватное поведение в /report"
	},
	["rnm1"] = {
		reason = "Неадекватное поведение в /report"
	},
	["rnm2"] = {
		reason = "Неадекватное поведение в /report"
	},
	["rkl"] = {
			reason = "Клевета на администрацию в /report"
	},
	["rup"] = {
		reason = "Упоминание сторонних проектов в /report"
	},
	["rrz"] = {
		reason = "Розжиг межнац.розни в /report"
	},
 	["fd1"] = {
		reason = "Спам/Флуд"
	},
	["fd2"] = {
			reason = "Спам/Флуд - x2"
	},
	["fd3"] = {
			reason = "Спам/Флуд - x3"
	},
	["fd4"] = {
			reason = "Спам/Флуд - x4"
	},
	["fd5"] = {
			reason = "Спам/Флуд - x5"
	},
	["fd6"] = {
			reason = "Спам/Флуд - x6"
	},
	["fd7"] = {
			reason = "Спам/Флуд - x7"
	},
	["fd8"] = {
			reason = "Спам/Флуд - x8"
	},
	["fd9"] = {
			reason = "Спам/Флуд - x9"
	},
	["fd10"] = {
			reason = "Спам/Флуд - x10"
	},
	["po1"] = {
			reason = "Попрошайничество"
	},
	["po2"] = {
			reason = "Попрошайничество - x2"
	},
	["po3"] = {
			reason = "Попрошайничество - x3"
	},
	["po4"] = {
			reason = "Попрошайничество - x4"
	},
	["po5"] = {
			reason = "Попрошайничество - x5"
	},
	["po6"] = {
			reason = "Попрошайничество - x6"
	},
	["po7"] = {
			reason = "Попрошайничество - x7"
	},
	["po8"] = {
			reason = "Попрошайничество - x8"
	},
	["po9"] = {
			reason = "Попрошайничество - x9"
	},
	["po10"] = {
			reason = "Попрошайничество - x10"
	},
	["ok"] = {
		reason = "Оскорбление/Унижение игрока(-ов)."
	},
	["m"] = {
		reason = "Нецензурная лексика."
	},
	["or"] = {
		reason = "Оскорбление/Упоминание родных"
	},
	["zs"] = {
		reason = "Злоупотребление символами"
	},
	["oa"] = {
		reason = "Оскорбление/Унижение администрации."
	},
	["ia"] = {
		reason = "Выдача себя за администрацию."
	},
	["nm"] = {
		reason = "Неадекватное поведение."
	},
	["nm1"] = {
		reason = "Неадекватное поведение."
	},
	["nm2"] = {
		reason = "Неадекватное поведение."
	},
 	["kl"] = {
		reason = "Клевета на администрацию"
	},
	["up"] = {
		reason = "Упоминание сторонних проектов"
	},
	["rz"] = {
		reason = "Розжиг межнац.розни"
	},
	["afd1"] = {
		reason = "Спам/Флуд || Offline"
	},
	["afd2"] = {
			reason = "Спам/Флуд - x2 || Offline"
	},
	["afd3"] = {
			reason = "Спам/Флуд - x3 || Offline"
	},
	["afd4"] = {
			reason = "Спам/Флуд - x4 || Offline"
	},
	["afd5"] = {
			reason = "Спам/Флуд - x5 || Offline"
	},
	["afd6"] = {
			reason = "Спам/Флуд - x6 || Offline"
	},
	["afd7"] = {
			reason = "Спам/Флуд - x7 || Offline"
	},
	["afd8"] = {
			reason = "Спам/Флуд - x8 || Offline"
	},
	["afd9"] = {
			reason = "Спам/Флуд - x9 || Offline"
	},
	["afd10"] = {
			reason = "Спам/Флуд - x10 || Offline"
	},
	["apo1"] = {
			reason = "Попрошайничество || Offline"
	},
	["apo2"] = {
			reason = "Попрошайничество - x2 || Offline"
	},
	["apo3"] = {
			reason = "Попрошайничество - x3 || Offline"
	},
	["apo4"] = {
			reason = "Попрошайничество - x4 || Offline"
	},
	["apo5"] = {
			reason = "Попрошайничество - x5 || Offline"
	},
	["apo6"] = {
			reason = "Попрошайничество - x6 || Offline"
	},
	["apo7"] = {
			reason = "Попрошайничество - x7 || Offline"
	},
	["apo8"] = {
			reason = "Попрошайничество - x8 || Offline"
	},
	["apo9"] = {
			reason = "Попрошайничество - x9 || Offline"
	},
	["apo10"] = {
			reason = "Попрошайничество - x10 || Offline"
	},
	["aok"] = {
		reason = "Оскорбление/Унижение игрока(-ов). || Offline"
	},
	["am"] = {
		reason = "Нецензурная лексика. || Offline"
	},
	["aor"] = {
		reason = "Оскорбление/Упоминание родных || Offline"
	},
	["azs"] = {
		reason = "Злоупотребление символами || Offline"
	},
	["aoa"] = {
		reason = "Оскорбление/Унижение администрации. || Offline"
	},
	["aia"] = {
		reason = "Выдача себя за администрацию. || Offline"
	},
	["anm"] = {
		reason = "Неадекватное поведение. || Offline"
	},
	["anm1"] = {
		reason = "Неадекватное поведение. || Offline"
	},
	["anm2"] = {
		reason = "Неадекватное поведение. || Offline"
	},
 	["akl"] = {
		reason = "Клевета на администрацию || Offline"
	},
	["aup"] = {
		reason = "Упоминание сторонних проектов || Offline"
	},
	["arz"] = {
		reason = "Розжиг межнац.розни || Offline"
	},
	-- [x] -- Джайлы -- [x] --
	["dz"] = {
		reason = "DM/DB in zz"
	},
	["dz1"] = {
		reason = "DM/DB in zz - x2"
	},
	["dz2"] = {
		reason = "DM/DB in zz - x3"
	},
	["dz3"] = {
		reason = "DM/DB in zz - x4"
	},
	["td"] = {
		reason = "DB/car in trade"
	},
	["skw"] = {
		reason = "SK in /gw"
	},
	["dgw"] = {
		reason = "Использование наркотиков in /gw"
	},
	["ngw"] = {
		reason = "Использование запрещенных команд in /gw"
	},
	["dbgw"] = {
		reason = "Использование вертолета in /gw"
	},
	["fsh"] = {
		reason = "Использование SpeedHack/FlyCar"
	},
	["bag"] = {
		reason = "Игровой багоюз (deagle in car)"
	},
	["pk"] = {
		reason = "Использование паркур мода"
	},
	["jch"] = {
		reason = "Использование читерского скрипта/ПО"
	},
	["sch"] = {
		reason = "Использование запрещенных скриптов"
	},
	["jcw"] = {
		reason = "Использование ClickWarp/Metla (ИЧС)"
	},
	["zv"] = {
		reason = "Злоупотребление VIP`ом"
	},
	["pmx"] = {
		reason = "Серьезная помеха игрокам"
	},
	["jm"] = {
		reason = "Нарушение правил МП"
	},
	["sk"] = {
		reason = "Spawn Kill"
	},
	["adz"] = {
		reason = "DM/DB in zz || Offline"
	},
	["adz1"] = {
		reason = "DM/DB in zz - x2 || Offline"
	},
	["adz2"] = {
		reason = "DM/DB in zz - x3 || Offline"
	},
	["adz3"] = {
		reason = "DM/DB in zz - x4 || Offline"
	},
	["atd"] = {
		reason = "DB/car in trade || Offline"
	},
	["askw"] = {
		reason = "SK in /gw || Offline"
	},
	["adgw"] = {
		reason = "Использование наркотиков in /gw || Offline"
	},
	["angw"] = {
		reason = "Использование запрещенных команд in /gw || Offline"
	},
	["adbgw"] = {
		reason = "Использование вертолета in /gw || Offline"
	},
	["afsh"] = {
		reason = "Использование SpeedHack/FlyCar || Offline"
	},
	["abag"] = {
		reason = "Игровой багоюз (deagle in car) || Offline"
	},
	["apk"] = {
		reason = "Использование паркур мода || Offline"
	},
	["ajch"] = {
		reason = "Использование читерского скрипта/ПО || Offline"
	},
	["asch"] = {
		reason = "Использование запрещенных скриптов || Offline"
	},
	["ajcw"] = {
		reason = "Использование ClickWarp/Metla (ИЧС) || Offline"
	},
	["azv"] = {
		reason = "Злоупотребление VIP`ом || Offline"
	},
	["apmx"] = {
		reason = "Серьезная помеха игрокам || Offline"
	},
	["ajm"] = {
		reason = "Нарушение правил МП || Offline"
	},
	["ask"] = {
		reason = "Spawn Kill || Offline"
	},
	["askw"] = {
		reason = "SK in /gw || Offline"
	},
	["apmx"] = {
		reason = "Серьезная помеха игрокам || Offline"
	},
	-- [x | Исключение из игры | x] -- 
	["dj"] = {
		reason = "DM in /jail"
	},
	["gnk1"] = {
		reason = "Смените никнейм. 1/3"
	},
	["gnk2"] = {
		reason = "Смените никнейм. 2/3"
	},
	["gnk3"] = {
		reason = "Смените никнейм. 3/3"
	},
	["cafk"] = {
		reason = "AFK in /arena"
	},
	-- [x | Вспомогательные команды | x] -- 
	["ru"] = {
		reason = "Размутить игрока в /report"
	},
	["uu"] = {
		reason = "Размутить игрока."
	},
	["uj"] = {
		reason = "Разджайлить игрока."
	},
	["as"] = {
		reason = "Заспавнить игрока."
	},
	["stw"] = {
		reason = "Выдать миниган"
	},
	["spp"] = {
		reason = " - Заспавнить всех в зоне стрима"
	},
	["cfind"] = {
		reason = " [Слово] - Найти слово в чат-логе"
	},
	["tpcord"] = {
		reason = " [X Y Z] - Телепортация по введенным координатам"
	},
	["delch"] = {
		reason = " - Локальная очистка чата"
	},
	["tpad"] = {
		reason = " - Телепортация на админиский остров"
	},
	["ahi"] = {
		reason = " - Приветствие к /a"
	},
	["tool"] = {
		reason = " - Открытие основного интерфейса AdminTool"
	},
	["rep_fr"] = {
		reason = " [IDAdmin] - Выдача форм"
	},
	["prf1"] = {
		reason = " [IDAdmin] - Выдача префикса «Хелпер»"
	},
	["prf2"] = {
		reason = " [IDAdmin] - Выдача префикса «Модератор»"
	},
	["prf3"] = {
		reason = " [IDAdmin] - Выдача префикса «Мл.Администратор»"
	},
	["prf4"] = {
		reason = " [IDAdmin] - Выдача префикса «Администратор»"
	},
	["prf5"] = {
		reason = " [IDAdmin] - Выдача префикса «Ст.Администратор»"
	},
	["prf6"] = {
		reason = " [IDAdmin] - Выдача префикса «Помощник.Глав.Администратора»"
	},
	["prf7"] = {
		reason = " [IDAdmin] - Выдача префикса «Зам.Глав.Администратора»"
	},
	["prf8"] = {
		reason = " [IDAdmin] - Выдача префикса «Главный.Администратор»"
	},
	["wh"] = {
		reason = "- Включение/Выключение WallHack"
	},
	["keysync"] = {
		reason = " [IDPlayer/Off] - Синхронизация клавиш игрока" 
	},
	["chip"] = {
		reason = " [IP] - Информация об IP"
	},
	["s_mat"] = {
		reason = " [Слово] - Сохранение слова автомута за мат"
	},
	["d_mat"] = {
		reason = " [Слово] - Удаления слова автомута за мат"
	},
	["s_osk"] = {
		reason = " [Слово] - Сохранение слова автомута за оск"
	},
	["d_osk"] = {
		reason = " [Слово] - Удаление слова автомута за оск"
	}
}

local commands = {

				-- ## Команды для выдачи бана ## --

	["ch"] = {
		cmd = "/iban",
		reason = " Использование читерского ПО/скриптов",
		time = 7,
	}, 
	["pl"] = {
		cmd = "/ban",
		reason = " Плагиат ника администратора",
		time = 7,
	},
	["ob"] = {
		cmd = "/iban",
		reason = " Обход прошлого бана",
		time = 7,
	},
	["hl"] = {
		cmd = "/iban",
		reason = " Оскорбление/Унижение/Мат в хелпере",
		time = 3,
	},
	["menk"] = {
		cmd = "/iban",
		reason = " Ник, содержающий запрещенные слова",
		time = 7,
	},
	["gnck"] = {
		cmd = "/iban",
		reason = " Банда, содержащая нецензурную лексину",
		time = 7,
	},
	["bnm"] = {
		cmd = "/iban",
		reason = " Неадекватное поведение",
		time = 7,
	},
	["nk"] = {
		cmd = "/ban",
		reason = " Ник, содержащий нецензурную лексику",
		time = 7,
	},

				-- ## Команды для выдачи бана ## --


				-- ## Команды для выдачи мута в чате ## --

	["fd"] = {
		cmd = "/mute",
		reason = "Флуд/Спам",
		time = 120,
		multi = true,
	}, 
	["po"] = {
		cmd = "/mute",
		reason = "Попрошайничество",
		time = 120,
		multi = true,
	}, 
	["nm"] = {
		cmd = "/mute",
		reason = "Неадекватное поведение",
		time = 600,
		multi = true,
	},
	['m'] = {
		cmd = "/mute",
		reason = "Нецензурная лексика",
		time = 300,
	},
	['ok'] = {
		cmd = "/mute",
		reason = " Оскорбление/Унижение",
		time = 400,
	},
	['oa'] = {
		cmd = "/mute",
		reason = " Оск/Унижение адм",
		time = 2500,
	},
	['kl'] = {
		cmd = "/mute",
		reason = " Клевета на администрацию",
		time = 3000,
	},
	['up'] = {
		cmd = "/mute",
		reason = " Упоминание стор.проектов",
		time = 1000,
	},
	['or'] = {
		cmd = "/mute",
		reason = " Оск/Унижение родных",
		time = 5000,
	},
	['ia'] = {
		cmd = "/mute",
		reason = " Выдача себя за адм",
		time = 2500,
	},
	['rz'] = {
		cmd = "/mute",
		reason = " Розжиг межнац.розни",
		time = 5000,
	},
	['zs'] = {
		cmd = "/mute",
		reason = " Злоуп. символами",
		time = 600,
	},

			-- ## Команды для выдачи мута в чате## --

			-- ## Команды для выдачи мута за репорт ## --

	["cp"] = {
		cmd = "/rmute",
		reason = "Флуд/Оффтоп",
		time = 120,
		multi = true,
	}, 
	["rpo"] = {
		cmd = "/rmute",
		reason = "Попрошайничество",
		time = 120,
		multi = true,
	}, 
	["rnm"] = {
		cmd = "/rmute",
		reason = "Неадекватное поведение",
		time = 600,
		multi = true,
	},
	['rm'] = {
		cmd = "/rmute",
		reason = "Нецензурная лексика",
		time = 300,
	},
	['rok'] = {
		cmd = "/rmute",
		reason = " Оскорбление/Унижение",
		time = 400,
	},
	['roa'] = {
		cmd = "/rmute",
		reason = " Оск/Унижение адм",
		time = 2500,
	},
	['rkl'] = {
		cmd = "/rmute",
		reason = " Клевета на администрацию",
		time = 3000,
	},
	['rup'] = {
		cmd = "/rmute",
		reason = " Упоминание стор.проектов",
		time = 1000,
	},
	['ror'] = {
		cmd = "/rmute",
		reason = " Оск/Унижение родных",
		time = 5000,
	},
	['ria'] = {
		cmd = "/rmute",
		reason = " Выдача себя за адм",
		time = 2500,
	},
	['rrz'] = {
		cmd = "/rmute",
		reason = " Розжиг межнац.розни",
		time = 5000,
	},
	['rzs'] = {
		cmd = "/rmute",
		reason = " Злоуп. символами",
		time = 600,
	},

			-- ## Команды для выдачи мута за репорт ## --

			-- ## Команды для выдачи джайла ## -- 

	['sk'] = {
		cmd = "/jail",
		reason = " Spawn Kill",
		time = 300,
		multi = true,
	},
	['dz'] = {
		cmd = "/jail",
		reason = " DM/DB in ZZ",
		time = 300,
		multi = true,
	},
	['td'] = {
		cmd = "/jail",
		reason = " Car in /trade",
		time = 300,
	},
	['jm'] = {
		cmd = "/jail",
		reason = " Нарушение правил MP",
		time = 300,
		multi = true,
	},
	['pmx'] = {
		cmd = "/jail",
		reason = " Серьезная помеха игрокам",
		time = 3000,
	},
	['skw'] = {
		cmd = "/jail",
		reason = " Spawn Kill in /gw",
		time = 600,
	},
	['dgw'] = {
		cmd = "/jail",
		reason = " Nark in /gw",
		time = 500,
	},
	['ngw'] = {
		cmd = "/jail",
		reason = " Closed Commands in /gw",
		time = 600,
	},
	['cmd_dbgw'] = {
		cmd = "/jail",
		reason = " Helicopter in /gw",
		time = 600,
	},
	['fsh'] = {
		cmd = "/jail",
		reason = " SpeedHack/FlyCar",
		time = 900,
	},
	['bag'] = {
		cmd = "/jail",
		reason = " Bagouse (Deagle in Car and etc)",
		time = 300,
	},
	['pk'] = {
		cmd = "/jail",
		reason = " Parkour Mode",
		time = 900,
	},
	['jch'] = {
		cmd = "/jail",
		reason = " Использование читерского ПО/скриптов",
		time = 3000,
	},
	['zv'] = {
		cmd = "/jail",
		reason = " Злоуп. VIP",
		time = 3000,
	},
	['sch'] = {
		cmd = "/jail",
		reason = " Without Damage Scripts",
		time = 900,
	},
	['jcw'] = {
		cmd = '/jail',
		reason = " ClickWarp/Metla",
		time = 900,
	},
	['dbk'] = {
		cmd = '/jail',
		reason = ' ДБ с ковшом (ZZ)',
		time = 900,
	},
			-- ## Команды для выдачи джайла ## -- 
			

			-- ## Команды для выдачи кика ## --

	['dj'] = {
		cmd = "/kick",
		reason = ' DM in /jail',
	},
	['nk1'] = {
		cmd = "/kick",
		reason = ' Смените никнейм. 1/3',
	},
	['nk2'] = {
		cmd = "/kick",
		reason = ' Смените никнейм. 2/3',
	},
	['nk3'] = {
		cmd = "/nak",
		reason = ' Смените никнейм. 3/3',
	},
	['cafk'] = {
		cmd = "/kick",
		reason = ' AFK in /arena',
	},
			-- ## Команды для выдачи кика ## --

}

local cmd_punis_jail = { "sk" , "dz" , "dz1" , "dz2", "dz3" , "zv" , "pk" , "jch" , "jm" , "td", "fsh", "jcw", "dgw", "dbgw", "ngw", "skw", "pmx", "bag", "ask" , "adz" , "adz1" , "adz2", "adz3" , "azv" , "apk" , "ajch" , "ajm" , "atd", "afsh", "ajcw", "adgw", "adbgw", "angw", "askw", "apmx", "abag"}
local cmd_punis_mute = { "fd1" , 'fd2', 'fd3', 'fd4', 'fd5', 'fd6', 'fd7', 'fd8', 'fd9', 'fd10', 'po1', 'po2', 'po3', 'po4', 'po5', 'po6', 'po7', 'po8', 'po9', 'po10', "m" , "ok" , "oa" , "kl" , "up" , "nm" , "nm1" , "nm2" , "ia" , "rz", "rrz" , "zs" , "afd1" , 'afd2', 'afd3', 'afd4', 'afd5', 'afd6', 'afd7', 'afd8', 'afd9', 'afd10', 'apo1', 'apo2', 'apo3', 'apo4', 'apo5', 'apo6', 'apo7', 'apo8', 'apo9', 'apo10', "am" , "aok" , "aoa" , "akl" , "aup" , "anm" , "anm1" , "anm2" , "aia" , "arz", "arz" , "zs" ,"roa" , "rpo1", "rpo2", "rpo3", "rpo4", "rpo5", "rpo6", "rpo7", "rpo8", "rpo9", "rpo10", "cp", "cp2", "cp3", "cp4", "cp5", "cp6", "cp7", "cp8", "cp9", "cp10", "rnm1", "rnm2", "rup", "rok", "rm", }
local cmd_helping = { "uu", "ru", "uj", "as", "stw"}
local cmd_other_help = {"spp", "cfind", "tpcord", "delch", "tpad", "ahi", "tool", "rep_fr", "prf1", "prf2", "prf3", "prf4", "prf5", "prf6", "prf7", "prf8", "wh", "keysync", "chip", "s_mat", "d_mat", "s_osk", "d_osk"}
local cmd_punis_kick = {"dj", "gnk1", "gnk2", "gnk3", "cafk"}
local cmd_punis_ban = { "bosk" , "brekl" , "pl" , "ch" , "ob" , "hl" , "nk" , "menk" , "gnck" , "bnm" , "bn", "abosk" , "abrekl" , "apl" , "ach" , "aob" , "ahl" , "ank" , "amenk" , "agnck" , "abnm" , "abn" }

imgui.ToggleButton = require('imgui_addons').ToggleButton
imgui.Spinner = require('imgui_addons').Spinner
imgui.BufferingBar = require('imgui_addons').BufferingBar
local password = "world123"
local input_password = imgui.ImBuffer(256)
local login_admintool = imgui.ImBool(false)
local test_window = imgui.ImBool(false)
local logIn = false
local window_new = imgui.ImBool(false)

local window_menu = 0
local description_menu = 0

local checked_test = imgui.ImBool(false) -- отвечает за чекбокс
local checked_test_2 = imgui.ImBool(false) -- отвечает за второй введенный чекбокс

local menu_select = 0

local checked_radio = imgui.ImInt(1) -- отвечает за радиобаттоны

local combo_select = imgui.ImInt(0) -- отвечает за комбо-штучки

local focusId = -1

local color = imgui.ImFloat3(1.0, 1.0, 1.0)

local sw1, sh1 = getScreenResolution() -- отвечает за ширину и длину, короче говоря - размер окна.
local sw, sh = getScreenResolution() -- отвечает за второстепенную длину и ширину окон.
local selectMenu = 0

local target = -1
local keys = {
	["onfoot"] = {},
	["vehicle"] = {}
}

local onscene = {
	"я твою мать",
	"mq",
	"мать твою ипал"
}

local directIni = "devconf.ini"

local defTable = inicfg.load({
	settings = {
		time = 0
	},
}, directIni)
inicfg.save(defTable, directIni)
function save() 
	inicfg.save(defTable, directIni)
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

local nick_mute_frame = {}
local reason_mute_frame = {}
local time_mute_frame = {}

function sampev.onServerMessage(color, text)

	local _, check_mat_id, _, check_mat = string.match(text, "(.+)%((.+)%): {(.+)}(.+)")

	if text:find("Администратор (.+)%[(%d+)%] раздал всем игрокам (%d+) очков и (%d+)$ за онлайн") then  
		nickAdmin, id , _, _ = text:match("Администратор (.+)%[(%d+)%] раздал всем игрокам (%d+) очков и (%d+)$ за онлайн")
		sampAddChatMessage(tag .. " Логирую сообщение: " .. nickAdmin .. " | ID:" .. id)
		return true
	end	

	if text:find("Администратор .+ заткнул%(.+%) игрока .+ на .+ секунд. Причина: .+") then  
		_, nick_player, time, m_reason = text:match("Администратор (.+) заткнул%(.+%) игрока (.+) на (.+) секунд. Причина: (.+)")
		for key in pairs(commands) do
			if commands[key].reason == m_reason and commands[key].multi == true then   
				sampAddChatMessage("ok 1", -1)
				if #nick_mute_frame > 0 then
					sampAddChatMessage("ok true", -1)
					for i, v in pairs(nick_mute_frame) do
						if v == nick_player then  
							keying = i
							sampAddChatMessage("ok 2", -1)
							sampAddChatMessage("check:", -1)
							sampAddChatMessage(reason_mute_frame[i], -1)
							if reason_mute_frame[i] == m_reason then 
								sampAddChatMessage("меняем нахуй", -1)
								table.insert(time_mute_frame, keying, tonumber(time)+tonumber(commands[key].time))
								table.remove(time_mute_frame, keying + 1)
								break
							else 
								table.insert(nick_mute_frame, nick_player)
								table.insert(reason_mute_frame, m_reason)
								table.insert(time_mute_frame, tonumber(time)+commands[key].time)
								break
							end 
							break
						else
							sampAddChatMessage("ok 3", -1)
							table.insert(nick_mute_frame, nick_player)
							table.insert(reason_mute_frame, m_reason)
							table.insert(time_mute_frame, tonumber(time)+commands[key].time)
							break
						end 
					end
				else
					sampAddChatMessage("ok 4", -1)
					table.insert(nick_mute_frame, nick_player)
					table.insert(reason_mute_frame, m_reason)
					table.insert(time_mute_frame, tonumber(time)+commands[key].time)
				end
			end
		end  
	end

	if text:find('(.+)%(%d+%) пытался написать в чат:') then
        local nick, id, text = text:match('(.+)%((%d+%)) пытался написать в чат: (.+)')
        --nick_imgui = nick
        --text_imgui = text 
        --id_imgui = id:match("(%d+)")
        --imgui.Text(u8"nick")
		return true
    end

	if text:find("Жалоба (.+) | {AFAFAF}(.+)%[(%d+)%]: (.+)") then  
		number_rep, nick, id, text = text:match("Жалоба (.+) | {AFAFAF}(.+)%[(%d+)%]: (.+)")
		sampAddChatMessage(tag .. "Жалоба " ..number_rep.. " | " .. nick .. ' ['  .. id .. ']: ' .. text, -1)
		full_report = "Жалоба " ..number_rep.. " | " .. nick .. ' ['  .. id .. ']: ' .. text
		--sampSendChat("/a " .. nick .. " [" .. id .. "]: " .. text)
		return true
	end

	-- if text:find("[VIP чат] (.+)%[(%d+)%]: (.+)") then   
	-- 	nick, id, text = text:match("[VIP чат] (.+)%[(%d+)%]: (.+)")
	-- 	sampAddChatMessage("Сообщение вип чата от ID:" .. id .. ": " .. text, -1)
	-- end

	-- if text:find("%[A%] (.+)%[(%d+)%] начал") then
	-- 	nick, ids = text:match("%[A%] (.+)%[(%d+)%] начал")
	-- 	sampAddChatMessage("id: " .. ids,-1)
    -- end
	-- блок ивента, отвечающий за перехват пакета сообщений на уровне сервера
end	

function sampev.onSendChat(text)
	-- блок ивента, отвечающий за перехват пакета присылаемых сообщений в чат на уровне сервера
end

function sampev.onSendClickTextDraw(id)
	if sendClick then 
		sampAddChatMessage(tag .. " ID TextDraw: " .. id)
	end	
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
        elseif ch == 168 then -- Ё
            output = output .. russian_characters[184]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end

function getMyNick()
    local result, id = sampGetPlayerIdByCharHandle(playerPed)
    if result then
        local nick = sampGetPlayerNickname(id)
        return nick
    end
end

local get_adminfo = false
local adminfo_time

function sampev.onShowDialog(id, style, title, button1, button2, text)
	if (title == nick_scan or title == sampGetPlayerNickname(id_scan)) then  
		sampAddChatMessage(tag .. "Открыт диалог с /offstats. ", -1)
		if text:match("REG-IP") then  
			sampAddChatMessage("Строка какая-та есть!")
		end	
		if text:match("LAST-IP:\n{......}(.*)") then  
			sampAddChatMessage("ЧЕ ЭТО")
		end	
		for line in text:gmatch("[^\n]+") do -- разбиваем чтобы искать по строкам
			if line:find("LAST-.+: (.+)") then  
				ip_last = line:match("LAST-.+: (.+)")
				sampAddChatMessage(tag .. "че это, а это IP: " .. ip_last)
			end	
			if line:find("REG-.+: (.+)") then  
				ip_reg = line:match("REG-.+: (.+)")
				ip_reg = ip_reg
				sampAddChatMessage(tag .. " IP-REG: " .. ip_reg)
			end	
			--sampAddChatMessage(tag .. line)
			--sampAddChatMessage(tag .."IP_LAST: " .. ip_last)
		end
	end	
	if title == getMyNick() then  
		for line in text:gmatch("[^\n]+") do -- разбиваем чтобы искать по строкам
			if line:find("Онлайн за текущий день:(.+) мин") then
				adminfo_time = line:match("Онлайн за текущий день:(.+) мин")
				--sampAddChatMessage(tag .. line, -1)
				--sampAddChatMessage(tag .. adminfo_time, -1)
			end
		end
	end
	-- блок ивента, отвечающий за перехват пакета показываемых диалоговых окон на уровне сервера
end

local sendClick = false
local offstats_scan = false

function sampev.onPlayerSync(playerId, data)
	local result, id = sampGetPlayerIdByCharHandle(target)
	if result and id == playerId then
		keys["onfoot"] = {}

		keys["onfoot"]["W"] = (data.upDownKeys == 65408) or nil
		keys["onfoot"]["A"] = (data.leftRightKeys == 65408) or nil
		keys["onfoot"]["S"] = (data.upDownKeys == 00128) or nil
		keys["onfoot"]["D"] = (data.leftRightKeys == 00128) or nil

		keys["onfoot"]["Alt"] = (bit.band(data.keysData, 1024) == 1024) or nil
		keys["onfoot"]["Shift"] = (bit.band(data.keysData, 8) == 8) or nil
		keys["onfoot"]["Tab"] = (bit.band(data.keysData, 1) == 1) or nil
		keys["onfoot"]["Space"] = (bit.band(data.keysData, 32) == 32) or nil
		keys["onfoot"]["F"] = (bit.band(data.keysData, 16) == 16) or nil
		keys["onfoot"]["C"] = (bit.band(data.keysData, 2) == 2) or nil

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
al = false 
function onScriptTerminate(script, quitGame)
	if script == thisScript() and al == true then 
		get_adminfo = true  
		lua_thread.create(function()
			sampSendChat("/adminfo")
			wait(3000)
			sampAddChatMessage(tag .. adminfo_time, -1)
			wait(500)
			sampCloseCurrentDialogWithButton(0)
		end)	
		defTable.settings.time = enc(adminfo_time)
		save()
		sampfuncsLog('{00FF00}AdminTool: {FFFFFF}Время сохранено!! Time: ' .. dec(defTable.settings.time))
	end
end

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end

	for key in pairs(commands) do  
		sampRegisterChatCommand(key, function(arg)
			reason_send = nil  
			time_send = nil
			if #arg > 0 then  
				if commands[key].cmd == "/iban" or commands[key].cmd == "/ban" then
					sampSendChat("/ans " .. arg .. " Уважаемый игрок, вы нарушали правила сервера, и если вы..")
					sampSendChat("/ans " .. arg .. " ..не согласны с наказанием, напишите жалобу на форум https://forumrds.ru")
					sampSendChat(commands[key].cmd .. " " .. arg .. " " .. commands[key].time .. " " .. commands[key].reason)
				end
				if commands[key].cmd == "/mute" then  
					if #nick_mute_frame > 0 then 
						for i, v in pairs(nick_mute_frame) do  
							if commands[key].reason == reason_mute_frame[i] then  
								if v == sampGetPlayerNickname(arg) then  
									reason_send = reason_mute_frame[i]
									time_send = time_mute_frame[i]
								end  
							end  
						end
					end
					if time_send and reason_send then  
						sampSendChat(commands[key].cmd .. " " .. arg .. " " .. time_send .. " " .. reason_send)
					else 
						sampSendChat(commands[key].cmd .. " " .. arg .. " " .. commands[key].time .. " " .. commands[key].reason)
					end
				end
			else 
				sampAddChatMessage(tag .. "Вы забыли ввести ID/Nick нарушителя! ", -1)
			end
		end)
	end

	-- local file = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\Special\\table.json", "r")
	-- a = file:read("*a")
	-- file:close()

	-- table = decodeJson(a) 

	-- for i, v in pairs(table) do  
	-- 	print(i)
	-- 	for item, value in pairs(v) do 
	-- 		print(item)
	-- 		for first, second in pairs(value) do  
	-- 			print(first)
	-- 			print(second['cmd'])
	-- 			print(u8:decode(second['reason']))
	-- 			print(u8:decode(second['time']))
	-- 		end
	-- 	end
	-- end

	sampRegisterChatCommand("testmassive", function()
		for i, v in pairs(nick_mute_frame) do  
			sampAddChatMessage(nick_mute_frame, -1)
			sampAddChatMessage("NICK: " .. v .. " | REASON: " .. reason_mute_frame[i] .. " | NEW TIME: " .. time_mute_frame[i] , -1)
		end  
	end)

	sampRegisterChatCommand("recon", reconnect)

	sampRegisterChatCommand("mass", function()
		for i, value in ipairs(onscene) do  
			sampAddChatMessage("massive value: " .. onscene[i], -1)
		end
	end)

	sampRegisterChatCommand("reloadscripts", function()
		sampAddChatMessage(tag .. 'Перезагружаю скрипты.')
		reloadScripts()
	end)

	sampRegisterChatCommand("closedi", function()
		sampCloseCurrentDialogWithButton(2348, 0, 0)
	end)

	sampRegisterChatCommand("dialogshow", function()
		sampShowDialog(1000,tag,"Загрузчик обновлений AdminTool","OK","NO",0)
	end)

	sampRegisterChatCommand("huita", function(arg)
		local che, ph = checkMessage(arg)
		if che then  
			sampAddChatMessage("Я все понял", -1)
		else 
			sampAddChatMessage("НИХУЯ НЕ ПОНЯЛ", -1)
		end
	end)

	_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	nick = sampGetPlayerNickname(id)
	thread = lua_thread.create_suspended(thread_function)

	if nick == "alfantasyz" or nick == "lxrdsavage.fedos" then  
		sampAddChatMessage(tag .. " Привет, Егорушка! Все готово.")
		logIn = true
	end

	sampRegisterChatCommand("rsf", function()
		--os.remove(getGameDirectory() .. "//SAMPFUNCS//SAMPFUNCS.log")
		file = io.open(getGameDirectory() .. "//SAMPFUNCS//SAMPFUNCS.log", "w")
		file:write(tag .. "Reset This File. Loading AdminTool")
		file:close()
		file = io.open(getWorkingDirectory() .. "//moonloader.log", "w")
		file:write(tag .. "Reset This File. Loading AdminTool")
		file:close()
	end)

	sampRegisterChatCommand("csf", function()
		runSampfuncsConsoleCommand("clear")
	end)

	sampRegisterChatCommand("dtext", function()
		sampAddChatMessage(tag .. tostring(dec(defTable.settings.time)), -1)
	end)

	sampRegisterChatCommand("fal", function()
		lua_thread.create(function()
		sampSendChat("/alogin fedoss")
		wait(1000)
		sampSendChat("/aclist")
		wait(1000)
		sampSendChat("/ears")
		end)
	end)

	sampRegisterChatCommand("sadm", function()
		get_adminfo = true 
		lua_thread.create(function()
			sampSendChat("/adminfo")
			wait(3000)
			sampAddChatMessage(tag .. adminfo_time, -1)
			wait(500)
			sampCloseCurrentDialogWithButton(0)
		end)	
	end)

	sampRegisterChatCommand("abch", function(arg)
		if tonumber(arg) then  
			offstats_scan = true  
			id_scan = arg  
			lua_thread.create(function()
				sampSendChat("/offstats " .. sampGetPlayerNickname(id_scan))
				wait(3000)
				sampSendChat("/banip " .. ip_last .. " 7 ИЗП/ПО ")
			end)
		else  
			offstats_scan = true  
			nick_scan = arg  
			lua_thread.create(function()
				sampSendChat("/offstats " .. nick_scan)
				wait(3000)
				sampSendChat("/banip " .. ip_last .. " 7 ИЗП/ПО ")
				sampSendChat("/bajailk " .. nick_scan .. " 7 ИЗП/ПО")
			end)
		end 
		if #arg > 0 then -- перевод arg, как строку.
			sampfuncsLog(tag .. " Зафиксирован IP адрес игрока.")
		else 
			if offstats_scan == true then 
				offstats_scan = false 
				sampAddChatMessage(tag .. "Введите ник/ид. /rekl IDPlayer/NickPlayer")
			else 
				sampAddChatMessage(tag .. "Введите ник/ид. /rekl IDPlayer/NickPlayer")
			end	
		end	
	end)

	sampRegisterChatCommand("rekl", function(arg)
		if tonumber(arg) then
			offstats_scan = true 
			id_scan = arg
			sampSendChat("/offstats " .. sampGetPlayerNickname(id_scan))
			sampSendChat("/banip " .. ip_reg .. " 999 Реклама иных проектов")
		else  
			offstats_scan = true
			nick_scan = arg
			sampSendChat("/offstats " .. nick_scan)
		end
		if #arg > 0 then -- перевод arg, как строку.
			sampfuncsLog(tag .. " Зафиксирован IP адрес игрока.")
		else 
			if offstats_scan == true then 
				offstats_scan = false 
				sampAddChatMessage(tag .. "Введите ник/ид. /rekl IDPlayer/NickPlayer")
			else 
				sampAddChatMessage(tag .. "Введите ник/ид. /rekl IDPlayer/NickPlayer")
			end	
		end	
	end)
	
	if logIn == false then 
		login_admintool.v = true 
		imgui.Process = true 
	else
		logIn = true  
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

	sampRegisterChatCommand("agtn", function(text)
		local id = sampGetPlayerIdByNickname(text)
		sampSendChat("/agt " .. id)
	end)

	sampRegisterChatCommand("openclick", function(id)
		lua_thread.create(function()
			sampSendClickPlayer(id, 0)
			wait(200)
			sampSendDialogResponse(500, 1, 4)
			wait(200)
			sampCloseCurrentDialogWithButton(0)
		end)
	end)

	sampRegisterChatCommand("dev", function()
		window_main.v = not window_main.v  
		imgui.Process = window_main.v
	end)
	sampRegisterChatCommand("dkey", function()
		window_key.v = not window_key.v  
		imgui.Process = window_key.v  
	end)
	sampRegisterChatCommand("newindow", function()
		window_new.v = not window_new.v  
		imgui.Process = window_new.v
	end)
	sampRegisterChatCommand("dsorry", function()
		sampSendChat("/mess 10 Происходит тестирование админ-скрипта AdminTool!")
		sampSendChat("/mess 10 Простите за беспокойство, дорогие игроки <3")
	end)

	sampRegisterChatCommand("scanip", function(arg)
		if tonumber(arg) then
			offstats_scan = true
			id_scan = arg
			sampSendChat("/offstats " .. sampGetPlayerNickname(id_scan))
		else  
			offstats_scan = true
			nick_scan = arg
			sampSendChat("/offstats " .. nick_scan)
		end
		if #arg > 0 then -- перевод arg, как строку.
			sampAddChatMessage(tag .. "Есть аргумент!")
		else 
			sampAddChatMessage(tag .. "Нет аргумента!")
		end	
	end)

	--sampRegisterChatCommand("dec", function(text)
	--	text = enc(text)
	--	sampAddChatMessage(text,-1)
	--	text = dec(text)
	--	sampAddChatMessage(text,-1)
	--end)

	sampRegisterChatCommand("iddialog", iddialog)

	local fonte = renderCreateFont("Arial", 8, 5) --creating font
	sampfuncsRegisterConsoleCommand("showtdid", show)   --registering command to sampfuncs console, this will call function that shows textdraw id's
	------------------ Показ запуска скрипта, указ автора и функций -------------------------
	sampAddChatMessage(tag .. 'Script for develop is initialized. ', -1)
	------------------ Показ запуска скрипта, указ автора и функций -------------------------

	while true do

		wait(0)

		imgui.Process = true

		-- if isKeyJustPressed(VK_R) and not sampIsDialogActive() and not sampIsChatInputActive() then  
		-- 	sampSendChat("/anim 61")
		-- end

		if res and time ~= nil then
			sampDisconnectWithReason(quit)
			wait(time*1000)
			sampSetGamestate(1)
			res= false
			else if res and time == nil then
				sampDisconnectWithReason(quit)
				wait(2500)
				sampSetGamestate(1)
				res= false
			end
		end

		if not window_main.v and not login_admintool.v and not window_key.v and not window_new.v then imgui.Process = false imgui.ShowCursor = false end

		if sampIsChatInputActive() then
			if sampGetChatInputText():find("/") == 1 then
				window_key.v = true
				imgui.Process = true
				if sampGetChatInputText():match("/(.+)") ~= nil then
					check_cmd_punis = sampGetChatInputText():match("/(.+)")
				else
					check_cmd_punis = nil
				end
			elseif sampGetChatInputText():find("/(.+)%(%D+)") == 1 then  
				window_key.v = false
			end
		else
			window_key.v = false
		end

		if toggle then --params that not declared has a nil value that same as false
			for a = 0, 2304	do --cycle trough all textdeaw id
				if sampTextdrawIsExists(a) then --if textdeaw exists then
					x, y = sampTextdrawGetPos(a) --we get it's position. value returns in game coords
					x1, y1 = convertGameScreenCoordsToWindowScreenCoords(x, y) --so we convert it to screen cuz render needs screen coords
					renderFontDrawText(fonte, a, x1, y1, 0xFFBEBEBE) --and then we draw it's id on textdeaw position
				end
			end
		end

		if offstats_scan == true and (sampGetDialogCaption() == nick_scan or sampGetDialogCaption() == sampGetPlayerNickname(id_scan)) then  
			offstats_scan = false 
			sampCloseCurrentDialogWithButton(0)
		end

	end
end

function join_argb(a, r, g, b)
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end

function sampev.onShowTextDraw(id, data)
	if id == 0 then  
		return false  
	end
end

function reconnect(param)
	time = tonumber(param)
	res = true
end

function iddialog()
	iddea = sampGetCurrentDialogId()
	sampAddChatMessage("Диалог с ID: " .. iddea, -1)
end

function show()
	toggle = not toggle
	sendClick = not sendClick
end

function sampev.onSendCommand(command)
	 -- ебать
end	

function imgui.OnDrawFrame()


	if login_admintool.v then  

		royalblue()

		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(580, 300), imgui.Cond.FirstUseEver)
		imgui.Begin(u8" Password ", login_admintool) 
			imgui.InputText('Enter Pass', input_password)
			if imgui.Button(u8' Login ') then
				if input_password.v == password then  
					login_admintool.v = false  
					logIn = true  
					input_password.v = ''
					imgui.Process = false 
					imgui.ShowCursor = false
					sampAddChatMessage(tag .. "Вам разрешено пользоваться функциями AT", -1) 
				else  
					sampAddChatMessage(tag .. "Вы не пользователь. Деактивирую.")	
					login_admintool.v = false 
					imgui.Process = false 
					thisScript():unload()
				end	
			end
		imgui.End()
	end

	if window_main.v then  

		royalblue()

		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(580, 300), imgui.Cond.FirstUseEver)

		imgui.ShowCursor = true
		imgui.Begin(u8" Window Help AT ", window_main) 
		imgui.BeginChild('##Special', imgui.ImVec2(120, 265), true)
			if imgui.Button(u8"Проверки") then  
				selectMenu = 1
			end
			if imgui.Button(u8"Спец.функции") then  
				selectMenu = 2
			end	
			if imgui.Button(u8'Demo ImGUI') then  
				test_window.v = not test_window.v
			end
		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginChild('##Special2', imgui.ImVec2(450, 265), true)
			if selectMenu == 1 then  
				if imgui.Button(u8"Тест") then  
					if copyImageToClipboard(getWorkingDirectory() .. "\\resource\\samp.png") then
						sampAddChatMessage("True", -1)
					end
				end
				if imgui.Button(u8"тест имгуи окна") then  
					per = imgui.GetWindowPos()
					sampAddChatMessage(tag .. "X: " .. per.x .. " | Y: " .. per.y, -1)
				end
				if imgui.Button(u8"Проверка закрытия диалогов c /mp") then  
					sampSendChat("/mp")
					sampSendDialogResponse(5343, 1, 14)
					sampSendDialogResponse(16066, 1, 0)
					sampSendDialogResponse(16066, 1, 1)
					sampSendDialogResponse(16067, 1, 0, "359")
					sampSendDialogResponse(16066, 0, 0)
					sampSendDialogResponse(5343, 1, 14)
					sampSendDialogResponse(16066, 1, 2)
					sampSendDialogResponse(16068, 1, 0, "0")
					sampSendDialogResponse(16066, 0, 0)
					sampSendDialogResponse(5343, 1, 0)
					sampSendDialogResponse(5344, 1, 0, "Тест")
				end	
				imgui.PushFont(fontsize)
					imgui.Text(u8'Текст размером 30')
				imgui.PopFont()
				if imgui.Button(u8"Текст /mess") then  
					sampSendChat("/mess 10 ------ AdminTool Testing --------")
					sampSendChat("/mess 6 Извиняемся за тестирования административного скрипта!")
					sampSendChat("/mess 6 Если что-то было сделано против Вас или в Вашу сторону разработчиком, то это случайность!")
					sampSendChat("/mess 10 ------ AdminTool Testing --------")
				end	

				imgui.ColorEdit3("##Color", color)

				local clr = join_argb(0, color.v[1] * 255, color.v[2] * 255, color.v[3] * 255)
				if imgui.Button("Render") then 
					sampAddChatMessage(('CLR: %06X | Example: {%06X}text'):format(clr, clr), -1)
				end

			end	
			if selectMenu == 2 then  
				if imgui.Button(u8"Перезагрузка") then  
					reloadScripts()
				end	
			end	
		imgui.EndChild()
		imgui.End()
	end
	if test_window.v then  
		imgui.SetNextWindowPos(imgui.ImVec2(650, 20), imgui.Cond.FirstUseEver)
		imgui.ShowTestWindow(test_window)
	end
	if window_new.v then  

		royalblue()

		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(600, 400), imgui.Cond.FirstUseEver)

		imgui.ShowCursor = true

		imgui.Begin(" New Window AT", window_new, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
			imgui.BeginChild('##Menu', imgui.ImVec2(120, 290), true)
				if imgui.Button(fai.ICON_FA_HOME .. u8" Приветствие", imgui.ImVec2(110, 0)) then  
					window_menu = 0 
				end
				if imgui.Button(fai.ICON_FA_USER_COG .. u8" Функции", imgui.ImVec2(110, 0)) then  
					window_menu = 1 
				end
				if imgui.Button(fa.ICON_FA_KEYBOARD .. u8" Клавиши", imgui.ImVec2(110, 0)) then  
					window_menu = 2 
				end
				if imgui.Button(fai.ICON_FA_BAN .. u8" Наказания", imgui.ImVec2(110, 0)) then  
					window_menu = 3
				end
				if imgui.Button(fai.ICON_FA_TH_LIST .. u8" Флуды", imgui.ImVec2(110, 0)) then  
					window_menu = 4 
				end
				imgui.Button(fa.ICON_CALCULATOR .. u8" Биндер /ans", imgui.ImVec2(110, 0))
				imgui.Button(fai.ICON_FA_TOOLS .. u8" Спец.функции", imgui.ImVec2(110, 0))
				imgui.Button(fa.ICON_FA_COGS .. u8" Настройки", imgui.ImVec2(110, 0))
			imgui.EndChild()

			imgui.SameLine()

			imgui.BeginChild('##Main', imgui.ImVec2(470, 290), true)
				if window_menu == 1 then 
					imgui.Text(u8'Здесь будут прописаны все основные функции АТ')
				end
			imgui.EndChild()

			imgui.BeginChild('##Description', imgui.ImVec2(592, 70), true)
				if window_menu == 0 then  
					imgui.Text(u8'Слева от основного окна расположено управляющее меню.\n\nРазрабочик: alfantasyz')
				end 
				if window_menu == 1 then  
					imgui.Text(u8'В данном окне указаны все основные функции АТ, которые вы можете успешно включить \nпри помощи переключателей')
				end
			imgui.EndChild()
		imgui.End()
	end 
	-- if window_key.v then  
	-- 	local in1 = sampGetInputInfoPtr()
	-- 	local in1 = getStructElement(in1, 0x8, 4)
	-- 	local in2 = getStructElement(in1, 0x8, 4)
	-- 	local in3 = getStructElement(in1, 0xC, 4)
	-- 	fib = in3 + 41
	-- 	fib2 = in2 + 10
	-- 	imgui.SetNextWindowPos(imgui.ImVec2(fib2, fib), imgui.Cond.FirstUseEver, imgui.ImVec2(0, -0.1))
	-- 	imgui.SetNextWindowSize(imgui.ImVec2(590, 120), imgui.Cond.FirstUseEver)
	-- 	imgui.Begin(u8"Любитель подсказывать команды", false, 2+4+32)
	-- 	if check_cmd_punis ~= nil then
	-- 		for key, v in pairs(cmd_punis_mute) do
	-- 			if v:find(string.lower(check_cmd_punis)) ~= nil or v == string.lower(check_cmd_punis):match("(.+) (.+) ") or v == string.lower(check_cmd_punis):match("(.+) ") then
	-- 				imgui.Text("Mute: /" .. v .. u8" [PlayerID] " .. u8:encode(punishments[v].reason))
	-- 			end
	-- 		end
	-- 		for key, v in pairs(cmd_punis_ban) do
	-- 			if v:find(string.lower(check_cmd_punis)) ~= nil or v == string.lower(check_cmd_punis):match("(.+) (.+) ")  then
	-- 				imgui.Text("Ban: /" .. v .. u8" [PlayerID] - " .. u8:encode(punishments[v].reason))
	-- 			end
	-- 		end
	-- 		for key, v in pairs(cmd_punis_jail) do
	-- 			if v:find(string.lower(check_cmd_punis)) ~= nil or v == string.lower(check_cmd_punis):match("(.+) (.+) ") or v == string.lower(check_cmd_punis):match("(.+) ") then
	-- 				imgui.Text("Jail: /" .. v .. u8" [PlayerID] - " .. u8:encode(punishments[v].reason))
	-- 			end
	-- 		end
	-- 		for key, v in pairs(cmd_punis_kick) do
	-- 			if v:find(string.lower(check_cmd_punis)) ~= nil or v == string.lower(check_cmd_punis):match("(.+) (.+) ") or v == string.lower(check_cmd_punis):match("(.+) ") then
	-- 				imgui.Text("Kick: /" .. v .. u8" [PlayerID] - " .. u8:encode(punishments[v].reason))
	-- 			end
	-- 		end
	-- 		for key, v in pairs(cmd_helping) do
	-- 			if v:find(string.lower(check_cmd_punis)) ~= nil or v == string.lower(check_cmd_punis):match("(.+) (.+) ") or v == string.lower(check_cmd_punis):match("(.+) ") then
	-- 				imgui.Text("/" .. v .. u8" [PlayerID] - " .. u8:encode(punishments[v].reason))
	-- 			end
	-- 		end
	-- 		for key, v in pairs(cmd_other_help) do
	-- 			if v:find(string.lower(check_cmd_punis)) ~= nil or v == string.lower(check_cmd_punis):match("(.+) (.+) ") or v == string.lower(check_cmd_punis):match("(.+) ") then
	-- 				imgui.Text("/" .. v .. u8:encode(punishments[v].reason))
	-- 			end
	-- 		end
	-- 	else
	-- 		for key, v in pairs(cmd_punis_mute) do
	-- 			imgui.Text("Mute: /" .. v .. u8" [PlayerID] " .. u8:encode(punishments[v].reason))
	-- 		end
	-- 		for key, v in pairs(cmd_punis_ban) do
	-- 			imgui.Text("Ban: /" .. v .. u8" [PlayerID] - " .. u8:encode(punishments[v].reason))
	-- 		end
	-- 		for key, v in pairs(cmd_punis_jail) do
	-- 			imgui.Text("Jail: /" .. v .. u8" [PlayerID] - " .. u8:encode(punishments[v].reason))
	-- 		end
	-- 		for key, v in pairs(cmd_punis_kick) do
	-- 			imgui.Text("Kick: /" .. v .. u8" [PlayerID] - " .. u8:encode(punishments[v].reason))
	-- 		end
	-- 		for key, v in pairs(cmd_helping) do
	-- 			imgui.Text("/" .. v .. u8" [PlayerID] - " .. u8:encode(punishments[v].reason))
	-- 		end
	-- 		for key, v in pairs(cmd_other_help) do
	-- 			imgui.Text("/" .. v .. u8:encode(punishments[v].reason))
	-- 		end
	-- 	end
	-- 	imgui.End()
	-- end	
end

function apply_custom_style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    colors[clr.FrameBg]                = ImVec4(0.48, 0.23, 0.16, 0.54) -- R, G, B, A
    colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.43, 0.26, 0.40) -- R, G, B, A
    colors[clr.FrameBgActive]          = ImVec4(0.98, 0.43, 0.26, 0.67) -- R, G, B, A
end
apply_custom_style()

function royalblue()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	local ImVec2 = imgui.ImVec2

	style.WindowPadding       = ImVec2(4, 6)
	style.WindowRounding      = 0
	style.ChildWindowRounding = 3
	style.FramePadding        = ImVec2(5, 4)
	style.FrameRounding       = 2
	style.ItemSpacing         = ImVec2(3, 3)
	style.TouchExtraPadding   = ImVec2(0, 0)
	style.IndentSpacing       = 21
	style.ScrollbarSize       = 14
	style.ScrollbarRounding   = 16
	style.GrabMinSize         = 10
	style.GrabRounding        = 5
	style.WindowTitleAlign    = ImVec2(0.50, 0.50)
	style.ButtonTextAlign     = ImVec2(0, 0)

	colors[clr.Text] = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled] = ImVec4(0.60, 0.60, 0.60, 1.00)
	colors[clr.WindowBg] = ImVec4(0.11, 0.10, 0.11, 1.00)
	colors[clr.ChildWindowBg] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.PopupBg] = ImVec4(0.30, 0.30, 0.30, 1.00)
	colors[clr.Border] = ImVec4(0.86, 0.86, 0.86, 1.00)
	colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.FrameBg] = ImVec4(0.21, 0.20, 0.21, 0.60)
	colors[clr.FrameBgHovered] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.FrameBgActive] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.TitleBg] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.TitleBgActive] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.MenuBarBg] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.ScrollbarBg] = ImVec4(0.00, 0.46, 0.65, 0.00)
	colors[clr.ScrollbarGrab] = ImVec4(0.00, 0.46, 0.65, 0.44)
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.00, 0.46, 0.65, 0.74)
	colors[clr.ScrollbarGrabActive] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.ComboBg] = ImVec4(0.15, 0.14, 0.15, 1.00)
	colors[clr.CheckMark] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.SliderGrab] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.SliderGrabActive] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.Button] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.ButtonHovered] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.ButtonActive] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.Header] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.HeaderHovered] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.HeaderActive] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.ResizeGrip] = ImVec4(1.00, 1.00, 1.00, 0.30)
	colors[clr.ResizeGripHovered] = ImVec4(1.00, 1.00, 1.00, 0.60)
	colors[clr.ResizeGripActive] = ImVec4(1.00, 1.00, 1.00, 0.90)
	colors[clr.CloseButton] = ImVec4(1.00, 0.10, 0.24, 0.00)
	colors[clr.CloseButtonHovered] = ImVec4(0.00, 0.10, 0.24, 0.00)
	colors[clr.CloseButtonActive] = ImVec4(1.00, 0.10, 0.24, 0.00)
	colors[clr.PlotLines] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.PlotLinesHovered] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.PlotHistogram] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.PlotHistogramHovered] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.TextSelectedBg] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.ModalWindowDarkening] = ImVec4(0.00, 0.00, 0.00, 0.00)
end