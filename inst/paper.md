---
title: 'citesdb: An R package to support analysis of CITES Trade Database shipment-level data'
tags:
  - R
  - database
  - wildlife
  - trade
  - conservation
  - sustainability
authors:
 - name: Noam Ross
   orcid: 0000-0002-2136-0000
   affiliation:
    - 1
 - name: Evan A. Eskew
   orcid: 0000-0002-1153-5356
   affiliation:
    - 1
affiliations:
 - name: EcoHealth Alliance, 460 West 34th Street -- Suite 1701, New York, NY 10001
   index: 1
date: 21 May 2019
bibliography: paper.bib
---

# Summary

International trade is a significant threat to wildlife globally [@Bennett_2002; @Lenzen_2012; @Bush_2014; @Tingley_2017]. Consequently, high-quality, widely accessible data on the wildlife trade are urgently needed to generate effective conservation strategies and action [@Joppa_2016]. The [Convention on International Trade in Endangered Species of Wild Fauna and Flora](https://www.cites.org) (CITES) provides a key dataset for conservationists, the CITES Trade Database, which is maintained by the [UN Environment World Conservation Monitoring Centre](https://www.unep-wcmc.org/). Broadly, CITES is a trade oversight mechanism which aims to limit the negative effects of overharvesting, and the CITES Trade Database represents compiled data from CITES Parties regarding the trade of wildlife or wildlife products listed under the CITES Appendices. Despite data complexities that can complicate interpretation [@Harrington_2015; @Lopes_2017; @Berec_2018; @Robinson_2018; @Eskew_2019], the CITES Trade Database remains a critically important resource for evaluating the extent and impact of the legal, international wildlife trade [@Harfoot_2018].

`citesdb` is an R package designed to support analysis of the recently released shipment-level CITES Trade Database [@tradedb]. Currently, the database contains over 40 years and 20 million records of shipments of wildlife and wildlife products subject to reporting under CITES, including individual shipment permit IDs that have been anonymized by hashing, and accompanying metadata. @Harfoot_2018 provide a recent overview of broad temporal and spatial trends in this data. To facilitate further analysis of this large dataset, the package imports the CITES Trade Database into a local, on-disk embedded database [@monetdblite]. This avoids the need for users to pre-process the data or load the multi-gigabyte dataset into memory. The MonetDB back-end allows high-performance querying and is accessible via a `DBI`- and `dplyr`-compatible interface familiar to most R users [@DBI; @dplyr]. For users of the RStudio integrated development environment [@rstudio], the package also provides an interactive pane for exploring the database and previewing data. 

# Acknowledgements

NR and EAE were funded by the generous support of the American people through the United States Agency for International Development (USAID) Emerging Pandemic Threats PREDICT project.

# References
