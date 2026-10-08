// structural model of datapath extracted from datapath.mag
// created by ext2svmod 13.1

module datapath(
	output CarryOut ,
	output [7:0] Result0 ,
	output [7:0] Result1 ,
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
	input [7:0] Operand1 ,
	input [7:0] Operand2 ,
	input SDI ,
	input SelACC ,
	input SelR ,
	input SelR1 ,
	input Test 
	);

timeunit 1ns;
timeprecision 10ps;



// include netlist information from datapath.vnet

`include "datapath.vnet"

endmodule
