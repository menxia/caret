modelInfo <- list(label = "Rotation Forest",
                  library = "rotationForest",
                  type = c("Classification", "Regression"),
                  parameters = data.frame(parameter = c("K", "L"),
                                          class = rep("numeric", 2),
                                          label = c("#Variable Subsets", "Ensemble Size")),
                  grid = function(x, y, len = NULL) {
                    expand.grid(K = 1:min(len, ncol(x)-1), L = (1:len)*3)                    
                  },
                  loop = function(grid) { 
                    grid <- grid[order(grid$K, -grid$L, decreasing = TRUE),, drop = FALSE]
                    unique_k <- unique(grid$K)
                    loop <- data.frame(K = unique_k, L = NA)  
                    submodels <- vector(mode = "list", length = length(unique_k))
                    for(i in seq(along = unique_k)) {
                      sub_L <- grid[grid$K == unique_k[i],"L"]
                      loop$L[loop$K == unique_k[i]] <- sub_L[which.max(sub_L)]
                      submodels[[i]] <- data.frame(L = sub_L[-which.max(sub_L)])
                    }    
                    list(loop = loop, submodels = submodels)
                  },
                  fit = function(x, y, wts, param, lev, last, classProbs, ...) {
                    if(length(lev) != 2)
                      stop("rotationForest is only implemented for binary classification")
                    y <- ifelse(y == lev[1], 1, 0)
                    if(!is.data.frame(x)) x <- as.data.frame(x)
                    rotationForest(x, y, K = param$K, L = param$L, ...)
                    },
                  predict = function(modelFit, newdata, submodels = NULL) {
                    if(!is.data.frame(newdata)) newdata <- as.data.frame(newdata)
                    out <- predict(modelFit, newdata)
                    out <- ifelse(out >= .5, modelFit$obsLevels[1], modelFit$obsLevels[2])

                    if(!is.null(submodels)) {
                      tmp <- vector(mode = "list", length = nrow(submodels) + 1)
                      tmp[[1]] <- out
                      all_L <- predict(modelFit, newdata, all = TRUE)
                      for(j in seq(along = submodels$L)) {                        
                        tmp_pred <- apply(all_L[, 1:submodels$L[j],drop = FALSE], 1, mean)
                        tmp[[j+1]] <- ifelse(tmp_pred >= .5, modelFit$obsLevels[1], modelFit$obsLevels[2])
                      }
                      out <- tmp
                    }
                    out   
                    },
                  prob = function(modelFit, newdata, submodels = NULL) {
                    if(!is.data.frame(newdata)) newdata <- as.data.frame(newdata)
                    all_L <- predict(modelFit, newdata, all = TRUE)
                    out <- apply(all_L, 1, mean)
                    out <- data.frame(x = out, y = 1 - out)
                    colnames(out) <- modelFit$obsLevels
                    if(!is.null(rownames(newdata))) rownames(out) <- rownames(newdata)
                    
                    if(!is.null(submodels)) {
                      tmp <- vector(mode = "list", length = nrow(submodels) + 1)
                      tmp[[1]] <- out
                      for(j in seq(along = submodels$L)) {  
                        tmp_pred <- apply(all_L[, 1:submodels$L[j],drop = FALSE], 1, mean)
                        tmp_pred <- data.frame(x = tmp_pred, y = 1 - tmp_pred)
                        colnames(tmp_pred) <- modelFit$obsLevels
                        if(!is.null(rownames(newdata))) rownames(tmp_pred) <- rownames(newdata)
                        tmp[[j+1]] <- tmp_pred
                      }
                      out <- tmp
                    }
                    out   
                    },
                  predictors = function(x, ...) {
                    non_zero <- function(x) {                      
                     out <- apply(x, 1, function(x) any(x != 0))
                     names(out)[out]
                    }
                    sort(unique(unlist(lapply(x$loadings, non_zero))))
                  },
                  varImp = function(object, ...) {
                    imps <- lapply(object$models, varImp, scale = FALSE)
                    imps <- lapply(imps, 
                                   function(x) {
                                     x$Variable <- rownames(x)
                                     x
                                   })
                    imps <- do.call("rbind", imps)
                    imps <- aggregate(Overall ~ Variable,  data = imps, sum)
                    imps$Overall <- imps$Overall/length(object$models)
                    rownames(imps) <- as.character(imps$Variable)
                    imps$Variable <- NULL
                    imps
                    },
                  levels = function(x) x$obsLevels,
                  tags = c("Ensemble Model", "Implicit Feature Selection", 
                           "Feature Extraction Models", "Tree-Based Model"),
                  sort = function(x) x[order(x[,1]),])
