require 'lib.moonloader'

local log = "{00BFFF} [AdminTool-Log] {FFFFFF}" -- тэг лога АТ

function main()
    while not isSampAvailable() do wait(0) end
    
    sampfuncsLog(log .. " Инициализация сторонней плагиновой системы. Внимание! \nДля полноценной работоспособности, проверьте загруженность основного скрипта. \n       Иначе инициализации всего пакета АТ - не будет. \n       Исключение: внешняя подгрузка плагиновой системы через AdminTool-Load")

    while true do
        wait(0)
        
    end
end