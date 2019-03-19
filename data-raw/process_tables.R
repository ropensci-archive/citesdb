

library(tidyverse)
library(tabulizer)

h <- here::here

#==============================================================================


# Prepare cites_metadata table

cites_metadata <- read_tsv(h("data-raw", "cites_metadata.tsv"))

write_tsv(cites_metadata, h("inst", "extdata", "cites_metadata.tsv"))

#==============================================================================


# Prepare cites_codes table

cites_codes <- read_tsv(h("data-raw", "cites_codes.tsv")) %>%
  arrange(field, code) %>%
  filter(field != "Term", field != "Unit")

# Note, currently leaving out "Term" and "Unit" since these variables appear
# as full descriptions (not codes) in the citesdb data

write_tsv(cites_codes, h("inst", "extdata", "cites_codes.tsv"))

#==============================================================================


# Prepare cites_parties table

cites_parties <- read_tsv(h("data-raw", "cites_parties.tsv")) %>%
  mutate(code = ifelse(country == "Namibia", "NA", code)) %>%
  separate(., code, into = c("code1", "code2"),
           sep = ", formerly| ex-", fill = "right") %>%
  mutate(code1 = str_replace_all(code1, " ", ""),
         code2 = str_replace_all(code2, " ", "")) %>%
  gather(., key = code_version, value = code, -country, -date) %>%
  filter(!is.na(code)) %>%
  mutate(code_version = ifelse(code_version == "code2", TRUE, FALSE)) %>%
  select(country, code, code_version, date) %>%
  rename(former_code = code_version) %>%
  filter(!(country == "Slovakia" & former_code == TRUE),
         !(country == "Czech Republic" & former_code == TRUE))

countries_raw <- h("data-raw", "en-CITES_Trade_Database_Guide.pdf") %>%
  extract_areas(., pages = c(14, 15, 16))

countries_raw2 <- do.call(rbind, countries_raw)

countries <-
  tibble(
    code = c(countries_raw2[, c(1, 3)]),
    country = c(countries_raw2[, c(2, 4)])
  ) %>%
  filter(country != "" | code != "",
         country != "ISLANDS",
         country != "AND NORTHERN IRELAND") %>%
  mutate(country = tolower(country),
         country = stringi::stri_trans_totitle(country)) %>%
  tidyr::separate(., col = code, into = c("code", "non_ISO_code"),
                  sep = "1", fill = "right") %>%
  mutate(non_ISO_code = ifelse(is.na(non_ISO_code), FALSE, TRUE),
         country = str_replace_all(country, "And", "and"),
         country = str_replace_all(country, "Of", "of"),
         country = str_replace_all(country, "The", "the")) %>%
  mutate(country = case_when(
    country == "andorra" ~ "Andorra",
    country == "Bolivia (Plurinational State of)" ~ "Bolivia, Plurinational State of",
    country == "Congo, Democratic Republic of the" ~ "Democratic Republic of the Congo",
    country == "Côte D'ivoire" ~ "Côte d'Ivoire",
    country == "Tanzania, United Republic of" ~ "United Republic of Tanzania",
    country == "Saint Vincent and the Grenadines" ~ "Saint Vincent and the Grenadines",
    country == "South Georgia and the South Sandwich" ~ "South Georgia and the South Sandwich Islands",
    country == "United Kingdom of Great Britain" ~ "United Kingdom of Great Britain and Northern Ireland",
    country == "Virgin Islands (U.s.)" ~ "Virgin Islands (U.S.)",
    TRUE ~ country
  )) %>%
  mutate(former_code = FALSE)

cites_parties <- full_join(cites_parties, countries,
                  by = c("code", "country", "former_code")) %>%
  select(country, code, former_code, non_ISO_code, date) %>%
  arrange(country, desc(former_code)) %>%
  mutate(non_ISO_code = ifelse(non_ISO_code == "", FALSE, non_ISO_code)) %>%
  # Deal with CS and YU code issues
  filter(!(country == "Former Serbia and Montenegro" & is.na(former_code)),
         !(country == "Serbia and Montenegro" & former_code == TRUE))

write_tsv(cites_parties, h("inst", "extdata", "cites_parties.tsv"))
