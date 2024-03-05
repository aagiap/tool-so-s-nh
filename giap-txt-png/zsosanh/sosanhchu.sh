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


# Đặt thư mục cần duyệt
temp_dir="text"

# Lấy danh sách tất cả các tệp trong thư mục
files=("$temp_dir"/*)
# Duyệt qua từng cặp tệp

result=""
for ((i = 0; i < ${#files[@]}; i++)); do
    file1="${files[i]}"
    for ((j = i + 1; j < ${#files[@]}; j++)); do
        file2="${files[j]}"
        # Tính tỷ lệ phần trăm dòng giống nhau
        similarity_percentage_file1_to_file2=$(calculate_similarity_percentage "$file1" "$file2")
        similarity_percentage_file2_to_file1=$(calculate_similarity_percentage "$file2" "$file1")
        result+="$file1 - $file2: $similarity_percentage_file1_to_file2%\\n"
        result+="$file2 - $file1: $similarity_percentage_file2_to_file1%\\n"
    done
done

# Kiểm tra và hiển thị các tệp duy nhất
unique_files=()
for file1 in "${files[@]}"; do
    is_unique=true
    for file2 in "${files[@]}"; do
        if [ "$file1" != "$file2" ]; then
            # Tính tỷ lệ phần trăm giống nhau
            similarity_percentage=$(calculate_similarity_percentage "$file1" "$file2")
            if [ "$similarity_percentage" -ne 0 ]; then
                is_unique=false
                break
            fi
        fi
    done
    if [ "$is_unique" = true ]; then
        unique_files+=("$file1")
    fi
done

# Kiểm tra và hiển thị các tệp duy nhất
if [ ${#unique_files[@]} -gt 0 ]; then
    result+="Tệp duy nhất:"
    for unique_file in "${unique_files[@]}"; do
        result+=" $unique_file"
    done
else
    result+="Không có tệp duy nhất."
fi

echo -e "$result"

