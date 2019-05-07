library(citesdb)
library(tidyverse)
library(CoordinateCleaner)
library(countrycode)
library(sf)

pangolin_shipments <- cites_shipments() %>%
  filter(Order == "Pholidota", Purpose %in% c(NA_character_, "T")) %>%
  select(-Purpose, -Import.permit.RandomID, -Export.permit.RandomID, -Origin.permit.RandomID, -Class, -Order, -Family, -Genus, -Reporter.type ) %>%
  collect()
cites_disconnect()

cref <- CoordinateCleaner::countryref %>%
  filter(type == "country") %>%
  distinct(iso2, .keep_all = TRUE) %>%
  select(iso2, centroid.lon, centroid.lat)

pangolin_shipments <- pangolin_shipments %>%
  mutate(start = coalesce(Origin, Exporter)) %>%
  left_join(cref, by = c("start" = "iso2")) %>%
  rename(start.lon = centroid.lon, start.lat = centroid.lat) %>%
  left_join(cref, by = c("Importer" = "iso2")) %>%
  rename(end.lon = centroid.lon, end.lat = centroid.lat) %>%
  filter(Importer != start) %>%
  filter(!is.na(start.lon), !is.na(end.lon), !is.na(start.lat), !is.na(end.lat)) %>%
  mutate(id = seq_len(n()))


dat <- pangolin_shipments %>%
  janitor::clean_names() %>%
  mutate(
    # reporting_country = ifelse(reporter_type == "I", importer, exporter),
    # reporting_country  = countrycode(sourcevar = reporting_country,
    #                                  origin = "iso2c",
    #                                  destination = "country.name"),
    start2 = countrycode(sourcevar = start,
                         origin = "iso2c",
                         destination = "country.name"),
    end = countrycode(sourcevar = importer,
                      origin = "iso2c",
                      destination = "country.name")) %>%
  select(year, start2, end, term, start_lon, start_lat, end_lon, end_lat) %>%
  rename(start = start2)


dat2 <- dat %>%
  group_by_all() %>%
  mutate(n = n()) %>%
  ungroup()

write_rds(dat2, here::here("vignettes", "pangolin_dat.rds"))
