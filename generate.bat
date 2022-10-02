@echo off
Setlocal ENABLEDELAYEDEXPANSION
call hexo g
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
echo Git reported an error during pull action, please check the git output for more information.
echo Git Opt:%vars%
pause
exit 1

:GitPush
echo Pushing to remote.
for /f "tokens=*" %%i in ('git push') do (
  set pushV = %%i
)
set result = %pushV:~-11%
if "%result:~0,5%" == "errno" (
  echo Push Failed, please check for git output.
  echo Git Opt:%pushV%
) else (
  echo "Push Success, Job done."
)

pause