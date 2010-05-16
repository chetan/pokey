
module Poker

class Table
    
    attr_accessor :players, :game, :big_blind, :small_blind, :blind_pos, :hand_num, :starting_chips
    
    def initialize(starting_chips, big_blind, small_blind)
        @players = []
        @game = nil
        @blind_pos = 0
        @hand_num = 0
        @starting_chips = starting_chips
        @big_blind = big_blind
        @small_blind = small_blind
    end
    
    def << (player)
        @chip_map[player.name] = @starting_chips
        @players << player
    end

    def chips(player)
        @chip_map[player.addr]
    end
    
    def settle()
        @game.players.each { |p| @chip_map[p.name] = p.chips }
    end
    
    def next_blind_pos 
        b = @blind_pos
        @blind_pos += 1
        @blind_pos = 0 if @blind_pos >= @players.size # reset
        return b
    end
    
    def new_game
        @hand_num += 1
        if @hand_num == 1 then
            # randomly seat the players at the start of the session
            @players = @players.sort_by { rand }
        end
        @game = Game.new(@players, next_blind_pos(), @big_blind, @small_blind)
    end  
    
end

end