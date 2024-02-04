threads = (1..5).map do |i|
  Thread.new do 
    Thread.current.kill if i == 1
    sleep(1)
    puts "Поток #{i} завершился"
    rand(1..100)
  end
end 

puts "Старт"
Thread.list.each {|t| puts t.inspect}
begin
  results = threads.map(&:value)
rescue => e
  puts e.inspect
end
puts "Все задачи были завершены"

puts results.inspect