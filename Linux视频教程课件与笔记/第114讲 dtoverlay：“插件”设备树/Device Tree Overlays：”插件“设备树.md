## Device Tree Overlays：”插件“设备树

#### 传统设备树

批量管理硬件资源，机制僵化

#### ”插件“设备树

模块化管理硬件资源，灵活定制

#### 使用前提

- 内核配置
  - CONFIG_OF_OVERLAY = y
  - CONFIG_OF_CONFIGFS = y

- 挂载ConfigFS

  ```
  mount x /sys/kernel/config -t configfs
  ```

#### 案例说明

##### 设备树：foo.dts

```

	/ {
		compatible = "corp,foo";
		
		/* On chip peripherals */
		ocp: ocp {
			/* peripherals that are always instantiated */
			peripheral1 { ... };
		}
	};

```



##### “插件”设备树：bar.dts

```
/dts-v1/;
/plugin/;
/ {
	....	
	fragment@0 {
		target = <&ocp>;
		__overlay__ {
			/* bar peripheral */
			bar {
				compatible = "corp,bar";
				... /* various properties and child nodes */
			}
		};
	};
};
```

- /dts-v1/ ：指定dts版本号

- /plugin/：允许设备树中引用未定义的节点
- target = <&xxx>：指定"插件"设备树的父节点
- target-path = “xxx”：指定"插件"设备树的父节点路径



##### 设备树+"插件设备树"：foo.dts + bar.dts

```
/ {
		compatible = "corp,foo";

		/* shared resources */
		res: res {
		};

		/* On chip peripherals */
		ocp: ocp {
			/* peripherals that are always instantiated */
			peripheral1 { ... };

			/* bar peripheral */
			bar {
				compatible = "corp,bar";
				... /* various properties and child nodes */
			}
		}
	};
```

#### 编译方式

````
./scripts/dtc/dtc -I dts -O dtb -o xxx.dtbo arch/arm/boot/dts/xxx.dts // 编译 dts 为 dtbo
./scripts/dtc/dtc -I dtb -O dts -o xxx.dts arch/arm/boot/dts/xxx.dtbo // 反编译 dtbo 为 dts
````

#### APT下载dtc工具

```
sudo apt install device-tree-compiler
```



#### 使用方式

##### 内核运行状态加载(通用)

1. 在/sys/kernel/config/device-tree/overlays/下创建一个新目录：

   ```
   mkdir /sys/kernel/config/device-tree/overlays/xxx
   ```

2. 将dtbo固件echo到path属性文件中

   ```
   echo xxx.dtbo >/sys/kernel/config/device-tree/overlays/xxx/path
   ```

   或者将dtbo的内容cat到dtbo属性文件

   ```
   cat xxx.dtbo >/sys/kernel/config/device-tree/overlays/xxx/dtbo
   ```

3. 节点将被创建，查看内核设备树

   ```
   ls /proc/device-tree
   ```

4. 删除"插件"设备树

   ```
   rmdir /sys/kernel/config/device-tree/overlays/xxx
   ```

##### uboot加载(野火linux开发板)

修改/boot/uEnv.txt

