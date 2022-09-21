#Toxiproxy.host = "http://host.docker.internal:8474"
#Toxiproxy.host =  "toxiproxy:8474"
# Toxiproxy.populate([{
#    name: "postgres",
#    listen: "http://host.docker.internal:29092",
#    upstream: "http://host.internal.docker:5432", 
# }])

#Toxiproxy.host = "http://127.0.0.1:8474"

# Toxiproxy.populate([
#     {
#       name: "postgres",
#       listen: "0.0.0.0:22001",
#       upstream: "localhost:3306",
#     }
#   ])



# @proxies = Toxiproxy.populate([
#   {
#      name: "postgres",
#      listen: "toxiproxy:22001",
#      upstream: "db:5432",
#   }
#  ])
