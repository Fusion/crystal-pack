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

  enum Arch
    BIG_ENDIAN
    LITTLE_ENDIAN
  end

  alias ScopeNumber = Int64
  alias InArrayType = Int64 | Int32 | Int16 | Int8 | UInt64 | UInt32 | UInt16 | UInt8

end
