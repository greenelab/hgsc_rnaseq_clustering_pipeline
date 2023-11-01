# Install rforge and custom github packages
#
# Usage:
#
#    After activating conda environment (`source activate hgsc_subtypes`):
#
#          R --no-save < install_custom.R

tmp_url <- "https://cran.r-project.org/src/contrib/Archive/whisker/whisker_0.3-2.tar.gz"
install.packages(tmp_url, repos=NULL, type="source")

tmp_url <- "https://cran.r-project.org/src/contrib/Archive/rstudioapi/rstudioapi_0.6.tar.gz"
install.packages(tmp_url, repos=NULL, type="source")

tmp_url <- "https://cran.r-project.org/src/contrib/Archive/git2r/git2r_0.17.0.tar.gz"
install.packages(tmp_url, repos=NULL, type="source")



tmp_url <- "https://cran.r-project.org/src/contrib/Archive/devtools/devtools_1.13.3.tar.gz"
install.packages(tmp_url, repos=NULL, type="source")

library(devtools)

# Install ESTIMATE
rforge <- "http://r-forge.r-project.org"
install.packages("estimate", repos = rforge, dependencies = TRUE)

# Install MCPcounter
options(unzip = "internal")
devtools::install_github("ebecht/MCPcounter", ref = "master", subdir = "Source", force = TRUE)

# Install FSQN
options(unzip = "internal")
devtools::install_github("jenniferfranks/FSQN", ref = "master", subdir = "Source", force = TRUE)

# Install WGCNA version 1.51

# for some reason this version is no longer able
# to be successfully loaded using envoronment.yml
# and silently fails
# to get around this we explicitly download the package
# dependencies, using a best guess
# I guessed that the packages were up-to-date
# with WGCNA 1.51, so this was in 2016
# and I take the packags version most recently updated
# before 2016


# packages must be installed in this order

## packages to install Hmisc
# acepack requires installation of gfortran, installed in environment.yml
ace_url <- "https://cran.r-project.org/src/contrib/Archive/acepack/acepack_1.3-3.3.tar.gz"
install.packages(ace_url, repos=NULL, type="source")

latt_url <- "https://cran.r-project.org/src/contrib/Archive/latticeExtra/latticeExtra_0.6-28.tar.gz"
install.packages(latt_url, repos=NULL, type="source")

for_url <- "https://cran.r-project.org/src/contrib/Archive/foreign/foreign_0.8-66.tar.gz"
install.packages(for_url, repos=NULL, type="source")

tmp_url <- "https://cran.r-project.org/src/contrib/Archive/Formula/Formula_1.2-1.tar.gz"
install.packages(tmp_url, repos=NULL, type="source")

tmp_url <-"https://cran.r-project.org/src/contrib/Archive/rpart/rpart_4.1-10.tar.gz"
install.packages(tmp_url, repos=NULL, type="source")

tmp_url <-"https://cran.r-project.org/src/contrib/Archive/nnet/nnet_7.3-11.tar.gz"
install.packages(tmp_url, repos=NULL, type="source")

hmsic_url <- "https://cran.r-project.org/src/contrib/Archive/Hmisc/Hmisc_3.17-2.tar.gz"
install.packages(hmsic_url, repos=NULL, type="source")



## remaining packages to install WGCNA
tmp_url <-"https://cran.r-project.org/src/contrib/Archive/dynamicTreeCut/dynamicTreeCut_1.62.tar.gz"
install.packages(tmp_url, repos=NULL, type="source")

tmp_url <-"https://cran.r-project.org/src/contrib/Archive/fastcluster/fastcluster_1.1.16.tar.gz"
install.packages(tmp_url, repos=NULL, type="source")

tmp_url <-"https://cran.r-project.org/src/contrib/Archive/matrixStats/matrixStats_0.50.1.tar.gz"
install.packages(tmp_url, repos=NULL, type="source")

packageurl <- "https://cran.r-project.org/src/contrib/Archive/WGCNA/WGCNA_1.51.tar.gz"
install.packages(packageurl, repos=NULL, type="source")

## install sfsmisc
packageurl <- "https://cran.r-project.org/src/contrib/Archive/sfsmisc/sfsmisc_1.1-0.tar.gz"
install.packages(packageurl, repos=NULL, type="source")

## install estimate 
install.packages("http://download.r-forge.r-project.org/src/contrib/estimate_1.0.13.tar.gz")

# install GSVA version 1.22.4 for Bioconductor version 3.4   1.24.1
#install.packages("https://bioconductor.org/packages/3.5/bioc/src/contrib/GSVA_1.24.2.tar.gz")
#biocLite("GSVA")