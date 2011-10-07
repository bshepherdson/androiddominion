package dominion

import dominion.Decision
import dominion.Option
import dominion.Game
import dominion.Utils
import dominion.Card

import java.util.ArrayList
import java.util.HashMap

class Player

  @@PHASE_NOT_PLAYING = 1
  @@PHASE_ACTION = 2
  @@PHASE_BUY = 3
  @@PHASE_CLEANUP = 4


  def initialize(name:String)
    # TODO: Set id and name properly. Do we need a game pointer?
    @name = name
    @turn = 1
    @discards = Card.starterDeck
    @deck = RubyList.new
    @inPlay = RubyList.new
    @duration = RubyList.new

    shuffleDiscards()
    @hand = RubyList.new

    @phase = @@PHASE_NOT_PLAYING
    @actions = 0
    @buys = 0
    @coins = 0
    @vpTokens = 0
  end


  def turnStart
    @phase = @@PHASE_ACTION
    @actions = 1
    @buys = 1
    @coins = 0

    # TODO: Outpost support
    logMe('starts turn ' + @turn + '.')

    # TODO: Duration rules
  end

  /* Returns true to continue playing actions, false to move to the next phase. */
  def turnActionPhase:boolean
    return false unless @actions > 0

    options = Utils.cardsToOptions(@hand)
    options.add(Option.new('buy', 'Proceed to Buy phase'))
    options.add(Option.new('coins', 'Play all basic coins and proceed to Buy phase.'))

    info = RubyList.new
    info.add('Actions: ' + @actions)
    info.add('Buys: ' + @buys)
    info.add('Coins: ' + @coins)

    dec = Decision.new(self, options, 'Play an Action card or proceed to the Buy phase.', info)

    key = Game.instance.decision dec
    if key.equals('buy')
      logMe('ends Action phase.')
    elsif key.equals('coin')
      logMe('ends Action phase.')
      playCoins()
    else
      index = Utils.keyToIndex(key)
      if index >= 0
        playAction(index)
        return true
      end
    end
    return false
  end


  def playAction(index:int):void
    if index < 0 or index >= @hand.size
      return
    end

    card = Card(@hand.get(index))
    if card.types & CardTypes.ACTION == 0
      return
    end

    removeFromHand(index)
    @inPlay.add(card)
    @actions -= 1

    logMe('plays ' + card.name + '.')
    card.runRules(self)
  end


  /* Returns true to continue buying, false to move to the next phase. */
  def turnBuyPhase:boolean
    @phase = @@PHASE_BUY

    if @buys <= 0
      return false
    end
    
    /* First, ask to play a coin or buy a card. */
    key = Utils.handDecision(self, 'Choose a treasure to play, or to buy a card.', 'Buy a card') { |c| Card(c).types & CardTypes.TREASURE > 0 }
    index = Utils.keyToIndex key
    if index >= 0
      card = Card(@hand.get(index))
      removeFromHand(index)
      @inPlay.add(card)
      @coins += Card.treasureValues(card.name)

      logMe('plays ' + card.name + '.')
      return true
    end
      
    /* player chose to buy a card */
    info = RubyList.new
    info.add('Buys: ' + @buys)
    info.add('Coins: ' + @coins)

    # TODO: Contraband handling

    coins = @coins
    key = Utils.gainCardDecision(self, 'Buy cards or end your turn.', 'Done buying. End your turn.', info) { |card| Game.instance.cardCost(Card(card)) <= coins }
    index = Utils.keyToIndex(key)
    if index >= 0
      buyCard(index, false)
      return true
    else
      return false
    end
  end


  /* Index into the kingdom, and true if we're buying for free */
  /* Returns whether the purchase was successful. */
  def buyCard(index:int, free:boolean):boolean
    inKingdom = Kingdom(Game.instance.kingdom.get(index))
    if inKingdom.count <= 0
      logMe('fails to ' + (free ? 'gain' : 'buy') + ' ' + inKingdom.card.name + ' because the Supply pile is empty.')
      return false
    end

    @discards.add(inKingdom.card)
    inKingdom.count -= 1

    logMe((free ? 'gains' : 'buys') +' '+ inKingdom.card.name + '.')

    if inKingdom.count == 1
      Game.instance.log('There is only one ' + inKingdom.card.name + ' remaining.')
    elsif inKingdom.count == 0
      Game.instance.log('The ' + inKingdom.card.name + ' pile is empty.')
    end

    if not free
      @coins -= Game.instance.cardCost(inKingdom.card)
      @buys -= 1
    end

    return true
  end

  def turnCleanupPhase
    @phase = @@PHASE_CLEANUP

    @discards.addAll(@inPlay)
    @discards.addAll(@hand)
    @inPlay = RubyList.new
    @hand = RubyList.new
  end

  def turnEnd
    logMe('ends turn.')
    @phase = @@PHASE_NOT_PLAYING
    @turn += 1
  end

  def draw(n:int):int
    i = 0
    while i < n
      if @deck.isEmpty
        logMe('reshuffles.')
        shuffleDiscards
        if @deck.isEmpty
          return i
        end
      end

      card = @deck.pop
      @hand.add(card)
      i += 1
    end
    return n
  end

  def removeFromHand(index:int):void
    @hand = @hand.select_index do |c,i| i != index end
    return
  end

  def discard(index:int)
    card = Card(@hand.get(index))
    logMe('discards ' + card.name + '.')
    removeFromHand(index)
    @discards.add(card)
  end

  def shuffleDiscards
    i = @discards.size
    if i == 0
      return
    end

    begin
      i -= 1
      j = int(Math.floor(Math.random()*(i+1)))
      tempi = @discards.get(i)
      tempj = @discards.get(j)
      @discards.set(i, tempj)
      @discards.set(j, tempi)
    end while i > 0

    @deck = @discards
    @discards = RubyList.new
  end

  def calculateScore:int
    score = 0
    gardens = 0

    deck = RubyList.new
    deck.addAll(@hand)
    deck.addAll(@deck)
    deck.addAll(@discards)

    i = 0
    while i < deck.size
      c = Card(deck.get(i))
      if c.name.equals('Gardens')
        gardens += 1
      elsif c.types & CardTypes.VICTORY > 0
        score += Card.victoryValues(c.name)
      elsif c.name.equals('Curse')
        score -= 1
      end
    end

    score += gardens * (deck.size / 10)
    return score
  end

  def safeFromAttack:String
    if @hand.include? Card.cards('Moat')
      return 'Moat'
    end

    return nil
  end

  def playCoins:void
    i = 0
    while i < @hand.size
      card = Card(@hand.get(i))
      if Card.basicCoin?(card.name)
        removeFromHand(i)
        @inPlay.add(card)
        @coins += Card.treasureValues(card.name)
      else
        i += 1
      end
    end
  end

  def logMe(str:String):void
    Game.instance.logPlayer(str, self)
  end

  def id:int
    @id
  end
  def id=(v:int)
    @id = v
  end

  def name:String
    @name
  end
  def name=(v:String)
    @name = v
  end

  def turn:int
    @turn
  end
  def turn=(v:int)
    @turn = v
  end

  def discards:RubyList
    @discards
  end
  def discards=(v:RubyList)
    @discards = v
  end

  def deck:RubyList
    @deck
  end
  def deck=(v:RubyList)
    @deck = v
  end

  def inPlay:RubyList
    @inPlay
  end
  def inPlay=(v:RubyList)
    @inPlay = v
  end

  def hand:RubyList
    @hand
  end
  def hand=(v:RubyList)
    @hand = v
  end

  def phase:int
    @phase
  end
  def phase=(v:int)
    @phase = v
  end

  def actions:int
    @actions
  end
  def actions=(v:int)
    @actions = v
  end

  def buys:int
    @buys
  end
  def buys=(v:int)
    @buys = v
  end

  def coins:int
    @coins
  end
  def coins=(v:int)
    @coins = v
  end
end

