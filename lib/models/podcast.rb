require_relative "base"
require_relative "episode"
require "net/http"
require "rss"

class Podcast < Base
  attr_reader :title, :feed_url

  def initialize(title:, feed_url:)
    @title = title
    @feed_url = feed_url
  end

  def episodes
    @episodes ||= fetch_all_episodes
  end

  private

  def fetch_all_episodes
    uri = URI.parse(feed_url)
    response = fetch_with_redirect(uri)

    feed = RSS::Parser.parse(response.body)

    feed.items.map do |item|
      enclosure = item.enclosure

      Episode.new(
        title: item.title,
        audio_url: enclosure&.url,
        duration: parse_duration(item),
        podcast: self
      )
    end
  end

  def fetch_with_redirect(uri, limit = 10)
    raise "Too many HTTP redirects" if limit == 0

    response = Net::HTTP.get_response(uri)

    case response
    when Net::HTTPSuccess
      response
    when Net::HTTPRedirection
      redirect_uri = URI.parse(response["location"])
      redirect_uri = uri + redirect_uri if redirect_uri.relative?
      fetch_with_redirect(redirect_uri, limit - 1)
    else
      raise "Failed to fetch feed: #{response.code} #{response.message}"
    end
  end

  def parse_duration(item)
    # iTunes RSS の itunes:duration タグから再生時間を取得
    duration_element = item.instance_variable_get(:@itunes_duration)
    return nil unless duration_element

    duration_element.content
  end
end
