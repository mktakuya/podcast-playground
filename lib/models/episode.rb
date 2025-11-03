require_relative "base"

class Episode < Base
  attr_reader :podcast
  attr_reader :title, :audio_url, :duration

  def initialize(title:, audio_url:, duration:, podcast: nil)
    @title = title
    @audio_url = audio_url
    @duration = duration
    @podcast = podcast
  end
end
