---
title: 'citesdb: An R package to support analysis of CITES shipment data'
tags:
  - R
  - database
  - wildlife
  - trade
authors:
 - name: Noam Ross
   orcid: 0000-0002-2136-0000
   affiliation:
    - 1
 - name: Evan Eskew
   orcid: 0000-0002-1153-5356
   affiliation:
    - 1
affiliations:
 - name: EcoHealth Alliance, 460 W 34th St. Suite 1701, New York, NY 10001
   index: 1
date: 18 March 2019
bibliography: paper.bib
---

# Summary

`citesdb` is an R package to support analysis of shipments in the trade database of the [Convention on International Trade in Endangered Species of Wild Fauna and Flora](https://www.cites.org) [@tradedb].  The database contains 44 years and over 20 million records of shipments of wildlife and wildlife products subject to reporting under the treaty, including individual shipment permit IDs that have been anonymized by hashing. To facilitate analysis of this large data set, the package imports the data into a local on-disk MonetDB database [@monetdblite].  This avoids the need for users to pre-process the data or load the multi-gigabyte data into RAM.  The MonetDB back-end allows a high-performance querying, and is accessible via a `DBI`- and `dplyr`-compatible interface familiar to most R users [@DBI, @dplyr]. For users of the RStudio IDE [@rstudio], the package also provides an interactive pane for exploring the database and previewing data. 

# References
