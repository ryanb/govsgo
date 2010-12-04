# Go vs Go

This is the source code for [govsgo.com](http://govsgo.com), a site for playing the board game [Go](http://bit.ly/9xwZTy) online with other players or against the computer.

If you have problems or suggestions, please post them on the [Issue Tracker](http://github.com/ryanb/govsgo/issues).


## Setup

Ruby 1.9.2 is required. If you're using [RVM](http://rvm.beginrescueend.com/) it should automatically switch to 1.9.2 when entering the directory.

Run the following commands to set it up. Note the [Homebrew](http://github.com/mxcl/homebrew) command to install [GNU Go](http://www.gnu.org/software/gnugo/) and [Beanstalk](http://kr.github.com/beanstalkd/). You may want to use a different packaging system or install them from the source.

<pre>
bundle
cp config/database.example.yml config/database.yml
cp config/private.example.yml config/private.yml
rake db:create db:migrate
brew install gnu-go beanstalk
</pre>

You can start up the server with `rails s` and run the specs with `rake`.


### Background Process

In production, the computer moves are handled in a background process because GNU Go can take a while and we don't want to tie up the Rails process during this time.

If you want to test the background process, set `background_process: true` in your `config/private.yml` file. Next run `beanstalkd` and `script/worker`. to start up the processes. Alternatively you can use [god](http://god.rubyforge.org/) to start and monitor it. See the `config/god.rb` file.


## Credits

This site was originally created for [Rails Rumble 2010](http://r10.railsrumble.com/) by [Ryan Bates](http://railscasts.com/), [James Edward Gray II](http://blog.grayproductions.net/) and [Phil Bates](http://www.prbates.com/).
