#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

class String
  def to_nil
    self.empty? ? nil : self
  end
end

games_url = "http://web1.ncaa.org/stats/exec/records"

games_header = ["year","team_name","team_id","opponent_name","opponent_id",
                "game_date","team_score","opponent_score","location",
                "neutral_site_location","game_length","attendance"]

records_header = ["year","team_id","team_name","wins","losses","ties",
                  "total_games"]

game_xpath = "//table/tr[3]/td/form/table[2]/tr"
record_xpath = "//table/tr[3]/td/form/table[1]/tr[2]"

nthreads = 6

base_sleep = 0
sleep_increment = 3
retries = 4

first_year = 2014
last_year = 2014

(first_year..last_year).each do |year|

  teams = CSV.read("csv/ncaa_teams_#{year}.csv", "r",
                   {:col_sep => "\t", :headers => true})

  n = teams.size
  gpt = (n.to_f/nthreads.to_f).ceil

  games = CSV.open("csv/ncaa_games_ruby_mt_#{year}.csv", "w",
                   {:col_sep => "\t"})

  records = CSV.open("csv/ncaa_records_ruby_mt_#{year}.csv", "w",
                     {:col_sep => "\t"})

  games << games_header
  records << records_header

  threads = []

  teams.each_slice(gpt).with_index do |teams_slice,i|

    threads << Thread.new(teams_slice) do |t_teams|

      agent = Mechanize.new{ |agent| agent.history.max_size=0 }

      agent.user_agent = 'Mozilla/5.0'

      agent.get(games_url)

      n_t = t_teams.size

      t_teams.each_with_index do |team,j|

        team_id = team["team_id"]
        team_name = team["team_name"]

        team_count = 0
        game_count = 0

        print "#{i}:#{j}/#{n_t} - #{year}/#{team_name}\n"

        begin
          page = agent.post(games_url, {"academicYear" => "#{year}",
                              "orgId" => team_id,
                              "sportCode" => "MFB"})
        rescue
          print "  -> error, retrying\n"
          retry
        end

        if !(page.class==Mechanize::Page)
          next
        end

        begin
          page.parser.xpath(record_xpath).each do |row|
            r = []
            row.xpath("td").each do |d|
              r += [d.text.strip]
            end
            team_count += 1
            records << [year,team_id]+r
          end
        end

        page.parser.xpath(game_xpath).each do |row|
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

      end
    end
  end

  threads.each(&:join)
  games.close
  records.close
end
