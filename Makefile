# Global variables
SHELL:=/bin/bash
PROJECT=cartoon
VERSION=3.7.4
VENV=${PROJECT}-${VERSION}
VENV_DIR=$(shell pyenv root)/versions/${VENV}
PYTHON=${VENV_DIR}/bin/python
JUPYTER_ENV_NAME=${VENV}
JUPYTER_PORT=8888

# Source for a good Python Makefile: https://gist.github.com/genyrosk/2a6e893ee72fa2737a6df243f6520a6d

## --------------------------------------------------------------------------------------------------------------------
# General options
## --------------------------------------------------------------------------------------------------------------------

## Make sure you have `pyenv` and `pyenv-virtualenv` installed beforehand
##
## https://github.com/pyenv/pyenv
## https://github.com/pyenv/pyenv-virtualenv
##
## On a Mac: $ brew install pyenv pyenv-virtualenv
##
## Configure your shell with $ eval "$(pyenv virtualenv-init -)"
##

# .ONESHELL:
DEFAULT_GOAL: help
.PHONY: help run clean build venv ipykernel update jupyter

# Colors for echos 
ccend=$(shell tput sgr0)
ccbold=$(shell tput bold)
ccgreen=$(shell tput setaf 2)
ccso=$(shell tput smso)

clean:
	@rm -f */version.txt .coverage
	@find . -name '__pycache__' |xargs rm -fr {} \;
	@rm -fr build dist .eggs .pytest_cache

Darwin: ## >> install pyenv for MacOS
	brew update 
	brew install pyenv pyenv-virtualenv

Linux: ## >> install pyenv for linux
	git clone https://github.com/pyenv/pyenv.git ~/.pyenv
	echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
	echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile
	exec "$SHELL"
	. ~/.bash_profile
	echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.bash_profile

## --------------------------------------------------------------------------------------------------------------------
# General Development workflow
## --------------------------------------------------------------------------------------------------------------------

build: ##@main >> build the virtual environment with an ipykernel for jupyter and install requirements
	@echo ""
	@echo "$(ccso)--> Build $(ccend)"
	$(MAKE) install
	$(MAKE) ipykernel

clean-env: ##@setup >> remove all environment and build files
	@echo ""
	@echo "$(ccso)--> Removing virtual environment $(ccend)"
	pyenv virtualenv-delete --force ${VENV}
	rm .python-version
	rm .python-versionmake jupyter
	
venv: $(VENV_DIR) ##@setup >> setup the virtual environment

$(VENV_DIR):
	@echo "$(ccso)--> Install and setup pyenv and virtualenv $(ccend)"
	python3 -m pip install --upgrade pip
	pyenv virtualenv ${PYTHON_VERSION} ${VENV}
	echo ${VENV} > .python-version

install: venv requirements.txt ##@setup >> update requirements.txt inside the virtual environment
	@echo "$(ccso)--> Updating packages $(ccend)"
	$(PYTHON) -m pip install -r requirements.txt

ipykernel: venv ##@setup >> install a Jupyter iPython kernel using our virtual environment
	@echo ""
	@echo "$(ccso)--> Install ipykernel to be used by jupyter notebooks $(ccend)"
	$(PYTHON) -m pip install ipykernel jupyter jupyter_contrib_nbextensions
	$(PYTHON) -m ipykernel install 
					--user 
					--name=$(VENV) 
					--display-name=$(JUPYTER_ENV_NAME)
	$(PYTHON) -m jupyter nbextension enable --py widgetsnbextension --sys-prefix

jupyter: venv ##@main >> start a jupyter notebook
	@echo ""
	@"$(ccso)--> Running jupyter notebook on port $(JUPYTER_PORT) $(ccend)"
	jupyter notebook --port $(JUPYTER_PORT)

## --------------------------------------------------------------------------------------------------------------------
# Specific make for the project
## --------------------------------------------------------------------------------------------------------------------

download-models: ##@setup >> download all necessary models from Google Drive
	@echo "$(ccso)--> Download necessary models $(ccend)"
	@echo "Put the pre-trained photo2cartoon model photo2cartoon_weights.pt into models folder (update on may 4, 2020)"
	@wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1MILr0SBjH-qln9EdV5J98DFaWkhSMeJJ' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1MILr0SBjH-qln9EdV5J98DFaWkhSMeJJ" -O ./models/photo2cartoon_weights.pt && rm -rf /tmp/cookies.txt
	@echo "Place the head segmentation model seg_model_384.pb in utils folder"
	@wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1zfFAFgx72PK_V4TNGT1TiC55R2njs_Y1' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1zfFAFgx72PK_V4TNGT1TiC55R2njs_Y1" -O ./utils/seg_model_384.pb && rm -rf /tmp/cookies.txt
	@echo "Put the pre-trained face recognition model model_mobilefacenet.pth into models folder"
	@wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1GnDPPPcds_iPpdZwcvejVVP7gclRGPEd' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1GnDPPPcds_iPpdZwcvejVVP7gclRGPEd" -O ./models/model_mobilefacenet.pth && rm -rf /tmp/cookies.txt
	@echo "Put the photo2cartoon onnx model photo2cartoon_weights.onnx into models folder"
	@wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1t7BXBEo6tfntk0_9qHSQXRRhZYkdjduF' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1t7BXBEo6tfntk0_9qHSQXRRhZYkdjduF" -O ./models/photo2cartoon_weights.onnx && rm -rf /tmp/cookies.txt


## --------------------------------------------------------------------------------------------------------------------
# And add help text after each target name starting with '\#\#'
# A category can be added with @category
HELP_FUN = \
	%help; \
	while(<>) { push @{$$help{$$2 // 'options'}}, [$$1, $$3] if /^([a-zA-Z\-\$\(]+)\s*:.*\#\#(?:@([a-zA-Z\-\)]+))?\s(.*)$$/ }; \
	print "usage: make [target]\n\n"; \
	for (sort keys %help) { \
	print "${WHITE}$$_:${RESET}\n"; \
	for (@{$$help{$$_}}) { \
	$$sep = " " x (32 - length $$_->[0]); \
	print "  ${YELLOW}$$_->[0]${RESET}$$sep${GREEN}$$_->[1]${RESET}\n"; \
	}; \
	print "\n"; }

help: ##@other >> Show this help.
	@perl -e '$(HELP_FUN)' $(MAKEFILE_LIST)
	@echo ""
	@echo "Note: to activate the environment in your local shell type:"
	@echo "   $$ pyenv activate $(VENV)"

