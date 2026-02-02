require "net/http"
require "json"
require "securerandom"

API_URL = URI("http://localhost:3000/api/v1/device_reports")

STATUSES = (
  ["operational"] * 16 + 
  ["maintenance"] * 4 +    
  ["failing"] * 4 +        
  ["offline"] * 4          
).freeze

# STATUSES = %w[operational failing maintenance offline]
DEVICE_KINDS = %w[pos printer network]

def random_status
  STATUSES.sample
end

def random_device(identifier)
  status = random_status

  device = {
    identifier: identifier,
    kind: DEVICE_KINDS.sample,
    status: status,
    meta: {
      ip: "10.0.#{rand(1..10)}.#{rand(1..254)}",
      version: "1.#{rand(0..5)}.#{rand(0..9)}"
    }
  }

  if status == "maintenance"
    device[:maintenance] = {
      action: "cleaning",
      notes: "Mantenimiento preventivo automático"
    }
  end

  device
end

def send_report(restaurant_name, city, device_count = 3)
  payload = {
    report: {
      restaurant: {
        name: restaurant_name,
        city: city
      },
      devices: (1..device_count).map do |i|
        random_device("DEV-#{i}")
      end
    }
  }

  http = Net::HTTP.new(API_URL.host, API_URL.port)
  request = Net::HTTP::Post.new(API_URL)
  request["Content-Type"] = "application/json"
  request.body = JSON.generate(payload)

  response = http.request(request)

  puts "→ Enviado reporte para #{restaurant_name}"
  puts "  Status HTTP: #{response.code}"
  puts "  Response: #{response.body}"
  puts "-" * 50
rescue => e
  puts "❌ Error enviando reporte: #{e.message}"
end

# -----------------------------
# LOOP DE SIMULACIÓN
# -----------------------------

restaurants = [
  ["Niu Centro", "Santiago"],
  ["Niu Norte", "Independencia"],
  ["Niu Sur", "San Miguel"]
]

puts "🟢 Iniciando simulación de restaurantes..."

loop do
  restaurants.each do |name, city|
    send_report(name, city, rand(2..4))
  end

  sleep 5
end