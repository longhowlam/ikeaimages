library(keras)
library(text2vec)
library(stringr)
library(dplyr)
library(futile.logger)
library(purrr)

vgg16_notop = keras::application_vgg16(weights = 'imagenet', include_top = FALSE)
vgg19_notop = keras::application_vgg19(weights = 'imagenet', include_top = FALSE)

#########################################################################################################

### extract features from scraped ikea images that are in a data frame

ikeadinegn = list(
  keuken, stoel, boekenkast, 
  keuken, zitbank, bestek, 
  pannen, tafel, kussen,
  eten, verlichting, woonacc,
  badkamer, tuin, speelgoed, bureau
)

vgg16_ExtractionResults = purrr::map(ikeadinegn, ExtractFeatures)

###### combine everything #####################################################  

# Combineer data sets
allImages = purrr::map_df(vgg16_ExtractionResults, function(x)x[[2]])

# Combineer MATRICES

tmp = purrr::map(vgg16_ExtractionResults, function(x)x[[1]])
ikeafeaturesVGG16 = vgg16_ExtractionResults[[1]][[1]]
for(i in 2:length(ikeadinegn))
{
  ikeafeaturesVGG16 = rbind(
    ikeafeaturesVGG16,
    vgg16_ExtractionResults[[i]][[1]]
  )
}
dim(ikeafeaturesVGG16)

saveRDS(ikeafeaturesVGG16, "ikeafeauturesVGG16.RDs")
saveRDS(allImages, "Allimages.RDs")




######  helper function ################################################################################

## import pretrained model without the fully connected top layers
ExtractFeatures = function(allImages)
{
  
  N = dim(allImages)[1]
  flog.info("start feature extraction for %s images in dataset", N)
  
  allImages$remove = FALSE
  
  pb <- txtProgressBar(style=3)
  for(i in 1:N)
  {
    imgf = paste0("images/", allImages$imagefile[i])
    if(file.exists(imgf))
    {
      img = image_load(
        imgf,
        target_size = c(224,224)
      )
      x = image_to_array(img)
      
      dim(x) <- c(1, dim(x))
      x = imagenet_preprocess_input(x)
      
      # extract features
      features = vgg16_notop %>% predict(x)
      f1 = as.numeric(features)
      if(i==1){
        M1 <- as(matrix(f1, ncol = length(f1)), "dgCMatrix")
      }
      else{
        M1 = rbind(M1, f1)
      }
    }
    else
    {
      allImages$remove[i] = TRUE
    }
    setTxtProgressBar(pb, i/N)
  }
  close(pb)
  
  allImages2 = allImages[!allImages$remove,]
  flog.info("dimension featurematrix, %s", dim(M1)[1])
  flog.info("images processed, %s", dim(allImages2)[1])
  
  list(M1, allImages2)
}

