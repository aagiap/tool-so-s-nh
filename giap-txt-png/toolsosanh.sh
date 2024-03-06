#!/bin/bash

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
  CHOICE=$(zenity --list --title="Tool so sánh" --column="Options" "Select zip file" "So sanh" "Lay ket qua" "Restart")

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
          
# Chạy lệnh sosanhchu.sh và sshinhanh.py và lưu kết quả vào biến
resultc=$(./zsosanh/sosanhchu.sh "$temp_dir/text" "$input")
resulth=$(python3 ./zsosanh/sshinhanh.py "$temp_dir/images" "$input" 2>&1)

# Khai báo trọng số cho text và image
text_weight=0.7
image_weight=0.3

# Khởi tạo mảng để lưu trữ phần trăm từ kết quả
declare -a percent_c
declare -a percent_h

# Trích xuất phần trăm từ kết quả và lưu vào mảng
mapfile -t percent_c < <(echo "$resultc" | grep -oE '[0-9.]+%')
mapfile -t percent_h < <(echo "$resulth" | grep -oE '[0-9.]+%')

# Khởi tạo mảng để lưu trữ tổng phần trăm sau mỗi lần tính
declare -a total_percentages

# Duyệt qua từng phần tử trong mảng và tính tổng phần trăm
for ((i=0; i<${#percent_c[@]}; i++)); do
    total_percentage=$(echo "scale=2; $text_weight * ${percent_c[$i]%%%} + $image_weight * ${percent_h[$i]%%%}" | bc)
    # Thêm giá trị mới vào mảng total_percentages
    total_percentages+=("$total_percentage%")
done

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
    
    "Lay ket qua")
    >> result.csv
    # Khởi tạo mảng để lưu trữ phần trăm từ kết quả
declare -a total_percentages

# Duyệt qua từng phần tử trong mảng và tính tổng phần trăm
for ((i=0; i<${#percent_c[@]}; i++)); do
    total_percentage=$(echo "scale=2; $text_weight * ${percent_c[$i]} + $image_weight * ${percent_h[$i]}" | bc)
    # Thêm giá trị mới vào mảng total_percentages
    total_percentages+=("$total_percentage%")
done

# In ra tổng phần trăm theo cặp file
echo "Tổng phần trăm theo cặp file:" > result.csv
file_list=($(ls "$temp_dir"))
index=0
for ((i=0; i<${#file_list[@]}; i++)); do
    for ((j=i+1; j<${#file_list[@]}; j++)); do
        file1="${file_list[$i]}"
        file2="${file_list[$j]}"
        percentage1="${total_percentages[$index]}"
        index=$((index+1))
        percentage2="${total_percentages[$index]}"
        index=$((index+1))
        echo "$file1 - $file2: $percentage1" >> result.csv
        echo "$file2 - $file1: $percentage2" >> result.csv
    done
done


    echo "complete"
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
