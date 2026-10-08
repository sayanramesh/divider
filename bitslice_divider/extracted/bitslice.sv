// structural model of bitslice extracted from bitslice.mag
// created by ext2svmod 13.1

module bitslice(
	output CarryOut ,
	output Databus ,
	output Result0 ,
	output Result1 ,
	output SDO ,
	input CarryIn ,
	input Clock ,
	input EnableALU ,
	input EnableOp1 ,
	input EnableOp2 ,
	input [0:0] F ,
	input LoadACC ,
	input LoadR ,
	input LoadR0 ,
	input LoadR1 ,
	input LoadT ,
	input nReset ,
	input Operand1 ,
	input Operand2 ,
	input SDI ,
	input SelACC ,
	input SelR ,
	input SelR1 ,
	input Test 
	);

timeunit 1ns;
timeprecision 10ps;

wire ACC ;
wire R0 ;
wire R1 ;
wire Temp ;


// include netlist information from bitslice.vnet

`include "bitslice.vnet"

endmodule
