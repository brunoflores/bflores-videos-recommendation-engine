require 'sinatra'
require 'sinatra/cookies'
require 'elasticsearch'
require_relative 'model/user'
require_relative 'model/video'
require_relative 'model/show'

set :bind, '0.0.0.0'
enable :sessions

get '/' do
  redirect 'usuario/d10571ff55764928'
end

get '/usuario/:id' do |user_id|
  if session[:user_id].nil? || user_id != session[:user_id]
    session[:recent_history] = []
  end
  session[:user_id] = user_id
  
  client = Elasticsearch::Client.new log: true
  
  user = User.new(user_id)
  videos_history = user.get_videos_history client
  videos_history = videos_history | session[:recent_history]
  shows_history = user.get_shows_history client
  
  video = Video.new
  videos_top_recs = video.get_top_recs client, videos_history
  categories_recs = video.get_recs_by_category client, videos_history
  tags = video.get_tags client, videos_history
  
  show = Show.new
  shows_top_recs = show.get_top_recs client, shows_history
  
  erb :home, :locals => {
    :videos_top_recs => videos_top_recs, 
    :shows_top_recs => shows_top_recs, 
    :categories => categories_recs,
    :tags => tags
  }
end

get '/video/:id/:title' do |video_id, video_title|
  session[:recent_history] = session[:recent_history] | [video_id]
  
  client = Elasticsearch::Client.new log: true
  
  user = User.new(session[:user_id])
  videos_history = user.get_videos_history client
  videos_history = videos_history | session[:recent_history]
  
  video = Video.new
  similar_to = video.similar_to client, video_id, videos_history
  
  erb :video, :locals => {
    :tags => [],
    :video_title => video_title,
    :similar_to => similar_to
  }
end

get '/programa/:id/:title' do |show_id, show_title|
  client = Elasticsearch::Client.new log: true
  
  show = Show.new
  similar_to = show.similar_to client, show_id
  
  erb :show, :locals => {
    :tags => [],
    :show_title => show_title,
    :similar_to => similar_to
  }
end
