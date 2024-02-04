require 'socket'

# обработать ошибки
# присоединение по паролю в комнате

class ChatServer
  def initialize(port)
    @server = TCPServer.new(port)
    @clients = {}
    @passwords = {}
    @room = {"example_pass" => {"username" => "client"}}
  end

  def run 
    loop do 
      Thread.start(@server.accept) do |client|
        handle_client(client)
      end
    end
  end

  private 

  def handle_client(client)
    client.puts "Добро пожаловать на сервер! Введите ник"
    username = client.gets.chomp

    client.puts "Введите пароль комнаты"
    password = client.gets.chomp

    @clients[username] = client 
    @passwords[username] = password 

    broadcast("#{username} присоединился к чату")

    client.puts "Вы вошли в чат"

    loop do
      message = client.gets.chomp
      
      if message.downcase.start_with?('/exit')
        @clients.delete(username)
        @passwords.delete(username)

        broadcast("#{username} вышел из чата")
        Thread.current.kill
        break
      elsif message.downcase.start_with?('/private')
        message = message.split(' ')
        message.shift

        send_private_message(
          message.join(' '),
          username
        )
      elsif message.downcase.start_with?('/room')
        message = message.split(' ')
        message.shift
        send_room_message(
          message.join(' '),
          username, 
          client
        )
      else
        broadcast("#{username}: #{message}")
      end
    end
  end

  def broadcast(message)
    @clients.each do |username, client|
      client.puts message
    end
  end

  def send_private_message(message, sender)
    recipient, *content = message.split(' ')
    content = content.join(' ')

    if @clients.key?(recipient)
      @clients[recipient].puts "Приватное сообщение от #{sender}: #{content}"
    else
      @clients[sender].puts "Пользователь #{recipient} не существует"
    end
  end

  def send_room_message(message, sender, client)
    recipient, *content = message.split(' ')
    content = content.join(' ')

    if @room.key?(recipient)
      @room[recipient][sender] = client unless @room[recipient].include?(sender)
      @room[recipient].each do |username, user|
        user.puts "Сообщение в комнату #{recipient} от #{sender}: #{content}" if username != sender
      end
    else
      @room[recipient] = {sender => client}
      client.puts "Такой комнаты ранее не существовало\n #{recipient} и теперь создали новую и в ней только вы!"
    end
  end
end

server = ChatServer.new(2000)
server.run