package dominion

import dominion.Card
import dominion.Game
import dominion.Decision
import dominion.Option
import dominion.Player

import java.util.ArrayList
import java.util.regex.*

/* Utility class that includes various helper methods. */
class RubyList < ArrayList
  interface CollectI do
    def run(x:Object):Object; end
  end

  def collect(block:CollectI):RubyList
    ret = RubyList.new
    i = 0
    while i < size
      ret.add(block.run(get(i)))
      i += 1
    end
    ret
  end


  interface CollectIndexI do
    def run(x:Object, i:int):Object; end
  end

  def collect_index(block:CollectIndexI):RubyList
    ret = RubyList.new
    i = 0
    while i < size
      ret.add(block.run(get(i), i))
      i += 1
    end
    ret
  end


  interface SelectI do
    def run(x:Object):boolean
      false
    end
  end

  def select(block:SelectI):RubyList
    ret = RubyList.new
    i = 0
    while i < size
      x = get(i)
      if block.run(x)
        ret.add(x)
      end
      i += 1
    end
    ret
  end


  interface FindIndexI do
    def run(x:Object):boolean
      false
    end
  end

  def find_index(block:FindIndexI):int
    i = 0
    while i < size
      if block.run(get(i))
        return i
      end
      i += 1
    end
    return -1
  end


  interface EachWithIndexI do
    def run(x:Object, i:int); end
  end

  def each_with_index(block:EachWithIndexI)
    i = 0
    while i < size
      block.run(get(i), i)
      i += 1
    end
  end


  interface EachI do
    def run(x:Object); end
  end

  def each(block:EachI)
    i = 0
    while i < size
      block.run(get(i))
      i += 1
    end
  end
end


class Utils
  def self.cardsToOptions(cards:RubyList):RubyList
    cards.collect.with_index do |c,i|
      Option.new 'card[' + i + ']', c.name
    end
  end

  interface GCDI do
    def run(c:Card):boolean; end
  end
    

  /* Takes a block for the card filtering predicate. */
  def self.gainCardDecision(p:Player, message:String, done:String, info:RubyList, block:GCDI):String
    kingdom = Game.instance.kingdom
    cards = kingdom.select do |k_|
      k = Kingdom(k_)
      k.count > 0 and block.run(k.card)
    end

    options = cards.map.with_index do |k,i|
      Option.new 'card[#{i}]', '(#{ Game.instance.cardCost(k.card) }) #{ k.card.name }'
    end

    if done
      options.add(Option.new('done', done))
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
      options.add(Option.new('done', done))
    end
    dec = Decision.new p, options, message, RubyList.new()
    Game.instance.decision dec
  end

  def self.showCards(cards:RubyList):String
    cards.collect { |c| Card(c).name }.join(', ')
  end

  def self.keyToIndex(key:String):int
    regex = Pattern.compile("^card\\[(\\d+)\\]$")
    matcher = regex.matcher("done")
    if matcher.matches
      return Integer.parseInt(matcher.group(1))
    else
      return -1
    end
  end

end

