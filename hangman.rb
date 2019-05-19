# Note that the dictionary containing the words for the game has already been
# edited via regex to omit word of length : 5 < length < 12

require 'yaml'

class Game
  attr_accessor :player, :gameboard, :hidden_word, :winner, :win_loss_record

  def initialize(player_name)
    @player = Player.new(player_name)
    @gameboard = GameBoard.new(@player)
    @winner = false

  end

  def determine_hidden_word
    # 44044 = # of words in dictionary file
    random_number = rand( 44_044)
    @dictionary_file = File.open('5desk.txt', 'r') do |file|
      file.each_line do |line|
        # $. means current line in file
        @hidden_word = line[0...line.length - 1] if $. == random_number
      end
    end
  end

  def display_total_word
    0...@hidden_word.length.times do |index|
      if @player.guesses.include? @hidden_word[index]
        print "#{@hidden_word[index]} "
      else
        print '_ '
      end
    end
    print "\n\n"
  end

  def prompt_move
    puts "\nMake a guess, #{@player.name}!"
  end

  def winner?
    @winner = false
    game_over = false
    regex = "/[#{@player.guesses.join}{#{@player.guesses.length}}]+/"
    game_over = true if !!(@hidden_word.match(regex))
    @winner = true if game_over
    game_over
  end

  def display_outro
    if @winner
      puts "You kicked Hangman ASS, #{@player.name}!"
    else
      puts "Looks like you couldn't handle the heat, #{@player.name}... The word"
      puts "was #{@hidden_word}!"
    end
  end

  # Game loop
  def play
    count = 0
    loop do

      break if winner? && count != 0

      @gameboard.display(@player.incorrect_guesses)
      display_total_word
      @player.display_guesses
      prompt_move
      @player.move(@hidden_word)

      break if @player.incorrect_guesses == 8

      count += 1
    end
    display_outro
    @player.update_win_loss_record(@winner)
  end
end



class Player
  attr_accessor :name, :guesses, :correct_guesses, :incorrect_guesses,
                :hidden_word, :win_loss_record

  def initialize(name)
    @name = name
    @guesses = []
    @correct_guesses = 0
    @incorrect_guesses = 0
    @win_loss_record = YAML.load_file('./save_files/wins_and_losses.yml')
  end

  def display_guesses
    puts "You've made the following guesses: #{guesses.sort.join(' ')}"
  end

  def display_win_loss_record
    puts "#{@name}; your win/loss record is as follows:"
    puts "\tWins: #{@win_loss_record[:win_loss_count][:wins]}"
    puts "\tLosses: #{@win_loss_record[:win_loss_count][:losses]}"
  end

  def update_win_loss_record(winner)
    if winner
      @win_loss_record[:win_loss_count][:wins] += 1
      puts 'Updating win count in save file...'
    else
      @win_loss_record[:win_loss_count][:losses] += 1
      puts 'Updating loss count in save file...'
    end
    File.open('./save_files/wins_and_losses.yml', 'w') {|file|
      file.write @win_loss_record.to_yaml}
    sleep(2)
    puts "File saved!\nGoodbye, #{@name}!"
  end

  def valid?(input)
    if input =~ /[^A-Z]+/ || @guesses.include?(input) ||
       input.length > 1 || input.empty?
      false
    else
      true
    end
  end

  def move(hidden_word)
    input = ''
    loop do
      puts "You've already guessed that letter!" if @guesses.include?(input
                                                                          .upcase)
      puts 'You can only guess one letter at a time!' if input.length > 1
      input = gets.chomp
      redo unless valid?(input.upcase)
      break
    end
    if hidden_word.include?(input.upcase)
      @correct_guesses += 1
    else
      @incorrect_guesses += 1
    end
    @guesses.push input.upcase
    nil
  end

end


class GameBoard
  attr_accessor :player

  def initialize(player)
    @player = player
  end

  def display(incorrect_guesses)
    if incorrect_guesses == 1
      puts %{




    _________
   /        /_
  /         _/|_
 /________/| |_/|____
 | |      ||___|_____/
 |        |}
    elsif incorrect_guesses == 2
      puts %{
  +----+
       |
       |
       |
     __|_____
   /   |    /_
  /    l    _/|_
 /________/| |_/|____
 | |      ||___|_____/
 |        |}

    elsif incorrect_guesses == 3
    puts %{
  +----+
  |    |
 ( )   |
       |
    ___|_____
   /   |    /_
  /    l    _/|_
 /________/| |_/|____
 | |      ||___|_____/
 |        |}
    elsif incorrect_guesses == 4
      puts %{
  +----+
  |    |
 ( )   |
  |    |
  | ___|_____
  |/   |    /_
  /    l    _/|_
 /________/| |_/|____
 | |      ||___|_____/
 |        |}
    elsif incorrect_guesses == 5
      puts %{
  +----+
  |    |
 ( )   |
  |    |
 /| ___|_____
/ |/   |    /_
  /    l    _/|_
 /________/| |_/|____
 | |      ||___|_____/
 |        |}
    elsif incorrect_guesses == 6
      puts %{

  +----+
  |    |
 ( )   |
  |__  |
 /| ___|_____
/  /   |    /_
  /    l    _/|_
 /________/| |_/|____
 | |      ||___|_____/
 |        |}
    elsif incorrect_guesses == 7
      puts %{
  +----+
  |    |
 ( )   |
  |__  |
 /| ___|_____
// /   |    /_
/ /    l    _/|_
 /________/| |_/|____
 | |      ||___|_____/
 |        |}
    elsif incorrect_guesses == 8
    puts %{
  +----+
  |    |
 ( )   |
  |__  |
 /| ___|_____
// \\  |    /_
/ / \\ l    _/|_
 /________/| |_/|____
 | |      ||___|_____/
 |        |}
    end

  end
end


def intro_to_user(name)
  puts "\nPress [1] to get justice servin', #{name}, or press [2] to check your
win/loss
 counts."
  puts "\t[1] Play"
  puts "\t[2] Show me how awesome I am at justice servin'"
end

def grab_player_name
  puts "Enter your darn tootin' name!"
  name = gets.chomp
  name
end

def make_decision
  decision = "1"
  loop do
     puts "You have to enter a dag gammit number! (that happens to be 1 or 2)
" if decision.match(/[^12]/)
      decision = gets.chomp
      break if decision.match(/[12]/)
  end
  decision.to_i
end







# TODO: perhaps allow the player to 'level up' and gain access to longer words