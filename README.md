Podcast Playground
=====

Podcast 系のいろんなコードを書いて遊ぶ

## 概要

Podcast の RSS フィードを取得・解析するための Ruby CLI ツールです。

## 機能

- RSS フィードからエピソード一覧を取得
- エピソードのタイトル、音声 URL、再生時間を表示
- リダイレクト対応（最大10回まで自動追従）
- iTunes RSS 拡張に対応

## インストール

```bash
bundle install
```

## 使い方

### エピソード一覧の取得

```bash
./app.rb episodes --feed https://yuru28.com/feed
```

または

```bash
ruby app.rb episodes --feed https://yuru28.com/feed
```

### ヘルプ表示

```bash
./app.rb help
```

## 開発

### テスト

```bash
bundle exec rspec
```

### 構成

```
.
├── app.rb                   # CLI エントリーポイント
├── lib/
│   └── models/
│       ├── base.rb          # 基底クラス
│       ├── podcast.rb       # Podcast モデル
│       └── episode.rb       # Episode モデル
└── spec/
    ├── lib/models/
    │   └── podcast_spec.rb  # Podcast のテスト
    └── fixtures/
        └── vcr_cassettes/   # HTTP リクエストの記録
```

## 依存関係

- Ruby 標準ライブラリ (net/http, rss, optparse)
- nokogiri
- rspec (テスト用)
- vcr, webmock (テスト用)
