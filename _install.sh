#!/bin/bash
clear
if [ "$(whoami)" = "root" ]; then echo "==========="; else echo -e "Script must be run as root user.\nvia this command:\nsudo ./_install.sh\nNow exiting..." & sleep 5 & exit ; fi
uname="$(who am i | awk '{print $1}')"
echo -e "Klipper-Box\n==========="
echo "An even more automatic KIAUH helper script."
echo -e "\n\n***** Supported printers:\nEnder 5 S1\n\nIf you own a printer not on this list and want to contribute you can submit a PR or reach out to me via email @ thisisyourknife@gmail.com. Thanks!"
sleep 3
klipperdir="/home/$uname/klipper"
pdatadir="-/home/$uname/printer_data"
configdir="$pdatadir/config"
if [ -d "$klipperdir" ]; then
    echo "Klipper found..."
else
    echo "Klipper not found, installing now..."
    apt-get install git -y
    cd "/home/$uname" && su - "$uname" -c "git clone https://github.com/th33xitus/kiauh.git"
    cd "/home/$uname" && su - "$uname" -c "./kiauh/kiauh.sh"
fi

echo -n "Building up to date firmware..."
# copy from repo  .config file to klipper dir
make clean  1>/dev/null 2>/dev/null
make 1>/dev/null 2>/dev/null
mkdir "$HOME/STM32F4_UPDATE" 1>/dev/null 2>/dev/null
cp ~/klipper/out/klipper.bin "$HOME/STM32F4_UPDATE"
echo "Completed!"
echo -e "\n"
echo -e "1) Copy entire STM32F4_UPDATE directory (located at $HOME/STM32F4_UPDATE) to your SD card.\n2) Put the SD card in your printer and power it on."
read -p "3) Then return here and press ENTER..."
echo -e "\n"
echo -e "Next- you need to flash this newly built firmware onto your printer so that we can automatically obtain your MCU serial."
read -p "Please remove any usb connection that is NOT your printer itself from your pi/sonic pad/klipper-box(this is what I call a laptop or PC with ubuntu installed just for klipper running purposes) then press ENTER..."
MCU="$(ls /dev/serial/by-id/*)"
if [ -z "$MCU" ]; then
	echo "No printer found via USB, did you make sure to flash your firmware?"
	exit
else
	echo "Serial found!! Serial:$MCU"
fi

sed -i "s/serial:.*/serial:${MCU//\//\\/}/g" "$HOME/printer_data/config/printer.cfg"
if [ $? = 0 ]; then
	echo "Success!"
fi
