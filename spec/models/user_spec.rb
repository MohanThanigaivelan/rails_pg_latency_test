require 'rails_helper'

RSpec.describe User, type: :model do
  LATENCY_IN_MILLISECONDS = [50, 2000]
  
  context "Hypothesis" do
   let!(:user) { FactoryBot.create(:user) }

   LATENCY_IN_MILLISECONDS.each do |latency|
      context "with #{latency} seconds" do
        it "Sequential execution of queries" do
          ActiveRecord::Base.logger = Logger.new(STDOUT)
          Toxiproxy[:postgres].toxic(:latency, latency: latency).apply do
            time = Benchmark.measure {
              User.uncached do
                user_1 = User.slow_query
                user_2 = User.slow_query
                user_3 = User.slow_query
                user_4 = User.slow_query
                user_5 = User.slow_query
    
                user_1.to_a
                user_2.to_a
                user_3.to_a
                user_4.to_a
                user_5.to_a
              end
            }
            SPEC_STATS["sequential_execution_with_#{latency}ms"] = time.real
          end
        end
    
        it "Queries in pipeline mode" do  
        
          ActiveRecord::Base.logger = Logger.new(STDOUT)
          conn = PG.connect(dbname: Rails.configuration.database_configuration["test"]["database"], host: 'toxiproxy', port: 22001, user: "postgres" , password: "postgres")
          Toxiproxy[:postgres].toxic(:latency, latency: latency).apply do
            time = Benchmark.measure {
              conn.enter_pipeline_mode
              conn.send_query("SELECT users.* FROM users WHERE (SELECT true FROM pg_sleep(3));")
              conn.pipeline_sync
              conn.send_query("SELECT users.* FROM users WHERE (SELECT true FROM pg_sleep(3));")
              conn.pipeline_sync
              conn.send_query("SELECT users.* FROM users WHERE (SELECT true FROM pg_sleep(3));")
              conn.pipeline_sync
              conn.send_query("SELECT users.* FROM users WHERE (SELECT true FROM pg_sleep(3));")
              conn.pipeline_sync
              conn.send_query("SELECT users.* FROM users WHERE (SELECT true FROM pg_sleep(3));")
              conn.pipeline_sync
              @a = conn.get_result 
              @b = conn.get_result 
              @c = conn.get_result
              @d = conn.get_result 
              @e = conn.get_result 
              @f = conn.get_result 
              @g = conn.get_result
              @h =  conn.get_result
              @i = conn.get_result
              @j = conn.get_result
              conn.get_result 
            }
            SPEC_STATS["pipeline_mode_with_#{latency}ms"] = time.real
          end
        end
    
        it "Load Async" do
          ActiveRecord::Base.logger = Logger.new(STDOUT)
          Toxiproxy[:postgres].toxic(:latency, latency: latency).apply do
            time = Benchmark.measure {
              user_1 = User.slow_query.load_async
              user_2 = User.slow_query.load_async
              user_3 = User.slow_query.load_async
              user_4 = User.slow_query.load_async
              user_5 = User.slow_query.load_async
    
              user_1.to_a
              user_2.to_a
              user_3.to_a
              user_4.to_a
              user_5.to_a
           }
           SPEC_STATS["load_async_with_#{latency}ms"] = time.real
          end
        end
      end
   end
  end

end

# proxy = @proxies.find{|b| b.name == "postgres"}
# latency_proxy = Toxiproxy::Toxic.new(type: "latency", attributes: { latency: 6000 }, proxy: proxy ).save
# latency_proxy.destroy


# 15.times do 
#   time = Benchmark.measure {
#             user_1 = User.slow_query.load_async 
#             user_2 = User.slow_query.load_async 
#             user_1.to_a
#             user_2.to_a
#         }
#         pp time.real
# end



# 15.times do |i|
#   time = Benchmark.measure {
#     user_1 = User.slow_query.load_async
#     user_2 = User.slow_query.load_async
#     user_1.to_a

#     user_2.to_a
# }
# end

# m = Mutex.new
# count = 0
# a = Thread.new do
#   loop do
#     m.synchronize do
#       puts "Inside First Thread"
#       count = count + 1; 
#     end
#   end
# end

# a = Thread.new do
#   loop do
#     m.synchronize do
#       puts "Inside Second Thread"
#       puts count
#     end
#   end
# end


# conn = PG.connect(dbname: Rails.configuration.database_configuration["test"]["database"], host: 'toxiproxy', port: 22001, user: "postgres" , password: "postgres")
# conn.enter_pipeline_mode
# conn.send_query("SELECT users.* FROM users WHERE (SELECT true FROM pg_sleep(3))")
# conn.send_query("SELECT users.email FROM users WHERE (SELECT true FROM pg_sleep(3))")
# conn.pipeline_sync
# conn.send_flush_request

# conn.pipeline_sync
# conn.get_result
# conn.get_result
# conn.get_result


# conn = PG.connect(dbname: Rails.configuration.database_configuration["test"]["database"], host: 'toxiproxy', port: 22001, user: "postgres" , password: "postgres")
# conn.enter_pipeline_mode
# conn.send_query("SELECT users.* FROM users WHERE (SELECT true FROM pg_sleep(3))")
# conn.send_query("SELECT users.email FROM users WHERE (SELECT true FROM pg_sleep(3))")
# conn.send_query("SELECT users.id FROM users WHERE (SELECT true FROM pg_sleep(3))")
# conn.send_query("SELECT users.email FROM users WHERE (SELECT true FROM pg_sleep(3))")
# conn.send_query("SELECT users.email FROM users WHERE (SELECT true FROM pg_sleep(3))")
# conn.pipeline_sync
# conn.get_result
# conn.get_result
# conn.get_result