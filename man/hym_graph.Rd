% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ontophylo_data.R
\docType{data}
\name{hym_graph}
\alias{hym_graph}
\title{Hymenoptera graphics information}
\format{
A data table with three columns; "Term" contains the ontology term labels (e.g., "cranium", "antenna");
"ID" contains the respective ontology term ids from the HAO ontology (e.g., "HAO:0000234", "HAO:0000101");
"pic_id" contains the layer ids of the corresponding anatomical entities in the vector image of a hymenopteran wasp.
}
\usage{
hym_graph
}
\description{
Example of annotations of anatomy terms from the Hymenoptera Anatomy Ontology (HAO)
to layers representing anatomical entities in a vector image of a hymenopteran wasp.
This data object is used to run the examples of the ontophyo package.
}
\examples{
data(hym_graph)
}
\keyword{datasets}
