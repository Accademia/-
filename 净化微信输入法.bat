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



echo -------------------------------------------
echo .

set "roamingPath=%APPDATA%\Tencent\WeType"


if defined roamingPath (
    echo  微信，在用户空间 ，的 安装路径  =  %roamingPath%
) else (
    echo .
    echo 未找到安装目录。建议重新安装《微信输入法》后，再执行本脚本
)


echo .
echo -------------------------------------------
echo .

set "regPath=HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Tencent\WeType"
set "valueName=InstallDir"

echo 扫描 注册表： 

for /f "tokens=2*" %%a in ('reg query "%regPath%" /v "%valueName%" 2^>nul') do (
    set "installLocation=%%b"
)

if defined installLocation (
    echo .
    echo  微信，在系统空间 ，的 安装路径  =  %installLocation%
) else (
    echo .
    echo 未找到安装目录。建议重新安装《微信输入法》后，再执行本脚本
)


echo .
echo -------------------------------------------
echo .

echo 验证：微信输入法，安装目录， 

:: 检查路径是否存在
if not defined roamingPath (
    echo 发生错误：在《注册表》，未找到微信输入法，在用户空间的安装路径。请重新安装“微信输入法”后，在执行本程序！即将退出本程序！
    pause
    exit /B
)else (
    echo 用户空间 安装路径 = %roamingPath%
)

:: 检查路径是否存在
if not defined installLocation (
    echo 发生错误：在《注册表》，未找到微信输入法，系统空间的安装路径。。请重新安装“微信输入法”后，在执行本程序！即将退出本程序！
    pause
    exit /B
)else (
    echo 程序空间 安装路径 = %installLocation%
)
    
echo 以上安装目录，验证结果：存在 !!!! 

set "LOG_FILE=%~dp0修改日志.txt"

:: 清空日志文件
if exist "%LOG_FILE%" del "%LOG_FILE%"

echo .
echo -------------------------------------------
echo .

echo 开始修改.exe为.bak...

echo -------------------------------- >> "%LOG_FILE%"

:: 修改文件扩展名，并处理权限和锁定问题
for /r "%roamingPath%" %%F in (*.exe) do (
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
for %%D in (log business MMKV) do (
    for /d /r "%roamingPath%" %%I in (%%D) do (
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
for /r "%roamingPath%" %%F in (*.bak) do (
    echo %%F >> "%LOG_FILE%"
)

echo 修改完成。详细信息请查看"%LOG_FILE%"。
type "%LOG_FILE%"

echo -------------------------------------------
echo -------------------------------------------

echo 已完成全部净化操作，现在输入法不会泄露你的隐私了！ 可以尽情的 去反X了 ！！！！！

echo -------------------------------------------
echo -------------------------------------------

pause
