
class Card

    include Comparable

    attr_reader :face, :suit, :face_value
    
    # face_value is optional
    # only used for overriding low ace
    def initialize(face, suit, face_value = nil)
        @face = face.upcase
        @suit = suit.downcase
        @face_value = face_value.nil? ? Deck::FACE_VALUES[@face] : face_value
    end
    
    def to_s
        return "#{@face}#{@suit}"
    end
    
    def <=> card2
        @face_value <=> card2.face_value
    end

end