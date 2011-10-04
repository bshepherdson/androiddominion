package dominion

import dominion.Player
import java.util.ArrayList

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

  def initialize(player:Player, options:ArrayList, message:String, info:ArrayList)
    @player = player
    @options = options
    @message = message
    @info = info

    if player.temp['Native Village mat'] && player.temp['Native Village mat'].length > 0
      @info.push('Native Village mat: ' + player.temp['Native Village mat'].collect { |c| c.name }.join(', '))
    end

    @info.push("Hand: " + player.hand.collect { |c| c.name }.join(', '))

    @info = info
    @id = @@nextId
    @@nextId += 1
  end

end

