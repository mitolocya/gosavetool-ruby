# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/gosavetool"

# The checks of @gosavetool/subtitles and @gosavetool/text
class TestGoSaveTool < Minitest::Test
  S = GoSaveTool::Subtitles
  T = GoSaveTool::Text
  SRT = "1\r\n00:00:01,000 --> 00:00:03,500\r\nHello\r\nworld\r\n\r\n2\r\n00:00:03,000 --> 00:00:02,000\r\nSecond\r\n\r\n" \
        "3\r\n00:00:00,500 --> 00:00:00,900\r\nFirst\r\n"

  def test_parse_and_write
    cues = S.parse(SRT)
    assert_equal 3, cues.length
    assert_equal "Hello\nworld", cues[0].text
    assert S.to_vtt(cues).start_with?("WEBVTT\n\n00:00:01.000 --> 00:00:03.500\nHello")
    assert_equal "1\n00:01:02,500 --> 00:01:04,000\nA\n", S.convert("WEBVTT\n\nNOTE hi\n\n01:02.5 --> 01:04.000 align:start\nA\n", "srt")
    assert_equal "WEBVTT\n\n00:01:02.500 --> 00:01:04.000 align:start\nA\n", S.convert("WEBVTT\n\n01:02.5 --> 01:04.000 align:start\nA\n", "vtt")
    assert_raises(ArgumentError) { S.convert(SRT, "ass") }
    assert_empty S.parse("no cues here")
  end

  def test_shift_and_repair
    cues = S.parse(SRT)
    assert_equal [[0, 2500], [2000, 1000]], S.shift(cues, -1000).map { |c| [c.start, c.end] }
    fixed, n = S.repair(cues)
    assert_equal ["First", "Hello\nworld", "Second"], fixed.map(&:text)
    assert(fixed.all? { |c| c.end > c.start })
    assert_equal 3, n
    assert_equal 2000, cues[1].end
  end

  def test_times
    assert_equal "01:02:03,004", S.from_ms(3_723_004, ",")
    assert_equal 3_723_400, S.to_ms("1:02:03.4")
    assert_nil S.to_ms("nope")
    assert S.vtt?("﻿WEBVTT\n")
  end

  def test_stats
    assert_equal({ words: 4, chars: 23, chars_no_spaces: 20, lines: 1, sentences: 2, read_seconds: 1 }, T.stats("Hello world. It’s 2026!"))
    st = T.stats("Hello world. It’s 2026!\nSecond line.")
    assert_equal [6, 2, 3], st.values_at(:words, :lines, :sentences)
    assert_equal 0, T.stats("")[:lines]
    assert_equal 2, T.stats("\u{1F600}a")[:chars]
    assert_equal({ limit: 280, used: 300, left: -20, fits: false }, T.limits("x" * 300, ["x-post"])["x-post"])
    assert_equal 9, T.limits("a").length
  end

  def test_cases
    assert_equal "The Lord of the Rings: Return of the King", T.title("the lord of the rings: return of the king")
    assert_equal "Hello world. How are you?", T.sentence("HELLO WORLD. how ARE you?")
    assert_equal "olcu-birimi-ceviri", T.slug("Ölçü Birimi & Çeviri!")
    assert_equal "strasse-cafe", T.slug("Straße café")
    assert_equal "bestPostingTime", T.camel("best posting time")
    assert_equal "best_posting_time", T.snake("bestPostingTime")
    assert_equal "best-posting-time", T.kebab("Best Posting_Time")
    assert_equal "a b\n\nc", T.clean("a   b  \n\n\n\nc\t")
    assert_equal "a\r\n\r\nb", T.clean("a  \r\n\r\n\r\n\r\nb")
  end
end
