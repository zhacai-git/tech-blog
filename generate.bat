@echo off
Setlocal ENABLEDELAYEDEXPANSION
echo -----Website Update Started-----
echo ACTION: Generating static files.
call hexo g
echo ACTION: Generate done.
echo ACTION: Synchronizing from remote, it may takes time depending on your network...
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
echo ACTION: Sync done.
git add . 
echo ACTION: added files.
git commit -m "Website Update"
echo ACTION: Commit Done.
goto :GitPush

:SyncFail
echo ERROR: Git reported an error during pull action, please check the git output for more information.
echo Git Opt:%vars%
pause
exit 1

:GitPush
echo ACTION: Pushing to remote, it may takes time depending on your network....
for /f "tokens=*" %%i in ('git push') do (
  set pushV = %%i
)
set result = %pushV:~-11%
if "%result:~0,5%" == "errno" (
  echo ERROR: Push Failed, please check for git output.
  echo Git Opt:%pushV%
) else (
  echo ACTION: Push Success, Job done.
  echo -----Website Update Done-----
)

pause