class String

  Formats = "Cc"
  Repeaters = "0123456789*"

  enum FormatActions
    NOOP
    DONE
    AS_CHAR
  end

  record NextFormat, format_action, format_str_remainder

  private def next_format(format_str)

    return NextFormat.new FormatActions::DONE, "" if format_str.size == 0

    action = FormatActions::NOOP
    repeat = 0

    format_char = format_str.head
    if Formats.includes?(format_char)
      case format_char
      when 'C'
        action = FormatActions::AS_CHAR
      end
      repeat_char = format_str.tail.head
      if repeat_char != ""
        if Repeaters.includes?(repeat_char)
          repeat = repeat_char == '*' ? -1 : repeat_char.to_i
          format_str = format_str.tail
        end
      end
      NextFormat.new action, format_str.tail
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
    unpacked = [] of UInt8

    format_idx = 0

    nextf = next_format format_str

    bytesize.times do |source_idx|
      break if nextf.format_action == FormatActions::DONE
      
      format_str = nextf.format_str_remainder
      case nextf.format_action
      when FormatActions::AS_CHAR
        unpacked << byte_at(source_idx)
        format_idx += 1
        nextf = next_format format_str
      else
      end
    end

    unpacked
  end
end
