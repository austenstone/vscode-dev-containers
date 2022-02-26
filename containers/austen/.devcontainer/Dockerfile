# [Choice] Ubuntu version (https://hub.docker.com/_/ubuntu)
ARG VARIANT=latest
ARG USERNAME=astone
FROM ubuntu:${VARIANT}

WORKDIR /home/

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York
RUN apt update && apt install -y \
  wget \
  curl \
  git \
  zsh

# oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# GH CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
RUN apt update
RUN apt install gh

# Node
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
RUN apt install -y nodejs

# Chromium
RUN apt install -y chromium-browser

RUN useradd -ms /usr/bin/zsh ${USERNAME}
USER ${USERNAME}
WORKDIR /home/${USERNAME}

# COPY . .
