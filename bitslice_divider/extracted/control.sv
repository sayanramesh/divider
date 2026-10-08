// Auto-generated Header control.sv
//   created by vlog2net 9.0
//   on Sun Aug  9 22:27:21 BST 2026

module control(Done, F, CarryIn, LoadACC, LoadR0, LoadR1, LoadT, LoadR, SelACC, SelR1, SelR, EnableOp1, EnableOp2, EnableALU, Clock, nReset, Req, CarryOut, Test, SDI, SDO);
timeunit 1ns;
timeprecision 10ps;


  input Clock, nReset, Req, CarryOut;
  output Done, F, CarryIn, LoadACC, LoadR0, LoadR1, LoadT, LoadR, SelACC, SelR1, SelR, EnableOp1, EnableOp2, EnableALU;

  input Test;
  input SDI;
  output SDO;

  wire [3:0] state;

`include "control.vnet"

endmodule
