package dominion

import dominion.Game
import dominion.Player
import dominion.Card
import dominion.CardTypes
import dominion.CardSets

import java.util.HashMap
import java.util.Collections
import java.util.Comparator

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

  def plusVP(p:Player, n:int)
    p.vpTokens += n
    p.logMe('gains +' + n + ' VP token' + (n == 1 ? '' : 's') + '.')
  end

  # abstract function called by everyPlayer
  def runEveryPlayer(p:Player, o:Player):void
    puts "ERROR: runEveryPlayer called but not overridden."
    System.exit(2)
  end

  def everyPlayer(p:Player, includeMe:boolean, isAttack:boolean):void
    i = 0
    while i < p.game.players.size
      o = Player(p.game.players.get(i))
      if includeMe or o.id != p.id
        protectedBy = o.safeFromAttack
        if isAttack && protectedBy != nil && protectedBy.length() > 0
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
    p.game.decision(dec)
  end

  def self.victoryValues(name:String):int
    if name.equals('Estate')
      return 1
    elsif name.equals('Duchy')
      return 3
    elsif name.equals('Province')
      return 6
    elsif name.equals('Island')
      return 2
    elsif name.equals('Colony')
      return 10
    end
    return 0
  end

  def self.treasureValues(p:Player, name:String):int
    if name.equals('Copper')
      return 1
    elsif name.equals('Silver')
      return 2
    elsif name.equals('Gold')
      return 3
    elsif name.equals('Loan')
      return 1
    elsif name.equals('Quarry')
      return 1
    elsif name.equals('Talisman')
      return 1
    elsif name.equals('Contraband')
      return 3
    elsif name.equals('Royal Seal')
      return 2
    elsif name.equals('Venture')
      return 1
    elsif name.equals('Hoard')
      return 2
    elsif name.equals('Bank')
      treasures = p.inPlay.select { |c| Card(c).types & CardTypes.TREASURE > 0 }
      return treasures.size
    elsif name.equals('Platinum')
      return 5
    end
    return 0
  end

  def self.isBasicCoin(name:String):boolean
    name.equals('Copper') or name.equals('Silver') or name.equals('Gold') or name.equals('Platinum')
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
      if not drawn.includes(kingdomCards.get(i))
        drawn.add(kingdomCards.get(i))
      end
    end

    Collections.sort(drawn, KingdomComparator.new)
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

    # Seaside
    @@cards.put('Embargo', Embargo.new)
    @@cards.put('Haven', Haven.new)
    @@cards.put('Lighthouse', Lighthouse.new)
    @@cards.put('Native Village', NativeVillage.new)
    @@cards.put('Pearl Diver', PearlDiver.new)
    @@cards.put('Ambassador', Ambassador.new)
    @@cards.put('Fishing Village', FishingVillage.new)
    @@cards.put('Lookout', Lookout.new)
    @@cards.put('Smugglers', Smugglers.new)
    @@cards.put('Warehouse', Warehouse.new)
    @@cards.put('Caravan', Caravan.new)
    @@cards.put('Cutpurse', Cutpurse.new)
    @@cards.put('Island', Island.new)
    @@cards.put('Navigator', Navigator.new)
    @@cards.put('Pirate Ship', PirateShip.new)
    @@cards.put('Salvager', Salvager.new)
    @@cards.put('Sea Hag', SeaHag.new)
    @@cards.put('Treasure Map', TreasureMap.new)
    @@cards.put('Bazaar', Bazaar.new)
    @@cards.put('Explorer', Explorer.new)
    @@cards.put('Ghost Ship', GhostShip.new)
    @@cards.put('Merchant Ship', MerchantShip.new)
    @@cards.put('Outpost', Outpost.new)
    @@cards.put('Tactician', Tactician.new)
    @@cards.put('Treasury', Treasury.new)
    @@cards.put('Wharf', Wharf.new)

    # Prosperity
    @@cards.put('Platinum', Platinum.new)
    @@cards.put('Colony', Colony.new)

    @@cards.put('Loan', Loan.new)
    @@cards.put('Trade Route', TradeRoute.new)
    @@cards.put('Bishop', Bishop.new)
    @@cards.put('Monument', Monument.new)
    @@cards.put('Quarry', Quarry.new)
    @@cards.put('Talisman', Talisman.new)
    @@cards.put('Worker\'s Village', WorkersVillage.new)
    @@cards.put('City', City.new)
    @@cards.put('Contraband', Contraband.new)
    @@cards.put('Counting House', CountingHouse.new)
    @@cards.put('Mint', Mint.new)
    @@cards.put('Mountebank', Mountebank.new)
    @@cards.put('Rabble', Rabble.new)
    @@cards.put('Royal Seal', RoyalSeal.new)
    @@cards.put('Vault', Vault.new)
    @@cards.put('Venture', Venture.new)
    @@cards.put('Goons', Goons.new)
    @@cards.put('Grand Market', GrandMarket.new)
    @@cards.put('Hoard', Hoard.new)
    @@cards.put('Bank', Bank.new)
    @@cards.put('Expand', Expand.new)
    @@cards.put('Forge', Forge.new)
    @@cards.put('King\'s Court', KingsCourt.new)
    @@cards.put('Peddler', Peddler.new)

    # Intrigue
    @@cards.put('Courtyard', Courtyard.new)
    @@cards.put('Pawn', Pawn.new)
    @@cards.put('Great Hall', GreatHall.new)
    @@cards.put('Masquerade', Masquerade.new)
    @@cards.put('Shanty Town', ShantyTown.new)
    @@cards.put('Steward', Steward.new)
    @@cards.put('Swindler', Swindler.new)
    @@cards.put('Wishing Well', WishingWell.new)
    @@cards.put('Baron', Baron.new)
    @@cards.put('Bridge', Bridge.new)
    @@cards.put('Conspirator', Conspirator.new)
    @@cards.put('Coppersmith', Coppersmith.new)
    @@cards.put('Ironworks', Ironworks.new)
    @@cards.put('Mining Village', MiningVillage.new)
    @@cards.put('Scout', Scout.new)
  end

end


class KingdomComparator
  implements Comparator
  def compare(o1:Object, o2:Object):int
    c1 = Card(o1)
    c2 = Card(o2)

    if c1.cost > c2.cost
      return 1
    elsif c2.cost == c1.cost
      return c1.name.compareTo c2.name
    else
      return -1
    end
  end
end


class BasicCoin < Card
  def initialize(name:String, cost:int)
    super(name, CardSets.COMMON, CardTypes.TREASURE, cost, '')
  end

  def cardCount(players:int)
    1000
  end

  def runRules(p:Player)
  end
end

class Gold     < BasicCoin; def initialize; super('Gold',     6); end; end
class Silver   < BasicCoin; def initialize; super('Silver',   3); end; end
class Copper   < BasicCoin; def initialize; super('Copper',   0); end; end
class Platinum < BasicCoin; def initialize; super('Platinum', 9); end; end


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
class Colony   < BasicVictory; def initialize; super('Colony',  11); end; end

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


class DurationCard < Card
  def initialize(name:String, set:int, cost:int, text:String)
    super(name, set, CardTypes.ACTION | CardTypes.DURATION, cost, text)
  end

  def runDurationRules(p:Player):void; end
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
    kCards = p.game.kingdom.select { |k| p.game.cardCost(Kingdom(k).card) <= 4 }
    kCard = Utils.gainCardDecision(p, 'Gain a card costing up to 4 Coin.', nil, RubyList.new, kCards)
    p.buyCard(kCard, true)
  end
end


class Bureaucrat < Card
  def initialize
    super('Bureaucrat', CardSets.BASE, CardTypes.ACTION | CardTypes.ATTACK, 4, 'Gain a Silver card; put it on top of your deck. Each other player reveals a Victory card from his hand and puts it on his deck, or reveals a hand with no Victory cards.')
  end

  def runRules(p:Player)
    p.buyCard(p.game.inKingdom('Silver'), true)
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

    kCard = Utils.gainCardDecision(p, 'Gain a card costing up to 5 Coins.', nil, RubyList.new, p.game.kingdom.select { |k| p.game.cardCost(Kingdom(k).card) <= 5 })
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

    newCost = p.game.cardCost(toTrash) + 2
    toGain = Utils.gainCardDecision(p, 'Gain a card costing up to ' + Integer.new(newCost).toString + '.', nil, RubyList.new, p.game.kingdom.select { |k| p.game.cardCost(Kingdom(k).card) <= newCost })
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
    key = p.game.decision(dec)
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
    key = p.game.decision(dec)

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
        key = p.game.decision(dec)

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

    newCost = p.game.cardCost(trash) + 3
    gain = Utils.gainCardDecision(p, 'Now choose a Treasure costing up to ' + Integer.new(newCost).toString + '.', nil, RubyList.new, p.game.kingdom.select do |k_|
      k = Kingdom(k_)
      return (k.card.types & CardTypes.TREASURE > 0) && (p.game.cardCost(k.card) <= newCost)
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
    o.buyCard(p.game.inKingdom('Curse'), true)
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

# Seaside cards

class Embargo < Card
  def initialize
    super('Embargo', CardSets.SEASIDE, CardTypes.ACTION, 2, '+2 Coins. Trash this card. Put an Embargo token on top of a Supply pile. When a player buys a card, he gains a Curse card per Embargo token on that pile.')
  end

  def runRules(p:Player)
    plusCoins p, 2
    if p.inPlay.size > 0 && p.inPlay.get(p.inPlay.size-1) == self
      p.inPlay.pop # trash
    end

    options = RubyList.new
    i = 0
    while i < p.game.kingdom.size
      k = Kingdom(p.game.kingdom.get(i))
      if k.count > 0
        options.add(Option.new('card[' + Integer.new(i).toString() + ']', k.card.name + (k.embargoTokens > 0 ? ' (' + Integer.new(k.embargoTokens).toString() + ' Embargo token' + (k.embargoTokens > 1 ? 's' : '') : ')')))
      end
      i += 1
    end

    dec = Decision.new(p, options, 'Choose a Supply pile to place an Embargo token on.', RubyList.new)
    key = p.game.decision dec
    index = Utils.keyToIndex(key)

    k = Kingdom(p.game.kingdom.get(index))
    k.embargoTokens += 1

    p.logMe('Embargoes ' + k.card.name + '. Now ' + Integer.new(k.embargoTokens).toString() + ' Embargo token' + (k.embargoTokens > 1 ? 's' : '') + ' on that pile.')
  end
end


class Haven < DurationCard
  def initialize
    super('Haven', CardSets.SEASIDE, 2, '+1 Card, +1 Action. Set aside a card from your hand face down. At the start of your next turn, put it into your hand.')
  end

  def runRules(p:Player)
    plusCards p, 1
    plusActions p, 1
    if p.hand.size == 0 # very unlikely, but it's possible that drawing could fail
      p.logMe('has no cards left to set aside.')
      return
    end

    card = Utils.handDecision(p, 'Choose a card from your hand to set aside for next turn.', nil, p.hand)
    p.removeFromHand(card)
    p.havenCards.add(card)
    p.logMe('sets aside a card.')

    p.durationRules.add(self)
  end

  def runDurationRules(p:Player)
    if p.havenCards.size > 0
      p.havenCards.each { |c| p.hand.add(c) }
      p.logMe('draws ' + p.havenCards.size + ' card' + (p.havenCards.size > 1 ? 's' : '') + ' set aside with Haven.')
      p.havenCards = RubyList.new
    end
  end
end


class Lighthouse < DurationCard
  def initialize
    super('Lighthouse', CardSets.SEASIDE, 2, '+1 Action. Now and at the start of your next turn: +1 Coin. -- While this is in play, when another player plays an Attack card, it doesn\'t affect you.')
  end

  def runRules(p:Player)
    plusActions p, 1
    plusCoins p, 1
    p.durationRules.add(self)
  end

  def runDurationRules(p:Player)
    plusCoins p, 1
  end
end


class NativeVillage < Card
  def initialize
    super('Native Village', CardSets.SEASIDE, CardTypes.ACTION, 2, '+2 Actions. Choose one: Set aside the top card of your deck face down on your Native Village mat; or put all the cards from your mat into your hand. You may look at the cards on your mat at any time; return them to your deck at the end of the game.')
  end

  def runRules(p:Player)
    plusActions p, 2

    options = RubyList.new
    options.add(Option.new('setaside', 'Set aside the top card of your deck on your Native Village mat.'))
    options.add(Option.new('intohand', 'Put all the cards on your Native Village mat into your hand.'))

    dec = Decision.new(p, options, 'You have played Native Village. Choose one of its options.', RubyList.new)
    key = p.game.decision dec

    if key.equals('setaside')
      if p.deck.size == 0
        p.shuffleDiscards
        if p.deck.size == 0
          p.logMe('has no cards to set aside.')
          return
        end
      end
      p.nativeVillageMat.add(p.deck.pop)
      p.logMe('sets aside the top card of their deck.')
    else
      mat = p.nativeVillageMat
      p.logMe('puts the ' + Integer.new(mat.size).toString() + ' card' + (mat.size == 1 ? '' : 's') + ' from their Native Village mat into their hand.')
      p.hand.addAll(mat)
      p.nativeVillageMat = RubyList.new
    end
  end
end


class PearlDiver < Card
  def initialize
    super('Pearl Diver', CardSets.SEASIDE, CardTypes.ACTION, 2, '+1 Card, +1 Action. Look at the bottom card of your deck. You may put it on top.')
  end

  def runRules(p:Player)
    plusCards p, 1
    plusActions p, 1

    if p.deck.size == 0
      p.shuffleDiscards
    end

    bottom = Card(p.deck.get(0))
    options = RubyList.new
    options.add(Option.new('ontop', 'Put it on top of your deck.'))
    options.add(Option.new('leave', 'Leave it on the bottom.'))
    dec = Decision.new(p, options, 'The bottom card of your deck is ' + bottom.name + '.', RubyList.new)
    key = p.game.decision(dec)

    if key.equals('ontop')
      p.deck.remove(0)
      p.deck.add(bottom)
      p.logMe('looks at the bottom card of his deck, putting it on top.')
    else
      p.logMe('looks at the bottom card of his deck, leaving it there.')
    end
  end
end


class Ambassador < Card
  def initialize
    super('Ambassador', CardSets.SEASIDE, CardTypes.ACTION | CardTypes.ATTACK, 3, 'Reveal a card from your hand. Return up to 2 copies of it from your hand to the Supply. Then each other player gains a copy of it.')
  end

  def runRules(p:Player)
    if p.hand.size == 0
      p.logMe('has no cards to return to the Supply.')
      return
    end

    card = Utils.handDecision(p, 'Choose a card from your hand to set aside for next turn.', nil, p.hand)

    p.logMe('reveals ' + card.name + '.')
    @revealedCard = p.game.inKingdom(card.name)

    copies = p.hand.select { |c| Card(c).name.equals(card.name) }

    options = RubyList.new
    options.add(Option.new('0', 'Don\'t return any.'))
    options.add(Option.new('1', 'Return one copy.'))
    if copies.size > 1
      options.add(Option.new('2', 'Return two copies.'))
    end
    dec = Decision.new(p, options, 'Return up to two copies to the Supply.', RubyList.new)
    key = p.game.decision(dec)

    if key.equals('2')
      p.removeFromHand(card)
      p.removeFromHand(card)
      @revealedCard.count += 2
      p.logMe('returns two copies of ' + card.name + ' to the Supply.')
    elsif key.equals('1')
      p.removeFromHand(card)
      k = p.game.inKingdom(card.name)
      @revealedCard.count += 1
      p.logMe('returns one copy of ' + card.name + ' to the Supply.')
    else
      p.logMe('does not return any copies.')
    end

    everyPlayer(p, false, true)
  end

  def runEveryPlayer(p:Player, o:Player)
    o.buyCard(@revealedCard, true)
  end
end


class FishingVillage < DurationCard
  def initialize
    super('Fishing Village', CardSets.SEASIDE, 3, '+2 Actions, +1 Coin. At the start of your next turn: +1 Action, +1 Coin.')
  end

  def runRules(p:Player)
    plusActions p, 2
    plusCoins p, 1
    p.durationRules.add(self)
  end

  def runDurationRules(p:Player)
    plusActions p, 1
    plusCoins p, 1
  end
end

class Lookout < Card
  def initialize
    super('Lookout', CardSets.SEASIDE, CardTypes.ACTION, 3, '+1 Action. Look at the top 3 cards of your deck. Trash one of them. Discard one of them. Put the other one on top of your deck.')
  end

  def runRules(p:Player)
    drawn = p.draw(3)

    cards = RubyList.new
    while drawn > 0
      cards.add(p.hand.pop)
      drawn -= 1
    end

    if cards.size == 0
      p.logMe('has no cards to draw for Lookout.')
      return
    end

    options = Utils.cardsToOptions(cards)
    dec = Decision.new(p, options, 'Choose a card to trash.', RubyList.new)
    key = p.game.decision(dec)
    index = Utils.keyToIndex(key)
    p.logMe('trashes ' + Card(cards.get(index)).name + '.')

    cards2 = RubyList.new
    i = 0
    while i < cards.size
      if i != index
        cards2.add(cards.get(i))
      end
      i += 1
    end

    if cards2.size == 0
      p.logMe('has no remaining Lookout cards.')
    end

    options = Utils.cardsToOptions(cards2)
    dec = Decision.new(p, options, 'Choose a card to discard.', RubyList.new)
    key = p.game.decision(dec)
    index = Utils.keyToIndex(key)
    card = Card(cards2.get(index))
    p.discards.add(card)
    p.logMe('discards ' + card.name + '.')

    if cards2.size == 2
      index2 = 1 - index
      p.deck.add(cards2.get(index2))
      p.logMe('returns the last card to the top of their deck.')
    end
  end
end


class Smugglers < Card
  def initialize
    super('Smugglers', CardSets.SEASIDE, CardTypes.ACTION, 3, 'Gain a copy of a card costing up to 6 Coins that the player to your right gained on his last turn.')
  end

  def runRules(p:Player)
    index = 0
    while index < p.game.players.size
      if Player(p.game.players.get(index)).id == p.id
        break
      end

      index += 1
    end

    index -= 1
    if index < 0
      index = p.game.players.size - 1
    end

    other = Player(p.game.players.get(index))
    gained = other.gainedLastTurn.select do |c|
      (p.game.cardCost(GainedCard(c).card) <= 6) and
      (p.game.inKingdom(GainedCard(c).card.name).count > 0)
    end

    if gained.size == 0
      other.logMe('gained no eligible cards last turn.')
      return
    end

    unique = RubyList.new
    index = 0
    while index < gained.size
      if not unique.contains(gained.get(index))
        unique.add(gained.get(index))
      end

      index += 1
    end

    cards = unique.collect do |gc| GainedCard(gc).card end

    options = Utils.cardsToOptions(cards)
    dec = Decision.new(p, options, 'Choose a card to gain from those that ' + other.name + ' gained last turn.', RubyList.new)
    key = p.game.decision(dec)
    index = Utils.keyToIndex(key)

    card = Card(cards.get(index))
    k = p.game.inKingdom(card.name)
    p.buyCard(k, true)
  end
end


class Warehouse < Card
  def initialize
    super('Warehouse', CardSets.SEASIDE, CardTypes.ACTION, 3, '+3 Cards, +1 Action. Discard 3 cards.')
  end

  def runRules(p:Player)
    plusActions(p, 1)
    plusCards(p, 3)

    discarded = 0
    while discarded < 3 and p.hand.size > 0
      card = Utils.handDecision(p, 'Choose a card to discard.', nil, p.hand)

      p.removeFromHand(card)
      p.discards.add(card)
      p.logMe('discards ' + card.name + '.')
      discarded += 1
    end
  end
end


class Caravan < DurationCard
  def initialize
    super('Caravan', CardSets.SEASIDE, 4, '+1 Card, +1 Action. At the start of your next turn, +1 Card.')
  end

  def runRules(p:Player)
    plusCards(p, 1)
    plusActions(p, 1)

    p.durationRules.add(self)
  end

  def runDurationRules(p:Player)
    plusCards(p, 1)
  end
end


class Cutpurse < Card
  def initialize
    super('Cutpurse', CardSets.SEASIDE, CardTypes.ACTION | CardTypes.ATTACK, 4, '+2 Coin. Each other player discards a Copper card (or reveals a hand with no Copper).')
  end

  def runRules(p:Player)
    plusCoins(p, 2)
    everyPlayer(p, false, true)
  end

  def runEveryPlayer(p:Player, o:Player)
    coppers = o.hand.select do |c| Card(c).name.equals('Copper') end

    if coppers.size == 0
      o.logMe('reveals their hand: ' + Utils.showCards(o.hand) + '.')
      return
    end

    card = o.removeFromHand(Card.cards('Copper'))
    o.discards.add(card)
    o.logMe('discards a Copper.')
  end
end


class Island < Card
  def initialize
    super('Island', CardSets.SEASIDE, CardTypes.ACTION | CardTypes.VICTORY, 4, 'Set aside this and another card from your hand. Return them to your deck at the end of the game. 2 VP.')
  end

  def runRules(p:Player)
    if p.hand.size == 0
      p.logMe('has no cards to set aside.')
      return
    end

    card = Utils.handDecision(p, 'Choose a card to set aside until the end of the game.', nil, p.hand)

    p.removeFromHand(card)
    p.islandSetAside.add(card)

    # Set aside the Island too, if it's still there and this wasn't the second play on a Throne Room.
    if p.inPlay.size > 0 and Card(p.inPlay.get(p.inPlay.size-1)).name.equals('Island')
      p.islandSetAside.add(p.inPlay.pop)
      p.logMe('sets aside Island and ' + card.name + '.')
    else
      p.logMe('sets aside ' + card.name +'.')
    end
  end
end


class Navigator < Card
  def initialize
    super('Navigator', CardSets.SEASIDE, CardTypes.ACTION, 4, '+2 Coin. Look at the top 5 cards of your deck. Either discard all of them, or put them back in any order.')
  end

  def runRules(p:Player)
    plusCoins(p, 2)

    drawn = p.draw(5)
    cards = RubyList.new
    while drawn > 0
      cards.add(p.hand.pop)
      drawn -= 1
    end

    options = RubyList.new
    options.add(Option.new('discard', 'Discard them all'))
    options.add(Option.new('keep', 'Put them back in any order'))

    info = RubyList.new
    info.add('Navigator cards: ' + Utils.showCards(cards))

    dec = Decision.new(p, options, 'Choose whether to discard or put back the cards (listed below under "Navigator cards:")', info)
    key = p.game.decision(dec)

    if key.equals('discard')
      p.discards.addAll(cards)
      p.logMe('draws 5 cards, discarding them.')
    else
      discards = RubyList.new
      while cards.size > 0
        dec = Decision.new(p, Utils.cardsToOptions(cards), 'Choose a card to put back (you will draw these cards in the order you choose them here)', RubyList.new)
        key = p.game.decision(dec)
        index = Utils.keyToIndex(key)

        i = 0
        newcards = RubyList.new
        while i < cards.size
          if i == index
            discards.add(cards.get(i))
          else
            newcards.add(cards.get(i))
          end
          i += 1
        end
        cards = newcards
      end

      while discards.size > 0
        p.deck.add(discards.pop)
      end
      p.logMe('draws 5 cards, putting them back.')
    end
  end
end


class PirateShip < Card
  def initialize
    super('Pirate Ship', CardSets.SEASIDE, CardTypes.ACTION | CardTypes.ATTACK, 4, 'Choose one: Each other player reveals the top 2 cards of his deck, trashes a revealed Treasure that you choose, discards the rest, and if anyone trashed a Treasure you take a Coin token; or, +1 Coin per Coin token you\'ve taken with Pirate Ships this game.')
  end

  def runRules(p:Player)
    p.pirateShipAttack = 0

    opts = RubyList.new
    opts.add(Option.new('attack', 'Attack the other players'))
    opts.add(Option.new('coin', 'Gain ' + p.pirateShipCoins + ' Coin' + (p.pirateShipCoins == 1 ? '' : 's') + '.'))

    dec = Decision.new(p, opts, 'Choose what to do with your Pirate Ship.', RubyList.new)
    key = p.game.decision(dec)
    if key.equals('coin')
      p.logMe('plays Pirate Ship for the Coins.')
      plusCoins(p, p.pirateShipCoins)
    else
      p.logMe('plays Pirate Ship for the attack.')

      everyPlayer(p, false, true)

      if p.pirateShipAttack > 0
        p.logMe('gains a Pirate Ship token.')
        p.pirateShipCoins += 1
      else
        p.logMe('does not gain a Pirate Ship token.')
      end
    end
  end

  def runEveryPlayer(p:Player, o:Player)
    drawn = o.draw(2)
    if drawn == 0
      o.logMe('has no cards to draw.')
      return
    end

    cards = RubyList.new
    while drawn > 0
      cards.add(o.hand.pop)
      drawn -= 1
    end

    treasures = cards.select do |c| Card(c).types & CardTypes.TREASURE > 0 end

    log = 'reveals ' + Utils.showCards(cards)

    if treasures.size == 0
      o.logMe(log + '; and discards ' + (cards.size > 1 ? 'both' : 'it') + '.')
      o.discards.addAll(cards)
    elsif treasures.size == 1
      if cards.size == 1
        o.logMe(log + '; and trashes it.')
        p.pirateShipAttack += 1
      else
        o.logMe(log + '; and trashes the ' + Card(treasures.get(0)).name + '.')
        p.pirateShipAttack += 1
        if cards.get(0).equals(treasures.get(0))
          o.discards.add(cards.get(1))
        else
          o.discards.add(cards.get(0))
        end
      end
    else
      if treasures.get(0).equals(treasures.get(1))
        o.discards.add(treasures.get(0))
        o.logMe(log + '; and trashes one.')
      else
        card = Utils.handDecision(p, 'Choose which of ' + o.name + '\'s Treasures to trash.', nil, treasures)
        if treasures.get(0).equals(card)
          o.discards.add(treasures.get(1))
          o.logMe(log + '; and trashes ' + card.name + '.')
        else
          o.discards.add(treasures.get(0))
          o.logMe(log + '; and trashes ' + card.name + '.')
        end
      end
      
      p.pirateShipAttack += 1
    end
  end
end


class Salvager < Card
  def initialize
    super('Salvager', CardSets.SEASIDE, CardTypes.ACTION, 4, '+1 Buy. Trash a card from your hand. +Coins equal to its cost.')
  end

  def runRules(p:Player)
    plusBuys(p, 1)
    card = Utils.handDecision(p, 'Choose a card to trash.', nil, p.hand)
    p.removeFromHand(card)
    p.logMe('trashes ' + card.name + '.')
    plusCoins(p, p.game.cardCost(card))
  end
end
    

class SeaHag < Card
  def initialize
    super('Sea Hag', CardSets.SEASIDE, CardTypes.ACTION | CardTypes.ATTACK, 4, 'Each other player discards the top card of his deck, then gains a Curse card, putting it on top of his deck.')
  end

  def runRules(p:Player)
    everyPlayer(p, false, true)
  end

  def runEveryPlayer(p:Player, o:Player)
    drawn = o.draw(1)

    log = ''
    if drawn == 0
      log = 'as no top card to disard, '
    else
      discarded = Card(o.hand.pop)
      o.discards.add(discarded)
      log = 'discards the top card of his deck (' + discarded.name + '), '
    end

    inKingdom = p.game.inKingdom('Curse')
    if inKingdom.count > 0
      o.deck.add(Card.cards('Curse'))
      inKingdom.count -= 1
      o.logMe(log + 'putting a Curse on top of his deck.')
    else
      o.logMe(log + 'but there are no more Curses.')
    end
  end
end


class TreasureMap < Card
  def initialize
    super('Treasure Map', CardSets.SEASIDE, CardTypes.ACTION, 4, 'Trash this and another copy of Treasure Map from your hand. If you do trash two Treasure Maps, gain 4 Gold cards, putting them on top of your deck.')
  end

  def runRules(p:Player)
    another = false
    newhand = RubyList.new
    i = 0
    while i < p.hand.size
      if Card(p.hand.get(i)).name.equals('Treasure Map')
        another = true
      else
        newhand.add(p.hand.get(i))
      end
      i += 1
    end

    p.hand = newhand

    newInPlay = p.inPlay.select do |c| not Card(c).name.equals('Treasure Map') end
    p.inPlay = newInPlay

    if another
      p.logMe('trashes two Treasure Maps, putting 4 Gold on top of their deck.')
      p.deck.add(Card.cards('Gold'))
      p.deck.add(Card.cards('Gold'))
      p.deck.add(Card.cards('Gold'))
      p.deck.add(Card.cards('Gold'))
    end
  end
end


class Bazaar < Card
  def initialize
    super('Bazaar', CardSets.SEASIDE, CardTypes.ACTION, 5, '+1 Card, +2 Actions, +1 Coin.')
  end

  def runRules(p:Player)
    plusCards(p, 1)
    plusActions(p, 2)
    plusCoins(p, 1)
  end
end


class Explorer < Card
  def initialize
    super('Explorer', CardSets.SEASIDE, CardTypes.ACTION, 5, 'You may reveal a Province card from your hand. If you do, gain a Gold card, putting it into your hand. Otherwise, gain a Silver card, putting it into your hand.')
  end
  
  def runRules(p:Player)
    provinces = p.hand.select do |c| Card(c).name.equals('Province') end

    if provinces.size > 0
      options = RubyList.new
      options.add(Option.new('yes', 'Reveal the Province to gain a Gold.'))
      options.add(Option.new('no',  'Do not reveal, gain a Silver.'))
      dec = Decision.new(p, options, 'You have a Province in your hand, choose whether to reveal it.', RubyList.new)
      key = p.game.decision(dec)

      if key.equals('yes')
        p.logMe('reveals a Province from their hand, gaining a Gold into their hand.')
        p.hand.add(Card.cards('Gold'))
        return
      end # let 'no' fall through to Silver below.
    end

    p.logMe('gains a Silver into their hand.')
    p.hand.add(Card.cards('Silver'))
  end
end


class GhostShip < Card
  def initialize
    super('Ghost Ship', CardSets.SEASIDE, CardTypes.ACTION | CardTypes.ATTACK, 5, '+2 Cards. Each other player with 4 or more cards in hand puts cards from his hand on top of his deck until he has 3 cards in his hand.')
  end

  def runRules(p:Player)
    plusCards(p, 2)

    everyPlayer(p, false, true)
  end

  def runEveryPlayer(p:Player, o:Player)
    if o.hand.size < 4
      o.logMe('already has fewer than 4 cards in their hand.')
      return
    end

    while o.hand.size > 3
      card = Utils.handDecision(o, 'Choose a card to discard onto the top of your deck. You must discard down to 3 cards in hand.', nil, o.hand)
      o.removeFromHand(card)
      o.deck.add(card)
    end

    o.logMe('discards down to 3 cards in hand, putting the cards on top of their deck.')
  end
end


class MerchantShip < DurationCard
  def initialize
    super('Merchant Ship', CardSets.SEASIDE, 5, 'Now and at the start of your next turn: +2 Coins.')
  end

  def runRules(p:Player)
    plusCoins(p, 2)
    p.durationRules.add(self)
  end

  def runDurationRules(p:Player)
    plusCoins(p, 2)
  end
end


class Outpost < DurationCard
  def initialize
    super('Outpost', CardSets.SEASIDE, 5, 'You only draw 3 cards (instead of 5) in this turn\'s Clean-up phase. Take an extra turn after this one. This can\'t cause you to take more than two consecutive turns.')
  end

  def runRules(p:Player)
    p.outpostPlayed = true
  end
end


class Tactician < DurationCard
  def initialize
    super('Tactician', CardSets.SEASIDE, 5, 'Discard your whole hand. If you discarded any cards this way, then at the start of your next turn, +5 Cards, +1 Buy and +1 Action.')
  end

  def runRules(p:Player)
    if p.hand.size > 0
      p.logMe('discards their whole hand.')
      p.discards.addAll(p.hand)
      p.hand = RubyList.new
      p.durationRules.add(self)
    else
      p.logMe('discards no cards for Tactician.')
    end
  end

  def runDurationRules(p:Player)
    plusCards(p, 5)
    plusBuys(p, 1)
    plusActions(p, 1)
  end
end


class Treasury < Card
  def initialize
    super('Treasury', CardSets.SEASIDE, CardTypes.ACTION, 5, '+1 Card, +1 Action, +1 Coin. When you discard this from play, if you didn\'t buy a Victory card this turn, you may put this on top of your deck.')
  end

  def runRules(p:Player)
    plusCards(p, 1)
    plusActions(p, 1)
    plusCoins(p, 1)
  end
end


class Wharf < DurationCard
  def initialize
    super('Wharf', CardSets.SEASIDE, 5, 'Now and at the start of your next turn: +2 Cards, +1 Buy.')
  end

  def runRules(p:Player)
    plusCards(p, 2)
    plusBuys(p, 1)
    p.durationRules.add(self)
  end

  def runDurationRules(p:Player)
    plusCards(p, 2)
    plusBuys(p, 1)
  end
end


####################################################################
# PROSPERITY
####################################################################

class Loan < Card
  def initialize
    super('Loan', CardSets.PROSPERITY, CardTypes.TREASURE, 3, 'Worth 1 Coin. When you play this, reveal cards from your deck until you reveal a Treasure. Discard it or trash it. Discard the other cards.')
  end

  def runRules(p:Player)
    setAside = RubyList.new

    while true
      drawn = p.draw(1)
      if drawn == 0
        p.logMe('has run out of cards to reveal.')
        p.discards.addAll(setAside)
        return
      end

      card = Card(p.hand.pop)
      p.logMe('reveals ' + card.name + '.')

      if card.types & CardTypes.TREASURE > 0
        options = RubyList.new
        options.add(Option.new('discard', 'Discard it.'))
        options.add(Option.new('trash', 'Trash it.'))
        dec = Decision.new(p, options, 'You revealed ' + card.name + ', discard it or trash it.', RubyList.new)
        key = p.game.decision(dec)

        if key.equals('discard')
          p.logMe('discards ' + card.name + '.')
          p.discards.add(card)
        else
          p.logMe('trashes ' + card.name + '.')
        end

        p.discards.addAll(setAside)
        break
      else
        setAside.add(card)
        next
      end
    end
  end
end


class TradeRoute < Card
  def initialize
    super('Trade Route', CardSets.PROSPERITY, CardTypes.ACTION, 3, '+1 Buy. +1 Coin per token on the Trade Route mat. Trash a card from your hand. -- Setup: Put a token on each Victory card Supply pile. When a card is gained from that pile, move the token to the Trade Route mat.')
  end

  def runRules(p:Player)
    plusBuys(p, 1)
    plusCoins(p, p.game.tradeRouteCoins)

    card = Utils.handDecision(p, 'Trash a card from your hand.', nil, p.hand)
    p.removeFromHand(card)
    p.logMe('trashes ' + card.name + '.')
  end
end

# TODO: Implement Watchtower.


class Bishop < Card
  def initialize
    super('Bishop', CardSets.PROSPERITY, CardTypes.ACTION, 4, '+1 Coin. +1 VP token. Trash a card from your hand. +VP tokens equal to half its cost in Coins, rounded down. Each other player may trash a card from his hand.')
  end

  def runRules(p:Player)
    plusCoins(p, 1)

    card = Utils.handDecision(p, 'Trash a card for Bishop.', nil, p.hand)
    p.removeFromHand(card)
    p.logMe('trashes ' + card.name + '.')

    cost = p.game.cardCost(card)
    tokens = int(Math.floor(cost/2) + 1)

    plusVP(p, tokens)

    everyPlayer(p, false, false)
  end

  def runEveryPlayer(p:Player, o:Player)
    card = Utils.handDecision(o, 'You may trash a card on ' + p.name + '\'s Bishop.', 'Do not trash.', o.hand)
    if card == nil
      o.logMe('chooses not to trash a card.')
    else
      o.logMe('trashes ' + card.name + '.')
      o.removeFromHand(card)
    end
  end
end


class Monument < Card
  def initialize
    super('Monument', CardSets.PROSPERITY, CardTypes.ACTION, 4, '+2 Coins, +1 VP token.')
  end

  def runRules(p:Player)
    plusCoins(p, 2)
    plusVP(p, 1)
  end
end


class Quarry < Card
  def initialize
    super('Quarry', CardSets.PROSPERITY, CardTypes.TREASURE, 4, 'Worth 1 Coin. While this is in play, Action cards cost 2 Coins less, but not less than 0 Coins.')
  end

  def runRules(p:Player)
    p.game.quarries += 1
  end
end


class Talisman < Card
  def initialize
    super('Talisman', CardSets.PROSPERITY, CardTypes.TREASURE, 4, 'Worth 1 Coin. While this is in play, when you buy a card costing 4 Coins or less that is not a Victory card, gain a copy of it.')
  end

  def runRules(p:Player)
  end
end


class WorkersVillage < Card
  def initialize
    super('Worker\'s Village', CardSets.PROSPERITY, CardTypes.ACTION, 4, '+1 Card, +2 Actions, +1 Buy.')
  end

  def runRules(p:Player)
    plusCards(p, 1)
    plusActions(p, 2)
    plusBuys(p, 1)
  end
end


class City < Card
  def initialize
    super('City', CardSets.PROSPERITY, CardTypes.ACTION, 5, '+1 Card, +2 Actions. If there are one or more empty Supply piles, +1 Card. If there are two or more, +1 Coin and +1 Buy.')
  end

  def runRules(p:Player)
    cards = 1

    emptyPiles = p.game.kingdom.select { |k| Kingdom(k).count == 0 }

    if emptyPiles.size >= 1
      cards = 2
    end

    plusCards(p, cards)
    plusActions(p, 2)

    if emptyPiles.size >= 2
      plusCoins(p, 1)
      plusBuys(p, 1)
    end
  end
end
      

class Contraband < Card
  def initialize
    super('Contraband', CardSets.PROSPERITY, CardTypes.TREASURE, 5, 'Worth 3 Coins. +1 Buy. When you play this, the player to your left names a card. You can\'t buy that card this turn.')
  end

  def runRules(p:Player)
    plusBuys(p, 1)

    playerIndex = p.game.players.find_index { |o_| Player(o_).id == p.id }
    o = Player(p.game.players.get( (playerIndex+1) % p.game.players.size))

    /* now find all kingdom cards which are not empty piles
     * and not already Contraband. */
    cards = p.game.kingdom.select do |k_|
      k = Kingdom(k_)
      k.count > 0 and not p.contrabandCards.includes(k.card)
    end

    opts = Utils.cardsToOptions(cards.collect { |k_| Kingdom(k_).card })
    info = RubyList.new
    info.add('Contraband cards: ' + Utils.showCards(p.contrabandCards))
    info.add(p.name + '\'s hand size: ' + p.hand.size)
    info.add(p.name + '\'s coins: ' + Integer.new(p.coins).toString)
    dec = Decision.new(o, opts, 'Choose a card that ' + p.name + ' cannot buy this turn.', info)

    key = p.game.decision(dec)
    index = Utils.keyToIndex(key)

    k = Kingdom(cards.get(index))
    p.contrabandCards.add(k.card)

    p.logMe('can\'t buy ' + k.card.name + ' this turn.')
  end
end


class CountingHouse < Card
  def initialize
    super('Counting House', CardSets.PROSPERITY, CardTypes.ACTION, 5, 'Look through your discard pile, reveal any number of Copper cards from it, and put them into your hand.')
  end

  def runRules(p:Player)
    coppers = RubyList.new
    others = RubyList.new

    i = 0
    while i < p.discards.size
      c = Card(p.discards.get(i))
      if c.name.equals('Copper')
        coppers.add(c)
      else
        others.add(c)
      end
      i += 1
    end

    p.logMe('puts ' + coppers.size + ' Coppers into their hand.')
    p.discards = others
    p.hand.addAll(coppers)
  end
end


class Mint < Card
  def initialize
    super('Mint', CardSets.PROSPERITY, CardTypes.ACTION, 5, 'You may reveal a Treasure card from your hand. Gain a copy of it. -- When you buy this, trash all Treasures you have in play.')
  end

  def runRules(p:Player)
    treasures = p.hand.select { |c_| Card(c_).types & CardTypes.TREASURE > 0 }
    c = Utils.handDecision(p, 'Choose a Treasure to reveal and gain a copy of.', 'Reveal nothing', treasures)

    if c == nil
      p.logMe('reveals nothing.')
    else
      p.logMe('reveals ' + c.name + '.')
      k = p.game.inKingdom(c.name)
      p.buyCard(k, true)
    end
  end
end


class Mountebank < Card
  def initialize
    super('Mountebank', CardSets.PROSPERITY, CardTypes.ACTION | CardTypes.ATTACK, 5, '+2 Coins. Each other player may discard a Curse. If he does not, he gains a Curse and a Copper.')
  end

  def runRules(p:Player)
    plusCoins(p, 2)

    everyPlayer(p, false, true)
  end

  def runEveryPlayer(p:Player, o:Player)
    curses = o.hand.select { |c_| Card(c_).name.equals('Curse') }

    if curses.size > 0
      yn = yesNo(o, p.name + ' has played Mountebank. Would you like to discard a Curse?')
      if yn.equals('yes')
        o.discard(Card(curses.get(0)))
        return
      end
    end

    o.buyCard(p.game.inKingdom('Curse'), true)
    o.buyCard(p.game.inKingdom('Copper'), true)
  end
end


class Rabble < Card
  def initialize
    super('Rabble', CardSets.PROSPERITY, CardTypes.ACTION | CardTypes.ATTACK, 5, '+3 Cards. Each other player reveals the top 3 cards of his deck, discards the revealed Actions and Treasures, and puts the rest back on top in any order he chooses.')
  end

  def runRules(p:Player)
    plusCards(p, 3)

    everyPlayer(p, false, true)
  end

  def runEveryPlayer(p:Player, o:Player)
    drawn = o.draw(3)
    
    cards = RubyList.new
    while drawn > 0
      cards.add(o.hand.pop)
      drawn -= 1
    end

    bad = RubyList.new
    i = 0
    while i < cards.size
      c = Card(cards.get(i))
      if (c.types & CardTypes.ACTION > 0) or (c.types & CardTypes.TREASURE > 0)
        o.discards.add(c)
        o.logMe('discards ' + c.name + '.')
      else
        bad.add(c)
      end
      i += 1
    end

    if bad.size == 0
      return
    end
    while bad.size > 1
      c = Utils.handDecision(o, 'Choose which card to put back on your deck. Later cards will go on top of this one.', nil, bad)
      other = RubyList.new
      i = 0
      found = false
      while i < bad.size
        if (not found) and Card(bad.get(i)).name.equals(c.name)
          o.logMe('returns a card to the top of their deck.')
          o.deck.add(c)
          found = true
        else
          other.add(bad.get(i))
        end
        i += 1
      end
      bad = other
    end

    o.logMe('returns the last card to the top of their deck.')
    o.deck.add(bad.get(0))
  end
end


class RoyalSeal < Card
  def initialize
    super('Royal Seal', CardSets.PROSPERITY, CardTypes.TREASURE, 5, 'Worth 2 Coins. While this is in play, when you gain a card, you may put that card on top of your deck.')
  end

  def runRules(p:Player)
    p.royalSeal = true
  end
end


class Vault < Card
  def initialize
    super('Vault', CardSets.PROSPERITY, CardTypes.ACTION, 5, '+2 Cards. Discard any number of cards. +1 Coin per card discarded. Each other player may discard 2 cards. If he does, he draws a card.')
  end

  def runRules(p:Player)
    plusCards(p, 2)

    discarded = 0
    while p.hand.size > 0
      c = Utils.handDecision(p, 'Discard any number of cards for Vault.', 'Done discarding', p.hand)
      if c == nil
        break
      end

      discarded += 1
      p.discard(c)
    end
    if discarded > 0
      plusCoins(p, discarded)
    end

    everyPlayer(p, false, false)
  end

  def runEveryPlayer(p:Player, o:Player)
    yn = yesNo(o, p.name + ' has played Vault. Do you want to discard two cards and draw one?')
    if yn.equals('yes')
      c = Utils.handDecision(o, 'Choose the first card to discard.', nil, o.hand)
      o.discard(c)
      c = Utils.handDecision(o, 'Choose the second card to discard.', nil, o.hand)
      o.discard(c)
      o.draw(1)
    else
      o.logMe('chooses not to discard two cards and draw one.')
    end
  end
end


class Venture < Card
  def initialize
    super('Venture', CardSets.PROSPERITY, CardTypes.TREASURE, 5, 'Worth 1 Coin. When you play this, reveal cards from your deck until you reveal a Treasure. Discard the other cards. Play that Treasure.')
  end

  def runRules(p:Player)
    setAside = RubyList.new
    while true
      drawn = p.draw(1)
      if drawn == 0
        p.logMe('has drawn their whole deck and found no Treasures to play.')
        p.discards.addAll(setAside)
        return
      end

      card = Card(p.hand.pop)
      p.logMe('reveals ' + card.name + '.')
      if card.types & CardTypes.TREASURE > 0
        p.discards.addAll(setAside)
        p.inPlay.add(card)
        p.coins += Card.treasureValues(p, card.name)
        p.logMe('plays ' + card.name + '.')
        card.runRules(p)
        return
      end

      setAside.add(card)
    end
  end
end


class Goons < Card
  def initialize
    super('Goons', CardSets.PROSPERITY, CardTypes.ACTION | CardTypes.ATTACK, 6, '+1 Buy, +2 Coins. Each other player discards down to 3 cards in hand. While this is in play, when you buy a card, +1 VP token.')
  end

  def runRules(p:Player)
    plusBuys(p, 1)
    plusCoins(p, 2)

    everyPlayer(p, false, true)
    p.goons += 1
  end

  def runEveryPlayer(p:Player, o:Player)
    while o.hand.size > 3
      card = Utils.handDecision(o, 'You must discard down to 3 cards in hand. Choose a card to discard.', nil, o.hand)
      o.discard(card)
    end
  end
end


class GrandMarket < Card
  def initialize
    super('Grand Market', CardSets.PROSPERITY, CardTypes.ACTION, 6, '+1 Card, +1 Action, +1 Buy, +2 Coins. -- You can\'t buy this if you have any Copper in play.')
  end

  def runRules(p:Player)
    plusCards(p, 1)
    plusActions(p, 1)
    plusBuys(p, 1)
    plusCoins(p, 2)
  end
end


class Hoard < Card
  def initialize
    super('Hoard', CardSets.PROSPERITY, CardTypes.TREASURE, 6, 'Worth 2 Coins. While this is in play, when you buy a Victory card, gain a Gold.')
  end

  def runRules(p:Player)
  end
end


class Bank < Card
  def initialize
    super('Bank', CardSets.PROSPERITY, CardTypes.TREASURE, 7, 'When you play this, it\'s worth 1 Coin per Treasure card you have in play (counting this).')
  end

  def runRules(p:Player)
  end
end


class Expand < Card
  def initialize
    super('Expand', CardSets.PROSPERITY, CardTypes.ACTION, 7, 'Trash a card from your hand. Gain a card costing up to 3 Coins more than the trashed card.')
  end

  def runRules(p:Player)
    card = Utils.handDecision(p, 'Trash a card from your hand.', nil, p.hand)
    p.removeFromHand(card)
    p.logMe('trashes ' + card.name + '.')
    
    price = p.game.cardCost(card) + 3
    affordableCards = p.game.kingdom.select { |k_| p.game.cardCost(Kingdom(k_).card) <= price }
    inKingdom = Utils.gainCardDecision(p, 'Now choose a card costing up to ' + Integer.new(price).toString + '.', nil, RubyList.new, affordableCards)
    p.buyCard(inKingdom, true)
  end
end
    

class Forge < Card
  def initialize
    super('Forge', CardSets.PROSPERITY, CardTypes.ACTION, 7, 'Trash any number of cards from your hand. Gain a card with cost exactly equal to the total cost in coins of the trashed cards.')
  end

  def runRules(p:Player)
    price = 0
    while p.hand.size > 0
      card = Utils.handDecision(p, 'Trash any number of cards for Forge.', 'Done trashing', p.hand)
      if card == nil
        break
      end

      p.logMe('trashes ' + card.name + '.')
      p.removeFromHand(card)
      price += p.game.cardCost(card)
    end

    affordable = p.game.kingdom.select do |k_|
      k = Kingdom(k_)
      k.count > 0 and p.game.cardCost(k.card) == price
    end
    if affordable.size == 0
      p.logMe('cannot buy a card with cost ' + Integer.new(price).toString + '.')
      return
    else
      inKingdom = Utils.gainCardDecision(p, 'Now gain a card costing exactly ' + Integer.new(price).toString + '.', nil, RubyList.new, affordable)
      p.buyCard(inKingdom, true)
    end
  end
end


class KingsCourt < Card
  def initialize
    super('King\'s Court', CardSets.PROSPERITY, CardTypes.ACTION, 7, 'You may choose an Action card in your hand. Play it three times.')
  end

  def runRules(p:Player)
    actions = p.hand.select { |c| Card(c).types & CardTypes.ACTION > 0 }
    if actions.size == 0
      p.logMe('has no Actions in hand.')
      return
    end

    card = Utils.handDecision(p, 'Choose an Action card to play three times.', nil, actions)
    p.removeFromHand(card)
    p.inPlay.add(card)

    p.logMe('uses King\'s Court on ' + card.name + '.')

    p.logMe('plays ' + card.name + ' once.')
    card.runRules(p)
    p.logMe('plays ' + card.name + ' again.')
    card.runRules(p)
    p.logMe('plays ' + card.name + ' yet again.')
    card.runRules(p)
  end
end
    

class Peddler < Card
  def initialize
    super('Peddler', CardSets.PROSPERITY, CardTypes.ACTION, 8, '+1 Card, +1 Action, +1 Coin -- During your Buy phase, this costs 2 Coins less per Action card you have in play, but not less than 0 Coins.')
  end

  def runRules(p:Player)
    plusCards(p, 1)
    plusActions(p, 1)
    plusCoins(p, 1)
  end
end


# Intrigue

class Courtyard < Card
  def initialize
    super('Courtyard', CardSets.INTRIGUE, CardTypes.ACTION, 2, '+3 Cards. Put a card from your hand on top of your deck.')
  end

  def runRules(p:Player)
    plusCards(p, 3)

    card = Utils.handDecision(p, 'Choose a card to put back on top of your deck.', nil, p.hand)
    p.removeFromHand(card)
    p.deck.add(card)
    p.logMe('puts a card back on top of their deck.')
  end
end


class Pawn < Card
  def initialize
    super('Pawn', CardSets.INTRIGUE, CardTypes.ACTION, 2, 'Choose two: +1 Card, +1 Action, +1 Buy, +1 Coin. (The choices must be different.)')
  end

  def runRules(p:Player)
    opts = RubyList.new
    opts.add(Option.new('card', '+1 Card'))
    opts.add(Option.new('action', '+1 Action'))
    opts.add(Option.new('buy', '+1 Buy'))
    opts.add(Option.new('coin', '+1 Coin'))

    i = 2
    while i > 0
      dec = Decision.new(p, opts, 'Choose the ' + (i == 2 ? 'first' : 'second') + ' effect of Pawn.', RubyList.new)
      key = p.game.decision(dec)

      if key.equals('card')
        if p.draw(1) == 1
          p.logMe('draws 1 card.')
        else
          p.logMe('has no cards left to draw.')
        end
      elsif key.equals('action')
        p.actions += 1
        p.logMe('gains +1 Action.')
      elsif key.equals('buy')
        p.buys += 1
        p.logMe('gains +1 Buy.')
      else
        p.coins += 1
        p.logMe('gains +1 Coin.')
      end

      j = 0
      newopts = RubyList.new
      while j < opts.size
        if not Option(opts.get(j)).key.equals(key)
          newopts.add(opts.get(j))
        end
        j += 1
      end

      opts = newopts
      i -= 1
    end
  end
end


# TODO: Implement Secret Chamber

class GreatHall < Card
  def initialize
    super('Great Hall', CardSets.INTRIGUE, CardTypes.ACTION | CardTypes.VICTORY, 3, '+1 Card, +1 Action. Worth 1 VP.')
  end

  def runRules(p:Player)
    plusCards(p, 1)
    plusActions(p, 1)
  end
end


class Masquerade < Card
  def initialize
    super('Masquerade', CardSets.INTRIGUE, CardTypes.ACTION | CardTypes.ATTACK, 3, '+2 Cards. Each player passes a card in their hand to the player on their left. You may trash a card from your hand.')
  end

  def runRules(p:Player)
    plusCards(p, 2)

    # This stages a card in o.masqueradeCard.
    everyPlayer(p, true, true)
    # Now put each card into the new owner's hand.
    p.game.players.each do |q_|
      q = Player(q_)
      q.hand.add(q.masqueradeCard)
      q.masqueradeCard = nil
    end

    card = Utils.handDecision(p, 'You may trash a card from your hand.', 'Do not trash.', p.hand)
    if card != nil 
      p.removeFromHand(card)
      p.logMe('trashes ' + card.name + '.')
    end
  end

  def runEveryPlayer(p:Player, o:Player)
    card = Utils.handDecision(o, 'Choose a card to pass to the player to your left.', nil, o.hand)
    o.removeFromHand(card)

    i = 0
    found = false
    done = false
    playerToLeft = nil
    while i < o.game.players.size
      q = Player(o.game.players.get(i))
      if found
        q.masqueradeCard = card
        playerToLeft = q
        done = true
        break
      end
      if q.id == o.id
        found = true
      end
      i += 1
    end

    if not done
      playerToLeft = Player(o.game.players.get(0))
      playerToLeft.masqueradeCard = card
    end

    o.logMe('passes a card to ' + playerToLeft.name + '.')
  end
end


class ShantyTown < Card
  def initialize
    super('Shanty Town', CardSets.INTRIGUE, CardTypes.ACTION, 3, '+2 Actions. Reveal your hand. If you have no Action cards, +2 Cards.')
  end

  def runRules(p:Player)
    plusActions(p, 2)
    p.logMe('reveals their hand: ' + Utils.showCards(p.hand))
    actions = p.hand.select do |c_| c = Card(c_)
      c.types & CardTypes.ACTION > 0
    end

    if actions.size == 0
      p.logMe('has no Action cards in hand.')
      plusCards(p, 2)
    end
  end
end


class Steward < Card
  def initialize
    super('Steward', CardSets.INTRIGUE, CardTypes.ACTION, 3, 'Choose one: +2 Cards; or +2 Coins; or trash 2 cards from your hand.')
  end

  def runRules(p:Player)
    opts = RubyList.new
    opts.add(Option.new('cards', '+2 Cards'))
    opts.add(Option.new('coins', '+2 Coins'))
    opts.add(Option.new('trash', 'Trash two cards from your hand'))
    dec = Decision.new(p, opts, 'Choose what to do with your Steward', RubyList.new)
    choice = p.game.decision(dec)
    if choice.equals('cards')
      plusCards(p, 2)
    elsif choice.equals('coins')
      plusCoins(p, 2)
    else
      card = Utils.handDecision(p, 'Choose the first card to trash for Steward.', nil, p.hand)
      p.removeFromHand(card)
      p.logMe('trashes ' + card.name)
      card = Utils.handDecision(p, 'Choose the second card to trash for Steward.', nil, p.hand)
      p.removeFromHand(card)
      p.logMe('trashes ' + card.name)
    end
  end
end


class Swindler < Card
  def initialize
    super('Swindler', CardSets.INTRIGUE, CardTypes.ACTION | CardTypes.ATTACK, 3, '+2 Coins. Each other player trashes the top card of his deck and gains a card with the same cost that you choose.')
  end

  def runRules(p:Player)
    plusCoins(p, 2)

    everyPlayer(p, false, true)
  end

  def runEveryPlayer(p:Player, o:Player)
    drawn = o.draw(1)
    if drawn == 0
      o.logMe('has no cards to draw.')
      return
    end

    topCard = Card(o.hand.pop())
    cost = p.game.cardCost(topCard)
    log = 'trashes his top card, ' + topCard.name

    replacements = p.game.kingdom.select do |k_| k = Kingdom(k_)
      k.count > 0 && p.game.cardCost(k.card) == cost
    end

    if replacements.size == 0
      o.logMe(log + ', but there are no replacements.')
    elsif replacements.size == 1
      o.logMe(log + '.')
      o.buyCard(Kingdom(replacements.get(0)), true)
    else
      o.logMe(log + '.')
      inKingdom = Utils.gainCardDecision(p, 'Choose a card for ' + o.name + ' to gain in exchange for their ' + topCard.name + '.', nil, RubyList.new, replacements)
      o.buyCard(inKingdom, true)
    end
  end
end


class WishingWell < Card
  def initialize
    super('Wishing Well', CardSets.INTRIGUE, CardTypes.ACTION, 3, '+1 Card, +1 Action. Name a card, then reveal the top card of your deck. If it is the named card, put it in your hand.')
  end

  def runRules(p:Player)
    kingdomCards = p.game.kingdom.collect { |k_| Kingdom(k_).card }
    card = Utils.handDecision(p, 'Name the card you wish to find on top of your deck.', nil, kingdomCards)

    p.logMe('wishes for ' + card.name + '.')
    drawn = p.draw(1)
    if drawn == 0
      p.logMe('has no cards to draw.')
      return
    end

    drawnCard = Card(p.hand.get(p.hand.size-1))
    if drawnCard.name.equals(card.name)
      p.logMe('reveals ' + card.name + ', putting it into his hand.')
    else
      p.logMe('reveals ' + drawnCard.name + ', discarding it.')
      p.discards.add(p.hand.pop)
    end
  end
end


class Baron < Card
  def initialize
    super('Baron', CardSets.INTRIGUE, CardTypes.ACTION, 4, '+1 Buy. You may discard an Estate card. If you do, +4 Coins. Otherwise, gain an Estate card.')
  end

  def runRules(p:Player)
    plusBuys(p, 1)
    estates = p.hand.select do |c_| Card(c_).name.equals('Estate') end
    if estates.size == 0
      discarding = false
    else
      yn = yesNo(p, 'Discard an Estate for +4 Coins?')
      discarding = yn.equals('yes')
    end

    if discarding
      p.removeFromHand(Card(estates.get(0)))
      p.logMe('discards an Estate.')
      plusCoins(p, 4)
    else
      p.logMe('does not discard an Estate.')
      p.buyCard(p.game.inKingdom('Estate'), true)
    end
  end
end


class Bridge < Card
  def initialize
    super('Bridge', CardSets.INTRIGUE, CardTypes.ACTION, 4, '+1 Buy, +1 Coin. All cards (including cards in player\'s hands) cost 1 Coin less this turn, but not less than 0 Coin.')
  end

  def runRules(p:Player)
    plusBuys(p, 1)
    plusCoins(p, 1)
    p.logMe('reduces all prices by 1 this turn.')
    p.game.bridges += 1
  end
end


class Conspirator < Card
  def initialize
    super('Conspirator', CardSets.INTRIGUE, CardTypes.ACTION, 4, '+2 Coins. If you\'ve player 3 or more Actions this turn (counting this): +1 Card, +1 Action.')
  end

  def runRules(p:Player)
    plusCoins(p, 2)
    actionsPlayed = p.inPlay.select do |c_| Card(c_).types & CardTypes.ACTION > 0 end
    if actionsPlayed.size >= 3
      plusCards(p, 1)
      plusActions(p, 1)
    end
  end
end


class Coppersmith < Card
  def initialize
    super('Coppersmith', CardSets.INTRIGUE, CardTypes.ACTION, 4, 'Copper produces an extra 1 Coin this turn.')
  end

  def runRules(p:Player)
    p.game.log('Copper produces an extra 1 Coin this turn.')
    p.game.coppersmiths += 1
  end
end


class Ironworks < Card
  def initialize
    super('Ironworks', CardSets.INTRIGUE, CardTypes.ACTION, 4, 'Gain a card costing up to 4 Coins. If it is an : Action card, +1 Action; Treasure card, +1 Coin; Victory card, +1 Card.')
  end

  def runRules(p:Player)
    inKingdom = Utils.gainCardDecision(p, 'Gain a card costing up to 4 Coins.', nil, RubyList.new, p.game.kingdom.select { |k_| p.game.cardCost(Kingdom(k_).card) <= 4 })
    card = inKingdom.card

    if card.types & CardTypes.ACTION > 0
      plusActions(p, 1)
    end

    if card.types & CardTypes.TREASURE > 0
      plusCoins(p, 1)
    end

    if card.types & CardTypes.VICTORY > 0
      plusCards(p, 1)
    end
  end
end


class MiningVillage < Card
  def initialize
    super('Mining Village', CardSets.INTRIGUE, CardTypes.ACTION, 4, '+1 Card, +2 Actions. You may trash this card immediately. If you do, +2 Coins.')
  end

  def runRules(p:Player)
    plusCards(p, 1)
    plusActions(p, 2)

    if Card(p.inPlay.get(p.inPlay.size-1)).name.equals('Mining Village')
      yn = yesNo(p, 'Trash Mining Village for +2 Coins?')
      if yn.equals('yes')
        p.inPlay.pop
        p.logMe('trashes Mining Village.')
        plusCoins(p, 2)
      else
        p.logMe('does not trash Mining Village.')
      end
    end
  end
end


class Scout < Card
  def initialize
    super('Scout', CardSets.INTRIGUE, CardTypes.ACTION, 4, '+1 Action. Reveal the top 4 cards of your deck. Put the revealed Victory cards into your hand. Put the other cards on top of your deck in any order.')
  end

  def runRules(p:Player)
    plusActions(p, 1)

    drawn = p.draw(4)
    cards = RubyList.new
    i = drawn
    while i > 0
      cards.add(p.hand.pop)
      i -= 1
    end

    p.logMe('reveals the top ' + drawn + ' cards of their deck: ' + Utils.showCards(cards) + '.')

    victoryCards = cards.select { |c_| Card(c_).types & CardTypes.VICTORY > 0 }
    otherCards   = cards.select { |c_| Card(c_).types & CardTypes.VICTORY == 0 }

    p.logMe('puts the Victory cards (' + Utils.showCards(victoryCards) + ') into their hand.')

    stack = RubyList.new
    while otherCards.size > 1
      newCards = RubyList.new
      card = Utils.handDecision(p, 'Put the remaining cards back on your deck in any order. You will draw them in the same order you choose here.', nil, otherCards)
      i = 0
      found = false
      while i < otherCards.size
        c = Card(otherCards.get(i))
        if c.name.equals(card.name) and not found
          found = true
        else
          newCards.add(c)
        end
        i += 1
      end

      otherCards = newCards
    end

    if otherCards.size > 0
      newCards.add(otherCards.get(0))
    end

    while newCards.size > 0
      p.deck.add(newCards.pop)
    end

    p.logMe('puts the remaining cards back on his deck.')
  end
end


