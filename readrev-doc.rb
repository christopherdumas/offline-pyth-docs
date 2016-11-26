$tokens = {}
$types = {}

def print_help
  puts "LOCAL PYTH DOCS"
  puts "---------------\n\n"
  
  puts "Operators: "
  puts "ot - search operators by token"
  puts "oa - search operators by args"
  puts "ol - list operators"
  puts "od - search operators by description\n\n"
  
  puts "Types: "
  puts "tn - search types by name"
  puts "td - search types by description"
  puts "tl - list types\n\n"
  
  puts "System: "
  puts "hp - print this"
  puts "qt - exit the program\n\n"
end

print_help()

puts "TIPS"
puts "----"

File.open("/Users/christopherdumas/Downloads/offline-pyth-docs/rev-doc.txt") do |f|
  current_section = "Intro:"
  f.each_line do |line|
    line = line.chomp
    
    if line[-1] == ":" then
      current_section = line
    else
      if current_section == "Types:"
        kv = line.split(" = ")
        $types[kv[0]] = kv[1] if not kv[0].nil? and not kv[1].nil?
      elsif current_section == "Shorthands:"
        puts(line)
      elsif current_section == "Tokens:"
        s = line.split(/([A-Za-z]\s[A-Za-z.+*\-^%()]|[A-Za-z][A-Za-z0-9.+*\/\-^%\(\)]+\s)/)
        
        sp = s[0].split("")
        name = sp.take(2).join.strip
        
        attrs = [{name: name,
                  args: sp.drop(2).join.strip,
                  desc: s[1..s.length-1].join}]

        if not $tokens[name].nil? then
          $tokens[name].concat attrs
        else
          $tokens[name] = attrs
        end
      end
    end
  end
end

input = [""]
JUST = 50

while input[0] != "qt" do
  $stdout << "> "
  input = gets.chomp.split

  puts ''
  if input[0] == "ot" then
    tok = $tokens[input[1]]

    unless tok.nil? then
      tok.each do |t|
        len = JUST - "#{t[:args]}".length
        ndesc = " " + "-"*(len-2) + " " + t[:desc]
        puts "\e[31;6m#{t[:args]}\e[39;49m#{ndesc}"
      end
    else
      puts "Operator '#{input[1]}' not found."
    end
  elsif input[0] == "oa" then
    $tokens.each do |k, v|
      v.each do |t|
        if t[:args].downcase.include? input[1].downcase then
          len = JUST - "#{t[:name]} #{t[:args]}".length
          ndesc = " " + "-"*(len-2) + " " + t[:desc]
          puts "#{t[:name]} \e[31;6m#{t[:args]}\e[39;49m#{ndesc}"
        end
      end
    end
  elsif input[0] == "ol" then
    puts "Letters:"
    puts $tokens.keys.reject { |k| k.upcase == k.downcase or k[0] == "." }.join "  "
    puts ''
    
    puts "Symbols:"
    puts $tokens.keys.select { |k| k.upcase == k.downcase and k[0] != "." }.join "  "
    puts ''

    puts "Dots:"
    puts $tokens.keys.select { |k| k[0] == "." }.join "  "
  elsif input[0] == "od" then
    $tokens.each do |k, v|
      v.each do |t|
        if t[:desc].downcase.include? input[1].downcase then
          len = JUST - "#{t[:name]} #{t[:args]}".length
          ndesc = " " + "-"*(len-2) + " " + t[:desc].sub(input[1], "\e[31;6m"+input[1]+"\e[39;49m")
          puts "#{t[:name]} \e[31;6m#{t[:args]}\e[39;49m#{ndesc}"
        end
      end
    end
  elsif input[0] == "tl" then
    $types.each do |k, v|
      len = JUST - k.length
      nstr = "\e[31;6m" + k + "\e[39;49m " + "-"*(len-2) + " " + v
      puts nstr if k != ""
    end
  elsif input[0] == "tn" then
    $types.each do |k, v|
      puts "#{k}  -  #{v}" if k == input[1]
    end
  elsif input[0] == "td" then
    $types.each do |k, v|
      puts "#{k}  -  #{v}" if v.downcase.include?(input[1].downcase)
    end
  elsif input[0] == "qt" then
    puts "Bye!"
  elsif input[0] == "hp" then
    print_help()
  else
    puts "Unknown command, '#{input[0]}'"
  end

  puts ''
end
