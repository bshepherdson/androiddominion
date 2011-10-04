package dominion

import dominion.Player
import dominion.Decision
import dominion.Card

class Game
  @@instance = Game.new


  def initialize
    @players = RubyList.new
    @turn = -1
    @kingdom = RubyList.new
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
    # TODO: Handle decisions! Needs to be part of the Android/web integration.
    return ''
  end

  def startGame
    cards = Card.drawKingdom
    cards.each do |c|
      k = Kingdom.new c, Card.cardCount(c, @players.size)
      @kingdom.add k
    end

    @kingdom.add(Kingdom.new(Card.cards('Copper'), 1000))
    @kingdom.add(Kingdom.new(Card.cards('Silver'), 1000))
    @kingdom.add(Kingdom.new(Card.cards('Gold'), 1000))
    @kingdom.add(Kingdom.new(Card.cards('Estate'), Card.cardCount(Card.cards('Estate'), @players.size)))
    @kingdom.add(Kingdom.new(Card.cards('Duchy'), Card.cardCount(Card.cards('Duchy'), @players.size)))
    @kingdom.add(Kingdom.new(Card.cards('Province'), Card.cardCount(Card.cards('Province'), @players.size)))
    @kingdom.add(Kingdom.new(Card.cards('Curse'), Card.cardCount(Card.cards('Curse'), @players.size)))
  end

  /* Advances the current player and runs through one turn.
   * Returns true when the game is over.
   */
  def playTurn:boolean
    @turn = (@turn + 1) % @players.size
    p = @players[@turn]

    p.turnStart
    begin
      ret = p.turnActionPhase
    end while ret

    begin
      ret = p.turnBuyPhase
    end while ret
    
    p.turnCleanupPhase
    p.endTurn

    checkEndOfGame
  end

  def checkEndOfGame:boolean
    province = cardInKingdom('Province')
    empties = @kingdom.select { |k| Kingdom(k).count == 0 }.size

    province.count == 0 or empties >= 3
  end


  def indexInKingdom(name:String):int
    @kingdom.find_index { |k| Kingdom(k).card.name.equals(name) }
  end

  def cardInKingdom(name:String):Card
    Card(@kingdom.get(indexInKingdom(name)))
  end

  def cardCost(card:Card):int
    # TODO: Bridge, Quarry
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

