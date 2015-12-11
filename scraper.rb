require 'nokogiri'
require 'open-uri'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("-uURL", "--url=URL", "The bible.is URL for the bible.") do |u|
    options[:url] = u
  end
end.parse!

bible_url = options[:url]  || "http://www.bible.is/ENGESV/2Pet/3"
page_exists = true
output = ""

while page_exists
  page = Nokogiri::HTML(open(bible_url))
  a = page.css(".verse-container")
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