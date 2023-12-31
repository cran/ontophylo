
### IMPORTS ###
#' @importFrom stats setNames


#######################################################
##### Organizing ontology terms and character IDs #####
#######################################################


#' @title Convert list to edge matrix
#'
#' @description Takes a list of charater annotations and creates an edge matrix comprising two columns: from and to.
#' The list to table conversion can be done using ldply function from plyr package: plyr::ldply(list, rbind).
#'
#' @param annotated.char.list character list. A character list with ontology annotations.
#' @param col_order_inverse logical. The default creates the first columns consisting of character IDs and the second columns consisting of ontology annotations.
#' The inverse order changes the columns order.
#'
#' @return Two-column matrix.
#'
#' @author Sergei Tarasov
#'
#' @examples
#' annot_list <- list("CH1" = c("HAO:0000933", "HAO:0000958"), "CH2" = c("HAO:0000833", "HAO:0000258"))
#' list2edges(annot_list)
#'
#' @export
list2edges <- function(annotated.char.list, col_order_inverse = FALSE) {

  annotated.vec = setNames(unlist(annotated.char.list, use.names = FALSE), rep(names(annotated.char.list), lengths(annotated.char.list)))
  
  if (col_order_inverse == TRUE) {
  
    edge.matrix = cbind(unname(annotated.vec), names(annotated.vec))
	
  } else {
  
	edge.matrix = cbind(names(annotated.vec), unname(annotated.vec))
  
  }
  
  return(edge.matrix)
  
}


#' @title Get characters that are the descendants of a selected ontology term
#'
#' @description Returns all characters located (associated) with a given ontology term.
#'
#' @param ontology ontology_index object.
#' @param annotations character. Sets which annotations to use: "auto" means automatic annotations, "manual" means manual annotations.
#' Alternatively, any other list of element containing annotations can be specified.
#' @param terms character. IDs of ontology terms for which descendants are queried.
#' @param ... other parameters for ontologyIndex::get_descendants() function.
#'
#' @return The vector of character IDs.
#'
#' @author Sergei Tarasov
#'
#' @examples
#' data("HAO")
#' HAO$terms_selected_id <- list("CH1" = c("HAO:0000653"), "CH2" = c("HAO:0000653"))
#' get_descendants_chars(HAO, annotations = "manual", "HAO:0000653")
#'
#' @export
get_descendants_chars <- function(ontology, annotations = "auto", terms, ...) {
  
  if (is.list(annotations)) {
  
    annot_list <- annotations # specify your annotation list
	
  } else {
    
    if (annotations == "auto") {
	
      annot_list <- ontology$auto_annot_characters
	  
    }
	
    if (annotations == "manual") {
	
      annot_list <- ontology$terms_selected_id
    
	}
	
  }
  
  onto_chars_list = list2edges(annot_list, col_order_inverse = TRUE)
  descen <- unique(onto_chars_list[,2][onto_chars_list[,1] %in%
                                       ontologyIndex::get_descendants(ontology = ontology, roots = terms, ...)])
  
  return(descen)
  
}


#' @title Retrieve all characters under a given set of terms
#'
#' @description Returns a named list aggregating characters under a specified set of terms (e.g., body regions).
#'
#' @param char_info data.frame. A data.frame with two columns: the first column with character IDs and the second column with ontology IDs.
#' @param ONT ontology_index object.
#' @param terms character. The set of terms to aggregate characters.
#'
#' @return A named list with character groups.
#'
#' @author Sergei Tarasov
#'
#' @examples
#' data("HAO", "hym_annot")
#' char_info <- hym_annot[1:2]
#' # Query for three anatomical regions.
#' terms <- c("head", "mesosoma", "metasoma")
#' query <- RAC_query(char_info, HAO, terms)
#' query 
#'
#' @export
RAC_query <- function(char_info, ONT, terms) {
  
  char_info[[2]] <- gsub(char_info[[2]], pattern = "_", replacement = ":")
  
  annot <- as.list(as.character(char_info[[2]]))
  names(annot) <- as.character(char_info[[1]])
  ONT$terms_selected_id <- annot
  
  levelA <- names(ONT$name[ONT$name %in% terms])
  levelA <- setNames(levelA, terms)
  
  res <- lapply(levelA, function(x) get_descendants_chars(ONT, annotations = "manual", terms = x))
  
  #cat("\nAggregations by :\n")
  #print(res)
  
  return(res)
  
}


######################################
##### Processing stochastic maps #####
######################################


#' @title Reading unsummarized simmap for one tree
#'
#' @description Discretizes tree edges into identical bins given a selected resolution value.
#'
#' @param tree simmap or phylo object.
#' @param res integer. A resolution value for the discretization of tree edges.
#'
#' @return A simmap or phylo object.
#'
#' @author Sergei Tarasov
#'
#' @examples
#' data("hym_stm")
#' tree <- hym_stm[[1]][[1]]
#' stm_discr <- discr_Simmap(tree, res = 100)
#' # Check some arbitrary branch.
#' tree$maps[[8]]
#' stm_discr$maps[[8]]
#' sum(tree$maps[[8]])
#' sum(stm_discr$maps[[8]])
#'
#' @export
discr_Simmap <- function(tree, res) {
  
  steps <- 0:res/res * max(phytools::nodeHeights(tree))
  H <- phytools::nodeHeights(tree)
  maps.n <- vector(mode = "list", length = nrow(tree$edge))
  
  for (i in 1:nrow(tree$edge)) {
    
    YY <- cbind(c(H[i, 1], steps[intersect(which(steps > H[i, 1]), which(steps < H[i, 2]))]), 
                c(steps[intersect(which(steps > H[i, 1]), which(steps < H[i, 2]))], H[i, 2])) -  H[i, 1]
    
    
    TR <- cumsum(tree$maps[[i]])
    
    int.out = findInterval(YY[,2], c(0,TR), left.open = TRUE, rightmost.closed = FALSE, all.inside = TRUE)

    maps.n[[i]] <- setNames(YY[,2]-YY[,1], names(tree$maps[[i]])[int.out])
    
  }
  
  tree$maps <- maps.n

  class(tree) <- append(class(tree), c('discr_simmap', 'discr_phylo'))
  
  return(tree)        
  
}


#' @title Reading unsummarized simmap for a list of trees
#'
#' @description Discretizes tree edges of a list of trees.
#'
#' @param tree multiSimmap or multiPhylo object.
#' @param res integer. A resolution value for the discretization of tree edges.
#'
#' @return A multiSimmap or multiPhylo object.
#'
#' @author Sergei Tarasov
#'
#' @examples
#' data("hym_stm")
#' tree_list <- hym_stm[[1]]
#' stm_discr_list <- discr_Simmap_all(tree_list, res = 100)
#' # Check some arbitrary branch of some arbitrary tree.
#' tree_list[[1]]$maps[[8]]
#' stm_discr_list[[1]]$maps[[8]]
#' sum(tree_list[[1]]$maps[[8]])
#' sum(stm_discr_list[[1]]$maps[[8]])
#'
#' @export
discr_Simmap_all <- function(tree, res) {
  
  if (class(tree)[1] == "simmap") {
    
    tree <- discr_Simmap(tree, res)

	class(tree) <- append(class(tree), c('discr_simmap', 'discr_phylo'))
    
  }
  
  if (class(tree)[1] == "multiSimmap") {
    
    for (j in 1:length(tree)) {
      
      tree[[j]] <- discr_Simmap(tree[[j]], res)
      
    }

	class(tree) <- append(class(tree), c('discr_multiSimmap', 'discr_multiPhylo'))
    
  }
  
  return(tree)
  
}


#' @title Merge state bins over branch
#'
#' @description Merges identical state bins over the same branch in the discretized stochastic map.
#'
#' @param br numeric or character vector. The branches of the tree.
#'
#' @return A numeric or character vector with merged identical bins.
#'
#' @author Sergei Tarasov
#'
#' @examples
#' data("hym_stm")
#' tree <- hym_stm[[1]][[1]]
#' stm_discr <- discr_Simmap(tree, res = 100)
#' # Check some arbitrary branch.
#' br1 <- stm_discr$maps[[5]]
#' br1
#' br2 <- merge_branch_cat(br1)
#' br2
#' sum(br1) == br2
#' 
#' @export
merge_branch_cat <- function(br) {

  i=2
  while (i <= length(br)) {
  
    if ((names(br[i])) == names( br[i-1] )) {
	
      br[i-1] <- br[i-1]+br[i]
      br <- br[-i]
	  
    } else {
	
      i=i+1
	  
    }
	
  }
  
  return(br)
  
}


#' @title Merge state bins over a tree
#'
#' @description Merges identical state bins over a tree in the discretized stochastic map.
#'
#' @param tree simmap object.
#'
#' @return A tree with merged identical bins.
#'
#' @author Sergei Tarasov
#'
#' @examples
#' data("hym_stm")
#' tree <- hym_stm[[1]][[1]]
#' tree <- discr_Simmap(tree, res = 100)
#' stm_merg <- merge_tree_cat(tree)
#' # Check some arbitrary branch.
#' br1 <- tree$maps[[5]]
#' br1
#' br2 <- stm_merg$maps[[5]]
#' br2
#' sum(br1) == br2
#'
#' @export 
merge_tree_cat <- function(tree) {

  tree$maps <- lapply(tree$maps, merge_branch_cat)
  
  return(tree)
  
}


#' @title Merge state bins over a tree list
#'
#' @description A wrapper function to merge identical state bins over a tree list.
#'
#' @param tree.list multiSimmap object.
#'
#' @return A list of trees with merged identical bins.
#'
#' @author Diego S. Porto
#'
#' @examples
#' data("hym_stm")
#' tree_list <- hym_stm[[1]]
#' tree_list <- discr_Simmap_all(tree_list, res = 100)
#' stm_merg_list <- merge_tree_cat_list(tree_list)
#' # Check some arbitrary branch of some arbitrary tree.
#' br1 <- tree_list[[1]]$maps[[5]]
#' br1
#' br2 <- stm_merg_list[[1]]$maps[[5]]
#' br2
#' sum(br1) == br2
#'
#' @export
merge_tree_cat_list <- function(tree.list) {
  
  tree.list <- lapply(tree.list, function(x) merge_tree_cat(x) )
  
  tree.list <- do.call(c, tree.list)
  
  return(tree.list)
  
}


################################################
##### Stacking discretized stochastic maps #####
################################################


#' Stack two discrete stochastic character maps.
#'
#' @param stm.list list. A list of stochastic maps to be amalgamated.
#'
#' Internal function. Not exported.
#'
#' @author Sergei Tarasov
#'
stack_stm <- function(stm.list) {

  M <- lapply(stm.list, function(x) x$maps)
  M <- lapply(M, function(x) lapply(x, function(y) names(y)))
  M <- Reduce(stack2, M)
  
  M.out <- mapply(function(x,y){ setNames(x,y) }, x = stm.list[[1]]$maps, y = M)
  
  out <- stm.list[[1]]
  out$maps <- M.out
  
  return(out)
  
}


#' Stack two discrete stochastic character map lists; x and y are the list of state names (i.e. maps).
#'
#' @param x list. A list of state names.
#' @param y list. A list of state names.
#'
#' Internal function. Not exported.
#'
#' @author Sergei Tarasov
#'
stack2 <- function(x,y) {

  mapply(function(x,y){ paste(x,y, sep = "") }, x = x, y = y)
  
}


#' @title Stack multiple discrete stochastic character map lists
#'
#' @description Performs the final stacking of maps for a set of stochastic character maps stored in a list.
#' 
#' @param cc character. Characters IDs to stack.
#' @param tree.list multiSimmap or multiPhylo object. Named list with stochastic character maps.
#' @param ntrees integer. Number of trees to stack.
#'
#' @return A list of stacked stochastic character maps.
#'
#' @author Sergei Tarasov
#' 
#' @examples
#' data("hym_stm")
#' # Select the first five characters.
#' tree_list <- hym_stm[1:5]
#' tree_list <- lapply(tree_list, function(x) discr_Simmap_all(x, res = 100))
#' tree_list_amalg <- paramo.list(names(tree_list), tree_list, ntrees = 50)
#' tree_list_amalg <- do.call(c, tree_list_amalg)
#' # Plot one amalgamated stochastic map.
#' phytools::plotSimmap(tree_list_amalg[[1]], get_rough_state_cols(tree_list_amalg[[1]]),  
#' lwd = 3, pts = FALSE,ftype = "off")
#'
#' @export
paramo.list <- function(cc, tree.list, ntrees = 1) {

  tr <- vector("list", ntrees)
  ncharacters <- length(cc)
  cc <- gsub(" ", "_", cc)
  
  for (i in 1:ntrees) {
  
    stack.L <- vector("list", length(cc))
	
    for (j in 1:ncharacters) {
	
      stack.L[[j]] <- tree.list[[cc[j]]][[i]]
	  
    }
	
    tr[[i]] <- stack_stm(stack.L)
	
  }
  
  return(tr)
  
}


#' @title PARAMO 
#'
#' @description Wrapper function to perform the final paramo stacking of maps for a set of anatomy ontology terms.
#' 
#' @param rac_query character list. Named list obtained from the RAC_query function.
#' @param tree.list multiSimmap or multiPhylo object. Named list with stochastic character maps.
#' @param ntrees integer. Number of trees to stack.
#'
#' @return A list of stacked stochastic character maps.
#'
#' @author Diego S. Porto
#'
#' @examples
#' char_info <- hym_annot[1:2]
#' # Query for three anatomical regions.
#' terms <- c("head", "mesosoma", "metasoma")
#' query <- RAC_query(char_info, HAO, terms)
#' # Select the first three characters for each anatomical region.
#' query <- lapply(query, function(x) x[1:3])
#' # Subset the list of multiple maps.
#' tree_list <- hym_stm[unname(unlist(query))]
#' tree_list <- lapply(tree_list, function(x) discr_Simmap_all(x, res = 100))
#' tree_list_amalg <- paramo(query, tree_list, ntrees = 50)
#' tree_list_amalg <- lapply(tree_list_amalg, function(x) do.call(c,x) )
#' # Get one sample of map from head.
#' stm_hd <- tree_list_amalg$head[[1]]
#' # Get one sample of map from mesosoma.
#' stm_ms <- tree_list_amalg$mesosoma[[1]]
#' # Get one sample of map from metasoma.
#' stm_mt <- tree_list_amalg$metasoma[[1]]
#' # Plot one amalgamated stochastic map from each anatomical region.
#' phytools::plotSimmap(stm_hd, get_rough_state_cols(stm_hd), 
#' lwd = 3, pts = FALSE,ftype = "off")
#' phytools::plotSimmap(stm_ms, get_rough_state_cols(stm_ms), 
#' lwd = 3, pts = FALSE,ftype = "off")
#' phytools::plotSimmap(stm_mt, get_rough_state_cols(stm_mt), 
#' lwd = 3, pts = FALSE,ftype = "off")
#'
#' @export
paramo <- function(rac_query, tree.list, ntrees) {
  
  paramo.maps <- vector("list", length(rac_query))
  names(paramo.maps) <- names(rac_query)
  
  for (i in 1:length(paramo.maps)) {
    
    paramo.maps[[i]] <- paramo.list(rac_query[[i]], tree.list = tree.list, ntrees = ntrees)
    
  }
  
  return(paramo.maps)
  
}


#################################
#### Miscellaneous functions ####
#################################


#' @title Multiple character state colors
#'
#' @description Get state colors for ploting stochastic character maps when there many states.
#'
#' @param tree simmap object.
#'
#' @return A character vector with colors associated with state names. 
#'
#' @author Sergei Tarasov
#'
#' @import RColorBrewer
#' @importFrom grDevices colorRampPalette
#'
#' @examples
#' data("hym_stm_amalg")
#' # Get one sample of stochastic map from head.
#' tree <- hym_stm_amalg$head[[5]]
#' # Plot one amalgamated stochastic map from head.
#' phytools::plotSimmap(tree, get_rough_state_cols(tree), 
#' lwd = 3, pts = FALSE,ftype = "off")
#'
#' @export
get_rough_state_cols <- function(tree) {

  states <- lapply(tree$maps, names) %>%
    unlist() %>%
    unique()
  
  hm.palette <- colorRampPalette(brewer.pal(9, "Set1"), space = "Lab")
  color <- hm.palette(length(states))
  
  return(setNames(color, states))
  
}


#' @title Reading stochastic character maps file from ReVBayes
#'
#' @description Imports stochastic character maps file from RevBayes into R.
#'
#' @param file character. Path to the RevBayes file.
#' @param start integer. First tree of the sample to start reading the RevBayes file.
#' @param end integer. Last tree of the sample to finish reading the RevBayes file.
#' @param save character. Name to save output file.
#'
#' @return A tree in 'phylip' format.
#'
#' @author Sergei Tarasov
#'
#' @examples
#' rev_stm <- "Iteration\t1\t2\t3\tsimmap\n
#' 0\t{1,2.0}\t((spp1:{1,4.0:0,4.0},spp2:{1,2.0:0,6.0}):{1,0.5});\n
#' 1\t{1,2.0}\t((spp1:{1,2.0:0,6.0},spp2:{1,3.0:0,5.0}):{1,0.5});\n
#' 3\t{1,2.0}\t((spp1:{1,2.0:0,6.0},spp2:{1,3.0:0,5.0}):{1,0.5});"
#' stm <- read_Simmap_Rev(textConnection(rev_stm, "r"), start = 0, end = 3, save = NULL)
#' stm <- phytools::read.simmap(text = stm, format = "phylip")
#' phytools::plotSimmap(stm[[1]])
#'
#' @export
read_Simmap_Rev <- function(file, start = 1, end = 1, save = NULL) {

  skip = start + 2
  max2read = end - start + 1

  text <- scan(file = file, sep = "\n", what = "character", skip = skip, nlines = max2read)

  trees <- c()
  for (i in 1:length(text)) {

    #trees[i]<-strsplit(text[i], "\\}\t\\(")[[1]][2]

    ss = regexpr("\\}\t\\(",  text[i])[1]
    trees[i] <- substring(text[i], first = ss + 2)

  }

  if (is.null(save)) {

    return(trees)

  } else {

    write(trees, file = save, sep = "\n")
    #print(paste0("Tree(s) are saved to ", save))

  }

}

