@echo off
setlocal

:: Определяем имя файла без суффикса "_check"
set "filename=%~n0"
set "filename=%filename:_check=%"

:: Определяем путь к Python
set "python_path=C:\Python\Python312\python.exe"

:: Проверяем код на ошибки без запуска
echo Check file "%filename%.py"...
"%python_path%" -m py_compile "%~dp0%filename%.py"

:: Проверяем код возврата последней команды
if %errorlevel% neq 0 (
    echo Error!
) else (
    echo OK!
)

:: Ожидание нажатия клавиши перед закрытием окна
pause

endlocal
