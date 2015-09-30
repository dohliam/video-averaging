# video-averaging: Extract frames from videos and use them to create composite images

This script takes a video as input and uses ffmpeg (or avconv) to extract frames from the video at a set rate (by default, one frame per minute, but this is adjustable). It then uses mexitek's [python-image-averaging](https://github.com/mexitek/python-image-averaging) script to create an image average with the extracted frames as a source.

The results can be interesting:

![](https://i.imgur.com/5GIQUHf.jpg)

(Example image averaged from [Sita Sings the Blues](http://sitasingstheblues.com/) by Nina Paley)

The video can be a locally stored file on machine, or you can feed the script a YouTube url and it will download the video, extract the frames and then automatically create a result image.

Because the script uses youtube-dl to download videos, it can also take urls from any of the [703 other sites supported by youtube-dl](https://github.com/rg3/youtube-dl/blob/master/docs/supportedsites.md).

## Requirements

Video-averaging strings together a number of other tools that are leveraged to do the work of downloading videos, extracting frames, and creating averaged images from those frames. You will need to have the following tools installed for video-averaging to work:

* Either [ffmpeg](https://www.ffmpeg.org/) or [avconv](http://www.libav.org/) (to extract video frames)
* [youtube-dl](https://github.com/rg3/youtube-dl) (to make images from YouTube or other online videos)
* [python-image-averaging](https://github.com/mexitek/python-image-averaging) (to make the actual averaged images)

The script is written in Ruby, so you will also need to have that installed. Additionally, the python-image-averaging script requires Python as well as the [Python Imaging Library](http://www.pythonware.com/products/pil/).


## Installation

Make sure you have all the requirements listed above, as well as a copy of the files in this repo.

You can run the script (`video_average_machine.rb`) from the project folder, or call it from somewhere else.

Before you start using video-averaging however, you will need to set a few options in the script configuration file (see below).

## Configuration

The script looks for a configuration file named `config.yml` in your home folder (under `~/.config/video-averaging`). If it does not find it there, it will look in the $XDG_CONFIG_DIRS folder (under `/etc/xdg/video-averaging`). If it does not find it in either of those places, it will read `config.yml` from the folder the script is in (this repo comes with a copy of the default configuration file). The first time you run the script, this default configuration file will be copied to `~/.config/video-averaging`, and any changes you want to make after that should be made there (or optionally in the $XDG_CONFIG_DIRS folder).

The following options available in the configuration file:
* `:average_machine:` The location of the python-image-averaging script (average_machine.py). If you don't have a copy of this, you can download it from the [python-image-averaging project page](https://github.com/mexitek/python-image-averaging). This needs to be specified for the image averaging process to work.
* `:converter:` The preferred video converter to use for extracting frames from videos. This can be set to either `"ffmpeg"` or `"avconv"`.
* `:width:` The default image width (the default is set to 720 px)
* `:temp_dir:` The default temporary image directory to use for downloaded videos and extracted frames (default is `.video_averaging_img` in the directory containing the source video)
* `:seconds_per_frame:` The default number of seconds per frame (default is 60, or one frame per minute)
* `:output:` The default output directory (default is the same location as the source video)

## Usage

### Basic usage

    ruby video_average_machine.rb [OPTIONS] [INPUT FILE]
    ./video_average_machine.rb [OPTIONS] [INPUT FILE]

    ruby video_average_machine.rb [OPTIONS] -u [URL]
    ./video_average_machine.rb [OPTIONS] -u [URL]

### Examples

#### Local video

    ruby video_average_machine.rb video_file.mp4

This will tell the script to create an average of the frames of `video_file.mp4` using default settings (e.g., 1 frame per 60 seconds, with an image width of 720 px).

    ruby video_average_machine.rb big_buck_bunny_480p_surround-fix.avi

Creates an average of every 60th frame in the movie [Big Buck Bunny](https://peach.blender.org/), which you can download [here](https://peach.blender.org/download/). The result looks like this:

![](https://i.imgur.com/4qeHisa.jpg)

If you want to remove the black bars at the top and bottom of the image, you can adjust the image width and/or height:

    ruby video_average_machine.rb -w 1240 big_buck_bunny_480p_surround-fix.avi

The result:

![](https://i.imgur.com/HBK5r2x.jpg)

#### Online video

    ruby -u https://www.youtube.com/watch?v=TxHBeXCWzGg

This will create an average of the frames from [this cc-by licensed YouTube video](https://www.youtube.com/watch?v=TxHBeXCWzGg) by [Stephane Thomas](https://www.youtube.com/channel/UCnpk8qFPkxy2Tp_VS6SyWTQ) using the default settings.

Result:

![](https://i.imgur.com/207bb1U.jpg)

    ruby video_average -w 1240 -u https://www.youtube.com/watch?v=TxHBeXCWzGg

Creates an image average at 1240 px width:

![](https://i.imgur.com/m4xU41J.jpg)

    ruby video_average -f 10 -w 1240 -u https://www.youtube.com/watch?v=TxHBeXCWzGg

Creates an image based on the same YouTube video as above, but taking one frame every 10 seconds instead of every 60 seconds

![](https://i.imgur.com/nMwAzF6.jpg)


## Options

The following command-line options are available:
* `--avconv`: Use avconv for video conversion instead of ffmpeg
* `-b` (`--batch`): Batch extract average images from specified video at multiple frame rates (-f = 60, 30, 15, 10, and 1)
* `-f SECONDS` (`--seconds-per-frame SECONDS`): Specify the number of seconds per frame
* `--ffmpeg`: Use ffmpeg for video conversion`
* `-g` (`--gif`): Use together with `-b` -- make a gif out of a series of averaged images
* `-h SIZE` (`--height SIZE`): Specify an output image height
* `-o DIRECTORY` (`--output DIRECTORY`): Specify an output directory for the result image
* `-s DIRECTORY` (`--source DIRECTORY`): Specify source directory
* `-u URL` (`--url URL`): Extract video from url
* `-w SIZE` (`--width SIZE`): Specify an output image width

To extract one frame per minute, use `-f 60` (the default); for two frames per minute (or one every 30 seconds), use `-f 30`, and so on.

By default, images are sized at 720 px width. You can adjust this with `-w`.

Temporary files (downloaded video and extracted images) as well as the final averaged image are by default stored in the same directory as the source video. This can be changed using the `-o` option to specify a different directory.

## Tips

### Video duration and seconds per frame
If you have a very short video, you will probably want to adjust the seconds per frame rate of image extraction using `-f` to something smaller (the default is 60, which is a good compromise for videos of various lengths). For example, if your source video is 5 minutes or less, you might want to use `-f 30` (one frame every 30 seconds) or lower; if your video is shorter than one minute, the default won't extract any images, so you could use `-f 1` instead to grab one frame per second.

In general, the fewer frames are extracted from the source video, the more defined and distinct the resulting image will be; conversely, the more frames are extracted, the more hazy or indistinct the result. If you are looking for a nice blurry [bokeh](https://en.wikipedia.org/wiki/Bokeh) type of effect or just something more abstract, then the more frames the better.

As an example, here is [this cc-by licensed cell phone video from YouTube](https://www.youtube.com/watch?v=YvNnWQeatMg) by [Brian Ruhe](https://www.youtube.com/channel/UCU3u-_-Y6j07XILBHo4rkXA) at `-f 60` vs. `-f 10`:

_-f 60_

![](https://i.imgur.com/7PJbstK.jpg)

_-f 10_

![](https://i.imgur.com/wzWxyFV.jpg)

Another thing to note is that usually the more frames per second are extracted, the darker the resulting average image will be. Compare the following average of Big Buck Bunny at `-f 10`:

![](https://i.imgur.com/cK7lrus.jpg)

vs. the same video at `-f 1`:

![](https://i.imgur.com/MDjp4Sv.jpg)

### Objects in frame
The longer an object is in a particular place on screen in the source video, the more distinct it will tend to be in the resulting average image.

For example, in [this video by Eben Moglen](https://en.wikipedia.org/wiki/File:Eben_Moglen_-_From_the_birth_of_printing_to_industrial_culture;_the_root_of_copyright.ogv), the camera angle, background, and main subject change very little over the duration of the clip. If we average the frames, even using a low rate such as `-f 10`, the image remains quite recognizable:

_-f 10_

![](http://imgur.com/tloeYD1.jpg)

Bringing the seconds-per-frame rate down all the way to `-f 1` leads to a surprising result:

_-f 1_

![](http://imgur.com/T9qitgX.jpg)

Here the subject remains distinct, but the background in particular has become even sharper and more focused (as opposed to videos with lots of motion, which become blurry and indistinct at high seconds-per-frame rates).

### Black and white videos
Running video-averaging on black and white videos can have an interesting effect. Here is the result of averaging frames from [Battleship Potemkin](https://archive.org/details/BattleshipPotemkin) (1925):

![](https://i.imgur.com/OXWlJVb.jpg)

## License

MIT -- see LICENSE file for details.

All example images retain the license of their source videos:
* The 1925 film [Battleship Potemkin](https://archive.org/details/BattleshipPotemkin) is now in the Public Domain.
* [Big Buck Bunny](https://peach.blender.org/) by [the Blender Foundation](https://www.blender.org/) is licensed CC-BY
* [Kauai in HD - Hawaii Amazing Scenery](https://www.youtube.com/watch?v=TxHBeXCWzGg) by [Stephane Thomas](https://www.youtube.com/channel/UCnpk8qFPkxy2Tp_VS6SyWTQ) is licensed CC-BY
* [Sita Sings the Blues](http://sitasingstheblues.com/) by [Nina Paley](http://blog.ninapaley.com/) is licensed CC-0
* [Spectacular Scenery! Flying Across BC with Samsung Phone Optical Illusion](https://www.youtube.com/watch?v=YvNnWQeatMg) by [Brian Ruhe](https://www.youtube.com/channel/UCU3u-_-Y6j07XILBHo4rkXA)
* [From the birth of printing to industrial culture; the root of copyright](https://en.wikipedia.org/wiki/File:Eben_Moglen_-_From_the_birth_of_printing_to_industrial_culture;_the_root_of_copyright.ogv) by [Eben Moglen](http://emoglen.law.columbia.edu/) is licensed CC-BY-SA
