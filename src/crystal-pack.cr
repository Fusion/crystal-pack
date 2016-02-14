require "./crystal-pack/*"

#
# The pack format defines how we willl handle the next character(s)
#
# "Ruby".unpack("C C C C")
# => [82, 117, 98, 121]
#
# [82, 117, 98, 121].pack("C C C C")
# => "Ruby"
#
# "Ruby".unpack("C4")
# => [82, 117, 98, 121]
#
# "Ruby".unpack("C2")
# => [82, 117]
#
#"Ruby".unpack("C*")
# => [82, 117, 98, 121]
# Yes, "*" means "repeat as many times as possible"
#
# Character: not directive|number|* => ignored (comment)
#
# Formats:
#
# C	char
# I! or I_	int
# S! or S_	short
# L! or L_	long
# Q! or Q_	long long
# J! or J_	pointer width
#
# "!" means "depend on OS sizes"
#
# Upper case ("C") means "unsigned" while lower case ("c") means "signed"
#
# Characters not in 0-255 will, when packing, be expanded to \xXX
#
# Big endian (">")/little endian ("<"):
#
# "\x01\x00\x02\x00".unpack("S<*") #=> [1, 2]
# "\x01\x00\x02\x00".unpack("S>*") #=> [256, 512]
# In fact, in Crystal, this is:
# "\u{01}\u{00}\u{02}\u{00}".unpack("S<*") #=> [1, 2]
# "\u{01}\u{00}\u{02}\u{00}".unpack("S>*") #=> [256, 512]
#

module Crystal::Pack
  puts [73, 100, 105, 111, 115, 121, 110, 99, 114, 195, 164, 116, 105, 99].pack("C*")
  puts [73, 100, 105, 111, 115, 121, 110, 99, 114, -61, -92, 116, 105, 99].pack("C*")
  puts "Idiosyncrätic".unpack("C*")
  puts "Idiosyncrätic".unpack("c*")
end
