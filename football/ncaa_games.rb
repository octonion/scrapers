#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

url = "http://web1.ncaa.org/stats/exec/records"

first_year = 2014
last_year = 2014

games_header = ["year","team_name","team_id","opponent_name","opponent_id",
                "game_date","team_score","opponent_score","location",
                "neutral_site_location","game_length","attendance"]

records_header = ["year","team_id","team_name","wins","losses","ties",
                  "total_games"]

(first_year..last_year).each do |year|

  teams = CSV.read("csv/ncaa_teams_#{year}.csv", "r",
                   {:col_sep => "\t", :headers => true})

  games = CSV.open("csv/ncaa_games_ruby_#{year}.csv", "w",
                   {:col_sep => "\t"})

  records = CSV.open("csv/ncaa_records_ruby_#{year}.csv", "w",
                     {:col_sep => "\t"})

  games << games_header
  records << records_header

  team_count = 0
  game_count = 0

  teams.each do |team|

    team_id = team["team_id"]
    team_name = team["team_name"]

    print "#{year}/#{team_name} (#{team_count}/#{game_count})\n"
    begin
      page = agent.post(url, {"academicYear" => "#{year}", "orgId" => team_id,
                             "sportCode" => "MFB"})
    rescue
      print "  -> error, retrying\n"
      retry
    end

    if !(page.class==Mechanize::Page)
      next
    end

    begin
      page.parser.xpath("//table/tr[3]/td/form/table[1]/tr[2]").each do |row|
        r = []
        row.xpath("td").each do |d|
          r += [d.text.strip]
        end
        team_count += 1
        records << [year,team_id]+r
      end
      records.flush
    end

    page.parser.xpath("//table/tr[3]/td/form/table[2]/tr").each do |row|
      r = []
      row.xpath("td").each do |d|
        r += [d.text.strip,d.inner_html.strip]
      end
      if (r[0]=="Opponent")
        next
      end
      opponent_id = r[1][/(\d+)/]
      game_count += 1

      rr = [year,team_name,team_id,r[0],opponent_id,
            r[2],r[4],r[6],r[8],r[10],r[12],r[14]]

      rr.map!{ |e| e=='' ? nil : e }

      games << rr

    end
    games.flush

  end
  records.close
  games.close

end

