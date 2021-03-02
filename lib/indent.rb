require 'colorize'
require_relative '../lib/read_line'
# Indent class checks indentation error
class Indent < ReadLine
  def detect_key(line)
    state = false
    array = ['do ', 'def ', 'unless ', 'if', 'begin ', 'for ', 'end']
    array.each do |i|
      next unless line.include?(i)

      keyword = i
      state = true
      return [state, keyword]
    end
    [state]
  end

  def count_key(content)
    count = 0
    arr = []
    content.length.times do |i|
      j = detect_key(content[i])
      if j[0]
        count += 1
        arr << [j[1], i]
      end
    end
    [count, arr]
  end

  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/AbcSize

  def blockss(content)
    j = count_key(content)
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
    keywords
  end

  def indentation_error(content)
    a = indent(content)
    s = a[0]
    unless content[s[1]].index(/\S/) == s[0] - 2
      @error << "line #{s[1] + 1} is not properly indented::#{content[s[1]]}".colorize(:yellow)
    end
    a.length.times do |i|
      x = a[i]
      if x[2] != 'end'
        h = x[1] + 1
        (h..x[2]).each do |b|
          if content[b].include?('elsif') || content[b].include?('else') || content[b].include?('end')
            unless content[b].index(/\S/) == x[0] - 2
              @error << "line #{b + 1} is not properly indented::#{content[b]}".colorize(:yellow)
            end
          else
            unless content[b].index(/\S/) == x[0]
              @error << "line #{b + 1} is not properly indented::#{content[b]}".colorize(:yellow)
            end
          end
        end
      else
        k = x[1] - 1
        (k..x[2]).each do |c|
          if content[c].include?('end')
            unless content[c].index(/\S/) == x[0] - 2
              @error << "line #{c + 1} is not properly indented::#{content[c]}".colorize(:yellow)
            end
            p x[0]
          else
            unless content[c].index(/\S/) == x[0]
              @error << "line #{c + 1} is not properly indented::#{content[c]}".colorize(:yellow)
            end
          end
        end
      end
    end
  end

  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/AbcSize

  def indent(content)
    a = blockss(content)
    arr = []
    space = 0
    (a.length - 1).times do |i|
      x = a[i]
      y = a[i + 1]
      if x[0] != 'end'
        space += 2
        arr << [space, x[1], y[1]] # rubocop:disable Style/IdenticalConditionalBranches
      else
        space -= 2
        arr << [space, x[1], y[1]] # rubocop:disable Style/IdenticalConditionalBranches
      end
    end
    arr
  end

  # rubocop:enable Metrics/MethodLength

  def count_space(line)
    c = 0
    line.length.times do |i|
      c += 1 if line[i] == ' '
      break if line[i] != ' '
    end
    c
  end
end
