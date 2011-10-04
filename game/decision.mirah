package dominion

import dominion.Player
import dominion.Utils

class Option
  def initialize(key:String, text:String)
    @key = key
    @text = text
  end

  def key:String
    @key
  end

  def text:String
    @text
  end
end


class Decision
  @@nextId = 0

  def initialize(player:Player, options:RubyList, message:String, info:RubyList)
    @player = player
    @options = options
    @message = message
    @info = info

    if player.temp['Native Village mat'] and not player.temp['Native Village mat'].isEmpty
      @info.add('Native Village mat: ' + player.temp['Native Village mat'].collect { |c| c.name }.join(', '))
    end

    @info.add("Hand: " + player.hand.collect { |c| Card(c).name }.join(', '))

    @info = info
    @id = @@nextId
    @@nextId += 1
  end

  def player:Player
    @player
  end
  def options:RubyList
    @options
  end
  def message:String
    @message
  end
  def info:RubyList
    @info
  end
end

