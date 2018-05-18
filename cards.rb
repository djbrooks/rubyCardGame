#!/usr/bin/env ruby -w
=begin
Project
Shuffle up a deck of cards and deal them out.

A pgm that has a deck of cards, can shuffle, and then deal them to players.

  Player 1: 3H
  Player 2: 2C
  Player 3: KS
  Player 4: AH
=end

# TODO: Better user input processing with working Game class defaults.

require 'pry'

# Set to true if you wish debug statements to print
$debug=false
$dm="\t->debug:"; # Debug Msg prompt

# Game class that keeps track of players, cards, dealing, shuffling, etc.
class Game
  SUITA = [ 'H', 'C', 'D', 'S' ]
  VALUEA = [ '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A' ]
  def initialize
    @suitA = SUITA
    @valueA = VALUEA
    @numberOfDecks = 1  # May need more if user input requires it.
    @players = 1        # Default. User input required
    @playersCards = {}  # Hash of each player number (key) and an array value of card objects they've been dealt
    @cardsDealt = 5     # Default. User input required
    @cardsNeeded = @players * @cardsDealt
    @cardsAvailable = SUITA.count * VALUEA.count * @numberOfDecks
    @deckOfCards = {} # Hash of ALL cards in deck. Key is card # value is card object.
    @deckA = []       # Shuffle array of card #s. Then use number as the key to deckOfCards hash.
  end

  def suitA
    @suitA
  end
  def valueA
    @valueA
  end
  def deckCount
    @numberOfDecks
  end
  def addToDeckCount(c)
    @numberOfDecks += c
  end
  def deckSetCount(s)
    @numberOfDecks = s
  end
  def players
    @players
  end
  def playersSet(p)
    @players = p
  end
  def cardsNeeded
    (@players * @cardsDealt)
  end
  def cardsSetNeeded
    @cardsNeeded =  @players * @cardsDealt
  end
  def cardsDealt
    @cardsDealt
  end
  def cardsSetDealt(s)
    @cardsDealt = s
  end
  def cardsAvailable
    (SUITA.count * VALUEA.count * @numberOfDecks)
  end
  def hasEnoughCards
    self.cardsAvailable >= self.cardsNeeded ? TRUE : FALSE
  end
  def neededDecks
    (self.cardsNeeded - self.cardsAvailable)/self.cardsAvailable + 1
  end
  def setDeckOrder(a)
    @deckA = a
  end
  def setDeckOfCards(d)
    @deckOfCards = d
  end
  def shuffle
    @deckA.shuffle!
  end

  # Print the deck array in the order shuffled
  def showDeck
    puts "\nDeck looks like this:"
    i = 0
    @deckA.each do |c|
      i += 1
      puts "Card #{i} in deck is: #{c}->#{@deckOfCards[c].visible}"
    end
  end

  # Determine cards in players hand by jumping through array by # of
  # players instead of beginning to end sequentially.
  def dealCards
    @players.times do |p|
      c=p
      c+=1
      tmp = []
      puts "#{$dm} Dealing #{c} of #{cardsDealt} Cards for player #{c} of #{players}" if $debug
      while c <= cardsNeeded do
        puts "#{$dm} INSIDE While #{c} up to #{cardsNeeded}" if $debug
        d=c-1 # This is ugly... :( Needed to start at array 0 beginning
        tmp.push(@deckOfCards[@deckA[d]])
        c += @players
      end
      @playersCards[(p+1)] = tmp
    end
  end

  # showHand - Prints out all player's cards.
  def showHands
    @players.times do |p|
      i=p
      i+=1
      print "\nPlayer #{i}:"
      @playersCards[i].each do |c|
        print " #{c.visible}"
      end
    end
  end
end

# Asks the user how many players are playing and how many cards should
# be dealt. Prompts to add decks if there are not enough cards to play.
#
# Could use much better input filtering and defaults...
#
def prompt(myGame)
  #binding.pry
  loop do
    print "\nThis is a card game. Please enter number of players: "
    myGame.playersSet(gets.chomp().to_i)

    print "\nEnter number of cards to be dealt each player: "
    myGame.cardsSetDealt(gets.chomp().to_i)

    puts "\nCalculations indicate we will need #{myGame.cardsNeeded} cards and have #{myGame.cardsAvailable}"
    if (!myGame.hasEnoughCards)
      print "Sorry, not enough cards!\n"
      print "\tShould I add another #{myGame.neededDecks} deck(s): y/[n] "

      if !gets.chomp().match(/y/i)
        puts "Starting over..."
      else
        myGame.addToDeckCount(myGame.neededDecks)
        puts "#{$dm} myGame.neededDecks number is: #{myGame.neededDecks}" if $debug
      end
    end
    puts "#{$dm} players is #{myGame.players} cards dealt are #{myGame.cardsDealt} deck count #{myGame.deckCount}" if $debug
    puts "Does myGame have enough cards: #{myGame.hasEnoughCards}"
    break if myGame.hasEnoughCards
  end
end

# Card class creats individual card objects as specified by the
# passed in parameters: suit (Harts, Spades, etc.) and value (King,
# Queen, Ten, etc.)
class Card

  def initialize(s, v)
    @suit = s
    @value = v
    @count = 0
    @color = ( @suit === ('H' || 'D')) ? "Red" : "Black"

    # Determine count 2 - 11
    if !v.match(/[^[:digit:]]+/)
        @count = v.to_i
    elsif v === 'A'
        @count = 11
    else
        @count = 10
    end
  puts "#{$dm} In class: #{@suit}=#{s} #{@color} #{@value} #{@count} " if $debug
  end

  def visible
    "#{@value}#{@suit}"
  end
end

# Creates the correct number of cards using the Card Class
# required to be able to deal the necessary number of cards
# so all players have enough to play. Stores the prestine
# (in order two-through-Ace in each suite deck) in the Game class.
#
def createDeck(myGame)
  x = 0
  deckA = []
  deckOfCards = {}
  myGame.deckCount.times do |d|
    myGame.suitA.each do |s|
      myGame.valueA.each do |v|
        x += 1
        deckA.push(x)

        # Make a HASH of cards
        deckOfCards[x] = Card.new(s, v)

        # Make an ARRAY of cards
        #deckOfCardsA.push(Card.new(s, v))
      end
    end
  end
  myGame.setDeckOrder(deckA)
  myGame.setDeckOfCards(deckOfCards)
end

def debugOnOrOff()
  print "Would you like to see copious amounts of debug statements: y/[n] "
  if gets.chomp().match(/^y/i)
    $debug=true
    print "#{$dm} GAME ON!\n"
  else
    $debug=false
  end
end

def beginGame()
  # Let's get to it! Instantiate an instance of Class Game.
  myGame = Game.new

  # Ask if they are interested in seeing debug print
  # statements or not.
  debugOnOrOff()

  # Ask how many players and the number of cards they get.
  prompt(myGame)

  # Generate the perfect deck based upon the number of cards
  # necessary to be sure everyone gets enough to play.
  #
  # Deck is stored as a hash with the key being the card
  # number [1-52 in a normal one deck game] and the value
  # being a Card object. Once created, the deck never
  # changes, but the array HOLDING the card hashes does.
  #
  createDeck(myGame)

  print "\nShould I print the deck BEFORE shuffling? y/[n] "
  if gets.chomp().match(/^y/i)
    myGame.showDeck
  end

  # Does a shuffle of an array that contains the Card number
  # of the cardDeck hash with the card attributes.
  #
  # Hash has keys of 1-52 with a card object as the value.
  #
  print "\nShould I shuffle? y/[n] "
  if gets.chomp().match(/^y/i)
    myGame.shuffle
  end

  print "\nShould I print the deck? y/[n] "
  if gets.chomp().match(/^y/i)
    myGame.showDeck
  end

  # Calculates the array locations that hold each players cards.
  # 4 players getting 3 cards would use the follwoing shuffled
  # card array:
  #  player 1 gets array locations [1, 5, 9]
  #  player 2 gets array locations [2, 6, 10]
  #  player 3 gets array locations [3, 7, 11]
  #  player 4 gets array locations [4, 8, 12]
  #
  #  Those array locations then link cardDeck hash key holding
  #  the card object
  #
  myGame.dealCards

  # Now print each players hash of held card objects and
  # you're done! :)
  #
  print "\n<ENTER> when you are ready to see each player's hand. "
  gets.chomp()
  myGame.showHands
  #myGame.destroy
end

print "\nWould you like to play a game? y/[n] "
loop do
  if gets.chomp().match(/^y/i)
    beginGame()
  else
    print "\nBye."
    break;
  end
  print "\n\nWould you like to play again? y/[n] "
end
puts "\n\nFini!"


# Below NOT used. Went to Class solution instead of simple array.
# Below will print out an ARRAY of cards
#deckOfCardsA.each do |c|
#    puts c.inspect
#end
