clean:
	@rm -f */version.txt .coverage
	@find . -name '__pycache__' |xargs rm -fr {} \;
	@rm -fr build dist .eggs .pytest_cache

# Development workflow

dev_install:
	@echo "Install Python necessary packages"
	@pip install -r requirements.txt 

download_models:
	@echo "Download necessary models"
	@echo "Put the pre-trained photo2cartoon model photo2cartoon_weights.pt into models folder (update on may 4, 2020)"
	@wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1MILr0SBjH-qln9EdV5J98DFaWkhSMeJJ' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1MILr0SBjH-qln9EdV5J98DFaWkhSMeJJ" -O ./models/photo2cartoon_weights.pt && rm -rf /tmp/cookies.txt
	@echo "Place the head segmentation model seg_model_384.pb in utils folder"
	@wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1zfFAFgx72PK_V4TNGT1TiC55R2njs_Y1' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1zfFAFgx72PK_V4TNGT1TiC55R2njs_Y1" -O ./utils/seg_model_384.pb && rm -rf /tmp/cookies.txt
	@echo "Put the pre-trained face recognition model model_mobilefacenet.pth into models folder"
	@wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1GnDPPPcds_iPpdZwcvejVVP7gclRGPEd' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1GnDPPPcds_iPpdZwcvejVVP7gclRGPEd" -O ./models/model_mobilefacenet.pth && rm -rf /tmp/cookies.txt
	@echo "Put the photo2cartoon onnx model photo2cartoon_weights.onnx into models folder"
	@wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1t7BXBEo6tfntk0_9qHSQXRRhZYkdjduF' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1t7BXBEo6tfntk0_9qHSQXRRhZYkdjduF" -O ./models/photo2cartoon_weights.onnx && rm -rf /tmp/cookies.txt