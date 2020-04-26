//============
// GCD FSM
//============

`include "GcdUnitRTL.sv"

module GcdFSM #(
  parameter integer SIZE = 1;
)
(
  input  logic			clk,
  input  logic			reset,
  input  logic          start,
  input  logic          resp_rdy,
     
  input  logic [15:0] 	A[SIZE-1],
  
  input  logic [15:0] 	B[SIZE-1],
  
  output logic [15:0]   out[SIZE-1], 
  output logic          done,
  output logic          req_rdy
);

  localparam integer LOG_SIZE = $clog2(SIZE);
  logic [LOG_SIZE:0] idx_in, idx_in_in;
  logic [LOG_SIZE:0] idx_out, idx_out_in;
  logic [LOG_SIZE:0] size;
  
  logic        req_val;
  logic	       req_rdy;
  logic        resp_val;
  logic        resp_rdy;
  logic [31:0] req_msg;
  logic [15:0] resp_msg;
  
tut4_verilog_gcd_GcdUnitRTL gcd
(
  .clk      (clk),
  .reset    (reset),
  .req_val  (req_val),
  .req_rdy  (req_rdy),
  .req_msg  (req_msg),
  .resp_val (resp_val),
  .resp_rdy (resp_rdy),
  .resp_msg (resp_msg)
);

typedef enum logic [2:0] {
	STATE_INIT,
	STATE_GCD,
	STATE_DONE
} state_t;

state_t state_reg;

always_ff @(posedge clk) begin
	
	if (reset) begin
		state_reg <= STATE_INIT;
	end
	else begin
		case (state_reg)
			STATE_INIT: 
						if (start) begin
							state_reg <= STATE_GCD;
						end
						else begin
							state_reg <= STATE_INIT;
						end
			STATE_GCD:  
						if (idx_out == size) begin  
							state_reg <= STATE_DONE;
						end
						else begin
							state_reg <= STATE_GCD;
						end
			STATE_DONE:
						if (resp_rdy) begin
							state_reg <= STATE_INIT;
						end
						else begin
							state_reg <= STATE_DONE;
						end
			default:  state_reg <= STATE_INIT;
		endcase
	end
end

always_ff @(posedge clk) begin
	idx_in <= idx_in_in;
	idx_out <= idx_out_in;
end

always_comb begin
	if (state_reg == STATE_INIT) begin
		idx_in_in <= 0;
		idx_out_in <= 0;
		resp_rdy <= 1;
		done <= 0;
		size <= SIZE;
	end
	else if (state_reg == STATE_GCD) begin
		if (req_rdy) begin
			req_msg[15:0]  <= A[idx_in];
			req_msg[31:16] <= B[idx_in];
			req_val <= 1;
			idx_in_in <= idx_in + 1;
		end
		
		if (resp_val) begin
			out[idx_out] <= resp_msg;
			idx_out_in <= idx_out + 1;
		end
	end
	else if (state_reg == STATE_DONE) begin
		done <= 1;
	end

end

assign req_rdy = (state_reg == STATE_INIT)

endmodule
