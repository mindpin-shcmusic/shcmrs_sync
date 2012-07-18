require 'chinese_pinyin'

names = File.open('vendor/names.txt').map(&:chomp)
i = 0

names.each do |name|
  i += 1
  pinyin = Pinyin.t(name, '')

  User.create :name     => name,
              :password => "1234",
              :email    => "#{pinyin}#{i}@#{pinyin}.fake"
end
