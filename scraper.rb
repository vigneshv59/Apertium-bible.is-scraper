require 'nokogiri'
require 'open-uri'

bible_url = "http://www.bible.is/ENGESV/2Pet/3"
page_exists = true
output = ""

while page_exists
  page = Nokogiri::HTML(open(bible_url))
  a = page.xpath('//*[@class="verse-container"]')
  output << page.xpath('.//*[@class="chapter-title"]').text << "\n"

  puts a[0].xpath('.//*[@class="verse-text"]')
  a.each do |v|
    output << v.xpath('.//*[@class="verse-marker"]').text << " "
    output << v.xpath('.//*[@class="verse-text"]').text << "\n"
  end
  
  bible_url = page.at_css(".chapter-nav-right")["href"]
  
  page_exists = false if bible_url.nil? || bible_url.empty?
end

open("output.txt", "w") do |f|
  f.puts output
end