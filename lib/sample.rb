def my_count(var = nil)
  c = 0
  if block_given?
    my_each { |i| c += 1 if yield(i) }
  elsif !var.nil?
    c
  else
    c = size
  end
  c
end
