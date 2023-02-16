

#include <ap_int.h>
#include <hls_stream.h>

#include "../network.h"




void
icmp(
		hls::stream<net::net_word_t> &input_strm,
		hls::stream<net::net_word_t> &output_strm,

		ap_uint<32> & ip_addr,
		ap_uint<32> & mac_addr_lo,
		ap_uint<16> & mac_addr_hi
		)
{
#pragma HLS INTERFACE s_axilite port=ip_addr bundle=ctrl
#pragma HLS INTERFACE s_axilite port=mac_addr_lo bundle=ctrl
#pragma HLS INTERFACE s_axilite port=mac_addr_hi bundle=ctrl
#pragma HLS INTERFACE axis register both port=input_strm
#pragma HLS INTERFACE axis register both port=output_strm
#pragma HLS INTERFACE ap_ctrl_none port=return

	net::net_word_t word;
	net::ethernet_header_t ethernet_header;
	net::mac_addr_t mac_addr;
	net::ipv4_header_t ip_header;
	net::icmp_header_t icmp_header;

	ap_uint<8> ip_options[40];
	ap_uint<8> ip_options_len;

	word.last = 0;
	mac_addr(31,  0) = mac_addr_lo(31, 0);
	mac_addr(47, 32) = mac_addr_hi(15, 0);

	ethernet_header = net::read_ethernet_header(input_strm);

	ip_header = net::read_ip_header(input_strm);
	ip_options_len = ip_header.IHL;
	ip_options_len *= 4;
	ip_options_len -= 20;

	for(ap_uint<8> i = 0; i < ip_options_len; i++){
		word = input_strm.read();
		ip_options[i] = word.data;
	}

	word = input_strm.read();
	icmp_header.type = word.data;

	word = input_strm.read();
	icmp_header.code = word.data;

	word = input_strm.read();
	icmp_header.checksum(15, 8) = word.data;
	word = input_strm.read();
	icmp_header.checksum( 7, 0) = word.data;

	if(icmp_header.type == 8 && ip_header.dst_ip == ip_addr){	// echo request
		word.last = 0;

		// write ethernet header
		net::write_mac_addr(output_strm, ethernet_header.src_mac_addr, false);
		net::write_mac_addr(output_strm, mac_addr, false);
		word.data = 0x08;
		output_strm.write(word);
		word.data = 0x00;
		output_strm.write(word);

		// write ip header
		ip_header.dst_ip = ip_header.src_ip;
		ip_header.src_ip = ip_addr;
		net::write_ip_header(output_strm, ip_header);

		for(ap_uint<8> i = 0; i < ip_options_len; i++){
			word.data = ip_options[i];
			output_strm.write(word);
		}

		// ICMP type
		word.data = 0;
		output_strm.write(word);

		word.data = icmp_header.code;
		output_strm.write(word);

		icmp_header.checksum -= 8;
		word.data = icmp_header.checksum(15, 8);
		output_strm.write(word);
		word.data = icmp_header.checksum( 7, 0);
		output_strm.write(word);

		net::pass_stream(input_strm, output_strm);
	}
	else{
		net::discard_stream(input_strm);
	}

}



