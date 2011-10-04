package dominion

import dominion.Game
import dominion.Player

/*
 * Plans for handling the rules. Card superclass has runRules method that implements
 * the rules. It takes as an argument the current player, and returns void.
 * For handling all-players rules, that logic is implemented using two functions in
 * the Card superclass that take a block.
 */

class Card
  @@cards = {}

  class Types
    @@TREASURE = 1
    @@ACTION = 2
    @@VICTORY = 4
    @@REACTION = 8
    @@ATTACK = 16
    @@CURSE = 32
  end

  def initialize(name:String, types:Integer, cost:Integer, text:String)
    @name = name
    @types = types
    @cost = cost
    @text = text
  end

  # abstract method to be implemented by each subclass.
  def runRules(p:Player); end

  # helper rules
  def plusCoins(p:Player, n:Integer)
    p.coin += n
    p.logMe 'gains +' + n + ' Coin' + (n === 1 ? '' : 's') + '.'
  end

  def plusBuys(p:Player, n:Integer)
    p.buys += n
    p.logMe 'gains +' + n + ' Buy' + (n === 1 ? '' : 's') + '.'
  end

  def plusActions(p:Player, n:Integer)
    p.actions += n
    p.logMe 'gains +' + n + ' Action' + (n === 1 ? '' : 's') + '.'
  end

  def plusCards(p:Player, n:Integer)
    p.draw n
    p.logMe 'gains +' + n + ' Card' + (n === 1 ? '' : 's') + '.'
  end


  def everyOtherPlayer(p:Player, isAttack:Boolean, block)
    everyPlayer(p, false, isAttack, block)
  end

  def everyPlayer(p:Player, includeMe:Boolean, isAttack:Boolean, block)
    Game.instance.players.each.with_index do |o,i|
      next if not includeMe and Game.instance.players[i].id === p.id

      protectedBy = o.safeFromAttack
      if isAttack and protectedBy
        o.logMe 'is protected by ' + protectedBy + '.'
        next
      end

      block p, o
    end
  end

end




class Gold < Card
  def initialize
    super('Gold', Card.Types.TREASURE, 6, '')
  end
end
Card.cards['Gold'] = Gold.new

class Silver < Card
  def initialize
    super('Silver', Card.Types.TREASURE, 3, '')
  end
end
Card.cards['Silver'] = Silver.new

class Copper < Card
  def initialize
    super('Copper', Card.Types.TREASURE, 0, '')
  end
end
Card.cards['Copper'] = Copper.new


p Card.cards

