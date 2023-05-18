@ECHO OFF
echo Launching Prusa Slicer from default install location or in current folder...
IF EXIST "C:\Program Files\Prusa3D\PrusaSlicer\prusa-slicer.exe" {
"C:\Program Files\Prusa3D\PrusaSlicer\prusa-slicer.exe" --load bundle.ini
} ELSE {
prusa-slicer.exe --load bundle.ini
}
if %ERRORLEVEL% EQU "1" {
echo prusa-slicer.exe not found...
}
