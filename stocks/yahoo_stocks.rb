#!/usr/bin/ruby

require "csv"
require "mechanize"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = "Mozilla/5.0"

base = "http://finance.yahoo.com"

# Stock symbol
stock = "YHOO"

# Date range - two weeks
first = [9,8,2012]
last = [9,22,2012]

# Daily
freq = "d"

# This version doesn't skip the first row 
#path = "//*[@id='yfncsumtab']/tr[2]/td[1]/table[4]/tr/td/table/tr"

# This variation skips the first row
path = "//*[@id='yfncsumtab']/tr[2]/td[1]/table[4]/tr/td/table/tr[position() > 1]"

results = CSV.open("stocks_ruby.csv","w")

url = "#{base}/q/hp?s=#{stock}&a=#{first[0]}&b=#{first[1]}&c=#{first[2]}&d=#{last[0]}&e=#{last[1]}&f=#{last[2]}&g=#{freq}"

begin
  page = agent.get(url)
rescue
  print "  -> error, retrying\n"
  retry
end

# You can use this statement to help figure out the right xpath command
#puts page.parser.xpath(path).to_html

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
