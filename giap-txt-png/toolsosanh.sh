#!/bin/bash

# Hàm tính tỷ lệ phần trăm dòng giống nhau giữa hai tệp
calculate_similarity_percentage() {
    file1="$1"
    file2="$2"
    # Đếm số dòng trong mỗi tệp (bỏ qua các dòng trống)
    lines_file1=$(grep -v '^$' "$file1" | wc -l)
    lines_file2=$(grep -v '^$' "$file2" | wc -l)
    # Đếm số dòng giống nhau
    similar_lines=$(grep -Fxf "$file1" "$file2" | grep -v '^$' | wc -l)
    # Tính tỷ lệ phần trăm
    if [ "$lines_file1" -gt 0 ]; then
        similarity_percentage=$(( (similar_lines * 100) / lines_file1 ))
    else
        similarity_percentage=0
    fi
    echo "$similarity_percentage"
}

# Kiểm tra xem thư mục đã được tạo chưa
check_directories() {
  if [ -d "images" ] && [ -d "text" ]; then
    return 0
  else
    return 1
  fi
}

 # Chạy file taofolder.sh
./ztaoxoa/taofolder.sh

# Xử lý khi nhận tín hiệu SIGINT hoặc SIGTERM
cleanup() {
  ./ztaoxoa/xoafile.sh
  exit
}

# Đặt trap
trap cleanup SIGINT SIGTERM

# Tạo giao diện người dùng với Zenity
while true; do
  CHOICE=$(zenity --list --title="Tool so sánh" --column="Options" "Select zip file" "So sanh" "Restart")

  # Kiểm tra xem người dùng có muốn hủy không
  if [ $? -ne 0 ]; then
    cleanup
    exit
  fi

  case "$CHOICE" in
  
    "Select zip file")
    if check_directories; then
      # Cho phép người dùng chọn tệp
      zip_file=$(zenity --file-selection --title="Chọn tệp zip")
      
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
    else
        zenity --error --text="Vui lòng tạo thư mục lưu trữ trước."
    fi
    ;;
      
    "So sanh")    
      # Kiểm tra xem đã tách tệp chưa
      if [ -z "$temp_dir" ]; then
          zenity --error --text="Vui lòng tách tệp trước khi so sánh."
      else
          # Thêm hộp thoại nhập liệu
          input=$(zenity --entry --text="Nhập tỷ lệ phần trăm tối thiểu để hiển thị kết quả")
          
          # Thêm lệnh chạy file sosanhchu.sh và sshinhanh.py với tham số thứ hai là tỷ lệ phần trăm
          resultc=$(./zsosanh/sosanhchu.sh "$temp_dir/text" "$input")
          resulth=$(python3 ./zsosanh/sshinhanh.py "$temp_dir/images" "$input" 2>&1)
          
          # Tách kết quả thành từng dòng
          IFS=$'\n' read -rd '' -a linesc <<<"$resultc"
          IFS=$'\n' read -rd '' -a linesh <<<"$resulth"
          
          # Hiển thị kết quả bằng Zenity
          filtered_resultc=""
          for line in "${linesc[@]}"; do
            percentage=$(echo "$line" | grep -oP '(?<=: ).*(?=%)')
            if (( $(echo "$percentage >= $input" | bc -l) )); then
              filtered_resultc+="$line\n"
            fi
          done
          zenity --info --text="$filtered_resultc" --title="Kết quả so sánh văn bản"
          
          filtered_resulth=""
          for line in "${linesh[@]}"; do
            percentage=$(echo "$line" | grep -oP '(?<=: ).*(?=%)')
            if (( $(echo "$percentage >= $input" | bc -l) )); then
              filtered_resulth+="$line\n"
            fi
          done
          zenity --info --text="$filtered_resulth" --title="Kết quả so sánh hình ảnh"
      fi
    ;;
    
    "Restart")
      # xoa folder luu tru
      ./ztaoxoa/xoafile.sh  
    ;;   
    *)
      break
      ;;
        
  esac
done

