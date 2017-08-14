require 'open-uri'
require 'json'

class PagesController < ApplicationController
  def game
    games = session[:games]
    if !games
      session[:games] = 0
    end
    @start_time = Time.now
    @grid = generate_grid(9)
  end

  def score
    @numbergames = session[:games] += 1
    @grid = params[:grid].chars
    @start_time = Time.parse(params[:start_time])
    @end_time = Time.now
    answer = params[:answer]
    game = run_game(answer, @grid, @start_time, @end_time)
    @score = game[:score].round(2)
    @message = game[:message]
    @time = game[:time].round(2)
  end


private
  def generate_grid(grid_size)
    result = []
    grid_size.times do
      result << ("A".."Z").to_a.sample
    end
    return result
  end

  def run_game(attempt, grid, start_time, end_time)
    score = 0
    if real_word(attempt) && compare(attempt, grid)
      message = "well done"
      score = (attempt.length * 5) - (end_time - start_time)
    elsif !real_word(attempt)
      message = "not an english word"
    elsif !compare(attempt, grid)
      message = "not in the grid"
    end
    return { time: end_time - start_time, score: score, message: message }
  end

  def real_word(input)
    serialized_url = open("https://wagon-dictionary.herokuapp.com/#{input}").read
    word = JSON.parse(serialized_url)
    if word["found"]
      true
    else
      false
    end
  end

  def count_words(word)
    hash = Hash.new(0)
    word = word.join if word.class == Array
    word.split("").each do |x|
      hash[x] += 1
    end
    hash
  end

  def compare(input, grid)
    word = input.upcase
    word.split("").all? do |x|
      count_words(word)[x] <= count_words(grid)[x]
    end
  end


end




