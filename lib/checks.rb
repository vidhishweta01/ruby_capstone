# frozen_string_literal: true

# ReadLine is a class with a method which return every line of the file content
class ReadLine
  def readline(content, index)
    content[index]
  end

  def detect_keyword(line)
    state = false
    array = ['do ', 'def ', 'unless ', 'elsif', 'if ', 'begin ', 'for ' 'end']
    array.each do |i|
      if line.include?(i)
        keyword = i
        state = true
        return [state, keyword]
      end
    end
    [state]
  end
end

# Checks contains the method for checking the error its child class of Readline
class Checks < ReadLine
  def initialize(array)
    @error = array
  end
  def trailing_spaces(line)
    state = false
    state = true if line.end_with?(' ')
    state
  end

  def count_keyword(content)
    count = 0
    arr = []
    content.length.times do |i|
      j = detect_keyword(content[i])
      if j[0]
        count += 1
        arr << [j[1], i]
      end
    end
    [count, arr]
  end

  def blocks(content)
    j = count_keyword(content)
    array = []
    keywords = j[1]
    keywords.length.times do |i|
      arr = keywords[i]
      key = ['if','unless']
      key.each do |val|
        if arr[0] == val
          line = content[arr[1]]
          k = line.index(val) - 1
          res = (0..k).reject{|n| line[n] ==' '}
          array << i if !res.empty?
        end 
      end
    end
    keyword = []
    array.length.times do |i|
      keyword << keywords[array[i]]
    end
    keywords -= keyword
    keywords
  end

  def for_usage(content)
    content.length.times do |i|
      line = content[i] 
      if line.include?('for')
        @error << "line:#{i+1} use each or times instead of for".colorize(:red)
      end
    end
  end
  
  def check_indentation(content)
    msg = 'IndentationWidth: Use 2 spaces for indentation.'
    cur_val = 0
    indent_val = 0
    arr = []
    content.each_with_index do |str_val, indx|
      strip_line = str_val.strip.split(' ')
      exp_val = cur_val * 2
      res_word = %w[class def if elsif until module unless begin case]
  
      next unless !str_val.strip.empty? || !strip_line.first.eql?('#')
  
      indent_val += 1 if res_word.include?(strip_line.first) || strip_line.include?('do')
      indent_val -= 1 if str_val.strip == 'end'
  
      next if str_val.strip.empty?
  
      @error << indent_error(str_val, indx, exp_val, msg)
      cur_val = indent_val
    end
    arr
  end

  private

  def indent_error(str_val, indx, exp_val, msg)
    strip_line = str_val.strip.split(' ')
    emp = str_val.match(/^\s*\s*/)
    end_chk = emp[0].size.eql?(exp_val.zero? ? 0 : exp_val - 2)
  
    if str_val.strip.eql?('end') || strip_line.first == 'elsif' || strip_line.first == 'when'
      return("line:#{indx + 1} #{msg}".colorize(:red)) unless end_chk
    elsif !emp[0].size.eql?(exp_val)
      return("line:#{indx + 1} #{msg}".colorize(:red))
    end
  end
end
