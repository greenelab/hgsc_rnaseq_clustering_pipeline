FROM continuumio/miniconda3:4.10.3

# Install Ubuntu dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
		git \
        ed \		
		less \
		locales \
		vim-tiny \
		wget \
        ca-certificates \
		bison \
		flex \
		apt-utils \
		gawk \
		libcurl4-openssl-dev \
		libxml2-dev\
		libssl-dev


# Install Sleipnir
RUN apt-get install -y --no-install-recommends \
		mercurial \
		gengetopt \
		libboost-regex-dev \
		libboost-graph-dev \
		liblog4cpp5-dev \
		build-essential \
		libgsl0-dev

RUN apt-get install -y --no-install-recommends \
		gfortran \
		zlib1g-dev


# install R dependencies
COPY ./environment.yml /tmp/environment.yml
COPY ./install_custom.R /tmp/install_custom.R

RUN conda install -c conda-forge mamba
RUN mamba env create -f /tmp/environment.yml
RUN conda run -n hgsc_subtypes R --no-save < /tmp/install_custom.R

RUN wget -nv http://download.joachims.org/svm_perf/current/svm_perf.tar.gz \
	--directory-prefix svmperf/
RUN cd svmperf && tar -xf svm_perf.tar.gz && make

WORKDIR /app

COPY . /app

CMD ["/app/aaces_subtypes_pipeline.sh"]
