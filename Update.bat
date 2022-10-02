@REM @echo on
echo on
Setlocal ENABLEDELAYEDEXPANSION
echo -----Website Update Started-----
echo ACTION: Generating static files.
call hexo g
echo ACTION: Generate done.
echo ACTION: Synchronizing from remote, it may takes time depending on your network...
for /f "tokens=*" %%i in ('git pull') do (
  set vars = %%i
  echo %%i
  echo %vars%
)
echo %vars:~-5%
if "%vars:~-5%" == "date." (
  echo ACTION: Sync done.
  goto :addcommit
) else (
  goto :SyncFail
)

:addcommit
git add . 
echo ACTION: added files.
git commit -m "Website Update"
echo ACTION: Commit Done.
goto :GitPush

:SyncFail
echo ERROR: Git reported an error during pull action, please check the git output for more information.
echo ERROR: Pull failed, try to continue execution.
goto :addcommit
exit 1

:GitPush
echo ACTION: Pushing to remote, it may takes time depending on your network....
@REM for /f "tokens=*" %%i in ('git push') do (
@REM   set pushV = %%i
@REM )
@REM if "%pushV:~-6%" == "master" (
@REM   echo ACTION: Push Success, Job done.
@REM   echo -----Website Update Done-----
@REM ) else (
@REM   echo ERROR: Push Failed, Website Update NOT DONE. Please check the git output for more information and rerun this script.
@REM   @REM echo Git Opt:%pushV%
@REM )
pause