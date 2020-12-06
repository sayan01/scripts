# Desktop to virtual camera

    ffmpeg -f x11grab -framerate 15 -video_size 1280x720 -i :0.0 -f v4l2 /dev/video0

# Video file (MP4) to virtual camera

    ffmpeg -re -i input.mp4 -map 0:v -f v4l2 /dev/video0

# Image to virtual camera

    ffmpeg -re -loop 1 -i input.jpg -vf format=yuv420p -f v4l2 /dev/video0

# Webcam → ffmpeg → Virtual webcam
## Such as if you want to do some filtering. This example will flip the image vertically.

    ffmpeg -f v4l2 -i /dev/video0 -vf vflip -f v4l2 /dev/video1

## If you get error Unknown V4L2 pixel format equivalent then add the output option -vf format=yuv420p.

# Preview with ffplay
    ffplay /dev/video0
