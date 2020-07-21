##  SDK方式烧录镜像

#### 获取NXP官方SDK

- 官方网站：

  https://www.nxp.com/products/processors-and-microcontrollers/arm-processors/i-mx-applications-processors/i-mx-6-processors/i-mx-6ull-single-core-processor-with-arm-cortex-a7-core:i.MX6ULL?&tab=Design_Tools_Tab&

- 野火大学堂

  Linux系统开发板->i.MX 6ul系列开发板->基本资料->

  embed_linux_tutorial\base_code\bare_metal\sdk_nxp

#### Linux安装SDK

```
./XXX.run
```

#### SDK中镜像相关工具

#####  说明文档

tools\imgutil\readme.txt

##### 使用要点

tool/imgutil

- 复制bin文件到imgutil/evkmcimx6ull文件下，并重命名为sdk20-app.bin
- 执行编译命令，得到img文件
  - flash：mkimage.sh flash
  - sd：mkimage.sh sd

#### mkimage.sh

- 根据dcd.config文件，由dcdgen.bin程序生成DCD表
- imgutil.bin程序生成img可烧录镜像

#### 野火烧录工具

embed_linux_tutorial\base_code\bare_metal\download-tool



