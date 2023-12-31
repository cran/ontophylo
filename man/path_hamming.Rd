% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/nhpp_functions.R
\name{path_hamming}
\alias{path_hamming}
\title{Path hamming}
\usage{
path_hamming(Path)
}
\arguments{
\item{Path}{data.frame. A tibble with state information about a given path (from root to a given node).
The tibble is the output obtained from the get_states_path function. The columns give information on state changes, time spent on each state, and edge IDs.}
}
\value{
The input tibble with two additional columns giving information on absolute and normalized hamming distances.
}
\description{
Calculates the hamming distance between states for a given path.
}
\author{
Sergei Tarasov

Internal function. Not exported.
}
