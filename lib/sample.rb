# frozen_string_literal: true

def my_count(var = nil)
  c = 0
  if block_given?
    my_each { |i| c += 1 if yield(i) }
  elsif !var.nil?
    if to_a.include? var
      to_a.length.times do |i|
        c += 1 if to_a[i] == var
      end
    end
    c
  else
    c = size
  end
  c
end
