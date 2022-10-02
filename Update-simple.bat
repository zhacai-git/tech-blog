@echo off
call hexo g
git add .
git commit -m "Website Update"
git push