% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/EPDr-classes.R
\docType{class}
\name{site-class}
\alias{site-class}
\alias{site}
\title{Class for Site of an entity}
\description{
Class \code{site} stores all information relative to site where samples were
taken and to which a specified entity of the European Pollen Database
(EPD) belong to. This object is created by \code{\link[EPDr]{get_site}}.
}
\section{Slots}{

\describe{
\item{\code{siteloc}}{data.frame Information on the location (e.g. geographical
coordinates) for the site.}

\item{\code{sitedesc}}{data.frame Description of the site in terms of vegetation
and orography.}

\item{\code{siteinfo}}{data.frame This table summarize the information available
for that site (e.g. C14, pollen, insects, etc.)}

\item{\code{country}}{data.frame Country to which the site belong to.}

\item{\code{region}}{data.frame Regions to which the site belong to.}

\item{\code{region3rd}}{data.frame 3rd level regions to which the site belong to.}

\item{\code{igcptype}}{data.frame IGCP regions to which the site belong to.}

\item{\code{infotype}}{data.frame This table provide a longer description of the
information summarized in \code{@siteinfo}}

\item{\code{publ}}{data.frame PUBL data where the data were published}
}}

