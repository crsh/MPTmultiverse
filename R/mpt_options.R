#' Options Settings for MPT Comparison
#' 
#' Set and examine a variety of \emph{options} which affect the way MPT models
#' are estimated.
#' 
#' @param ... Named parameters to set. Possible values are:
#' \itemize{
#'   \item{\code{bootstrap_samples}: }{Numeric. The number of bootstrap samples to be drawn for the calculation parametric bootstrap confidence intervals.}
#'   \item{\code{n.optim}: }{Numeric. The number of optimization runs for the models estimated with maximum-likelihood methods.}
#'   \item{\code{n.chains}: }{Numeric. The number of MCMC chains for the Bayesian models.}
#'   \item{\code{n.adapt}: }{Numeric. The number of iterations for adaptation.}
#'   \item{\code{n.burnin}: }{Numeric. The number of burn-in/warm-up iterations.}
#'   \item{\code{n.iter}: }{Numeric. The total number of iterations to be drawn \emph{after} adaptation (including burnin).}
#'   \item{\code{n.thin}: }{Numeric. Thinning interval.}
#'   \item{\code{Rhat_max}: }{Numeric. The maximum rhat.}
#'   \item{\code{Neff_min}: }{Numeric. The minimum number of effective samples you are willing to accept.}
#'   \item{\code{extend_max}: }{Numeric.}
#'   \item{\code{n.PPP}: }{Numeric. The number of posterior predictive samples drawn for the calculation of fit statistics T_1 and T_2.}
#'   \item{\code{n.CPU}: }{Numeric. The number of CPU cores to use. Defaults to the number of available cores on your machine.}
#'   \item{\code{ci_size}: }{Numeric.}
#'   \item{\code{max_ci_indiv}: }{Numeric.}
#'   \item{\code{silent_jags}: }{Logical. Whether to suppress JAGS output.}
# ' TODO  \item{\code{catch_warnings}: }{Logical. Whether to store warnings and errors as additional coluumns in the output.}
#'   \item{\code{save_models}: }{Logical.}
#' }
#'   
#' 
#' @examples 
#' # Examine options:
#' mpt_options()
#' 
#' # Set number of MCMC chains to 20:
#' mpt_options(n.chains = 20)
#' mpt_options()
#' 
#' @export
 
mpt_options <- function(...){
  
  fetched <- getOption("MPTmultiverse")
  args <- c(...)
  
  if(length(args)==0L) return(fetched)
  
  # Provide some shorthand terms:
  if(args[[1]] %in% c("test", "default")){
    changed <- switch(
      args[[1]]
      , test = set_test_options()
      , default = set_default_options()
    )
  } else {
    changed <- lapply(
      X = fetched
      , FUN = function(x, args){
        if(is.list(x)) {
          sub_args <- args[names(args)%in%names(x)]
          x[names(sub_args)] <- sub_args
        }
        x
      }
      , args = args
    )

    sub_args <- args[names(args)%in%names(fetched)]
    changed[names(sub_args)] <- sub_args

  }
  options(list(MPTmultiverse = changed))
}



#' @keywords internal

set_test_options <- function() { # nocov start
  cat("Setting options for a quick test run.\nDo not interpret results!")
  
  list(
    mptinr = list(
      bootstrap_samples = 1e1
      , n.optim = 1
    )
    , treebugs = list(
      n.chains = 4
      , n.iter = 8e2
      , n.adapt = 1e2
      , n.burnin = 1e2
      , n.thin = 1e0
      , Rhat_max = 10
      , Neff_min = 2
      , extend_max = 1
      , n.PPP = 4e1
    )
    , silent_jags = FALSE
    # , catch_warnings = TRUE
    , ci_size = c(.025, .1, .9, .975)
    , max_ci_indiv = .99
    , n.CPU = parallel::detectCores()
    , save_models = FALSE
  )
}


#' @keywords internal

set_default_options <- function() {
  
  list(
    mptinr = list(
      bootstrap_samples = 2e3
      , n.optim = 2e1
    )
    , treebugs = list(
      n.chains = 4
      , n.iter = 5e4
      , n.adapt = 1e4
      , n.burnin = 2e4
      , n.thin = 1e1
      , Rhat_max = 1.01
      , Neff_min = 1e3
      , extend_max = 2e1
      , n.PPP = 5e3
    )
    , silent_jags = TRUE
    # , catch_warnings = TRUE
    , ci_size = c(.025, .1, .9, .975)
    , max_ci_indiv = .99
    , n.CPU = parallel::detectCores()
    , save_models = TRUE
  )
}

#' @importFrom tibble as_tibble
#' @keywords internal

tidy_options <- function(x) {
  y <- cbind(
    tibble::as_tibble(x[["mptinr"]])
    , tibble::as_tibble(x[["treebugs"]])
  )
  # y$silent_jags <- x$silent_jags
  y$ci_size[[1]] <- x$ci_size
  y$max_ci_indiv <- x$max_ci_indiv
  # y$save_models <- x$save_models
  tibble::as_tibble(y)
}