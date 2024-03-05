#!/bin/bash

# Kiểm tra xem có đủ đối số không
if [ "$#" -ne 1 ]; then
    echo "Sử dụng: $0 <tên_file_pdf>"
    exit 1
fi

# Đường dẫn đến tệp PDF được truyền từ dòng lệnh
PDF_FILE="$1"

# Kiểm tra xem tệp PDF tồn tại hay không
if [ ! -f "$PDF_FILE" ]; then
    echo "Lỗi: Tệp PDF '$PDF_FILE' không tồn tại."
    exit 1
fi

# Biến đếm để tạo tên tệp duy nhất
count=0

# Trích xuất hình ảnh từ tệp PDF
for page in $(seq 0 $(pdfinfo "$PDF_FILE" | awk '/Pages/ {print $2}')); do
    pdfimages -png -f $page -l $page "$PDF_FILE" "images/img_$count"
    count=$((count+1))
done

echo "Trích xuất hình ảnh từ PDF thành công."
