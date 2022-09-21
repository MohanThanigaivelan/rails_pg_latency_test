class User < ApplicationRecord
    scope :slow_query, -> {
        where("SELECT true FROM pg_sleep(3)") } 

    scope :fast_query, -> {
        where("SELECT true FROM pg_sleep(1)") }     
end
