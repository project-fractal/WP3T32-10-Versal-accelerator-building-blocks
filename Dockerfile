ARG UBUNTU_VERSION

FROM ubuntu:${UBUNTU_VERSION}

# Required build arguments:
ARG PETA_VERSION

# Optional build arguments:
ARG UBUNTU_MIRROR
ARG PETA_RUN_FILE="petalinux-v${PETA_VERSION}-final-installer.run"

ENV DEBIAN_FRONTEND=noninteractive

RUN echo $PETA_VERSION

RUN echo $PETA_RUN_FILE

RUN [ -z "${UBUNTU_MIRROR}" ] || sed -i.bak s/archive.ubuntu.com/${UBUNTU_MIRROR}/g /etc/apt/sources.list

# Install essential packages

RUN apt-get update && apt-get install -y \
  sudo \
  expect \
  rsync \
  locales \
  bc \
  xxd && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Install 32-bit libraries:

RUN dpkg --add-architecture i386
RUN apt-get update && apt-get install -y \
  xinetd \
  tftpd \
  tftp && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Ínstall dependencies:

RUN apt-get update && apt-get install -y \
  iproute2 \
  gawk \
  python3 \
  python \
  build-essential \
  gcc \
  git \
  make \
  net-tools \
  libncurses5-dev \
  tftpd \
  zlib1g-dev \
  libssl-dev \
  flex bison \
  libselinux1 \
  gnupg \
  wget \
  git-core \
  diffstat \
  chrpath \
  socat \
  xterm \
  autoconf \
  libtool \
  tar unzip \
  texinfo \
  zlib1g-dev \
  gcc-multilib \
  automake \
  zlib1g:i386 \
  screen \
  pax \
  gzip \
  cpio \
  python3-pip \
  python3-pexpect \
  xz-utils \
  debianutils \
  iputils-ping \
  python3-git \
  python3-jinja2 \
  libegl1-mesa \
  libsdl1.2-dev \
  pylint3 && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Install & configure TFTP server

COPY src/tftp /etc/xinetd.d/tftp
RUN mkdir -p /tftpboot && \
  chmod -R 777 /tftpboot && \
  chown -R nobody /tftpboot
RUN /etc/init.d/xinetd stop && \
  /etc/init.d/xinetd start

# Make a 'xilinx' user

RUN adduser --disabled-password --gecos '' xilinx && \
  usermod -aG sudo xilinx && \
  echo "xilinx ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers

RUN locale-gen en_US.UTF-8 && update-locale

# Make /bin/sh symlink to bash instead of dash:

RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN dpkg-reconfigure dash

# Install PetaLinux

COPY src/accept-eula.sh /

COPY src/${PETA_RUN_FILE} /

RUN chmod a+rx /${PETA_RUN_FILE} && \
  chmod a+rx /accept-eula.sh

RUN mkdir -p /tools/Xilinx/PetaLinux/${PETA_VERSION}/ && \
  chmod 777 /tmp /tools/Xilinx/PetaLinux/${PETA_VERSION}/ && \
  chown -R xilinx:xilinx /tools/Xilinx/PetaLinux/${PETA_VERSION}/

WORKDIR /tmp
RUN sudo -u xilinx -i /accept-eula.sh /${PETA_RUN_FILE} /tools/Xilinx/PetaLinux/${PETA_VERSION}

RUN rm -f /${PETA_RUN_FILE} /accept-eula.sh

# Configure user 'xilinx'

USER xilinx
ENV HOME /home/xilinx
ENV LANG en_US.UTF-8

# Add PetaLinux tools to path

RUN echo "source /tools/Xilinx/PetaLinux/${PETA_VERSION}/settings.sh" >>/home/xilinx/.bashrc

# Set intial working directory (volume)

RUN mkdir /home/xilinx/petalinux
WORKDIR /home/xilinx/petalinux
