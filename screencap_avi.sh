#!/bin/bash

if [[ -z "$1" ]]
then
    dir="."
else
    dir=${1%/}
fi

#checking if Jackd is running
if ps ax | grep -v grep | grep jackd > /dev/null
then
    echo -e "Jack is up and running "
else
    echo -e "Jack is not running, please start jack before you go on "
fi

#checking if ffmpeg can handle jack
if ! ffmpeg -formats |& grep jack > /dev/null
then
    echo -e "FFmpeg is not compiled with jack"
    exit
fi

# insert your desired filename below, extension will be added automatically
echo -n "Enter the filename without [.avi] extension and hit <ENTER>: "
read name

ffmpeg -loglevel panic -f x11grab -s hd1080 -r 30 -i :0.0 -vcodec libx264 -vpre lossless_ultrafast -threads 8 "${dir}/${name}_video.avi" </dev/null >/dev/null 2>/dev/null &

ffmpeg -loglevel panic -f jack -ac 2 -i ffmpeg -threads 8 "${dir}/${name}_audio.mp3" </dev/null >/dev/null 2>/dev/null &

echo "Capturing Video: ${dir}/${name}_video.avi"
echo "Capturing Audio: ${dir}/${name}_audio.mp3"
echo -e "Press ctrl-c to finish."

# Clean Exit that kills our ffmpeg processes
ExitFunc ()
{
    echo -e "\nDone"
    # This is probably not necessary,
    # but I would hate to leave them run.
    killall -s INT ffmpeg
}
trap ExitFunc SIGINT

wait
