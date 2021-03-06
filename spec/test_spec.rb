require 'colorize'
require_relative '../lib/checks'
require_relative '../lib/indent'
file = ['def my_count(var = nil)', '  c = 0', '  if block_given?', '    my_each { |i| c += 1 if yield(i) }',
        '  elsif !var.nil?', '    if to_a.include? var', '      to_a.length.times do |i|',
        '        c += 1 if to_a[i] == var', '      end', '    end', '    c', 'else', '    c = size', '  end',
        '  c', 'end']
res = [7, [['def ', 0], ['if', 2], ['if', 3], ['if', 4], ['if', 5], ['do ', 6], ['if', 7]]]
line = '  c = 0'
line1 = 'def my_count(var = nil)'
err = []
ch = Checks.new(err)
indent = Indent.new(err)

describe '#Checks' do # rubocop:disable Metrics/BlockLength
  describe '#Checks.trailing_spaces' do
    it 'return true if any line has a trailing space or false' do
      line2 = '  if block_given? '
      line3 = '  if block_given?'
      expect(ch.trailing_spaces(line2)).to eql(true)
      expect(ch.trailing_spaces(line3)).to eql(false)
    end
  end

  describe '#Checks.detect_keyword' do
    it 'returns false array if not contain the keywords (which have opening block)' do
      expect(ch.detect_keyword(line)).to eql([false])
    end
    it 'returns true and the name of keyword if it finds any in the line' do
      expect(ch.detect_keyword(line1)).to eql([true, 'def '])
    end
  end

  describe '#Checks.count_keyword' do
    it 'return count of all and the keyword with line no.' do
      expect(ch.count_keyword(file)).to eql(res)
    end
  end

  describe '#Checks.blocks' do
    it 'returns count of block which have end' do
      expect(ch.blocks(file)).to eql(4)
    end
  end

  describe '#Checks.detect_end' do
    it 'returns the count of ends' do
      expect(ch.detect_end(file)).to eql(4)
    end
  end

  describe 'Checks.last_end' do
    it 'returns last line number which contain last end' do
      expect(ch.last_end(file)).to eql(15)
    end
  end
end

describe '#Indent' do
  describe '#Indent.count_spaces' do
    it 'counts the spaces at the begining of a line' do
      expect(indent.count_space(line)).to eql(2)
    end
  end

  describe '#Indent.indent' do
    it 'returns array of array, which contain number of spaces with the block closing and end line no.' do
      expect(indent.indent(file)).to eql([[2, 0, 2], [4, 2, 5], [6, 5, 6], [8, 6, 8], [6, 8, 9], [4, 9, 13], [2, 13, 15]]) # rubocop:disable Layout/LineLength
    end
  end
end
