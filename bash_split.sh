#!/bin/bash
encoding=`file -i $1 | awk 'BEGIN {FS="="}{print $2}'`
flacname=`file -ib $2 | awk 'BEGIN {FS="/"}{print $2}'`
if [ "$flacname" = "x-ape; charset=binary" ]
then
     ffmpeg -i $2 CDImage.flac
     flacname="CDImage.flac"
else
     flacname=$2
fi
if [ "$encoding" != "utf-8" ] 
then
    echo "Wrong encoding, converting!"
    iconv --from-code CP1251 --to-code utf-8 $1 >new.cue
    cuebreakpoints new.cue | shnsplit -a "Track" -o flac $flacname
    cuetag new.cue Track*.flac
    rm new.cue
    rm $1
else
    cuebreakpoints $1 | shnsplit -a "Track" -o flac $flacname
    cuetag $1 Track*.flac
    rm $1
fi
rm $flacname
for a in *.flac; do
    ARTIST=`metaflac "$a" --show-tag=ARTIST | sed s/.*=//g`
    TITLE=`metaflac "$a" --show-tag=TITLE | sed s/.*=//g`
    TRACKNUMBER=`metaflac "$a" --show-tag=TRACKNUMBER | sed s/.*=//g`
    mv "$a" "`printf %02g $TRACKNUMBER` - $ARTIST - $TITLE.flac"
done