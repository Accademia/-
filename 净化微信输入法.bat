@echo off
:: ������ԱȨ��
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' neq '0' (
    echo �������ԱȨ��...
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

:: ��ʼ�߼�����
:: ��ȡ΢�����뷨��װ·��

setlocal

set "REG_PATH=HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths"
set "SEARCH_STRING=WeType"

echo -------------------------------------------

echo ��ʼɨ��ע������Ұ��� "%SEARCH_STRING%" ��΢�����뷨�ؼ��ʣ���ע�������:

for /f "tokens=1,2*" %%a in ('reg query "%REG_PATH%" 2^>nul') do (
    echo %%c | findstr /C:"%SEARCH_STRING%" >nul && echo ����ѯ�����%%a: %%c\  &&  set "SEARCH_DIR=%%c\"
   
)

echo ע���ɨ������� !!!

echo -------------------------------------------

set "INSTALL_DIR=C:\Program Files\Tencent\WeType\"

echo ��֤��΢�����뷨����װĿ¼�� 

:: ���·���Ƿ����
if not defined SEARCH_DIR (
    echo δ�ҵ�΢�����뷨��װ·����
    exit /B
)else (
    echo ��װ·�� = %SEARCH_DIR%
)

:: ���·���Ƿ����
if not defined INSTALL_DIR (
    echo δ�ҵ�΢�����뷨��װ·����
    exit /B
)else (
    echo ��װ·�� = %INSTALL_DIR%
)
    
echo ���ϰ�װĿ¼����֤��������� !!!! 

set "LOG_FILE=%~dp0�޸���־.txt"

:: �����־�ļ�
if exist "%LOG_FILE%" del "%LOG_FILE%"

echo -------------------------------------------

echo ��ʼ�޸�.exeΪ.bak...

echo -------------------------------- >> "%LOG_FILE%"

:: �޸��ļ���չ����������Ȩ�޺���������
for /r "%SEARCH_DIR%" %%F in (*.exe) do (
    if exist "%%F" (
        takeown /f "%%F"
        icacls "%%F" /grant %username%:F
        if exist "%%~dpnF.bak" del /f "%%~dpnF.bak"
        ren "%%F" "%%~nF.bak" && (
            echo �ɹ��޸�: %%F >> "%LOG_FILE%"
        ) || (
            echo �޸�ʧ��: %%F >> "%LOG_FILE%"
        )
    )
)

:: ɾ��ָ�����ļ���
for %%D in (log business MMKV) do (
    for /d /r "%SEARCH_DIR%" %%I in (%%D) do (
        if exist "%%I" (
            takeown /f "%%I" /r /d y
            icacls "%%I" /grant %username%:F /t
            rmdir /s /q "%%I" && (
                echo ɾ���ļ���: %%I >> "%LOG_FILE%"
            ) || (
                echo ɾ��ʧ��: %%I >> "%LOG_FILE%"
            )
        )
    )
)

echo -------------------------------- >> "%LOG_FILE%"
echo ԭ�е�.bak�ļ�: >> "%LOG_FILE%"

:: �г�����.bak�ļ�
for /r "%SEARCH_DIR%" %%F in (*.bak) do (
    echo %%F >> "%LOG_FILE%"
)

echo �޸���ɡ���ϸ��Ϣ��鿴"%LOG_FILE%"��
type "%LOG_FILE%"
pause
