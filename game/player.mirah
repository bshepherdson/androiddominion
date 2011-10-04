package dominion

import dominion.Decision
import dominion.Option
import dominion.Game
import dominion.Utils

class Player

  @@PHASE_NOT_PLAYING = 1
  @@PHASE_ACTION = 2
  @@PHASE_BUY = 3
  @@PHASE_CLEANUP = 4


  def initialize
    # TODO: Set id and name properly. Do we need a game pointer?
    @turn = 1;
    @discards = Cards.starterDeck
    @deck = [];
    @inPlay = [];
    @duration = [];

    shuffleDiscards();
    @hand = [];

    @phase = @@PHASE_NOT_PLAYING
    @actions = 0;
    @buys = 0;
    @coins = 0;
    @vpTokens = 0;

    @temp = {};
    @temp['gainedLastTurn'] = [];
    @temp['Contraband cards'] = [];
  end


  def turnStart
    @phase = @@PHASE_ACTION
    @actions = 1
    @buys = 1
    @coins = 0
    @temp['gainedLastTurn'] = [];

    # TODO: Outpost support
    logMe('starts turn ' + @turn + '.')

    # TODO: Duration rules
  end

  /* Returns true to continue playing actions, false to move to the next phase. */
  def turnActionPhase
    return false unless @actions > 0

    options = Utils.cardsToOptions(@hand)
    options.push(Option.new('buy', 'Proceed to Buy phase'))
    options.push(Option.new('coins', 'Play all basic coins and proceed to Buy phase.'))
    dec = Decision.new(self, options, 'Play an Action card or proceed to the Buy phase.', [
      'Actions: ' + @actions,
      'Buys: ' + @buys,
      'Coins: ' + @coins
    ])
    key = Game.instance.decision dec
    if key === 'buy'
      logMe('ends Action phase.')
    elsif key === 'coin'
      logMe('ends Action phase.')
      playCoins()
    else
      index = Utils.keyToIndex(key)
      if index
        playAction(index)
        return true
      end
    end
    return false
  end

  /* Returns true to continue buying, false to move to the next phase. */
  def turnBuyPhase
    @phase = @@PHASE_BUY

    if @buys <= 0
      return false
    end
    
    /* First, ask to play a coin or buy a card. */
    key = Utils.handDecision(self, 'Choose a treasure to play, or to buy a card.', 'Buy a card') { |c| c.types['Treasure'] }
    index = Utils.keyToIndex key
    if index
      card = @hand[index]
      removeFromHand(index)
      @inPlay.push(card)
      @coin += Card.treasureValues[card.name]

      logMe('plays ' + card.name + '.')
      return true
    end
      
    /* player chose to buy a card */
    info = [
      'Buys: ' + @buys,
      'Coins: ' + @coins
    ]

    # TODO: Contraband handling

    key = Utils.gainCardDecision(self, 'Buy cards or end your turn.', 'Done buying. End your turn.', info) { |card| Game.instance.cardCost(card) <= @coins }
    index = Utils.keyToIndex(key)
    if index
      buyCard(index, false)
      return true
    else
      return false
    end
  end


  /* Index into the kingdom, and true if we're buying for free */
  def buyCard(index:Integer, free:Boolean)
    inKingdom = Game.instance.kingdom[index]
    if inKingdom.count <= 0
      logMe('fails to ' + (free ? 'gain' : 'buy') + ' ' + inKingdom.card.name + ' because the Supply pile is empty.')
      return false;
    end

    @discards.push(inKingdom.card)
    inKingdom.count -= 1

    logMe((free ? 'gains' : 'buys') +' '+ inKingdom.card.name + '.')

    if inKingdom.count == 1
      Game.instance.log('There is only one ' + inKingdom.card.name + ' remaining.')
    elsif inKingdom.count == 0
      Game.instance.log('The ' + inKingdom.card.name + ' pile is empty.')
    end

    if not free
      @coin -= Game.instance.cardCost(inKingdom.card)
      @buys -= 1
    end

    return true
  end

  def turnCleanupPhase
    @phase = @@PHASE_CLEANUP

    @inPlay.each { |c| @discards.push(c) }
    @hand.each { |c| @discards.push(c) }
    @inPlay = []
    @hand = []
  end

  def turnEnd
    logMe('ends turn.')
    @phase = @@PHASE_NOT_PLAYING
    @turn += 1
  end

  def draw(n:Integer)
    i = 0
    while i < n
      if @deck.length == 0
        logMe('reshuffles.')
        shuffleDiscards
        return i if @deck.length == 0 # nothing to draw. rare but possible.
      end

      card = @deck.pop
      @hand.push(card)
      i += 1
    end
    return drawn
  end

  def discard(index:Integer)
    card = @hand[index]
    logMe('discards ' + card.name + '.')
    removeFromHand(index)
    @discards.push(card)
  end

  def shuffleDiscards
    i = @discards.length
    return if i == 0
    begin
      i -= 1
      j = rand(i+1)
      tempi = @discards[i]
      tempj = @discards[j]
      @discards[i] = tempj;
      @discards[j] = tempi;
    end while i > 0

    @deck = @discards
    @discards = []
  end
end

  /*
  def calculateScore
    score = 0
    gardens = 0

    deck = @hand + @deck + @discards
    deck.each do |c|
      if c.name === 'Gardens'
        gardens += 1
      elsif c.types['Victory']
        score += Card.victoryValues[c.name]
      elsif c.types['Curse']
        score -= 1
      end
    end

    score += gardens * deck.length.div(10)
    return score
  end

  def safeFromAttack
    if @hand.include? Card.cards['Moat']
      return 'Moat'
    end

    return nil
  end

  def logMe(str)
    Game.instance.logPlayer(str, self)
  end

  def id:Integer
    @id
  end
  def id=(v:Integer)
    @id = v
  end

  def name:String
    @name
  end
  def name=(v:String)
    @name = v
  end

  def turn:Integer
    @turn
  end
  def turn=(v:Integer)
    @turn = v
  end

  def discards:ArrayList
    @discards
  end
  def discards=(v:ArrayList)
    @discards = v
  end

  def deck:ArrayList
    @deck
  end
  def deck=(v:ArrayList)
    @deck = v
  end

  def inPlay:ArrayList
    @inPlay
  end
  def inPlay=(v:ArrayList)
    @inPlay = v
  end

  def hand:ArrayList
    @hand
  end
  def hand=(v:ArrayList)
    @hand = v
  end

  def phase:Integer
    @phase
  end
  def phase=(v:Integer)
    @phase = v
  end

  def actions:Integer
    @actions
  end
  def actions=(v:Integer)
    @actions = v
  end

  def buys:Integer
    @buys
  end
  def buys=(v:Integer)
    @buys = v
  end

  def coins:Integer
    @coins
  end
  def coins=(v:Integer)
    @coins = v
  end
end
  */

