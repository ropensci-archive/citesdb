
<!-- README.md is generated from README.Rmd. Please edit that file -->

# citesdb

Authors: *Noam Ross, Evan Eskew, and Carlos Zambrana-Torrelio*

[![License:
MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![CircleCI](https://circleci.com/gh/ecohealthalliance/citesdb.svg?style=svg)](https://circleci.com/gh/ecohealthalliance/citesdb)
[![codecov](https://codecov.io/gh/ecohealthalliance/citesdb/branch/master/graph/badge.svg)](https://codecov.io/gh/ecohealthalliance/citesdb)
[![Project Status: WIP - Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)

**citesdb** is a package to conveniently analyze the full CITES
shipment-level wildlife trade database, available at
<https://trade.cites.org/>. This data consists of over 20 million
records of reported shipments of wildlife and wildlife products subject
to oversight under the [Convention on International Trade in Endangered
Species of Wild Fauna and Flora](https://www.cites.org).

## Installation

Install the **citesdb** package with this command:

``` r
source("https://install-github.me/ecohealthalliance/citesdb")
```

## Usage

### Getting the data

When you first load the package you will see a message like this:

    library(citesdb)
    #> Local CITES database empty or corrupt. Download with cites_db_download()

Not to worry, just do as it says and run `cites_db_download()`. This
will fetch the most recent database from online, an approximately 158 MB
download. It will expand to over 1 GB in the local database. During the
download and database building up to 3.5 GB of disk space may be used
temporarily.

### Using the database

Once you fetch the data you can connect to the database with the
`cites_db()` command. You can use the `cites_shipments()` command to
load a remote `tibble` that is backed by the database but not loaded
into R. You can use this to analyze CITES data without ever loading it
into memory, then gather your results with `collect()`. For example:

``` r
library(citesdb)
library(dplyr)
start <- Sys.time()

cites_shipments() %>%
  group_by(Year) %>%
  summarize(number = n()) %>%
  arrange(desc(Year)) %>%
  collect()
#> # A tibble: 44 x 2
#>     Year  number
#>    <int>   <dbl>
#>  1  2018    1326
#>  2  2017 1015719
#>  3  2016 1262632
#>  4  2015 1296532
#>  5  2014 1109872
#>  6  2013 1127363
#>  7  2012 1096645
#>  8  2011  950144
#>  9  2010  894011
#> 10  2009  908669
#> # … with 34 more rows

stop <- Sys.time()
```

The back-end database, [MonetDB](https://monetdb.org), is very fast and
powerful, making such analyses quite snappy even on such large data
using normal desktops and laptops. Here’s the timing of the above query,
which processes over 20 million records, on an ordinary laptop:

``` r
stop - start
#> Time difference of 1.130414 secs
```

If you are using a recent version of RStudio interactively, loading the
CITES package also brings up a browsable pane in the “Connections” tab
that lets you explore and preview the database, as well as interact with
it directly via SQL commands.

If you don’t need any of the bells and whistles of this package, you can
download the raw data as a single compressed TSV from the [releases
page](https://github.com/ecohealthalliance/citesdb/releases), or as a
`.zip` file of many CSV files from original source at
<https://trade.cites.org/>.

### Metadata

The database also contains tables of field metadata, codes used, and
CITES countries. This information comes from [“A guide to using the
CITES Trade
Database”](https://trade.cites.org/cites_trade_guidelines/en-CITES_Trade_Database_Guide.pdf),
on the CITES website. Convenience functions `cites_metadata()`,
`cites_codes()`, and `cites_parties()` access this information:

``` r
head(cites_metadata())
#> # A tibble: 6 x 2
#>   variable description                                 
#>   <chr>    <chr>                                       
#> 1 Year     year in which trade occurred                
#> 2 Appendix CITES Appendix of taxon concerned           
#> 3 Taxon    scientific name of animal or plant concerned
#> 4 Class    scientific name of animal or plant concerned
#> 5 Order    scientific name of animal or plant concerned
#> 6 Family   scientific name of animal or plant concerned

head(cites_codes())
#> # A tibble: 6 x 3
#>   field code  description  
#>   <chr> <chr> <chr>        
#> 1 Term  BAL   Baleen       
#> 2 Term  BAR   Bark         
#> 3 Term  BEL   Belts        
#> 4 Term  BOC   Bone carvings
#> 5 Term  BOD   Bodies       
#> 6 Term  BON   Bones
```

More information on the release of shipment-level data can be found in
the `?guidance` help file.

### Contributing

Want have feedback or want to contribute? Great\! Please take a look at
the [contributing
guidelines](https://github.com/ecohealthalliance/citesdb/blob/master/.github/CONTRIBUTING.md)
before filing an issue or pull request.

Please note that this project is released with a [Contributor Code of
Conduct](https://github.com/ecohealthalliance/citesdb/blob/master/.github/CODE_OF_CONDUCT.md).
By participating in this project you agree to abide by its terms.

[![Created by EcoHealth
Alliance](https://github.com/ecohealthalliance/citesdb/blob/master/inst/img/eha-footer.png)](https://www.ecohealthalliance.org/)
