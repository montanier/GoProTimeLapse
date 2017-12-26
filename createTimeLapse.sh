#!/bin/bash

positional=()
# Default output is timelapse.mp4
output=timelapse
picture_dir="./"

while [[ $# -gt 0 ]]
do
	key="$1"

	case $key in
	-o|--output)
	output="$2"
	shift # past argument
	shift # past value
	;;

	*)    # unknown option
	POSITIONAL+=("$1") # save it in an array for later
	shift # past argument
	;;
esac
done

set -- "${POSITIONAL[@]}" # restore positional parameters

if [[ $# -gt 0 ]]
then
	picture_dir=$1
fi

# Check if dictory contains actually GoPro pictures

if ls $picture_dir/G00*.JPG 1>/dev/null 2>&1
then

	# Create the morph images
	# Create them manually by pair of images to avoid
	# to run in a memory explosion

	prevFile="$(ls $picture_dir/G00*.JPG | head -n 1)"
	first=true
	fileId=0

	for file in $picture_dir/G00*.JPG
	do
		# First loop is just used to update prevFile
		if [ "$first" == false ]
		then
			echo -ne "Morph btw pictures: "$(basename $prevFile)"-"$(basename $file)"\r"

			cp $prevFile $picture_dir/P01.jpg
			cp $file $picture_dir/P02.jpg

			# Actually morph between a pair of image
			convert $picture_dir/P0*.jpg -delay 10 -morph 5 $picture_dir/M%05d.jpg

			# Move the result of the morph to the correct
			# file id
			for fileRename in $picture_dir/M*.jpg
			do
				id=$(printf "%05d" $fileId)
				cp $fileRename $picture_dir/"TMP"$id".jpg"
				fileId=$((fileId + 1))
			done

			# Remove temporary files
			rm $picture_dir/M*.jpg
			rm $picture_dir/P01.jpg
			rm $picture_dir/P02.jpg
		else
			first=false
		fi

		prevFile=$file

	done

	# Stitch morphed image together into a video
	ffmpeg -loglevel 16 -r 50 -i $picture_dir/TMP%05d.jpg -s 640x480 -vcodec libx264 $picture_dir/$output.mp4

	# Clean up
	rm $picture_dir/TMP*.jpg

	if [ -f $picture_dir"/"$output".mp4" ]
	then
		echo "Video created in: "$picture_dir"/"$output".mp4"
	else
		echo "Failed at creating video "$picture_dir" in: "$output".mp4"
	fi
fi
