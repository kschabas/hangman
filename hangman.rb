# frozen_string_literal: true

require 'yaml'
FILE_NAME = './google-10000-english-no-swears.txt'
# Hangman base class
class Hangman
  MAX_MISTAKES = 7
  def initialize
    @letters_guessed = Array.new(26, 'false')
    @answer_word = nil
    @mistakes_made = 0
  end

  def new_game
    @answer_word = new_random_word
    @mistakes_made = 0
    @letters_guessed.each_index { |index| @letters_guessed[index] = false }
  end

  def finished?
    return true if @mistakes_made == MAX_MISTAKES

    return false if @answer_word.split('').any? { |letter| @letters_guessed[letter.ord - 'a'.ord] == false }

    true
  end

  def user_guess
    puts 'Please input your guess (or type save to save the game)'
    letter_guessed = gets.chomp.downcase
    return save_game if letter_guessed == 'save'

    @letters_guessed[char_to_array_index(letter_guessed)] = true
    @mistakes_made += 1 unless @answer_word.split('').include?(letter_guessed)
  end

  def print_board
    @answer_word.split('').each do |letter|
      if @letters_guessed[char_to_array_index(letter)]
        print letter
      else
        print '_'
      end
    end
    print "\n"
    print_incorrect_letters
    puts "Mistakes remaining #{MAX_MISTAKES - @mistakes_made}\n\n"
  end

  def print_incorrect_letters
    print 'Incorrect Letters Guessed: '
    @letters_guessed.each_with_index do |bool, letter|
      if bool && @answer_word.split('').include?(array_index_to_char(letter)) == false
        print "#{array_index_to_char(letter)} "
      end
    end
    print "\n"
  end

  def print_end_message
    if @mistakes_made == MAX_MISTAKES
      puts "You lose! The word was #{@answer_word}. Better luck next time"
    else
      puts 'Congratulations! You win'
    end
  end

  def save_game
    index = 0
    index += 1 while File.exist?("./saved_games/saved_game#{index}.yml")
    file = File.open("./saved_games/saved_game#{index}.yml", 'w')
    file.puts YAML.dump({
                          answer_word: @answer_word,
                          letters_guessed: @letters_guessed,
                          mistakes_made: @mistakes_made
                        })
    file.close
    puts "Saved as game number #{index}"
  end

  def load_game
    puts 'Please enter save game number'
    index = gets.chomp
    until File.exist?("./saved_games/saved_game#{index}.yml")
      puts "File doesn't exist. Please re-enter the saved game number"
      index = gets.chomp
    end
    file = File.open("./saved_games/saved_game#{index}.yml", 'r')
    data = file.read
    data = YAML.load data
    @answer_word = data[:answer_word]
    @letters_guessed = data[:letters_guessed]
    @mistakes_made = data[:mistakes_made]
    print_board
  end
end

def new_random_word
  word_list = File.readlines(FILE_NAME)
  random_number = rand(1..word_list.length - 1)
  random_number = rand(1..word_list.length - 1) until word_list[random_number].chomp.length.between?(5, 12)
  word_list[random_number].chomp
end

def char_to_array_index(char)
  char.ord - 'a'.ord
end

def array_index_to_char(index)
  (index + 'a'.ord).chr
end

def play_game
  game = Hangman.new
  puts 'Do you wish to load a saved game (y/n)?'
  if gets.chomp.downcase == 'y'
    game.load_game
  else
    game.new_game
  end
  until game.finished?
    game.user_guess
    game.print_board
  end
  game.print_end_message
end

play_game
