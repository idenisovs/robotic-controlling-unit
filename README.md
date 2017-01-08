# robotic-controlling-unit

## Description
This is sources from my High School project, in which I tried to build Robotic Controlling Unit. 

## Structure
Robotic controlling unit shall consist from two parts:

1. Robotic platform, which includes itself the __controller mainboard__ and __low-level operations mainboard__. The controller mainboard is Intel Atom PC with Linux OS and low-level operations mainboard is ATMega88 MCU and it`s connections.
2. Operator station, an laptop with Wi-Fi card and Operator station software. 

## Software

### Operator station
This software gave the possibility to use an Laptop as operator station. It sends the commands remotely to the robotic platform 
and display the measurement values to its operator. Written mostly in C# (Visual Studio 2010) and uses the joystic as main controlling device. 

### Middle level controller
This is the middle-level software, generally purposed to as bridge between operator station (protocol over TCP/IP) and MCU 
(by using UART). This part is written in C and shall run as Linux daemon.

### Driver and sensor controller unit
This part consists from ATMega88 firmware (ASM), which is used to controll the drivers (in my case it is two Maxon DC motors (12V)) and multiple sensors. It communicates with upper controller by using UART.

## Library

* __Linux Socket Programming__ by Sean Walton, 2001;
* __Advanced Programming in the UNIX Environment, 2nd Edition__ by W. Richard Stevens (Author), Stephen A. Rago, 2007;
* __Микроконтроллеры AVR семейства Mega__ by А. В. Евстифеев, 2007;

# License
__TBD__
