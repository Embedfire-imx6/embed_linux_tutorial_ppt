#!/bin/bash

version="0.1.2"
author="Emdebfire"
package_name="$2"
package_dir="$1"

mkdir -p ./$package_dir/DEBIAN/

cat <<EOF > ./$package_dir/DEBIAN/changelog
AUTHOR:$author
VERSION:$version 
DATE:$(date -R)
EOF


cat <<EOF > ./$package_dir/DEBIAN/copyright
******************************************************************
  * @attention
  *
  * 实验平台:野火  i.MX6ULL开发板 
  * 公司    :http://www.embedfire.com
  * 论坛    :http://www.firebbs.cn
  * 淘宝    :https://fire-stm32.taobao.com
  *
* * ******************************************************************
EOF

cat <<EOF > ./$package_dir/DEBIAN/control
Source:embedfire
Package:${package_name%.*}
Version:$version
Section: debug
Priority: optional
Architecture: amd64
Maintainer:$author 
Description: Embedfire Tools
EOF

cat <<EOF > ./$package_dir/DEBIAN/postinst
#!/bin/sh
echo "******************************************************************"
echo "welcome to use $package_name!"
echo "******************************************************************"
EOF

sudo chmod 775 ./$package_dir/DEBIAN/postinst

dpkg -b $package_dir $package_name

