@echo off
echo Building English Script... 
copy /y ".\tools\putt\marvelous\eng_ver2_main\table.tbl" ".\text\en_new\table.tbl"
copy /y ".\tools\putt\marvelous\eng_ver2_main\main.txt" ".\text\en_new\script.txt"
copy /y ".\tools\putt\marvelous\eng_ver2_main\notes.txt" ".\text\en_new\script_notes.txt"
".\tools\putt\puttscript.exe" -e ".\text\en_new\table.tbl" ".\text\en_new\script.txt" ".\text\en_new\script.bin"
echo.
echo Building English Items...
copy /y ".\tools\putt\marvelous\eng_ver2_items\table.tbl" ".\text\en_new\items_table.tbl"
copy /y ".\tools\putt\marvelous\eng_ver2_items\main.txt" ".\text\en_new\items.txt"
copy /y ".\tools\putt\marvelous\eng_ver2_items\notes.txt" ".\text\en_new\items_notes.txt"
".\tools\putt\puttscript.exe" -e ".\text\en_new\items_table.tbl" ".\text\en_new\items.txt" ".\text\en_new\items.bin"
echo.
echo Done.
pause