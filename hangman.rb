# frozen_string_literal: true

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
    @letters_guessed[letter_guessed.ord - 'a'.ord] = true
  end
end

def new_random_word
  word_list = File.readlines(FILE_NAME)
  random_number = rand(1..word_list.length - 1)
  random_number = rand(1..word_list.length - 1) until word_list[random_number].chomp.length.between?(5, 12)
  word_list[random_number].chomp
end

def play_game
  game = Hangman.new
  game.new_game
  until game.finished?
    game.user_guess
    game.check_for_mistake
    game.print_board
  end
  game.print_end_message
end

play_game
