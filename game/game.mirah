package dominion

import dominion.Player
import dominion.Decision
import dominion.Card
import java.util.ArrayList

class Game
  @@instance = Game.new

  attr_accessor players, turn, kingdom

  def initialize
    @players = []
    @turn = -1
    @kingdom = []
  end

  def self.instance
    @@instance
  end

  def isStarted
    @turn >= 0
  end

  def addPlayer(name)
    p = Player.new(name)
    @players.push(p)
    p
  end

  def decision(dec)
    # TODO: Handle decisions! Needs to be part of the Android/web integration.
  end

  def startGame
    cards = Card.drawKingdom
    cards.each do |c|
      k = Kingdom.new c, Card.cardCount(c, @players.length)
      @kingdom.push k
    end

    @kingdom.push(Kingdom.new(Card.cards['Copper'], 1000))
    @kingdom.push(Kingdom.new(Card.cards['Silver'], 1000))
    @kingdom.push(Kingdom.new(Card.cards['Gold'], 1000))
    @kingdom.push(Kingdom.new(Card.cards['Estate'], Card.cardCount(Card.cards['Estate'], @players.length)))
    @kingdom.push(Kingdom.new(Card.cards['Duchy'], Card.cardCount(Card.cards['Duchy'], @players.length)))
    @kingdom.push(Kingdom.new(Card.cards['Province'], Card.cardCount(Card.cards['Province'], @players.length)))
    @kingdom.push(Kingdom.new(Card.cards['Curse'], Card.cardCount(Card.cards['Curse'], @players.length)))
  end

  /* Advances the current player and runs through one turn.
   * Returns true when the game is over.
   */
  def playTurn
    @turn = (@turn + 1) % @players.length
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

  def checkEndOfGame
    province = cardInKingdom('Province')
    empties = @kingdom.select { |k| k.count == 0 }.length

    province.count == 0 or empties >= 3
  end


  def indexInKingdom(name)
    @kingdom.find_index { |k| k.card.name === name }
  end

  def cardInKingdom(name)
    @kingdom[indexInKingdom(name)]
  end

  def cardCost(card)
    # TODO: Bridge, Quarry
    card.cost
  end

  def log(str)
    # Do nothing
  end

  def logPlayer(str, p)
    log(p.name + ' ' + str)
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

