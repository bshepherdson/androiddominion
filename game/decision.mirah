
class Option
  attr_reader key, text

  def initialize(key, text)
    @key = key
    @text = text
  end
end


class Decision
  attr_reader player, options, message, info
  @@nextId = 0

  def initialize(player, options, message, info)
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

