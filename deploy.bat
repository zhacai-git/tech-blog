@echo off
echo Website Update Started
git add . 
"C:\Program Files\Git\cmd\git.exe" commit -m "Website Updated"
"C:\Program Files\Git\cmd\git.exe" push

echo "Update done."

pause