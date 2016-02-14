require "./crystal-pack/String.cr"
require "./crystal-pack/Array.cr"

#
# The pack format defines how we willl handle the next character(s)
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
# Big endian (">")/little endian ("<"):
#
# "\x01\x00\x02\x00".unpack("S<*") #=> [1, 2]
# "\x01\x00\x02\x00".unpack("S>*") #=> [256, 512]
# In fact, in Crystal, this is:
# "\u{01}\u{00}\u{02}\u{00}".unpack("S<*") #=> [1, 2]
# "\u{01}\u{00}\u{02}\u{00}".unpack("S>*") #=> [256, 512]
#

module Crystal::Pack
end
