#!/bin/bash
clear
if [ "$(whoami)" = "root" ]; then echo "==========="; else echo -e "Script must be run as root user.\nvia this command:\nsudo ./_install.sh\nNow exiting..." & sleep 5 & exit ; fi
uname="$(who am i | awk '{print $1}')"
udir="/home/$uname"
echo -e "Klipper-Box\n==========="
echo "An even more automatic KIAUH helper script."
echo -e "\n\n***** Supported printers:\nEnder 5 S1\n\nIf you own a printer not on this list and want to contribute you can submit a PR or reach out to me via email @ thisisyourknife@gmail.com. Thanks!"
sleep 3

# SET PRINTER MODEL HERE!!!
model="Ender-5-S1"
#

modeldirectory="$udir/Klipper-Box/models/$model"
klipperdir="$udir/klipper"
pdatadir="$udir/printer_data"
configdir="$pdatadir/config"
if [ -d "$klipperdir" ]; then
    echo "Klipper found..."
else
    echo -e "Klipper not found, about to launch install script.\nFor easiest setup please install:\n\nREQUIRED-\nOption 1- Klipper\nOption 2- moonraker\n\nOptional-\nOption 8- OctoEverywhere\nThis allows you to access your printer and webcam from outside your home network and on many convenient mobile apps like Mobileraker!"
    read -p "Press enter when you're ready..."
    cd "/home/$uname" && su "$uname" -c "git clone https://github.com/th33xitus/kiauh.git"
    cd "/home/$uname" && su "$uname" -c "./kiauh/kiauh.sh"
fi
cp -a "$modeldirectory/config" "$configdir"
cp -a "$modeldirectory/.config" "$klipperdir"
if ! cd "$klipperdir"; then 
echo "Something went wrong, klipper directory doesn't exist! Aborting!"
exit
fi
echo -n "Building up to date firmware..."
make clean  1>/dev/null 2>/dev/null
make 1>/dev/null 2>/dev/null
mkdir "/home/$uname/_KLIPPER_BOX_OUTPUT/"
mkdir "/home/$uname/_KLIPPER_BOX_OUTPUT/STM32F4_UPDATE" 1>/dev/null 2>/dev/null
cp "$klipperdir/out/klipper.bin" "/home/$uname/_KLIPPER_BOX_OUTPUT/STM32F4_UPDATE"
echo "Completed!"
echo -e "Editing Prusa Slicer ini bundle with the IP of the machine running this script.\nThis will allow you to upload STL files direct to the printer from Prusa Slicer!\n"
MYIP="$(hostname -I)"
count="$(echo "$MYIP" | wc -l 1>/dev/null 2>/dev/null)"
if [ "$count" -gt 1 ]; then
    MYIP="$(hostname -I | cut -f2 -d' ')"
fi
if sed -i "s/YOURIPADDRESS/$MYIP/g" "$modeldirectory/bundle.ini"; then
    echo "Success!"
    cp -a "$modeldirectory/bundle.ini" "/home/$uname/_KLIPPER_BOX_OUTPUT/"
else
    echo "Could not update bundle.ini."
fi
echo -e "\n"
echo -e "1) Copy entire STM32F4_UPDATE directory (located at /home/$uname/_KLIPPER_BOX_OUTPUT/STM32F4_UPDATE) to your SD card.\n2) Put the SD card in your printer and power it on."
read -p  "3) Then return here and press ENTER..."
echo -e "\n"
echo -e "Next- you need to flash this newly built firmware onto your printer so that we can automatically obtain your MCU serial."
read -p -r "Please remove any usb connection that is NOT your printer itself from your pi/sonic pad/klipper-box(this is what I call a laptop or PC with ubuntu installed just for klipper running purposes) then press ENTER..."
read -p "Are you using WSL?[y/n]?" WSLYN
if echo "$WSLYN" | grey -i "y"; then 
    echo -e "Ok you must run the WSL_USB.bat from the main repo directory.\nThis will allow you to assign your USB to an ID in wsl!"
    read -p "Once you've done that and it is assigned return here and press enter!"
    MCU="/dev/ttyUSB0"
else
    MCU="$(ls /dev/serial/by-id/*)"
fi
if [ -z "$MCU" ]; then
	echo "No printer found via USB, did you make sure to flash your firmware?"
	exit
else
	echo "Serial found!! Serial:$MCU"
fi
if sed -i "s/serial:.*/serial:${MCU//\//\\/}/g" "$configdir/printer.cfg"; then echo "success!"; fi
if sed -i "s/serial:.*/serial:${MCU//\//\\/}/g" "/home/$uname/printer_data/config/printer.cfg"; then echo "success!"; fi
echo -e "Thats all folks!\nIn your /home/$uname/_KLIPPER_BOX_OUTPUT directory you will find a file named bundle.ini\nLocate your prusa slicer application exe and copy the bundle.ini to and open a command prompt in that folder.\nThen type-\nprusa-slicer.exe --load bundle.ini\nThat should load Prusa Slicer with all of the suggested settings!\nThat's including super speed printing, which you can adjust on your own terms!\nIf for any reason Prusa Slicer acts up, you can load the _BASE_PROJECT.3mf fileincluded in the folder for your model on the repo!"
