#include "AES.h"

int main(void)
{
	BYTE Input[4*Nb]={0xe1,0xfa,0x65,0xa9,0x00,0x20,0x13,0x48,0x31,0x85, 0x7f,0x71,0xe2,0x06,0x75,0x99};
	//BYTE key[4*Nk]={0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f};
	BYTE w[Nr+1][4*Nb]=
			{{0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f},
			{0xd6,0xaa,0x74,0xfd,0xd2,0xaf,0x72,0xfa,0xda,0xa6,0x78,0xf1,0xd6,0xab,0x76,0xfe},
			{0xb6,0x92,0xcf,0x0b,0x64,0x3d,0xbd,0xf1,0xbe,0x9b,0xc5,0x00,0x68,0x30,0xb3,0xfe},
			{0xb6,0xff,0x74,0x4e,0xd2,0xc2,0xc9,0xbf,0x6c,0x59,0x0c,0xbf,0x04,0x69,0xbf,0x41},
			{0x47,0xf7,0xf7,0xbc,0x95,0x35,0x3e,0x03,0xf9,0x6c,0x32,0xbc,0xfd,0x05,0x8d,0xfd},
			{0x3c,0xaa,0xa3,0xe8,0xa9,0x9f,0x9d,0xeb,0x50,0xf3,0xaf,0x57,0xad,0xf6,0x22,0xaa},
			{0x5e,0x39,0x0f,0x7d,0xf7,0xa6,0x92,0x96,0xa7,0x55,0x3d,0xc1,0x0a,0xa3,0x1f,0x6b},
			{0x14,0xf9,0x70,0x1a,0xe3,0x5f,0xe2,0x8c,0x44,0x0a,0xdf,0x4d,0x4e,0xa9,0xc0,0x26},
			{0x47,0x43,0x87,0x35,0xa4,0x1c,0x65,0xb9,0xe0,0x16,0xba,0xf4,0xae,0xbf,0x7a,0xd2},
			{0x54,0x99,0x32,0xd1,0xf0,0x85,0x57,0x68,0x10,0x93,0xed,0x9c,0xbe,0x2c,0x97,0x4e},
			{0x13,0x11,0x1d,0x7f,0xe3,0x94,0x4a,0x17,0xf3,0x07,0xa7,0x8b,0x4d,0x2b,0x30,0xc5}};
	BYTE Output[4*Nb];
	aes_cipher(Input,Output,w);

	DispArray("CipherOut",(BYTE *)Output,1,4*Nb);

	//BYTE w_i[3][5]={{0x00,0x11,0x22,0x33,0x44},{0x55,0x66,0x77,0x88,0x99},{0xaa,0xbb,0xcc,0xdd,0xee}};
	//BYTE w_o[3][5];
	//Cipher(w_i,w_o);
	//DispArray("CipherIn",(BYTE *)Input,1,4*Nb);
	//DispArray("w_o",(BYTE *)w_o,1,15);
}
