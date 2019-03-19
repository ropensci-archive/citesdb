

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
           sep = ", formerly| ex-",fill = "right") %>%
  mutate(code1 = str_replace_all(code1, " ", ""),
         code2 = str_replace_all(code2, " ", "")) %>%
  gather(., key = code_version, value = code, -country, -date) %>%
  filter(!is.na(code)) %>%
  mutate(code_version = ifelse(code_version == "code2", TRUE, FALSE)) %>%
  select(country, code, code_version, date) %>%
  rename(former_code = code_version) %>%
  arrange(country, desc(former_code))

write_tsv(cites_parties, h("inst", "extdata", "cites_parties.tsv"))
