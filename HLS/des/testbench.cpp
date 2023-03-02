

#include <hls_stream.h>
#include "des.h"
#include <stdio.h>

int
main()
{
	unsigned char des_key[8] = {0xe9, 0xc3, 0x3f, 0x59, 0xbe, 0x1b, 0x74, 0xca};
	key_set key_sets[17];
	unsigned char key_sets_k[17][8];

	memset((void*)key_sets, 0, sizeof(key_sets));

	unsigned char data[8] = {0x65, 0x6d, 0x13, 0xcc, 0xcf, 0x8d, 0x34, 0xe8};

	generate_sub_keys(des_key, key_sets);

	for(int i = 0; i < 17; i++){
		for(int j = 0; j < 8; j++){
			key_sets_k[i][j] = key_sets[i].k[j];
		}
	}


	hls::stream<unsigned char> inp_strm;
	hls::stream<unsigned char> out_strm;
	for(int i = 0; i < 8; i++){
		inp_strm.write(data[i]);
	}

	ap_uint<1> mode = 1;
	des(inp_strm, out_strm, key_sets_k, mode);

	for(int i = 0; i < 8; i++){
		unsigned char word = out_strm.read();
		std::cout << std::hex << (int)word << std::endl;
	}

}
