# RubyGems.org'da yayınlama

Durum: kaynak hazır (kütüphane, `gosavetool` komut satırı aracı ve Minitest testleri), ancak bu bilgisayarda Ruby kurulu değil ve dış araç indirmek kapalıydı; bu yüzden **testler çalıştırılmadı**. Mantık, test edilmiş Python/Java/Perl sürümleriyle aynı adımları izliyor. Yayından önce:

```
winget install RubyInstallerTeam.Ruby.3.3
ruby -Ilib test/test_gosavetool.rb
gem build gosavetool.gemspec
```

Testler 5 test olarak geçmeli; `gem build` `gosavetool-1.0.0.gem` dosyasını üretir.

## 1. Hesap

1. https://rubygems.org/sign_up → kullanıcı adı `gosavetool`, e-posta, şifre. E-postayı doğrula.
2. **Edit Profile → Multi-factor authentication**: MFA'yı aç (gemspec'te `rubygems_mfa_required` açık, yayın için gerekli). Telefonda bir doğrulama uygulaması (Google Authenticator vb.) kullan.

## 2. Yayınlama

```
gem signin
gem push gosavetool-1.0.0.gem
```

`gem signin` e-posta, şifre ve MFA kodunu sorar; bilgisayarda bir oturum anahtarı saklar. `gem push` de MFA kodunu ister. Birkaç dakika içinde https://rubygems.org/gems/gosavetool sayfası açılır ve `gem install gosavetool` çalışır.

İsteğe bağlı GitHub deposu: `mitolocya/gosavetool-ruby` (gemspec'teki `source_code_uri`). Depo açılmayacaksa `source_code_uri` ve `changelog_uri` satırlarını silip öyle derle.

## Listeleme metinleri

Sayfa gemspec ve README'den oluşur:

- **Gem adı:** gosavetool
- **Özet:** SRT and WebVTT subtitle tools, word count, social media limits and case changes
- **Açıklama:** Parse, convert, shift and repair SRT and WebVTT subtitles; word, character and reading-time counts, social media character limits, Title Case, slugs and other case changes. No dependencies, with a command-line tool.
- **Ana sayfa:** https://www.gosavetool.com/
- **Etiketler (GitHub topics, depo açılırsa):** ruby, gem, subtitles, srt, webvtt, word-count, slug

## Sonraki sürümler

`lib/gosavetool/version.rb` içinde `VERSION` değerini artır, `CHANGELOG.md`'ye not ekle, `gem build` ve `gem push`. Yüklenen bir sürüm `gem yank` ile geri çekilebilir ama aynı numara tekrar kullanılamaz.
