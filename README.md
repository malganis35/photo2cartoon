<div align='center'>
  <img src='./images/title.png'>
</div>

# Photo to Cartoon

[中文版](README_CH.md) | English Version

[Minivision](https://www.minivision.cn/)'s photo-to-cartoon translation project is opened source in this repo, you can try our WeChat mini program "AI Cartoon Show" via scanning the QR code below.

<div>
  <img src='./images/QRcode.jpg' height='150px' width='150px'>
</div>

You can also try on this page: [https://ai.minivision.cn/#/coreability/cartoon](https://ai.minivision.cn/#/coreability/cartoon)

Alternatively, we propose also a demonstration on Google Colab: https://colab.research.google.com/drive/1H20Xhsq1NBr2h_tKv6tiIuEZE236c_oH?usp=sharing

**Updates**
- `2021.12.2`: [Run this model on Replicate](https://beta.replicate.ai/hao-qiang/photo2cartoon).
- `2020.12.2`: [photo2cartoon-paddle](https://github.com/minivision-ai/photo2cartoon-paddle) is released.
- `2020.12.1`: Add onnx test model, see [test_onnx.py](./test_onnx.py) for details.

## Introduce

The aim of portrait cartoon stylization is to transform real photos into cartoon images with portrait's ID information and texture details. We use Generative Adversarial Network method to realize the mapping of picture to cartoon. Considering the difficulty in obtaining paired data and the non-corresponding shape of input and output, we adopt unpaired image translation fashion.

The results of CycleGAN, a classic unpaired image translation method, often have obvious artifacts and are unstable. Recently, Kim et al. propose a novel normalization function (AdaLIN) and an attention module in paper "U-GAT-IT" and achieve exquisite selfie2anime results.

Different from the exaggerated anime style, our cartoon style is more realistic and contains unequivocal ID information. To this end, we add a Face ID Loss (cosine distance of ID features between input image and cartoon image) to reach identity invariance. 

We propose a Soft Adaptive Layer-Instance Normalization (Soft-AdaLIN) method which fuses the statistics of encoding features and decoding features in de-standardization. 

Based on U-GAT-IT, two hourglass modules are introduced before encoder and after decoder to improve the performance in a progressively way.

We also pre-process the data to a fixed pattern to help reduce the difficulty of optimization. For details, see below.

<div align='center'>
  <img src='./images/results.png'>
</div>

## Start

### Easy install on Linux (Automatic with Makefile)
1. Clone the project
```
git clone git@github.com:malganis35/photo2cartoon.git
```

1.bis (optional) If you have not install pyenv, use:
```
make Linux
```

2. Build the project (environment, requirements, etc.)
```
make build
```

3. Download all the models in the right folders
```
make download-models
```

4. If you need to clean your environments:
```
make clean-env
```

5. If you need all the help and commands in the Makefile
```
make
```


### Easy install on Linux (Semi-Automatic)

1. Clone the project
```
git clone git@github.com:malganis35/photo2cartoon.git
```

2. Create a virtual environment ``cartoon`` with ``pyenv`` and activate it
```
pyenv virtualenv system cartoon
pyenv activate cartoon
```
*Alternatively you can run ``pyenv local cartoon`` to automatically launch the environment when you are placed in this folder*

3. Install the requirements packages
```
pip install -r requirements.txt 
```

4. Download the model as described below

### Download (Automatic)
*Note: Large download of files on Google Drive should be using the syntax in this article: https://medium.com/@acpanjan/download-google-drive-files-using-wget-3c2c025a8b99*

1. Put the pre-trained photo2cartoon model **photo2cartoon_weights.pt** into `models` folder (update on may 4, 2020).
```
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1MILr0SBjH-qln9EdV5J98DFaWkhSMeJJ' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1MILr0SBjH-qln9EdV5J98DFaWkhSMeJJ" -O ./models/photo2cartoon_weights.pt && rm -rf /tmp/cookies.txt
```

2. Place the head segmentation model **seg_model_384.pb** in `utils` folder. 
```
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1zfFAFgx72PK_V4TNGT1TiC55R2njs_Y1' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1zfFAFgx72PK_V4TNGT1TiC55R2njs_Y1" -O ./utils/seg_model_384.pb && rm -rf /tmp/cookies.txt
```

3. Put the pre-trained face recognition model **model_mobilefacenet.pth** into `models` folder (From [InsightFace_Pytorch](https://github.com/TreB1eN/InsightFace_Pytorch)).
```
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1GnDPPPcds_iPpdZwcvejVVP7gclRGPEd' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1GnDPPPcds_iPpdZwcvejVVP7gclRGPEd" -O ./models/model_mobilefacenet.pth && rm -rf /tmp/cookies.txt
```

4. Put the photo2cartoon onnx model **photo2cartoon_weights.onnx** into `models` folder.
```
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1t7BXBEo6tfntk0_9qHSQXRRhZYkdjduF' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1t7BXBEo6tfntk0_9qHSQXRRhZYkdjduF" -O ./models/photo2cartoon_weights.onnx && rm -rf /tmp/cookies.txt
```

### Download (Manual)

[Google Drive](https://drive.google.com/open?id=1lsQS8hOCquMFKJFhK_z-n03ixWGkjT2P) | [Baidu Cloud](https://pan.baidu.com/s/1MsT3-He3UGipKhUi4OcCJw) acess code: y2ch

1. Put the pre-trained photo2cartoon model **photo2cartoon_weights.pt** into `models` folder (update on may 4, 2020).
2. Place the head segmentation model **seg_model_384.pb** in `utils` folder. 
3. Put the pre-trained face recognition model **model_mobilefacenet.pth** into `models` folder (From [InsightFace_Pytorch](https://github.com/TreB1eN/InsightFace_Pytorch)).
4. Open-source cartoon dataset **`cartoon_data/`** contains `trainB` and `testB`.
5. Put the photo2cartoon onnx model **photo2cartoon_weights.onnx** [Google Drive](https://drive.google.com/file/d/1PhwKDUhiq8p-UqrfHCqj257QnqBWD523/view?usp=sharing) into `models` folder.

### Test

Please use a young Asian woman photo.
```
python test.py --photo_path ./images/photo_test.jpg --save_path ./images/cartoon_result.png
```

### Test onnx model
```
python test_onnx.py --photo_path ./images/photo_test.jpg --save_path ./images/cartoon_result.png
```

### Train
**1.Data**

Training data contains portrait photos (domain A) and cartoon images (domain B). The following process can help reduce the difficulty of optimization.
- Detect face and its landmarks.
- Face alignment according to landmarks.
- expand the bbox of landmarks and crop face.
- remove the background by semantic segment.

<div align='center'>
  <img src='./images/data_process.jpg'>
</div>

We provide 204 cartoon images, besides, you need to prepare about 1,000 young Asian women photos and pre-process them by following command.

```
python data_process.py --data_path YourPhotoFolderPath --save_path YourSaveFolderPath
```

The `dataset` directory should look like this:
```
├── dataset
    └── photo2cartoon
        ├── trainA
            ├── xxx.jpg
            ├── yyy.png
            └── ...
        ├── trainB
            ├── zzz.jpg
            ├── www.png
            └── ...
        ├── testA
            ├── aaa.jpg 
            ├── bbb.png
            └── ...
        └── testB
            ├── ccc.jpg 
            ├── ddd.png
            └── ...
```

**2.Train**

Train from scratch:
```
python train.py --dataset photo2cartoon
```

Load pre-trained weights:
```
python train.py --dataset photo2cartoon --pretrained_weights models/photo2cartoon_weights.pt
```

Train with Multi-GPU:
```
python train.py --dataset photo2cartoon --batch_size 4 --gpu_ids 0 1 2 3
```

## Q&A
#### Q：Why is the result of this project different from mini program?

A: For better performance, we customized the cartoon data (about 200 images) when training model for mini program. We also improved input size for high definition. Besides, we adopted our internal recognition model to calculate Face ID Loss which is much better than the open-sourced one used in this repo.

#### Q: How to select best model?

A: We trained model about 200k iterations, then selected best model according to FID metric.

#### Q: About face recognition model.

A: We found that the experimental result calculated Face ID Loss by our internal recognition model is much better than the open-sourced one. You can try to remove Face ID Loss if the result is unstable.

#### Q：Can I use the segmentation model to predict half-length portrait?
A：No. The model is trained for croped face specifically.

## Reference

U-GAT-IT: Unsupervised Generative Attentional Networks with Adaptive Layer-Instance Normalization for Image-to-Image Translation [[Paper](https://arxiv.org/abs/1907.10830)][[Code](https://github.com/znxlwm/UGATIT-pytorch)]

[InsightFace_Pytorch](https://github.com/TreB1eN/InsightFace_Pytorch)
