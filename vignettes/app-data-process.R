library(citesdb)
library(tidyverse)
library(magrittr)
library(CoordinateCleaner)
library(countrycode)
library(sf)

pangolin_shipments <- cites_shipments() %>%
  filter(Order == "Pholidota", Purpose %in% c(NA_character_, "T")) %>%
  select(-Purpose, -Import.permit.RandomID, -Export.permit.RandomID, -Origin.permit.RandomID, -Class, -Order, -Family, -Genus ) %>%
  collect()
cites_disconnect()

all_shipments <- cites_shipments() %>%
  select(Year, Importer, Exporter, Reporter.type) %>%
  distinct() %>%
  mutate(reporting_country = ifelse(Reporter.type == "I", Importer, Exporter)) %>%
  group_by(Year) %>%
  summarize(n_reporting = n_distinct(reporting_country)) %>%
  ungroup %>%
  collect()

cref <- CoordinateCleaner::countryref %>%
  filter(type == "country") %>%
  distinct(iso2, .keep_all = TRUE) %>%
  select(iso2, centroid.lon, centroid.lat)

pangolin_shipments %<>%
  mutate(start = coalesce(Origin, Exporter)) %>%
  left_join(cref, by = c("start" = "iso2")) %>%
  rename(start.lon = centroid.lon, start.lat = centroid.lat) %>%
  left_join(cref, by = c("Importer" = "iso2")) %>%
  rename(end.lon = centroid.lon, end.lat = centroid.lat) %>%
  filter(Importer != start) %>%
  filter(!is.na(start.lon), !is.na(end.lon), !is.na(start.lat), !is.na(end.lat)) %>%
  mutate(id = seq_len(n()))

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
  mutate(term = fct_lump_min(term, min = 5, other_level = "other")) %>%
  # mutate(start = ifelse(start == reporting_country_full_name, paste0(start, "*"), start),
  #        end = ifelse(end == reporting_country_full_name, paste0(end, "*"), end)) %>%
  select(year, start, end, term, start_lon, start_lat, end_lon, end_lat)

pangolin_shipments %<>%
  group_by_at(vars(-start, -end)) %>%
  mutate(n = n()) %>%
  ungroup() %>%
  mutate(n_scale = scales::rescale(n, to = c(3, 10))) %>%
  left_join(all_shipments, by = c("year" = "Year"))

write_rds(pangolin_shipments, here::here("vignettes", "pangolin_dat.rds"))
