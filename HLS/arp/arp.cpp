

#include <ap_int.h>
#include <hls_stream.h>

#include "../network.h"




void
arp(
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
	net::arp_packet_t arp_packet;
	net::mac_addr_t mac_addr;

	word.last = 0;
	mac_addr(31,  0) = mac_addr_lo(31, 0);
	mac_addr(47, 32) = mac_addr_hi(15, 0);

	ethernet_header = net::read_ethernet_header(input_strm);
	arp_packet = net::read_arp_packet(input_strm);

	if(arp_packet.oper == net::ARP_OPER_REQUEST && arp_packet.tpa == ip_addr){

		// write ethernet header
		net::write_mac_addr(output_strm, ethernet_header.src_mac_addr, false);
		net::write_mac_addr(output_strm, mac_addr, false);
		word.data = 0x08;
		output_strm.write(word);
		word.data = 0x06;
		output_strm.write(word);

		arp_packet.oper = net::ARP_OPER_REPLY;
		arp_packet.tpa = arp_packet.spa;
		arp_packet.tha = arp_packet.sha;
		arp_packet.spa = ip_addr;
		arp_packet.sha = mac_addr;

		net::write_arp_packet(output_strm, arp_packet);
	}

}
