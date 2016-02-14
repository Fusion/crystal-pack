module BER
  # I'l admit it: I am stumped. Here is why:
  # The BER spec can be found at
  # http://www.itu.int/ITU-T/studygroups/com17/languages/X.690-0207.pdf
  # It makes clear that 00010000 would mean: native, primitive, Seq of Seq.
  # This is not possible because a Seq of Seq. would not be a primitive type.
  # Yet, I have been using this page as a reference for pack():
  # http://idiosyncratic-ruby.com/4-what-the-pack.html
  # Notice how is encodes a series using BER to 1102452
  # which is: 00010000,11010010,01110100
  # Well, crap.
  #
  # Anyway, here is a shorthand version of what I gathered:
  #
  # structure: type, length, value+, end-of-contents*
  # type: Class(8,7) P/C(6), Tag#(5-1)
  #   class: [0,0 - universal ASN.1 ]| [0,1 - app specific] | [1,0 - ctx specific] |
  #          [1,1 - private spec]
  #   P/C: [0 - primitive] | [1 - constructed]
  #   P/C+tag: [P0 - E-O-C] | [P1 - Bool] | [P2 - Int] | [P/C3 - BitStr] |
  #            [P/C4 - OctStr] | [P5 - NULL] | [P6 -ObjId] | [P/C7 - ObjDesc] |
  #            [C8 - External] | [P9 - Float] | [PA - Enum] | [PB - EmbedPDV] |
  #            [P/CC - UTF8Str] | [PD - Rel OID] | [E - Rsvd] | [F - Rsvd] |
  #            [C10 - Seq of Seq] | [P/C12 - NumStr] | [P/C13 - PrtStr] |
  #            [P/C14 - T61Str] | [P/C15 - VideotexStr] | [P/C16 - IA5Str] |
  #            [P/C17 - UTCTime] | [P/C18 - GenTime] | [P/C19 - GfxStr] |
  #            [P/C1A - VisStr] | [P/C1B - GenStr] | [P/C1C - UnivStr] |
  #            [P/C1D - CharStr] | [P/C1E - BMPStr] | [1F - long form]
  #     1F means tag > 5 bits; need a new octet:
  #       Bit8: GoOn(1) | End(0)
  #       Bit7-1: UInt
  # length:
  #   Definite form:
  #     Bit8: Short form(0) | Long form(1)
  #     Bit7-1: Length, when short form
  #     Bit7-1: Number of subsequent length octets; followed by said octects
  #   Indefinite form:
  #     Bit8: 1
  #     Bit7-1: 0000000
  #     2 E-O-C will end data stream
  #
end
