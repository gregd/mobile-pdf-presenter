class RwStringExt
  # English alphabet plus Polish letters. This is needed because Ruby doesn't covert
  # Polish characters to lower or upper case.
  POLISH_L_2_U = {
    "a" => "A",
    "ą" => "Ą",
    "b" => "B",
    "c" => "C",
    "ć" => "Ć",
    "d" => "D",
    "e" => "E",
    "ę" => "Ę",
    "f" => "F",
    "g" => "G",
    "h" => "H",
    "i" => "I",
    "j" => "J",
    "k" => "K",
    "l" => "L",
    "ł" => "Ł",
    "m" => "M",
    "n" => "N",
    "ń" => "Ń",
    "o" => "O",
    "ó" => "Ó",
    "p" => "P",
    "q" => "Q",
    "r" => "R",
    "s" => "S",
    "ś" => "Ś",
    "t" => "T",
    "u" => "U",
    "v" => "V",
    "w" => "W",
    "x" => "X",
    "y" => "Y",
    "z" => "Z",
    "ź" => "Ź",
    "ż" => "Ż" }.freeze

  POLISH_U_2_L = POLISH_L_2_U.invert.freeze

  def self.upper_case(s)
    return s if s.nil? || s.size == 0
    res = ""
    s.each_char do |c|
      if POLISH_L_2_U.has_key?(c)
        res << POLISH_L_2_U[c]
      else
        res << c
      end
    end
    res
  end

  def self.lower_case(s)
    return s if s.nil? || s.size == 0
    res = ""
    s.each_char do |c|
      if POLISH_U_2_L.has_key?(c)
        res << POLISH_U_2_L[c]
      else
        res << c
      end
    end
    res
  end

  def self.capitalize(s)
    return s if s.nil? || s.size == 0
    upper_case(s[0]) + lower_case(s[1..-1])
  end

  def self.to_ascii(s)
    return nil if s.nil?
    return "" if s == ""
    foo = String.new(s)
    foo.gsub!(/[ĄÀ�?ÂÃ]/,'A')
    foo.gsub!(/[âäàãáäå�?ăąǎǟǡǻ�?ȃȧẵặ]/,'a')
    foo.gsub!(/[Ę]/,'E')
    foo.gsub!(/[ëêéèẽēĕėẻȅȇẹȩęḙḛ�?ếễểḕḗệ�?]/,'e')
    foo.gsub!(/[Ì�?ÎĨ]/,'I')
    foo.gsub!(/[�?iìíîĩīĭïỉ�?ịįȉȋḭɨḯ]/,'i')
    foo.gsub!(/[ÒÓÔÕÖ]/,'O')
    foo.gsub!(/[òóôõ�?�?ȯö�?őǒ�?�?ơǫ�?ɵøồốỗổȱȫȭ�?�?ṑṓ�?ớỡởợǭộǿ]/,'o')
    foo.gsub!(/[ÙÚÛŨÜ]/,'U')
    foo.gsub!(/[ùúûũūŭüủůűǔȕȗưụṳųṷṵṹṻǖǜǘǖǚừứữửự]/,'u')
    foo.gsub!(/[ỳýŷỹȳ�?ÿỷẙƴỵ]/,'y')
    foo.gsub!(/[œ]/,'oe')
    foo.gsub!(/[ÆǼǢæ]/,'ae')
    foo.gsub!(/[Ń]/,'N')
    foo.gsub!(/[ñǹń]/,'n')
    foo.gsub!(/[ÇĆ]/,'C')
    foo.gsub!(/[çć]/,'c')
    foo.gsub!(/[ß]/,'ss')
    foo.gsub!(/[œ]/,'oe')
    foo.gsub!(/[ĳ]/,'ij')
    foo.gsub!(/[Ł]/,'L')
    foo.gsub!(/[�?ł]/,'l')
    foo.gsub!(/[Ś]/,'S')
    foo.gsub!(/[ś]/,'s')
    foo.gsub!(/[ŹŻ]/,'Z')
    foo.gsub!(/[źż]/,'z')
    foo
  end

  # do not remove '_' because of ims brick names
  def self.simplify(s)
    return nil if s.nil?
    return "" if s == ""
    s = to_ascii(s).downcase
    s.gsub(/[\\\/"'-\.\[\]\(\),:]/, ' ')
  end

end
