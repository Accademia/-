@echo off
:: 检查管理员权限
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' neq '0' (
    echo 请求管理员权限...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"

:: ------------------------------------------------------------------------------------

:: 开始逻辑部分
set "SEARCH_DIR=C:\Program Files (x86)\sogoupinyin\"
set "LOG_FILE=%~dp0修改日志.txt"

:: 清空日志文件
if exist "%LOG_FILE%" del "%LOG_FILE%"

echo 开始修改.exe为.bak...
echo -------------------------------- >> "%LOG_FILE%"

:: 修改文件扩展名，并处理权限和锁定问题
for /r "%SEARCH_DIR%" %%F in (*.exe) do (
    if exist "%%F" (
        takeown /f "%%F"
        icacls "%%F" /grant %username%:F
        if exist "%%~dpnF.exe.bak" del /f "%%~dpnF.exe.bak"
        ren "%%F" "%%~nF.exe.bak" && (
            echo 成功修改: %%F >> "%LOG_FILE%"
        ) || (
            echo 修改失败: %%F >> "%LOG_FILE%"
        )
    )
)

:: 删除指定的文件夹
for %%D in (game_center biz_pdf biz_center scd scdicon SkinPreview SogouExe ThirdPassportIcon) do (
    for /d /r "%SEARCH_DIR%" %%I in (%%D) do (
        if exist "%%I" (
            takeown /f "%%I" /r /d y
            icacls "%%I" /grant %username%:F /t
            rmdir /s /q "%%I" && (
                echo 删除文件夹: %%I >> "%LOG_FILE%"
            ) || (
                echo 删除失败: %%I >> "%LOG_FILE%"
            )
        )
    )
)

echo -------------------------------- >> "%LOG_FILE%"
echo 原有的.bak文件: >> "%LOG_FILE%"

:: 列出所有.bak文件
for /r "%SEARCH_DIR%" %%F in (*.bak) do (
    echo %%F >> "%LOG_FILE%"
)

echo 修改完成。详细信息请查看"%LOG_FILE%"。
type "%LOG_FILE%"
pause
