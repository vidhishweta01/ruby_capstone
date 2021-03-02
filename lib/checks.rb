require 'colorize'
require_relative '../lib/read_line'

# Checks contains the method for checking the error its child class of Readline
class Checks < ReadLine
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

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize

  def blocks(content)
    j = count_keyword(content)
    array = []
    keywords = j[1]
    keywords.length.times do |i|
      arr = keywords[i]
      key = %w[if unless]
      key.each do |val|
        next unless arr[0] == val

        line = content[arr[1]]
        k = line.index(val) - 1
        res = (0..k).reject { |n| line[n] == ' ' }
        array << i unless res.empty?
      end
    end
    keyword = []
    array.length.times do |i|
      keyword << keywords[array[i]]
    end
    keywords -= keyword
    keywords.length
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def for_usage(content)
    content.length.times do |i|
      line = content[i]
      @error << "line:#{i + 1} use each or times instead of for".colorize(:red) if line.include?('for')
    end
  end

  def end_error(content)
    x = blocks(content)
    y = detect_end(content)
    @error << 'missing end tag'.colorize(:light_red) if x != y
  end

  def empty_line(con)
    x = rem_emp_line_begin(con).length
    v = con.length
    y = v - x
    @error << "#{y} empty lines at the begining".colorize(:light_red) if y.positive?
  end

  def last_end(content)
    arr = []
    g = 0
    while g < content.length
      arr << g if content[g].include?('end')
      g += 1
    end
    x = arr.length
    arr[x - 1]
  end

  def detect_keyword(line)
    state = false
    array = ['do ', 'def ', 'unless ', 'if', 'begin ', 'for ', 'class ', 'module ']
    array.each do |i|
      next unless line.include?(i)

      keyword = i
      state = true
      return [state, keyword]
    end
    [state]
  end

  def detect_end(content)
    arr = []
    i = 0
    while i < content.length
      arr << i if content[i].include?('end')
      i += 1
    end
    arr.length
  end

  private

  def rem_emp_line_begin(content)
    arr = []
    j = 0
    j += 1 while content[j].empty? if content[0].empty? # rubocop:disable Style/NestedModifier
    (j...content.length).each { |n| arr << content[n] }
    arr
  end
end
