GoProTimeLapse
================

# Introduction 
This is a little script to create a time lapse video from intervalled pictures. It is aimed for linux users with a GoPros version under 3.

# Usage

Place your intervalled pictures in on directory. Call the script on that directory:

```
$ ./createTimeLapse.sh DIR
```

A timelapse.mp4 file will be created in DIR containing your video


If you want to generate a file with another name call:
```
$ ./createTimeLapse.sh -o FILENAME DIR
```
