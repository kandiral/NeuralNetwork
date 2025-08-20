@echo off
setlocal

:: Определяем имя файла без расширения
set "filename=%~n0"

:: Определяем путь к Python
set "python_path=C:\Python\Python312\python.exe"

:: Запускаем соответствующий .py файл
"%python_path%" "%~dp0%filename%.py" %*

:: Ожидание нажатия клавиши перед закрытием окна
:: pause

endlocal
