@echo off
setlocal

:: ���������� ��� ����� ��� ����������
set "filename=%~n0"

:: ���������� ���� � Python
set "python_path=C:\Python\Python312\python.exe"

:: ��������� ��������������� .py ����
"%python_path%" "%~dp0%filename%.py" %*

:: �������� ������� ������� ����� ��������� ����
:: pause

endlocal
