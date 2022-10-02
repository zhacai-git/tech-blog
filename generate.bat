@echo off
call hexo g
@REM @echo off
echo Website Update Started
echo Synchronizing from remote, it may takes time depending on your network...
for /f "tokens=*" %%i in ('git pull') do (
  set vars = %%i
)
if defined vars (
  if "%vars%" == "Already up to date." (
    goto :addcommit
  ) else (
    goto :SyncFail
  )
)

:addcommit
echo Sync done.
git add . 
echo added files.
git commit -m "Website Update"
echo Commit Done.
goto :GitPush

:SyncFail
echo Git reported an error during pull action, please check the internet connection.
pause
exit 1

:GitPush
echo Pushing to remote.
for /f "tokens=*" %%i in ('git push') do (
  set pushV = %%i
)
echo %pushV%

pause