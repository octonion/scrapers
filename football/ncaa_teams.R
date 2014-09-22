###########################
# File: ncaa_teams.R
# Description: Creates a csv file of all FBS football teams from NCAA.org
# Date: 09/22/2014
# Notes: This is a modified version of Christopher D. Long's original in ruby,
#        https://github.com/octonion/scrapers/blob/master/football/ncaa_teams.rb
###########################

# Set working directory
dir <- # Insert path
setwd(dir)

# Load packages
library(rvest) # devtools::install_github("hadley/rvest")
library(stringr)
library(magrittr)

year <- 2014
division <- 11

# Base URL for relative team links
base_url <- "http://stats.ncaa.org"

year_division_url <- paste0(base_url,
                            "/team/inst_team_list?sport_code=MFB&academic_year=",
                            year, "&division=", division, 
                            "&conf_id=-1&schedule_date=")

# Request html document
doc <-html(year_division_url)

# Extract the components
teams       <- html_nodes(doc, css = "td a")

names       <- teams %>% html_text(trim = TRUE)

team_url    <- teams %>% html_attr("href") %>% paste0(base_url, .)

split_links <- team_url %>% str_split(pattern = "\\?", n = 2)

year_id     <-  sapply(split_links, "[[", 1) %>% str_extract(pattern = "[0-9]+")
team_id     <-  sapply(split_links, "[[", 2) %>% str_extract(pattern = "[0-9]+")

# Collect into a data frame
results <- data.frame(year      = year, 
                      year.id   = year_id, 
                      team.id   = team_id,
                      team.name = names, 
                      team.url  = team_url, stringsAsFactors = FALSE)

# Output as a csv file
write.csv(results, paste0("ncaa_teams_", year, ".csv") , row.names = FALSE)
