#!/bin/bash
set -e

cd "$(dirname "$0")"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="build/apk_output"
APK_NAME="omao_${TIMESTAMP}.apk"

mkdir -p "$OUTPUT_DIR"

echo "==> 开始构建 Release APK..."
flutter build apk --release

SOURCE_APK="build/app/outputs/flutter-apk/app-release.apk"

if [ ! -f "$SOURCE_APK" ]; then
  echo "错误: 未找到构建产物 $SOURCE_APK"
  exit 1
fi

cp "$SOURCE_APK" "$OUTPUT_DIR/$APK_NAME"

echo "==> 构建完成!"
echo "    文件: $OUTPUT_DIR/$APK_NAME"
echo "    大小: $(du -h "$OUTPUT_DIR/$APK_NAME" | cut -f1)"
