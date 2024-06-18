# frozen_string_literal: true

require 'open-uri'
require 'fastimage'

# Function to map MIME types to file extensions
def mime_type_to_extension(mime_type)
  puts "@@@@@#{mime_type}@@@@@"
  case mime_type
  when 'image/jpeg' then 'jpg'
  when 'image/png' then 'png'
  when 'image/gif' then 'gif'
  when 'image/bmp' then 'bmp'
  when 'image/tiff' then 'tiff'
  when 'image/webp' then 'webp'
  else 'unknown'
  end
end

# Function to identify file extension from image URL
def identify_file_extension(url)
  response = Faraday.get(url)
  unless response.success?
    puts "Failed to fetch the image. Status: #{response.status}"
    return 'unknown'
  end
  io = StringIO.new(response.body)
  FastImage.type(io)
end

# Example usage
url = 'https://img-cdn.hltv.org/teamlogo/IejtXpquZnE8KqYPB1LNKw.svg?ixlib=java-2.1.0&s=7fd33b8def053fbfd8fdbb58e3bdcd3c'
extension = identify_file_extension(url)
puts "File extension: #{extension}"
