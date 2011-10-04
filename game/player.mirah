package dominion

require 'decision'
require 'utils'

class Player

  PHASE_NOT_PLAYING = 1
  PHASE_ACTION = 2
  PHASE_BUY = 3
  PHASE_CLEANUP = 4

  attr_accessor id, name, turn, discards, deck, inPlay, duration, hand, phase, actions, buys, coins, temp, vpTokens

  def initialize
    # TODO: Set id and name properly. Do we need a game pointer?
    @turn = 1;
    @discards = Cards.starterDeck
    @deck = [];
    @inPlay = [];
    @duration = [];

    shuffleDiscards();
    @hand = [];

    @phase = PHASE_NOT_PLAYING
    @actions = 0;
    @buys = 0;
    @coins = 0;
    @vpTokens = 0;

    @temp = {};
    @temp['gainedLastTurn'] = [];
    @temp['Contraband cards'] = [];
  end


  def turnStart
    @phase = PHASE_ACTION
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
    @phase = PHASE_BUY

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
  def buyCard(index, free)
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
    @phase = PHASE_CLEANUP

    @inPlay.each { |c| @discards.push(c) }
    @hand.each { |c| @discards.push(c) }
    @inPlay = []
    @hand = []
  end

  def turnEnd
    logMe('ends turn.')
    @phase = PHASE_NOT_PLAYING
    @turn += 1
  end

  def draw(n = 1)
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

  def discard(index)
    card = @hand[index]
    logMe('discards ' + card.name + '.')
    removeFromHand(index)
    @discards.push(card)
  end

  def shuffleDiscards
    i = @discards.length
    return if i == 0 # deck is unchanged
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

end

