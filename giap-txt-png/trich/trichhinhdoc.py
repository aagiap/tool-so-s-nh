from docx import Document
import sys
import os

def extract_images_from_docx(docx_file):
    doc = Document(docx_file)
    images = []

    for rel in doc.part.rels.values():
        if "image" in rel.reltype:
            image_data = rel.target_part.blob
            images.append(image_data)

    return images

# Danh sách các tệp DOCX từ dòng lệnh
docx_files = sys.argv[1:]

for docx_file in docx_files:
    # Trích xuất hình ảnh từ mỗi tệp DOCX
    images = extract_images_from_docx(docx_file)

    # Lưu hình ảnh thành các tệp PNG
    for i, image in enumerate(images):
        with open(os.path.join("images", f"{os.path.basename(docx_file)}.png"), "wb") as f:
            f.write(image)

print("Extraction complete.")

