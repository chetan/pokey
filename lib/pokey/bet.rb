
module Poker

class Bet

    attr_accessor :name, :amount
    
    def initialize(name, amount)
        @name = name
        @amount = amount
    end

end

end