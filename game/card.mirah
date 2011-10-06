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

  def everyPlayer(epi:EveryPlayerInfo)
    #everyPlayer(p, false, isAttack, block)
    Game.instance.players.each_with_index do |o_,i|
      o = Player(o_)
      if not epi.includeMe and Player(Game.instance.players.get(i)).id == epi.p.id
        return
      end

      protectedBy = o.safeFromAttack
      if epi.isAttack and protectedBy != nil and not protectedBy.isEmpty()
        o.logMe 'is protected by ' + protectedBy + '.'
        return
      end

      epi.block.run epi.p, o
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
      Card(c).set != CardSets.COMMON
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
    @@cards = HashMap.new
    @@cards.put('Gold', Gold.new)
    @@cards.put('Silver', Silver.new)
    @@cards.put('Copper', Copper.new)
    @@cards.put('Estate', Estate.new)
    @@cards.put('Duchy', Duchy.new)
    @@cards.put('Province', Province.new)
    @@cards.put('Curse', Curse.new)
  end

end

class EveryPlayerInfo

  def initialize(p:Player, includeMe:boolean, isAttack:boolean)
    @p = p
    @includeMe = includeMe
    @isAttack = isAttack
  end

  def p:Player
    @p
  end
  def p=(v:Player)
    @p = v
  end

  def includeMe:boolean
    @includeMe
  end
  def includeMe=(v:boolean)
    @includeMe = v
  end

  def isAttack:boolean
    @isAttack
  end
  def isAttack=(v:boolean)
    @isAttack = v
  end

  interface EveryPlayerI do
    def run(p:Player, o:Player); end
  end
  def block:EveryPlayerI
    @block
  end
  def block=(block:EveryPlayerI)
    @block = block
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

