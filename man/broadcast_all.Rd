% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/distributions-utils.R
\name{broadcast_all}
\alias{broadcast_all}
\title{Given a list of values (possibly containing numbers), returns a list where each
value is broadcasted based on the following rules:
\itemize{
\item \code{torch.*Tensor} instances are broadcasted as per :ref:\verb{_broadcasting-semantics}.
\item numbers.Number instances (scalars) are upcast to tensors having
the same size and type as the first tensor passed to \code{values}.  If all the
values are scalars, then they are upcasted to scalar Tensors.
}}
\usage{
broadcast_all(values)
}
\description{
\preformatted{values (list of `numbers.Number`, `torch.*Tensor` or objects implementing __torch_function__)
}

Raises:
ValueError: if any of the values is not a \code{numbers.Number} instance,
a \code{torch.*Tensor} instance, or an instance implementing \strong{torch_function}
TODO: add has_torch_function((v,))
See: https://github.com/pytorch/pytorch/blob/master/torch/distributions/utils.py
}
