# frozen_string_literal: true

require 'colorize'
require_relative '../lib/checks'

str = ARGV
k = str[0]
error_message = []
ch = Checks.new(error_message)
begin
  if k.end_with?('.rb') || !k.include?('.')
    f = File.open(str[0])
    content = f.readlines.map(&:chomp) # content is an array of file lines
  else
    error_message << 'enter the file with extention .rb'.colorize(:light_red)
  end
rescue StandardError => e
  error_message << "Check file name or path again\n".colorize(:light_red) + e.to_s.colorize(:red)
end
content.length.times do |i|
  line = content[i]
  if ch.trailing_spaces(line)
    error_message << "line no.#{i} having trailing spaces at the end".colorize(:red)
  end
end
ch.check_indentation(content)
ch.for_usage(content)
if error_message.empty?
  puts "#{'No offenses'.colorize(:green)} detected"
else
  puts error_message
end
