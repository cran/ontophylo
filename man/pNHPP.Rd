% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/nhpp_functions.R
\name{pNHPP}
\alias{pNHPP}
\title{Phylogenetic Non-Homogeneous Poisson Process (pNHPP) method}
\usage{
pNHPP(
  stm_amalg,
  tree = tree,
  res = res,
  add.psd = TRUE,
  band.width = c("bw.nrd0", "bw.nrd0", "bw.ucv", "bw.bcv", "bw.SJ"),
  lambda.post.stat = "Mean"
)
}
\arguments{
\item{stm_amalg}{multiSimmap object. A list of amalgamated stochastic maps.}

\item{tree}{simmap or phylo object. A reference tree for discretization.}

\item{res}{integer. A resolution value for the discretization of tree edges.}

\item{add.psd}{logical. Whether to add pseudodata or not in the 'make_data_NHPP_KDE_Markov_kernel' function. Default is TRUE.}

\item{band.width}{character. Bandwidth selectors for the KDE in the 'estimate_band_W' function.}

\item{lambda.post.stat}{character. A value with the statistic to be used in the 'make_postPois_KDE' function.}
}
\value{
A list with the estimated Markov KDE for all edges, the contMap object for plotting the NHPP, and the information necessary for making the edgeplot.
}
\description{
Wrapper function for applying the pNHPP method.
}
\examples{
\donttest{

  # Load data.
  data("hym_stm", "hym_stm_amalg")
  # Get a reference tree for discretization.
  tree <- hym_stm[[1]][[1]]
  # Get ten samples of stochastic maps from head.
  tree_list <- hym_stm_amalg$head[1:10]
  # Run the pNHPP method.
  nhpp_test <- pNHPP(tree_list, tree, res = 500,
  add.psd = TRUE, band.width = 'bw.nrd', lambda.post.stat = 'Mean')

}

}
\author{
Diego Porto
}
