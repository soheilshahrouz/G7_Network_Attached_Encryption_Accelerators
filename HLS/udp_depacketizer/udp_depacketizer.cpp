

#include <ap_int.h>
#include <hls_stream.h>

#include "../network.h"




void
udp_depacketizer(
		hls::stream<net::net_word_t> &input_strm,
		hls::stream<net::net_word_t> &output_strm,

		ap_uint<32>* dst_ip_addr,
		ap_uint<48>* dst_mac_addr
		)
{
#pragma HLS INTERFACE ap_none register port=dst_mac_addr
#pragma HLS INTERFACE ap_none register port=dst_ip_addr
#pragma HLS INTERFACE axis register both port=input_strm
#pragma HLS INTERFACE axis register both port=output_strm
#pragma HLS INTERFACE ap_ctrl_none port=return

	net::net_word_t word;
	net::ethernet_header_t ethernet_header;
	net::ipv4_header_t ip_header;
	net::udp_header_t udp_header;


	word.last = 0;


	ethernet_header = net::read_ethernet_header(input_strm);
	ip_header = net::read_ip_header(input_strm);
	udp_header = net::read_udp_header(input_strm);

	*dst_ip_addr = ip_header.src_ip;
	*dst_mac_addr = ethernet_header.src_mac_addr;

	net::pass_stream(input_strm, output_strm);
}
