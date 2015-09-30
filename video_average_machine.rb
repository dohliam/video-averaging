#!/usr/bin/ruby -KuU
# encoding: utf-8

# require 'yaml'
require 'fileutils'
require 'optparse'
require 'yaml'

# command-line options
options = {}
OptionParser.new do |opts|
  opts.banner = "  video-averaging - tool to average video frames\n\n  Usage: ruby video_averaging_machine.rb [options] -s [source folder] -a [output folder]"

  opts.on("", "--avconv", "Use avconv for video conversion") { options[:avconv] = true }
  opts.on("-b", "--batch", "Batch extract average from video at multiple frame rates (60,30,15,10,1)") { options[:batch] = true }
  opts.on("-f", "--seconds-per-frame SECONDS", "Specify number of seconds per frame") { |v| options[:seconds_per_frame] = v }
  opts.on("", "--ffmpeg", "Use ffmpeg for video conversion") { options[:ffmpeg] = true }
  opts.on("-h", "--height SIZE", "Specify an output image height") { |v| options[:width] = v }
  opts.on("-o", "--output DIRECTORY", "Specify output directory") { |v| options[:output] = v }
  opts.on("-u", "--url URL", "Extract video from url") { |v| options[:url] = v }
  opts.on("-w", "--width SIZE", "Specify an output image width") { |v| options[:width] = v }

end.parse!

config_dir = Dir.home + "/.config/video-averaging/"
xdg = "/etc/xdg/video-averaging/"
script_dir = File.expand_path(File.dirname(__FILE__)) + "/"

# read config file from default directory or cwd, otherwise quit
if File.exist?(config_dir + "config.yml")
  config = YAML::load(File.read(config_dir + "config.yml"))
elsif File.exist?(xdg + "config.yml")
  config = YAML::load(File.read(xdg + "config.yml"))
  FileUtils.mkdir_p config_dir
  FileUtils.cp xdg + "config.yml", config_dir
elsif File.exist?(script_dir + "config.yml")
  config = YAML::load(File.read(script_dir + "config.yml"))
  FileUtils.mkdir_p config_dir
  FileUtils.cp script_dir + "config.yml", config_dir
else
  abort("        No configuration file found. Please make sure config.yml is located
        either in the config folder under your home directory (i.e.,
        ~/.config/video-averaging/config.yml), or in the same directory as the 
        video_averaging_machine.rb executable.")
end

if !ARGV[0]
  if !options[:url]
    abort("Please enter an input video filename")
  end
end

input_video = ARGV[0]
if options[:url]
  url = options[:url]
#   `youtube-dl #{url} -o .temp.mp4`
  system("youtube-dl", "-o", ".temp.mp4", "#{url}", out: $stdout)
#   test pattern: https://www.youtube.com/watch?v=Srmdij0CU1U
  input_video = Dir.pwd + "/.temp.mp4"
end

# location of python image averaging script
average_machine = config[:average_machine]

converter = "ffmpeg"	# either ffmpeg or avconv
if options[:ffpmeg]
  converter = "ffmpeg"
elsif config[:converter]
  converter = config[:converter]
end

seconds_per_frame = "60"
if options[:seconds_per_frame]
  seconds_per_frame = options[:seconds_per_frame]
elsif config[:seconds_per_frame]
  seconds_per_frame = config[:seconds_per_frame]
end

width = ""
if options[:width]
  width = " -w " + options[:width]
elsif config[:width]
  width = " -w " + config[:width]
end

basename = File.basename(input_video, File.extname(input_video))

# output = Dir.pwd + "/"
input_video = input_video.gsub(/^~/, Dir.home)
output = File.split(File.absolute_path(input_video))[0] + "/"
if options[:output]
  output = options[:output] + "/"
elsif config[:output]
  output = config[:output] + "/"
end

output = output.gsub(/\/\/$/, "/")

# hacky proxy for unique file name
quick_id = basename.gsub(/\s/, "").gsub(/^(.{9}).*/, "\\1")

temp_dir = output + ".video_averaging_img-" + quick_id
FileUtils.mkdir_p temp_dir

if options[:batch]
  batch_series = ["60", "30", "15", "10", "1"]
  batch_series.each do |s|
    `#{converter} -i "#{input_video}" -r 1/#{s} "#{temp_dir}/#{quick_id}%03d.png"`
    `python #{average_machine} -s #{temp_dir}/ -a #{output}img_avg-#{quick_id}_f#{s}-#{width}`
    FileUtils.rm_rf(temp_dir + "/*")
    puts "\n  **-f #{s} completed**"
  end
  puts
  puts "  Source video processed at -f 60, -f 30, -f 15, -f 10, -f 1"
  exit
end

# extract frames from video
`#{converter} -i "#{input_video}" -r 1/#{seconds_per_frame} "#{temp_dir}/#{quick_id}%03d.png"`


frames_count = Dir.glob(temp_dir + "/*").length.to_s

# average those frames to get the final image
`python #{average_machine} -s #{temp_dir}/ -a #{output}img_avg-#{quick_id}_f#{seconds_per_frame}-#{width}`

puts
puts "  #{frames_count} frames have been extracted and averaged at #{seconds_per_frame} seconds per frame from source video:
  #{basename}."

# cleanup temporary files
FileUtils.rm_rf(temp_dir)
if options[:url]
  FileUtils.rm_rf(".temp.mp4")
end
