package dominion

import dominion.Player
import dominion.Decision
import dominion.Card

import java.io.BufferedReader
import java.io.InputStreamReader


class Game
  def initialize
    Player.bootstrap
    @players = RubyList.new
    @turn = -1
    @kingdom = RubyList.new
  end

  def self.bootstrap
    @@instance = Game.new
  end

  def self.instance:Game
    @@instance
  end

  def isStarted:boolean
    @turn >= 0
  end

  def addPlayer(name:String):Player
    p = Player.new(name)
    @players.add(p)
    p
  end

  def decision(dec:Decision):String
    # temporary interface: uses the console
    puts 'Decision for ' + dec.player.name
    puts 'Info:'
    dec.info.each { |x| puts '    ' + String(x) }
    puts ''
    puts dec.message
    puts ''
    puts 'Options:'
    dec.options.each_with_index do |o_, i|
      o = Option(o_)
      puts '    ' + (i < 10 ? ' ' : '') + Integer.new(i+1).toString() + '. ' + o.text
    end

    reader = BufferedReader.new(InputStreamReader.new(System.in))
    index = -1
    begin
      System.out.print("Choice: ");
      line = reader.readLine
      if line == nil
        next
      end

      begin
        index = Integer.parseInt(line)
      rescue NumberFormatException => nfe
        next
      end
    end while index < 0

    return Option(dec.options.get(index-1)).key
  end

  def startGame
    cards = Card.drawKingdom
    playerCount = @players.size
    kingdom.addAll(cards.collect do |c_|
      c = Card(c_)
      Kingdom.new c, Card(c).cardCount(playerCount)
    end)

    @kingdom.add(Kingdom.new(Card.cards('Copper'), 1000))
    @kingdom.add(Kingdom.new(Card.cards('Silver'), 1000))
    @kingdom.add(Kingdom.new(Card.cards('Gold'), 1000))
    @kingdom.add(Kingdom.new(Card.cards('Estate'), Card.cards('Estate').cardCount(@players.size)))
    @kingdom.add(Kingdom.new(Card.cards('Duchy'), Card.cards('Duchy').cardCount(@players.size)))
    @kingdom.add(Kingdom.new(Card.cards('Province'), Card.cards('Province').cardCount(@players.size)))
    @kingdom.add(Kingdom.new(Card.cards('Curse'), Card.cards('Curse').cardCount(@players.size)))
  end

  /* Advances the current player and runs through one turn.
   * Returns true when the game is over.
   */
  def playTurn:boolean
    @turn = (@turn + 1) % @players.size
    p = Player(@players.get(@turn))

    p.turnStart
    begin
      ret = p.turnActionPhase
    end while ret

    begin
      ret = p.turnBuyPhase
    end while ret
    
    p.turnCleanupPhase
    p.turnEnd

    checkEndOfGame
  end

  def checkEndOfGame:boolean
    province = inKingdom('Province')
    empties = @kingdom.select { |k| Kingdom(k).count == 0 }.size

    province.count == 0 or empties >= 3
  end


  def indexInKingdom(name:String):int
    @kingdom.find_index { |k| Kingdom(k).card.name.equals(name) }
  end

  def inKingdom(name:String):Kingdom
    Kingdom(@kingdom.get(indexInKingdom(name)))
  end

  def cardInKingdom(name:String):Card
    inKingdom(name).card
  end

  def cardCost(card:Card):int
    # TODO: Bridge, Quarry
    puts card
    card.cost
  end

  def log(str:String):void
    puts str
  end

  def logPlayer(str:String, p:Player):void
    log(p.name + ' ' + str)
  end

  def players:RubyList
    @players
  end
  def players=(v:RubyList)
    @players = v
  end

  def turn:int
    @turn
  end
  def turn=(v:int)
    @turn = v
  end

  def kingdom:RubyList
    @kingdom
  end
  def kingdom=(v:RubyList)
    @kingdom = v
  end
end

class Kingdom
  def card:Card
    @card
  end
  def card=(v:Card)
    @card = v
  end

  def count:int
    @count
  end
  def count=(v:int)
    @count = v
  end

  def initialize(card:Card, count:int)
    @card = card
    @count = count
  end
end

