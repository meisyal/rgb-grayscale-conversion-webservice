require 'base64'
require 'json'
require 'net/http'

def file_name(file)
  result = file.split('.')[0]
end

def file_extensions(file)
  File.extname(file).delete('.')
end

def encode(filepath)
  f = File.open(filepath, "rb")
  contents = Base64.encode64(f.read)
  f.close

  return contents
end

worker = Array.new

worker << Net::HTTP.new('www.example.com', '4567')
#worker << Net::HTTP.new('10.151.34.18', '4567')

# define source and destination path
imagepath = 'your/image/path/here'
destinationpath = 'your/destination/image/path/here'

# add time start
start = Time.now

# create an item queue
item_queue = Queue.new
# read file on directory and push them to queue
Dir.foreach(imagepath) do |i|
  # skip reading the parent and current directories
  next if i == '.' or i == '..'
  item_queue.push(i)
end

worker.each do |work|
  until item_queue.empty?
    # pop with the non-blocking flag set, this raises
    # an exception if the queue is empty, in which case
    # item will be set to nil
    item = item_queue.pop(true) rescue nil
    if item
      # write log on terminal
      puts item
      # encode binary file to base64
      encoded_data = encode(imagepath + item)
      # initialize request using POST method
      convert_request = Net::HTTP::Post.new('/convert')
      convert_request.body = {encoded: encoded_data}.to_json
      # do request to server
      result = work.request(convert_request)
      # receive response from server
      receive = JSON.parse(result.body)
      # write log on terminal if image has been sent
      puts "#{item} has been sent successfully"
      # get file name without extensions
      filename = file_name(item)
      # get file extensions
      extensions = file_extensions(item)
      # decode received data from base64
      File.open(destinationpath + filename + "_grayscale." + extensions, 'wb') do |f|
        f.write(Base64.decode64(receive[:conversion]))
      end
    end
  end
end

# add time finish and calculate
finish = Time.now
difference = finish - start
# print total time
puts "Total time #{difference} seconds"
