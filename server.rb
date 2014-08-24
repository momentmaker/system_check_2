require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'csv'

def get_gameresults()
  games = []

  CSV.foreach('games.csv', headers: true, header_converters: :symbol, converters: :numeric) do |row|
    games << row.to_hash
  end
  games
  #binding.pry
end

def get_teamlist(games)
  team_list = []

  games.each do |team|
    team_list << team[:home_team]
    team_list << team[:away_team]
  end

  team_list.uniq!
end


def update_gamestats(games, teams)
  league = []
  team_count = 0

  teams.each do |team|

    league << {name: team, opps: [], wins: 0, losses: 0}

    games.each do |game|

      if game[:home_team] == team #if played at home
        #binding.pry
        league[team_count][:opps] << {game[:away_team] => [own_score: game[:home_score], opp_score: game[:away_score]]}
        if game[:home_score] > game[:away_score]
          league[team_count][:wins] += 1
        else
          league[team_count][:losses] += 1
        end
      elsif game[:away_team] == team #if played at opponent
        league[team_count][:opps] << {game[:home_team] => [own_score: game[:away_score], opp_score: game[:home_score]]}
        if game[:home_score] < game[:away_score]
          league[team_count][:wins] += 1
        else
          league[team_count][:losses] += 1
        end
      end
    end
    #binding.pry
    team_count += 1
  end
  league
end

def sort_team(league)
  sorted_league = league

  #binding.pry

  sorted_league.each do |team|
    #binding.pry
    team[:diff] = team[:wins] - team[:losses]
    #binding.pry
  end

  sorted_league.sort_by {|x| x[:diff]}.reverse!
end

def get_team(league, team)
  team_stat = []

  league.each do |team_name|
    #binding.pry
    if team_name[:name] == team
      team_stat << team_name
    end
  end
  team_stat
  # binding.pry
end


get '/' do
  @league = update_gamestats(get_gameresults, get_teamlist(get_gameresults))
  #binding.pry
  erb :index
end

get '/leaderboard' do
  @league = sort_team(update_gamestats(get_gameresults, get_teamlist(get_gameresults)))
  erb :leaderboard
end

get '/leaderboard/:team' do
  @team = get_team(update_gamestats(get_gameresults, get_teamlist(get_gameresults)), params[:team])
  #binding.pry
  erb :individual_team
end
