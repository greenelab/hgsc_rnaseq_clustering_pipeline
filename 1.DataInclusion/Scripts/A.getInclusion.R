############################################
# Natalie Davidson updated to include new RNA-Seq data
# Amy Campbell updated
# Updated from Greg Way/ James Rudd pipeline
# Cross-population analysis of high-grade serous ovarian cancer
# does not support four subtypes
#
# Way, G.P., Rudd, J., Wang, C., Hamidi, H., Fridley, L.B,  
# Konecny, G., Goode, E., Greene, C.S., Doherty, J.A.
# ~~~~~~~~~~~~~~~~~~~~~
# This script will perform our inclusion criteria on all datasets included
# in curatedOvarianData and a dataset from the Mayo Clinic

####################################
# Load Libraries
####################################
library(curatedOvarianData)
library(doppelgangR)
library(reshape2)
library(outliers)

# This R script holds custom inclusion functions
source("1.DataInclusion/Scripts/Functions/Inclusion_functions.R")

# Load patient selection info from curatedOvarianData package
source(system.file("extdata", "patientselection.config",
                   package = "curatedOvarianData"))

####################################
# Load Constants
####################################


vars <- c("sample_type", "histological_type", "grade", "primarysite",
          "arrayedsite", "summarystage", "tumorstage", "substage",
          "pltx", "tax", "neo", "recurrence_status", "vital_status",
          "os_binary", "relapse_binary", "site_of_tumor_first_recurrence",
          "primary_therapy_outcome_success", "debulking")

minimumSamples <- 100

# Esets that should never be included: Dressman and Bentink
excludeEsets <- c("PMID17290060_eset", "E.MTAB.386_eset")

# Load aaces path (if applicable)
options <- list(optparse::make_option(c("--aaces"),
                                      default = "aaces_expression.tsv",
                                      help = "path to AACES dataset",
                                      type = "character"),
                optparse::make_option(c("--aaces_rna"),
                                      default = "salmon_normalized_filtered_for_way_pipeline_bottom10Removed.tsv",
                                      help = "path to AACES RNASeq dataset",
                                      type = "character"),
                optparse::make_option(c("--aaces_rna_white"),
                                      default = "salmon_normalized_filtered_for_way_pipeline_bottom5Removed_whites.tsv",
                                      help = "path to AACES RNASeq dataset",
                                      type = "character"))
opt_parser <- optparse::OptionParser(option_list = options)
opt <- optparse::parse_args(opt_parser)

aacespath <- opt$aaces
aacesRNApath <- opt$aaces_rna
aacesWhiteRNApath <- opt$aaces_rna_white

print(aacespath)
print(aacesRNApath)
print(aacesWhiteRNApath)


####################################
# Load Data
####################################
# All the datasets within the curatedOvarianData package
esets <- getAllDataSets("curatedOvarianData")

# Load the Konecny data from GEO
load("1.DataInclusion/Data/Mayo/MayoEset.Rda")

 
# Load the AACES expression data
if (file.exists(aacespath)) {
  aaces.exprs <- read.table(aacespath, sep = "\t", row.names = 1, header = TRUE)

  pData <- data.frame(id=colnames(aaces.exprs), row.names=colnames(aaces.exprs))
  phenoData <- AnnotatedDataFrame(data=pData)

  aaces.eset <- ExpressionSet(assayData = as.matrix(aaces.exprs),
                  phenoData=phenoData)

  outfile = paste0(dirname(aacespath), "/", "aaces.eset.RData")
  save(aaces.eset, file=outfile)

  aaces <- TRUE
} else {
  aaces <- FALSE
  warning("Warning: AACES dataset not found; proceeding with the remaining datasets.")
}

if (file.exists(aacesRNApath)) {
  aaces.rnaseq.eset <- read.table(aacesRNApath, sep = "\t", row.names = 1, header = TRUE)
  aaces.rnaseq.eset = log(aaces.rnaseq.eset + 1)

  pData <- data.frame(id=colnames(aaces.rnaseq.eset), row.names=colnames(aaces.rnaseq.eset))
  phenoData <- AnnotatedDataFrame(data=pData)

  aaces.rnaseq.eset <- ExpressionSet(assayData = as.matrix(aaces.rnaseq.eset),
                  phenoData=phenoData)

  outfile = paste0(dirname(aacesRNApath), "/", "aaces.rnaseq.eset.RData")
  save(aaces.rnaseq.eset, file=outfile)

  aaces_rna <- TRUE
} else {
  aaces_rna <- FALSE
  warning("Warning: AACES RNASeq dataset not found; proceeding with the remaining datasets.")
}
if (file.exists(aacesWhiteRNApath)) {
  aaces.white.rnaseq.eset <- read.table(aacesWhiteRNApath, sep = "\t", row.names = 1, header = TRUE)
  aaces.white.rnaseq.eset = log(aaces.white.rnaseq.eset + 1)

  pData <- data.frame(id=colnames(aaces.white.rnaseq.eset), row.names=colnames(aaces.white.rnaseq.eset))
  phenoData <- AnnotatedDataFrame(data=pData)

  aaces.white.rnaseq.eset <- ExpressionSet(assayData = as.matrix(aaces.white.rnaseq.eset),
                  phenoData=phenoData)

  outfile = paste0(dirname(aacesWhiteRNApath), "/", "aaces.white.rnaseq.eset.RData")
  save(aaces.white.rnaseq.eset, file=outfile)

  aaces_white_rna <- TRUE
} else {
  aaces_white_rna <- FALSE
  warning("Warning: AACES Whites RNASeq dataset not found; proceeding with the remaining datasets.")
}
##################################
# ANALYSIS
##################################
# Use the inclusion/exclusion decision tree to filter samples in all
# curatedOvarainData datasets
inclusionTable <- exclusionTable(esets)

# Use the inclusion/exclusion decision tree on the Mayo data
inclusionTable.mayo <- simpleExclusion(mayo.eset)

# Use the inclusion/exclusion decision tree on aaces data, 
# manually add sample names
inclusionTable[[1]] <- cbind(inclusionTable[[1]],
                             inclusionTable.mayo[[1]])
colnames(inclusionTable[[1]])[(ncol(inclusionTable[[1]]))] <- "Mayo.eset"

# Add aaces to inclusion table if included
if (aaces) {
  inclusionTable.aaces <- simpleExclusion(aaces.eset)
  inclusionTable.aaces[[2]] <- sampleNames(aaces.eset)
  inclusionTable[[1]] <- cbind(inclusionTable[[1]],
                               inclusionTable.aaces[[1]])
  colnames(inclusionTable[[1]])[(ncol(inclusionTable[[1]]))] <- "aaces.eset"
  
}
if (aaces_rna) {
  inclusionTable.aaces.rnaseq <- simpleExclusion(aaces.rnaseq.eset)
  inclusionTable.aaces.rnaseq[[2]] <- sampleNames(aaces.rnaseq.eset)
  inclusionTable[[1]] <- cbind(inclusionTable[[1]],
                               inclusionTable.aaces.rnaseq[[1]])
  colnames(inclusionTable[[1]])[(ncol(inclusionTable[[1]]))] <- "aaces.rnaseq.eset"
  
}
if (aaces_white_rna) {
  inclusionTable.aaces.white.rnaseq <- simpleExclusion(aaces.white.rnaseq.eset)
  inclusionTable.aaces.white.rnaseq[[2]] <- sampleNames(aaces.white.rnaseq.eset)
  inclusionTable[[1]] <- cbind(inclusionTable[[1]],
                               inclusionTable.aaces.white.rnaseq[[1]])
  colnames(inclusionTable[[1]])[(ncol(inclusionTable[[1]]))] <- "aaces.white.rnaseq.eset"
  
}
# Save a copy of the first list element, a data.frame which details
# the creation of the analytic set and how many samples were excluded and why

write.csv(inclusionTable[[1]], "1.DataInclusion/Data/Inclusions.csv")

# The second list element in inclusionTable is a list of dataset specific
# 'good' sample IDs i.e. samples which should be included before applying
# doppelgangR
goodSamples <- inclusionTable[[2]]

# Remove the extra TCGA data (rnaseq and mirna)
goodSamples <- goodSamples[-1 * grep("rna|RNA", names(goodSamples))]

# Only consider the esets with the minimum number of samples
esetList.chosen <- list()
goodSamples.chosen <- list()

for (i in 1:(length(goodSamples))) {
    if (length(goodSamples[[i]]) >= minimumSamples &
        !(names(goodSamples)[i] %in% excludeEsets)) {
    # get the samples
    goodSamples.chosen[[names(goodSamples)[i]]] <- goodSamples[[i]]
    # load the eset
    exprs <- paste("data(", names(goodSamples)[i] , ")", sep = "")

    eval(parse(text = exprs))

    rm(exprs)

    # Limit it to only the good samples
    # also subsample for speed
    exprsString <- paste(names(goodSamples)[i], " <- ",
                         names(goodSamples)[i], "[,goodSamples[[i]]]", sep = "")

    eval(parse(text = exprsString))

    # add the eset to the eset List
    exprsString <- 
      paste("esetList.chosen[[", length(goodSamples.chosen), "]] <- ",
            names(goodSamples)[i], sep = "")
    eval(parse(text = exprsString))

    # delete the eset
    exprsString <- paste("rm(", names(goodSamples)[i], ")", sep = "")

    eval(parse(text = exprsString))
  }
}

names(esetList.chosen) <- names(goodSamples.chosen)

esetList.chosen[[length(esetList.chosen) + 1]] <-
  mayo.eset[, inclusionTable.mayo[[2]]]
goodSamples.chosen[[length(esetList.chosen)]] <-
  inclusionTable.mayo[[2]]
names(esetList.chosen)[(length(esetList.chosen))] <- 
  names(goodSamples.chosen)[(length(esetList.chosen))] <- "mayo.eset"

num_skip_dopple = 1
if (aaces) {
  esetList.chosen[[length(esetList.chosen) + 1]] <-
    aaces.eset[, inclusionTable.aaces[[2]]]
  goodSamples.chosen[[length(esetList.chosen)]] <-
    inclusionTable.aaces[[2]]
  names(esetList.chosen)[length(esetList.chosen)] <-
    names(goodSamples.chosen)[length(esetList.chosen)] <- "aaces.eset"
  num_skip_dopple = num_skip_dopple + 1
} 
if (aaces_rna) {
  esetList.chosen[[length(esetList.chosen) + 1]] <-
    aaces.rnaseq.eset[, inclusionTable.aaces.rnaseq[[2]]]
  goodSamples.chosen[[length(esetList.chosen)]] <-
    inclusionTable.aaces.rnaseq[[2]]
  names(esetList.chosen)[length(esetList.chosen)] <-
    names(goodSamples.chosen)[length(esetList.chosen)] <- "aaces.rnaseq.eset"
  num_skip_dopple = num_skip_dopple + 1
} 
if (aaces_white_rna) {
  esetList.chosen[[length(esetList.chosen) + 1]] <-
    aaces.white.rnaseq.eset[, inclusionTable.aaces.white.rnaseq[[2]]]
  goodSamples.chosen[[length(esetList.chosen)]] <-
    inclusionTable.aaces.white.rnaseq[[2]]
  names(esetList.chosen)[length(esetList.chosen)] <-
    names(goodSamples.chosen)[length(esetList.chosen)] <- "aaces.white.rnaseq.eset"
  num_skip_dopple = num_skip_dopple + 1
} 

testesets <- esetList.chosen
testesets[1:(length(esetList.chosen) - num_skip_dopple)] <-
  lapply(testesets[1:(length(testesets) - num_skip_dopple)], function(X) rename.esets(X))

default <- registered()
register(MulticoreParam(timeout = 30L * 24L * 60L * 60L * 100L), default = TRUE)

doppel.result <-
  doppelgangR::doppelgangR(testesets, intermediate.pruning = TRUE,
                           corFinder.args = list(use.ComBat = TRUE),
                           cache.dir = "cache")


#doppel.result_second <-
#  doppelgangR::doppelgangR(testesets[6:8], corFinder.args = list(use.ComBat = TRUE),
#                           cache.dir = "cache")
# Process the doppelgangR results into data.frames and write to the harddrive
doppelResult.full <- summary(doppel.result)
doppelResult.full_out <-
  doppelResult.full[c("sample1", "sample2",
                      "expr.similarity", "expr.doppel",
                      "pheno.similarity", "pheno.doppel")]
doppel.fname <-
  file.path("1.DataInclusion", "Data",
            "doppelgangR", "pairwiseSampleComparisons.tsv")
write.table(doppelResult.full_out,
            file = doppel.fname,
            sep = "\t", quote = FALSE, row.names = FALSE)

for (i in 1:length(goodSamples.chosen)) {
    sub <-
      (doppelResult.full_out)[
        lapply(strsplit(doppelResult.full_out$sample1, ":"),
               function(x) {x[1]}) %in% names(goodSamples.chosen)[i] &
          lapply(strsplit(doppelResult.full_out$sample2, ":"),
                 function(x) {x[1]}) %in% names(goodSamples.chosen)[i], ]
    
    cut <- mean(sub$expr.similarity) - (2 * sd(sub$expr.similarity))
    inc <- sub[sub$expr.similarity > cut, ]
    samp <- setdiff(sub$sample1, inc$sample1)
    
    if (names(goodSamples.chosen)[i] == 'TCGA_eset') {
      samp <- tcga.lowcor.outliers
    }
    
    lowcorSamples <- c()
    if (length(samp) != 0) {
      lowcorSamples <- unlist(strsplit(samp, ":"))[seq(2, length(samp) * 2, 2)]
      cat("Remove", length(lowcorSamples), "low-correlating samples from",
          names(goodSamples.chosen)[i], "\n")
    }

    doppelSamples <-
      c(sub$sample1[sub$expr.doppel & sub$expr.similarity > 0.95],
                    sub$sample2[sub$expr.doppel & sub$expr.similarity > 0.95])

    if (length(doppelSamples) != 0) {
      doppelSamples <- 
        unlist(strsplit(doppelSamples, ":"))[seq(2, length(doppelSamples) * 2, 2)]
      doppelSamples <- unique(doppelSamples)
      doppelSamples <- c(doppelSamples, lowcorSamples)

      sampleList <- setdiff(goodSamples.chosen[[i]], doppelSamples)
      outFName <- file.path("1.DataInclusion", "Data", "GoodSamples",
                            paste(names(goodSamples.chosen)[i],
                                  "_samplesRemoved.csv", sep = ""))
      sampleList <- sampleList[sampleList != "X1"]
      write.csv(sampleList, outFName)
    } else {
      sampleList <- setdiff(goodSamples.chosen[[i]], lowcorSamples)
      outFName <- file.path("1.DataInclusion", "Data", "GoodSamples",
                            paste(names(goodSamples.chosen)[i], 
                                  "_samplesRemoved.csv", sep = ""))
      write.csv(sampleList, outFName)
    }
}
