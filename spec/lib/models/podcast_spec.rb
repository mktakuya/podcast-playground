require "rspec"
require_relative "../../spec_helper"

require_relative "../../../lib/models/podcast"

RSpec.describe Podcast do
  describe "#episodes" do
    it "フィードから全エピソードを取得できる" do
      podcast = Podcast.new(
        title: "ゆるふわPodcast",
        feed_url: "https://yuru28.com/feed"
      )

      VCR.use_cassette("yuru28_feed") do
        episodes = podcast.episodes

        expect(episodes).not_to be_empty
        expect(episodes).to all(be_a(Episode))

        # 最初のエピソードの基本的な属性を確認
        first_episode = episodes.first
        expect(first_episode.title).not_to be_nil
        expect(first_episode.audio_url).not_to be_nil
        expect(first_episode.podcast).to eq(podcast)
      end
    end

    it "キャッシュされたエピソードを返す" do
      podcast = Podcast.new(
        title: "ゆるふわPodcast",
        feed_url: "https://yuru28.com/feed"
      )

      VCR.use_cassette("yuru28_feed") do
        episodes1 = podcast.episodes
        episodes2 = podcast.episodes

        expect(episodes1).to equal(episodes2)
      end
    end
  end
end
