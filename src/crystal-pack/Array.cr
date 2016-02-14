require "./PackUnpackDefs.cr"

class Array(T)
  include PackUnpackDefs

  struct NextFormat
    getter format_action, format_repeat, format_size, format_arch, format_sign, format_str_remainder

    def initialize(@format_action, @format_repeat, @format_size, @format_arch, @format_sign, @format_str_remainder)
    end

    def self.new
      new(FormatActions::DONE, 0, 0, Arch::LITTLE_ENDIAN, Sign::UNSIGNED, "")
    end

    def read_to_full_size(next_value)
      res_arr  = [] of Char
      size_ctr = @format_size
      loop do
        divider = 1 << (8 * (size_ctr - 1))
        value = Int8.new (next_value / divider)
        next_value %= divider
        if @format_arch == Arch::LITTLE_ENDIAN
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

    return NextFormat.new if format_str.size == 0

    action = FormatActions::NOOP
    repeat = 0
    size   = 1
    sign   = Sign::UNSIGNED
    arch   = Arch::LITTLE_ENDIAN

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
        size = sizeof(Pointer)
      when 'n'
        action = FormatActions::AS_SHORT; sign = Sign::UNSIGNED
        size = 2; arch = Arch::BIG_ENDIAN
      when 'N'
        action = FormatActions::AS_INTEGER; sign = Sign::SIGNED
        size = 4; arch = Arch::BIG_ENDIAN
      when 'v'
        action = FormatActions::AS_SHORT; sign = Sign::UNSIGNED
        size = 2; arch = Arch::LITTLE_ENDIAN
      when 'V'
        action = FormatActions::AS_INTEGER; sign = Sign::SIGNED
        size = 4; arch = Arch::LITTLE_ENDIAN
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
