/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

//#include <stdlib.h>
#include <stdio.h>
//#include "platform.h"
#include "xil_printf.h"

#include "xparameters.h"
#include <xil_io.h>
#include <xarp.h>
#include <xicmp.h>
#include <xudp_packetizer.h>
#include <xdes.h>
#include <xaes_cipher.h>
#include <xgpio.h>
#include <xaxis_switch.h>
#include <xaxidma.h>

#include <PmodSD.h>



//XPAR_M_AXI_TEMAC_BASEADDR

// Management configuration register address     (0x500)
#define CONFIG_MANAGEMENT_ADD  0x500
// Flow control configuration register address   (0x40C)
#define CONFIG_FLOW_CTRL_ADD   0x40C

// Receiver configuration register address       (0x404)
#define RECEIVER_ADD           0x404

// Transmitter configuration register address    (0x408)
#define TRANSMITTER_ADD        0x408

// Speed configuration register address    (0x410)
#define SPEED_CONFIG_ADD       0x410

// Unicast Word 0 configuration register address (0x700)
#define CONFIG_UNI0_CTRL_ADD   0x700

// Unicast Word 1 configuration register address (0x704)
#define CONFIG_UNI1_CTRL_ADD   0x704

// Address Filter configuration register address (0x708)
#define CONFIG_ADDR_CTRL_ADD   0x708


// MDIO registers
#define MDIO_CONTROL           0x504
#define MDIO_TX_DATA           0xh508
#define MDIO_RX_DATA           0x50C
#define MDIO_OP_RD             2
#define MDIO_OP_WR             1

#define PHY_ADDR               1
#define PHY_CONTROL_REG        0
#define PHY_STATUS_REG         1
#define PHY_ABILITY_REG        4
#define PHY_1000BASET_CONTROL_REG 9

XArp arp_proc;
XIcmp icmp_proc;
XUdp_packetizer udp_pack_proc;
XDes des_proc;
XAes_cipher aes_proc;
XGpio dipsw_gpio;

XAxis_Switch_Config *rawdata_sw_config;
XAxis_Switch_Config *outsel_sw_config;
XAxis_Switch rawdata_sw_proc;
XAxis_Switch outsel_sw_proc;

XAxiDma axi_dma_proc;
XAxiDma_Config *axi_dma_cfg_ptr;

unsigned char* dma_buf0 = reinterpret_cast<unsigned char*>(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 1*1024);
unsigned char* dma_buf1 = reinterpret_cast<unsigned char*>(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 2*1024);

unsigned char file_w_buf[1024];

uint32_t mdio_read(const uint32_t regad, const uint32_t phyad)
{
	Xil_Out32(XPAR_M_AXI_TEMAC_BASEADDR+0x504,  (1 << 11) | (MDIO_OP_RD << 14) | (regad << 16) | (phyad << 24) );

	while( (Xil_In32(XPAR_M_AXI_TEMAC_BASEADDR+0x504) & (1 << 7)) == 0 );

	uint32_t read_val;
	read_val = Xil_In32(XPAR_M_AXI_TEMAC_BASEADDR+0x50C) & 0x0000FFFF;
	return read_val;
}


void mdio_write(const uint32_t regad, const uint32_t data, const uint32_t phyad)
{
	Xil_Out32(XPAR_M_AXI_TEMAC_BASEADDR + 0x508,  data & 0xFFFF );
	Xil_Out32(XPAR_M_AXI_TEMAC_BASEADDR+0x504,  (1 << 11) | (MDIO_OP_WR << 14) | (regad << 16) | (phyad << 24) );
	while( (Xil_In32(XPAR_M_AXI_TEMAC_BASEADDR+0x504) & (1 << 7)) == 0 );
}


typedef struct {
	unsigned char k[8];
	unsigned char c[4];
	unsigned char d[4];
} key_set;


int initial_key_permutaion[] = {57, 49,  41, 33,  25,  17,  9,
								 1, 58,  50, 42,  34,  26, 18,
								10,  2,  59, 51,  43,  35, 27,
								19, 11,   3, 60,  52,  44, 36,
								63, 55,  47, 39,  31,  23, 15,
								 7, 62,  54, 46,  38,  30, 22,
								14,  6,  61, 53,  45,  37, 29,
								21, 13,   5, 28,  20,  12,  4};

int key_shift_sizes[] = {-1, 1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1};

int sub_key_permutation[] =    {14, 17, 11, 24,  1,  5,
								 3, 28, 15,  6, 21, 10,
								23, 19, 12,  4, 26,  8,
								16,  7, 27, 20, 13,  2,
								41, 52, 31, 37, 47, 55,
								30, 40, 51, 45, 33, 48,
								44, 49, 39, 56, 34, 53,
								46, 42, 50, 36, 29, 32};


void generate_sub_keys(unsigned char* main_key, key_set* key_sets) {
	int i, j;
	int shift_size;
	unsigned char shift_byte, first_shift_bits, second_shift_bits, third_shift_bits, fourth_shift_bits;

	for (i=0; i<8; i++) {
		key_sets[0].k[i] = 0;
	}

	for (i=0; i<56; i++) {
		shift_size = initial_key_permutaion[i];
		shift_byte = 0x80 >> ((shift_size - 1)%8);
		shift_byte &= main_key[(shift_size - 1)/8];
		shift_byte <<= ((shift_size - 1)%8);

		key_sets[0].k[i/8] |= (shift_byte >> i%8);
	}

	for (i=0; i<3; i++) {
		key_sets[0].c[i] = key_sets[0].k[i];
	}

	key_sets[0].c[3] = key_sets[0].k[3] & 0xF0;

	for (i=0; i<3; i++) {
		key_sets[0].d[i] = (key_sets[0].k[i+3] & 0x0F) << 4;
		key_sets[0].d[i] |= (key_sets[0].k[i+4] & 0xF0) >> 4;
	}

	key_sets[0].d[3] = (key_sets[0].k[6] & 0x0F) << 4;


	for (i=1; i<17; i++) {
		for (j=0; j<4; j++) {
			key_sets[i].c[j] = key_sets[i-1].c[j];
			key_sets[i].d[j] = key_sets[i-1].d[j];
		}

		shift_size = key_shift_sizes[i];
		if (shift_size == 1){
			shift_byte = 0x80;
		} else {
			shift_byte = 0xC0;
		}

		// Process C
		first_shift_bits = shift_byte & key_sets[i].c[0];
		second_shift_bits = shift_byte & key_sets[i].c[1];
		third_shift_bits = shift_byte & key_sets[i].c[2];
		fourth_shift_bits = shift_byte & key_sets[i].c[3];

		key_sets[i].c[0] <<= shift_size;
		key_sets[i].c[0] |= (second_shift_bits >> (8 - shift_size));

		key_sets[i].c[1] <<= shift_size;
		key_sets[i].c[1] |= (third_shift_bits >> (8 - shift_size));

		key_sets[i].c[2] <<= shift_size;
		key_sets[i].c[2] |= (fourth_shift_bits >> (8 - shift_size));

		key_sets[i].c[3] <<= shift_size;
		key_sets[i].c[3] |= (first_shift_bits >> (4 - shift_size));

		// Process D
		first_shift_bits = shift_byte & key_sets[i].d[0];
		second_shift_bits = shift_byte & key_sets[i].d[1];
		third_shift_bits = shift_byte & key_sets[i].d[2];
		fourth_shift_bits = shift_byte & key_sets[i].d[3];

		key_sets[i].d[0] <<= shift_size;
		key_sets[i].d[0] |= (second_shift_bits >> (8 - shift_size));

		key_sets[i].d[1] <<= shift_size;
		key_sets[i].d[1] |= (third_shift_bits >> (8 - shift_size));

		key_sets[i].d[2] <<= shift_size;
		key_sets[i].d[2] |= (fourth_shift_bits >> (8 - shift_size));

		key_sets[i].d[3] <<= shift_size;
		key_sets[i].d[3] |= (first_shift_bits >> (4 - shift_size));

		for (j=0; j<48; j++) {
			shift_size = sub_key_permutation[j];
			if (shift_size <= 28) {
				shift_byte = 0x80 >> ((shift_size - 1)%8);
				shift_byte &= key_sets[i].c[(shift_size - 1)/8];
				shift_byte <<= ((shift_size - 1)%8);
			} else {
				shift_byte = 0x80 >> ((shift_size - 29)%8);
				shift_byte &= key_sets[i].d[(shift_size - 29)/8];
				shift_byte <<= ((shift_size - 29)%8);
			}

			key_sets[i].k[j/8] |= (shift_byte >> j%8);
		}
	}
}
;


uint8_t input_key[16];

unsigned char aes_expanded_key[] =
					{0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f,
					0xd6,0xaa,0x74,0xfd,0xd2,0xaf,0x72,0xfa,0xda,0xa6,0x78,0xf1,0xd6,0xab,0x76,0xfe,
					0xb6,0x92,0xcf,0x0b,0x64,0x3d,0xbd,0xf1,0xbe,0x9b,0xc5,0x00,0x68,0x30,0xb3,0xfe,
					0xb6,0xff,0x74,0x4e,0xd2,0xc2,0xc9,0xbf,0x6c,0x59,0x0c,0xbf,0x04,0x69,0xbf,0x41,
					0x47,0xf7,0xf7,0xbc,0x95,0x35,0x3e,0x03,0xf9,0x6c,0x32,0xbc,0xfd,0x05,0x8d,0xfd,
					0x3c,0xaa,0xa3,0xe8,0xa9,0x9f,0x9d,0xeb,0x50,0xf3,0xaf,0x57,0xad,0xf6,0x22,0xaa,
					0x5e,0x39,0x0f,0x7d,0xf7,0xa6,0x92,0x96,0xa7,0x55,0x3d,0xc1,0x0a,0xa3,0x1f,0x6b,
					0x14,0xf9,0x70,0x1a,0xe3,0x5f,0xe2,0x8c,0x44,0x0a,0xdf,0x4d,0x4e,0xa9,0xc0,0x26,
					0x47,0x43,0x87,0x35,0xa4,0x1c,0x65,0xb9,0xe0,0x16,0xba,0xf4,0xae,0xbf,0x7a,0xd2,
					0x54,0x99,0x32,0xd1,0xf0,0x85,0x57,0x68,0x10,0x93,0xed,0x9c,0xbe,0x2c,0x97,0x4e,
					0x13,0x11,0x1d,0x7f,0xe3,0x94,0x4a,0x17,0xf3,0x07,0xa7,0x8b,0x4d,0x2b,0x30,0xc5};


const uint8_t sbox[] = {0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76, 0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0, 0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15, 0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75, 0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84, 0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf, 0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8, 0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2, 0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73, 0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb, 0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79, 0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08, 0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a, 0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e, 0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf, 0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16};
const uint8_t isbox[] = {0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38, 0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3, 0xd7, 0xfb, 0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87, 0x34, 0x8e, 0x43, 0x44, 0xc4, 0xde, 0xe9, 0xcb, 0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d, 0xee, 0x4c, 0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e, 0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2, 0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25, 0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92, 0x6c, 0x70, 0x48, 0x50, 0xfd, 0xed, 0xb9, 0xda, 0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84, 0x90, 0xd8, 0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a, 0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06, 0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02, 0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13, 0x8a, 0x6b, 0x3a, 0x91, 0x11, 0x41, 0x4f, 0x67, 0xdc, 0xea, 0x97, 0xf2, 0xcf, 0xce, 0xf0, 0xb4, 0xe6, 0x73, 0x96, 0xac, 0x74, 0x22, 0xe7, 0xad, 0x35, 0x85, 0xe2, 0xf9, 0x37, 0xe8, 0x1c, 0x75, 0xdf, 0x6e, 0x47, 0xf1, 0x1a, 0x71, 0x1d, 0x29, 0xc5, 0x89, 0x6f, 0xb7, 0x62, 0x0e, 0xaa, 0x18, 0xbe, 0x1b, 0xfc, 0x56, 0x3e, 0x4b, 0xc6, 0xd2, 0x79, 0x20, 0x9a, 0xdb, 0xc0, 0xfe, 0x78, 0xcd, 0x5a, 0xf4, 0x1f, 0xdd, 0xa8, 0x33, 0x88, 0x07, 0xc7, 0x31, 0xb1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xec, 0x5f, 0x60, 0x51, 0x7f, 0xa9, 0x19, 0xb5, 0x4a, 0x0d, 0x2d, 0xe5, 0x7a, 0x9f, 0x93, 0xc9, 0x9c, 0xef, 0xa0, 0xe0, 0x3b, 0x4d, 0xae, 0x2a, 0xf5, 0xb0, 0xc8, 0xeb, 0xbb, 0x3c, 0x83, 0x53, 0x99, 0x61, 0x17, 0x2b, 0x04, 0x7e, 0xba, 0x77, 0xd6, 0x26, 0xe1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0c, 0x7d};


#define Nk(keysize) ((int)(keysize / 32))
#define Nr(keysize) ((int)(Nk(keysize) + 6))


void copyWord(uint8_t* start, uint8_t* word){
    /*
        Returns a pointer to a copy of a word.
    */
    int i;
    for(i = 0; i < 4; i++, start++){
        word[i] = *start;
    }
}

uint8_t* getWord(uint8_t* w, int i){
    /*
        Takes a word number (w[i] in spec) and
        returns a pointer to the first of it's 4 bytes.
    */
    return &w[4*i];
}

void Rcon(int a, uint8_t *word){
    /* Calculates the round constant and returns it in an array.
       This implementation is adapted from
       https://github.com/secworks/aes/blob/6fb0aef25df082d68da9f75e2a682441b5f9ff8e/src/model/python/rcon.py#L180
    */
    uint8_t rcon = 0x8d;
    int i;
    for(i = 0; i < a; i++){
        rcon = ((rcon << 1) ^ (0x11b & - (rcon >> 7)));
    }
    /* The round constant array is always of the form [rcon, 0, 0, 0] */
    for(i = 0; i < 4; i++){
    	word[i] = 0;
    }
    word[0] = rcon;

}


uint8_t* RotWord(uint8_t* a){
    /*
        Rotate word then copy to pointer.
    */
    uint8_t rot[] = {a[1], a[2], a[3], a[0]};
//    memcpy(a, rot, 4);
    for(int i = 0; i < 4; i++){
    	a[i] = rot[i];
    }
    return a;
}

uint8_t* SubWord(uint8_t* a){
    /*
        Substitute bytes in a word using the sbox.
    */
    int i;
    uint8_t* init = a;
    for(i = 0; i < 4; i++){
        *a = sbox[*a];
        a++;
    }
    return init;
}

uint8_t* xorWords(uint8_t* a, uint8_t* b){
    /* Takes the two pointers to the start of 4 byte words and
       XORs the words, overwriting the first. Returns a pointer to
       the first byte of the first word. */
    int i;
    uint8_t* init = a;
    for(i = 0; i < 4; i++, a++, b++){
        *a ^= *b;
    }
    return init;
}


void KeyExpansion(uint8_t* key, uint8_t* w, size_t keySize){
    /*
        Takes a 128-, 192- or 256-bit key and applies the
        key expansion algorithm to produce a key schedule.
    */
    int i, j;
    const int Nb = 4;
    uint8_t *wi, *wk;
    uint8_t temp[4];
    uint8_t rconval[4];

    /* Copy the key into the first Nk words of the schedule */
    for(i = 0; i < Nk(keySize); i++){
        for(j = 0; j < Nb; j++){
            w[4*i+j] = key[4*i+j];
        }
    }
    i = Nk(keySize);
    /* Generate Nb * (Nr + 1) additional words for the schedule */
    while(i < Nb * (Nr(keySize) + 1)){
        /* Copy the previous word */
        copyWord(getWord(w, i-1), temp);
        if(i % Nk(keySize) == 0){
            /* If i is divisble by Nk, rotate and substitute the word
               and then xor with Rcon[i/Nk] */
            Rcon(i/Nk(keySize), rconval);
            xorWords(SubWord(RotWord(temp)), rconval);
        } else if(Nk(keySize) > 6 && i % Nk(keySize) == 4){
            /* If Nk > 6 and i mod Nk is 4 then just substitute */
        	SubWord(temp);
//            memcpy(temp, SubWord(temp), 4);

        }
        /* Get pointers for the current word and the (i-Nk)th word */
        wi = getWord(w, i);
        wk = getWord(w, i - Nk(keySize));
        /* wi = temp xor wk */
        xorWords(temp, wk);
//        memcpy(wi, xorWords(temp, wk), 4);
        for(int i_cpy = 0; i_cpy < 4; i_cpy++){
        	wi[i_cpy] = temp[i_cpy];
		}
        i++;
    }
}


void aes_expaned_key_select_col(const int col, const unsigned char* orig_key, unsigned char* key_col)
{
	for(int i = 0; i < 11; i++){
		key_col[i] = orig_key[i*16 + col];
	}
}


u32 (*aes_expanded_write_key_funcs[16])(XAes_cipher *InstancePtr, int offset, char *data, int length) =
	{
			XAes_cipher_Write_w_0_Bytes, XAes_cipher_Write_w_1_Bytes, XAes_cipher_Write_w_2_Bytes,
			XAes_cipher_Write_w_3_Bytes, XAes_cipher_Write_w_4_Bytes, XAes_cipher_Write_w_5_Bytes,
			XAes_cipher_Write_w_6_Bytes, XAes_cipher_Write_w_7_Bytes, XAes_cipher_Write_w_8_Bytes,
			XAes_cipher_Write_w_9_Bytes,
			XAes_cipher_Write_w_10_Bytes, XAes_cipher_Write_w_11_Bytes, XAes_cipher_Write_w_12_Bytes,
			XAes_cipher_Write_w_13_Bytes, XAes_cipher_Write_w_14_Bytes, XAes_cipher_Write_w_15_Bytes
	};

int main()
{

	key_set key_sets[17];


	unsigned char key_sets_k[8][17];
	unsigned char aes_expaned_col[11];

//    init_platform();
    memset((void*)input_key, 0, sizeof(uint8_t)*16);
    sleep(2);
    xil_printf("s\n\r");


    Xil_Out32(XPAR_M_AXI_TEMAC_BASEADDR + CONFIG_MANAGEMENT_ADD, 0x58);
    Xil_Out32(XPAR_M_AXI_TEMAC_BASEADDR + SPEED_CONFIG_ADD, 1<<30);

    uint32_t reg_val;
    reg_val = mdio_read(PHY_STATUS_REG, PHY_ADDR);

    if( reg_val == 0xFFFF ){
    	print("No PHY exists with address 1\n\r");
    	return -1;
    }

    mdio_write(PHY_1000BASET_CONTROL_REG, 0x00, PHY_ADDR); // No 1G advertisement
    mdio_write(PHY_ABILITY_REG, (1 << 7 ), PHY_ADDR);	// Advertise for full 100M
    mdio_write(PHY_CONTROL_REG, (9 << 12), PHY_ADDR);	// Auto negotiation and software reset

    reg_val = 0;
    do{
    	reg_val = mdio_read(PHY_STATUS_REG, PHY_ADDR);
    }while((reg_val & (1 << 5)) == 0);

    Xil_Out32(XPAR_M_AXI_TEMAC_BASEADDR + RECEIVER_ADD, 0x90000000);	// reset receiver
    Xil_Out32(XPAR_M_AXI_TEMAC_BASEADDR + TRANSMITTER_ADD, 0x90000000);	// reset transmitter

    Xil_Out32(XPAR_M_AXI_TEMAC_BASEADDR + CONFIG_MANAGEMENT_ADD, 0x68);
    Xil_Out32(XPAR_M_AXI_TEMAC_BASEADDR + CONFIG_FLOW_CTRL_ADD, 0x00);

    sleep(1);

	XArp_Initialize(&arp_proc, XPAR_ARP_0_DEVICE_ID);
	XArp_Set_ip_addr_V(&arp_proc, 0xC0A8010A);
	XArp_Set_mac_addr_lo_V(&arp_proc, 0xaabbccdd);
	XArp_Set_mac_addr_hi_V(&arp_proc, 0x0011);

	XIcmp_Initialize(&icmp_proc, XPAR_ICMP_0_DEVICE_ID);
	XIcmp_Set_ip_addr_V(&icmp_proc, 0xC0A8010A);
	XIcmp_Set_mac_addr_lo_V(&icmp_proc, 0xaabbccdd);
	XIcmp_Set_mac_addr_hi_V(&icmp_proc, 0x0011);

	XUdp_packetizer_Initialize(&udp_pack_proc, XPAR_UDP_PACKETIZER_0_DEVICE_ID);
	XUdp_packetizer_Set_ip_addr_V(&udp_pack_proc, 0xC0A8010A);
	XUdp_packetizer_Set_mac_addr_lo_V(&udp_pack_proc, 0xaabbccdd);
	XUdp_packetizer_Set_mac_addr_hi_V(&udp_pack_proc, 0x0011);

	XDes_Initialize(&des_proc, XPAR_DES_0_DEVICE_ID);
	XAes_cipher_Initialize(&aes_proc, XPAR_AES_CIPHER_0_DEVICE_ID);
	XGpio_Initialize(&dipsw_gpio, XPAR_AXI_GPIO_0_DEVICE_ID);



	rawdata_sw_config = XAxisScr_LookupConfig(XPAR_AXIS_SWITCH_RAW_DATA_DEVICE_ID);
	XAxisScr_CfgInitialize(&rawdata_sw_proc, rawdata_sw_config, XPAR_AXIS_SWITCH_RAW_DATA_BASEADDR);

	outsel_sw_config = XAxisScr_LookupConfig(XPAR_AXIS_SWITCH_OUT_SEL_DEVICE_ID);
	XAxisScr_CfgInitialize(&outsel_sw_proc, outsel_sw_config, XPAR_AXIS_SWITCH_OUT_SEL_BASEADDR);


	axi_dma_cfg_ptr = XAxiDma_LookupConfig(XPAR_AXI_DMA_0_DEVICE_ID);
	if (!axi_dma_cfg_ptr){
		return XST_FAILURE;
	}

	int status;
	status = XAxiDma_CfgInitialize(&axi_dma_proc, axi_dma_cfg_ptr);
	if (status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	XAxiDma_IntrDisable(&axi_dma_proc, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
	XAxiDma_IntrDisable(&axi_dma_proc, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);


	// Default output --> network
	XAxisScr_RegUpdateDisable(&outsel_sw_proc);
	XAxisScr_MiPortDisableAll(&outsel_sw_proc);
	XAxisScr_MiPortEnable(&outsel_sw_proc, 0, 0);
	XAxisScr_RegUpdateEnable(&outsel_sw_proc);

	int sd_state = (XGpio_DiscreteRead(&dipsw_gpio, 1) & 0x04) >> 2;

	DXSPISDVOL disk(XPAR_PMODSD_0_AXI_LITE_SPI_BASEADDR, XPAR_PMODSD_0_AXI_LITE_SDCS_BASEADDR);
	DFILE input_file;
	DFILE output_file;

	// The drive to mount the SD volume to.
	// Options are: "0:", "1:", "2:", "3:", "4:"
	static const char szDriveNbr[] = "0:";
	DFATFS::fsmount(disk, szDriveNbr, 1);

	while(1){
//		xil_printf("s\n\r");

		for(int i = 0; i < 4; i++){
			uint32_t key_reg = Xil_In32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 4*i);
			input_key[4*i+0] = (key_reg >> 24) & 0xFF;
			input_key[4*i+1] = (key_reg >> 16) & 0xFF;
			input_key[4*i+2] = (key_reg >>  8) & 0xFF;
			input_key[4*i+3] = (key_reg >>  0) & 0xFF;
		}

//		for(int i = 0; i < 8; i++){
//			xil_printf("0x%02X ", (unsigned int)(input_key[i] & 0xFF));
//		}
//		xil_printf("\n\r");

		memset((void*)key_sets, 0, sizeof(key_set)*17);
		generate_sub_keys(input_key, key_sets);

		for(int i = 0; i < 8; i++){
			for(int j = 0; j < 17; j++){
				key_sets_k[i][j] = key_sets[j].k[i];
			}
		}

		XDes_Write_key_sets_k_0_Bytes(&des_proc, 0, (char*)key_sets_k[0], 17);
		XDes_Write_key_sets_k_1_Bytes(&des_proc, 0, (char*)key_sets_k[1], 17);
		XDes_Write_key_sets_k_2_Bytes(&des_proc, 0, (char*)key_sets_k[2], 17);
		XDes_Write_key_sets_k_3_Bytes(&des_proc, 0, (char*)key_sets_k[3], 17);
		XDes_Write_key_sets_k_4_Bytes(&des_proc, 0, (char*)key_sets_k[4], 17);
		XDes_Write_key_sets_k_5_Bytes(&des_proc, 0, (char*)key_sets_k[5], 17);
		XDes_Write_key_sets_k_6_Bytes(&des_proc, 0, (char*)key_sets_k[6], 17);
		XDes_Write_key_sets_k_7_Bytes(&des_proc, 0, (char*)key_sets_k[7], 17);


		memset((void*)aes_expanded_key, 0, 11*16*sizeof(unsigned char));
		KeyExpansion(input_key, aes_expanded_key, 128);

//		for(int i = 0; i < 11*16; i++){
//			xil_printf("0x%02X ", (unsigned int)(aes_expanded_key[i] & 0xFF));
//		}
//		xil_printf("\n\r");

		for(int i = 0; i < 16; i++){
			aes_expaned_key_select_col(i, aes_expanded_key, aes_expaned_col);
			const int ZERO_OFFSET = 0;
			aes_expanded_write_key_funcs[i](&aes_proc, ZERO_OFFSET, (char*)aes_expaned_col, 11);
		}

		unsigned int dipsw = XGpio_DiscreteRead(&dipsw_gpio, 1) & 0x07;
		const uint32_t SLAVE_0 = 0;
		XAxisScr_RegUpdateDisable(&rawdata_sw_proc);
		XAxisScr_MiPortDisableAll(&rawdata_sw_proc);
		uint32_t enabled_master = dipsw & 0x01;
		XAxisScr_MiPortEnable(&rawdata_sw_proc, enabled_master, SLAVE_0);
		XAxisScr_RegUpdateEnable(&rawdata_sw_proc);

		uint32_t des_mode = (dipsw & 0x02) >> 1;
		XDes_Set_mode_V(&des_proc, des_mode);

		int new_sd_state = (XGpio_DiscreteRead(&dipsw_gpio, 1) & 0x04) >> 2;
		if(sd_state != new_sd_state){

			// the input to encryption cores now comes from the DMA
			XAxisScr_RegUpdateDisable(&rawdata_sw_proc);
			XAxisScr_MiPortDisableAll(&rawdata_sw_proc);
			XAxisScr_MiPortEnable(&rawdata_sw_proc, enabled_master, 1);
			XAxisScr_RegUpdateEnable(&rawdata_sw_proc);


			// the output of encryption cores goes to the DMA
			XAxisScr_RegUpdateDisable(&outsel_sw_proc);
			XAxisScr_MiPortDisableAll(&outsel_sw_proc);
			XAxisScr_MiPortEnable(&outsel_sw_proc, 1, 0);
			XAxisScr_RegUpdateEnable(&outsel_sw_proc);

			FRESULT ofr, ifr;

			ofr = output_file.fsopen("enc_file", FA_WRITE | FA_CREATE_ALWAYS);
			ifr = input_file.fsopen("rand1M", FA_READ);

			if(ofr != FR_OK || ifr != FR_OK){
				xil_printf("open failed %i %i\r\n", ofr, ifr);
			}

			while(!input_file.fseof()){

				XGpio_DiscreteWrite(&dipsw_gpio, 2, ~XGpio_DiscreteRead(&dipsw_gpio, 2));

				int bytes_to_read = 512;
				uint32_t bytesRead;
				int totalBytesRead = 0;
				do {
					ifr = input_file.fsread(dma_buf0+totalBytesRead, bytes_to_read-totalBytesRead, &bytesRead);
					totalBytesRead += bytesRead;
				} while (totalBytesRead < 512 && ifr == FR_OK);

				bytes_to_read = 512;
				totalBytesRead = 0;
				do {
					ifr = input_file.fsread(dma_buf0+512+totalBytesRead, bytes_to_read-totalBytesRead, &bytesRead);
					totalBytesRead += bytesRead;
				} while (totalBytesRead < 512 && ifr == FR_OK);

				// Kick off S2MM transfer
				status = XAxiDma_SimpleTransfer(&axi_dma_proc, (u32)dma_buf1, 1024, XAXIDMA_DEVICE_TO_DMA);
				if (status != XST_SUCCESS){
					xil_printf("ERROR! Failed to kick off S2MM transfer!\n\r");
					return XST_FAILURE;
				}

				// Kick off MM2S transfer
				status = XAxiDma_SimpleTransfer(&axi_dma_proc, (u32)dma_buf0, 1024, XAXIDMA_DMA_TO_DEVICE);
				if (status != XST_SUCCESS){
					xil_printf("ERROR! Failed to kick off MM2S transfer!\n\r");
					return XST_FAILURE;
				}

				// Wait for transfers to complete
				while ((XAxiDma_Busy(&axi_dma_proc, XAXIDMA_DEVICE_TO_DMA)) || (XAxiDma_Busy(&axi_dma_proc, XAXIDMA_DMA_TO_DEVICE)));

				uint32_t bytesWritten = 0;
				ofr = output_file.fswrite(dma_buf1, 512, &bytesWritten);
				if(ofr != FR_OK){
					xil_printf("Write failed %i \r\n", bytesWritten);
				}
				ofr = output_file.fswrite(dma_buf1+512, 512, &bytesWritten);
				if(ofr != FR_OK){
					xil_printf("Write failed %i \r\n", bytesWritten);
				}
			}

			ifr = input_file.fsclose();
			ofr = output_file.fsclose();
			if(ofr != FR_OK || ifr != FR_OK){
				xil_printf("File close successful\r\n");
			}



			// reconnect the input of encryption cores to the network
			XAxisScr_RegUpdateDisable(&rawdata_sw_proc);
			XAxisScr_MiPortDisableAll(&rawdata_sw_proc);
			XAxisScr_MiPortEnable(&rawdata_sw_proc, enabled_master, SLAVE_0);
			XAxisScr_RegUpdateEnable(&rawdata_sw_proc);


			// reconnect the output of encryption cores to the network
			XAxisScr_RegUpdateDisable(&outsel_sw_proc);
			XAxisScr_MiPortDisableAll(&outsel_sw_proc);
			XAxisScr_MiPortEnable(&outsel_sw_proc, 0, 0);
			XAxisScr_RegUpdateEnable(&outsel_sw_proc);

		}
		sd_state = new_sd_state;

		sleep(1);
	}


//    cleanup_platform();
    return 0;
}
