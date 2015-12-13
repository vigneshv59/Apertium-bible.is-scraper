require 'nokogiri'
require 'open-uri'
require 'optparse'
require 'net/http'

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: example.rb URL OUTPUT [options]"

  opts.on("-tTIME", "--time=TIME", "The time limit in seconds. (Optional)") do |t|
    options[:time] = t
  end
  
  opts.on("-nVERSES", "--num=VERSES", "The verse limit. (Optional)") do |v|
    options[:verses] = v
  end
end

options[:url] = ARGV[0]
options[:out] = ARGV[1]

begin
  optparse.parse!
  raise OptionParser::MissingArgument if options[:url].nil? || options[:out].nil?
rescue OptionParser::MissingArgument, OptionParser::InvalidOption
  puts optparse
  exit
end

bible_url = options[:url]
page_exists = true
verses_finished = 0
start_time = Time.now
distiction_type = options[:url].split("/")[-1]

open(options[:out] || "out.txt", "w:UTF-8") do |f|
  while page_exists && (options[:time].nil? || Time.now - start_time < options[:time].to_i) && (options[:verses].nil? || verses_finished < options[:verses].to_i)
    url = URI.parse(bible_url)
    
    if url.path.split("/")[-1] != "N" &&  url.path.split("/")[-1] != "D"
      url.path = File.join(url.path, distiction_type)
    end
    
    req = Net::HTTP::Get.new(url.path)
    
    req.add_field("Cookie", {"current-bible-location" => URI.encode(url.path) })
    
    res = Net::HTTP.new(url.host, url.port).start do |http|
      http.request(req)
    end
    
    page = Nokogiri::HTML(res.body, nil, 'UTF-8')
    a = page.css(".verse-container")
  
    ch_title = page.xpath('.//*[@class="chapter-title"]').text
    
    f.puts ch_title << "\n"
    puts(ch_title)
    
    a.each do |v|
      f.puts v.xpath('.//*[@class="verse-marker"]').text << " " << v.xpath('.//*[@class="verse-text"]').text << "\n"
    end
  
    bible_url = page.at_css(".chapter-nav-right")["href"]
  
    page_exists = false if bible_url.nil? || bible_url.empty?
    verses_finished = verses_finished + 1
    f.puts("\n")
  end
end