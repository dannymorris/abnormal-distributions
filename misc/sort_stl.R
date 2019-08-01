
library(Matrix)
library(Rcpp)
library(RcppEigen)

mat <- matrix(rep(0, 15), ncol = 3)

mat[1, 1] <- 4L
mat[2, 2] <- 7L
mat[2, 2] <- 5L
mat[3, 3] <- 8L
mat[3, 2] <- 16L
mat[3, 1] <- 1L

sparse_mat <- as(mat, "dgCMatrix")

mat_loop2(sparse_mat, 1)

lapply(sparse_mat, print)

apply(sparse_mat, 2, mat_loop2)

d <- diff(sparse_mat@p)
colInd <- rep.int(1:ncol(sparse_mat), d)
ss <- split(sparse_mat@x, colInd)
sapply(ss, stl_sort)

// [[Rcpp::export]]
NumericVector stl_sort(NumericVector x) {
  NumericVector y = clone(x);
  std::sort(y.begin(), y.end());
  return y;
}