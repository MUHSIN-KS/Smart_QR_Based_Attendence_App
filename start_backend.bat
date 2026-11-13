@echo off
title Smart QR Attendance Backend Server
echo ==========================================================
echo  Smart QR Attendance Backend Server
echo ==========================================================
echo.
echo  [IMPORTANT] Make sure your phone and computer are connected to the SAME Wi-Fi!
echo.
echo  Your PC's Wi-Fi IP is: 192.168.0.165
echo  Backend URL for Mobile App: http://192.168.0.165:3000
echo.
echo ==========================================================
cd /d "%~dp0backend"
node server.js
pause

