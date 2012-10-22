#!/usr/bin/python

import csv
import lxml.html as lh

base = 'http://finance.yahoo.com'

# Stock symbol
stock = 'YHOO'

# Date range - two weeks
first = [9,8,2012]
last = [9,22,2012]

# Daily
freq = 'd'

# This version doesn't skip the first row 
#path = '//*[@id='yfncsumtab']/tr[2]/td[1]/table[4]/tr/td/table/tr'

# This variation skips the first row
path = '//*[@id="yfncsumtab"]/tr[2]/td[1]/table[4]/tr/td/table/tr[position() > 1]'

results = csv.writer(file(r'stocks_python.csv','wb'))

url = '%s/q/hp?s=%s&a=%i&b=%i&c=%i&d=%i&e=%i&f=%i&g=%s' % (base,stock,first[0],first[1],first[2],last[0],last[1],last[2],freq)

while True:
    try:
        page = lh.parse(url)
        break
    except:
        print "  -> error, retrying\n"
        continue

for row in page.xpath(path):
    r = [stock]
    for td in row.xpath('td'):
        r += [td.text]

    if (len(r)>2):
        results.writerow(r)

    results.flush()
  
#results.close
