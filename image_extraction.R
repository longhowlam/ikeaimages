 
library(rvest)

## twee persoons bedden
out = read_html("http://www.ikea.com/nl/nl/catalog/categories/departments/bedroom/16284/")
zz = '//img[@class=" center-x"]/@src'
images = html_nodes(out,xpath = zz) %>% html_text()

zz = '//a[@class="link-block center-x "]/@href'
href = html_nodes(out,xpath = zz) %>% html_text()

download.file(images[1], destfile = "ppp.JPG")

##grote file staat in de product pagina zelf
## we moeten door de href heen loopen

out = read_html(paste0("http://www.ikea.com/", href[1]))
zz = '//img[@id="productImg"]/@src'
img = html_nodes(out,xpath = zz) %>% html_text()
download.file(paste0("http://www.ikea.com/",img[1]), destfile = "PPP.JPG")
              