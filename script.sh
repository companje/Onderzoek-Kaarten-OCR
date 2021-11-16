# set -x
if [[ $# -eq 0 ]] ; then
    echo 'Usage: ./script.sh {INPUT.JPG} {tesseract|easyocr} [psm]'
    exit 0
fi

jpg=$1
method=${2:-easyocr}    # $3 parameter gets defaulted to 11
psm=${3:-11}    # $3 parameter gets defaulted to 11
PATH=$PATH:/usr/local/bin/
PATH=$PATH:/Users/rickcompanje/.pyenv/shims/
scriptdir=`dirname $0`
base=tmp
#`basename $jpg .jpg`

cd $scriptdir   # important for Processing

rm tmp/* 2&>/dev/null 
rm tmp/boxes/* 2&>/dev/null 

echo "method: $method"

###### TESSERACT
if [ $method = "tesseract" ] ; then
  
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
  convert tessinput.tif tmp/${base}_bw.png
  rm tessinput.tif
  echo tmp/tmp.tsv
else
  easyocr -l nl -f $jpg --detail=1 --gpu=True > tmp/$base.txt
fi

###### EASYOCR

