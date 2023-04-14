

#include <ap_int.h>
#include <hls_stream.h>

#include "../network.h"




void
tlast_gen(
		hls::stream<ap_uint<8> > &input_strm,
		hls::stream<net::net_word_t> &output_strm
		)
{
#pragma HLS INTERFACE axis register both port=input_strm
#pragma HLS INTERFACE axis register both port=output_strm
#pragma HLS INTERFACE ap_ctrl_none port=return


	ap_uint<8> in_word;
	net::net_word_t out_word;

	for(ap_uint<11> i = 0; i < 1024; i++){
#pragma HLS PIPELINE
		in_word = input_strm.read();
		out_word.data = in_word;
		out_word.last = (i == 1023);
		output_strm.write(out_word);
	}

}
