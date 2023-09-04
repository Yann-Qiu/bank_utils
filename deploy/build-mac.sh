current_dir=$(cd "$(dirname "$0")";pwd);
version="$1";
cert="$2"
username="$3"
password="$4"
teamId=$(echo "$cert"|grep -Eo "\(.*\)$"|grep -Eo "[^\(\)]+");
echo $teamId
# flutter 构建
flutter pub get
if [[ "$5" == "" ]]; then
  flutter build macos
else 
  flutter build macos --dart-define=target=$5
fi
echo "Fluter build successfully"
# 对goios二进制程序进行签名
# 对flutter构建后生成的.app文件进行签名
codesign -f -o runtime -s "$cert" -v "$current_dir/../build/macos/Build/Products/Release/bank_utils.app" --deep
echo "Codesign .app file successfully"
# 如果旧版本存在就删除
rm -rf "$current_dir/dmg-build/build/bank_utils.dmg"
# 把flutter构建后生成的.app文件转换为.dmg文件
python3 "$current_dir/dmg-build/package.py"
# 如果旧版本存在就删除
rm -rf "$current_dir/dmg-build/build/bank_utils-$version.dmg"
# 给.dmg文件追加版本号
dmgName="$current_dir/dmg-build/build/bank_utils-$version.dmg"
mv "$current_dir/dmg-build/build/bank_utils.dmg" "$dmgName"
echo "Build dmg file($dmgName) successfully"
# 对.dmg文件进行签名
codesign -f -o runtime -s "$cert" -v "$current_dir/dmg-build/build/bank_utils-$version.dmg"  --deep
echo "Codesign .dmg file successfully"
# 把签名后的.dmg文件进行公证，并等待结果
xcrun notarytool submit --apple-id $username --password $password --team-id $teamId --wait "$dmgName"
# 把签名后的.dmg文件进行公证，获取返回的requestUUID
# result=$(xcrun altool --notarize-app --primary-bundle-id com.example.udt-desktop --username $username --password $password --file "$current_dir/dmg-build/build/udt-desktop-$version.dmg")
# reqId=$(echo $result | grep -Eo "[^ ]+$")
# echo "Notarization requestUUID: $reqId, start polling notarization state:"
# # 使用requestUUID，每30s获取一次公证结果，直到公证成功或失败
# while true
# do
#   status=$(xcrun altool --notarization-info $reqId --username $username --password $password)
#   s=`echo "$status" | grep "success"`
#   i=`echo "$status" | grep "invalid"`
#   if [[ "$s" != "" ]]; then
#       echo "Notarization successfully!"
#       break
#   fi
#   if [[ "$i" != "" ]]; then
#       echo "Notarization failed!"
#       break
#   fi
#   echo "Notarization processing, check again after 30 seconds."
#   sleep 30
# done