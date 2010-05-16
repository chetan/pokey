
module Poker

class Hand

    TYPES = {
        'flushes'   => { 'Royal Flush' => 10,
                         'Straight Flush' => 9,
                         'Flush' => 8 },
        'straights' => { 'Straight Flush' => 9,
                         'Straight' => 8 },
        'pairs'     => {'Four of a kind' => 3,
                        'Full House' => 3,
                        'Three of a kind' => 3,
                        'Two pair' => 2,
                        'Pair' => 1},
        'high'      => {'High Card' => 1}
    }
    
    # ranks
    ROYAL_FLUSH     = 10
    STRAIGHT_FLUSH  =  9
    FOUR_KIND       =  8
    FULL_HOUSE      =  7
    FLUSH           =  6
    STRAIGHT        =  5
    THREE_KIND      =  4
    TWO_PAIR        =  3
    PAIR            =  2
    HIGH_CARD       =  1
    
    RANK_MAP = {
        10 => 'Royal Flush',
        9  => 'Straight Flush',
        8  => 'Four of a kind',
        7  => 'Full House',
        6  => 'Flush',
        5  => 'Straight',
        4  => 'Three of a kind',
        3  => 'Two pair',
        2  => 'Pair',
        1  => 'High Card'
    }

    include Comparable

    attr_accessor :cards, :best, :faces, :suits, :total_face_value, :score, :rank, :value
    
    def initialize(cards = nil)
        @cards = []
        @faces = []
        @suits = []
        @total_face_value = 0
        @score = 0
        @rank = 0
        @value = 0
        @unpaired_cards = nil
        self << cards if cards
    end
    
    # add cards
    def << (cards)
        if ! cards.is_a?(Array) then
            cards = [cards]
        end
        cards.each { |c| add_card(c) }
        return if @cards.size < 5 # only rank & score with 5 cards or more
        identify()
        calculate_score()
    end

    def add_card(card)
        @cards << card
        @faces << card.face
        @suits << card.suit
        @total_face_value += card.face_value
    end
    
    def calculate_score()
        if @unpaired_cards.nil? then
            @score = [@rank*10000 + @value, '.', join_values(@cards)].join('').to_f
        else
            # add kicker to score
            s = [@rank*10000 + @value, '.', join_values(@unpaired_cards)]
            @score = s.join('').to_f
        end
    end
    
    def join_values(cards)
        sorted = cards.sort
        sorted.reverse!
        s = []
        sorted.each { |c|
            s << (c.face_value < 10 ? "0#{c.face_value}" : c.face_value)
        }
        return s.join('')
    end
    
    def <=> hand2
        @score <=> hand2.score
    end
    
    def to_s
        s = []
        @cards.each { |c| s << c.to_s }
        return sprintf("cards: %s; score: %s (%s)", s.join(' '), @score, RANK_MAP[@rank])
    end
    
    # figure out what we have based on cards
    def identify
    
        return if @value > 0 # no need to do it twice!
        return if @cards.size < 5 # need at least 5 cards
        
        @cards.sort!
        
        #puts "@total_face_value = #{@total_face_value}"
        
        if is_flush? then 
            #puts 'have a flush of some kind...' 
            
            if @total_face_value == 60 then
                #puts "it's a royal flush!"
                @rank = ROYAL_FLUSH
                @value = @cards.max.face_value
                return
            end
            
            if is_straight? then
                #puts "it's straight flush!"
                @rank = STRAIGHT_FLUSH
                @value = @cards.max.face_value
                return
            end
            
            #puts "it's a regular flush!"
            @rank = FLUSH
            @value = @cards.max.face_value
            return
        end
        
        #puts 'not a flush'
        
        if is_straight? then
            #puts "it's a straight!"
            @rank = STRAIGHT
            @value = @cards.max.face_value
            return
        end
        
        # look for pairs
        (pairs, @unpaired_cards) = find_pairs()
        if pairs.empty? then
            # high card!
            #puts "high card " + high_card.to_s
            @rank = HIGH_CARD
            @value = @cards.max.face_value
            return
        end
        
        if pairs.size == 1 then
            paired_cards = pairs[0].size
            @value = pairs[0].max.face_value
            if paired_cards == 2 then
                #puts "it's a single pair!"
                @rank = PAIR
            elsif paired_cards == 3 then
                #puts "it's a three of a kind!"
                @rank = THREE_KIND
            elsif paired_cards == 4 then
                @rank = FOUR_KIND
            end
            return
            
        elsif pairs.size == 2 then
            paired_cards = pairs[0].size + pairs[1].size
            a = pairs[0].max.face_value
            b = pairs[1].max.face_value
            if a > b then
                @value = a
            elsif b > a then
                @value = b
            else
                # should never happen since it means the
                # pairs are of the same face value
                # e.g., two pairs of 6s
                @value = a
            end
            if paired_cards == 4 then
                #puts "it's two pair!"
                @rank = TWO_PAIR
            elsif paired_cards == 5 then
                #puts "it's a full house!"
                @rank = FULL_HOUSE
                # add faces of each pair for value
                if a > b then
                    @value = a * 100 + b
                elsif b > a then
                    @value = b * 100 + a
                end
            end
            return
            
        end
        
        # should never get here
        raise "oh no, should never have come to this!"
    
    end
    
    def find_pairs 
        cards_by_face = {}
        @cards.each { |c|
            if cards_by_face.has_key? c.face then
                cards_by_face[c.face] << c
            else
                cards_by_face[c.face] = [c]
            end
        }
        pairs = []
        unpaired = []
        cards_by_face.each { |face, cards| 
            if cards.size < 2 then
                unpaired << cards[0]
            else
                pairs << cards
            end
        }
        return [pairs, unpaired]
    end
    
    def is_straight?
        s = check_straight(@cards)
        return s if s == true
        # check for low ace straight
        cards = []
        @cards.each { |c| 
            if c.face == 'A' then
                cards << Card.new(c.face, c.suit, 1)
            else
                cards << c
            end
        }
        cards.sort!
        s = check_straight(cards)
        if s == true then
            @cards = cards
        end
        return s
    end
    
    # should be private method
    def check_straight(cards)
        last = nil
        cards.each { |c|
            if last.nil? then
                last = c.face_value
                next
            end
            return false if c.face_value != last + 1
            last = c.face_value
        }
        return true
    end
    
    def is_flush?
        first = nil
        @suits.each { |s| 
            if first.nil? then
                first = s
                next
            end
            return false if s != first
        }
        return true
    end

end

end