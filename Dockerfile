# Start with Ubuntu base image
FROM ubuntu:14.04

RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:jonathonf/python-2.7
RUN add-apt-repository -y ppa:ross-kallisti/python-urllib3
RUN apt-get update
RUN apt-get install -y python2.7
RUN apt-get install -y python2.7-dev

# Install git, apt-add-repository and dependencies for iTorch
RUN apt-get update && apt-get install -y \
  git \
  software-properties-common \
  libssl-dev \
  libzmq3-dev \
  python-zmq \
  sudo

#RUN apt-get update
#RUN apt-get install -y software-properties-common
#RUN add-apt-repository ppa:jonathonf/python-2.7
#RUN apt-get update
#RUN apt-get install -y python2.7
#RUN apt-get install -y python2.7-dev
#RUN apt-get install -y python-pkg-resources=3.3-1ubuntu1
#RUN apt-get install -y python-setuptools
#RUN apt -f install
#RUN apt -y dist-upgrade
#RUN apt-get autoremove
#RUN apt-get update 
#RUN apt-get upgrade
#RUN apt-get install -y python-pip
#RUN apt-get install -y python-dev
#RUN apt-get install -y build-essential

RUN apt-get update
RUN apt-get clean
RUN apt-get autoremove
RUN apt-get update -y && sudo apt-get dist-upgrade -y
RUN apt-get install -f libpython2.7-stdlib
RUN apt-get upgrade -y python-six python-chardet python-urllib3 python-requests
RUN apt-get install -y python-pip

RUN pip install --upgrade pip
RUN apt-get install -y python-dev

RUN pip install --ignore-installed six
RUN pip install --ignore-installed pyzmq

# Install git, apt-add-repository and dependencies for iTorch
RUN apt-get update && apt-get install -y \
  git \
  ipython3 \
  libssl-dev \
  libzmq3-dev

#RUN pip install 'Tornado>=4.0.0,<5.0.0'

# Install Jupyter Notebook for iTorch
RUN pip install notebook ipywidgets

# Run Torch7 installation scripts
RUN git clone https://github.com/torch/distro.git /root/torch --recursive && cd /root/torch && \
  bash install-deps && \
  ./install.sh

# Set ~/torch as working directory
WORKDIR /root/torch

# Export environment variables manually
ENV LUA_PATH='/root/.luarocks/share/lua/5.1/?.lua;/root/.luarocks/share/lua/5.1/?/init.lua;/root/torch/install/share/lua/5.1/?.lua;/root/torch/install/share/lua/5.1/?/init.lua;./?.lua;/root/torch/install/share/luajit-2.1.0-beta1/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua'
ENV LUA_CPATH='/root/.luarocks/lib/lua/5.1/?.so;/root/torch/install/lib/lua/5.1/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so'
ENV PATH=/root/torch/install/bin:$PATH
ENV LD_LIBRARY_PATH=/root/torch/install/lib:$LD_LIBRARY_PATH
ENV DYLD_LIBRARY_PATH=/root/torch/install/lib:$DYLD_LIBRARY_PATH
ENV LUA_CPATH='/root/torch/install/lib/?.so;'$LUA_CPATH

# install necessary packages
RUN luarocks install torch
RUN luarocks install nn
RUN luarocks install image
RUN luarocks install lua-cjson

# fetch fast neural style
RUN git clone https://github.com/avaranovich/fast-neural-style.git fast-neural-style

# create volume for the images
RUN mkdir /images
VOLUME /images

# Download models
RUN cd fast-neural-style; bash models/download_style_transfer_models.sh

# Prepare execution environment
WORKDIR /fast-neural-style/

#RUN ls -al /root/torch/install/lib/lua/5.1/
CMD th fast_neural_style.lua print_iter 1

# set neural_style as entrypoint
#ENTRYPOINT [ "th",  "fast_neural_style.lua" ]
