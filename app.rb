require_relative "lib/models/podcast"
require "optparse"

class App
  def self.run(args)
    command = args.shift

    case command
    when "episodes"
      run_episodes(args)
    when "help", nil
      show_help
    else
      puts "Unknown command: #{command}"
      show_help
      exit 1
    end
  end

  def self.run_episodes(args)
    options = {}
    OptionParser.new do |opts|
      opts.banner = "Usage: app.rb episodes [options]"
      opts.on("--feed URL", "RSS feed URL") do |url|
        options[:feed] = url
      end
    end.parse!(args)

    unless options[:feed]
      puts "Error: --feed option is required"
      exit 1
    end

    podcast = Podcast.new(
      title: "Podcast",
      feed_url: options[:feed]
    )

    episodes = podcast.episodes

    if episodes.empty?
      puts "No episodes found"
      return
    end

    puts "Found #{episodes.size} episodes:\n\n"

    episodes.each do |episode|
      puts "Title: #{episode.title}"
      puts "URL: #{episode.audio_url}" if episode.audio_url
      puts "Duration: #{episode.duration}" if episode.duration
      puts "-" * 80
    end
  end

  def self.show_help
    puts <<~HELP
      Usage: ruby app.rb <command> [options]

      Commands:
        episodes    Fetch and display episodes from a podcast feed
        help        Show this help message

      Examples:
        ruby app.rb episodes --feed https://yuru28.com/feed
    HELP
  end
end

if __FILE__ == $0
  App.run(ARGV.dup)
end
