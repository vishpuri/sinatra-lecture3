require 'rubygems'
require 'sinatra'

set :sessions, true

get '/'  do
	if session[:player]
		redirect '/game'
	else
		redirect '/form'
	end
end

helpers do
	# any method defined in helpers block is available in the main file and the view template
	def calculate_total(cards) # where cards is a nested array
	face_values = cards.map{|element| element[1] }
    total = 0
    face_values.each do |val|
      if val == "A"
        total += 11
      else
        total += (val.to_i == 0 ? 10 : val.to_i)
      end
    end

    #correct for Aces
    face_values.select{|val| val == "A"}.count.times do
      break if total <= 21
      total -= 10
    	end
    total
	end

	def card_image(card) # card is a nested array [H,4]
		suit = case card[0]
		when 'H' then 'hearts'
		when 'D' then 'diamonds'
		when 'C' then 'clubs'
		when 'S' then 'spades'
		end

		value = case card[1]
		when 'J' then 'jack'
		when 'Q' then 'queen'
		when 'K' then 'king'
		when 'A' then 'ace'
		else card[1]
		end
		return "<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"
	end
end

get '/form' do
erb :form1
end

# before filter runs this code before everything else
before do
@show_buttons=true
end


post '/playername' do
session[:player] = params[:username]
redirect '/game'
end

get '/game' do
	suit = ['H', 'C', 'S', 'D']
	values = ['2','3','4','5','6','7','8','9','10', 'J', 'Q', 'K', 'A']
	session[:deck] = suit.product(values).shuffle!
	session[:player_cards]=[]
	session[:dealer_cards]=[]
	session[:player_cards]<< session[:deck].pop
	session[:dealer_cards]<< session[:deck].pop
	session[:player_cards]<< session[:deck].pop
	session[:dealer_cards]<< session[:deck].pop
erb :game
end


post '/game/player/hit' do
session[:player_cards]<< session[:deck].pop
player_total = calculate_total(session[:player_cards])
if player_total == 21
	@success = "Congratulations, #{session[:player]} hit blackjack!"
@show_buttons = false
elsif player_total > 21
@error = "Looks like you are busted"
# @error and @success instance variables are available in the template
@show_buttons = false
end
erb :game
end

post '/game/player/stay' do
@success = "You have choosen to stay"
@show_buttons = false
erb :game
end

