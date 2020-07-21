#!/bin/bash

function usage()
{
  echo "Usage: $0 file"
  echo "	file : the image which you want to burn "
  echo "Example: $0 helloworld.bin"
}



cur_user=`env | grep USER | cut -d "=" -f 2`
echo $cur_user
if [ $cur_user == "root" ]; then
	echo -e "\033[31mThe cur_user is $cur_user. Please run the script with a normal user.\033[0m"
	exit 1
fi 

if [ "$#" -ne 1 ]; then
  usage $0
  exit 1
fi




SYSTEM=`uname -s`
if [ $SYSTEM == "Linux" ]; then
    DCD_BUILDER=dcdgen.bin
    IMG_BUILDER=imgutil.bin
else
		exit 1
fi


cat /proc/partitions
while true
do
read -p "Please Input the card ID [a~z]: (Input 'exit' for quit):" dev_index
    case $dev_index in  
    [[:lower:]]) break
    ;;
    exit) exit 0
    ;;

    * ) echo -e "\033[31mInvalid parameter!\033[0m"
				echo -e "\033[31mThe parameter should be between a~z, enter 'exit' to quit.\033[0m"
				echo -e "\033[34mUsage: If the SD card device corresponds to /dev/sdd, enter d\033[0m"
		continue
    ;;

    esac  
done
sd_idnex=sd$dev_index
echo $sd_index
if [ ! -e /dev/$sd_idnex ]; then 
	echo "mkimage : /dev/$sd_idnex : No such file or directory"
	exit 1
fi

if [ ! -x $DCD_BUILDER ]; then
	chmod +x $DCD_BUILDER
fi

if [ ! -x $IMG_BUILDER ]; then
	chmod +x $IMG_BUILDER
fi

./$DCD_BUILDER dcd.config dcd.bin
./$IMG_BUILDER --combine base_addr=0x80000000 ivt_offset=0x400 app_offset=0x2000 dcd_file=dcd.bin app_file=$1 ofile=sdk20-app.img image_entry_point=0x80002000

sudo dd if=sdk20-app.img of=/dev/$sd_idnex bs=512 conv=fsync

