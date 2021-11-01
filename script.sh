# set -x

PATH=$PATH:/usr/local/bin/

scriptdir=`dirname $0`
jpg=$1
base=tmp
#`basename $jpg .jpg`
psm=${2:-11}    # $2 parameter gets defaulted to 11

echo $psm

cd $scriptdir   # important for Processing

rm tmp/*
rm tmp/boxes/*

tesseract "$jpg" bw --dpi 300 get.images

rm bw.txt
mv tessinput.tif bw.tif

tesseract bw.tif "tmp/$base" -l nld --dpi 300 --oem 1 --psm $psm \
-c "tessedit_char_whitelist=0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz- " \
-c "textord_blockndoc_fixed=1" \
-c "textonly_pdf=1" \
-c "tessedit_write_unlv=1" \
-c "tessedit_unrej_any_wd=1" \
-c "tessedit_write_block_separators=1" \
-c "textord_debug_pitch_metric=1" \
-c "tessedit_write_params_to_file=rick.txt" \
-c "tessedit_create_wordstrbox=1" \
-c "poly_debug=1" \
get.images tsv pdf makebox > "tmp/$base.stdout" 2> "tmp/$base.stderr"

rm bw.tif


# -c "interactive_display_mode=1" \





echo tmp/tmp.tsv

# config-rick 
# -c "textord_min_linesize=1.3" \
# -c "textord_width_limit=1" \

# -c "tessedit_char_whitelist=0123456789" \
 
 # msdemo
 # -c "load_system_dawg=False" \
# -c "load_freq_dawg=False" \

# --user-words userwords.txt \
# alto bigram hocr inter 

# kannada linebox rebox strokewidth unlv

# alto
# ambigs.train
# api_config
# bigram
# box.train
# box.train.stderr
# digits
# get.images
# hocr
# inter
# kannada
# linebox
# logfile
# lstm.train
# lstmbox
# lstmdebug
# makebox
# pdf
# quiet
# rebox
# strokewidth
# tsv
# txt
# unlv

# -c "textord_min_linesize=1.25" \
# -c "tessedit_dump_pageseg_images=1" \
# -c "tessedit_create_tsv=1" \
# -c "textord_tabfind_show_partitions=1" \
# -c "textord_tabfind_show_images=1" \
# -c "textord_debug_images=1" \
# -c "textord_tabfind_show_initial_partitions=1" \
# -c "edges_debug=1" \
# -c "equationdetect_save_seed_image=1" \
# -c "textord_debug_blob=1" \



# -c "textord_tabfind_show_strokewidths=1" \

 # logfile

# -c "textord_tabfind_show_images=1" \
# -c "textord_debug_tabfind=1" \
# -c tessedit_char_whitelist=0123456789ABCDEFGHIJKLMOPQRSTUVWXYZabcdefghijklmopqrstuvwxyz 

convert tessinput.tif tmp/${base}_bw.png

rm tessinput.tif
# mv tesseract.log tmp/$base.log
