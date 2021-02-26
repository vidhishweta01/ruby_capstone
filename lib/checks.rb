# frozen_string_literal: true

# ReadLine is a class with a method which return every line of the file content
class ReadLine
  def readline(content, index)
    content[index]
  end

  def detect_keyword(line)
    state = false
    array = ['do','def','if','unless','begin','for']
    array.each do |i|
      if line.include?(i)
        state = true
        return [state, i]
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
  def trailing_spaes(line)
    state = false
    state = true if line.end_with?(' ')
    state
  end

  def count_keyword(content)
    count = 0
    arr = []
    content.each do |i|
      j = detect_keyword(i)
      if j[0]
        count += 1
        arr << [j[1], content.index(i)]
      end
    end
    [count, arr]
  end

  def indentation_error(content)
    j = count_keyword(content)
    k = j[1]
    
  end

end
