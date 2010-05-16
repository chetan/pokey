
class Deck

    SUITS = %w/C D H S/ # club, diamond, heart, spade
    FACES = %w/2 3 4 5 6 7 8 9 T J Q K A/

    FACE_VALUES = {
        '1' =>  1,
        '2' =>  2,
        '3' =>  3,
        '4' =>  4,
        '5' =>  5,
        '6' =>  6,
        '7' =>  7,
        '8' =>  8,
        '9' =>  9,
        'T' => 10,
        'J' => 11,
        'Q' => 12,
        'K' => 13,
        'A' => 14
    }

    attr_reader :cards, :dealt
    
    @cards
    @dealt

    def initialize
        
        @cards = []
        SUITS.each { |s|
            FACES.each { |f|
                @cards << Card.new(f, s)
            }
        }
        
        # holds cards which have been dealt
        @dealt = []
        
    end
    
    def shuffle!
        @cards = @cards.sort_by { rand }
    end
    
    def shuffle
        return @cards.sort_by { rand }
    end
    
    def deal
        return nil if @cards.empty?
        c = @cards.pop
        @dealt << c
        return c
    end

end
