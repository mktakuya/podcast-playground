require_relative "base"
require_relative "episode"

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
    # TODO: feed_url からエピソード情報を取得して返す
    []
  end
end
