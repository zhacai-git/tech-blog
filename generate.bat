@echo off
Setlocal ENABLEDELAYEDEXPANSION
echo -----Website Update Started-----
echo ACTION: Generating static files.
call hexo g
echo ACTION: Generate done.
echo ACTION: Synchronizing from remote, it may takes time depending on your network...
for /f "tokens=*" %%i in ('git pull') do (
  set vars = %%i
  echo %%i
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
if "%pushV:~-5%" == "master" (
  echo ACTION: Push Success, Job done.
  echo -----Website Update Done-----
) else (
  echo ERROR: Push Failed, please check for git output.
  @REM echo Git Opt:%pushV%
)

pause