# Ruby converter server
require 'sinatra'
require 'json'
require 'base64'
require 'mini_magick'

configure{ enable :logging, :dump_errors, :raise_errors}

class ConverterServer

  def convert(data)
    # print the time when image is sent
    puts "Image received #{Time.now}"

    # decode received data from base64 and
    # convert to grayscape using ImageMagick and RMagick
    image = MiniMagick::Image.read(Base64.decode64(data))
    image = image.colorspace("Gray")

    # encode converted image (blob)
    contents = Base64.encode64(image.to_blob)
    puts "Image sent #{Time.now}"
    receive = contents

    return receive
  end

end

converter = ConverterServer.new

# Sinatra part
post '/convert' do
    # initialize return_message
    return_message = {}
    # parse JSON data from client
    jdata = JSON.parse(params[:data], :symbolize_names => true)
    # convert image and insert them to JSON
    return_message[:conversion] = converter.convert(jdata[:encoded])
    return_message.to_json
end
