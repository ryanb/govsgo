Factory.define :user do |f|
  f.sequence(:username) { |n| "foo#{n}" }
  f.sequence(:email) { |n| "foo#{n}@example.com" }
  f.password "foobar"
  f.password_confirmation { |u| u.password }
end

Factory.define :game do |f|
  f.association(:black_player, :factory => :user)
  f.association(:white_player, :factory => :user)
  f.current_player { |g| g.black_player }
  f.board_size 19
  f.valid_positions ("a".."s").map { |l| ("a".."s").map { |r| l + r } }
                    .flatten.join
end
