class RwAddrNormalizer

  def self.clean_company_name(name)
    COMPANY_NAME_ABBR.each_pair do |k, v|
      name = name.gsub(k, v)
    end
    name.gsub(/\s+/, ' ').strip
  end

  def self.prepare_to_split(s)
    s.gsub(/\.+/, '.').gsub('.', '. ').strip.gsub(/\s+/, ' ').gsub(/-+/, '-')
  end

  def self.capitalize_city(city)
    return nil if city.blank?
    prepare_to_split(city).split(/(-|\/|\s)/).map do |w|
      if w == ' ' || w == '-'
        w
      elsif w =~ /^(k|n|nad)$/i
        $1.downcase
      else
        RwStringExt.capitalize(w)
      end
    end.join
  end

  def self.capitalize_street(street)
    return nil if street.blank?
    street = street.gsub(/\.+/, '.').gsub(/\s+/, ' ')
    STREET_REPLACE.each_pair {|k, v| street = street.gsub(k, v) }

    parts = prepare_to_split(street).split(/(-|\/|\s)/)
    last_index = parts.size - 1
    parts.each_with_index.map do |w, index|
      if w == ' ' || w == '-' || w == '/'
        w
      elsif w == 'i' || w == 'I'
        index == 0 || index == last_index ? 'I' : 'i'
      elsif STREET_ABBR.has_key?(RwStringExt.lower_case(w))
        STREET_ABBR[RwStringExt.lower_case(w)]
      else
        RwStringExt.capitalize(w)
      end
    end.join
  end

  def self.split_street_nr(street)
    street = street.gsub(/\/\s*paw\./i, ' paw.').gsub("–", "-")

    if street =~ /\s*(dywizjonu\s+(303|305)|o(s|ś)\.\s+2000)\s+(.+)/i
      st = $1
      num = $4

    elsif street =~ /(\d+\/\d+\w?\s+m\s+\d+\w?)/i
      # numer/numer litera m i numer
      num = $1
      st = street[0, street.size - num.size]

    elsif street =~ /(\d+\w?\s+m\s+\d+\w?)/i
      # numer litera m i numer
      num = $1
      st = street[0, street.size - num.size]

    elsif street =~ /(\d+\w{0,2}(\/\d+\w{0,2})?\s(lok\.|lok\s|blok\s|paw\.|p\.|gab\.|pok\.).*)$/i
      # numer lok. i wszystko po
      num = $1
      st = street[0, street.size - num.size]

    elsif street =~ /\s((lok\.|lok\s|blok\s|paw\.|p\.)\s*.+)$/i
      # paw. i numer po
      num = $1
      st = street[0, street.size - num.size]

    elsif street =~ /\s(\(.*\))$/
      # (cokowkiek)
      num = $1
      st = street[0, street.size - num.size]

    elsif street !~ /\d+/
      # bez numerów więc nie ma nr domu
      num = ""
      st = street

    elsif street =~ /(\d+\w{0,2}\s*\/.*)$/
      # numer / i wszystko po
      if $1.size < 11
        num = $1
        st = street[0, street.size - num.size]
      else
        # to może być podwójna ulica
        num = nil
        st = street
      end

    elsif street =~ /(\d{1,4}\s*(\/|-)\s*\d{1,4}\s+\w{1,4})$/
      # numer sep numer i literki
      num = $1
      st = street[0, street.size - num.size]

    elsif street =~ /(\d{1,4}\w{0,3}\s+\w{0,3})$/
      # numer i literki po spacjach
      num = $1
      st = street[0, street.size - num.size]

    elsif street =~ /(\d{1,4}\w{0,3}(\s*(\/|-)\s*(\d{1,4}\w{0,2}|\w{0,2}))?)$/
      # ogólny regexp
      num = $1
      st = street[0, street.size - num.size]

    else
      num = nil
      st = street
    end

    puts "Normalizer.split_street_nr cannot split '#{street}'" if num.nil?
    return st.strip, num
  end

  def self.split_nr(house_number)
    return house_number, "" if house_number.nil? || house_number == ""

    house_number = house_number.gsub(',', ' ').gsub(/-+/, '-').gsub(/\.+/, '.').
      gsub(/\.0\b/, '').gsub(/\s+/, ' ').strip

    if house_number =~ /^(\d+)\s+([a-z]+)$/i
      num = ($1 + $2).upcase
      loc = ""
    elsif house_number =~ /^(.+)\s+(([a-z]{1,3}\.|lok\s|blok\s).+)$/i
      num = $1.upcase
      loc = $2
    elsif house_number =~ /^([^-\/m]+)(-|\/|m)(.+)$/i
      num = $1.strip.upcase
      loc = $3.strip
    elsif house_number =~ /^([^-\/]+)(-|\/)(.+)$/
      num = $1.upcase
      loc = $3.strip
    elsif house_number =~ /^([^\(\s]+)\s*(\(.+)$/
      num = $1.upcase
      loc = $2
    elsif house_number =~ /^(\w+)\s+i\s+(\w+)$/
      num = "#{$1.upcase} i #{$2.upcase}"
      loc = ""
    else
      num = house_number.upcase
      loc = ""
    end

    return num, loc
  end

  STREET_REPLACE = {
    /-lecia/i     => " Lecia",
    /n\.m\.p\./i  => "NMP ",
    /\s*-\s*/     => "-",
    /gen\./i      => " ",
    /marsz\./i    => " ",
    /kard\./i     => " ",
    /płk\./i      => " ",
    /-go/i        => " ",
    /ul\./i       => " ",
    /J\./i        => " ",
    /F\./i        => " ",
  }.freeze

  STREET_ABBR = {
    "ii"      => "II",
    "iii"     => "III",
    "iv"      => "IV",
    "v"       => "V",
    "vi"      => "VI",
    "vii"     => "VII",
    "viii"    => "VIII",
    "ix"      => "IX",
    "x"       => "X",
    "xi"      => "XI",
    "xii"     => "XII",

    "xx"      => "20",
    "xxv"     => "25",
    "xxx"     => "30",
    "xxxv"    => "35",

    "aleja"   => "Al.",
    "al."     => "Al.",
    "pl."     => "Pl.",
    "plac"    => "Pl.",
    "os."     => "Oś.",
    "oś."     => "Oś.",
    "osiedle" => "Oś.",
    "ks."     => "Ks.",
    "św."     => "Św.",
    "wś"      => "WŚ",

    "ze"      => "ze",
    "z"       => "z",

    "prl"     => "PRL",
    "ken"     => "KEN",
    "win"     => "WiN",
    "pck"     => "PCK",
    "onz"     => "ONZ",
    "wp"      => "WP",
    "nmp"     => "NMP",
    "plm"     => "PLM",
    "onp"     => "ONP",
    "pow"     => "POW",
    "zor"     => "ZOR",
    "wop"     => "WOP",
  }.freeze

  COMPANY_NAME_ABBR = {
    /s\.c\./i                     => "",
    /sp\.\s*z\.?\s*o\.\s*o\.?/i   => "",
    /sp\.\s*j\./i                 => "",
    /s\.\s*j\./i                  => "",
    /s\.\s*a\./i                  => "",
    /i wspólnicy\.?/i             => "",
    /\bphu\b/i                    => "",

    # Sp. c.
    # S.C
    # Spółka Jawna
    # sp j.
    # mgr farm.
    # mgr farm
  }.freeze

end



