namespace :data do
  namespace :game do
    desc "Requeue all games waiting on a computer move"
    task :queue_all_for_computer => :environment do
      Game.where("current_player_id IS NULL AND finished_at IS NULL")
          .find_each do |game|
        game.queue_computer_move
      end
    end
  end
end