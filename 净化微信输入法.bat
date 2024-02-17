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
:: 获取微信输入法安装路径

setlocal

set "REG_PATH=HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths"
set "SEARCH_STRING=WeType"

echo -------------------------------------------

echo 开始扫描注册表：查找包含 "%SEARCH_STRING%" （微信输入法关键词）的注册表数据:

for /f "tokens=1,2*" %%a in ('reg query "%REG_PATH%" 2^>nul') do (
    echo %%c | findstr /C:"%SEARCH_STRING%" >nul && echo 【查询结果】%%a: %%c\  &&  set "SEARCH_DIR=%%c\"
   
)

echo 注册表扫描已完成 !!!

echo -------------------------------------------

set "INSTALL_DIR=C:\Program Files\Tencent\WeType\"

echo 验证：微信输入法，安装目录， 

:: 检查路径是否存在
if not defined SEARCH_DIR (
    echo 未找到微信输入法安装路径。
    exit /B
)else (
    echo 安装路径 = %SEARCH_DIR%
)

:: 检查路径是否存在
if not defined INSTALL_DIR (
    echo 未找到微信输入法安装路径。
    exit /B
)else (
    echo 安装路径 = %INSTALL_DIR%
)
    
echo 以上安装目录，验证结果：存在 !!!! 

set "LOG_FILE=%~dp0修改日志.txt"

:: 清空日志文件
if exist "%LOG_FILE%" del "%LOG_FILE%"

echo -------------------------------------------

echo 开始修改.exe为.bak...

echo -------------------------------- >> "%LOG_FILE%"

:: 修改文件扩展名，并处理权限和锁定问题
for /r "%SEARCH_DIR%" %%F in (*.exe) do (
    if exist "%%F" (
        takeown /f "%%F"
        icacls "%%F" /grant %username%:F
        if exist "%%~dpnF.bak" del /f "%%~dpnF.bak"
        ren "%%F" "%%~nF.bak" && (
            echo 成功修改: %%F >> "%LOG_FILE%"
        ) || (
            echo 修改失败: %%F >> "%LOG_FILE%"
        )
    )
)

:: 删除指定的文件夹
for %%D in (log business MMKV) do (
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
