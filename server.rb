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
  begin
    request.body.rewind
    data = request.body.read
    jdata = JSON.parse(data)

    return_message = {}
    return_message[:conversion] = converter.convert(jdata['encoded'])
  rescue => e
    p e
  else
    content_type :json
    return_message.to_json
  end
end
