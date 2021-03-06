#' @include utils.R

#' Distribution is the abstract base class for probability distributions.
#' Note: in Python, adding torch.Size objects works as concatenation
#' Try for example: torch.Size((2, 1)) + torch.Size((1,))
Distribution <- R6::R6Class(
  "torch_Distribution",
  lock_objects = FALSE,
  
  public = list(
    
    has_rsample           = FALSE,
    has_enumerate_support = FALSE,
    .validate_args        = FALSE,
    .support              = NULL,
    .batch_shape          = NULL,
    .event_shape          = NULL,
    
    # Choose different structure?
    .arg_constraints       = list(),
    
    initialize = function(batch_shape = NULL, event_shape = NULL, validate_args = NULL){

      self$.batch_shape <- batch_shape
      self$.event_shape <- event_shape

      if (!is.null(validate_args))
        self$.validate_args <- validate_args

        for (param in names(self$.arg_constraints)) {

          constraint <- self$.arg_constraints[[param]]

          if (is_dependent(constraint))
            next
          
          # TODO: check lazy_property
          # if (!(param %in% names(self) && inherits(constraint, "lazy_property"))
          #   next # skip checking lazily-constructed args
          # if (all(constraint$check(constraint)))
          #   value_error("The parameter {param} has invalid values")
        }
    },
    
    expand = function(batch_shape, .instance = NULL){
      not_implemented_error()
    },
    
    #' Generates a sample_shape shaped sample or sample_shape shaped batch of
    #' samples if the distribution parameters are batched.
    sample = function(sample_shape=NULL){
      with_no_grad({
        self$rsample(sample_shape)
      })
    },
    
    #' Generates a sample_shape shaped reparameterized sample or sample_shape
    #' shaped batch of reparameterized samples if the distribution parameters
    #' are batched.
    #' In PyTorch: sample_shape=torch.Size()
    rsample = function(sample_shape = NULL) {
       not_implemented_error()
    },
    
    #' Returns the log of the probability density/mass function evaluated at
    #' `value`.
    log_prob = function(value) {
      not_implemented_error()
    },
    
    #'  Returns the cumulative density/mass function evaluated at
    #' `value`.
    cdf = function(value) {
      not_implemented_error()
    },
    
    #'  Returns the inverse cumulative density/mass function evaluated at
    #' `value`.
    icdf = function(value) {
      not_implemented_error()
    },
    
    #'  Returns tensor containing all values supported by a discrete
    #'  distribution. The result will enumerate over dimension 0, so the shape
    #'  of the result will be `(cardinality,) + batch_shape + event_shape
    #'  (where `event_shape = ()` for univariate distributions).
    #'  Note that this enumerates over all batched tensors in lock-step
    #'  `[[0, 0], [1, 1], ...]`. With `expand=FALSE`, enumeration happens
    #'  along dim 0, but with the remaining batch dimensions being
    #'  singleton dimensions, `[[0], [1], ..`.
    #'  @param expand (bool): whether to expand the support over the
    #'  batch dims to match the distribution's `batch_shape`.
    #'  @return Tensor iterating over dimension 0.
    enumerate_support = function(expand = TRUE) {
      not_implemented_error()
    },
    
    #'  Returns entropy of distribution, batched over batch_shape.
    #'  @return Tensor of shape batch_shape.
    entropy = function() {
      not_implemented_error()
    },
    
    #'  Returns perplexity of distribution, batched over batch_shape.
    #'  @param Tensor of shape batch_shape.
    perplexity = function() {
      not_implemented_error()
    },
    
    #' Returns the size of the sample returned by the distribution, given
    #' a `sample_shape`. Note, that the batch and event shapes of a distribution
    #' instance are fixed at the time of construction. If this is empty, the
    #' returned shape is upcast to (1,).
    #' @param sample_shape (torch_Size): the size of the sample to be drawn.
    .extended_shape = function(sample_shape = NULL){
      c(sample_shape, self$batch_shape, self$event_shape)
    },
    
    #' Argument validation for distribution methods such as `log_prob`,
    #' `cdf` and `icdf`. The rightmost dimensions of a value to be
    #' scored via these methods must agree with the distribution's batch
    #' and event shapes.
    #' @param value (Tensor): the tensor whose log probability is to be
    #' computed by the `log_prob` method.
    .validate_sample = function(value){
      
      if (!inherits(value, "torch_Tensor"))
        value_error('The value argument to log_prob must be a Tensor')
      
      event_dim_start <-length(value$size()) - length(self$.event_shape)
    
      if (value$size()[event_dim_start, ] != self$.event_shape)
        value_error(
          'The right-most size of value must match event_shape:
           {value$size()} vs {self$.event_shape}.'
        )

      actual_shape <- value$size()
      expected_shape <- c(self$.batch_shape, self$.event_shape)

      shape_length <- length(actual_shape)
      
      for (idx in shape_length:1) {
        i <- actual_shape[idx]
        j <- expected_shape[idx]
        
        if (i != 1 && j != 1 && i != j)
          value_error(
            'Value is not broadcastable with 
             batch_shape+event_shape: {actual_shape} vs {expected_shape}.'
          )
      }
      
      if (!self$support$check(value)$all())
        value_error('The value argument must be within the support')
    },
    
    .get_checked_instance = function(cls, .instance = NULL, .args){
      if (is.null(.instance) && !identical(self$initialize, cls$initialize))
        #' TODO: consider different message
        not_implemented_error(
          "Subclass {paste0(class(self), collapse = ' ')} of ", 
          "{paste0(class(cls), collapse = ' ')} ",
          "that defines a custom `initialize()` method ",
          "must also define a custom `expand()` method."
        )
      
      if (is.null(.instance))
        return(do.call(self$class_def$new, .args))
      else
        return(.instance)
    },
    
    print = function(){
    
      param_names <- 
        names(self$.arg_constraints)[
          names(self$.arg_constraints) %in% names(as.list(self))
            ]
      
      args_string <- paste0(
        param_names, collapse = ","
      )
      
      class_name <- class(self)[1]
      cat(glue("{class_name} ({args_string})"))
    }
  ),
  
  active = list(
    
    #' Returns the shape over which parameters are batched.
    batch_shape = function(){
      self$.batch_shape
    },
    
    #' Returns the shape of a single sample (without batching).
    event_shape = function(){
      self$.event_shape
    },
    
    #' Returns a dictionary from argument names to
    #' `torch_Constraint` objects that
    #' should be satisfied by each argument of this distribution. Args that
    #' are not tensors need not appear in this dict.
    # arg_constraints = function(){
    #   not_implemented_error()
    # },

    #' Returns a `torch_Constraint` object
    #' representing this distribution's support.
    support = function() {
      not_implemented_error()
    },

    #' Returns the mean on of the distribution
    mean = function() {
      not_implemented_error()
    },

    #' Returns the variance of the distribution
    variance = function() {
      not_implemented_error()
    },

    #' Returns the standard deviation of the distribution
    stddev = function() {
      self$variance$sqrt()
    }
  )
)

Distribution <- add_class_definition(Distribution)
