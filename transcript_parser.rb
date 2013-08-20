#!/usr/bin/env ruby

# transcript_parser.rb
# A simple script to parse a plain text transcript of a particular format into webvtt objects
# with some other data.
# Does not serialize back into WebVTT though.

require 'webvtt'
require 'chronic_duration'
require 'pp'
require 'pry'

filepath = ARGV[0]
file = File.read(filepath)

first_cue = Webvtt::Cue.new
first_cue.start = '0'
cues = [first_cue]

interview = file.match(/START OF INTERVIEW(.*)END OF INTERVIEW/m)[1]

interview.chomp!

interview_lines = interview.each_line.to_enum
interview_lines.with_index do |line, index|
  if !line.chomp.empty?
    timestamp_match = line.match(/\[\[(.*)\]\]/)
    if timestamp_match
      cues.last.end = ChronicDuration.parse(timestamp_match[1]) - 1
      if interview_lines.count != index + 1
        cues << Webvtt::Cue.new
        cues.last.start = ChronicDuration.parse(timestamp_match[1])
      end
    else
      cues.last.text ||= ''
      cues.last.text << line
    end
  end
end



pp cues

