

#include <ap_int.h>
#include <hls_stream.h>

#include "../network.h"




void
udp_packetizer(
		hls::stream<net::net_word_t> &input_strm,
		hls::stream<net::net_word_t> &output_strm,

		ap_uint<32> & ip_addr,
		ap_uint<32> & mac_addr_lo,
		ap_uint<16> & mac_addr_hi,

		ap_uint<32> & dst_ip_addr,
		ap_uint<48> & dst_mac_addr
		)
{
#pragma HLS INTERFACE ap_none port=dst_ip_addr
#pragma HLS INTERFACE ap_none port=dst_mac_addr
#pragma HLS INTERFACE s_axilite port=ip_addr bundle=ctrl
#pragma HLS INTERFACE s_axilite port=mac_addr_lo bundle=ctrl
#pragma HLS INTERFACE s_axilite port=mac_addr_hi bundle=ctrl
#pragma HLS INTERFACE axis register both port=input_strm
#pragma HLS INTERFACE axis register both port=output_strm
#pragma HLS INTERFACE ap_ctrl_none port=return

	net::net_word_t word;
	net::ethernet_header_t ethernet_header;
	net::ipv4_header_t ip_header;
	net::udp_header_t udp_header;

	ap_uint<32> checksum = 0;

	ap_uint<8> data_buf [1024];

	word.last = 0;

	ethernet_header.src_mac_addr(31,  0) = mac_addr_lo(31, 0);
	ethernet_header.src_mac_addr(47, 32) = mac_addr_hi(15, 0);
	ethernet_header.ether_type = net::ETHER_TYPE_IPv4;

	ip_header.version = 4;
	ip_header.IHL = 5;
	ip_header.DSCP = 0;
	ip_header.ECN = 0;
	ip_header.total_length = 20 + 8;
	ip_header.identification = 0x5894;
	ip_header.flags = 0;
	ip_header.frag_offset = 0;
	ip_header.ttl = 255;
	ip_header.protocol = net::IP_PROTOCOL_UDP;
	ip_header.header_checksum = 0;
	ip_header.src_ip = ip_addr;
	ip_header.dst_ip = dst_ip_addr;


	checksum += (ip_header.version, ip_header.IHL, ip_header.DSCP, ip_header.ECN);
//	checksum += ip_header.total_length;
	checksum += ip_header.identification;
	checksum += (ip_header.flags, ip_header.frag_offset);
	checksum += (ip_header.ttl, ip_header.protocol);
	checksum += ip_header.src_ip(31, 16);
	checksum += ip_header.src_ip(15,  0);
	checksum += ip_header.dst_ip(31, 16);
	checksum += ip_header.dst_ip(15,  0);

	udp_header.checksum = 0;
	udp_header.dst_port = 60001;
	udp_header.src_port = 50000;
	udp_header.len = 8;

	checksum += udp_header.dst_port;
	checksum += udp_header.src_port;

	payload_buffering_loop:
	for(ap_uint<11> i = 0; i < 1024; i++){
#pragma HLS PIPELINE
		word = input_strm.read();
		if(i%2){
			checksum += ((ap_uint<16>)word.data) << 8;
		}
		else{
			checksum += ((ap_uint<16>)word.data);
		}
		data_buf[i] = word.data;
		udp_header.len++;
		ip_header.total_length++;
		if(word.last){
			break;
		}
	}

	checksum += udp_header.len;
	checksum += ip_header.total_length;

	ap_uint<16> carry = checksum >> 16;
	checksum = checksum & 0x0000FFFF;
	checksum += carry;
	carry = checksum >> 16;
	checksum = checksum & 0x0000FFFF;
	checksum += carry;

	net::write_ethernet_header(output_strm, ethernet_header);
	net::write_ip_header(output_strm, ip_header);
	net::write_udp_header(output_strm, udp_header);

	output_strm_loop:
	for(ap_uint<11> i = 8; i < udp_header.len; i++){
#pragma HLS PIPELINE
		word.last = (udp_header.len-1 == i);
		word.data = data_buf[i-8];
		output_strm.write(word);
	}
}
