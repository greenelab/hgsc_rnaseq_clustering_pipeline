# Molecular subtypes of high grade serous ovarian cancer across racial groups and gene expression platforms

## Overview
This repository and the analysis repository ([link](https://github.com/greenelab/hgsc_rnaseq_cluster)) contains all the code needed to recreate the analyses, tables, and figures in the paper "Molecular subtypes of high grade serous ovarian cancer across racial groups and gene expression platforms"
Black individuals with ovarian cancer experience poorer survival compared to non-Hispanic White individuals.
High-grade serous carcinoma (HGSC) is the most common ovarian cancer histotype, with gene expression subtypes that are associated with differential survival.
We characterized HGSC gene expression in Black individuals and considered whether gene expression differences by race may contribute to disparities in survival. 

We performed gene expression clustering using RNA-Seq data from Black and White individuals with HGSC, as well as array-based genotyping data from four existing studies of HGSC.
Our main analysis assigned subtypes by identifying dataset-specific clusters using K-means clustering for K=2-4.
The cluster- and dataset-specific gene expression patterns were summarized by moderated t-scores that differentiate an individual cluster from all other clusters within each dataset.
We compared the calculated gene expression patterns for each cluster across datasets by calculating the Pearson correlation between the two summarized vectors of moderated t-scores.
Following K=4 subtype assignment and mapping to The Cancer Genome Atlas (TCGA)-derived HGSC subtypes, we used multivariable-adjusted Cox proportional hazards models to estimate subtype-specific survival separately for each dataset. 

This repository contains all of the code used to cluster the samples across difference datasets. 
Code to QC the RNA-Seq samples before clustering, all downstream analyses after clustering, and all code to generate the figures and tables in the manuscript are available here: [link](https://github.com/greenelab/hgsc_rnaseq_cluster)


## Data Availability
The data used in this analysis, raw and processed, will be made available upon publication.

## Code overview
- `1.DataInclusion`: This folder contains the code to download external data, exclude samples that are too similar using dopplegangeR, normalize the Mayo dataset, and select genes to be used as features during clustering.
- `2.Clustering_DiffExprs`: This folder contains the code to run the sample clustering for each data set, as well as the SAM analysis.
- `3.Fit`: This contains code for testing the fit of the clusters. We keep this folder for comparison to the original Way et al. 2016 pipeline ([link](https://github.com/greenelab/hgsc_subtypes)), but the QC metrics generated in this folder are not used in the manuscript. For the clustering metrics used in the paper, refer to the other git repo, specifically `figure_notebooks/rerun_clustering.Rmd` and `figure_notebooks/K3_kmeans_vs_nmf.Rmd`.

## Installation

Type `./run_docker.sh` This may take a while, building all of the r packages can take 30 minutes to an 2 hours. This will run the pipeline directly. If you would like to run the pipeline interactively, an conda environment will be created for you called `hgsc_subtypes` which will need to be activated before running any step of the pipeline.
