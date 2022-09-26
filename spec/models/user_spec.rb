require 'rails_helper'

RSpec.describe User, type: :model do
  NETWORK_LATENCY_IN_MILLISECONDS = [5, 10, 50] 
  QUERY_DELAY_IN_MILLISECONDS = [50,100, 200]


  describe "Hypothesis" do
   let!(:user) { FactoryBot.create(:user) }

   context "Warming up" do
    it "Executing queries to set up the connection pool" do
      8.times do
        User.slow_query(0).load_async.to_a
      end
    end
  end
   
   NETWORK_LATENCY_IN_MILLISECONDS.each do |latency|
    QUERY_DELAY_IN_MILLISECONDS.each do |delay|
      context "with #{latency} seconds" do
        it "Sequential execution of queries" do
          ActiveRecord::Base.logger = Logger.new(STDOUT)
          Toxiproxy[:postgres].toxic(:latency, latency: latency).apply do
            queries = []
            time = Benchmark.measure {
              User.uncached do
                5.times do
                  queries << User.slow_query(delay* 0.001)
                end
                queries.each do |query|
                  query.to_a
                end
              end
            }
            SPEC_STATS["sequential_execution_with_#{latency}ms_latency_and_#{delay}ms_query_time"] = time.real
          end
        end
    
        it "Queries in pipeline mode" do  
          ActiveRecord::Base.logger = Logger.new(STDOUT)
          conn = PG.connect(dbname: Rails.configuration.database_configuration["test"]["database"], host: 'toxiproxy', port: 22001, user: "postgres" , password: "postgres")
          Toxiproxy[:postgres].toxic(:latency, latency: latency).apply do
            time = Benchmark.measure {
              conn.enter_pipeline_mode
              5.times do 
                conn.send_query("SELECT users.* FROM users WHERE (SELECT true FROM pg_sleep(#{delay* 0.001}));")
                conn.pipeline_sync
              end
              non_nil_results = 0
              loop do
                result =  conn.get_result
                if result.try(:values) && !result.values.empty?
                 
                  non_nil_results += 1
                  if non_nil_results == 5
                    break
                  end
                end
              end

              
            }
            SPEC_STATS["pipeline_mode_with_#{latency}ms_latency_and_#{delay}ms_query_time"] = time.real
          end
        end
    
        it "Queries with Load Async" do
          ActiveRecord::Base.logger = Logger.new(STDOUT)
          queries = []
          Toxiproxy[:postgres].toxic(:latency, latency: latency).apply do
            time = Benchmark.measure {
              5.times do 
                queries << User.slow_query(delay* 0.001).load_async
              end
              queries.each do |query|
                query.to_a
              end
           }
           SPEC_STATS["load_async_with_#{latency}ms_latency_and_#{delay}ms_query_time"] = time.real
          end
        end
      end
    end
   end
  end

end