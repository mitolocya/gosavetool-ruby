# frozen_string_literal: true

module GoSaveTool
  # SRT and WebVTT: read cues, write them in either format, shift and repair timings.
  # The Ruby version of @gosavetool/subtitles: https://www.gosavetool.com/vtt-subtitle-generator
  module Subtitles
    # One subtitle cue; times in milliseconds.
    Cue = Struct.new(:start, :end, :settings, :text, keyword_init: true)

    STAMP = /(?:\d{1,2}:)?\d{1,2}:\d{1,2}[,.]\d{1,3}/
    TIME = /(\d{1,2}:)?(\d{1,2}):(\d{1,2})[,.](\d{1,3})/
    ARROW = /\A\s*(#{STAMP})\s*-->\s*(#{STAMP})(.*)\z/

    module_function

    # "00:01:02,500" or "01:02.5" => 62500; nil when it is not a timestamp
    def to_ms(stamp)
      m = TIME.match(stamp)
      return nil unless m

      h = m[1] ? m[1].chomp(":").to_i : 0
      ((h * 60 + m[2].to_i) * 60 + m[3].to_i) * 1000 + m[4].ljust(3, "0").to_i
    end

    # 62500 => "00:01:02,500" (sep ",", SRT) or "00:01:02.500" (sep ".", WebVTT)
    def from_ms(ms, sep = ",")
      # Half up, as JavaScript's Math.round
      t = [(ms + 0.5).floor, 0].max
      format("%02d:%02d:%02d%s%03d", t / 3_600_000, t / 60_000 % 60, t / 1000 % 60, sep, t % 1000)
    end

    # Cues of an SRT or WebVTT text. Headers, NOTE and STYLE blocks are skipped.
    def parse(src)
      # "\r\r\n" too: a file saved twice with Windows line endings
      text = src.delete_prefix("﻿").gsub(/\r*\n|\r/, "\n")
      text.split(/\n{2,}/).filter_map do |block|
        lines = block.split("\n", -1)
        at = lines.index { |l| ARROW.match?(l) }
        next unless at

        m = ARROW.match(lines[at])
        Cue.new(start: to_ms(m[1]), end: to_ms(m[2]), settings: m[3].strip, text: lines[(at + 1)..].join("\n").strip)
      end
    end

    # True when the text starts with the WEBVTT signature
    def vtt?(src)
      src.delete_prefix("﻿").start_with?("WEBVTT")
    end

    def to_srt(cues)
      cues.each_with_index.map { |c, i| "#{i + 1}\n#{from_ms(c.start, ',')} --> #{from_ms(c.end, ',')}\n#{c.text}" }.join("\n\n") + "\n"
    end

    def to_vtt(cues)
      body = cues.map do |c|
        settings = c.settings.to_s.empty? ? "" : " #{c.settings}"
        "#{from_ms(c.start, '.')} --> #{from_ms(c.end, '.')}#{settings}\n#{c.text}"
      end
      "WEBVTT\n\n#{body.join("\n\n")}\n"
    end

    # Converts a subtitle text to "srt" or "vtt"
    def convert(src, to)
      case to.to_s
      when "vtt" then to_vtt(parse(src))
      when "srt" then to_srt(parse(src))
      else raise ArgumentError, 'the target format must be "srt" or "vtt"'
      end
    end

    # Moves every cue by ms (negative = earlier); cues pushed before zero are clipped or dropped
    def shift(cues, ms)
      cues.map { |c| Cue.new(start: [c.start + ms, 0].max, end: [c.end + ms, 0].max, settings: c.settings, text: c.text) }
          .select { |c| c.end.positive? }
    end

    # Sorts cues, fixes end times before the start and overlaps, drops empty cues.
    # Returns [cues, number_of_changes]. The input is not changed.
    def repair(cues, min_duration: 2000)
      fixed = cues.count { |c| c.text.empty? }
      kept = cues.reject { |c| c.text.empty? }.map(&:dup)
      # sort_by is not stable in Ruby, so the original position breaks ties
      out = kept.each_with_index.sort_by { |c, i| [c.start, i] }.map(&:first)
      fixed += 1 if out.map(&:start) != kept.map(&:start)
      out.each_with_index do |c, i|
        nxt = out[i + 1]
        unless c.end > c.start
          c.end = c.start + min_duration
          fixed += 1
        end
        if nxt && c.end > nxt.start
          c.end = [c.start + 1, nxt.start - 1].max
          fixed += 1
        end
      end
      [out, fixed]
    end
  end
end
