class User < ApplicationRecord
    scope :slow_query, -> {
        where("SELECT true FROM pg_sleep(3)") } 
end
