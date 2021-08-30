#!/usr/bin/zsh

mkdir $2 2> /dev/null

for dir in `ls $1/*.colors | tr " " "?"`
do
  source=`echo $dir | sed "s|?|\\\ |g"`
  save=`echo $dir | sed "s|?|_|g"`
  cursorFgColour=`grep "cursor_foreground " $source | awk '{print $3}'`
  cursorBgColour=`grep "cursor " $source | awk '{print $3}'`
  foregroundColour=`grep "foreground " $source | awk '{print $3}'`
  backgroundColour=`grep "background " $source | awk '{print $3}'`
  highlightFgColour=`grep "highlight_foreground " $source | awk '{print $3}'`
  highlightBgColour=`grep "highlight " $source | awk '{print $3}'`
  color0=`grep "color0 " $source | awk '{print $3}'`
  color1=`grep "color1 " $source | awk '{print $3}'`
  color2=`grep "color2 " $source | awk '{print $3}'`
  color3=`grep "color3 " $source | awk '{print $3}'`
  color4=`grep "color4 " $source | awk '{print $3}'`
  color5=`grep "color5 " $source | awk '{print $3}'`
  color6=`grep "color6 " $source | awk '{print $3}'`
  color7=`grep "color7 " $source | awk '{print $3}'`
  color8=`grep "color8 " $source | awk '{print $3}'`
  color9=`grep "color9 " $source | awk '{print $3}'`
  color10=`grep "color10 " $source | awk '{print $3}'`
  color11=`grep "color11 " $source | awk '{print $3}'`
  color12=`grep "color12 " $source | awk '{print $3}'`
  color13=`grep "color13 " $source | awk '{print $3}'`
  color14=`grep "color14 " $source | awk '{print $3}'`
  color15=`grep "color15 " $source | awk '{print $3}'`
  echo $cursorFgColour$cursorBgColour$foregroundColour$backgroundColour$highlightFgColour$highlightBgColour\
    $color0$color1$color2$color3$color4$color5$color6$color7$color8$color9$color10$color11$color12$color13$color14$color15\
    | sed ":t;N;s/\s//;b t" | sed "s/\s//" > $2/${${save##*/}%.colors}
done
