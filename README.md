# Network Attached Encryption Accelerators

As the project title suggests, our goal was to design and implement power-efficient encryption accelerators capable of low-latency encryption of network data. While the same functionality can be achieved using a pure software-based approach, a software-only implementation has some characteristics that are not desirable:
In a software approach, the operating system manages the network interface. Therefore, if a process wants to receive or transmit data through the network interface, it cannot interact with the network interface directly. Instead, it must copy data to or from the kernel space, which manages the network interface. These redundant copies require the processor to move data into an external memory. However, using an external memory has three disadvantages: First, it introduces high latency to the application. Second, the added latency is not deterministic. Third, since most of the energy in a computer system is consumed by the memory hierarchy, such a software-based approach is power inefficient.
To address the aforementioned concerns, we have proposed the utilization of network-attached encryption accelerators implemented on an FPGA board. Our approach involves the complete implementation of the network stack through the use of customized IP-cores in hardware. The design employs a dataflow architecture that obviates the necessity of external memory by enabling network data to be transmitted between cores in a streaming manner. The elimination of external memory ensures deterministic low latency, and enhances the power efficiency of the design.
Our initial objective for this project was to develop two encryption algorithm accelerators on FPGA that could encrypt data at the network line rate. To enhance power efficiency even more, we planned to use partial reconfiguration for switching between these two encryption algorithms. However, we opted to substitute partial reconfiguration functionality with SD card capability.


## Developers
Soheil Shahrouz

Chun Yee Chu

Serdar Ozturk 

## How to build the project?
First, you must initialize submodules used in this repository:
```bash
git submodule update --init --recursive
```

Then, you need to build all HLC cores. Change the directory to /HLS. There is a separate folder for each core. Go to each folder and run the following command:
```bash
vivado_hls build.tcl
```

Once all HLs cores built, open Vivado in the project's directory and enter the following command in the Tcl console:
```bash
source ./ECE532_project.tcl
```

When the Vivado project is created, you can generate the bitstream and program the FPGA. However, since the project contains a Microblaze processor, you need to create an SDK project and compile a C++ program as well. To do so, clock on the File->Export->Export Hardware. When a new window is opened, check Include the bitstream and export the hardware. Then, launch the SDK through File->Launch SDK and create an application project. Finally, add the main.cc file in /src folder to your project and build the software project. The generated elf file can be used to program the FPGA. You can also modify the board's network parameters such as IP address and MAC address by changing some constants.


## Directories
/src: All HDL files used in the Vivado project along with a c++ source file that is used in the SDK project.

/HLS: All source codes and scripts required for building HLS IP cores.

/IP: .xci files for IP cores that are instantiated in our RTL codes.

/vivado-library: Digilent's IP cores for Vivado. This folder is actually a submodule.

/ECE532_project: Once the project is built, this directory contains the Vivado project.

/docs: Group report and slides for the final demo.


## Acknowledgments
We thank Lingfeng Wu, who contributed to the development of encryption cores in this project, but sadly decided to drop the course.

