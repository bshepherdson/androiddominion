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


  interface SelectIndexI do
    def run(x:Object, i:int):boolean
      false
    end
  end

  def select_index(block:SelectIndexI):RubyList
    ret = RubyList.new
    i = 0
    while i < size
      x = get(i)
      if block.run(x,i)
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


  def join(sep:String):String
    sb = StringBuffer.new
    i = 0
    while i < size
      sb.append(get(i))
      if (i+1) < size
        sb.append(sep)
      end
      i += 1
    end
    sb.toString()
  end


  /* NB: uses .equals */
  def include?(x:Object):boolean
    i = 0
    while i < size
      if get(i).equals(x)
        return true
      end
      i += 1
    end
    return false
  end

  /* NB: uses == */
  def include_exact?(x:Object):boolean
    i = 0
    while i < size
      if get(i) == x
        return true
      end
      i += 1
    end
    return false
  end


  def pop:Object
    remove(size-1)
  end
end


class Utils
  def self.cardsToOptions(cards:RubyList):RubyList
    cards.collect_index do |c,i|
      Option.new 'card[' + Integer.new(i).toString() + ']', Card(c).name
    end
  end

  interface GCDI do
    def run(c:Card):boolean
      false
    end
  end
    

  /* Takes a block for the card filtering predicate. */
  def self.gainCardDecision(p:Player, message:String, done:String, info:RubyList, block:GCDI):String
    kingdom = Game.instance.kingdom
    cards = kingdom.select do |k_|
      k = Kingdom(k_)
      k.count > 0 and block.run(k.card)
    end

    options = cards.collect_index do |k_,i|
      k = Kingdom(k_)
      Option.new("card["+Integer.new(i).toString()+"]",
          "("+ Integer.new(Game.instance.cardCost(k.card)).toString() + ") " + k.card.name)
    end

    if done
      options.add(Option.new('done', done))
    end

    dec = Decision.new p, options, message, info
    Game.instance.decision(dec)
  end

  interface HandDecI do
    def run(c:Card):boolean
      false
    end
  end

  /* Choose a card from (a subset of) the hand.
   *
   * Args: Player, message, optional done message, predicate as a block.
   * Returns: the decision key.
   */
  def self.handDecision(p:Player, message:String, done:String, block:HandDecI):String
    options = p.hand.collect_index do |c_,i|
      c = Card(c_)
      block.run(c) ? Option.new('card[#{i}]', c.name) : nil
    end.select { |o| o != nil }

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

