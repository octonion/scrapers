#!/usr/bin/ruby

require "csv"
require "mechanize"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = "Mozilla/5.0"

base = "http://finance.yahoo.com"

# Stock symbol
stock = "GOOG"

results = CSV.open("#{stock}_ruby.csv","w")

url = "https://finance.yahoo.com/quote/#{stock}/history?ltr=1"

begin
  page = agent.get(url)
rescue
  print "  -> error, retrying\n"
  retry
end

# You can use this statement to help figure out the right xpath command
#puts page.parser.xpath(path).to_html

path = '//tr'

page.parser.xpath(path).each_with_index do |row,i|

  r = [stock]
  row.xpath("td").each_with_index do |td,j|
    r << td.text.strip
  end

  if (r.size>2)
    results << r
  end

  results.flush

end

results.close
