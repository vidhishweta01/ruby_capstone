# ReadLine is a class with a method which return every line of the file content
class ReadLine
  def initialize(array)
    @error = array
  end

  def readline(content, index)
    content[index]
  end

  def last_end(content)
    arr = []
    content.length.times do |i|
      arr << i if content[i].include?('end')
    end
    x = arr.length - 1
    arr[x]
  end

  def detect_keyword(line)
    state = false
    array = ['do ', 'def ', 'unless ', 'if', 'begin ', 'for ']
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
end

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
    @error << "empty lines #{y} at the begining".colorize(:light_red) if y.positive?
  end
  # rubocop:disable Metrics/CyclomaticComplexity 
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity

  def check_indentation(cont)
    reg = /\A\s{2}/
    content = rem_emp_line_begin(cont)
    a = last_end(cont)
    x = cont.length - content.length
    line1 = content[0]
    line2 = content[1]
    k = 1
    bool = line1.match?(/\A[def]|..*\s[do]\s|[begin]|[if]...*/)
    bool2 = line2.match?(/\A\s*[def]|\A\s*[else]|\A\s*[elsif]|..*\s[do]\s|..*\s*[begin]...*/) || line2.match?(/\A\s*[if]/) || line2.include?('end') # rubocop:disable Layout/LineLength
    @error << 'line:1 is not properly indented expected no space at begining'.colorize(:light_red) unless bool
    while k < content.length
      unless line1.empty?
        case line1
        when /\A\s*[def]|\A\s*[else]|\A\s*[elsif]|..*\s[do]\s|..*\s*[begin]...*/, /\A\s*[if]/
          reg = Regexp.union(reg, /\s{2}/)
        when /..*[end]/
          reg = Regexp.union(reg, /^[\s{2}]/)
          @error << "line #{k + x} is not properly indented :: #{line1}".colorize(:light_red) unless line1.match?(reg) # rubocop:disable Metrics/BlockNesting
        end
      end
      if !line2.empty? && cont.index(line2) != a
        @error << "line #{k + 1 + x} is not properly indented :: #{line2}".colorize(:light_red) unless line2.match?(reg)
        line1 = line2 if bool2
        line2 = content[k + 1].to_s
      end
      k += 1
    end
    @error << "line #{a + 1} is not properly indented".colorize(:light_red) unless content[a].match?(/\A\S[end]/)
  end

  # rubocop:enable Metrics/CyclomaticComplexity 
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity

  private

  def rem_emp_line_begin(con)
    k, i = 0
    arr = []
    if con[0].empty?
      while con[i].empty?
        i += 1
        k = i
      end
    end
    (k...con.length).each { |n| arr << con[n] }
    arr
  end
end
