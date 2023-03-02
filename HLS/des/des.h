#ifndef _DES_H_
#define _DES_H_

#define ENCRYPTION_MODE 1
#define DECRYPTION_MODE 0

#include <hls_stream.h>
#include <ap_int.h>

typedef struct {
	unsigned char k[8];
	unsigned char c[4];
	unsigned char d[4];
} key_set;

void generate_key(unsigned char* key);
void generate_sub_keys(unsigned char* main_key, key_set* key_sets);
void process_message(unsigned char* message_piece, unsigned char* processed_piece, key_set* key_sets, int mode);

void
des(
		hls::stream<unsigned char>& inp_strm,
		hls::stream<unsigned char>& out_strm,
		unsigned char key_sets_k[17][8],
		ap_uint<1>& mode);

#endif
