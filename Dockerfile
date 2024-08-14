FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install essential packages and add required PPA
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    git \
    libatomic1 \
    sudo \
    software-properties-common && \
    add-apt-repository ppa:ubuntu-toolchain-r/test && \
    apt-get update && \
    apt-get install -y libstdc++6 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a new user "runcode" with sudo privileges
ARG USERNAME=runcode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USERNAME -m -s /bin/bash $USERNAME && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME && \
    mkdir -p /home/$USERNAME/workspace && \
    chown -R $USERNAME:$USERNAME /home/$USERNAME

USER $USERNAME
WORKDIR /home/$USERNAME

# Download and set up the OpenVSCode server
RUN wget https://github.com/runcode-io/openvscode-web-server/releases/download/1.91.1/openvscode-web-server-v1.91.1-linux-x64.zip && \
    unzip openvscode-web-server-v1.91.1-linux-x64.zip && \
    mv vscode-reh-web-linux-x64 .runcode && \
    rm openvscode-web-server-v1.91.1-linux-x64.zip


# Expose the necessary port
EXPOSE 8000

# Set the entrypoint to start the server
ENTRYPOINT ["./.runcode/bin/runcode-server", "--disable-workspace-trust", "--default-folder=/home/runcode/workspace", "--host=0.0.0.0"]

