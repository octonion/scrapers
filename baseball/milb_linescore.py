import urllib2
import json
import pprint

linescore_url = 'http://www.milb.com/gdcross/components/game/afa/year_2013/month_09/day_14/gid_2013_09_14_inlafa_sjgafa_1/linescore.json'

response = urllib2.urlopen(linescore_url)

json_linescore = response.read()

linescore = json.loads(json_linescore)
pprint.pprint(linescore)
