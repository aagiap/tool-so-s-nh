#!/bin/bash

# Tên tệp DOCX và TXT
docx_file="$1"
txt_file="text/$(basename "${docx_file%.*}").txt"

# Chuyển đổi từ DOCX sang TXT bằng pandoc
pandoc -s "$docx_file" -o "$txt_file"

echo "Hoàn thành chuyển đổi: $txt_file"
