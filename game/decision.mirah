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

    @info.add('Actions: ' + Integer.new(player.actions).toString())
    @info.add('Buys: ' + Integer.new(player.buys).toString())
    @info.add('Coins: ' + Integer.new(player.coins).toString())
    @info.add("Hand: " + player.hand.collect { |c| Card(c).name }.join(', '))
    if player.nativeVillageMat.size > 0
      @info.add('Native Village mat: ' + Utils.showCards(player.nativeVillageMat))
    end

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

