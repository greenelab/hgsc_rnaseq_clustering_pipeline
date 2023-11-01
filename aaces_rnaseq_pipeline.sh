#!/bin/bash
exec &> aaces_rnaseq_analysis.out

# Amy Campbell, 2017
# This shell script performs differential clustering analyses
# from Way et al's 'Cross-population analysis of high-grade serous ovarian 
# cancer does not support four subtypes'
# This script assumes you have activated the conda hgsc_subtypes environment
# encoded in environment.yml

############################################
# INSTALL DEPENDENCIES
#Rscript INSTALL.R

#################
# PART ZERO:
# Download Mayo data
#################
# COMBAT adjust Mayo data
echo "RUNNING: COMBAT adjust Mayo data"
#Rscript 1.DataInclusion/Scripts/processMayoEset/\
#Agilent1and2and3_COMBAT_datamerge.R
echo "FINISHED: COMBAT adjust Mayo data"

# Create an eset from the Mayo data
echo "RUNNING: Create an eset from the Mayo data"
#Rscript 1.DataInclusion/Scripts/processMayoEset/createMayoEset.R
echo "FINISHED: Create an eset from the Mayo data"

# Define Constants
DATASETS="aaces.rnaseq.eset aaces.white.rnaseq.eset TCGA_eset mayo.eset GSE32062.GPL6480_eset GSE9891_eset aaces.eset"
KMIN=2
KMAX=4
SEED=123
NSTARTS=100
NMFSTARTS=2 # 10
NO_SHUFFLE=FALSE
SHUFFLE=TRUE
SAM_SUBSET='commongenes'
AACES_PATH='1.DataInclusion/Data/AACES/aaces_expression.tsv'
AACES_RNASEQ_PATH='1.DataInclusion/Data/AACES/salmon_normalized_filtered_for_way_pipeline_bottom10Removed.tsv'
AACES_WHITE_RNASEQ_PATH='1.DataInclusion/Data/AACES/salmon_normalized_filtered_for_way_pipeline_bottom5Removed_whites.tsv'

#################
# PART ONE: 
# Dataset Selection and Inclusion
#################
# ~~~~~~~~~~~~~~~~~~~~~
# This section will determine which samples meet a specific inclusion criteria 
# for use in downstream analyses
# ~~~~~~~~~~~~~~~~~~~~~
# 
# We are using data from curatedOvarianData version 1.8.0
# NOTE: The Mayo Clinic Data is not currently in curatedOvarianData.

# Output the samples for each dataset that pass the inclusion criteria
echo "RUNNING: Dataset Selection and Inclusion step 1"
Rscript 1.DataInclusion/Scripts/A.getInclusion.R --aaces $AACES_PATH --aaces_rna $AACES_RNASEQ_PATH --aaces_rna_white $AACES_WHITE_RNASEQ_PATH
echo "FINISHED: Dataset Selection and Inclusion step 1"

# Output the common genes and the MAD (Median Absolute Deviation) genes to be
# used in developing moderated t score vectors and in clustering, respectively.
echo "RUNNING: Dataset Selection and Inclusion step 2"
Rscript 1.DataInclusion/Scripts/B.getGenes.R $DATASETS #"GSE26712_eset"
echo "FINISHED: Dataset Selection and Inclusion step 2"

#################
# PART TWO:
# Run k means and SAM
#################
# ~~~~~~~~~~~~~~~~~~~~~
# The scripts will take as inputs the samples and genes from the previous
# section that passed the inclusion criteria. It will also run k means for
# k min - k max, output several figures (moderated t score heatmaps, kmeans bar
# chart distributions, correlation matrices) and tables (cluster membership by
# dataset, within dataset cluster correlations)
# ~~~~~~~~~~~~~~~~~~~~~

# ~~~~~~~~~~~~~
# SAM with MAD genes
# ~~~~~~~~~~~~~
# Output across dataset correlations for MAD genes
# NOTE: common genes used in downstream analyses
echo "RUNNING: SAM with MAD genes"
Rscript 2.Clustering_DiffExprs/Scripts/A.run_kmeans_SAM.R $KMIN $KMAX $NSTARTS $SEED FALSE $NO_SHUFFLE \
"madgenes" $DATASETS #"GSE26712_eset" 
echo "FINISHED: SAM with MAD genes"

# ~~~~~~~~~~~~~
# k means & SAM (with common genes)
# ~~~~~~~~~~~~~
# Perform k means and SAM
echo "RUNNING: k means & SAM step 1"
Rscript 2.Clustering_DiffExprs/Scripts/A.run_kmeans_SAM.R $KMIN $KMAX $NSTARTS $SEED FALSE $NO_SHUFFLE $SAM_SUBSET \
$DATASETS #"GSE26712_eset" 
echo "FINISHED: k means & SAM step 1"

# Output correlation matrices
echo "RUNNING: k means & SAM step 2"
Rscript 2.Clustering_DiffExprs/Scripts/B.CorrelationMatrix.R $KMIN $KMAX $SEED Figures/CorrelationMatrix/ $DATASETS #"GSE26712_eset"
echo "FINISHED: k means & SAM step 2"

# Output k-means barcharts
echo "RUNNING: k means & SAM step 3"
Rscript 2.Clustering_DiffExprs/Scripts/C.KMeansBarCharts.R $KMIN $KMAX $DATASETS 
echo "FINISHED: k means & SAM step 3"

# Shuffle genes to compare across population correlations in real data
echo "RUNNING: k means & SAM step 4"
Rscript 2.Clustering_DiffExprs/Scripts/A.run_kmeans_SAM.R $KMIN $KMAX $NSTARTS $SEED FALSE $SHUFFLE $SAM_SUBSET \
$DATASETS #"GSE26712_eset" 
echo "FINISHED: k means & SAM step 4"

# ~~~~~~~~~~~~~
# NMF
# ~~~~~~~~~~~~~
# Output consensus matrices, NMF cluster membership files  and
# cophenetic coefficients
echo "RUNNING: NMF step 1"
Rscript 2.Clustering_DiffExprs/Scripts/D.NMF.R $KMIN $KMAX $NMFSTARTS $SEED $DATASETS #"GSE26712_eset"
echo "FINISHED: NMF step 1"

# Run SAM on NMF clusters (TRUE argument forces NMF analysis)
echo "RUNNING: NMF step 2"
Rscript 2.Clustering_DiffExprs/Scripts/A.run_kmeans_SAM.R $KMIN $KMAX $NMFSTARTS $SEED TRUE $NO_SHUFFLE $SAM_SUBSET \
$DATASETS #"GSE26712_eset"
echo "FINISHED: NMF step 2"

# ~~~~~~~~~~~~~
# k means vs. NMF
# ~~~~~~~~~~~~~
# Compare k-means defined clusters with NMF defined clusters 
echo "RUNNING: Kmeans vs. NMF step 1"
Rscript 2.Clustering_DiffExprs/Scripts/E.kmeans_v_nmf.R $DATASETS  
echo "FINISHED: Kmeans vs. NMF step 1"

# Compile table with all cluster membership information
echo "RUNNING: Kmeans vs. NMF step 2"
Rscript 2.Clustering_DiffExprs/Scripts/F.clusterMembership.R $DATASETS 
echo "FINISHED: Kmeans vs. NMF step 2"

# ~~~~~~~~~~~~~
# Dataset Concordance
# ~~~~~~~~~~~~~
# Investigate the similarities in cluster membership in original TCGA 2011 
# paper, the Konecny 2014 paper, and the Tothill 2008 paper (Table 4)
echo "RUNNING: Dataset Concordance"
R --no-save < 2.Clustering_DiffExprs/Scripts/G.Dataset_concordance.R
echo "FINISHED: Dataset Concordance"


echo "PIPELINE COMPLETE"

