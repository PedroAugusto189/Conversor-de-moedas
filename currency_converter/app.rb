require 'sinatra'
require 'sinatra/reloader' if development?
require './config/redis'
require './services/exchange_service'
require 'dotenv'
Dotenv.load

set :bind, '0.0.0.0'

# Endpoint principal
get '/convert' do
  content_type :json

  amount = params[:amount].to_f
  from = params[:from]&.upcase || 'USD'
  to = params[:to]&.upcase || 'BRL'

  rate = ExchangeService.get_rate(from, to)
  result = (amount * rate).round(4)

  {
    from: from,
    to: to,
    amount: amount,
    rate: rate,
    result: result,
    cached: $redis.exists?("#{from}_#{to}")
  }.to_json
end

# Health check
get '/health' do
  content_type :json
  { status: 'OK', redis: $redis.ping == 'PONG' }.to_json
end