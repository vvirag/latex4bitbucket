FROM ubuntu:17.04
MAINTAINER Virag Varga <virag.varga.it@gmail.com>
ENV DEBIAN_FRONTEND noninteractive

# update software repository
RUN apt-get update -q

# install latex
RUN apt-get install -qy \
	texlive-latex-extra  \
	texlive-fonts-extra  \
	texlive-bibtex-extra  \
	texlive-extra-utils \
    texlive-science
    
# install some additional tools    
RUN apt-get install -qy make latexmk git 
    
# install python and gdcp prerequisites
RUN apt-get install -qy python python-pip
RUN pip install pydrive && pip install backoff
RUN pip install --upgrade google-api-python-client 

# install gdcp
RUN mkdir -p /usr/src/gdcp \
	&& cd /usr/src/ \
	&& git clone https://github.com/ctberthiaume/gdcp.git \
	&& cp gdcp/gdcp /usr/bin
	
# prepare gdcp config dir
RUN mkdir $HOME/.gdcp

# setup gdcp settings
RUN echo "client_config_file: "$HOME"/.gdcp/client_secrets.json" > $HOME/.gdcp/settings.yaml \
	&&	echo "get_refresh_token: True" >> $HOME/.gdcp/settings.yaml \
	&&	echo "save_credentials: True" >> $HOME/.gdcp/settings.yaml \
	&&	echo "save_credentials_backend: file" >> $HOME/.gdcp/settings.yaml \
	&&	echo "save_credentials_file: "$HOME"/.gdcp/credentials.json" >> $HOME/.gdcp/settings.yaml \
	&&	echo "client_config_backend: file" >> $HOME/.gdcp/settings.yaml
