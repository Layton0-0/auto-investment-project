@echo off
REM SSH config 및 키 파일 권한 수정 (관리자 권한으로 실행)
REM 이 .cmd 파일을 우클릭 → "관리자 권한으로 실행" 하세요.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0fix-ssh-config-permissions.ps1"
if errorlevel 1 pause
