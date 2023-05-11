
<!-- README.md is generated from README.Rmd. Please edit that file -->

# citesdb

Authors: *Noam Ross, Evan A. Eskew and Mauricio Vargas*

<!-- badges: start -->

[![License:
MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![rOpensci\_Badge](https://badges.ropensci.org/292_status.svg)](https://github.com/ropensci/software-review/issues/292)
[![Published in the Journal of Open Source
Software](http://joss.theoj.org/papers/10.21105/joss.01483/status.svg)](https://doi.org/10.21105/joss.01483)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.2630836.svg)](https://doi.org/10.5281/zenodo.2630836)
[![CircleCI](https://circleci.com/gh/ropensci/citesdb/tree/master.svg?style=shield)](https://circleci.com/gh/ropensci/citesdb)
[![codecov](https://codecov.io/gh/ropensci/citesdb/branch/master/graph/badge.svg)](https://codecov.io/gh/ropensci/citesdb)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

<!-- badges: end -->

**citesdb** is an R package to conveniently analyze the full CITES
shipment-level wildlife trade database, available at
<https://trade.cites.org/>. This data consists of over 40 years and 20
million records of reported shipments of wildlife and wildlife products
subject to oversight under the [Convention on International Trade in
Endangered Species of Wild Fauna and Flora](https://www.cites.org). The
source data are maintained by the [UN Environment World Conservation
Monitoring Centre](https://www.unep-wcmc.org/).

## Installation

Install the **citesdb** package with this command:

``` r
devtools::install_github("ropensci/citesdb")
```

Note that since **citesdb** installs a source dependency from GitHub,
you will need [package build
tools](http://stat545.com/packages01_system-prep.html).

## Usage

### Getting the data

When you first load the package, you will see a message like this:

    library(citesdb)
    #> Local CITES database empty or corrupt. Download with cites_db_download()

Not to worry, just do as it says and run `cites_db_download()`. This
will fetch the most recent database from online, an approximately 158 MB
download. It will expand to over 1 GB in the local database. During the
download and database building, up to 3.5 GB of disk space may be used
temporarily.

### Using the database

Once you fetch the data, you can connect to the database with the
`cites_db()` command. The `cites_shipments()` command loads a remote
`tibble` that is backed by the database but is not loaded into R. You
can use this command to analyze CITES data without ever loading it into
memory, gathering your results with the `dplyr` function `collect()`.
For example:

``` r
library(citesdb)
library(dplyr)

start <- Sys.time()

cites_shipments() %>%
  group_by(Year) %>%
  summarize(n_records = n()) %>%
  arrange(desc(Year)) %>%
  collect()
#> # A tibble: 45 x 2
#>     Year n_records
#>    <int>     <dbl>
#>  1  2019     12610
#>  2  2018   1143044
#>  3  2017   1246684
#>  4  2016   1293178
#>  5  2015   1299183
#>  6  2014   1109877
#>  7  2013   1127377
#>  8  2012   1096664
#>  9  2011    950148
#> 10  2010    894115
#> # … with 35 more rows

stop <- Sys.time()
```

(*Note that running `collect()` on all of `cites_shipments()` will load
a \>3 GB data frame into memory\!*)

The back-end database, [duckdb](https://duckdb.org/), is very fast and
powerful, making analyses on such large data quite snappy using normal
desktops and laptops. Here’s the timing of the above query, which
processes over 20 million records:

``` r
stop - start
#> Time difference of 0.4658868 secs
```

If you are using a recent version of RStudio interactively, loading the
CITES package also brings up a browsable pane in the “Connections” tab
that lets you explore and preview the database, as well as interact with
it directly via SQL commands.

If you don’t need any of the bells and whistles of this package, you can
download the raw data as a single compressed TSV file from the [releases
page](https://github.com/ropensci/citesdb/releases), or as a `.zip` file
of many CSV files from the original source at
<https://trade.cites.org/>.

### Metadata

The package database also contains tables of field metadata, codes used,
and CITES countries. This information comes from [“A guide to using the
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
#>   field   code  description                                    
#>   <chr>   <chr> <chr>                                          
#> 1 Purpose B     Breeding in captivity or artificial propagation
#> 2 Purpose E     Educational                                    
#> 3 Purpose G     Botanical garden                               
#> 4 Purpose H     Hunting trophy                                 
#> 5 Purpose L     Law enforcement / judicial / forensic          
#> 6 Purpose M     Medical (including biomedical research)

head(cites_parties())
#> # A tibble: 6 x 6
#>   country        code  former_code non_ISO_code date       data_source                                                  
#>   <chr>          <chr> <lgl>       <lgl>        <chr>      <chr>                                                        
#> 1 Afghanistan    AF    FALSE       FALSE        1986-01-28 'A guide to using the CITES Trade Database', Version 8, Anne…
#> 2 Africa         XF    FALSE       TRUE         <NA>       'A guide to using the CITES Trade Database', Version 8, Anne…
#> 3 Åland Islands  AX    FALSE       FALSE        <NA>       'A guide to using the CITES Trade Database', Version 8, Anne…
#> 4 Albania        AL    FALSE       FALSE        2003-09-25 'A guide to using the CITES Trade Database', Version 8, Anne…
#> 5 Algeria        DZ    FALSE       FALSE        1984-02-21 'A guide to using the CITES Trade Database', Version 8, Anne…
#> 6 American Samoa AS    FALSE       FALSE        <NA>       'A guide to using the CITES Trade Database', Version 8, Anne…
```

More information on the release of shipment-level CITES data can be
found in the `?guidance` help file.

## Related work

The [**rcites**](https://github.com/ropensci/rcites) package provides
access to the Speciesplus/CITES Checklist API, which includes metadata
about species and their protected status through time.

## Citation

If you use **citesdb** in a publication, please cite both the package
and source data:

Ross, Noam, Evan A. Eskew, and Nicolas Ray. 2019. citesdb: An R package
to support analysis of CITES Trade Database shipment-level data. Journal
of Open Source Software, 4(37), 1483,
<https://doi.org/10.21105/joss.01483>

UNEP-WCMC (Comps.) 2019. Full CITES Trade Database Download. Version
2019.2. CITES Secretariat, Geneva, Switzerland. Compiled by UNEP-WCMC,
Cambridge, UK. Available at: <https://trade.cites.org>.

## Contributing

Have feedback or want to contribute? Great\! Please take a look at the
[contributing
guidelines](https://github.com/ropensci/citesdb/blob/master/.github/CONTRIBUTING.md)
before filing an issue or pull request.

Please note that this project is released with a [Contributor Code of
Conduct](https://github.com/ropensci/citesdb/blob/master/.github/CODE_OF_CONDUCT.md).
By participating in this project you agree to abide by its terms.

[![Created by EcoHealth
Alliance](https://raw.githubusercontent.com/ropensci/citesdb/master/vignettes/figures/eha-footer.png)](https://www.ecohealthalliance.org/)
