require 'open-uri'
require 'json'

class GamesController < ApplicationController
  attr_reader :start_time

  def new
    # used to display a new random grid and a form.
    letters = ('A'..'Z').to_a
    vowels = %w[A E I O U]
    grid = []
    i = 9
    while i.positive?
      grid << letters.sample(1)
      i -= 1
    end
    grid << vowels.sample(1)
    @letters = grid.flatten
  end

  def score
    # The form will be submitted (with POST) to the score action.
    attempt = params[:word]
    @end_time = Time.now
    url = "https://wagon-dictionary.herokuapp.com/#{@attempt}"
    check_word = JSON.parse(URI.open(url).read)

    @results = {}
    @results[:time] = @end_time - params[:start_time].to_datetime

    grid_char_count = params[:letters].split.select { |char| attempt.upcase.include? char }.group_by(&:itself).transform_values(&:count)
    attempt_char_count = attempt.upcase.chars.group_by { |e| e }.map { |k, v| [k, v.length] }
    # if the entered word contains letters not in grid
    if attempt.upcase.chars.any? { |s| params[:letters].include?(s).! }
      @results[:score] = 0
      @results[:message] = "Letter not in the grid"
    elsif attempt_char_count.any? { |count| count[1] > grid_char_count[count[0]] }
      @results[:score] = 0
      @results[:message] = "Letter not in the grid"
    elsif check_word["found"] == false
      @results[:score] = 0
      @results[:message] = "Not an english word"
    else
      score = (1 / @results[:time]) + attempt.length
      @results[:score] = score
      @results[:message] = "Well Done!"
    end
    @results
  end
end
