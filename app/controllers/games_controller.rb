require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    grid_array = []
    10.times { grid_array << ('A'..'Z').to_a.sample }
    @letters = grid_array
  end

  def score
    @guess = params['wordGuess']
    @letters_array = params['letters_array'].split(' ')
    @start_time = Time.parse(params['start_time'])
    @end_time = Time.now

    @time_taken = @end_time - @start_time
    @attempt = @guess.to_s.upcase.split('')

    @score_calc = 0

    # Check if word is in grid to start off with.
    if every_letter_in_grid?(@attempt, @letters_array)
      # p 'yes, every letter in is in the grid'
      if actual_english_word?([@attempt])
        # p 'actual english word'
        @score_calc = (@attempt.size * 10) + (100 - @time_taken)
        @message_result = 'Well done!'
      else
        @message_result = 'the given word is not an english word at all'
      end
    else
      # p 'every letter not in grid'
      @message_result = 'the given word is not in the grid.'
    end
    # raise
  end

  def every_letter_in_grid?(attempt, grid)
    # attempt = to source where letters came from

    # Check if player guess characters are all included in the source grid
    attempt.each do |character|
      # p character
      if grid.include?(character)
        # p "Source begin --> #{grid}"
        grid.delete_at(grid.index(character))
        # p "Source end --> #{grid}"
      else
        return false
      end
    end
    true
  end

  def word_in_grid?(attempt, grid)
    # p attempt
    # p grid
    remaining_array = attempt - grid
    remaining_array.empty? ? true : false
  end

  def actual_english_word?(attempt)
    word = attempt.join.downcase
    # p word
    url = 'https://wagon-dictionary.herokuapp.com/' + word
    # url = "https://wagon-dictionary.herokuapp.com/dogg"

    # get API response and parse it
    api_response = open(url).read
    info = JSON.parse(api_response)

    # Return what you found - will always be either true or false - due to API design
    info["found"]
  end
end
