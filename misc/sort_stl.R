
library(Matrix)
library(Rcpp)
library(RcppEigen)
library(doParallel)
library(itertools)
library(tidyverse)

num_of_cores <- detectCores()
cl <- makePSOCKcluster(num_of_cores)
registerDoParallel(cl)

#######################
# Create Spark Matrix #
#######################

# sample similarity matrix
sparse_mat <- rsparsematrix(15000, 15000, .01)
sparse_mat2 <- cbind(sparse_mat, sparse_mat, sparse_mat, sparse_mat, sparse_mat)
sparse_mat2 <- rbind(sparse_mat, sparse_mat, sparse_mat, sparse_mat, sparse_mat)

f <- function(sp_mat, by_cols, threshold) {
  by_cols <- "nm"
  spMat_dgT <- as(sp_mat, "dgTMatrix")
  
  idx <- spMat_dgT@x <= threshold
  
  spMat_dgT@i <- spMat_dgT@i[!idx]
  spMat_dgT@j <- spMat_dgT@j[!idx]
  spMat_dgT@x <- spMat_dgT@x[!idx]
  
  df <- tibble::tibble(nm = sample(letters, nrow(sparse_mat), replace = T)) %>%
    mutate(row_id = row_number())
  
  df_copy <- df
  colnames(df_copy) <- c("original_nm", "original_row_idx")
  
  # mutate df
  df[spMat_dgT@j + 1, by_cols] <- df[spMat_dgT@i+1, by_cols]
  df[spMat_dgT@j + 1, 'row_id'] <- df[spMat_dgT@i + 1, 'row_id']
  
  colnames(df) <- c("new_nm", "new_row_idx")
  
  out <- bind_cols(df_copy, df)
  
  return(out)
  
}

test <- f(sparse_mat, "nm", 3)
system.time(f(sparse_mat, "nm", 3))

test %>% 
  filter(original_row_idx != new_row_idx)
