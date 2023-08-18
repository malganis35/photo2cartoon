import sys
import os

# setting path for import from parent path
cdir = os.getcwd() 
print(cdir)
sys.path.append(cdir)

import streamlit as st
import numpy as np
import cv2

import torch
import numpy as np
from models import ResnetGenerator
import argparse
from utils import Preprocess

# Define the transformation function
def transform_manga(image):
    # Your manga transformation logic here
    # For demonstration, let's just invert the colors
    # transformed_image = cv2.bitwise_not(image)
    
    c2p = Photo2Cartoon()
    transformed_image = c2p.inference(image)
    
    return transformed_image

def get_image_path(img):
    # Create a directory and save the uploaded image.
    file_path = f"_tmp/{img.name}"
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    with open(file_path, "wb") as img_file:
        img_file.write(img.getbuffer())
    return file_path

# Define the class
class Photo2Cartoon:
    def __init__(self):
        self.pre = Preprocess()
        self.device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
        self.net = ResnetGenerator(ngf=32, img_size=256, light=True).to(self.device)
        
        assert os.path.exists('./models/photo2cartoon_weights.pt'), "[Step1: load weights] Can not find 'photo2cartoon_weights.pt' in folder 'models!!!'"
        params = torch.load('./models/photo2cartoon_weights.pt', map_location=self.device)
        self.net.load_state_dict(params['genA2B'])
        print('[Step1: load weights] success!')

    def inference(self, img):
        # face alignment and segmentation
        face_rgba = self.pre.process(img)
        if face_rgba is None:
            print('[Step2: face detect] can not detect face!!!')
            return None
        
        print('[Step2: face detect] success!')
        face_rgba = cv2.resize(face_rgba, (256, 256), interpolation=cv2.INTER_AREA)
        face = face_rgba[:, :, :3].copy()
        mask = face_rgba[:, :, 3][:, :, np.newaxis].copy() / 255.
        face = (face*mask + (1-mask)*255) / 127.5 - 1

        face = np.transpose(face[np.newaxis, :, :, :], (0, 3, 1, 2)).astype(np.float32)
        face = torch.from_numpy(face).to(self.device)

        # inference
        with torch.no_grad():
            cartoon = self.net(face)[0][0]

        # post-process
        cartoon = np.transpose(cartoon.cpu().numpy(), (1, 2, 0))
        cartoon = (cartoon + 1) * 127.5
        cartoon = (cartoon * mask + 255 * (1 - mask)).astype(np.uint8)
        cartoon = cv2.cvtColor(cartoon, cv2.COLOR_RGB2BGR)
        print('[Step3: photo to cartoon] success!')
        return cartoon


# Configure la page streamlit
st.set_page_config(page_title="Manga Transformer App", page_icon=":camera:", layout="wide")

# Créer une bannière en haut de la page
col1, col2 = st.columns([1, 3])  # Adjust the column ratios as needed

# Centrer verticalement l'icône du logo
with col1:
    st.empty()  # Espace vide pour centrer verticalement
    st.image("./app/images/logo_manga.png", width=200)

with col2:
    st.title("Manga Transformer App")

# Trait en gris clair
# st.markdown("---", unsafe_allow_html=True)

# Auteur et description
# st.text("Author: Mazars Data Services - Cao Tri DO, PhD")
# st.markdown("*Exemple d'une démonstration pour transformer une photo en un personne de manga*")

# Trait en gris clair
# st.markdown("---", unsafe_allow_html=True)
# st.empty()

# Streamlit app
def main():
    
    # Display a sidebar panel
    st.sidebar.title("File List")
    file_list = os.listdir("_tmp/")
    selected_file = st.sidebar.selectbox("Select an image file:", file_list)
    selected_file_path = os.path.join("_tmp", selected_file)

    # Display the selected image from the sidebar
    selected_image = cv2.imread(selected_file_path, cv2.IMREAD_COLOR)
    st.sidebar.image(selected_image, caption=selected_file, use_column_width=True, clamp=True, channels="BGR")

    # Load an image from local drive
    uploaded_image = st.file_uploader("Upload an image", type=["jpg", "png", "jpeg"])
    
    if uploaded_image is not None:
        print("Use the uploaded image from the sidebar as the main image")
        main_image = np.array(bytearray(uploaded_image.read()), dtype=np.uint8)
        main_image = cv2.imdecode(main_image, 1)  # Read the image in color
        # image = cv2.cvtColor(cv2.imread(uploaded_image), cv2.COLOR_BGR2RGB)

        file_path = get_image_path(uploaded_image)
        print(file_path)
        image_for_transformation = cv2.cvtColor(cv2.imread(file_path), cv2.COLOR_BGR2RGB)

        
    
        if main_image is not None:
            # Display original image on the left
            col1, col2 = st.columns(2)
            col1.subheader("Original Image")
            col1.image(main_image, width=500, clamp=True, channels="BGR")

            # Add a button to transform the image
            if st.button("Transform"):
                transformed_image = transform_manga(image_for_transformation)

                # Display transformed image on the right
                col2.subheader("Transformed Image")
                col2.image(transformed_image, width=500, clamp=True, channels="BGR")
                cv2.imwrite("tmp_result.png", transformed_image)
                
                # Add a button to save the transformed image
                if st.button("Save Transformed Image"):
                    st.image(transformed_image, caption='Transformed Image', use_column_width=True, clamp=True, channels="BGR", output_format="PNG")
                    st.download_button(
                        label="Download Transformed Image",
                        data=transformed_image,
                        file_name="transformed_image.png",
                        mime="image/png"
                    )

if __name__ == "__main__":
    main()


