require 'nokogiri'
require 'open-uri'
require 'optparse'

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("-uURL", "--url=URL", "The bible.is URL for the bible. (Mandatory)") do |u|
    options[:url] = u
  end
  
  opts.on("-oOUTPUT", "--out=OUTPUT", "The out file name. (Mandatory)") do |o|
    options[:out] = o
  end
end

begin
  optparse.parse!
  raise OptionParser::MissingArgument if options[:url].nil? || options[:out].nil?
rescue OptionParser::MissingArgument, OptionParser::InvalidOption
  puts optparse
  exit
end

bible_url = options[:url]  || "http://www.bible.is/ENGESV/2Pet/3"
page_exists = true

open(options[:out] || "out.txt", "w:UTF-16") do |f|
  while page_exists
    page = Nokogiri::HTML(open(bible_url).read, nil, 'UTF-8')
    a = page.css(".verse-container")
  
    ch_title = page.xpath('.//*[@class="chapter-title"]').text
    
    f.puts ch_title << "\n"
    puts(ch_title)
    
    a.each do |v|
      f.puts v.xpath('.//*[@class="verse-marker"]').text << " " << v.xpath('.//*[@class="verse-text"]').text << "\n"
    end
  
    bible_url = page.at_css(".chapter-nav-right")["href"]
  
    page_exists = false if bible_url.nil? || bible_url.empty?
  end
end