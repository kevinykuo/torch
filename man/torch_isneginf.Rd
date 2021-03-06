% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gen-namespace-docs.R,
%   R/gen-namespace-examples.R, R/gen-namespace.R
\name{torch_isneginf}
\alias{torch_isneginf}
\title{Isneginf}
\usage{
torch_isneginf(self)
}
\arguments{
\item{self}{(Tensor) the input tensor.}
}
\description{
Isneginf
}
\section{isneginf(input, *, out=None) -> Tensor }{


Tests if each element of \code{input} is negative infinity or not.
}

\examples{
if (torch_is_installed()) {

a <- torch_tensor(c(-Inf, Inf, 1.2))
torch_isneginf(a)
}
}
