@echo off
@mkdir "bin/src-lts"
@xcopy "src-lts" "bin/src-lts" /s /e
echo moved src-lts to bin/src-lts