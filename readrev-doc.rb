$tokens = {}
$types = {}

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
puts "tl - list types"
puts "quit - exit the program\n\n"
puts "TIPS"
puts "----"


File.open("rev-doc.txt") do |f|
  current_section = "Intro:"
  f.each_line do |line|
    line = line.chomp
    
    if line[-1] == ":" then
      current_section = line
    else
      if current_section == "Types:"
        kv = line.split(" = ")
        $types[kv[0]] = kv[1]
      elsif current_section == "Shorthands:"
        puts(line)
      elsif current_section == "Tokens:"
        s = line.split(/([A-Za-z]\s?[A-Za-z0-9.+*\-^%()]+\s)/)
        
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

while input[0] != "quit" do
  $stdout << "> "
  input = gets.chomp.split

  if input[0] == "ot" then
    tok = $tokens[input[1]]

    unless tok.nil? then
      puts ''
      tok.each do |t|
        puts "\e[31;6m#{t[:args]}\e[39;49m\t#{t[:desc]}"
      end
      puts ''
    else
      puts "Operator '#{input[1]}' not found."
    end
  elsif input[0] == "oa" then
    $tokens.each do |k, v|
      v.each do |t|
        if t[:args].include? input[1] then
          puts "\e[31;6m#{t[:args]}\e[39;49m\t#{t[:desc]}"
        end
      end
    end
  elsif input[0] == "ol" then
    puts ''
    
    puts "Letters:"
    puts $tokens.keys.reject { |k| k.upcase == k.downcase or k[0] == "." }.join "  "
    puts ''
    
    puts "Symbols:"
    puts $tokens.keys.select { |k| k.upcase == k.downcase and k[0] != "." }.join "  "
    puts ''

    puts "Dots:"
    puts $tokens.keys.select { |k| k[0] == "." }.join "  "
    
    puts ''
  elsif input[0] == "od" then
    $tokens.each do |k, v|
      v.each do |t|
        if t[:desc].include? input[1] then
          puts "\e[31;6m#{t[:args]}\e[39;49m\t#{t[:desc]}"
        end
      end
    end
  elsif input[0] == "tl" then
    $types.each do |k, v|
      puts "#{k}  -  #{v}" if k != ""
    end
  elsif input[0] == "tn" then
    $types.each do |k, v|
      puts "#{k}  -  #{v}" if k == input[1]
    end
  elsif input[0] == "td" then
    $types.each do |k, v|
      puts "#{k}  -  #{v}" if v.include?(input[1])
    end
  else
    puts "Unknown command, '#{input[0]}'"
  end
end
