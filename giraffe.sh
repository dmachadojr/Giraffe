#!/bin/bash
#-----------
# script name: giraffe.sh
# autor: Dorival M. Machado Jr.
# e-mail: dorivaljunior gmail com
# objective: saves or restores Quagga.conf files from all nodes on CORE
#-----------

save_quagga()
{
	echo "---|SAVE|---"
	echo -n "Number of your environment (verify the title on CORE): "
	read numberAmbience
	echo -n "File name to save as (without space character and without extension): "
	read newName
	cd /tmp/pycore.$numberAmbience
	touch giraffe_backup.txt
	tar -cf giraffe_$newName.tar giraffe_backup.txt
	confs=$( ls | grep .conf )
	for n in $confs; do
		tar -rvf giraffe_$newName.tar $n/usr.local.etc.quagga/Quagga.conf
	done
	mv giraffe_$newName.tar $myLocation
}

restore_quagga()
{
	echo "---|RESTORE|---"
	echo -n "Number of your environment (verify the title on CORE): "
	read numberAmbience
	echo -n "Complete file name without extension (.tar): "
	read P
	mkdir giraffe_dir
	cd giraffe_dir
	tar -xvf ../$P 
        confs=$( ls | grep .conf)
 	for i in $confs; do
		echo "Updating $i..."
		cp $i/usr.local.etc.quagga/Quagga.conf /tmp/pycore.$numberAmbience/$i/usr.local.etc.quagga/		
	done
	rm -rf $myLocation/giraffe_dir
	echo "Please, restart quagga on your nodes, before on your \"real quagga\":"
	echo "Execute: /etc/init.d/quagga-mr restart"
}

if [ `id -u` != "0" ]; then
	echo "You need root power."
	exit 0
fi

if [ `ps aux | grep pycore | wc -l` -lt 2 ]; then
	echo "Error: The CORE environment isn't running. Start it."
	exit 0
fi

myLocation=$(pwd)

echo ""
echo "Options:"
echo "  1 Save configuration files"
echo "  2 Restore configuration files"
echo ""
echo -n "  What do you do? "
read X
case $X in
	1)
		save_quagga
	;;
	2)
		restore_quagga
	;;
	*)
	echo "Invalid option"
esac

cd $myLocation
