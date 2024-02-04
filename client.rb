require 'socket'

class ChatClient 
  def initialize(server, port)
    @server = server
    @port = port
  end

  def run 
    @socket = TCPSocket.open(@server, @port)

    puts @socket.gets

    Thread.new { listen } 

    Thread.new { write }

    sleep
  end

  private 

  def listen 
    loop do 
      puts @socket.gets.chomp
    end
  end

  def write 
    loop do 
      message = gets.chomp 
      @socket.puts message
    end
  end
end

client = ChatClient.new('localhost', 2000)
client.run
