#ifndef __AES_H_
#define __AES_H_

#include <stdio.h>
#include <stdlib.h>
#include <ap_int.h>

#define AES_128

#ifdef AES_128
#define Nk 4
#define Nb 4
#define Nr 10
#endif

#ifdef AES_192
#define Nk 6
#define Nb 4
#define Nr 12
#endif

#ifdef AES_256
#define Nk 8
#define Nb 4
#define Nr 14
#endif

#define BYTE unsigned char
#define WORD unsigned int

void aes_cipher(BYTE in[4*Nb],BYTE out[4*Nb],BYTE w[Nr+1][4*Nb]);

BYTE xtime(BYTE A);
BYTE Multiplication(BYTE A,BYTE B);
void Four_Term_Multiplication(BYTE A[4],BYTE B[4],BYTE OUT[4]);
void SubBytes();
void ShiftRows();
void MixColumns();
void AddRoundKey(BYTE w_bias[4*Nb]);
void DispArray(char *Arrayname,BYTE *array,int height,int width);

#endif
