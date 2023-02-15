
#include "network.h"


//enum class net::prot { ARP = 0, ICMP, UDP, OTHER };

net::mac_addr_t
net::read_mac_addr(hls::stream<net::net_word_t> &input_strm)
{
#pragma HLS INLINE

	net::net_word_t word;
	net::mac_addr_t mac_addr;

	word = input_strm.read();
	mac_addr(47, 40) = word.data;
	word = input_strm.read();
	mac_addr(39, 32) = word.data;
	word = input_strm.read();
	mac_addr(31, 24) = word.data;
	word = input_strm.read();
	mac_addr(23, 16) = word.data;
	word = input_strm.read();
	mac_addr(15,  8) = word.data;
	word = input_strm.read();
	mac_addr( 7,  0) = word.data;

	return mac_addr;
}


net::ethernet_header_t
net::read_ethernet_header(hls::stream<net::net_word_t> &input_strm)
{
	net::ethernet_header_t header;
	net_word_t word;

	header.dst_mac_addr = net::read_mac_addr(input_strm);
	header.src_mac_addr = net::read_mac_addr(input_strm);

	word = input_strm.read();
	header.ether_type(15, 8) = word.data;

	word = input_strm.read();
	header.ether_type( 7, 0) = word.data;

	return header;
}


void
net::write_mac_addr(hls::stream<net::net_word_t> &output_strm, net::mac_addr_t mac_addr, bool last)
{
#pragma HLS INLINE

	net::net_word_t word;
	word.last = 0;
	word.user = 0;

	word.data = mac_addr(47, 40);
	output_strm.write(word);
	word.data = mac_addr(39, 32);
	output_strm.write(word);
	word.data = mac_addr(31, 24);
	output_strm.write(word);
	word.data = mac_addr(23, 16);
	output_strm.write(word);
	word.data = mac_addr(15,  8);
	output_strm.write(word);

	word.data = mac_addr( 7,  0);
	word.last = last;
	output_strm.write(word);
}


void
net::pass_stream(hls::stream<net_word_t> &input_strm, hls::stream<net_word_t> &output_strm)
{
#pragma HLS INLINE

	net::net_word_t word;

	do{
#pragma HLS PIPELINE
		word = input_strm.read();
		output_strm.write(word);
	}while(word.last == 0);
}


void
net::discard_stream(hls::stream<net_word_t> &input_strm)
{
#pragma HLS INLINE

	net::net_word_t word;

	do{
#pragma HLS PIPELINE
		word = input_strm.read();
	}while(word.last == 0);
}



net::ipv4_header_t
net::read_pass_ipv4_header(hls::stream<net::net_word_t> &input_strm, hls::stream<net::net_word_t> &output_strm)
{
#pragma HLS INLINE

	net::ipv4_header_t ip_header;
	net::net_word_t word;

	// read Version & IHL
	word = input_strm.read();
	output_strm.write(word);
	ip_header.version = word.data(7, 4);
	ip_header.IHL = word.data(3, 0);

	// read DSCP & ECN
	word = input_strm.read();
	output_strm.write(word);
	ip_header.DSCP = word.data(7, 2);
	ip_header.ECN = word.data(1, 0);

	// read Total Length
	word = input_strm.read();
	output_strm.write(word);
	ip_header.total_length(15, 8) = word.data;
	word = input_strm.read();
	output_strm.write(word);
	ip_header.total_length( 7, 0) = word.data;


	// read Identification
	word = input_strm.read();
	output_strm.write(word);
	ip_header.identification(15, 8) = word.data;
	word = input_strm.read();
	output_strm.write(word);
	ip_header.identification( 7, 0) = word.data;

	// read Identification
	word = input_strm.read();
	output_strm.write(word);
	ip_header.flags = word.data(7, 5);
	ip_header.frag_offset(12, 8) = word.data(4, 0);
	word = input_strm.read();
	output_strm.write(word);
	ip_header.frag_offset( 7, 0) = word.data;


	// read TTL
	word = input_strm.read();
	output_strm.write(word);
	ip_header.ttl = word.data;

	// read Protocol
	word = input_strm.read();
	output_strm.write(word);
	ip_header.protocol = word.data;

	// read Header checksum
	word = input_strm.read();
	output_strm.write(word);
	ip_header.header_checksum(15, 8) = word.data;
	word = input_strm.read();
	output_strm.write(word);
	ip_header.header_checksum( 7, 0) = word.data;

	// read source IP
	word = input_strm.read();
	output_strm.write(word);
	ip_header.src_ip(31, 24) = word.data;
	word = input_strm.read();
	output_strm.write(word);
	ip_header.src_ip(23, 16) = word.data;
	word = input_strm.read();
	output_strm.write(word);
	ip_header.src_ip(15,  8) = word.data;
	word = input_strm.read();
	output_strm.write(word);
	ip_header.src_ip( 7,  0) = word.data;

	// read destination IP
	word = input_strm.read();
	output_strm.write(word);
	ip_header.dst_ip(31, 24) = word.data;
	word = input_strm.read();
	output_strm.write(word);
	ip_header.dst_ip(23, 16) = word.data;
	word = input_strm.read();
	output_strm.write(word);
	ip_header.dst_ip(15,  8) = word.data;
	word = input_strm.read();
	output_strm.write(word);
	ip_header.dst_ip( 7,  0) = word.data;

	return ip_header;
}


net::arp_packet_t
net::read_arp_packet(hls::stream<net::net_word_t> &input_strm)
{
#pragma HLS INLINE

	net::arp_packet_t arp_packet;
	net::net_word_t word;

	word = input_strm.read();
	arp_packet.htype(15, 8) = word.data;
	word = input_strm.read();
	arp_packet.htype( 7, 0) = word.data;

	word = input_strm.read();
	arp_packet.ptype(15, 8) = word.data;
	word = input_strm.read();
	arp_packet.ptype( 7, 0) = word.data;

	word = input_strm.read();
	arp_packet.hlen( 7, 0) = word.data;

	word = input_strm.read();
	arp_packet.plen( 7, 0) = word.data;

	word = input_strm.read();
	arp_packet.oper(15, 8) = word.data;
	word = input_strm.read();
	arp_packet.oper( 7, 0) = word.data;

	word = input_strm.read();
	arp_packet.sha(47, 40) = word.data;
	word = input_strm.read();
	arp_packet.sha(39, 32) = word.data;
	word = input_strm.read();
	arp_packet.sha(31, 24) = word.data;
	word = input_strm.read();
	arp_packet.sha(23, 16) = word.data;
	word = input_strm.read();
	arp_packet.sha(15,  8) = word.data;
	word = input_strm.read();
	arp_packet.sha( 7,  0) = word.data;

	arp_packet.spa(31, 24) = word.data;
	word = input_strm.read();
	arp_packet.spa(23, 16) = word.data;
	word = input_strm.read();
	arp_packet.spa(15,  8) = word.data;
	word = input_strm.read();
	arp_packet.spa( 7,  0) = word.data;

	word = input_strm.read();
	arp_packet.tha(47, 40) = word.data;
	word = input_strm.read();
	arp_packet.tha(39, 32) = word.data;
	word = input_strm.read();
	arp_packet.tha(31, 24) = word.data;
	word = input_strm.read();
	arp_packet.tha(23, 16) = word.data;
	word = input_strm.read();
	arp_packet.tha(15,  8) = word.data;
	word = input_strm.read();
	arp_packet.tha( 7,  0) = word.data;

	arp_packet.tpa(31, 24) = word.data;
	word = input_strm.read();
	arp_packet.tpa(23, 16) = word.data;
	word = input_strm.read();
	arp_packet.tpa(15,  8) = word.data;
	word = input_strm.read();
	arp_packet.tpa( 7,  0) = word.data;

	while(word.last == 0){
		word = input_strm.read();
	}

	return arp_packet;
}


void
net::write_arp_packet(hls::stream<net::net_word_t> &output_strm, net::arp_packet_t arp_packet)
{
#pragma HLS INLINE

	net::net_word_t word;
	word.last = 0;

	word.data = arp_packet.htype(15, 8);
	output_strm.write(word);
	word.data = arp_packet.htype( 7, 0);
	output_strm.write(word);

	word.data = arp_packet.ptype(15, 8);
	output_strm.write(word);
	word.data = arp_packet.ptype( 7, 0);
	output_strm.write(word);

	word.data = arp_packet.hlen( 7, 0);
	output_strm.write(word);

	word.data = arp_packet.plen( 7, 0);
	output_strm.write(word);

	word.data = arp_packet.oper(15, 8);
	output_strm.write(word);
	word.data = arp_packet.oper( 7, 0);
	output_strm.write(word);

	word.data = arp_packet.sha(47, 40);
	output_strm.write(word);
	word.data = arp_packet.sha(39, 32);
	output_strm.write(word);
	word.data = arp_packet.sha(31, 24);
	output_strm.write(word);
	word.data = arp_packet.sha(23, 16);
	output_strm.write(word);
	word.data = arp_packet.sha(15,  8);
	output_strm.write(word);
	word.data = arp_packet.sha( 7,  0);
	output_strm.write(word);

	word.data = arp_packet.spa(31, 24);
	output_strm.write(word);
	word.data = arp_packet.spa(23, 16);
	output_strm.write(word);
	word.data = arp_packet.spa(15,  8);
	output_strm.write(word);
	word.data = arp_packet.spa( 7,  0);
	output_strm.write(word);


	word.data = arp_packet.tha(47, 40);
	output_strm.write(word);
	word.data = arp_packet.tha(39, 32);
	output_strm.write(word);
	word.data = arp_packet.tha(31, 24);
	output_strm.write(word);
	word.data = arp_packet.tha(23, 16);
	output_strm.write(word);
	word.data = arp_packet.tha(15,  8);
	output_strm.write(word);
	word.data = arp_packet.tha( 7,  0);
	output_strm.write(word);

	word.data = arp_packet.tpa(31, 24);
	output_strm.write(word);
	word.data = arp_packet.tpa(23, 16);
	output_strm.write(word);
	word.data = arp_packet.tpa(15,  8);
	output_strm.write(word);
	word.data = arp_packet.tpa( 7,  0);
	word.last = 1;
	output_strm.write(word);
}
