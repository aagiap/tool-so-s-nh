#!/bin/bash

# Tạo thư mục images nếu nó chưa tồn tại
if [ ! -d "images" ]; then
    mkdir images
    echo "Thư mục 'images' đã được tạo."
else
    echo "Thư mục 'images' đã tồn tại."
fi

# Tạo thư mục text nếu nó chưa tồn tại
if [ ! -d "text" ]; then
    mkdir text
    echo "Thư mục 'text' đã được tạo."
else
    echo "Thư mục 'text' đã tồn tại."
fi


