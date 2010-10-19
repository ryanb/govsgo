require "fileutils"

module GameThumb
  IMAGE_DIR = File.join( File.dirname(__FILE__),
                         *%w[.. public images thumbnail] )
  THUMB_DIR = File.join( File.dirname(__FILE__),
                         *%w[.. public assets games thumbs] )

  module_function

  def generate(id, size, black_positions, white_positions)
    images = File.join(IMAGE_DIR, size.to_s)
    board  = ChunkyPNG::Image.from_file(File.join(images, "board.png"))
    black  = ChunkyPNG::Image.from_file(File.join(images, "black_stone.png"))
    white  = ChunkyPNG::Image.from_file(File.join(images, "white_stone.png"))
    offset = 76 / size.to_f

    black_positions.each do |x, y|
      board.compose(black, (x * offset).round, (y * offset).round)
    end
    white_positions.each do |x, y|
      board.compose(white, (x * offset).round, (y * offset).round)
    end

    FileUtils.mkdir_p(THUMB_DIR)
    thumb = File.join(THUMB_DIR, "#{id}.png")
    board.save("#{thumb}~", :fast_rgba)
    FileUtils.mv("#{thumb}~", thumb)
  end
end
