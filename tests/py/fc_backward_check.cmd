@echo off
setlocal

:: ���������� ��� ����� ��� �������� "_check"
set "filename=%~n0"
set "filename=%filename:_check=%"

:: ���������� ���� � Python
set "python_path=C:\Python\Python312\python.exe"

:: ��������� ��� �� ������ ��� �������
echo Check file "%filename%.py"...
"%python_path%" -m py_compile "%~dp0%filename%.py"

:: ��������� ��� �������� ��������� �������
if %errorlevel% neq 0 (
    echo Error!
) else (
    echo OK!
)

:: �������� ������� ������� ����� ��������� ����
pause

endlocal
