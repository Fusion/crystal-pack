  # Surprisingly, Crystal mangles escaped hex codes weirdly: "\x" becomes "x"
  # So, here is #{h_("\x9a")}
  def h_(src_str)
    acc = 0_u8
    src_str.bytesize.times do |idx|
      car = src_str.byte_at(idx)
      next if car == 0x78 # x
      acc += (
          car >= 0x30 && car <= 0x39 ?
          car - 0x30 :
          car >= 0x41 && car <= 0x5A ?
          car - 0x37 :
          car >= 0x61 && car <= 0x7A ?
          car - 0x57 :
          0) << (src_str.bytesize - (1 + idx)) * 4
    end
    acc.chr
  end
