#!/usr/bin/zsh

mkdir $2 2> /dev/null

for dir in `ls $1/*.colors | tr " " "?"`
do
  source=`echo $dir | sed "s|?|\\\ |g"`
  save=`echo $dir | sed "s|?|_|g"`
  file=$2/${${save##*/}%.colors}
  cursorFgColour=`grep "^cursor_foreground " $source | cut -d "#" -f 2`
  cursorBgColour=`grep "^cursor " $source | cut -d "#" -f 2`
  foregroundColour=`grep "^foreground " $source | cut -d "#" -f 2`
  backgroundColour=`grep "^background " $source | cut -d "#" -f 2`
  highlightFgColour=`grep "^highlight_foreground " $source | cut -d "#" -f 2`
  highlightBgColour=`grep "^highlight " $source | cut -d "#" -f 2`
  color0=`grep "^color0 " $source | cut -d "#" -f 2`
  color1=`grep "^color1 " $source | cut -d "#" -f 2`
  color2=`grep "^color2 " $source | cut -d "#" -f 2`
  color3=`grep "^color3 " $source | cut -d "#" -f 2`
  color4=`grep "^color4 " $source | cut -d "#" -f 2`
  color5=`grep "^color5 " $source | cut -d "#" -f 2`
  color6=`grep "^color6 " $source | cut -d "#" -f 2`
  color7=`grep "^color7 " $source | cut -d "#" -f 2`
  color8=`grep "^color8 " $source | cut -d "#" -f 2`
  color9=`grep "^color9 " $source | cut -d "#" -f 2`
  color10=`grep "^color10 " $source | cut -d "#" -f 2`
  color11=`grep "^color11 " $source | cut -d "#" -f 2`
  color12=`grep "^color12 " $source | cut -d "#" -f 2`
  color13=`grep "^color13 " $source | cut -d "#" -f 2`
  color14=`grep "^color14 " $source | cut -d "#" -f 2`
  color15=`grep "^color15 " $source | cut -d "#" -f 2`
  # xxd in vim
  echo $cursorFgColour$cursorBgColour$foregroundColour$backgroundColour$highlightFgColour$highlightBgColour\
    $color0$color1$color2$color3$color4$color5$color6$color7$color8$color9$color10$color11$color12$color13$color14$color15\
    | tr "\n" " " | sed "s/\s//g" | xxd -r -ps > $2/${${save##*/}%.colors}
done
