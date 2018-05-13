// ---------------------------------------------------------------------------
//  Jelly  -- the soft-core processor system
//   image processing
//
//                                 Copyright (C) 2008-2018 by Ryuji Fuchikami
//                                 http://ryuz.my.coocan.jp/
// ---------------------------------------------------------------------------



`timescale 1ns / 1ps
`default_nettype none


module jelly_img_demosaic_acpi_core
		#(
			parameter	USER_WIDTH = 0,
			parameter	DATA_WIDTH = 10,
			parameter	MAX_X_NUM  = 4096,
			parameter	USE_VALID  = 0,
			
			parameter	USER_BITS  = USER_WIDTH > 0 ? USER_WIDTH : 1
		)
		(
			input	wire							reset,
			input	wire							clk,
			input	wire							cke,
			
			input	wire	[1:0]					param_phase,
			
			input	wire							s_img_line_first,
			input	wire							s_img_line_last,
			input	wire							s_img_pixel_first,
			input	wire							s_img_pixel_last,
			input	wire							s_img_de,
			input	wire	[USER_BITS-1:0]			s_img_user,
			input	wire	[DATA_WIDTH-1:0]		s_img_raw,
			input	wire							s_img_valid,
			
			output	wire							m_img_line_first,
			output	wire							m_img_line_last,
			output	wire							m_img_pixel_first,
			output	wire							m_img_pixel_last,
			output	wire							m_img_de,
			output	wire	[USER_BITS-1:0]			m_img_user,
			output	wire	[DATA_WIDTH-1:0]		m_img_raw,
			output	wire	[DATA_WIDTH-1:0]		m_img_r,
			output	wire	[DATA_WIDTH-1:0]		m_img_g,
			output	wire	[DATA_WIDTH-1:0]		m_img_b,
			output	wire							m_img_valid
		);
	
	
	// G
	wire							img_g_line_first;
	wire							img_g_line_last;
	wire							img_g_pixel_first;
	wire							img_g_pixel_last;
	wire							img_g_de;
	wire	[USER_BITS-1:0]			img_g_user;
	wire	[DATA_WIDTH-1:0]		img_g_raw;
	wire	[DATA_WIDTH-1:0]		img_g_g;
	wire							img_g_valid;
	
	jelly_img_demosaic_acpi_g_core
			#(
				.USER_WIDTH			(USER_WIDTH),
				.DATA_WIDTH			(DATA_WIDTH),
				.MAX_X_NUM			(MAX_X_NUM),
				.USE_VALID			(USE_VALID)
			)
		i_img_demosaic_acpi_g_core
			(
				.reset				(reset),
				.clk				(clk),
				.cke				(cke),
				
				.s_img_line_first	(s_img_line_first),
				.s_img_line_last	(s_img_line_last),
				.s_img_pixel_first	(s_img_pixel_first),
				.s_img_pixel_last	(s_img_pixel_last),
				.s_img_de			(s_img_de),
				.s_img_user			(s_img_user),
				.s_img_raw			(s_img_raw),
				.s_img_valid		(s_img_valid),
				
				.m_img_line_first	(img_g_line_first),
				.m_img_line_last	(img_g_line_last),
				.m_img_pixel_first	(img_g_pixel_first),
				.m_img_pixel_last	(img_g_pixel_last),
				.m_img_de			(img_g_de),
				.m_img_user			(img_g_user),
				.m_img_raw			(img_g_raw),
				.m_img_g			(img_g_g),
				.m_img_valid		(img_g_valid)
			);
	
	
	// R,B
	jelly_img_demosaic_acpi_rb_core
			#(
				.USER_WIDTH			(USER_WIDTH),
				.DATA_WIDTH			(DATA_WIDTH),
				.MAX_X_NUM			(MAX_X_NUM),
				.USE_VALID			(USE_VALID)
			)
		i_img_demosaic_acpi_rb_core
			(
				.reset				(reset),
				.clk				(clk),
				.cke				(cke),
				
				.param_phase		(param_phase),
				
				.s_img_line_first	(img_g_line_first),
				.s_img_line_last	(img_g_line_last),
				.s_img_pixel_first	(img_g_pixel_first),
				.s_img_pixel_last	(img_g_pixel_last),
				.s_img_de			(img_g_de),
				.s_img_user			(img_g_user),
				.s_img_raw			(img_g_raw),
				.s_img_g			(img_g_g),
				.s_img_valid		(img_g_valid),
				
				.m_img_line_first	(m_img_line_first),
				.m_img_line_last	(m_img_line_last),
				.m_img_pixel_first	(m_img_pixel_first),
				.m_img_pixel_last	(m_img_pixel_last),
				.m_img_de			(m_img_de),
				.m_img_user			(m_img_user),
				.m_img_raw			(m_img_raw),
				.m_img_r			(m_img_r),
				.m_img_g			(m_img_g),
				.m_img_b			(m_img_b),
				.m_img_valid		(m_img_valid)
			);
	
	
endmodule


`default_nettype wire


// end of file
