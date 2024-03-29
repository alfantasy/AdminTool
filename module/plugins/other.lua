require 'lib.moonloader'
local inicfg = require 'inicfg' -- работа с ini
local sampev = require "lib.samp.events" -- подключение основных библиотек, связанные с потокам пакетов ивентов SA:MP, и их прямое соединение с LUA
local atlibs = require 'libsfor' -- библиотека для работы с АТ
local encoding = require 'encoding' -- работа с кодировками

-- ## Блок текстовых переменных ## --
local tag = "{00BFFF} [AT] {FFFFFF}" -- тэг AT
local log = "{00BFFF} [AdminTool-Log] {FFFFFF}" -- тэг лога АТ
local ntag = "{00BFFF} Notf - AdminTool" -- тэг уведомлений АТ
encoding.default = 'CP1251' -- смена кодировки на CP1251
u8 = encoding.UTF8 -- переименовка стандтартного режима кодировки UTF8 - u8
-- ## Блок текстовых переменных ## --

function main()
    while not isSampAvailable() do wait(0) end
    
    sampfuncsLog(log .. " Инициализация сторонней плагиновой системы. Внимание! \nДля полноценной работоспособности, проверьте загруженность основного скрипта. \n       Иначе инициализации всего пакета АТ - не будет. \n       Исключение: внешняя подгрузка плагиновой системы через AdminTool-Load")

    while true do
        wait(0)
        
    end
end