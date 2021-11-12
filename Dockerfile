FROM nvidia/cuda:11.0-base as base

# general environment for docker
ENV DEBIAN_FRONTEND=noninteractive

# enable sudo
RUN apt-get update && apt-get install -y --no-install-recommends sudo curl vim && rm -rf /var/lib/apt/lists/*

# create docker user
RUN useradd -m -s /bin/bash -u 999 docker && echo "docker:docker" | chpasswd && adduser docker sudo

# enable passwordless sudo
RUN echo "docker ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/docker

USER    docker
WORKDIR /home/docker

ENV PATH="/home/docker/.local/opt/miniconda/bin:${PATH}"
RUN curl -LO https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/.local/opt/miniconda \
    && rm Miniconda3-latest-Linux-x86_64.sh \
    && conda init

# fetch latest
#RUN --mount=type=cache,target=/home/docker/.local/opt/miniconda/pkgs,uid=999 \
#    conda install --freeze-installed --strict-channel-priority -c pytorch pytorch::pytorch cudatoolkit numpy scipy ipython tqdm

# install from environment.yml
COPY --chown=docker:docker environment.yml .
RUN --mount=type=cache,target=/home/docker/.local/opt/miniconda/pkgs,uid=999 \
    conda env update -n base -f environment.yml
