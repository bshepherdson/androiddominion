package dominion

import dominion.Player
import dominion.Decision
import dominion.Card
import dominion.Exchange

import java.io.BufferedReader
import java.io.InputStreamReader
import java.util.HashMap


class Game
  def initialize
    @players = RubyList.new
    @turn = -1
    @kingdom = RubyList.new

    @tradeRouteCoins = 0
    @victoryCardMap = HashMap.new
    @quarries = 0
  end

  def isStarted:boolean
    @turn >= 0
  end

  def addPlayer(name:String):Player
    p = Player.new(name, self)
    @players.add(p)
    p
  end

  def exchange=(exchange:Exchange):void
    @exchange = exchange
  end

  def decision(dec:Decision):String
    key = @exchange.postDecision(dec)
    dec.player.lastLogIndex = @exchange.getLogSize
    key
  end

  def startGame
    cards = Card.drawKingdom
    playerCount = @players.size
    kingdom.addAll(cards.collect do |c_|
      c = Card(c_)
      Kingdom.new c, Card(c).cardCount(playerCount)
    end)

    r = int(Math.floor(Math.random()*kingdom.size))
    prosperity = Kingdom(kingdom.get(r)).card.set == CardSets.PROSPERITY

    @kingdom.add(Kingdom.new(Card.cards('Copper'), 1000))
    @kingdom.add(Kingdom.new(Card.cards('Silver'), 1000))
    @kingdom.add(Kingdom.new(Card.cards('Gold'), 1000))
    if prosperity
      @kingdom.add(Kingdom.new(Card.cards('Platinum'), 12))
    end

    @kingdom.add(Kingdom.new(Card.cards('Estate'), Card.cards('Estate').cardCount(@players.size)))
    @kingdom.add(Kingdom.new(Card.cards('Duchy'), Card.cards('Duchy').cardCount(@players.size)))
    @kingdom.add(Kingdom.new(Card.cards('Province'), Card.cards('Province').cardCount(@players.size)))
    if prosperity
      @kingdom.add(Kingdom.new(Card.cards('Colony'), Card.cards('Colony').cardCount(@players.size)))
    end

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
    @quarries = 0
    p.turnEnd

    over = checkEndOfGame
    if over
      return true
    elsif p.outpostPlayed && p.consecutiveTurns < 2
      @turn -= 1
      return playTurn
    else
      p.consecutiveTurns = 0
      p.outpostPlayed = false
      return false
    end
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
    if card.types & CardTypes.ACTION > 0
      Math.max(card.cost - 2*@quarries, 0)
    else
      card.cost
    end
  end

  def log(str:String):void
    @exchange.log(str)
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

  def tradeRouteCoins:int
    @tradeRouteCoins
  end
  def tradeRouteCoins=(v:int)
    @tradeRouteCoins = v
  end

  def victoryCardMap:HashMap
    @victoryCardMap
  end
  def victoryCardMap=(v:HashMap)
    @victoryCardMap = v
  end

  def quarries:int
    @quarries
  end
  def quarries=(v:int)
    @quarries = v
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

  def embargoTokens:int
    @embargoTokens
  end
  def embargoTokens=(v:int)
    @embargoTokens = v
  end


  def initialize(card:Card, count:int)
    @card = card
    @count = count
  end
end

