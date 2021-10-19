@echo off

PATH=%PATH%;C:\Program Files\Tesseract-OCR

cd Z:\CBG\KaartDetectie\
Z:

set jpg=%1
set base=tmp
set psm=11

del /q tmp\*
del /q tmp\boxes\*

tesseract "%jpg%" "tmp/%base%" -l nld --dpi 300 --oem 1 --psm %psm% ^
-c "tessedit_char_whitelist=0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz- " ^
-c "textord_blockndoc_fixed=1" ^
-c "textonly_pdf=1" ^
-c "tessedit_write_unlv=1" ^
-c "tessedit_unrej_any_wd=1" ^
-c "tessedit_write_block_separators=1" ^
-c "textord_debug_pitch_metric=1" ^
-c "tessedit_write_params_to_file=rick.txt" ^
-c "tessedit_create_wordstrbox=1" ^
-c "poly_debug=1" ^
get.images tsv pdf makebox > "tmp/%base%.stdout" 2> "tmp/%base%.stderr"

