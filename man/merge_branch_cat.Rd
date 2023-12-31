% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/paramo_functions.R
\name{merge_branch_cat}
\alias{merge_branch_cat}
\title{Merge state bins over branch}
\usage{
merge_branch_cat(br)
}
\arguments{
\item{br}{numeric or character vector. The branches of the tree.}
}
\value{
A numeric or character vector with merged identical bins.
}
\description{
Merges identical state bins over the same branch in the discretized stochastic map.
}
\examples{
data("hym_stm")
tree <- hym_stm[[1]][[1]]
stm_discr <- discr_Simmap(tree, res = 100)
# Check some arbitrary branch.
br1 <- stm_discr$maps[[5]]
br1
br2 <- merge_branch_cat(br1)
br2
sum(br1) == br2

}
\author{
Sergei Tarasov
}
