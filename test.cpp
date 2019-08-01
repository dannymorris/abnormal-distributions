// [[Rcpp::depends(RcppEigen)]]
#include <RcppEigen.h>
using namespace Rcpp;
typedef Eigen::MappedSparseMatrix<double> MSpMat;
typedef MSpMat::InnerIterator InIterMat;
typedef Eigen::SparseVector<double> SpVec;
typedef SpVec::InnerIterator InIterVec;

// [[Rcpp::export]]
void mat_loop2 (MSpMat X, int j){
  for (InIterMat i_(X, j); i_; ++i_) {
    Rcout << i_.index() << j << " value" << i_.value() << std::endl;
  }
}

// [[Rcpp::export]]
NumericVector stl_sort(NumericVector x) {
  NumericVector y = clone(x);
  std::sort(y.begin(), y.end());
  return y;
}