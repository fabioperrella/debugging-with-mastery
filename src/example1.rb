require 'pry-byebug'

def add_two(number)
  # binding.pry # try here to show up, down
  number + 2
end

def add_four(number)
  number + 4
end

binding.pry
if add_two(2) > 1 && add_four(2) != 2
  puts(add_four(add_two(3) + add_four(8)))
end
