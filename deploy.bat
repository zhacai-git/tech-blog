@echo off
set day = %date:~0,2%
set month = %date:~3,2%
set year = %date:~6,4%
set hour = %time:~0,2%
set minute = %time:~3,2%
echo %day%
echo Website Update At %year%-%month%-%day% %hour%:%minute% Started
hexo g
@echo on
echo "Generate done."
git add .
git commit -m "Website Updated At %year%-%month%-%day% %hour%:%minute%"
git push