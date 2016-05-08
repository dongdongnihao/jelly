// ---------------------------------------------------------------------------
//  Jelly  -- the soft-core processor system
//   image processing
//
//                                 Copyright (C) 2008-2016 by Ryuji Fuchikami
//                                 http://homepage3.nifty.com/ryuz/
// ---------------------------------------------------------------------------



`timescale 1ns / 1ps
`default_nettype none


//   �t���[�����Ԓ��̃f�[�^���̖͂������Ԃ� cke �𗎂Ƃ����Ƃ�
// �O��Ƃ��ăf�[�^�f���ŁA�������� READ_FIRST ���[�h�ōœK��
//   �t���[�������œf���o���̂��߂Ƀu�����N�f�[�^������ۂ�
// line_first �� line_last �͐��������䂪�K�v

module jelly_axi4s_img
		#(
			parameter	DATA_WIDTH   = 8,
			parameter	IMG_Y_NUM    = 480,
			parameter	IMG_Y_WIDTH  = 9,
			parameter	IMG_CKE_BUFG = 0
		)
		(
			input	wire								reset,
			input	wire								clk,
			
			input	wire	[IMG_Y_WIDTH-1:0]			param_y_num,
			
			input	wire	[DATA_WIDTH-1:0]			s_axi4s_tdata,
			input	wire								s_axi4s_tlast,
			input	wire	[0:0]						s_axi4s_tuser,
			input	wire								s_axi4s_tvalid,
			output	wire								s_axi4s_tready,
			
			output	wire	[DATA_WIDTH-1:0]			m_axi4s_tdata,
			output	wire								m_axi4s_tlast,
			output	wire	[0:0]						m_axi4s_tuser,
			output	wire								m_axi4s_tvalid,
			input	wire								m_axi4s_tready,
			
			
			output	wire								img_cke,
			
			output	wire								src_img_line_first,
			output	wire								src_img_line_last,
			output	wire								src_img_pixel_first,
			output	wire								src_img_pixel_last,
			output	wire	[DATA_WIDTH-1:0]			src_img_data,
			
			input	wire								sink_img_line_first,
			input	wire								sink_img_line_last,
			input	wire								sink_img_pixel_first,
			input	wire								sink_img_pixel_last,
			input	wire	[DATA_WIDTH-1:0]			sink_img_data
		);
	
	
	wire						cke;
	
	jelly_axi4s_to_img
			#(
				.DATA_WIDTH			(DATA_WIDTH),
				.IMG_Y_WIDTH		(IMG_Y_WIDTH),
				.IMG_Y_NUM			(IMG_Y_NUM),
				.IMG_CKE_BUFG		(IMG_CKE_BUFG)
			)
		i_axi4s_to_img
			(
				.reset				(reset),
				.clk				(clk),
				.cke				(cke),
				
				.param_y_num		(param_y_num),
				
				.s_axi4s_tdata		(s_axi4s_tdata),
				.s_axi4s_tlast		(s_axi4s_tlast),
				.s_axi4s_tuser		(s_axi4s_tuser),
				.s_axi4s_tvalid		(s_axi4s_tvalid),
				.s_axi4s_tready		(s_axi4s_tready),
				
				.m_img_cke			(img_cke),
				.m_img_line_first	(src_img_line_first),
				.m_img_line_last	(src_img_line_last),
				.m_img_pixel_first	(src_img_pixel_first),
				.m_img_pixel_last	(src_img_pixel_last),
				.m_img_data			(src_img_data),
				.m_img_de			()
			);
	
	wire	[DATA_WIDTH-1:0]	axi4s_tdata;
	wire						axi4s_tlast;
	wire	[0:0]				axi4s_tuser;
	wire						axi4s_tvalid;
	wire						axi4s_tready;
	
	jelly_img_to_axi4s
			#(
				.DATA_WIDTH		(DATA_WIDTH)
			)
		i_img_to_axi4s
			(
				.reset				(reset),
				.clk				(clk),
				.cke				(img_cke),
				
				.s_img_line_first	(sink_img_line_first),
				.s_img_line_last	(sink_img_line_last),
				.s_img_pixel_first	(sink_img_pixel_first),
				.s_img_pixel_last	(sink_img_pixel_last),
				.s_img_data			(sink_img_data),
				
				.m_axi4s_tdata		(axi4s_tdata),
				.m_axi4s_tlast		(axi4s_tlast),
				.m_axi4s_tuser		(axi4s_tuser),
				.m_axi4s_tvalid		(axi4s_tvalid)
			);
	
	jelly_pipeline_insert_ff
			#(
				.DATA_WIDTH			(2+DATA_WIDTH)
			)
		i_pipeline_insert_ff
			(
				.reset				(reset),
				.clk				(clk),
				.cke				(1'b1),
				
				.s_data				({axi4s_tlast, axi4s_tuser, axi4s_tdata}),
				.s_valid			(axi4s_tvalid),
				.s_ready			(),
				
				.m_data				({m_axi4s_tlast, m_axi4s_tuser, m_axi4s_tdata}),
				.m_valid			(m_axi4s_tvalid),
				.m_ready			(m_axi4s_tready),
				
				.buffered			(),
				.s_ready_next		(cke)
			);
	
	
	/*
	reg		[AXI4S_DATA_WIDTH-1:0]		reg_buf_tdata;
	reg									reg_buf_tlast;
	reg		[AXI4S_USER_WIDTH-1:0]		reg_buf_tuser;
	reg									reg_buf_tvalid;
	reg									reg_de;
	
	always @(posedge clk) begin
		if ( reset ) begin
			reg_buf_tdata  <= {AXI4S_DATA_WIDTH{1'bx}};
			reg_buf_tlast  <= 1'bx;
			reg_buf_tuser  <= 1'bx;
			reg_buf_tvalid <= 1'b0;
			reg_de         <= 1'b0;
		end
		else begin
			if ( img_cke && !cke ) begin
				reg_buf_tdata  <= sink_img_data;
				reg_buf_tlast  <= sink_img_pixel_last;
				reg_buf_tuser  <= (sink_img_line_first && sink_img_pixel_first);
				reg_buf_tvalid <= 1'b1;
			end
			else if ( m_axi4s_tready ) begin
				reg_buf_tdata  <= {AXI4S_DATA_WIDTH{1'bx}};
				reg_buf_tlast  <= 1'bx;
				reg_buf_tuser  <= 1'bx;
				reg_buf_tvalid <= 1'b0;
			end
			
			if ( img_cke ) begin
				if ( sink_img_line_first ) begin
					reg_de <= 1'b1;
				end
				else if ( sink_img_line_last & sink_img_pixel_last ) begin
					reg_de <= 1'b0;
				end
			end
		end
	end
	
	assign cke            = !(m_axi4s_tvalid & !m_axi4s_tready) && !reg_tvalid;
	
	assign m_axi4s_tdata  = reg_buf_tvalid ? reg_buf_tdata : sink_img_data;
	assign m_axi4s_tlast  = reg_buf_tvalid ? reg_buf_tlast : sink_img_pixel_last;
	assign m_axi4s_tuser  = reg_buf_tvalid ? reg_buf_tuser : (sink_img_line_first && sink_img_pixel_first);
	assign m_axi4s_tvalid = reg_buf_tvalid ? 1'b1          : img_cke & (sink_img_line_first | reg_de);
	*/
	
endmodule


`default_nettype wire


// end of file