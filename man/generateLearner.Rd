% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/generateLearner.r
\name{generateLearner}
\alias{generateLearner}
\title{Generates a Learner for a given task and ParConfig.}
\usage{
generateLearner(task, par.config)
}
\arguments{
\item{task}{[\code{Task}]
The Task}

\item{par.config}{[\code{\link{ParConfig}}]
The Parameter Configuration}
}
\value{
[\code{Learner}]
}
\description{
Generates a Learner for a given task and ParConfig
}
\examples{
par.config = downloadParConfig("1")
learner = generateLearner(iris.task, par.config)
print(learner)
}
