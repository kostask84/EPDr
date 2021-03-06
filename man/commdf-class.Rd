% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/EPDr-classes.R
\docType{class}
\name{commdf-class}
\alias{commdf-class}
\alias{commdf}
\title{Class for commdf objects}
\description{
This object stores information regarding the particles counts
in each biological sample of an entity but in vector or table 
format rather than the original format in the EPD database. 
Note, however, that data here comes from the table 
\code{SAMPLES} from the database or an 
\code{\link[EPDr]{epd.entity-class}} object. Contrary to data 
in \code{\link[EPDr]{epd.entity-class}} objects, this are 
intended to be manipulated and modified if necessary.
}
\section{Slots}{

\describe{
\item{\code{taxanames}}{character. Names of the taxa included in the object.}

\item{\code{taxa_}}{numeric. Identification numbers of the taxa.}

\item{\code{taxaaccepted}}{numeric. Identification numbers for the accepted taxa. 
This is useful to unify taxonomy across entities from different authors,
that may have used slightly different taxa names.}

\item{\code{taxamhvar}}{numeric. Identification numbers for the higher taxa levels
of each taxa. This is the only taxonomical hierarchy that is available
in the EPD. The approach is useful, but also very limited, since there 
is no intuitive way to homogenize the data at certain taxonomical level
(e.g., at the genus level).}

\item{\code{taxagroupid}}{character. Identify code (four characters code) 
indicating the group of taxa (e.g., TRSH for trees and shrubs or
HERB for herbs). Check \code{\link[EPDr]{list_taxagroups}} 
for the whole list and further details.}

\item{\code{counts}}{data.frame. Particles counts in a matrix format (sample 
x taxa). This format is more intuitive and handy for biologist 
(ecologist or palynologist) than the original format.}
}}

