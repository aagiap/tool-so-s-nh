#!/bin/bash

# Tên tệp DOCX và TXT
docx_file="$1"
txt_file="${docx_file%.*}.txt"

# Chuyển đổi từ DOCX sang TXT bằng pandoc
pandoc -s "$docx_file" -o "$txt_file"

# Loại bỏ thông tin hình ảnh trong tệp TXT
grep -vE '^\!\[.*\]\(.*\)' "$txt_file" > "${txt_file}_without_images.txt"

echo "Conversion complete. TXT file without image information created: ${txt_file}_without_images.txt"
