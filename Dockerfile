FROM nvidia/cuda:11.0-base as base

# general environment for docker
ENV DEBIAN_FRONTEND=noninteractive

# enable sudo
RUN apt-get update && apt-get install -y --no-install-recommends sudo curl vim

# create docker user
RUN useradd -m -s /bin/bash -u 999 docker && echo "docker:docker" | chpasswd && adduser docker sudo

# enable passwordless sudo
RUN echo "docker ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/docker

USER    docker
WORKDIR /home/docker

FROM base as builder

ENV PATH="/home/docker/.local/miniconda/bin:${PATH}"
RUN curl -LO https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/.local/miniconda \
    && rm Miniconda3-latest-Linux-x86_64.sh \
    && conda init

COPY --chown=docker:docker environment.yml .

RUN conda env update -n base -f environment.yml && rm environment.yml && conda clean -afy
