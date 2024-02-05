require 'lib.moonloader'
local inicfg = require 'inicfg' -- ������ � ini
local sampev = require "lib.samp.events" -- ����������� �������� ���������, ��������� � ������� ������� ������� SA:MP, � �� ������ ���������� � LUA
local atlibs = require 'libsfor' -- ���������� ��� ������ � ��
local encoding = require 'encoding' -- ������ � �����������

-- ## ���� ��������� ���������� ## --
local tag = "{00BFFF} [AT] {FFFFFF}" -- ��� AT
local log = "{00BFFF} [AdminTool-Log] {FFFFFF}" -- ��� ���� ��
local ntag = "{00BFFF} Notf - AdminTool" -- ��� ����������� ��
encoding.default = 'CP1251' -- ����� ��������� �� CP1251
u8 = encoding.UTF8 -- ������������ ������������� ������ ��������� UTF8 - u8
-- ## ���� ��������� ���������� ## --

function main()
    while not isSampAvailable() do wait(0) end
    
    sampfuncsLog(log .. " ������������� ��������� ���������� �������. ��������! \n��� ����������� �����������������, ��������� ������������� ��������� �������. \n       ����� ������������� ����� ������ �� - �� �����. \n       ����������: ������� ��������� ���������� ������� ����� AdminTool-Load")

    while true do
        wait(0)
        
    end
end