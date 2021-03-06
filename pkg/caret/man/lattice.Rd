\name{histogram.train}
\alias{stripplot.train}
\alias{xyplot.train}
\alias{densityplot.train}
\alias{histogram.train}

\title{Lattice functions for plotting resampling results}
\description{
A set of lattice functions are provided to plot the resampled performance estimates (e.g. classification accuracy, RMSE) over tuning parameters (if any).
}
\usage{
\method{histogram}{train}(x, data = NULL, metric = x$metric, ...)

\method{densityplot}{train}(x, data = NULL, metric = x$metric, ...)

\method{xyplot}{train}(x, data = NULL, metric = x$metric, ...)

\method{stripplot}{train}(x, data = NULL, metric = x$metric, ...)
}

\arguments{
  \item{x}{ An object produced by  \code{\link{train}} }
  \item{data}{This argument is not used }
  \item{metric}{A character string specifying  the single performance metric that will be plotted }
  \item{\dots}{arguments to pass to either  \code{\link[lattice:histogram]{histogram}}, \code{\link[lattice:histogram]{densityplot}}, \code{\link[lattice:xyplot]{xyplot}} or \code{\link[lattice:xyplot]{stripplot}}}
}
\details{
By default, only the resampling results for the optimal model are saved in the \code{train} object. The function \code{\link{trainControl}} can be used to save all the results (see the example below).

If leave-one-out or out-of-bag resampling was specified, plots cannot be produced (see the \code{method} argument of \code{\link{trainControl}})

For \code{xyplot} and \code{stripplot}, the tuning parameter with the most unique values will be plotted on the x-axis. The remaining parameters (if any) will be used as conditioning variables. For \code{densityplot} and \code{histogram}, all tuning parameters are used for conditioning.

Using \code{horizontal = FALSE} in \code{stripplot} works.
}
\value{A lattice plot object}
\author{Max Kuhn}

\seealso{\code{\link{train}}, \code{\link{trainControl}}, \code{\link[lattice:histogram]{histogram}}, \code{\link[lattice:histogram]{densityplot}}, \code{\link[lattice:xyplot]{xyplot}}, \code{\link[lattice:xyplot]{stripplot}}}
\examples{
\dontrun{

library(mlbench)
data(BostonHousing)

library(rpart)
rpartFit <- train(medv ~ .,
                  data = BostonHousing,
                  "rpart", 
                  tuneLength = 9,
                  trControl = trainControl(
                    method = "boot", 
                    returnResamp = "all"))

densityplot(rpartFit,
            adjust = 1.25)

xyplot(rpartFit,
       metric = "Rsquared",
       type = c("p", "a"))

stripplot(rpartFit,
          horizontal = FALSE,
          jitter = TRUE)

}
}

\keyword{hplot} 

