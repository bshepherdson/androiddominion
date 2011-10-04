def f(block)
  arr = [9,8,7,6,5,4,3,2,1,0]

  arr.collect.with_index do |n,i|
    block.call(n) ? "#{ i }: #{ n }" : nil
  end
end


def h(&block)
  arr = [9,8,7,6,5,4,3,2,1,0]

  arr.collect.with_index do |n,i|
    block.yield(n) ? "#{i}: #{n}" : nil
  end.select { |n| n }
end

g = Proc.new { |n| true }
#f g

h { |n| n % 2 == 0 }

