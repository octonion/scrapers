import urllib2
import json
import pprint

linescore_url = 'http://www.milb.com/gdcross/components/game/afa/year_2013/month_09/day_14/gid_2013_09_14_inlafa_sjgafa_1/linescore.json'

response = urllib2.urlopen(linescore_url)

json_linescore = response.read()

linescore = json.loads(json_linescore)

# To see the structure
#pprint.pprint(linescore)

print 'Game date/time:',linescore['data']['game']['time_date']
print 'Home team:',linescore['data']['game']['home_team_name']
print 'Home runs:',linescore['data']['game']['home_team_runs']
print 'Away team:',linescore['data']['game']['away_team_name']
print 'Away runs:',linescore['data']['game']['away_team_runs']
