#!/bin/bash

# Tên tệp PDF và TXT
pdf_file="$1"
txt_file="text/$(basename ${pdf_file%.*}).txt"

# Chuyển đổi từ PDF sang TXT bằng pdftotext
pdftotext "$pdf_file" "$txt_file"

echo "Conversion complete. TXT file created: ${txt_file}"

