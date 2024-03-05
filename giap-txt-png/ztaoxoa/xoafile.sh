#!/bin/bash

# Kiểm tra xem thư mục images có trống không
if [ -d "images" ]; then
    if [ "$(ls -A images)" ]; then
        rm -rf images/*
        echo "Đã xóa tất cả các tệp trong thư mục 'images'."
    else
        echo "Thư mục 'images' đã trống."
    fi
else
    echo "Thư mục 'images' không tồn tại."
fi

# Kiểm tra xem thư mục text có trống không
if [ -d "text" ]; then
    if [ "$(ls -A text)" ]; then
        rm -rf text/*
        echo "Đã xóa tất cả các tệp trong thư mục 'text'."
    else
        echo "Thư mục 'text' đã trống."
    fi
else
    echo "Thư mục 'text' không tồn tại."
fi


