FROM openjdk:10.0.1-10-jdk

RUN apt-get update
RUN apt-get install -y python3-pip

#RUN pip3 install --no-cache-dir notebook==5.5.* jupyterlab==0.32.*
RUN pip3 install --no-cache-dir notebook==5.* jupyterlab==0.35.* jupyter_contrib_nbextensions RISE

USER root

# Download the kernel release
RUN curl -L https://github.com/SpencerPark/IJava/releases/download/v1.2.0/ijava-1.2.0.zip > ijava-kernel.zip

# Unpack and install the kernel
RUN unzip ijava-kernel.zip -d ijava-kernel \
  && cd ijava-kernel \
  && python3 install.py --sys-prefix 

#Set up nbextensions
RUN jupyter-nbextension install rise --py --system
RUN jupyter-nbextension enable rise --py --system
RUN jupyter contrib nbextension install --system
RUN jupyter nbextension enable hide_input/main

# Set up the user environment

ENV NB_USER marcos
ENV NB_UID 1000
ENV HOME /home/$NB_USER

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid $NB_UID \
    $NB_USER

COPY . $HOME
RUN chown -R $NB_UID $HOME

USER $NB_USER

# Launch the notebook server
WORKDIR $HOME
CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
