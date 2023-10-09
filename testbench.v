`timescale 1ns/10ps
// Cash Register TestBench
module TestBench();
	parameter W = 4;
	reg Clock;
	reg C;												// Clear Total
	reg A;												// Add next X
	reg T;												// Display Total
	reg [W-1:0] X;
	wire [W-1:0] Total;
	//wire [W-1:0] AREG, SREG, TREG;
	//wire [2:0] Q;

	reg [15:0] Cycle;							// Cycle counter

	//CashReg #(.W(W)) CR(.Clock(Clock), .C(C), .T(T), .A(A), .X(X), .Total(Total), .Q(Q), .AREG(AREG), .SREG(SREG), .TREG(TREG));
	CashReg #(.W(W)) CR(.Clock(Clock), .C(C), .T(T), .A(A), .X(X), .Total(Total));
	
// Define Clock
	always #0.5 Clock = ~Clock;  //a delay of #1 results in a full clock cycle

	initial
	begin
// Cycle 0: Initialize circuit
		Cycle = 0;
		Clock = 0;
		C = 0; A = 0; T = 0;
		#0.5; Cycle = 1;
// Cycle 1: Init
		A = 1;	
	
// Cycle 2: LoadX
		#1; Cycle = Cycle + 1;
		X = 'd1;
// Cycle 3: AddX
		#1; Cycle = Cycle + 1;
// Cycle 4: MoreX
		#1; Cycle = Cycle + 1;
////
// Cycle 5: LoadX
		#1; Cycle = Cycle + 1;
		X = 'd2;
// Cycle 6: AddX
		#1; Cycle = Cycle + 1;
// Cycle 7: MoreX
		#1; Cycle = Cycle + 1;
////
// Cycle 8: LoadX
		#1; Cycle = Cycle + 1;
		X = 'd3;
// Cycle 9: AddX
		#1; Cycle = Cycle + 1;
// Cycle 10: MoreX
		#1; Cycle = Cycle + 1;
//	

	A= 0; T = 1;
// Cycle 11: LoadT
		#1; Cycle = Cycle + 1;
// Cycle 12: DisplayT
		#1; Cycle = Cycle + 1;
		C = 0; T = 0;
// Cycle 13: DisplayT
		#1; Cycle = Cycle + 1;
		C = 1;
// Cycle 14: Clear
		#1; Cycle = Cycle + 1;

	end
endmodule


module FullAdder(a, b, cin, s, cout);
	input a, b, cin;
	output s, cout;
	assign s = a ^ b ^ cin;
	assign cout = a & b | cin & (a ^ b);
endmodule

// W-bit Ripple-Carry Adder
// ModelSim allows the use of "generate".
// This module defines a parameterized W-bit RCA adder
module AddW
	#(parameter W = 16)			// Default width
	(A, B, c0, S, ovf);
	input [W-1:0] A, B;			// W-bit unsigned inputs
	input c0;						// Carry-in
	output [W-1:0] S;				// W-bit unsigned output
	output ovf;						// Overflow signal

	wire [W:0] c;					// Carry signals
	assign c[0] = c0;

// Instantiate and "chain" W full adders 
	genvar i;
	generate
		for (i = 0; i < W; i = i + 1) begin: add
		
			FullAdder FA(A[i], B[i], c[i], S[i], c[i+1]);
			end
	endgenerate

// Overflow
		assign ovf = c[W];
endmodule

