% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/nhpp_functions.R
\name{path_hamming_over_trees_KDE}
\alias{path_hamming_over_trees_KDE}
\title{Hamming distances for a list of trees}
\usage{
path_hamming_over_trees_KDE(tree.list)
}
\arguments{
\item{tree.list}{multiSimmap object.}
}
\value{
A tibble with information on state changes, time spent on each state, edge IDs, absolute and normalized hamming distances for all edges and all trees in a list.
}
\description{
Calculates hamming distances for all paths in each discretized tree of a list.
}
\examples{
data("hym_stm_amalg")
# Get ten samples of stochastic maps from head.
tree_list <- hym_stm_amalg$head[1:10]
tree_list <- merge_tree_cat_list(tree_list)
\donttest{

  # Calculate hamming distances.
  ph <- suppressWarnings(path_hamming_over_trees_KDE(tree_list))
  ph

}

}
\author{
Sergei Tarasov
}
