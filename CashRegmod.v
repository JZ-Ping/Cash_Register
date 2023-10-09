module CashRegmod
#(parameter W = 8)	
(KEY, CLOCK_50, SW,HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7);
    input [W-1:0] SW;
    input [2:0] KEY;
    input CLOCK_50;
    wire [36:0] clk_out;
    wire TooLarge1, TooLarge;
    wire [W-1:0] total;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
    
    Clock_Div d(CLOCK_50, clk_out);
    
    CashReg b(clk_out[25], ~KEY[2], ~KEY[0], ~KEY[1], SW[W-1:0], total);

    Unsigned_to_7SEG a(SW[W-1:0], HEX4, HEX5, HEX6, HEX7, TooLarge);
    Unsigned_to_7SEG c(total, HEX0, HEX1, HEX2, HEX3, TooLarge1);
endmodule

// Cash Register
module CashReg
  #(parameter W = 8)									// Default bit width
  (Clock, C, A, T, X, Total);
	input Clock;
	input A;													// Add next X
	input T;													// Display Total
	input C;													// Clear Total
	input [W-1:0] X;										// Unsigned
	output [W-1:0] Total;
  
  
// Datapath Components
	reg [W-1:0] AREG;
	wire A_LD;

	reg [W-1:0] SREG;
	wire S_CLR, S_LD;

	reg [W-1:0] TREG;
	wire T_CLR, T_LD;
  
	wire ovf;
	wire [W-1:0] R;
	AddW #(.W(W)) Adder(SREG, AREG, 1'b0, R, ovf);


// Datapath Controller
	reg [2:0] Q, Q_Next;
	localparam Init          = 3'd0;
	localparam LoadX         = 3'd1;
	localparam AddX          = 3'd2;
	localparam MoreX         = 3'd3;
	localparam LoadTotal     = 3'd4;
	localparam DisplayTotal  = 3'd5;
	localparam Clear         = 3'd6;


 // Controller State Transitions
	always @*
	begin
		case (Q)
			Init:
        if (A)
					Q_Next <= LoadX;
				else
					Q_Next <= Init;

			LoadX: Q_Next <= AddX;

			AddX: Q_Next <= MoreX;

			MoreX:
        if (A)
					Q_Next <= LoadX;
				else if (T)
					Q_Next <= LoadTotal;
				else
					Q_Next <= MoreX;

			LoadTotal: Q_Next <= DisplayTotal;

			DisplayTotal:
        if (C)
					Q_Next <= Clear;
				else
					Q_Next <= DisplayTotal;

			Clear: Q_Next <= Init;
		endcase
	end
  
 // Initial State
  initial
	begin
		Q <= Init;
		AREG <= 'd0;
		SREG <= 'd0;
		TREG <= 'd0;
	end


// Controller State Update
	always @(posedge Clock)
		Q <= Q_Next;

// Controller Output Logic
	assign A_LD = (Q == LoadX);
	assign S_LD = (Q == AddX);
	assign T_LD = (Q == LoadTotal);
	assign S_CLR = (Q == Clear);
	assign T_CLR = (Q == Clear);

 
// Datapath State Update
  always @(posedge Clock)
	begin
		AREG <= A_LD ? X : 'd0;
		SREG <=
			S_CLR ? 'd0 :
				(S_LD ? R : SREG);
		TREG <=
			T_CLR ? 'd0 :
				(T_LD ? SREG : TREG);
	end

// Datapath Output Logic
	assign Total = TREG;

endmodule
