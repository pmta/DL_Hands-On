FROM nvidia/cuda:11.1-devel-ubuntu20.04

ENV user=anaconda
ENV group=anaconda
ENV UID=1234
ENV GID=1234
ENV JUPYTERPORT=8888

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH
ENV TZ=Europe/Helsinki


# Install recuired OS packages
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update --fix-missing && apt-get install -y wget \
bzip2 ca-certificates libglib2.0-0 libxext6 libsm6 ffmpeg libxrender1 git mercurial subversion \
cmake zlib1g-dev iproute2 sudo 

#COPY sudoers /etc/sudoers
#RUN chown root:root /etc/sudoers

# Create user and group
RUN groupadd --gid ${GID} ${group} && useradd -u ${UID} -g ${GID} -G sudo -d /home/${user} ${user} && mkdir -p /home/${user}
RUN echo ${user}:P4ssw0rd#1 | chpasswd

# Anaconda
RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-2020.11-Linux-x86_64.sh -O ~/anaconda.sh && \
/bin/bash ~/anaconda.sh -b -p /opt/conda && rm ~/anaconda.sh && \
ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
echo ". /opt/conda/etc/profile.d/conda.sh" >> /home/${user}/.bashrc && \
conda install pytorch=1.7.0 torchvision cuda100 keras-gpu -c pytorch
#pip install torch==1.7.0+cu110 torchvision==0.8.1+cu110 torchaudio===0.7.0 -f https://download.pytorch.org/whl/torch_stable.html

# Python packages
RUN pip3 install gym atari-py opencv-python tensorboard pytorch-ignite tensorboardX ptan

# Folder to keep jupyter notebooks 
RUN mkdir -p /home/${user}/notebooks

# Include example notebook
COPY RecurrentNetworks.ipynb /home/${user}/notebooks

RUN echo "conda activate base" >> /home/${user}/.bashrc
RUN chown -R ${user}:${group} /home/${user}

USER ${user}:${group}

# Sources 
VOLUME ["/src"]

# Jupyter notebooks
WORKDIR /home/${user}/notebooks
EXPOSE ${JUPYTERPORT}

# Run Jupyter
ENTRYPOINT jupyter-notebook --ip `ip route list scope link | awk '{ print $7 }'` --port=${JUPYTERPORT} -y --no-browser --NotebookApp.disable_check_xsrf=True --notebook-dir=/home/${user}/notebooks --log-level=INFO
