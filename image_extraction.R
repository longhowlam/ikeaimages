library(rvest)
library(stringr)
library(dplyr)

#### twee persoons bedden #####################################################################
link = "http://www.ikea.com/nl/nl/catalog/categories/departments/bedroom/16284/"
out = read_html(link)
zz = '//a[@class="productLink"]/@href'
productLinks = html_nodes(out,xpath = zz) %>% html_text
bedden = extractImage(productLinks, soort = "bedden")



#########  Bureaus #####################################################################

link = "http://www.ikea.com/nl/nl/catalog/categories/departments/workspaces/20649/"
out = read_html(link)
zz = '//a[@class="productLink"]/@href'
productLinks = html_nodes(out,xpath = zz) %>% html_text
bureaus = extractImage(productLinks, soort = "bureaus")






##########  helper function ####################################################

extractImage = function(href, soort)
{
  outframe = data.frame()
  for( i in 1:length(href))
  {
    link = paste0("http://www.ikea.com/", href[i])
    out = read_html(link)
    type = soort
  
    zz = '//img[@id="productImg"]/@src'
    img = html_nodes(out,xpath = zz) %>% html_text()
    imagefile = str_sub(img,24,str_length(img))
    download.file(
      paste0("http://www.ikea.com", img),
      destfile = paste0("images/", imagefile)
    )
  
    outframe = bind_rows(outframe, data.frame(link,type,imagefile))
  }
  outframe
}


