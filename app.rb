require 'sinatra/base'
require 'sinatra/reloader'
require_relative './lib/listing_repo'
require_relative './lib/database_connection'
require_relative './lib/user_repo'
require_relative './lib/bookings_repository'

DatabaseConnection.connect

class Application < Sinatra::Base
  enable :sessions
  
  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    repo = ListingRepository.new

    @listings = repo.all

    return erb(:index)
  end
  
  get '/listing/:id' do
    repo = ListingRepository.new
    @listing = repo.find(params[:id])
    session[:listing_id] = @listing.id
    return erb(:listing)
  end

  get '/login' do
    return erb(:login)
  end 
  
  post '/login' do
    repo = UserRepository.new

    outcome = repo.all

    user = repo.find_by_email(params[:email])

    if outcome.to_s.include?(user.email)
      user_password = user.password
      if repo.valid_password?(user_password, params[:password]) == "success"
        session[:user_id] = user.id
        redirect '/'
      else  
        redirect '/login'
      end    
    else 
      redirect '/login'
    end
  end  

  get '/booking/new' do 
    return erb(:new_booking)
  end 

  post '/booking' do 
    booking = Booking.new
    
    booking.date = params[:date]
    booking.user_id = session[:user_id] ||= params[:user_id]
    booking.listing_id = session[:listing_id] ||= params[:listing_id]

    repo = BookingRepository.new 
    repo.create(booking)
  end 
  
end