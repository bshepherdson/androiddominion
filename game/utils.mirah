package dominion

import dominion.Card
import dominion.Game
import dominion.Decision
import dominion.Option
import dominion.Player

import java.util.ArrayList

class Utils
  def self.cardsToOptions(cards:ArrayList):ArrayList
    cards.collect.with_index do |c,i|
      Option.new 'card[' + i + ']', c.name
    end
  end

  interface GCDI do
    def run(c:Card):Boolean; end
  end
    

  /* Takes a block for the card filtering predicate. */
  def self.gainCardDecision(p:Player, message:String, done:String, info:ArrayList, block:GCDI):String
    kingdom = Game.instance.kingdom
    cards = kingdom.select do |k|
      k.count > 0 and block.run(k.card)
    end

    options = cards.map.with_index do |k,i|
      Option.new 'card[#{i}]', '(#{ Game.instance.cardCost(k.card) }) #{ k.card.name }'
    end

    if done
      options.push(Option.new('done', done))
    end

    dec = Decision.new p, options, message, info
    Game.instance.decision(dec)
  end

  interface HandDecI do
    def run(c:Card):Boolean; end
  end

  /* Choose a card from (a subset of) the hand.
   *
   * Args: Player, message, optional done message, predicate as a block.
   * Returns: the decision key.
   */
  def self.handDecision(p:Player, message:String, done:String, block:HandDecI):String
    options = p.hand.select.with_index do |c,i|
      block.run(c) ? Option.new('card[#{i}]', c.name) : nil
    end.select { |o| o }

    if done
      options.push(Option.new('done', done))
    end
    dec = Decision.new p, options, message, []
    Game.instance.decision dec
  end

  def self.showCards(cards:ArrayList):String
    cards.collect { |c| c.name }.join(', ')
  end

  def self.keyToIndex(key:String):int
    match = key =~ /^card\[(\d+)\]$/
    match ? match.captures[0] : nil
  end

end

