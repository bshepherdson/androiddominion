package dominion

import dominion.Game
import dominion.Player
import dominion.Card

import java.util.HashMap

/*
 * Plans for handling the rules. Card superclass has runRules method that implements
 * the rules. It takes as an argument the current player, and returns void.
 * For handling all-players rules, that logic is implemented using two functions in
 * the Card superclass that take a block.
 */

class CardTypes
  @@TREASURE = 1
  @@ACTION = 2
  @@VICTORY = 4
  @@REACTION = 8
  @@ATTACK = 16
  @@CURSE = 32

  def self.TREASURE; @@TREASURE; end
  def self.ACTION; @@ACTION; end
  def self.VICTORY; @@VICTORY; end
  def self.REACTION; @@REACTION; end
  def self.ATTACK; @@ATTACK; end
  def self.CURSE; @@CURSE; end
end

class Card
  @@cards = HashMap.new

  @@SET_COMMON = 1
  @@SET_BASE = 2
  def self.SET_COMMON; @@SET_COMMON; end
  def self.SET_BASE; @@SET_BASE; end

  def initialize(name:String, set:int, types:int, cost:int, text:String)
    @name = name
    @set = set
    @types = types
    @cost = cost
    @text = text

    Card.initializeCards
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
  def runRules(p:Player); end

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

  interface EveryOtherI do
    def run(p:Player, o:Player); end
  end

  def everyOtherPlayer(p:Player, isAttack:boolean, block:EveryOtherI)
    everyPlayer(p, false, isAttack, block)
  end

  def everyPlayer(p:Player, includeMe:boolean, isAttack:boolean, block:EveryOtherI)
    Game.instance.players.each_with_index do |o_,i|
      o = Player(o_)
      if not includeMe and Player(Game.instance.players.get(i)).id == p.id
        return
      end

      protectedBy = o.safeFromAttack
      if isAttack and protectedBy
        o.logMe 'is protected by ' + protectedBy + '.'
        return
      end

      block.run p, o
    end
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


  # TODO: Implement me
  def self.starterDeck:RubyList
    RubyList.new
  end


  def self.drawKingdom
    all = RubyList.new
    all.addAll(@@cards.values)
    kingdomCards = all.select do |c|
      Card(c).set != Card.SET_COMMON
    end

    drawn = RubyList.new

    while drawn.size < 10
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
    @@cards.put('Gold', Gold.new)
    @@cards.put('Silver', Silver.new)
    @@cards.put('Copper', Copper.new)
  end

end


class Gold < Card
  def initialize
    super('Gold', Card.SET_COMMON, CardTypes.TREASURE, 6, '')
  end

  def cardCount(players:int)
    1000
  end
end

class Silver < Card
  def initialize
    super('Silver', Card.SET_COMMON, CardTypes.TREASURE, 3, '')
  end

  def cardCount(players:int)
    1000
  end
end

class Copper < Card
  def initialize
    super('Copper', Card.SET_COMMON, CardTypes.TREASURE, 0, '')
  end

  def cardCount(players:int)
    1000
  end
end

