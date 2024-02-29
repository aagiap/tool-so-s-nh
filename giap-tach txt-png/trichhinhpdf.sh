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

# Tạo thư mục mới để lưu hình ảnh
mkdir -p images

# Trích xuất hình ảnh từ tệp PDF
pdfimages -png "$PDF_FILE" img

echo "Trích xuất hình ảnh từ PDF thành công."

