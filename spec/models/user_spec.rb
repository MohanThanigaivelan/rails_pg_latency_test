require 'rails_helper'

RSpec.describe User, type: :model do
  NETWORK_LATENCY_IN_MILLISECONDS = [2000, 50, 3000] 
  
  describe "Hypothesis" do
   let!(:user) { FactoryBot.create(:user) }
   
   NETWORK_LATENCY_IN_MILLISECONDS.each do |latency|
      context "with #{latency} seconds" do
        it "Sequential execution of queries" do
          ActiveRecord::Base.logger = Logger.new(STDOUT)
          Toxiproxy[:postgres].toxic(:latency, latency: latency).apply do
            queries = []
            time = Benchmark.measure {
              User.uncached do
                5.times do
                  queries << User.slow_query
                end
                queries.each do |query|
                  query.to_a
                end
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
              5.times do 
                conn.send_query("SELECT users.* FROM users WHERE (SELECT true FROM pg_sleep(3));")
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
            SPEC_STATS["pipeline_mode_with_#{latency}ms"] = time.real
          end
        end
    
        it "Queries with Load Async" do
          ActiveRecord::Base.logger = Logger.new(STDOUT)
          queries = []
          Toxiproxy[:postgres].toxic(:latency, latency: latency).apply do
            time = Benchmark.measure {
              5.times do 
                queries << User.slow_query.load_async
              end
              queries.each do |query|
                query.to_a
              end
           }
           SPEC_STATS["load_async_with_#{latency}ms"] = time.real
          end
        end
      end
   end
  end

end