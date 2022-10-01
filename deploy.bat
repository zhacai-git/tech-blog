@echo off
echo Website Update Started
echo Sync from remote...
git pull
echo done.
git add . 
echo added files.
git commit -m "Website Updated"
git push

echo Update done.

pause