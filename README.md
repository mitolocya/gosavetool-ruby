# gosavetool

Parse, convert, shift and repair **SRT and WebVTT** subtitles, and count **words, characters and reading time** with **social media character limits**, **Title Case**, **slugs** and other case changes. A Ruby library and a command-line tool, with no dependencies.

Made by [GoSaveTool](https://www.gosavetool.com/), free online tools for creators.

## Install

```bash
gem install gosavetool
```

Or in a Gemfile: `gem "gosavetool"`. Requires Ruby 3.0 or newer.

## Command line

```bash
gosavetool convert movie.srt --to vtt      # writes movie.vtt
gosavetool shift movie.srt -1.5            # 1.5 s earlier, in place
gosavetool repair movie.srt                # sort, fix overlaps and bad times
gosavetool info movie.vtt                  # WebVTT, 412 cues, ends at 01:42:10.500

echo "Your caption" | gosavetool count
gosavetool limits post.txt                 # characters left for X, Instagram, TikTok, YouTube, SEO...
echo "the lord of the rings" | gosavetool case title
```

## Library

```ruby
require "gosavetool"

S = GoSaveTool::Subtitles
vtt = S.convert(File.read("movie.srt"), "vtt")
cues = S.parse(text)                          # [#<struct Cue start=1000, end=3500, settings="", text="Hello">, ...]
later = S.to_srt(S.shift(cues, 1500))
fixed, n = S.repair(cues)                     # sorted, no overlaps, no empty cues

T = GoSaveTool::Text
T.stats(post)                                 # { words:, chars:, chars_no_spaces:, lines:, sentences:, read_seconds: }
T.limits(post)["x-post"][:fits]               # also instagram-caption, tiktok-caption, youtube-title, seo-title, ...
T.title("the lord of the rings")              # "The Lord of the Rings"
T.slug("Ölçü Birimi & Çeviri!")               # "olcu-birimi-ceviri"
T.camel("best posting time")                  # "bestPostingTime"
```

Characters are Unicode code points, so an emoji counts as one. The rules are the same as the [`@gosavetool/subtitles`](https://www.npmjs.com/package/@gosavetool/subtitles) and [`@gosavetool/text`](https://www.npmjs.com/package/@gosavetool/text) JavaScript packages.

## Tests

```bash
rake test
```

## Online tools

[VTT Subtitle Generator](https://www.gosavetool.com/vtt-subtitle-generator), [Auto Captions Generator](https://www.gosavetool.com/auto-captions-generator), [Character Counter](https://www.gosavetool.com/character-counter)

## License

MIT
