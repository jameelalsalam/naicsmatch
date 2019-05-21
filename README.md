
<!-- README.md is generated from README.Rmd. Please edit that file -->

# naicsmatch

<!-- badges: start -->

<!-- badges: end -->

The goal of naicsmatch is to provide functions and crosswalks from and
between NAICS sector codes

The North American Industry Classification system is the standard used
by Federal statistical agencies in classifying businesses for the
purposes of data collection, analysis, and publishing statistical data.
[see here](https://www.census.gov/eos/www/naics/index.html)

The NAICS code classification system is regularly updated, and so
translating between different iterations can be necessary to do
comparisons between different data sources. This package provides some
functions to automate some of these translations using concordances
downloaded from the U.S. Census and other agencies and data sources.

References:

  - [NAICS
    Concordances](https://www.census.gov/eos/www/naics/concordances/concordances.html)

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("jameelalsalam/naicsmatch")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(tidyverse)
#> -- Attaching packages ---------------------------------- tidyverse 1.2.1 --
#> v ggplot2 3.1.1       v purrr   0.3.2  
#> v tibble  2.1.1       v dplyr   0.8.0.1
#> v tidyr   0.8.3       v stringr 1.4.0  
#> v readr   1.3.1       v forcats 0.4.0
#> -- Conflicts ------------------------------------- tidyverse_conflicts() --
#> x dplyr::filter() masks stats::filter()
#> x dplyr::lag()    masks stats::lag()
library(naicsmatch)

sum(ex_asm$vos)
#> [1] 19877492

ex_asm
#> # A tibble: 6 x 3
#>   NAICS.id `NAICS.display-label`                                     vos
#>   <chr>    <chr>                                                   <dbl>
#> 1 311830   Tortilla manufacturing                                3157424
#> 2 333315   Photographic and photocopying equipment manufacturing 1975217
#> 3 333512   Machine tool (metal cutting types) manufacturing      3473464
#> 4 333513   Machine tool (metal forming types) manufacturing      1217675
#> 5 334113   Computer terminal manufacturing                        467003
#> 6 334119   Other computer peripheral equipment manufacturing     9586709
## basic example code
```

``` r

library(tidyverse)

naics_2007_2012
#> # A tibble: 1,184 x 2
#>    naics_2007 naics_2012
#>    <chr>      <chr>     
#>  1 111110     111110    
#>  2 111120     111120    
#>  3 111130     111130    
#>  4 111140     111140    
#>  5 111150     111150    
#>  6 111160     111160    
#>  7 111191     111191    
#>  8 111199     111199    
#>  9 111211     111211    
#> 10 111219     111219    
#> # ... with 1,174 more rows
```

``` r
asm_2012 <- ex_asm %>% left_join(naics_2007_2012, 
                     by = c("NAICS.id" = "naics_2007"))

sum(asm_2012$vos)
#> [1] 29464201

asm_2012
#> # A tibble: 7 x 4
#>   NAICS.id `NAICS.display-label`                             vos naics_2012
#>   <chr>    <chr>                                           <dbl> <chr>     
#> 1 311830   Tortilla manufacturing                         3.16e6 311830    
#> 2 333315   Photographic and photocopying equipment manuf~ 1.98e6 333316    
#> 3 333512   Machine tool (metal cutting types) manufactur~ 3.47e6 333517    
#> 4 333513   Machine tool (metal forming types) manufactur~ 1.22e6 333517    
#> 5 334113   Computer terminal manufacturing                4.67e5 334118    
#> 6 334119   Other computer peripheral equipment manufactu~ 9.59e6 333316    
#> 7 334119   Other computer peripheral equipment manufactu~ 9.59e6 334118
```

# Weighting

``` r
naics_2007_2012_wgt <- naics_2007_2012 %>%
  group_by(naics_2007) %>%
  summarize(wgt = 1 / n())

filter(naics_2007_2012_wgt, wgt != 1)
#> # A tibble: 6 x 2
#>   naics_2007   wgt
#>   <chr>      <dbl>
#> 1 221119       0.2
#> 2 238190       0.5
#> 3 238330       0.5
#> 4 334119       0.5
#> 5 423620       0.5
#> 6 423720       0.5
```

``` r
asm_2012_v2 <- asm_2012 %>%
  left_join(naics_2007_2012_wgt, 
            by = c("NAICS.id" = "naics_2007")) %>%
  mutate(vos = vos * wgt)

sum(asm_2012_v2$vos)
#> [1] 19877492

asm_2012_v2
#> # A tibble: 7 x 5
#>   NAICS.id `NAICS.display-label`                       vos naics_2012   wgt
#>   <chr>    <chr>                                     <dbl> <chr>      <dbl>
#> 1 311830   Tortilla manufacturing                   3.16e6 311830       1  
#> 2 333315   Photographic and photocopying equipmen~  1.98e6 333316       1  
#> 3 333512   Machine tool (metal cutting types) man~  3.47e6 333517       1  
#> 4 333513   Machine tool (metal forming types) man~  1.22e6 333517       1  
#> 5 334113   Computer terminal manufacturing          4.67e5 334118       1  
#> 6 334119   Other computer peripheral equipment ma~  4.79e6 333316       0.5
#> 7 334119   Other computer peripheral equipment ma~  4.79e6 334118       0.5
```

# Aggregation

``` r

asm_2012_v3 <- asm_2012_v2 %>%
  group_by(naics_2012) %>%
  summarize(vos = sum(vos, na.rm = TRUE))

sum(asm_2012_v3$vos)
#> [1] 19877492

asm_2012_v3
#> # A tibble: 4 x 2
#>   naics_2012      vos
#>   <chr>         <dbl>
#> 1 311830     3157424 
#> 2 333316     6768572.
#> 3 333517     4691139 
#> 4 334118     5260358.
```
