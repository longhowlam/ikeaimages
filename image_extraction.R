library(rvest)
library(stringr)
library(dplyr)
library(futile.logger)

##############################################################################################
## Op product categorieen

#### twee persoons bedden ########
mainlink = "http://www.ikea.com/nl/nl/catalog/categories/departments/bedroom/16284/"
bedden = extractImage(mainlink)

#########  Bureaus ###############
mainlink = "http://www.ikea.com/nl/nl/catalog/categories/departments/workspaces/20649/"
bureaus = extractImage(mainlink)

####### Boeken kasten ############
mainlink = "http://www.ikea.com/nl/nl/catalog/categories/departments/living_room/10382/"
boekenkasten = extractImage(mainlink)


######### combine ##################

allImages = bind_rows(bedden, bureaus, boekenkasten)
saveRDS(allImages, "AllImages.RDs")




###############################################################################
######  op zoekpaginas scrapen #########################

stoel = searchIkea("stoel")
bed = searchIkea("bed")
boekenkast = searchIkea("boekenkast")
keuken = searchIkea("keuken")

allImages = bind_rows(
  stoel,
  bed,
  boekenkast,
  keuken
)

saveRDS(allImages, "AllImages.RDs")





##########  helper functions ####################################################

### function to retrive images from products that resulted on the IKEA search

searchIkea = function(query){

  #### first retrieve N pages on the first page 
  baselink = paste0(
    "http://www.ikea.com/nl/nl/search/?query=",
    query ,
    "&pageNumber="
  )
  firstpagelink = paste0(baselink , "1")
  
  flog.info("SEARCH %s", firstpagelink)
  out = read_html(firstpagelink)
  tmp =  html_nodes(out, xpath = '//a/@href') %>% html_text()
  pages = tmp[stringr::str_detect(tmp, "pageNumber")]

  NPAGES = pages %>% str_extract("\\d+") %>% as.numeric() %>% max()

  flog.info("npages %s", NPAGES)
  
  flog.info("loop over pages")
  #### loop over the search pages 
  if(NPAGES > 0){
  iter = 1:NPAGES
  purrr::map_df(iter, searchIkeaOnePage, baselink, query)
  }
}


searchIkeaOnePage = function(iter, baselink, query)
{
  link = paste0(baselink,iter)
  out = read_html(link)
  
  lijst =  html_nodes(out, xpath = '//a/@href') %>% html_text()
  producten = str_detect(lijst , "catalog/products")
  bvtab = str_detect(lijst , "bvtab")
  geldigeproductlinks = lijst[producten & !bvtab]
  
  outframe = data.frame()
  for( j in 1:length(geldigeproductlinks))
  {
    link = paste0("http://www.ikea.com/", geldigeproductlinks[j])
    out = read_html(link)
    type = query
    
    zz = 
    img = html_nodes(
      out,
      xpath = '//img[@id="productImg"]/@src'
    ) %>% 
      html_text()
    
    imagefile = str_sub(img,24,str_length(img))
    
    tryCatch(
      download.file(
        paste0("http://www.ikea.com", img),
        destfile = paste0("images/", imagefile),
        quiet = TRUE
      ),
      error=function(e)  flog.error("No such file")
    )
    
    outframe = bind_rows(
      outframe, 
      data.frame(link,type,imagefile, stringsAsFactors = FALSE)
    )
  }
  flog.info("search page %s processed", iter)
  outframe
}


fout = "http://www.ikea.com/nl/nl/images/products/norsborg-chaise-longue-element-grijs__0543521_PE654613_S4.JPG"
tryCatch(
  download.file(fout, destfile = "PPP.JPG", quiet = TRUE),
  error=function(e)  flog.error("No such file")
)
 

#### given a main product page, extract images ##########

extractImage = function(mainlink)
{
  out = read_html(mainlink)
  zz = '//a[@class="productLink"]/@href'
  href = html_nodes(out,xpath = zz) %>% html_text
  
  outframe = data.frame()
  for( i in 1:length(href))
  {
    link = paste0("http://www.ikea.com/", href[i])
    out = read_html(link)
    type = mainlink
  
    zz = '//img[@id="productImg"]/@src'
    img = html_nodes(out,xpath = zz) %>% html_text()
    imagefile = str_sub(img,24,str_length(img))
    download.file(
      paste0("http://www.ikea.com", img),
      destfile = paste0("images/", imagefile)
    )
  
    outframe = bind_rows(
      outframe, 
      data.frame(link,type,imagefile, stringsAsFactors = FALSE)
    )
  }
  outframe
}


