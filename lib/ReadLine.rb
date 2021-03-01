# ReadLine is a class with a method which return error message for regarding linter of the file content
class ReadLine
  def initialize(array)
    @error = array
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
end
