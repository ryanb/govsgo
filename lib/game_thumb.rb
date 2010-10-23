require "fileutils"

module GameThumb
  IMAGE_DIR = File.join(File.dirname(__FILE__), *%w[.. public images thumbnail])
  THUMB_DIR = File.join(File.dirname(__FILE__), *%w[.. public assets games thumbs])

  module_function

  def generate(id, size, black_positions, white_positions)
    images = File.join(IMAGE_DIR, size.to_s)
    board = ChunkyPNG::Image.from_file(File.join(images, "board.png"))
    black = ChunkyPNG::Image.from_file(File.join(images, "black_stone.png"))
    white = ChunkyPNG::Image.from_file(File.join(images, "white_stone.png"))
    offset = 76 / size.to_f

    add_stones(board, black, black_positions, offset)
    add_stones(board, white, white_positions, offset)

    FileUtils.mkdir_p(THUMB_DIR)
    thumb = File.join(THUMB_DIR, "#{id}.png")
    board.save("#{thumb}~", :fast_rgba)
    FileUtils.mv("#{thumb}~", thumb)
  end

  def add_stones(board, stone, positions, offset)
    positions.to_s.scan(/[a-s]{2}/).each do |position|
      x, y = Go::GTP::Point.new(position).to_indices
      board.compose(stone, 2 + (x * offset).round, 2 + (y * offset).round)
    end
  end
end
