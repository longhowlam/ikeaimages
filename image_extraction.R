# devtools::install_github("longhowlam/ikeaScraper")

library(rvest)
library(stringr)
library(dplyr)
library(futile.logger)
library(IkeaScraper)

###############################################################################
######  Ikea serach page scrapn ###############################################

bed = searchIkea("bed")
stoel = searchIkea("stoel")
boekenkast = searchIkea("boekenkast")
keuken = searchIkea("keuken")
zitbank = searchIkea("zitbank")
bestek = searchIkea("bestek")
pannen = searchIkea("pannen")
tafel = searchIkea("tafel")
kussen = searchIkea("kussen")
eten = searchIkea("eten")
verlichting = searchIkea("verlichting")
woonacc = searchIkea("woonaccessoires")
badkamer = searchIkea("badkamer")
tuin = searchIkea("tuin")
speelgoed = searchIkea("speelgoed")
bureau = searchIkea("bureau")


