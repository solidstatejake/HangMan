require_relative 'hangman.rb'
require 'yaml'

puts "Welcome to RHETORIC JUSTICE ™\n\n"
name = grab_player_name
intro_to_user(name)

choice = make_decision
if choice == 2
  data = YAML.load_file('./save_files/wins_and_losses.yml')
  wins = data[:win_loss_count][:wins]
  losses = data[:win_loss_count][:losses]

  
  puts "You have accumulated #{wins} wins."

  if data[:win_loss_count][:wins] < 5
    puts 'You gotta work on your justice servin!'
  elsif  losses < wins / 2 && wins > 10
	  puts 'You\'re on yer way ta sherrif!'
  elsif losses < wins / 4 && wins > 30
    puts 'You are a fucking God.'
  end

  puts "You have accumulated #{losses} losses."
  if losses > 10
		puts 'Yer lettin\' \'em get away!!!'
  elsif losses > 30
		puts "You suck."
  end

end

puts "\n\nIt's time ta serve justice!!!"

sleep(2)

game = Game.new(name)

game.determine_hidden_word

game.play

