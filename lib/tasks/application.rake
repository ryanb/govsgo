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

desc "Fix the old move syntax by inserting PASS and RESIGN where appropriate"
task :fix_moves => :environment do
  from_id = ENV["FROM"].to_i
  to_id = ENV["TO"] ? ENV["TO"].to_i : Game.last.id
  Game.where(:id => from_id..to_id).find_each do |game|
    moves = game.moves.to_s.dup
    moves.gsub!("--", "-PASS-")
    moves.sub!(/\-$/, "-PASS")
    moves.sub!(/^\-/, "PASS-")
    moves.sub!(/\-[a-z]{2}$/, "\\0-RESIGN") if game.finished?
    if moves != game.moves
      puts "GAME #{game.id}"
      puts "Old #{game.moves}"
      puts "New #{moves}"
      game.update_attribute(:moves, moves)
    end
  end
end

desc "Generate tokens for users who don't have them"
task :user_tokens => :environment do
  User.where(:token => nil).find_each do |user|
    user.generate_token
    user.save(:validate => false)
  end
end

desc "Set the started_at time for all existing games"
task :fix_started_at => :environment do
  Game.find_each do |game|
    game.update_attribute(:started_at, game.created_at)
  end
end

desc "Set the unsubscribe_token for existing users"
task :fix_unsubscribe_token => :environment do
  User.where(:unsubscribe_token => nil).find_each do |user|
    user.email_on_invitation = true
    user.generate_token(:unsubscribe_token)
    user.save!
  end
end

# Do this because GNU Go can become stuck on difficult moves
desc "Clear stuck games"
task :clear_stuck_games => :environment do
  Game.where("current_player_id IS NULL AND finished_at IS NULL and updated_at < ?", 1.day.ago).update_all(:finished_at, Time.zone.now)
end
