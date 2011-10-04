
import java.util.List
import java.util.ArrayList

import java.util.HashMap

import java.util.regex.*

/*
# testing regexes
regex = Pattern.compile("^card\\[(\\d+)\\]$")
matcher = regex.matcher("done")
if matcher.matches
  puts matcher.group(1)
else
  puts "failed"
end
*/

/* 
# testing hashmaps
map = HashMap.new
map.put("test","words")
puts map.get("test")
puts map.get("foo")
*/

# testing RubyList and its capabilities
class RubyList < ArrayList
  interface CollectI do
    def run(x:Object):Object; end
  end

  def collect(block:CollectI):RubyList
    ret = RubyList.new
    i = 0
    while i < size
      ret.add(block.run(get(i)))
      i += 1
    end
    ret
  end


  interface CollectIndexI do
    def run(x:Object, i:int):Object; end
  end

  def collect_index(block:CollectIndexI):RubyList
    ret = RubyList.new
    i = 0
    while i < size
      ret.add(block.run(get(i), i))
      i += 1
    end
    ret
  end


  interface SelectI do
    def run(x:Object):boolean
      false
    end
  end

  def select(block:SelectI):RubyList
    ret = RubyList.new
    i = 0
    while i < size
      x = get(i)
      if block.run(x)
        ret.add(x)
      end
      i += 1
    end
    ret
  end


  interface FindIndexI do
    def run(x:Object):boolean
      false
    end
  end

  def find_index(block:FindIndexI):int
    i = 0
    while i < size
      if block.run(get(i))
        return i
      end
      i += 1
    end
    return -1
  end


  interface EachWithIndexI do
    def run(x:Object, i:int); end
  end

  def each_with_index(block:EachWithIndexI)
    i = 0
    while i < size
      block.run(get(i), i)
      i += 1
    end
  end


  interface EachI do
    def run(x:Object); end
  end

  def each(block:EachI)
    i = 0
    while i < size
      block.run(get(i))
      i += 1
    end
  end


  def join(sep:String):String
    sb = StringBuffer.new
    i = 0
    while i < size
      sb.append(get(i))
      if (i+1) < size
        sb.append(sep)
      end
      i += 1
    end
    sb.toString()
  end
end

# test whether and how collect works
arr = RubyList.new
arr.add "test"
arr.add "strings"
arr.add "here"
puts arr.join(' !!! ')

