@[Link("sizes")]
lib LibSizes
  fun get_char_size(): UInt8
  fun get_short_size(): UInt8
  fun get_int_size(): UInt8
  fun get_long_size(): UInt8
  fun get_long_long_size(): UInt8
  fun get_ptr_size(): UInt8
end

module PackUnpackDefs

  Formats = "CcIiSsLlQqPp"
  Repeaters = "0123456789*"
  Endianness = "><"

  enum FormatActions
    NOOP
    DONE
    AS_CHAR
    AS_SHORT
    AS_INTEGER
    AS_LONG
    AS_LONG_LONG
    AS_PTR_SIZE
  end

  enum Sign
    UNSIGNED
    SIGNED
  end

  enum Arch
    BIG_ENDIAN
    LITTLE_ENDIAN
  end

  alias ScopeNumber = Int64
  alias ScopeUNumber = UInt64
  alias InArrayType = Int64 | Int32 | Int16 | Int8 | UInt64 | UInt32 | UInt16 | UInt8

  macro def get_sign(car : Char) : Sign
    car.ord > 0x5A ? Sign::SIGNED : Sign::UNSIGNED
  end

  macro def get_native_size(action) : UInt8
    case action
    when FormatActions::AS_CHAR
      LibSizes.get_char_size
    when FormatActions::AS_SHORT
      LibSizes.get_short_size
    when FormatActions::AS_INTEGER
      LibSizes.get_int_size
    when FormatActions::AS_LONG
      LibSizes.get_long_size
    when FormatActions::AS_LONG_LONG
      LibSizes.get_long_size
    when FormatActions::AS_PTR_SIZE
      LibSizes.get_ptr_size
    else
      raise "Attempting to get native size of unknown type"
    end
  end
end
