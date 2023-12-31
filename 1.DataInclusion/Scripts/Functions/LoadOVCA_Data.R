 ############################################
# Cross-population analysis of high-grade serous ovarian cancer reveals
# only two robust subtypes
#
# Way, G.P., Rudd, J., Wang, C., Hamidi, H., Fridley, L.B,  
# Konecny, G., Goode, E., Greene, C.S., Doherty, J.A.
# ~~~~~~~~~~~~~~~~~~~~~
# This script will load the data required for all downstream analyses. 
# Each script that requires data will source() this script.

############################################
# Load Libraries
############################################
library(curatedOvarianData)
library(plyr)

############################################
# Load Data Function
############################################
LoadOVCA_Data <- function(datasets,
                          goodsample_subset_dir = "1.DataInclusion/Data/GoodSamples/",
                          commongenes_dir = "1.DataInclusion/Data/Genes/CommonGenes_genelist.csv",
                          madgenes_dir = "1.DataInclusion/Data/Genes/GlobalMAD_genelist.csv",
                          genelist_subset = "commongenes",
                          mayo_exprs_file = "1.DataInclusion/Data/Mayo/MayoEset.Rda",
                          aaces_exprs_file = "1.DataInclusion/Data/AACES/aaces.eset.RData",
                          aaces_rnaseq_exprs_file = "1.DataInclusion/Data/AACES/aaces.rnaseq.eset.RData",
                          aaces_white_rnaseq_exprs_file = "1.DataInclusion/Data/AACES/aaces.white.rnaseq.eset.RData",
                          aaces_path = "aaces_expression.tsv",
                          shuffle = FALSE,
                          zscore = FALSE) {
# ~~~~~~~~~~~~~~
  # Loads ovarian cancer data from curatedOvarianData
  #
  # Args: 
  # datasets: a list of datasets to download
  # goodsample_subset_dir: the directory holds .txt files of samples that
  # passed inclusion
  # if no sample subsetting is desired, set this argument to "None"
  # commongenes_dir: the file location of the common genes .txt file
  # madgenes_dir: the file location of the mad (median absolute deviation)
  # genes .txt file 
  # genelist_subset: the genelist to subset each dataset
  # shuffle: determines if the genelists should be shuffled in the final
  # expression matrix
  #
  # Returns:
  # A list object holding the gene expression data for the
  # input datasets
  # ~~~~~~~~~~~~~~
  
  # Get data from the curatedOvarianData package  
  detailedData <- data(package = "curatedOvarianData")[3]
  # Get the eset IDs
  detailedData.names <- detailedData$results[, 3]

  # Initialize a list object
  ExpData <- list()
  for (eset_exprs in datasets) {
    if (goodsample_subset_dir != "None") {
      # Get the list of samples to remove
      fileName <- paste(eset_exprs, "_samplesRemoved.csv", sep = "")
      goodSamples <- read.csv(file = paste(goodsample_subset_dir,
                                           fileName, sep = ""))
      # The samples to use in the subset
      goodSamples <- c(paste(goodSamples$x))
    }

    # Load the expression data
    dta <- c()
    if (eset_exprs %in% detailedData.names) {
      # Load the data
      cat("Loading", eset_exprs, "...\n")
      data(list = eset_exprs, package = "curatedOvarianData")
      ExpressionData <- get(eset_exprs)
      dta <- exprs(ExpressionData)
      if (eset_exprs == "TCGA_eset") {
        # load Levi Waldron's selected outliers to remove from TCGA
        source(system.file("extdata", "patientselection.config",
                           package="curatedOvarianData"))
        outliers.toremove <- lapply(tcga.lowcor.outliers,
                                    function(x) strsplit(x, ":")[[1]][2])
        dta <- dta[, !(colnames(dta) %in% outliers.toremove)]
      }
      
      # Mayo data is not in curatedOvarianData
    } else if (any(grepl("mayo.eset", eset_exprs))) {
      cat("Loading", eset_exprs, "...\n")
      mayo.eset <- get(load(mayo_exprs_file))
      dta <- exprs(mayo.eset)
      # neither is AACES
    } else if (any(grepl("aaces.eset", eset_exprs))) {
      cat("Loading", eset_exprs, "...\n")
      aaces.eset <- get(load(aaces_exprs_file))
      dta <- exprs(aaces.eset)
    } else if (any(grepl("aaces.rnaseq.eset", eset_exprs))) {
      cat("Loading", eset_exprs, "...\n")
      aaces.rnaseq.eset <- get(load(aaces_rnaseq_exprs_file))
      dta <- exprs(aaces.rnaseq.eset)
    } else if (any(grepl("aaces.white.rnaseq.eset", eset_exprs))) {
      cat("Loading", eset_exprs, "...\n")
      aaces.rnaseq.eset <- get(load(aaces_white_rnaseq_exprs_file))
      dta <- exprs(aaces.rnaseq.eset)
    }  else {
      stop("Dataset does not exist in curatedOvarianData")
    }

    # Determine user defined method of subseting genes
    if (genelist_subset == "commongenes") {
      subset <- read.csv(commongenes_dir, header = T, stringsAsFactors = F)
    } else if (genelist_subset == "madgenes") {
      subset <- read.csv(madgenes_dir, header = T, stringsAsFactors = F)
    } else if (genelist_subset != "None") {
      # Raise an error
      stop("Set genelist_subset to 'commongenes', 'madgenes', or 'None'")
    }
    
    # Assign the list elements according to the subset of choice
    if (goodsample_subset_dir != "None" & genelist_subset != "None") {
      good.sample.names <- colnames(dta)[colnames(dta) %in% goodSamples]
      ExpData[[eset_exprs]] <- dta[subset[, 1], good.sample.names]
    } else if (goodsample_subset_dir == "None" & genelist_subset != "None") {
      ExpData[[eset_exprs]] <- dta[subset[, 1], ]
    } else {
      good.sample.names <- colnames(dta)[colnames(dta) %in% goodSamples]
      ExpData[[eset_exprs]] <- dta[, good.sample.names]
    }
    
    if (shuffle) {
      for (gene in 1:nrow(ExpData[[eset_exprs]])) {
        random_vec <- sample(ExpData[[eset_exprs]][gene, ],
                             ncol(ExpData[[eset_exprs]]))
        ExpData[[eset_exprs]][gene, ] <- random_vec
      }
    }
    
    # Z-Score data if required
    if (zscore) {
      scored <- scale(ExpData[[eset_exprs]])
      ExpData[[eset_exprs]] <- scored
    }
  }
  # Return a list of subsetted gene expression data.frames for all
  # input datasets
  return(ExpData)
}
