require 'lib.moonloader'

local log = "{00BFFF} [AdminTool-Log] {FFFFFF}" -- ��� ���� ��

function main()
    while not isSampAvailable() do wait(0) end
    
    sampfuncsLog(log .. " ������������� ��������� ���������� �������. ��������! \n��� ����������� �����������������, ��������� ������������� ��������� �������. \n       ����� ������������� ����� ������ �� - �� �����. \n       ����������: ������� ��������� ���������� ������� ����� AdminTool-Load")

    while true do
        wait(0)
        
    end
end