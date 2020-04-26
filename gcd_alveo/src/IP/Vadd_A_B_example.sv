// This is a generated file. Use and modify at your own risk.
//////////////////////////////////////////////////////////////////////////////// 
// default_nettype of none prevents implicit wire declaration.
`default_nettype none

module Top_wrapper #(
  parameter integer C_M00_AXI_ADDR_WIDTH = 64 ,
  parameter integer C_M00_AXI_DATA_WIDTH = 512,
  parameter integer C_M01_AXI_ADDR_WIDTH = 64 ,
  parameter integer C_M01_AXI_DATA_WIDTH = 512
)
(
  // System Signals
  input  wire                              ap_clk         ,
  input  wire                              ap_rst_n       ,
  // AXI4 master interface m00_axi
  output wire                              m00_axi_awvalid,
  input  wire                              m00_axi_awready,
  output wire [C_M00_AXI_ADDR_WIDTH-1:0]   m00_axi_awaddr ,
  output wire [8-1:0]                      m00_axi_awlen  ,
  output wire                              m00_axi_wvalid ,
  input  wire                              m00_axi_wready ,
  output wire [C_M00_AXI_DATA_WIDTH-1:0]   m00_axi_wdata  ,
  output wire [C_M00_AXI_DATA_WIDTH/8-1:0] m00_axi_wstrb  ,
  output wire                              m00_axi_wlast  ,
  input  wire                              m00_axi_bvalid ,
  output wire                              m00_axi_bready ,
  output wire                              m00_axi_arvalid,
  input  wire                              m00_axi_arready,
  output wire [C_M00_AXI_ADDR_WIDTH-1:0]   m00_axi_araddr ,
  output wire [8-1:0]                      m00_axi_arlen  ,
  input  wire                              m00_axi_rvalid ,
  output wire                              m00_axi_rready ,
  input  wire [C_M00_AXI_DATA_WIDTH-1:0]   m00_axi_rdata  ,
  input  wire                              m00_axi_rlast  ,
  // AXI4 master interface m01_axi
  output wire                              m01_axi_awvalid,
  input  wire                              m01_axi_awready,
  output wire [C_M01_AXI_ADDR_WIDTH-1:0]   m01_axi_awaddr ,
  output wire [8-1:0]                      m01_axi_awlen  ,
  output wire                              m01_axi_wvalid ,
  input  wire                              m01_axi_wready ,
  output wire [C_M01_AXI_DATA_WIDTH-1:0]   m01_axi_wdata  ,
  output wire [C_M01_AXI_DATA_WIDTH/8-1:0] m01_axi_wstrb  ,
  output wire                              m01_axi_wlast  ,
  input  wire                              m01_axi_bvalid ,
  output wire                              m01_axi_bready ,
  output wire                              m01_axi_arvalid,
  input  wire                              m01_axi_arready,
  output wire [C_M01_AXI_ADDR_WIDTH-1:0]   m01_axi_araddr ,
  output wire [8-1:0]                      m01_axi_arlen  ,
  input  wire                              m01_axi_rvalid ,
  output wire                              m01_axi_rready ,
  input  wire [C_M01_AXI_DATA_WIDTH-1:0]   m01_axi_rdata  ,
  input  wire                              m01_axi_rlast  ,
  // SDx Control Signals
  input  wire                              ap_start       ,
  output wire                              ap_idle        ,
  output wire                              ap_done        ,
  input  wire [32-1:0]                     scalar00       ,
  output wire                               ap_ready,
  input  wire [64-1:0]                     A              ,
  input  wire [64-1:0]                     B              
);


timeunit 1ps;
timeprecision 1ps;

///////////////////////////////////////////////////////////////////////////////
// Local Parameters
///////////////////////////////////////////////////////////////////////////////
// Large enough for interesting traffic.
localparam integer  LP_DEFAULT_LENGTH_IN_BYTES = 16384;
localparam integer  LP_NUM_EXAMPLES    = 2;

///////////////////////////////////////////////////////////////////////////////
// Wires and Variables
///////////////////////////////////////////////////////////////////////////////
(* KEEP = "yes" *)
logic                                areset                         = 1'b0;
logic                                ap_start_r                     = 1'b0;
logic                                ap_idle_r                      = 1'b1;
logic                                ap_start_pulse                ;
logic [LP_NUM_EXAMPLES-1:0]          ap_done_i                     ;
logic [LP_NUM_EXAMPLES-1:0]          ap_done_r                      = {LP_NUM_EXAMPLES{1'b0}};
logic [32-1:0]                       ctrl_xfer_size_in_bytes        = LP_DEFAULT_LENGTH_IN_BYTES;
logic [32-1:0]                       ctrl_constant                  = 32'd1;
logic                          a_rd_tvalid;
logic                          a_rd_tready;
logic                          a_rd_tlast;
logic [C_M00_AXI_DATA_WIDTH-1:0] a_rd_tdata;
logic                          b_rd_tvalid;
logic                          b_rd_tready;
logic                          b_rd_tlast;
logic [C_M01_AXI_DATA_WIDTH-1:0] b_rd_tdata;
logic                          out_tvalid;
logic                          out_tready;
logic                          out_tlast;
logic [C_M01_AXI_DATA_WIDTH-1:0] out_tdata;
logic                          reading_done;
logic                          gcd_start;
logic                          gcd_start_in;
logic                          gcd_done;
logic                          gcd_done_in;
logic                          write_done;
logic                   [15:0] gcd_input_A [C_M00_AXI_DATA_WIDTH/16-1];
logic                   [15:0] gcd_input_B [C_M01_AXI_DATA_WIDTH/16-1];
logic                   [15:0] gcd_out [C_M01_AXI_DATA_WIDTH/16-1];                         
///////////////////////////////////////////////////////////////////////////////
// Begin RTL
///////////////////////////////////////////////////////////////////////////////
localparam integer LP_DW_BYTES             = C_M01_AXI_DATA_WIDTH/8;
localparam integer LP_AXI_BURST_LEN        = 4096/LP_DW_BYTES < 256 ? 4096/LP_DW_BYTES : 256;
localparam integer LP_LOG_BURST_LEN        = $clog2(LP_AXI_BURST_LEN);
localparam integer LP_BRAM_DEPTH           = 512;
localparam integer LP_RD_MAX_OUTSTANDING   = LP_BRAM_DEPTH / LP_AXI_BURST_LEN;
localparam integer LP_WR_MAX_OUTSTANDING   = 32;
localparam integer C_GCD_BIT_WIDTH         = 16;
localparam integer NUM_LOOPS               = C_M00_AXI_DATA_WIDTH/C_GCD_BIT_WIDTH;




// Register and invert reset signal.
always @(posedge ap_clk) begin
  areset <= ~ap_rst_n;
end

// create pulse when ap_start transitions to 1
always @(posedge ap_clk) begin
  begin
    ap_start_r <= ap_start;
  end
end

assign ap_start_pulse = ap_start & ~ap_start_r;

// ap_idle is asserted when done is asserted, it is de-asserted when ap_start_pulse
// is asserted
always @(posedge ap_clk) begin
  if (areset) begin
    ap_idle_r <= 1'b1;
  end
  else begin
    ap_idle_r <= ap_done ? 1'b1 :
      ap_start_pulse ? 1'b0 : ap_idle;
  end
end

assign ap_idle = ap_idle_r;

// Done logic
always @(posedge ap_clk) begin
  if (areset) begin
    ap_done_r <= '0;
  end
  else begin
    ap_done_r <= (ap_start_pulse | ap_done) ? '0 : ap_done_r | ap_done_i;
  end
end

assign reading_done = (ap_done_i[0] && ap_done_i[1]);

// ready logic 

assign ap_ready = ap_done;

// Vadd example
Vadd_A #(
  .C_M_AXI_ADDR_WIDTH ( C_M00_AXI_ADDR_WIDTH ),
  .C_M_AXI_DATA_WIDTH ( C_M00_AXI_DATA_WIDTH ),
  .C_ADDER_BIT_WIDTH  ( 32                   ),
  .C_XFER_SIZE_WIDTH  ( 32                   )
)
Vector_A (
   .aclk                    ( ap_clk                  ),
  .areset                  ( areset                  ),
  .kernel_clk              ( ap_clk                  ),
  .kernel_rst              ( areset                  ),
  .ctrl_addr_offset        ( A                       ),
  .ctrl_xfer_size_in_bytes ( ctrl_xfer_size_in_bytes ),
  .ctrl_constant           ( ctrl_constant           ),
  .ap_start                ( ap_start_pulse          ),
  .ap_done                 ( ap_done_i[0]            ),
  .m_axi_awvalid           ( m00_axi_awvalid         ),
  .m_axi_awready           ( m00_axi_awready         ),
  .m_axi_awaddr            ( m00_axi_awaddr          ),
  .m_axi_awlen             ( m00_axi_awlen           ),
  .m_axi_wvalid            ( m00_axi_wvalid          ),
  .m_axi_wready            ( m00_axi_wready          ),
  .m_axi_wdata             ( m00_axi_wdata           ),
  .m_axi_wstrb             ( m00_axi_wstrb           ),
  .m_axi_wlast             ( m00_axi_wlast           ),
  .m_axi_bvalid            ( m00_axi_bvalid          ),
  .m_axi_bready            ( m00_axi_bready          ),
  .m_axi_arvalid           ( m00_axi_arvalid         ),
  .m_axi_arready           ( m00_axi_arready         ),
  .m_axi_araddr            ( m00_axi_araddr          ),
  .m_axi_arlen             ( m00_axi_arlen           ),
  .m_axi_rvalid            ( m00_axi_rvalid          ),
  .m_axi_rready            ( m00_axi_rready          ),
  .m_axi_rdata             ( m00_axi_rdata           ),
  .m_axi_rlast             ( m00_axi_rlast           ),
  .rd_tvalid               ( a_rd_tvalid             ) ,
  .rd_tready               ( a_rd_tready             ) ,
  .rd_tlast                ( a_rd_tlast              ) ,
  .rd_tdata                ( a_rd_tdata              )
);


// Vadd example
Vadd_B #(
  .C_M_AXI_ADDR_WIDTH ( C_M01_AXI_ADDR_WIDTH ),
  .C_M_AXI_DATA_WIDTH ( C_M01_AXI_DATA_WIDTH ),
  .C_ADDER_BIT_WIDTH  ( 32                   ),
  .C_XFER_SIZE_WIDTH  ( 32                   )
)
Vector_B (
  .aclk                    ( ap_clk                  ),
  .areset                  ( areset                  ),
  .kernel_clk              ( ap_clk                  ),
  .kernel_rst              ( areset                  ),
  .ctrl_addr_offset        ( B                       ),
  .ctrl_xfer_size_in_bytes ( ctrl_xfer_size_in_bytes ),
  .ctrl_constant           ( ctrl_constant           ),
  .ap_start                ( ap_start_pulse          ),
  .ap_done                 ( ap_done_i[1]            ),
  .m_axi_awvalid           ( m01_axi_awvalid         ),
  .m_axi_awready           ( m01_axi_awready         ),
  .m_axi_awaddr            ( m01_axi_awaddr          ),
  .m_axi_awlen             ( m01_axi_awlen           ),
  .m_axi_wvalid            ( m01_axi_wvalid          ),
  .m_axi_wready            ( m01_axi_wready          ),
  .m_axi_wdata             ( m01_axi_wdata           ),
  .m_axi_wstrb             ( m01_axi_wstrb           ),
  .m_axi_wlast             ( m01_axi_wlast           ),
  .m_axi_bvalid            ( m01_axi_bvalid          ),
  .m_axi_bready            ( m01_axi_bready          ),
  .m_axi_arvalid           ( m01_axi_arvalid         ),
  .m_axi_arready           ( m01_axi_arready         ),
  .m_axi_araddr            ( m01_axi_araddr          ),
  .m_axi_arlen             ( m01_axi_arlen           ),
  .m_axi_rvalid            ( m01_axi_rvalid          ),
  .m_axi_rready            ( m01_axi_rready          ),
  .m_axi_rdata             ( m01_axi_rdata           ),
  .m_axi_rlast             ( m01_axi_rlast           ),
  .rd_tvalid             ( b_rd_tvalid             ) ,
  .rd_tready             ( b_rd_tready             ) ,
  .rd_tlast              ( b_rd_tlast              ) ,
  .rd_tdata              ( b_rd_tdata              )
);

// AXI4 Write Master
Vadd_A_B_example_axi_write_master #(
  .C_M_AXI_ADDR_WIDTH  ( C_M01_AXI_ADDR_WIDTH    ) ,
  .C_M_AXI_DATA_WIDTH  ( C_M01_AXI_DATA_WIDTH    ) ,
  .C_XFER_SIZE_WIDTH   ( 32                    ) ,
  .C_MAX_OUTSTANDING   ( LP_WR_MAX_OUTSTANDING ) ,
  .C_INCLUDE_DATA_FIFO ( 1                     )
)
AXI_write (
  .aclk                    ( ap_clk                  ) ,
  .areset                  ( areset                  ) ,
  .ctrl_start              ( ap_start                ) ,
  .ctrl_done               ( write_done              ) ,
  .ctrl_addr_offset        ( B                       ) ,
  .ctrl_xfer_size_in_bytes ( ctrl_xfer_size_in_bytes ) ,
  .m_axi_awvalid           ( m01_axi_awvalid           ) ,
  .m_axi_awready           ( m01_axi_awready           ) ,
  .m_axi_awaddr            ( m01_axi_awaddr            ) ,
  .m_axi_awlen             ( m01_axi_awlen             ) ,
  .m_axi_wvalid            ( m01_axi_wvalid            ) ,
  .m_axi_wready            ( m01_axi_wready            ) ,
  .m_axi_wdata             ( m01_axi_wdata             ) ,
  .m_axi_wstrb             ( m01_axi_wstrb             ) ,
  .m_axi_wlast             ( m01_axi_wlast             ) ,
  .m_axi_bvalid            ( m01_axi_bvalid            ) ,
  .m_axi_bready            ( m01_axi_bready            ) ,
  .s_axis_aclk             ( ap_clk                  ) ,
  .s_axis_areset           ( areset                  ) ,
  .s_axis_tvalid           ( out_tvalid              ) ,
  .s_axis_tready           ( out_tready              ) ,
  .s_axis_tdata            ( out_tdata               )
);

GcdFSM #(
  .SIZE (NUM_LOOPS)
)
fsm (
  .clk         ( ap_clk ),
  .reset       ( areset ),
  .A           ( gcd_input_A ),
  .B           ( gcd_input_B ),
  .start       ( gcd_start  ),
  .req_rdy     ( b_rd_tready ),
  .out         ( gcd_out  ),
  .done        ( out_tvalid ),
  .resp_rdy    ( out_tready  )

);

genvar i;
generate
	for (i=0; i<NUM_LOOPS; i=i+1 ) begin
		assign gcd_input_A[i] = a_rd_tdata[i*C_GCD_BIT_WIDTH+:C_GCD_BIT_WIDTH];
                assign gcd_input_B[i] = b_rd_tdata[i*C_GCD_BIT_WIDTH+:C_GCD_BIT_WIDTH];
                assign out_tdata[i*C_GCD_BIT_WIDTH+:C_GCD_BIT_WIDTH] = gcd_out[i];
	end
endgenerate

assign a_rd_tready = b_rd_tready;
assign gcd_start = a_rd_tready & b_rd_tready & a_rd_tvalid & b_rd_tvalid;
assign ap_done = write_done; 
endmodule : Top_wrapper
`default_nettype wire
