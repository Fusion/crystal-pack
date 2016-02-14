class String
  include PackUnpackDefs

  struct NextFormat
    getter format_action, format_repeat, format_size, format_arch, format_sign, format_str_remainder

    def initialize(@format_action, @format_repeat, @format_size, @format_arch, @format_sign, @format_str_remainder)
      @size_ctr = @format_size
      @acc      = ScopeNumber.new 0
    end

    def read_to_full_size?(next_byte)
      if @format_arch == Arch::BIG_ENDIAN
        @acc +=(ScopeNumber.new(next_byte) << 8 * (@size_ctr - 1))
      else
        @acc +=(ScopeNumber.new(next_byte) << 8 * (@format_size - @size_ctr))
      end
      @size_ctr -= 1
      if @size_ctr < 1
        @size_ctr = @format_size
        true
      else
        false
      end
    end

    def step?
      return true if @format_repeat == -1
      @format_repeat -= 1
      @format_repeat < 1 ? false : true
    end

    def get_and_reset_acc!
      ret = @acc
      @acc = ScopeNumber.new 0
      ret
    end

    def expand_type(value) : InArrayType
      case format_size
      when 1
        format_sign == Sign::SIGNED ? Int8.new value : UInt8.new value
      when 2
        format_sign == Sign::SIGNED ? Int16.new value : UInt16.new value
      when 4
        format_sign == Sign::SIGNED ? Int32.new value : UInt32.new value
      when 8
        format_sign == Sign::SIGNED ? Int64.new value : UInt64.new value
      else
        format_sign == Sign::SIGNED ? ScopeNumber.new value : ScopeUNumber.new value
      end
    end
  end

  enum SpecialChars
    UNDEF
    ESCAPED
    HEX
  end

  private def next_format(format_str)

    return NextFormat.new FormatActions::DONE, 0, 0, Arch::BIG_ENDIAN, Sign::UNSIGNED, "" if format_str.size == 0

    action = FormatActions::NOOP
    repeat = 0
    size   = 1
    sign   = Sign::UNSIGNED
    arch   = Arch::BIG_ENDIAN

    format_char = format_str.head as Char
    if Formats.includes?(format_char)
      case format_char
      when 'C', 'c'
        action = FormatActions::AS_CHAR; sign = get_sign format_char
      when 'S', 's'
        action = FormatActions::AS_SHORT; sign = get_sign format_char
        size = 2
      when 'I', 'i'
        action = FormatActions::AS_INTEGER; sign = get_sign format_char
        size = 4
      when 'L', 'l'
        action = FormatActions::AS_LONG; sign = get_sign format_char
        size = 4
      when 'Q', 'q'
        action = FormatActions::AS_LONG_LONG; sign = get_sign format_char
        size = 8
      when 'J', 'j'
        action = FormatActions::AS_PTR_SIZE; sign = get_sign format_char
      end
      repeat_char = format_str.tail.head
      if repeat_char != ""
        if Endianness.includes?(repeat_char)
          case repeat_char
          when '>'
            arch = Arch::BIG_ENDIAN
          when '<'
            arch = Arch::LITTLE_ENDIAN
          end
          format_str = format_str.tail
          repeat_char = format_str.tail.head
        end
        if Repeaters.includes?(repeat_char)
          repeat = repeat_char == '*' ? -1 : repeat_char.to_i
          format_str = format_str.tail
        end
      end
      NextFormat.new action, repeat, size, arch, sign, format_str.tail
    else
      next_format format_str.tail
    end
  end

  def head
    size == 0 ? "" : byte_at(0).chr
  end

  def tail
    self[1..-1]
  end

  def unpack(format_str)
    unpacked = [] of InArrayType

    nextf = next_format format_str

    bytesize.times do |source_idx|
      break if nextf.format_action == FormatActions::DONE

      cur_byte = byte_at source_idx

      format_str = nextf.format_str_remainder
      case nextf.format_action
      when FormatActions::AS_CHAR
        unpacked << nextf.expand_type cur_byte
        nextf = next_format format_str if !nextf.step?
      when FormatActions::AS_SHORT, FormatActions::AS_INTEGER, FormatActions::AS_LONG, FormatActions::AS_LONG_LONG
        if nextf.read_to_full_size? cur_byte
          unpacked << nextf.get_and_reset_acc!
          nextf = next_format format_str if !nextf.step?
        end
      else
      end
    end

    unpacked
  end
end
