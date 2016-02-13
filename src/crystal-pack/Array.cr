class Array(T)
  include PackUnpackDefs

  struct NextFormat
    getter format_action, format_repeat, format_size, format_arch, format_str_remainder

    def initialize(@format_action, @format_repeat, @format_size, @format_arch, @format_str_remainder)
    end

    def read_to_full_size(next_value)
      res_arr  = [] of Char
      size_ctr = @format_size
      loop do
        divider = 1 << (8 * (size_ctr - 1))
        value = Int8.new (next_value / divider)
        next_value %= divider
        if @format_arch == Arch::BIG_ENDIAN
          res_arr << value.chr
        else
          res_arr.unshift value.chr
        end
        size_ctr -= 1
        break if size_ctr < 1
      end
      String.build { |str| res_arr.each { |c| str << c } }
    end

    def step?
      return true if @format_repeat == -1
      @format_repeat -= 1
      @format_repeat < 1 ? false : true
    end
  end

  private def next_format(format_str)

    return NextFormat.new FormatActions::DONE, 0, 0, Arch::BIG_ENDIAN, "" if format_str.size == 0

    action = FormatActions::NOOP
    repeat = 0
    size   = 1
    arch   = Arch::BIG_ENDIAN

    format_char = format_str.head
    if Formats.includes?(format_char)
      case format_char
      when 'C'
        action = FormatActions::AS_CHAR
      when 'S'
        action = FormatActions::AS_SHORT
        size = 2
      when 'I'
        action = FormatActions::AS_INTEGER
        size = 4
      when 'L'
        action = FormatActions::AS_LONG
        size = 4
      when 'Q'
        action = FormatActions::AS_LONG_LONG
        size = 8
      when 'J'
        action = FormatActions::AS_PTR_SIZE
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
      NextFormat.new action, repeat, size, arch, format_str.tail
    else
      next_format format_str.tail
    end
  end

  def pack(format_str)
    String.build do |packed|
      format_idx = 0
      nextf = next_format format_str

      each_index do |source_idx|
        cur_value = at(source_idx)

        format_str = nextf.format_str_remainder

        case nextf.format_action
        when FormatActions::AS_CHAR
          packed << cur_value.chr
          nextf = next_format format_str if !nextf.step?
        when FormatActions::AS_SHORT, FormatActions::AS_INTEGER, FormatActions::AS_LONG, FormatActions::AS_LONG_LONG
          packed << nextf.read_to_full_size cur_value
        else
        end
      end
    end
  end
end
