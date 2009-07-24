$KCODE = 'u'
require 'jcode'
module ActiveRecord
  module CharacterEncoding
    CP_MAP = {
      "\x80" => "U+20AC",    # EURO SIGN
      "\x82" => "U+201A",    # SINGLE LOW-9 QUOTATION MARK
      "\x83" => "U+0192",    # LATIN SMALL LETTER F WITH HOOK
      "\x84" => "U+201E",    # DOUBLE LOW-9 QUOTATION MARK
      "\x85" => "U+2026",    # HORIZONTAL ELLIPSIS
      "\x86" => "U+2020",    # DAGGER
      "\x87" => "U+2021",    # DOUBLE DAGGER
      "\x88" => "U+02C6",    # MODIFIER LETTER CIRCUMFLEX ACCENT
      "\x89" => "U+2030",    # PER MILLE SIGN
      "\x8A" => "U+0160",    # LATIN CAPITAL LETTER S WITH CARON
      "\x8B" => "U+2039",    # SINGLE LEFT-POINTING ANGLE QUOTATION MARK
      "\x8C" => "U+0152",    # LATIN CAPITAL LIGATURE OE
      "\x8E" => "U+017D",    # LATIN CAPITAL LETTER Z WITH CARON
      "\x91" => "U+2018",    # LEFT SINGLE QUOTATION MARK
      "\x92" => "U+2019",    # RIGHT SINGLE QUOTATION MARK
      "\x93" => "U+201C",    # LEFT DOUBLE QUOTATION MARK
      "\x94" => "U+201D",    # RIGHT DOUBLE QUOTATION MARK
      "\x95" => "U+2022",    # BULLET
      "\x96" => "U+2013",    # EN DASH
      "\x97" => "U+2014",    # EM DASH
      "\x98" => "U+02DC",    # SMALL TILDE
      "\x99" => "U+2122",    # TRADE MARK SIGN
      "\x9A" => "U+0161",    # LATIN SMALL LETTER S WITH CARON
      "\x9B" => "U+203A",    # SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
      "\x9C" => "U+0153",    # LATIN SMALL LIGATURE OE
      "\x9E" => "U+017E",    # LATIN SMALL LETTER Z WITH CARON
      "\x9F" => "U+0178",    # LATIN CAPITAL LETTER Y WITH DIAERESIS
      "\xA0" => "U+00A0",    # NO-BREAK SPACE
      "\xA1" => "U+00A1",    # INVERTED EXCLAMATION MARK
      "\xA2" => "U+00A2",    # CENT SIGN
      "\xA3" => "U+00A3",    # POUND SIGN
      "\xA4" => "U+00A4",    # CURRENCY SIGN
      "\xA5" => "U+00A5",    # YEN SIGN
      "\xA6" => "U+00A6",    # BROKEN BAR
      "\xA7" => "U+00A7",    # SECTION SIGN
      "\xA8" => "U+00A8",    # DIAERESIS
      "\xA9" => "U+00A9",    # COPYRIGHT SIGN
      "\xAA" => "U+00AA",    # FEMININE ORDINAL INDICATOR
      "\xAB" => "U+00AB",    # LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
      "\xAC" => "U+00AC",    # NOT SIGN
      "\xAD" => "U+00AD",    # SOFT HYPHEN
      "\xAE" => "U+00AE",    # REGISTERED SIGN
      "\xAF" => "U+00AF",    # MACRON
      "\xB0" => "U+00B0",    # DEGREE SIGN
      "\xB1" => "U+00B1",    # PLUS-MINUS SIGN
      "\xB2" => "U+00B2",    # SUPERSCRIPT TWO
      "\xB3" => "U+00B3",    # SUPERSCRIPT THREE
      "\xB4" => "U+00B4",    # ACUTE ACCENT
      "\xB5" => "U+00B5",    # MICRO SIGN
      "\xB6" => "U+00B6",    # PILCROW SIGN
      "\xB7" => "U+00B7",    # MIDDLE DOT
      "\xB8" => "U+00B8",    # CEDILLA
      "\xB9" => "U+00B9",    # SUPERSCRIPT ONE
      "\xBA" => "U+00BA",    # MASCULINE ORDINAL INDICATOR
      "\xBB" => "U+00BB",    # RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
      "\xBC" => "U+00BC",    # VULGAR FRACTION ONE QUARTER
      "\xBD" => "U+00BD",    # VULGAR FRACTION ONE HALF
      "\xBE" => "U+00BE",    # VULGAR FRACTION THREE QUARTERS
      "\xBF" => "U+00BF"     # INVERTED QUESTION MARK
    }
    
    CP1252 = CP_MAP.keys.join
    UTF = CP_MAP.values.join
    
    def self.included(base)
      base.extend(ClassMethods)  
    end
    
    module ClassMethods
      
      def to_unicode(column)
        define_method "#{column}_to_unicode" do
          self.send(column).tr!(CP1252,u(UTF)) unless self.send(column).nil?
        end    
        
        before_save "#{column}_to_unicode".to_sym
      end
    end
  end
end

class UString < String
  # Show u-prefix as in Python
  def inspect; "u#{ super }" end

  # Count multibyte characters
  def length; self.scan(/./).length end

  # Reverse the string
  def reverse; self.scan(/./).reverse.join end
end

module Kernel
  def u( str )
    UString.new str.gsub(/U\+([0-9a-fA-F]{4,4})/u){["#$1".hex ].pack('U*')}
  end
end 

