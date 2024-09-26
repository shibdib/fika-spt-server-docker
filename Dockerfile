FROM debian:bookworm as build

# SPT Server git tag or sha
ARG SPT_SERVER_SHA=3.9.8

USER root
RUN apt update && apt install -y --no-install-recommends \
    vim \
    curl \
    ca-certificates \
    git \
    git-lfs \
    unzip

# asdf version manager
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.1
RUN ASDF_DIR=$HOME/.asdf/ \. "$HOME/.asdf/asdf.sh" \
    && asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git \
    && asdf install nodejs 20.11.1

WORKDIR /
RUN git clone https://dev.sp-tarkov.com/SPT/Server.git spt

WORKDIR /spt/project
RUN git checkout $SPT_SERVER_SHA
RUN git lfs pull

ENV PATH="$PATH:/root/.asdf/bin"
ENV PATH="$PATH:/root/.asdf/shims"
RUN asdf global nodejs 20.11.1

RUN node -v
RUN npm install
RUN npm run build:release

RUN mv build /opt/build
RUN rm -rf /spt

WORKDIR /opt/server

COPY entrypoint.sh /usr/bin/entrypoint
ENTRYPOINT ["/usr/bin/entrypoint"]
