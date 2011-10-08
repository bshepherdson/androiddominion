package dominion

import dominion.Game
import dominion.Player
import dominion.Card
import dominion.CardTypes
import dominion.CardSets

import java.util.HashMap

/*
 * Plans for handling the rules. Card superclass has runRules method that implements
 * the rules. It takes as an argument the current player, and returns void.
 * For handling all-players rules, that logic is implemented using two functions in
 * the Card superclass that take a block.
 */

class Card
  @@cards

  def initialize(name:String, set:int, types:int, cost:int, text:String)
    @name = name
    @set = set
    @types = types
    @cost = cost
    @text = text
  end

  def name:String
    @name
  end
  def set:int
    @set
  end
  def types:int
    @types
  end
  def cost:int
    @cost
  end
  def text:String
    @text
  end

  def self.cards(name:String):Card
    # looks up the card in the hash and returns it
    Card(@@cards.get(name))
  end
  def self.allCards:HashMap
    @@cards
  end

  # abstract method to be implemented by each subclass.
  def runRules(p:Player):void; end

  # helper rules
  def plusCoins(p:Player, n:int)
    p.coins += n
    p.logMe 'gains +' + n + ' Coin' + (n == 1 ? '' : 's') + '.'
  end

  def plusBuys(p:Player, n:int)
    p.buys += n
    p.logMe 'gains +' + n + ' Buy' + (n == 1 ? '' : 's') + '.'
  end

  def plusActions(p:Player, n:int)
    p.actions += n
    p.logMe 'gains +' + n + ' Action' + (n == 1 ? '' : 's') + '.'
  end

  def plusCards(p:Player, n:int)
    p.draw n
    p.logMe 'gains +' + n + ' Card' + (n == 1 ? '' : 's') + '.'
  end

  # abstract function called by everyPlayer
  def runEveryPlayer(p:Player, o:Player):void
    puts "ERROR: runEveryPlayer called but not overridden."
    System.exit(2)
  end

  def everyPlayer(p:Player, includeMe:boolean, isAttack:boolean):void
    i = 0
    while i < Game.instance.players.size
      o = Player(Game.instance.players.get(i))
      if includeMe or o.id != p.id
        protectedBy = o.safeFromAttack
        if isAttack and protectedBy != nil and (not protectedBy.isEmpty())
          o.logMe 'is protected by ' + protectedBy + '.'
        else
          runEveryPlayer p, o
        end
      end
      i += 1
    end
  end

  def yesNo(p:Player, question:String):String
    options = RubyList.new
    options.add(Option.new('yes', 'Yes.'))
    options.add(Option.new('no', 'No.'))

    dec = Decision.new p, options, question, RubyList.new
    Game.instance.decision(dec)
  end

  def self.victoryValues(name:String):int
    if name.equals('Estate')
      return 1
    elsif name.equals('Duchy')
      return 3
    elsif name.equals('Province')
      return 6
    end
    return 0
  end

  def self.treasureValues(name:String):int
    if name.equals('Copper')
      return 1
    elsif name.equals('Silver')
      return 2
    elsif name.equals('Gold')
      return 3
    end
    return 0
  end

  def self.basicCoin?(name:String):boolean
    name.equals('Copper') or name.equals('Silver') or name.equals('Gold')
  end


  def self.starterDeck:RubyList
    deck = RubyList.new
    deck.add(Card.cards('Copper'))
    deck.add(Card.cards('Copper'))
    deck.add(Card.cards('Copper'))
    deck.add(Card.cards('Copper'))
    deck.add(Card.cards('Copper'))
    deck.add(Card.cards('Copper'))
    deck.add(Card.cards('Copper'))
    deck.add(Card.cards('Estate'))
    deck.add(Card.cards('Estate'))
    deck.add(Card.cards('Estate'))
    deck
  end

  def self.drawKingdom:RubyList
    all = RubyList.new
    all.addAll(@@cards.values)
    kingdomCards = all.select do |c|
      Card(c).set != CardSets.COMMON
    end

    drawn = RubyList.new

    while drawn.size < 10 and drawn.size < kingdomCards.size
      i = int(Math.floor(Math.random()*kingdomCards.size))
      if not drawn.include?(kingdomCards.get(i))
        drawn.add(kingdomCards.get(i))
      end
    end

    drawn
  end


  def cardCount(players:int):int
    10
  end

  def self.initializeCards
    @@cards = HashMap.new
    # Common
    @@cards.put('Gold', Gold.new)
    @@cards.put('Silver', Silver.new)
    @@cards.put('Copper', Copper.new)
    @@cards.put('Estate', Estate.new)
    @@cards.put('Duchy', Duchy.new)
    @@cards.put('Province', Province.new)
    @@cards.put('Curse', Curse.new)

    # Base
    @@cards.put('Cellar', Cellar.new)
    @@cards.put('Chapel', Chapel.new)
    @@cards.put('Chancellor', Chancellor.new)
    @@cards.put('Village', Village.new)
    @@cards.put('Woodcutter', Woodcutter.new)
    @@cards.put('Gardens', Gardens.new)
    @@cards.put('Moneylender', Moneylender.new)
    @@cards.put('Workshop', Workshop.new)
    @@cards.put('Bureaucrat', Bureaucrat.new)
    @@cards.put('Feast', Feast.new)
    @@cards.put('Moat', Moat.new)
    @@cards.put('Militia', Militia.new)
    @@cards.put('Remodel', Remodel.new)
    @@cards.put('Smithy', Smithy.new)
    @@cards.put('Spy', Spy.new)
    @@cards.put('Thief', Thief.new)
    @@cards.put('Throne Room', ThroneRoom.new)
    @@cards.put('Council Room', CouncilRoom.new)
    @@cards.put('Festival', Festival.new)
    @@cards.put('Laboratory', Laboratory.new)
    @@cards.put('Library', Library.new)
    @@cards.put('Mine', Mine.new)
    @@cards.put('Market', Market.new)
    @@cards.put('Witch', Witch.new)
    @@cards.put('Adventurer', Adventurer.new)
  end

end


class BasicCoin < Card
  def initialize(name:String, cost:int)
    super(name, CardSets.COMMON, CardTypes.TREASURE, cost, '')
  end

  def cardCount(players:int)
    1000
  end
end

class Gold   < BasicCoin; def initialize; super('Gold',   6); end; end
class Silver < BasicCoin; def initialize; super('Silver', 3); end; end
class Copper < BasicCoin; def initialize; super('Copper', 0); end; end


class BasicVictory < Card
  def initialize(name:String, cost:int)
    super(name, CardSets.COMMON, CardTypes.VICTORY, cost, '')
  end

  def cardCount(players:int)
    players > 2 ? 12 : 8;
  end
end

class Estate   < BasicVictory; def initialize; super('Estate',   2); end; end
class Duchy    < BasicVictory; def initialize; super('Duchy',    5); end; end
class Province < BasicVictory; def initialize; super('Province', 8); end; end

class Curse < Card
  def initialize
    super('Curse', CardSets.COMMON, CardTypes.CURSE, 0, '')
  end
  
  def cardCount(players:int)
    if players <= 2
      10
    elsif players == 3
      20
    else
      30
    end
  end
end


##########################################################
# KINGDOM CARDS
##########################################################

class Cellar < Card
  def initialize
    super('Cellar', CardSets.BASE, CardTypes.ACTION, 2, '+1 Action. Discard any number of cards. +1 Card per card discarded.')
  end

  def runRules(p:Player)
    plusActions p, 1

    discards = 0
    while not p.hand.isEmpty
      card = Utils.handDecision(p, 'Choose a card to discard, or stop discarding.', 'Done discarding.', p.hand)

      if card == nil
        break
      end
      p.discard(card)
      discards += 1
    end

    if discards > 0
      plusCards p, discards
    end
  end
end


class Chapel < Card
  def initialize
    super('Chapel', CardSets.BASE, CardTypes.ACTION, 2, 'Trash up to 4 cards from your hand.')
  end

  def runRules(p:Player)
    trashed = 0
    while trashed < 4
      card = Utils.handDecision(p, 'Choose a card to trash, or stop trashing.', 'Done trashing.', p.hand)
      if card == nil
        break
      end

      p.removeFromHand(card)
      p.logMe('trashes ' + card.name + '.')
      trashed += 1
    end
  end
end


class Chancellor < Card
  def initialize
    super('Chancellor', CardSets.BASE, CardTypes.ACTION, 3, '+2 Coins. You may immediately put your deck into your discard pile.')
  end

  def runRules(p:Player)
    plusCoins p, 2
    key = yesNo p, 'Do you want to move your deck to your discard pile?'
    if key.equals('yes')
      p.discards.addAll(p.deck)
      p.deck = RubyList.new
      p.logMe('moves their deck to their discard pile.')
    end
  end
end


class Village < Card
  def initialize
    super('Village', CardSets.BASE, CardTypes.ACTION, 3, '+1 Card, +2 Actions.')
  end

  def runRules(p:Player)
    plusCards p, 1
    plusActions p, 2
  end
end

class Woodcutter < Card
  def initialize
    super('Woodcutter', CardSets.BASE, CardTypes.ACTION, 3, '+1 Buy, +2 Coins.')
  end

  def runRules(p:Player)
    plusBuys p, 1
    plusCoins p, 2
  end
end


class Gardens < Card
  def initialize
    super('Gardens', CardSets.BASE, CardTypes.VICTORY, 4, 'Worth 1 Victory Point for every 10 cards in your deck (rounded down).')
  end

  def cardCount(players:int)
    players > 2 ? 12 : 8;
  end
end


class Moneylender < Card
  def initialize
    super('Moneylender', CardSets.BASE, CardTypes.ACTION, 4, 'Trash a Copper from your hand. If you do, +3 Coins.')
  end

  def runRules(p:Player)
    index = p.hand.indexOf(Card.cards('Copper'))
    if index >= 0
      p.logMe('trashes Copper.')
      p.removeFromHand(Card.cards('Copper'))
      plusCoins p, 3
    else
      p.logMe('has no Copper to trash.')
    end
  end
end


class Workshop < Card
  def initialize
    super('Workshop', CardSets.BASE, CardTypes.ACTION, 3, 'Gain a card costing up to 4 Coins.')
  end

  def runRules(p:Player):void
    kCards = Game.instance.kingdom.select { |k| Game.instance.cardCost(Kingdom(k).card) <= 4 }
    kCard = Utils.gainCardDecision(p, 'Gain a card costing up to 4 Coin.', nil, RubyList.new, kCards)
    p.buyCard(kCard, true)
  end
end


class Bureaucrat < Card
  def initialize
    super('Bureaucrat', CardSets.BASE, CardTypes.ACTION | CardTypes.ATTACK, 4, 'Gain a Silver card; put it on top of your deck. Each other player reveals a Victory card from his hand and puts it on his deck, or reveals a hand with no Victory cards.')
  end

  def runRules(p:Player)
    p.buyCard(Game.instance.inKingdom('Silver'), true)
    p.logMe('puts it on top of their deck.')
    p.deck.add(p.discards.pop)

    everyPlayer(p, false, true)
  end

  def runEveryPlayer(p:Player, o:Player):void
    victoryCards = o.hand.select { |c| Card(c).types & CardTypes.VICTORY > 0 }
    if victoryCards.size == 0
      o.logMe('reveals a hand with no Victory cards: ' + Utils.showCards(o.hand))
    elsif victoryCards.size == 1
      o.discard(Card(victoryCards.get(0)))
      o.logMe('puts it on top of their deck.')
      o.deck.add(o.discards.pop)
    else
      card = Utils.handDecision(o, 'Choose a Victory card to put on top of your deck.', nil, victoryCards)
      o.discard(card)
      o.logMe('puts it on top of their deck.')
      o.deck.add(o.discards.pop)
    end
  end
end


class Feast < Card
  def initialize
    super('Feast', CardSets.BASE, CardTypes.ACTION, 4, 'Trash this card. Gain a card costing up to 5 Coins.')
  end

  def runRules(p:Player)
    if Card(p.inPlay.get(p.inPlay.size-1)).name.equals('Feast')
      p.logMe('trashes Feast.')
      p.inPlay.pop
    end

    kCard = Utils.gainCardDecision(p, 'Gain a card costing up to 5 Coins.', nil, RubyList.new, Game.instance.kingdom.select { |k| Game.instance.cardCost(Kingdom(k).card) <= 5 })
    p.buyCard(kCard, true)
  end
end


class Moat < Card
  def initialize
    super('Moat', CardSets.BASE, CardTypes.ACTION | CardTypes.REACTION, 2, '+2 Cards. When another player plays an Attack card, you may reveal this from your hand. If you do, you are unaffected by that Attack.')
  end

  def runRules(p:Player)
    plusCards p, 2
  end
end


class Militia < Card
  def initialize
    super('Militia', CardSets.BASE, CardTypes.ACTION | CardTypes.ATTACK, 4, '+2 Coins. Each other player discards down to 3 cards in their hand.')
  end

  def runRules(p:Player)
    plusCoins p, 2
    everyPlayer(p, false, true)
  end

  def runEveryPlayer(p:Player, o:Player)
    if o.hand.size <= 3
      o.logMe('has only ' + Integer.new(o.hand.size).toString() + ' cards in hand.')
      return
    end

    while o.hand.size > 3
      card = Utils.handDecision(o, p.name + ' has played Militia. You must discard down to 3 cards in your hand; choose a card to discard.', nil, o.hand)
      o.discard card
    end
  end
end


class Remodel < Card
  def initialize
    super('Remodel', CardSets.BASE, CardTypes.ACTION, 4, 'Trash a card from your hand. Gain a card costing up to 2 Coins more than the trashes card.')
  end

  def runRules(p:Player)
    if p.hand.size == 0
      p.logMe('has no cards to trash.')
      return
    end

    toTrash = Utils.handDecision(p, 'Trash a card from your hand.', nil, p.hand)
    p.removeFromHand(toTrash)
    p.logMe('trashes ' + toTrash.name)

    newCost = Game.instance.cardCost(toTrash) + 2
    toGain = Utils.gainCardDecision(p, 'Gain a card costing up to ' + Integer.new(newCost).toString + '.', nil, RubyList.new, Game.instance.kingdom.select { |k| Game.instance.cardCost(Kingdom(k).card) <= newCost })
    p.buyCard(toGain, true)
  end
end


class Smithy < Card
  def initialize
    super('Smithy', CardSets.BASE, CardTypes.ACTION, 4, '+3 Cards.')
  end

  def runRules(p:Player)
    plusCards p, 3
  end
end
    

class Spy < Card
  def initialize
    super('Spy', CardSets.BASE, CardTypes.ACTION | CardTypes.ATTACK, 4, '+1 Card, +1 Action. Each player (including you) reveals the top card of his deck and either discards it or puts it back, your choice.')
  end

  def runRules(p:Player)
    plusCards p, 1
    plusActions p, 1
    everyPlayer(p, true, true)
  end

  def runEveryPlayer(p:Player, o:Player)
    options = RubyList.new
    options.add(Option.new('back', 'Put it back on the deck.'))
    options.add(Option.new('discard', 'Discard it.'))
    
    if o.deck.size == 0
      o.shuffleDiscards
      if o.deck.size == 0
        o.logMe('has no cards to draw.')
        return
      end
    end

    card = Card(o.deck.pop)
    o.logMe('reveals ' + card.name + '.')
    description = p.id == o.id ? 'You revealed a ' + card.name + '.' : o.name + ' revealed a ' + card.name + '.'

    dec = Decision.new(p, options, (p.id == o.id ? 'You' : o.name) + ' revealed a ' + card.name + '.', RubyList.new)
    key = Game.instance.decision(dec)
    if key.equals('discard')
      p.logMe('discards ' + (p.id == o.id ? 'their' : o.name + '\'s') + ' ' + card.name + '.')
      o.discards.add(card)
    else
      p.logMe('puts back ' + (p.id == o.id ? 'their' : o.name + '\'s') + ' ' + card.name + '.')
      o.deck.add(card)
    end
  end
end


class Thief < Card
  def initialize
    super('Thief', CardSets.BASE, CardTypes.ACTION | CardTypes.ATTACK, 4, 'Each other player reveals the top 2 cards of his deck. If they revealed any Treasure cards, they trash one of them that you choose. You may gain any or all of these trashed cards. They discard the other revealed cards.')
  end

  def runRules(p:Player)
    everyPlayer(p, false, true)
  end

  def runEveryPlayer(p:Player, o:Player)
    if o.deck.size == 0
      o.shuffleDiscards
      if o.deck.size == 0
        o.logMe('has no cards to reveal.')
        return
      end
    end

    cards = RubyList.new
    cards.add(o.deck.pop)
    if o.deck.size == 0
      o.shuffleDiscards
    end
    if o.deck.size > 0
      cards.add(o.deck.pop)
    end

    o.logMe('revealed ' + Utils.showCards(cards))
  
    if cards.size == 0
      return
    end

    options = RubyList.new
    if Card(cards.get(0)).types & CardTypes.TREASURE > 0
      options.add(Option.new('trash0', 'Trash ' + Card(cards.get(0)).name))
      options.add(Option.new('keep0', 'Keep ' + Card(cards.get(0)).name))
    end
    if cards.size > 1 and Card(cards.get(1)).types & CardTypes.TREASURE > 0
      options.add(Option.new('trash1', 'Trash ' + Card(cards.get(1)).name))
      options.add(Option.new('keep1', 'Keep ' + Card(cards.get(1)).name))
    end

    if options.size == 0
      return
    end

    info = RubyList.new
    info.add('Revealed: ' + Utils.showCards(cards))
    dec = Decision.new(p, options, 'Choose what to do with ' + o.name + '\'s revealed Treasures.', info)
    key = Game.instance.decision(dec)

    if key.equals('trash0')
      card = Card(cards.get(0))
      p.logMe('trashes ' + card.name)
      if cards.size > 1
        o.discards.add(cards.get(1))
      end
    elsif key.equals('keep0')
      card = Card(cards.get(0))
      p.logMe('keeps ' + card.name)
      p.discards.add(card)
      if cards.size > 1
        o.discards.add(cards.get(1))
      end
    elsif key.equals('trash1')
      card = Card(cards.get(1))
      p.logMe('trashes ' + card.name)
      o.discards.add(cards.get(0))
    elsif key.equals('keep1')
      card = Card(cards.get(1))
      p.logMe('keeps ' + card.name)
      p.discards.add(card)
      o.discards.add(cards.get(0))
    end
  end
end


class ThroneRoom < Card
  def initialize
    super('Throne Room', CardSets.BASE, CardTypes.ACTION, 4, 'Choose an Action card in your hand. Play it twice.')
  end

  def runRules(p:Player)
    actions = p.hand.select { |c| Card(c).types & CardTypes.ACTION > 0 }
    if actions.size == 0
      p.logMe('has no Actions in hand.')
      return
    end

    card = Utils.handDecision(p, 'Choose an Action card to play twice.', nil, actions)
    p.removeFromHand(card)
    p.inPlay.add(card)

    p.logMe('uses Throne Room on ' + card.name + '.')

    p.logMe('plays ' + card.name + ' once.')
    card.runRules(p)
    p.logMe('plays ' + card.name + ' again.')
    card.runRules(p)
  end
end


class CouncilRoom < Card
  def initialize
    super('Council Room', CardSets.BASE, CardTypes.ACTION, 5, '+4 Cards, +1 Buy. Each other player draws a card.')
  end

  def runRules(p:Player)
    plusCards p, 4
    plusBuys p, 1
    everyPlayer(p, false, false)
  end

  def runEveryPlayer(p:Player, o:Player)
    plusCards o, 1
  end
end


class Festival < Card
  def initialize
    super('Festival', CardSets.BASE, CardTypes.ACTION, 5, '+2 Actions, +1 Buy, +2 Coins.')
  end

  def runRules(p:Player)
    plusActions p, 2
    plusBuys p, 1
    plusCoins p, 2
  end
end


class Laboratory < Card
  def initialize
    super('Laboratory', CardSets.BASE, CardTypes.ACTION, 5, '+2 Cards, +1 Action.')
  end

  def runRules(p:Player)
    plusCards p, 2
    plusActions p, 1
  end
end


class Library < Card
  def initialize
    super('Library', CardSets.BASE, CardTypes.ACTION, 5, 'Draw until you have 7 cards in hand. You may set aside any Action cards drawn this way, as you draw them; discard the set aside cards after you finish drawing.')
  end

  def runRules(p:Player)
    setAside = RubyList.new

    while (p.deck.size > 0 or p.discards.size > 0) and p.hand.size < 7
      if p.deck.size == 0
        p.shuffleDiscards
      end

      card = Card(p.deck.pop)
      if card.types & CardTypes.ACTION > 0
        options = RubyList.new
        options.add(Option.new('take', 'Take it into your hand.'))
        options.add(Option.new('discard', 'Set it aside.'))
        dec = Decision.new(p, options, 'You drew an Action, ' + card.name + '. You can either draw it into your hand or set it aside (and later discard it).', RubyList.new)
        key = Game.instance.decision(dec)

        if key.equals('take')
          p.logMe('draws a card.')
          p.hand.add(card)
        else
          p.logMe('sets aside ' + card.name + '.')
          setAside.add(card)
        end
      else
        p.logMe('draws a card.')
        p.hand.add(card)
      end
    end

    if setAside.size > 0
      p.discards.addAll(setAside)
      p.logMe('discards the set aside cards.')
    end
  end
end


class Mine < Card
  def initialize
    super('Mine', CardSets.BASE, CardTypes.ACTION, 5, 'Trash a Treasure card from your hand. Gain a Treasure card costing up to 3 Coins more; put it into your hand.')
  end

  def runRules(p:Player)
    treasures = p.hand.select { |c| Card(c).types & CardTypes.TREASURE > 0 }
    if treasures.size == 0
      p.logMe('has no Treasures to trash.')
      return
    end

    trash = Utils.handDecision(p, 'Choose a Treasure to trash.', nil, treasures)
    p.removeFromHand(trash)
    p.logMe('trashes ' + trash.name + '.')

    newCost = Game.instance.cardCost(trash) + 3
    gain = Utils.gainCardDecision(p, 'Now choose a Treasure costing up to ' + Integer.new(newCost).toString + '.', nil, RubyList.new, Game.instance.kingdom.select do |k_|
      k = Kingdom(k_)
      return (k.card.types & CardTypes.TREASURE > 0) && (Game.instance.cardCost(k.card) <= newCost)
    end)

    if p.buyCard(gain, true)
      p.hand.add(p.discards.pop)
    end
  end
end


class Market < Card
  def initialize
    super('Market', CardSets.BASE, CardTypes.ACTION, 5, '+1 Card, +1 Action, +1 Buy, +1 Coin.')
  end

  def runRules(p:Player)
    plusCards p, 1
    plusActions p, 1
    plusBuys p, 1
    plusCoins p, 1
  end
end


class Witch < Card
  def initialize
    super('Witch', CardSets.BASE, CardTypes.ACTION | CardTypes.ATTACK, 5, '+2 Cards. Each other player gains a Curse.')
  end

  def runRules(p:Player)
    plusCards p, 2
    everyPlayer(p, false, true)
  end

  def runEveryPlayer(p:Player, o:Player)
    o.buyCard(Game.instance.inKingdom('Curse'), true)
  end
end


class Adventurer < Card
  def initialize
    super('Adventurer', CardSets.BASE, CardTypes.ACTION, 6, 'Reveal cards from your deck until you reveal 2 Treasure cards. Put those Treasure cards in your hand and discard the other revealed cards.')
  end

  def runRules(p:Player)
    toGo = 2
    setAside = RubyList.new
    while (p.deck.size + p.discards.size > 0) && toGo > 0
      if p.deck.size == 0
        p.shuffleDiscards
      end

      card = Card(p.deck.pop)
      p.logMe('reveals ' + card.name + '.')
      if card.types & CardTypes.TREASURE > 0
        toGo -= 1
        p.hand.add(card)
        p.logMe('putting it into their hand.')
      else
        setAside.add(card)
      end
      toGo = toGo # no-op line to satisfy the mirah typechecker.
    end

    if toGo > 0
      p.logMe('has run out of cards to draw.')
    end
    p.discards.addAll(setAside)
  end
end

