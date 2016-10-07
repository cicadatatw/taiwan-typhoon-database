# encoding=utf-8 
require 'open-uri'
require 'net/http'
require "json"

if ARGV[0].nil?
	year = "all"
else
	year = ARGV[0]
end



top_url = "http://rdc28.cwb.gov.tw/TDB/ntdb/pageControl/ty_warning?list=all"
top_path = "http://rdc28.cwb.gov.tw/TDB/ctrl_typhoon_list/redirect2detail?typhoonId="

uri = URI('http://rdc28.cwb.gov.tw/TDB/ctrl_typhoon_list/get_typhoon_list_table')
res = Net::HTTP.post_form(uri, 'year' => year, 'model' => 'all')
list = res.body

pat1 = /<a class="typhoon_e_name" value="(\d+)">(\w+)<\/a>/
pat2 = /<tr>\s*<td align=left class="td_title">(.+)<\/td>\s+<td[\s\w\d"=]*>([\u4e00-\uf937\u3002\uff0c\w\d\s<>\/:\-\(\)\.]+)<\/td>\s*<\/tr>/

typhoons = list.scan(pat1).to_a

puts typhoons.size.to_s + " typhoons found!"

typhoon_json = {}

for typhoon in typhoons
	id = typhoon[0]
	typhoon_name = typhoon[1]
	page_url = top_path + id
	puts typhoon_name + ": " + page_url
	tmp = open(page_url).read
	raw_json = JSON.parse(tmp)
	raw_table = raw_json["tytable"].scan(pat2).to_a
	data = {}
	for row in raw_table
		data[row[0]] = row[1].gsub("<br/>"," ").gsub("\n"," ")
	end
	puts data
	typhoon_json[id] = data
end


unless Dir.exists?("data")
	Dir.mkdir("data")
end

File.open("data/#{year}.json", "w+:utf-8") do |i|
	    i.write(JSON.pretty_generate(typhoon_json))
end





