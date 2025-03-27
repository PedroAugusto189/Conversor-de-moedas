require 'httparty'

class ExchangeService
  include HTTParty
  base_uri 'https://api.exchangerate-api.com/v4/latest'

  def self.get_rate(from, to)
    cache_key = "#{from}_#{to}"
    cached_rate = $redis.get(cache_key)

    return cached_rate.to_f if cached_rate

    response = get("/#{from}")
    rate = response.parsed_response['rates'][to]

    # Cache por 1 hora (3600 segundos)
    $redis.setex(cache_key, 3600, rate)

    rate
  rescue => e
    puts "Error fetching rate: #{e.message}"
    1.0 # Retorna 1.0 como fallback
  end
end