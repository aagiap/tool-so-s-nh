#!/bin/bash

# Tạo giao diện người dùng với Zenity
while true; do
  CHOICE=$(zenity --list --title="Chọn tệp và bắt đầu" --column="Options" "Select zip file" "Start")

  case "$CHOICE" in
    "Select zip file")
      # Cho phép người dùng chọn tệp
      zip_file=$(zenity --file-selection --title="Chọn tệp zip")
      ;;
    "Start")
      if [ -z "$zip_file" ]; then
        zenity --error --text="Vui lòng chọn tệp zip trước khi bắt đầu."
      else
        # Thực hiện thao tác với tệp zip
        temp_dir=$(mktemp -d)
        unzip "$zip_file" -d "$temp_dir" > /dev/null
        file_list=($(ls "$temp_dir"))
        
        for file in "${file_list[@]}"; do
          # Xác định loại tệp
          file_type=$(file -b --mime-type "$temp_dir/$file")

          # Tách văn bản và hình ảnh ra từ tệp DOCX và PDF
          case "$file_type" in
            application/vnd.openxmlformats-officedocument.wordprocessingml.document)
              # Tệp DOCX
              ./trich/trichtxtd.sh "$temp_dir/$file"
              python3 ./trich/trichhinhdoc.py "$temp_dir/$file"
              ;;
            application/pdf)
              # Tệp PDF
              ./trich/trichtxtp.sh "$temp_dir/$file"
              ./trich/trichhinhpdf.sh "$temp_dir/$file"
              ;;
          esac
        done

        zenity --info --text="Đã xử lý xong tất cả các tệp."
      fi
      ;;
    *)
      break
      ;;
  esac
done



