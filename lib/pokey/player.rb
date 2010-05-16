
module Poker

class Player

    attr_accessor :name, :hand, :chips, :all_in
    
    def initialize(name, chips)
        @name = name
        @chips = chips
        @all_in = false
    end

end

end