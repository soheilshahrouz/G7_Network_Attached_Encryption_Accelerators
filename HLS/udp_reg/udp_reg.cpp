

#include <ap_int.h>
#include <hls_stream.h>
#include <algorithm>

#include "../network.h"




void
udp_reg(
		hls::stream<net::net_word_t> &input_strm,
		hls::stream<net::net_word_t> &output_strm,
		ap_uint<32> *reg_space
		)
{
#pragma HLS INTERFACE m_axi depth=1 port=reg_space offset=off
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

	ap_uint<32> reg_addr;
	ap_uint<32> reg_data;

	ap_uint<8> data_buf[1536];
	ap_uint<16> buf_cnt = 0;

	if(udp_header.dst_port == 50000){ // write register
		for(ap_uint<16> i = 8; i < udp_header.len; i+=8){

			word = input_strm.read();
			reg_addr(31, 24) = word.data;
			word = input_strm.read();
			reg_addr(23, 16) = word.data;
			word = input_strm.read();
			reg_addr(15,  8) = word.data;
			word = input_strm.read();
			reg_addr( 7,  0) = word.data;

			word = input_strm.read();
			reg_data(31, 24) = word.data;
			word = input_strm.read();
			reg_data(23, 16) = word.data;
			word = input_strm.read();
			reg_data(15,  8) = word.data;
			word = input_strm.read();
			reg_data( 7,  0) = word.data;

			reg_space[reg_addr >> 2] = reg_data;

		}
	}
	else if(udp_header.dst_port == 40000){

		for(ap_uint<16> i = 8; i < udp_header.len; i+=8){

			word = input_strm.read();
			reg_addr(31, 24) = word.data;
			word = input_strm.read();
			reg_addr(23, 16) = word.data;
			word = input_strm.read();
			reg_addr(15,  8) = word.data;
			word = input_strm.read();
			reg_addr( 7,  0) = word.data;

			data_buf[buf_cnt] = reg_addr(31, 24);
			buf_cnt++;
			data_buf[buf_cnt] = reg_addr(23, 16);
			buf_cnt++;
			data_buf[buf_cnt] = reg_addr(15,  8);
			buf_cnt++;
			data_buf[buf_cnt] = reg_addr( 7,  0);
			buf_cnt++;

			reg_data = reg_space[reg_addr >> 2];

			data_buf[buf_cnt] = reg_data(31, 24);
			buf_cnt++;
			data_buf[buf_cnt] = reg_data(23, 16);
			buf_cnt++;
			data_buf[buf_cnt] = reg_data(15,  8);
			buf_cnt++;
			data_buf[buf_cnt] = reg_data( 7,  0);
			buf_cnt++;
		}

		std::swap(ethernet_header.dst_mac_addr, ethernet_header.src_mac_addr);
		std::swap(ip_header.dst_ip, ip_header.src_ip);
		ip_header.total_length += buf_cnt/2;
		ap_uint<17> checksum = ip_header.header_checksum;
		checksum += (buf_cnt/2);
		checksum += checksum >> 16;
		ip_header.header_checksum = checksum(15, 0);

		udp_header.checksum = 0;
		udp_header.len = 8 + buf_cnt;

		net::write_ethernet_header(output_strm, ethernet_header);
		net::write_ip_header(output_strm, ip_header);
		net::write_udp_header(output_strm, udp_header);

		net::net_word_t write_word;
		write_word.last = 0;
		for(ap_uint<16> i = 0; i < buf_cnt; i++){
			write_word.data = data_buf[i];
			write_word.last = (i == buf_cnt-1);
			output_strm.write(write_word);
		}

	}


	if(!word.last){
		net::discard_stream(input_strm);
	}


}
