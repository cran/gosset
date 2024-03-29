#' Kendall rank correlation coefficient
#' 
#' Compute Kendall rank correlation coefficient between two objects. 
#' Kendall is a coefficient used in statistics to measure the ordinal 
#' association between two measured quantities. A tau test is a non-parametric 
#' hypothesis test for statistical dependence based on the tau coefficient.
#' The 'kendallTau' function applies the "kendall" method from 'stats::cor' 
#' with some previous treatment in the data, such as converting floating numbers
#' into ranks (from the higher being the first and negative being the last) 
#' and the possibility to remove zeros from incomplete ranks
#' 
#' @author Kauê de Sousa and Jacob van Etten
#' @family goodness-of-fit functions
#' @param x a numeric vector, matrix or data frame
#' @param y a vector, matrix or data frame with compatible dimensions to \code{x}
#' @param null.rm logical, to remove zeros from \code{x} and \code{y} 
#' @param average logical, if \code{FALSE} returns the kendall and N-effective for each entry
#' @param na.omit logical, if \code{TRUE} ignores entries with kendall = NA when computing the average
#' @param ... further arguments affecting the Kendall tau produced. See details 
#' @return The Kendall correlation coefficient and the Effective N, which 
#' is the equivalent N needed if all items were compared to all items. 
#' Can be used for significance testing.
#' @references 
#' 
#' Kendall M. G. (1938). Biometrika, 30(1–2), 81–93. 
#' \doi{https://doi.org/10.1093/biomet/30.1-2.81}
#' 
#' @examples
#' 
#' # Vector based example same as stats::cor(x, y, method = "kendall")
#' # but showing N-effective
#' x = c(1, 2, 3, 4, 5)
#' 
#' y = c(1, 1, 3, 2, NA)
#' 
#' w = c(1, 1, 3, 2, 5)
#' 
#' kendallTau(x, y)
#' 
#' kendallTau(x, w)
#' 
#' # Matrix and PlacketLuce ranking example 
#' 
#' library("PlackettLuce")
#'  
#' R = matrix(c(1, 2, 4, 3,
#'              1, 4, 2, 3,
#'              1, 2, NA, 3,
#'              1, 2, 4, 3,
#'              1, 3, 4, 2,
#'              1, 4, 3, 2), nrow = 6, byrow = TRUE)
#' colnames(R) = LETTERS[1:4]
#' 
#' G = group(as.rankings(R), 1:6)
#' 
#' mod = pltree(G ~ 1, data = G)
#' 
#' preds = predict(mod)
#' 
#' kendallTau(R, preds)
#' 
#' # Also returns raw values (no average) 
#' 
#' kendallTau(R, preds, average = FALSE)
#' 
#' # Choose to ignore entries with NA
#' R2 = matrix(c(1, 2, 4, 3,
#'               1, 4, 2, 3,
#'               NA, NA, NA, NA,
#'               1, 2, 4, 3,
#'               1, 3, 4, 2,
#'               1, 4, 3, 2), nrow = 6, byrow = TRUE)
#' 
#' kendallTau(R, R2, average = FALSE)
#' 
#' kendallTau(R, R2, average = TRUE)
#' 
#' kendallTau(R, R2, average = TRUE, na.omit = TRUE)
#' 
#' @seealso \code{\link[stats]{cor}}
#' @importFrom methods addNextMethod asMethodDefinition assignClassDef
#' @importFrom stats cor
#' @importFrom PlackettLuce as.grouped_rankings
#' @export
kendallTau = function(x, y, null.rm = TRUE, average = TRUE, na.omit = FALSE, ...){
  
  UseMethod("kendallTau")
  
}

#' @rdname kendallTau
#' @export
kendallTau.default = function(x, y, null.rm = TRUE, ...){
  
  
  keep = !is.na(x) & !is.na(y)
  
  # if TRUE, remove zeros in both rankings
  if (null.rm) {
    
    keep = x != 0 & y != 0 & keep
    
  }
  
  x = x[keep]
  
  y = y[keep]
  
  # if any decimal in x or y transform it to integer rankings
  # decimals will be computed as descending rankings
  # where the highest values are the "best" 
  # negative values are placed as least positions
  if (any(.is_decimal(x))) {
    
    x = .rank_decimal(x)$rank
    
  }
  
  if(any(.is_decimal(y))) {
    
    y = .rank_decimal(y)$rank
    
  }
  
  tau_cor = stats::cor(x, 
                        y, 
                        method = "kendall", 
                        ...)
  
  n = length(x)
  
  weight = n * (n - 1) / 2
  
  kt = c(tau_cor, weight)
  
  # Extract the values from the vector
  N = kt[2]
  
  # Effective N is the equivalent N needed if all were compared to all
  # N_comparisons = ((N_effective - 1) * N_effective) / 2
  # This is used for significance testing later
  N_effective = 0.5 + sqrt(0.25 + 2 * sum(N)) 
  
  kt[2] = N_effective
  
  n = N_effective
  
  # calculate z-value using n effective
  z = (3 * tau_cor * sqrt(n * (n - 1))) / sqrt(2 * (2 * n + 5))
  
  # then p-value
  p = stats::pnorm(z, lower.tail = FALSE)
  
  kt = c(kt, z, p)
  
  names(kt) = c("kendallTau", "N_effective", "Zvalue", "Pr(>|z|)")
  
  kt = t(as.data.frame(kt))
  
  kt = as.data.frame(kt)
  
  class(kt) = union("gosset_df", class(kt))
  
  rownames(kt) = 1:nrow(kt)
  
  return(kt)
  
}

#' @rdname kendallTau
#' @method kendallTau matrix
#' @export
kendallTau.matrix = function(x, y, null.rm = TRUE, average = TRUE, na.omit = FALSE, ...){
  
  nc = ncol(x)
  
  kt = apply(cbind(x, y), 1, function(K){
    
    X = K[1:nc]
    Y = K[(nc + 1):(nc * 2)]
    
    kendallTau(X, Y, ...)
    
  })
  
  kt = do.call("rbind", kt)
  
  if (isFALSE(average)) {
    rownames(kt) = 1:nrow(kt)
    return(kt)
  }
  
  if (isTRUE(na.omit)) {
    kt = kt[!is.na(kt[,1]), ]
  } 
  
  # Extract the values from the matrix
  tau = kt[,1]
  N = kt[,2]

  tau_average = sum(tau * N, na.rm = TRUE) / sum(N)
  
  # Effective N is the equivalent N needed if all were compared to all
  # N_comparisons = ((N_effective - 1) * N_effective) / 2
  # This is used for significance testing later
  N_effective = 0.5 + sqrt(0.25 + 2 * sum(N)) 
  
  n = N_effective
  
  # calculate z-value using n effective
  z = (3 * tau_average * sqrt(n * (n - 1))) / sqrt(2 * (2 * n + 5))
  
  # then p-value
  p = stats::pnorm(z, lower.tail = FALSE)
  
  kt = c(tau_average, N_effective, z, p)
  
  names(kt) = c("kendallTau", "N_effective", "Zvalue", "Pr(>|z|)")
  
  kt = t(as.data.frame(kt))
  
  kt = as.data.frame(kt)
  
  class(kt) = union("gosset_df", class(kt))
  
  rownames(kt) = 1:nrow(kt)
  
  return(kt)
  
}

#' @rdname kendallTau
#' @method kendallTau rankings
#' @export
kendallTau.rankings = function(x, y, ...){
  
  X = x[1:nrow(x), , as.rankings = FALSE]
  
  Y = y[1:nrow(y), , as.rankings = FALSE]
  
  kendallTau(X, Y, ...)
  
}


#' @rdname kendallTau
#' @method kendallTau grouped_rankings
#' @export
kendallTau.grouped_rankings = function(x, y, ...){
  
  X = x[1:length(x), , as.grouped_rankings = FALSE]
  
  Y = y[1:length(y), , as.grouped_rankings = FALSE]
  
  kendallTau(X, Y, ...)
  
}

#' @rdname kendallTau
#' @method kendallTau paircomp
#' @export
kendallTau.paircomp = function(x, y, ...) {
  
  x = PlackettLuce::as.grouped_rankings(x)
  
  X = x[1:length(x), as.grouped_rankings = FALSE]
  
  y = PlackettLuce::as.grouped_rankings(y)
  
  Y = y[1:length(y), as.grouped_rankings = FALSE]
  
  kendallTau(X, Y, ...)
  
}

