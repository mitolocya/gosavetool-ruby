# frozen_string_literal: true

module GoSaveTool
  # Word, character and reading-time counts, social media character limits, case changes, URL slugs and
  # whitespace cleanup. The Ruby version of @gosavetool/text: https://www.gosavetool.com/character-counter
  module Text
    # Character limits of common fields; SEO values are the length search results show before cutting
    LIMITS = {
      "x-post" => 280,
      "instagram-caption" => 2200,
      "tiktok-caption" => 4000,
      "youtube-title" => 100,
      "youtube-description" => 5000,
      "linkedin-post" => 3000,
      "pinterest-description" => 500,
      "seo-title" => 60,
      "meta-description" => 160
    }.freeze

    SMALL = %w[a an and as at but by for in nor of on or so the to up yet via vs].freeze
    SLUG_MAP = {
      "ı" => "i", "İ" => "i", "ş" => "s", "Ş" => "s", "ğ" => "g", "Ğ" => "g", "ç" => "c", "Ç" => "c", "ö" => "o",
      "Ö" => "o", "ü" => "u", "Ü" => "u", "ß" => "ss", "æ" => "ae", "ø" => "o", "đ" => "d", "ł" => "l"
    }.freeze

    WORD = /[\p{L}\p{N}][\p{L}\p{N}'’_-]*/
    TITLE_WORD = /[\p{L}\p{N}][\p{L}\p{N}'’]*/
    SENTENCE = /[^.!?…]+[.!?…]+/

    module_function

    # Words, characters, lines, sentences and reading time (238 words a minute) of a text.
    # Characters are Unicode code points, so an emoji counts as one.
    def stats(s)
      words = s.scan(WORD).length
      {
        words: words,
        chars: s.length,
        chars_no_spaces: s.gsub(/[[:space:]]/, "").length,
        lines: s.empty? ? 0 : s.split(/\r\n|\r|\n/, -1).length,
        sentences: s.scan(SENTENCE).length,
        read_seconds: (words / 238.0 * 60 + 0.5).floor
      }
    end

    # How the text meets each limit: { "x-post" => { limit: 280, used: 120, left: 160, fits: true }, ... }
    def limits(s, only = nil)
      used = s.length
      LIMITS.each_with_object({}) do |(field, limit), out|
        next if only && !only.include?(field)

        out[field] = { limit: limit, used: used, left: limit - used, fits: used <= limit }
      end
    end

    # "bestPostingTime 2" => ["best", "Posting", "Time", "2"]
    def words(s)
      s.gsub(/([\p{Ll}\p{N}])(\p{Lu})/, '\1 \2').split(/[^\p{L}\p{N}]+/).reject(&:empty?)
    end

    def upper(s) = s.upcase
    def lower(s) = s.downcase

    def capitalize_first(w)
      w.empty? ? w : w[0].upcase + w[1..]
    end

    # "the lord of the rings: return of the king" => "The Lord of the Rings: Return of the King"
    def title(s)
      low = s.downcase
      first = true
      low.gsub(TITLE_WORD) do |w|
        at = Regexp.last_match.begin(0)
        after_colon = low[0, at].match?(/[:.!?][[:space:]]*\z/)
        keep = !first && !after_colon && SMALL.include?(w)
        first = false
        keep ? w : capitalize_first(w)
      end
    end

    # "HELLO WORLD. how ARE you?" => "Hello world. How are you?"
    def sentence(s)
      s.downcase.gsub(/(\A[[:space:]]*|[.!?…][[:space:]]+)(\p{L})/) { Regexp.last_match(1) + Regexp.last_match(2).upcase }
    end

    # "Ölçü Birimi & Çeviri!" => "olcu-birimi-ceviri"
    def slug(s)
      mapped = s.gsub(/[ıİşŞğĞçÇöÖüÜßæøđł]/, SLUG_MAP)
      mapped.unicode_normalize(:nfkd).gsub(/[̀-ͯ]/, "").downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-+|-+\z/, "")
    end

    def camel(s)
      words(s).each_with_index.map { |w, i| i.zero? ? w.downcase : capitalize_first(w.downcase) }.join
    end

    def snake(s) = words(s).map(&:downcase).join("_")
    def kebab(s) = words(s).map(&:downcase).join("-")

    # Removes trailing spaces, runs of spaces and more than one blank line in a row.
    def clean(s)
      nl = s.include?("\r\n") ? "\r\n" : "\n"
      lines = s.split(/\r\n|\n/, -1).map { |l| l.sub(/[ \t]+\z/, "").gsub(/([^[:space:]])[ \t]{2,}/, '\1 ') }
      lines.join(nl).gsub(/(?:#{Regexp.escape(nl)}){3,}/, nl * 2)
    end
  end
end
