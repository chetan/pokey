
module Poker

class Game

    attr_accessor :deck, :hands, :players, :stage, :pot, :community, :turn,
                  :small_blind, :big_blind,
                  :small_blind_bet, :big_blind_bet,
                  :bet_num, :current_bet, :current_bets, :bet_map,
                  :turns, :winner
    
    # stages:
    #   0   not started
    #   1   cards dealt, pre-flop bet 
    #   2   flop
    #   3   turn
    #   4   river
    #   5   hand over
    
    STAGES = {
        0 => 'Start',
        1 => 'Pre-flop', # cards dealt
        2 => 'Flop',
        3 => 'Turn',
        4 => 'River',
        5 => 'Showdown' # game over
    }
    
    FOLD    = 0
    CHECK   = 1
    CALL    = 2
    RAISE   = 3
        
    def initialize(players, big_blind, big_blind_bet, small_blind_bet)

        @deck = Deck.new
        @deck.shuffle!
        
        @hands = {}
        @players = players
        @bet_map = {}
        @players.each { |p|
            p.hand = Hand.new
            @hands[p.name] = p.hand
        }
        
        @stage = 0
        @pot = 0
        @community = []
        
        # setup blinds
        
        reset_bets()      
        
        @big_blind = big_blind
        @small_blind = big_blind + 1
        @small_blind = 0 if @small_blind >= @players.size
        
        @big_blind_bet = big_blind_bet
        @small_blind_bet = small_blind_bet
        
        @turn = @big_blind
        @turns = []
        
    end
    
    def start
        # give each player 2 cards
        (1..2).each { 
            @hands.each { |name, hand|
                hand << @deck.deal
            }
        }
        # blinds
        add_chips(0, @big_blind_bet, @players[@big_blind])
        add_chips(@small_blind_bet, 0, @players[@small_blind])
        
        # begin
        @stage = 1
    end
    
    def current_stage
        return STAGES[@stage]
    end
    
    def current_turn
        return @players[@turn]
    end
    
    # get the player on the button (last to go in a round, e.g., to the "left" of big blind)
    def player_on_button
        p = @big_blind - 1
        return @players[-1] if p < 0
        return @players[p]
    end
    
    def small_blind
        return @players[@small_blind]
    end
    
    def big_blind
        return @players[@big_blind]
    end
    
    # how much the current player needs to call
    def amount_to_call(player = nil)
        player = current_turn() if player.nil?
        return @bet_map[player.name]
    end
    
    # give all chips to player
    def end_game(player)
        @stage = 5
        player.chips += @pot
        log("* %s won the game! he now has %s chips (\+%s)", player.name, player.chips, @pot)
        #@pot = 0
        @winner = player
    end
    
    def add_turn(type, amount = nil)
        turns << { "player" => current_turn,
                   "type"   => type,
                   "amount" => amount } 
    end


    
    # FIXME these moves always assume the current players turn
    def check
        log("pp checked")
        add_turn(CHECK)
        
        if amount_to_call() > 0 then
            Kernel::raise "Player can't check! Must either call or raise"            
        end
        
        if current_turn == player_on_button then
            # checking from the last position is like a call
            deal()
        else
            # if not the last player, continue
            next_turn()
        end
    end
    
    def fold
        add_turn(FOLD)
        @hands.delete(current_turn.name)
        if @hands.size == 1 then
            # game ended
            winner = @players.find { |p| p.name == @hands.keys[0] }
            end_game(winner)
        end
    end
    
    def raise(amount)
        log("pp raised %s", amount)
        add_turn(RAISE, amount)
        add_chips(amount_to_call(), amount)
        next_turn()
    end
    
    # call is just adding the current bet amount
    def call
        log("pp called")
        add_turn(CALL)
        add_chips(amount_to_call())
        # check if bet map is zeroed out
        if @bet_map.values.detect { |v| v > 0 } then
            # still have outstanding bets
            next_turn()
        else
            # ready for next round
            deal()
        end
    end
    
    protected
    
    def add_blind(player, amount)
        if player.chips >= amount then
            @pot += amount
            player.chips -= amount
        else
            @pot += player.chips
            player.chips = 0
        end
    end
    
    def deal
        return if @stage == 0 || @stage == 5 #throw err?
        @deck.deal # burn a card
        if @stage == 1 then
            (1..3).each { @community << @deck.deal }
        elsif @stage == 2 || @stage == 3 then
            @community << @deck.deal
        end
        reset_bets()
        @stage += 1
        @turn = @big_blind
    end
    
    def log(msg, *args)
        out = msg % args
        out.gsub!('pp', current_turn.name) if current_turn()
        puts out
    end
    
    def add_chips(call_amount, raise_amount = 0, player = nil)
    
        player = current_turn() if player.nil?
    
        call_amount = 0 if call_amount.nil?
        amount = raise_amount + call_amount
        
        if call_amount > 0 then
            add_call(player, call_amount)
        end
        if raise_amount > 0 then
            add_raise(player, raise_amount)
        end
            
        if player.chips >= amount then
            add = amount
            player.chips -= amount
            
        else
            add = player.chips
            player.chips = 0
        end
        
        log("+ adding %s total chips to pot from %s", add, player.name)
        
        bet = Bet.new(player.name, add)
        
        @pot += add
        @current_bets.push(bet)
        @current_bet += add
    end
    
    # subtract call amount from calling player
    def add_call(player, amount)
        log("dbg: subtracting call %s for %s", amount, player.name)
        @bet_map[player.name] -= amount # multipurpose function, otherwise we could just set to zero
        print "bet map: "
        p @bet_map
    end
    
    # when raising, zero out player who raised and add to all others
    def add_raise(player, amount)
        log("dbg: adding raise %s for %s", amount, player.name)
        @bet_map.each { |p,v|
            if p == player.name then
                @bet_map[p] = 0
            else
                @bet_map[p] += amount
            end
        }
        print "bet map: "
        p @bet_map
    end
    
    def next_turn(turn = nil)
        @turn += 1 if turn.nil?
        @turn = 0 if @turn >= @players.size
        @bet_num += 1
    end
    
    def reset_bets()
        @bet_num = 1
        @current_bet = 0
        @current_bets = []
        @players.each { |p|
            @bet_map[p.name] = 0
        }
    end
    
    def find_best_hand(player)
    
        all_cards = @community + @hands[player].cards
        
        if all_cards.size == 5 then
            # only 1 possible hand
            #return Hand.new([ Card.new('A', 's'), Card.new('2', 'd'), Card.new('3', 's'), Card.new('4', 's'), Card.new('5', 's')]) 
            return Hand.new(all_cards.to_a)
        end
        
        best = nil
        all_hands = []
        all_cards.perm(5) do |p|
            all_hands << Hand.new(p)
        end
        
        all_hands.each { |h|
            if best.nil? then
                best = h
                next
            end
            if h > best then
                best = h
            end
        }
        
        return best
    
    end

end

end