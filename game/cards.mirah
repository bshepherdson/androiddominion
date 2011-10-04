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

class Card
  @@cards = HashMap.new

  class Types
    @@TREASURE = 1
    @@ACTION = 2
    @@VICTORY = 4
    @@REACTION = 8
    @@ATTACK = 16
    @@CURSE = 32
  end

  def initialize(name:String, types:int, cost:int, text:String)
    @name = name
    @types = types
    @cost = cost
    @text = text

    initializeCards
  end

  def name:String
    @name
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

  def everyOtherPlayer(p:Player, isAttack:Boolean, block:EveryOtherI)
    everyPlayer(p, false, isAttack, block)
  end

  def everyPlayer(p:Player, includeMe:Boolean, isAttack:Boolean, block:EveryOtherI)
    Game.instance.players.each_with_index do |o_,i|
      o = Player(o_)
      if not includeMe and Game.instance.players[i].id == p.id
        next
      end

      protectedBy = o.safeFromAttack
      if isAttack and protectedBy
        o.logMe 'is protected by ' + protectedBy + '.'
        next
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




  def initializeCards
    @@cards.put('Gold', Gold.new)
    @@cards.put('Silver', Silver.new)
    @@cards.put('Copper', Copper.new)
  end

end


class Gold < Card
  def initialize
    super('Gold', Card.Types.TREASURE, 6, '')
  end
end

class Silver < Card
  def initialize
    super('Silver', Card.Types.TREASURE, 3, '')
  end
end

class Copper < Card
  def initialize
    super('Copper', Card.Types.TREASURE, 0, '')
  end
end

