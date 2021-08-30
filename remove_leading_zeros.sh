#!/usr/bin/zsh

for file in $1/*
do
  mv $file `echo $file | sed "s|/0\+|/|g"`
done
