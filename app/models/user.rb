class User < ApplicationRecord
    scope :slow_query, ->(time) {
        where("SELECT true FROM pg_sleep(?)", time) } 
end
