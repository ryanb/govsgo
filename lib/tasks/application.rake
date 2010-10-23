desc "Requeue all games waiting on a computer move"
task :queue_computer_moves => :environment do
  Game.where("current_player_id IS NULL AND finished_at IS NULL").find_each do |game|
    game.queue_computer_move
  end
end

desc "Regenerate thumbnails for games between FROM and TO id"
task :generate_thumbnails => :environment do
  from_id = ENV["FROM"].to_i
  to_id = ENV["TO"] ? ENV["TO"].to_i : Game.last.id
  Game.where(:id => from_id..to_id).find_each do |game|
    puts "Generating thumbnail for game #{game.id}"
    game.update_thumbnail
  end
end
