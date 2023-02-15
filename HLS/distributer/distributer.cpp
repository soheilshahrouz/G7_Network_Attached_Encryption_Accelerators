

#include <ap_int.h>
#include <hls_stream.h>

#include "../network.h"




void
distributer(
		hls::stream<net::net_word_t> &input_strm,
		hls::stream<net::protocol_t> &prot_strm,

		hls::stream<net::net_word_t> &arp_strm,
		hls::stream<net::net_word_t> &icmp_strm,
		hls::stream<net::net_word_t> &udp_strm
		)
{
#pragma HLS INTERFACE axis register both port=input_strm
#pragma HLS INTERFACE axis register both port=prot_strm
#pragma HLS INTERFACE axis register both port=arp_strm
#pragma HLS INTERFACE axis register both port=icmp_strm
#pragma HLS INTERFACE axis register both port=udp_strm
#pragma HLS INTERFACE ap_ctrl_none port=return

	net::net_word_t word;
	net::protocol_t detected_prot;

	detected_prot = prot_strm.read();

	if(detected_prot == ((int)net::prot::ARP)){
		net::pass_stream(input_strm, arp_strm);
	}
	else if(detected_prot == ((int)net::prot::ICMP)){
		net::pass_stream(input_strm, icmp_strm);
	}
	else if(detected_prot == ((int)net::prot::UDP)){
		net::pass_stream(input_strm, udp_strm);
	}
	else{
		net::discard_stream(input_strm);
	}
}
