

#include <ap_int.h>
#include <hls_stream.h>

#include "../network.h"




void
parser(
		hls::stream<net::net_word_t> &input_strm,
		hls::stream<net::net_word_t> &output_strm,
		hls::stream<net::protocol_t> &prot_strm
		)
{
#pragma HLS INTERFACE axis register both port=input_strm
#pragma HLS INTERFACE axis register both port=output_strm
#pragma HLS INTERFACE axis register both port=prot_strm
#pragma HLS INTERFACE ap_ctrl_none port=return

	net::net_word_t word;

	// discard destination and source mac addresses
	for(ap_uint<4> i = 0; i < 12; i++){
#pragma HLS PIPELINE
		word = input_strm.read();
		output_strm.write(word);
	}

	net::ether_type_t ether_type;

	word = input_strm.read();
	output_strm.write(word);
	ether_type(15, 8) = word.data;

	word = input_strm.read();
	output_strm.write(word);
	ether_type( 7, 0) = word.data;

	if(ether_type == net::ETHER_TYPE_ARP){
		prot_strm.write((net::protocol_t)((int)net::prot::ARP));
		net::pass_stream(input_strm, output_strm);
		return;
	}
	else if(ether_type == net::ETHER_TYPE_IPv4){
		net::ipv4_header_t ip_header;
		ip_header = net::read_pass_ipv4_header(input_strm, output_strm);

		if(ip_header.protocol == net::IP_PROTOCOL_ICMP){
			prot_strm.write((net::protocol_t)((int)net::prot::ICMP));
		}
		else if(ip_header.protocol == net::IP_PROTOCOL_UDP){
			prot_strm.write((net::protocol_t)((int)net::prot::UDP));
		}
		else{
			prot_strm.write((net::protocol_t)((int)net::prot::OTHER));
		}
		net::pass_stream(input_strm, output_strm);
		return;
	}
	else{
		prot_strm.write((net::protocol_t)((int)net::prot::OTHER));
		net::pass_stream(input_strm, output_strm);
		return;
	}


}
