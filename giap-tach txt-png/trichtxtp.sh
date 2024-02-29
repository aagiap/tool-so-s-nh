#!/bin/bash

# Tên tệp PDF và TXT
pdf_file="$1"
txt_file="${pdf_file%.*}.txt"

# Chuyển đổi từ PDF sang TXT bằng pdftotext
pdftotext "$pdf_file" "$txt_file"

# Loại bỏ thông tin hình ảnh trong tệp TXT
grep -vE '^\!\[.*\]\(.*\)' "$txt_file" > "${txt_file}_without_images.txt"

echo "Conversion complete. TXT file without image information created: ${txt_file}_without_images.txt"
