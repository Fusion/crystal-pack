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
end
