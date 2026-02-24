@echo off
cd /d "e:\App\Syncro\build\windows\x64"
"C:\Program Files\7-Zip\7z.exe" x "mpv-dev-x86_64-20230924-git-652a1dd.7z" -o"libmpv" -y
"C:\Program Files\7-Zip\7z.exe" x "ANGLE.7z" -o"ANGLE" -y
echo Done!
