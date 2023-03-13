
#pragma once

#include <ap_int.h>
#include <hls_stream.h>



namespace net {

	typedef struct{
		ap_uint<8> data;
		ap_uint<1> last;
		ap_uint<1> user;
	} net_word_t;

	typedef struct{
		ap_uint<4>  version;
		ap_uint<4>  IHL;
		ap_uint<6>  DSCP;
		ap_uint<2>  ECN;
		ap_uint<16> total_length;
		ap_uint<16> identification;
		ap_uint<3>  flags;
		ap_uint<13> frag_offset;
		ap_uint<8>  ttl;
		ap_uint<8>  protocol;
		ap_uint<16> header_checksum;
		ap_uint<32> src_ip;
		ap_uint<32> dst_ip;
	} ipv4_header_t;

	typedef struct{
		ap_uint<48> dst_mac_addr;
		ap_uint<48> src_mac_addr;
		ap_uint<16> ether_type;
	} ethernet_header_t;

	typedef struct{
		ap_uint<16> htype;
		ap_uint<16> ptype;
		ap_uint<8>  hlen;
		ap_uint<8>  plen;
		ap_uint<16> oper;
		ap_uint<48> sha;
		ap_uint<32> spa;
		ap_uint<48> tha;
		ap_uint<32> tpa;
	} arp_packet_t;

	typedef struct{
		ap_uint<8>  type;
		ap_uint<8>  code;
		ap_uint<16> checksum;
	} icmp_header_t;

	typedef struct{
		ap_uint<16> src_port;
		ap_uint<16> dst_port;
		ap_uint<16> len;
		ap_uint<16> checksum;
	} udp_header_t;



	typedef ap_uint<8> protocol_t;
	typedef ap_uint<48> mac_addr_t;
	typedef ap_uint<16> ether_type_t;
	typedef ap_uint<8> ip_protocol_type_t;

	const ether_type_t ETHER_TYPE_IPv4 = 0x0800;
	const ether_type_t ETHER_TYPE_ARP  = 0x0806;
	const ip_protocol_type_t IP_PROTOCOL_ICMP = 0x01;
	const ip_protocol_type_t IP_PROTOCOL_UDP = 0x11;
	const ap_uint<16> ARP_OPER_REQUEST = 0x0001;
	const ap_uint<16> ARP_OPER_REPLY   = 0x0002;

	mac_addr_t read_mac_addr(hls::stream<net_word_t> &input_strm);
	ethernet_header_t read_ethernet_header(hls::stream<net_word_t> &input_strm);
	arp_packet_t read_arp_packet(hls::stream<net_word_t> &input_strm);
	ipv4_header_t read_ip_header(hls::stream<net_word_t> &input_strm);
	udp_header_t read_udp_header(hls::stream<net_word_t> &input_strm);


	void write_mac_addr(hls::stream<net_word_t> &output_strm, mac_addr_t mac_addr, bool last);
	void write_arp_packet(hls::stream<net_word_t> &output_strm, arp_packet_t arp_packet);
	void write_ethernet_header(hls::stream<net_word_t> &output_strm, ethernet_header_t header);
	void write_ip_header(hls::stream<net_word_t> &output_strm, ipv4_header_t ip_header);
	void write_udp_header(hls::stream<net_word_t> &output_strm, udp_header_t udp_header);

	void pass_stream(hls::stream<net_word_t> &input_strm, hls::stream<net_word_t> &output_strm);
	void discard_stream(hls::stream<net_word_t> &input_strm);

	enum class prot { ARP = 0, ICMP, UDP_STRM, UDP_REG, OTHER };


	ipv4_header_t read_pass_ipv4_header(hls::stream<net_word_t> &input_strm, hls::stream<net_word_t> &output_strm);
	udp_header_t read_pass_udp_header(hls::stream<net_word_t> &input_strm, hls::stream<net_word_t> &output_strm);

}  // namespace net
