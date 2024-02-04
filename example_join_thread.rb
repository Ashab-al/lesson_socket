threads = (1..5).map do |i|
  Thread.new { sleep(1); puts "Поток #{i} завершился"}
end 

puts "Старт"
Thread.list.each {|t| puts t.inspect}

threads.each(&:join)

puts "Все задачи были завершены"