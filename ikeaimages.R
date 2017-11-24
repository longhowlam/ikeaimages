library(keras)
library(text2vec)
library(stringr)

## import pretrained model without the fully connected top layers
vgg16_notop = application_vgg16(weights = 'imagenet', include_top = FALSE)


### Some brad pitt images
i=1
for(i in 1:5)
{
  img = image_load(
    paste0("images/bp0", i,".jpg"), target_size = c(224,224)
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



ff = list.files("images")
IM = ff[str_detect(ff,glob2rx("IM*"))]

for(i in 1:length(IM))
{
  img = image_load( paste0("images/", IM[i]), target_size = c(224,224))
  x = image_to_array(img)
  
  dim(x) <- c(1, dim(x))
  x = imagenet_preprocess_input(x)
  
  # extract features
  features = vgg16_notop %>% predict(x)
  f1 = as.numeric(features)
  if( i==1 ){
    M2 <- as(matrix(f1, ncol = length(f1)), "dgCMatrix")
  }else{
    M2 = rbind(M2, f1)
  }
}



afstanden = text2vec::dist2(M2,M1)
rowMeans(as.matrix(afstanden))

saveRDS(M1, "bradmatrix.RDs")

