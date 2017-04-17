require 'open-uri'
require 'json'

class GameController < ApplicationController
  def new_game
    @grid = generate_grid(10).shuffle
  end

  def score
    @attempt = params[:attempt].strip
    @grid = params[:grid].split('')
    @time = params[:time].to_f / 1000
    @result = run_game(@attempt, @grid, @time)
  end

  private

  def generate_grid(grid_size)
  Array.new(grid_size / 2) { random_consonant } + Array.new(grid_size / 2) { random_vowel }
  end

  def random_consonant
  (('A'..'Z').to_a - ['A', 'E', 'I', 'O', 'U']).sample
  end

  def random_vowel
    ['A', 'E', 'I', 'O', 'U'].sample
  end

  def run_game(attempt, grid, time)
  contained_grid = contained_in_grid?(attempt, grid)
  result_time = time.round(2)
  translation = translation(attempt)
  score = scoring(attempt, time, translation, contained_grid)
  message = message(attempt, translation, contained_grid)
  { time: result_time, translation: translation, score: score, message: message }
  end

  def contained_in_grid?(attempt, grid)
    attempt.upcase.split('').uniq.all? { |letter| grid.count(letter) >= attempt.upcase.count(letter) }
  end

  def translation(attempt)
    return nil if attempt.empty?
    url = "https://api-platform.systran.net/translation/text/translate?"\
          "source=en&target=fr&key=ec9555fc-fc67-4ecd-94a1-3be23efbf2c8&input=#{attempt}"
    response = JSON.parse(open(url).read)
    translation = response["outputs"][0]["output"]
    attempt != translation ? translation : nil
  end

  def message(attempt, translation, contained_grid)
    if attempt.empty?
      "No answer provided."
    elsif !contained_grid
      "Not in the grid."
    elsif translation.nil?
      "Not an english word."
    else
      "Well done!"
    end
  end

  def scoring(attempt, time, translation, contained_grid)
    translation.nil? || !contained_grid ? 0 : (attempt.length + ((30 - time) / 2)).round(2)
  end

end
