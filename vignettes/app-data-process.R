library(citesdb)
library(tidyverse)
library(magrittr)
library(CoordinateCleaner)
library(countrycode)
library(sf)

# get cites pangolin data
pangolin_shipments <- cites_shipments() %>%
  filter(Order == "Pholidota", Purpose %in% c(NA_character_, "T")) %>%
  select(-Purpose, -Import.permit.RandomID, -Export.permit.RandomID, -Origin.permit.RandomID, -Class, -Order, -Family, -Genus ) %>%
  collect()
cites_disconnect()

# qa check on species
check_taxon <- pangolin_shipments %>%
  select(Year, Taxon, Appendix) %>%
  distinct()
# ^ does not exactly match cites website https://speciesplus.net/#/taxon_concepts?taxonomy=cites_eu&taxon_concept_query=pangolin&geo_entities_ids=&geo_entity_scope=cites&page=1
# eg Manis tricuspis listed as App II in 91, but should be III
# eg Manis tricuspis listed as App II in 2017, but should be I

# get country centroids
cref <- CoordinateCleaner::countryref %>%
  filter(type == "country") %>%
  distinct(iso2, .keep_all = TRUE) %>%
  select(iso2, centroid.lon, centroid.lat)

# get start and end locs
pangolin_shipments %<>%
  mutate(start = coalesce(Origin, Exporter)) %>%
  left_join(cref, by = c("start" = "iso2")) %>%
  rename(start.lon = centroid.lon, start.lat = centroid.lat) %>%
  left_join(cref, by = c("Importer" = "iso2")) %>%
  rename(end.lon = centroid.lon, end.lat = centroid.lat) %>%
  filter(Importer != start) %>%
  filter(!is.na(start.lon), !is.na(end.lon), !is.na(start.lat), !is.na(end.lat)) %>%
  mutate(id = seq_len(n()))

# get country names
pangolin_shipments %<>%
  janitor::clean_names() %>%
  mutate(
    reporting_country = ifelse(reporter_type == "I", importer, exporter),
    reporting_country_full_name  = countrycode(sourcevar = reporting_country,
                                     origin = "iso2c",
                                     destination = "country.name"),
    start = countrycode(sourcevar = start,
                         origin = "iso2c",
                         destination = "country.name"),
    end = countrycode(sourcevar = importer,
                      origin = "iso2c",
                      destination = "country.name")) %>%
  mutate(term = ifelse(term %in% c("leather products (small)", "leather products (large)", "leather items"), "leather products", term)) %>%
  #mutate(term = fct_lump_min(term, min = 5, other_level = "other")) %>%
  # mutate(start = ifelse(start == reporting_country_full_name, paste0(start, "*"), start),
  #        end = ifelse(end == reporting_country_full_name, paste0(end, "*"), end)) %>%
  select(year, start, end, term, start_lon, start_lat, end_lon, end_lat)

# get n reporting countries
parties <- cites_parties() %>%
  drop_na(date) %>%
  mutate(year = as.numeric(str_sub(date, 1, 4))) %>%
  select(country, year) %>%
  mutate(in_cites = TRUE) %>%
  right_join(expand(., country, year = min(pangolin_shipments$year):max(pangolin_shipments$year))) %>%
  group_by(country) %>%
  fill(in_cites) %>%
  group_by(year)%>%
  summarize(n_parties = sum(in_cites, na.rm=T)) %>%
  ungroup()

# build final database to feed into shiny
pangolin_shipments %<>%
  group_by_at(vars(-start, -end)) %>%
  mutate(n = n()) %>%
  ungroup() %>%
  mutate(n_scale = scales::rescale(n, to = c(3, 10))) %>%
  left_join(parties)

write_rds(pangolin_shipments, here::here("vignettes", "pangolin_dat.rds"))

