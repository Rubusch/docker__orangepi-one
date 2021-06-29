[![CircleCI](https://circleci.com/gh/Rubusch/docker__orangepi-one.svg?style=shield)](https://circleci.com/gh/Rubusch/docker__orangepi-one)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.html)


# Build Container for my OrangePi One

Contains a Dockerfile for building an docker image and its container for the OrangePi One using buildroot.  

This is taking from a setup serving as console server for a DE0-SoC-FPGA board, together with a relais setup to powercycle the DE0 target board.  

Implicitely will run ```git clone --branch lothar/orangepi-devel https://github.com/Rubusch/buildroot.git``` inside the docker container.  

![OrangePi](pics/OrangePiOne.jpg)


## Tools Needed

```
$ sudo curl -L "https://github.com/docker/compose/releases/download/1.28.6/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
$ sudo chmod a+x /usr/local/bin/docker-compose
```

NB: Where 1.28.6 is the latest version (currently not supported by devian/ubuntu package management)  


## Build

```
$ cd docker
$ docker-compose up
```


## Usage


```
$ docker-compose -f ./docker-compose.yml run --rm orangepi_buildroot /bin/bash
```


## Image

For debugging the ``data abort`` issue when booting into the kernel, disassemble the u-boot to better understand what went wrong  

```
$ arm-linux-gnueabihf-objdump -sD u-boot > u-boot.txt
```

**NB**: alternatively, use kernel 5.2 and u-boot 2019.07 as minimum combination for the Orange Pi One.  

### Login

![OrangePiSerial](pics/OrangePiOne-serial-connection.jpg)

serial connection e.g. via screen  

```
$ sudo screen /dev/ttyUSB0 115200
```

u: root  
p: N/A  


### Example: Use the OrangePi as lowcost Remote Lab Automation Solution

Needed: Linkerkit Relais Shield, relais and cable, some wires  

![OrangePiAutomation](pics/OrangePiOne-automation-setup.jpg)

control the target device via OrangePi and Linker Kit Shield:  
 *  eth: connect the OrangePi via ssh connection, pick up the screen session (serial) or powercycle the target (gpio)
 *  pm: use LK shield and relais to powercycle the target board, here a Cyclone V SoC-FPGA Board
 *  serial: setup a ``screen`` session via usb-to-serial-altera-uart to the target, detach and attach as needed


#### Configuration

make sure the kernel has ``CONFIG_SERIAL_ALTERA_UART`` set, it's benefitial also to turn on additional things such as ``/proc/config.gz`` support - TODO verify   

make sure the board has the following onboard:  
 *  ``screen``
 *  ``dropbear``
 *  ``usb/serial`` support (drivers -> usb drivers -> section serial, enable generic support (/dev/ttyUSB0 will appear
 *  ``eudev + tempfs`` Build (convenience)
 * turn off taking eth0 to automatic dhcp (when using fixed IP addresses)

some gpio libs/tools might be helpful, find the following gpio numbering mapped to the pin numbering  

![GPIOs](pics/rpi-gpio-pinout.png)

in case, configure network and/or set a root password   

```
# vi /etc/network/interfaces

auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address 192.168.200.20
netmask 255.255.255.0
```

connect to the target boards GND and RST pins to trigger via relais connector  

![TargetBoardsRSTPins](pics/OrangePiOne-automation-reset-pins.jpg)


#### Setting gpio10 as an example

gpio10 will trigger on pin 19, make the gpio accessible, then set access direction "out" (write) or "in" (reading)  

then configure the following on the board  

```
$ echo 10 > /sys/class/gpio/export
$ echo "out" > /sys/class/gpio/gpio10/direction
```

turn on  

```
$ echo 1 > /sys/class/gpio/gpio10/value
```

turn off  

```
$ echo 0 > /sys/class/gpio/gpio10/value
```

in case, wrap all together in a script in /root  

```
# vi /root/powercycle.sh

#!/bin/sh
GPIO=/sys/class/gpio/gpio10/value
echo 1 > $GPIO
sleep 1
echo 0 > $GPIO
```
