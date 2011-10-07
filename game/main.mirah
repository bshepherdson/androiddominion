package dominion

import dominion.Card

Card.initializeCards
Game.bootstrap
Game.instance.addPlayer('Braden')
Game.instance.addPlayer('Amie')
Game.instance.startGame

puts 'Starting game.'
# repeated play turns until the game ends
while not Game.instance.playTurn
end

puts 'Game over.'


