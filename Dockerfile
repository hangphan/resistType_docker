#################################################################
# Source Image
FROM ubuntu:16.04

# Set noninterative mode
ENV DEBIAN_FRONTEND noninteractive

################## BEGIN INSTALLATION ######################
LABEL version="1"
LABEL software="resistType"
LABEL software.version="0.1"
LABEL description="Tools for bacterial sequence analysis, focusing on enterobacteriaceae"
LABEL website="https://github.com/hangphan/resistType_docker"
LABEL documentation="https://github.com/hangphan/resistType_docker"
LABEL license="https://github.com/hangphan/resistType_docker"
LABEL tags="Genomics"

# Maintainer
MAINTAINER Hang Phan <hangphan@gmail.com>


# add apt mirror
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bkp && \
    bash -c 'echo -e "deb mirror://mirrors.ubuntu.com/mirrors.txt xenial main restricted universe multiverse\n\
deb mirror://mirrors.ubuntu.com/mirrors.txt xenial-updates main restricted universe multiverse\n\
deb mirror://mirrors.ubuntu.com/mirrors.txt xenial-backports main restricted universe multiverse\n\
deb mirror://mirrors.ubuntu.com/mirrors.txt xenial-security main restricted universe multiverse\n\n" > /etc/apt/sources.list' && \
    cat /etc/apt/sources.list.bkp >> /etc/apt/sources.list && \
        cat /etc/apt/sources.list

# apt update and install global requirements
RUN apt-get clean all
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y  \
    	    git \
	    default-jre \
	    python \
	    python-setuptools \
	    python-dev \
	    build-essential \
	    wget \
	    zip && \
	    apt-get clean && \
	    apt-get purge && \
	    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
	    easy_install pip && \
	    pip install --upgrade pip && \
	    pip install pysam && \
	    pip install BioPython && \
	    pip install numpy


RUN mkdir /data /config
# Add user biodocker with password biodocker
RUN groupadd fuse && \
    useradd --create-home --shell /bin/bash --user-group --uid 1000 --groups sudo,fuse biodocker && \
    echo `echo "biodocker\nbiodocker\n" | passwd biodocker` && \
    chown biodocker:biodocker /data && \
    chown biodocker:biodocker /config

# Change user
USER biodocker

ENV BIN_FOLDER=/home/biodocker/bin
ENV RESIST_TYPE_FOLDER=/home/biodocker/resistType_docker

# Install bowtie2
RUN mkdir -p $BIN_FOLDER &&\
    cd $BIN_FOLDER &&\
    wget https://github.com/BenLangmead/bowtie2/releases/download/v2.2.9/bowtie2-2.2.9-linux-x86_64.zip &&\
    unzip bowtie2-2.2.9-linux-x86_64.zip -d ${BIN_FOLDER}

# get resistType scripts
RUN echo "cache-bust" &&\
   git clone https://github.com/hangphan/resistType_docker ${RESIST_TYPE_FOLDER}

# ENV path for bowtie2
ENV PATH ${BIN_FOLDER}/bowtie2-2.2.9:$PATH
# ENV path for scripts
ENV PATH ${RESIST_TYPE_FOLDER}/bin:${RESIST_TYPE_FOLDER}/src:$PATH

RUN cd $RESIST_TYPE_FOLDER/resources &&\
    tar -zxvf SPAdes-3.10.0-Linux.tar.gz -C $RESIST_TYPE_FOLDER/resources/ &&\
    rm SPAdes-3.10.0-Linux.tar.gz

# ENV path for SPAdes
ENV PATH $RESIST_TYPE_FOLDER/resources/SPAdes-3.10.0-Linux/bin:$PATH

WORKDIR /data/
VOLUME /data/
CMD ["resistType_v0.1.py", "-h"]
