require "rspec"
require_relative "../../spec_helper"

require_relative "../../../lib/models/episode"

RSpec.describe Episode do
  describe "#download_audio" do
    let(:episode) do
      Episode.new(
        title: "EP1 テストエピソード",
        audio_url: "https://example.com/audio/episode1.mp3",
        duration: "00:30:00"
      )
    end

    let(:output_dir) { "spec/tmp/downloads" }

    before do
      FileUtils.rm_rf(output_dir)
    end

    after do
      FileUtils.rm_rf(output_dir)
    end

    it "音声ファイルをダウンロードする" do
      stub_request(:get, "https://example.com/audio/episode1.mp3")
        .to_return(status: 200, body: "fake audio data", headers: {"Content-Type" => "audio/mpeg"})

      filepath = episode.download_audio(output_dir: output_dir)

      expect(filepath).to eq("#{output_dir}/EP1_.mp3")
      expect(File.exist?(filepath)).to be true
      expect(File.read(filepath)).to eq("fake audio data")
    end

    it "ダウンロード済みファイルは再ダウンロードしない" do
      stub_request(:get, "https://example.com/audio/episode1.mp3")
        .to_return(status: 200, body: "fake audio data", headers: {"Content-Type" => "audio/mpeg"})

      filepath1 = episode.download_audio(output_dir: output_dir)
      filepath2 = episode.download_audio(output_dir: output_dir)

      expect(filepath1).to eq(filepath2)
      expect(WebMock).to have_requested(:get, "https://example.com/audio/episode1.mp3").once
    end

    it "リダイレクトに対応する" do
      stub_request(:get, "https://example.com/audio/episode1.mp3")
        .to_return(status: 302, headers: {"Location" => "https://cdn.example.com/audio/episode1.mp3"})

      stub_request(:get, "https://cdn.example.com/audio/episode1.mp3")
        .to_return(status: 200, body: "fake audio data", headers: {"Content-Type" => "audio/mpeg"})

      filepath = episode.download_audio(output_dir: output_dir)

      expect(File.exist?(filepath)).to be true
      expect(File.read(filepath)).to eq("fake audio data")
    end

    it "audio_url がない場合はエラーを返す" do
      episode_without_url = Episode.new(
        title: "EP2 URLなし",
        audio_url: nil,
        duration: "00:20:00"
      )

      expect {
        episode_without_url.download_audio(output_dir: output_dir)
      }.to raise_error("No audio URL available")
    end

    it "ダウンロードに失敗した場合はエラーを返す" do
      stub_request(:get, "https://example.com/audio/episode1.mp3")
        .to_return(status: 404, body: "Not Found")

      expect {
        episode.download_audio(output_dir: output_dir)
      }.to raise_error(/Failed to download/)
    end
  end
end
