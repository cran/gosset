% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/worth_map.R
\name{worth_map}
\alias{worth_map}
\alias{worth_map.default}
\alias{worth_map.list}
\alias{worth_bar}
\title{Plot worth parameters}
\usage{
worth_map(object, ...)

\method{worth_map}{default}(object, ...)

\method{worth_map}{list}(object, labels, ...)

worth_bar(object, ...)
}
\arguments{
\item{object}{an object of class \code{party} or 
an object of class \code{PlackettLuce} or
a list objects of class \code{PlackettLuce}}

\item{...}{additional arguments passed to methods}

\item{labels}{a vector with the name of models in \var{object}}
}
\description{
Produces plots to highlight worth
 coefficients of items in a party tree of 
 a list of PlackettLuce models
}
\examples{
library("psychotree")
library("PlackettLuce")
data("Topmodel2007", package = "psychotree")
R = as.grouped_rankings(Topmodel2007$preference)

tm_tree = pltree(R ~ ., data = Topmodel2007[, -1], 
                  minsize = 5,
                  npseudo = 0)

worth_map(tm_tree)

##########################################

# Ranking of preference on four fruits 
# based on traits taste, texture, 
# price and storability

# taste
R1 = matrix(c(1, 2, 3, 4,
               4, 1, 3, 2,
               4, 1, 2, 3,
               1, 2, 0, 3), nrow = 4, byrow = TRUE)
colnames(R1) = c("apple", "banana", "orange", "pear")
mod1 = PlackettLuce(R1)

# texture
R2 = matrix(c(1, 4, 2, 3,
               1, 4, 3, 2,
               1, 4, 2, 3,
               1, 4, 2, 3), nrow = 4, byrow = TRUE)
colnames(R2) = c("apple", "banana", "orange", "pear")
mod2 = PlackettLuce(R2)

# price
R3 = matrix(c(2, 4, 3, 1,
               4, 1, 2, 3,
               3, 4, 2, 1,
               4, 3, 1, 2), nrow = 4, byrow = TRUE)
colnames(R3) = c("apple", "banana", "orange", "pear")
mod3 = PlackettLuce(R3)

# storability
R4 = matrix(c(1, 4, 3, 2,
               3, 4, 1, 2,
               1, 3, 2, 4,
               2, 3, 4, 1), nrow = 4, byrow = TRUE)
colnames(R4) = c("apple", "banana", "orange", "pear")
mod4 = PlackettLuce(R4)

# models in a list
mods = list(mod1, mod2, mod3, mod4)

# name for each model
labels = c("Taste", "Texture", "Price", "Storability")

worth_map(mods, labels)

# plot only one model as bar 
worth_bar(mod1)

}
