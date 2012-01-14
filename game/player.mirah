package dominion

import dominion.Decision
import dominion.Option
import dominion.Game
import dominion.Utils
import dominion.Card

import java.util.ArrayList
import java.util.HashMap

class Player

  def self.bootstrap
    @@PHASE_NOT_PLAYING = 1
    @@PHASE_ACTION = 2
    @@PHASE_BUY = 3
    @@PHASE_CLEANUP = 4
    @@nextId = 0
  end

  def initialize(name:String)
    @id = @@nextId
    @@nextId += 1

    @name = name
    @turn = 1
    @discards = Card.starterDeck
    @deck = RubyList.new
    @inPlay = RubyList.new
    @durationCards = RubyList.new
    @durationRules = RubyList.new
    @durationTurnCount = 1

    shuffleDiscards()
    @hand = RubyList.new
    draw(5)

    @phase = @@PHASE_NOT_PLAYING
    @actions = 0
    @buys = 0
    @coins = 0
    @vpTokens = 0

    @outpostTurns = 0
    @havenCards = RubyList.new
    @nativeVillageMat = RubyList.new
    @gainedLastTurn = RubyList.new
    @islandSetAside = RubyList.new
    @pirateShipAttack = 0
    @pirateShipCoins = 0
    @outpostPlayed = false
    @consecutiveTurns = 0
    @lastLogIndex = 0
    @contrabandCards = RubyList.new
  end


  def turnStart
    @phase = @@PHASE_ACTION
    @actions = 1
    @buys = 1
    @coins = 0
    @gainedLastTurn.clear
    @consecutiveTurns += 1

    if @outpostPlayed
      logMe('starts their Outpost turn.')
      @outpostPlayed = false
    else
      logMe('starts turn ' + @turn + '.')
    end

    @durationRules.each do |c_|
      c = DurationCard(c_)
      logMe('gets the delayed effect of ' + c.name + '.')
      c.runDurationRules(self)
    end
    @durationRules.clear
  end

  /* Returns true to continue playing actions, false to move to the next phase. */
  def turnActionPhase:boolean
    return false unless @actions > 0

    options = Utils.cardsToOptions(@hand)
    options.add(Option.new('buy', 'Proceed to Buy phase'))
    options.add(Option.new('coins', 'Play all basic coins and proceed to Buy phase.'))

    dec = Decision.new(self, options, 'Play an Action card or proceed to the Buy phase.', RubyList.new)

    key = Game.instance.decision dec
    if key.equals('buy')
      logMe('ends Action phase.')
    elsif key.equals('coins')
      logMe('ends Action phase.')
      playCoins()
    else
      index = Utils.keyToIndex(key)
      if index >= 0
        playAction(Card(@hand.get(index)))
        return true
      end
    end
    return false
  end


  def playAction(card:Card):void
    if card.types & CardTypes.ACTION == 0
      return
    end

    removeFromHand(card)
    @inPlay.add(card)
    @actions -= 1

    # If modifying this part of the code, update Throne Room/King's Court
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
    treasures = @hand.select { |c| Card(c).types & CardTypes.TREASURE > 0 }
    nonBasic = treasures.select { |c| not Card.isBasicCoin(Card(c).name) }
    if nonBasic.size > 0
      card = Utils.handDecision(self, 'Choose a treasure to play, or to buy a card.', 'Buy a card', treasures)
      if card != nil
        removeFromHand(card)
        @inPlay.add(card)
        @coins += Card.treasureValues(card.name)

        logMe('plays ' + card.name + '.')
        card.runRules(self)

        return true
      end
    elsif treasures.size > 0
      playCoins
    end

    coins = @coins
    contraband = @contrabandCards
    affordableCards = Game.instance.kingdom.select do |k_| 
      k = Kingdom(k_)
      Game.instance.cardCost(k.card) <= coins and not contraband.includes(k.card)
    end
    kCard = Utils.gainCardDecision(self, 'Buy cards or end your turn.', 'Done buying. End your turn.', RubyList.new, affordableCards)
    if kCard != nil
      buyCard(kCard, false)
      return true
    else
      return false
    end
  end


  /* Pointer to the kingdom, and true if we're buying for free */
  /* Returns true if the card was bought successfully. */
  def buyCard(inKingdom:Kingdom, free:boolean):boolean
    if inKingdom.count <= 0
      logMe('fails to ' + (free ? 'gain' : 'buy') + ' ' + inKingdom.card.name + ' because the Supply pile is empty.')
      return false
    end

    @discards.add(inKingdom.card)
    inKingdom.count -= 1

    @gainedLastTurn.add(GainedCard.new(!free, inKingdom.card))

    logMe((free ? 'gains' : 'buys') +' '+ inKingdom.card.name + '.')

    if inKingdom.card.types & CardTypes.VICTORY > 0
      if not Game.instance.victoryCardMap.containsKey(inKingdom.card.name)
        Game.instance.victoryCardMap.put(inKingdom.card.name, inKingdom.card)
        Game.instance.tradeRouteCoins += 1
      end
    end

    if inKingdom.count == 1
      Game.instance.log('There is only one ' + inKingdom.card.name + ' remaining.')
    elsif inKingdom.count == 0
      Game.instance.log('The ' + inKingdom.card.name + ' pile is empty.')
    end

    if not free
      @coins -= Game.instance.cardCost(inKingdom.card)
      @buys -= 1

      if inKingdom.embargoTokens > 0
        i = 0
        while i < inKingdom.embargoTokens
          buyCard(Game.instance.inKingdom('Curse'), true)
          i += 1
        end
      end

      talismanCards = @inPlay.select { |c| Card(c).name.equals('Talisman') }
      talismans = talismanCards.size
      if talismans > 0 and inKingdom.card.types & CardTypes.VICTORY == 0 and Game.instance.cardCost(inKingdom.card) <= 4
        while talismans > 0
          logMe('gains a copy for Talisman.')
          buyCard(inKingdom, true)
          talismans -= 1
        end
      end
    end

    return true
  end

  def turnCleanupPhase
    @phase = @@PHASE_CLEANUP

    @discards.addAll(@durationCards)
    @durationCards = RubyList.new
    @contrabandCards = RubyList.new
    treasuries = RubyList.new

    while @inPlay.size > 0
      card = Card(@inPlay.pop)
      if card.types & CardTypes.DURATION > 0
        @durationCards.add(card)
      elsif card.name.equals('Treasury')
        treasuries.add(card)
      else
        @discards.add(card)
      end
    end

    while @hand.size > 0
      card = Card(@hand.pop)
      if card.name.equals('Treasury')
        treasuries.add(card)
      else
        @discards.add(card)
      end
    end

    @inPlay = RubyList.new
    @hand = RubyList.new

    if treasuries.size > 0
      victoryCardsBought = @gainedLastTurn.select do |c_|
        c = GainedCard(c_)
        c.bought && (c.card.types & CardTypes.VICTORY > 0)
      end

      if victoryCardsBought.size > 0
        logMe('cannot put Treasuries on top because they bought a Victory card this turn.')
      else
        options = RubyList.new
        options.add(Option.new('yes', 'Yes'))
        options.add(Option.new('no',  'No'))
        dec = Decision.new(self, options, 'Do you want to put ' + treasuries.size + ' Treasur' + (treasuries.size == 1 ? 'y' : 'ies') + ' on top of your deck?', RubyList.new)
        key = Game.instance.decision(dec)

        if key.equals('yes')
          @deck.addAll(treasuries)
          logMe('puts ' + treasuries.size + ' Treasur' + (treasuries.size == 1 ? 'y' : 'ies') + ' on top of their deck.')
        else
          @discards.addAll(treasuries)
          logMe('discards their Treasuries.')
        end
      end
    end

    draw(@outpostPlayed ? 3 : 5)
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

  def removeFromHand(card:Card):Card
    newhand = RubyList.new
    i = 0
    found = false
    while i < @hand.size
      if (not found) and Card(@hand.get(i)) == card
        found = true
      else
        newhand.add(@hand.get(i))
      end
      i += 1
    end
    @hand = newhand
    return card
  end

  def discard(card:Card)
    removeFromHand(card)
    logMe('discards ' + card.name + '.')
    @discards.add(card)
  end

  def shuffleDiscards:void
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
    deck.addAll(@islandSetAside)
    deck.addAll(@havenCards)

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
      i += 1
    end

    score += gardens * (deck.size / 10)
    score += @vpTokens
    return score
  end

  def safeFromAttack:String
    if @hand.includes_exact Card.cards('Moat')
      return 'Moat'
    elsif @durationCards.includes_exact Card.cards('Lighthouse')
      return 'Lighthouse'
    end

    return nil
  end

  def playCoins:void
    i = 0
    while i < @hand.size
      card = Card(@hand.get(i))
      if Card.isBasicCoin(card.name)
        removeFromHand(card)
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

  def durationCards:RubyList
    @durationCards
  end
  def durationCards=(v:RubyList)
    @durationCards = v
  end

  def durationRules:RubyList
    @durationRules
  end
  def durationRules=(v:RubyList)
    @durationRules = v
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

  def havenCards:RubyList
    @havenCards
  end
  def havenCards=(v:RubyList)
    @havenCards = v
  end

  def nativeVillageMat:RubyList
    @nativeVillageMat
  end
  def nativeVillageMat=(v:RubyList)
    @nativeVillageMat = v
  end

  def gainedLastTurn:RubyList
    @gainedLastTurn
  end
  def gainedLastTurn=(v:RubyList)
    @gainedLastTurn = v
  end
  
  def islandSetAside:RubyList
    @islandSetAside
  end

  def pirateShipAttack:int
    @pirateShipAttack
  end
  def pirateShipAttack=(v:int)
    @pirateShipAttack = v
  end

  def pirateShipCoins:int
    @pirateShipCoins
  end
  def pirateShipCoins=(v:int)
    @pirateShipCoins = v
  end

  def outpostPlayed:boolean
    @outpostPlayed
  end
  def outpostPlayed=(v:boolean)
    @outpostPlayed = v
  end

  def consecutiveTurns:int
    @consecutiveTurns
  end
  def consecutiveTurns=(v:int)
    @consecutiveTurns = v
  end

  def lastLogIndex:int
    @lastLogIndex
  end
  def lastLogIndex=(v:int)
    @lastLogIndex = v
  end

  def vpTokens:int
    @vpTokens
  end
  def vpTokens=(v:int)
    @vpTokens = v
  end

  def contrabandCards:RubyList
    @contrabandCards
  end
  def contrabandCards=(v:RubyList)
    @contrabandCards = v
  end

end

class GainedCard
  def initialize(bought:boolean, card:Card)
    @bought = bought
    @card = card
  end
  
  def bought:boolean
    return @bought
  end

  def card:Card
    return @card
  end
end

