require_relative "base"
require "net/http"
require "uri"
require "fileutils"

class Episode < Base
  attr_reader :podcast
  attr_reader :title, :audio_url, :duration

  def initialize(title:, audio_url:, duration:, podcast: nil)
    @title = title
    @audio_url = audio_url
    @duration = duration
    @podcast = podcast
  end

  def download_audio(output_dir: "downloads")
    raise "No audio URL available" unless audio_url

    FileUtils.mkdir_p(output_dir)

    filename = generate_filename
    filepath = File.join(output_dir, filename)

    if File.exist?(filepath)
      puts "File already exists: #{filepath}"
      return filepath
    end

    uri = URI.parse(audio_url)
    download_file(uri, filepath)

    filepath
  end

  private

  def generate_filename
    # URL からファイル名と拡張子を取得
    uri = URI.parse(audio_url)
    original_filename = File.basename(uri.path)

    # クエリパラメータを除去
    original_filename = original_filename.split("?").first

    # 拡張子を取得（デフォルトは .mp3）
    extension = File.extname(original_filename)
    extension = ".mp3" if extension.empty?

    # タイトルから安全なファイル名を生成
    safe_title = title.gsub(/[^0-9A-Za-z.\-]/, "_").gsub(/_+/, "_")
    safe_title = safe_title[0..100] # 長さ制限

    "#{safe_title}#{extension}"
  end

  def download_file(uri, filepath, limit = 10)
    raise "Too many HTTP redirects" if limit == 0

    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
      request = Net::HTTP::Get.new(uri)

      http.request(request) do |response|
        case response
        when Net::HTTPSuccess
          File.open(filepath, "wb") do |file|
            response.read_body do |chunk|
              file.write(chunk)
            end
          end
          puts "Downloaded: #{filepath}"
        when Net::HTTPRedirection
          redirect_uri = URI.parse(response["location"])
          redirect_uri = uri + redirect_uri if redirect_uri.relative?
          download_file(redirect_uri, filepath, limit - 1)
        else
          raise "Failed to download: #{response.code} #{response.message}"
        end
      end
    end
  end
end
