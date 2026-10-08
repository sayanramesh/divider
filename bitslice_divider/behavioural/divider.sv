
module divider(
    output logic [7:0] Quotient,
    output logic [7:0] Remainder,
    output logic Done,
    input  logic [7:0] Operand1,
    input  logic [7:0] Operand2,
    input  logic Req,
    input  logic Clock,
    input  logic nReset
    );

timeunit 1ns;
timeprecision 10ps;


logic F;
logic CarryIn;
logic LoadACC, LoadR0, LoadR1, LoadT, LoadR;
logic SelACC, SelR1, SelR;
logic EnableOp1, EnableOp2, EnableALU;
logic CarryOut;

control control_inst(
    .Done (Done),
    .F (F),
    .CarryIn (CarryIn),
    .LoadACC (LoadACC),
    .LoadR0 (LoadR0),
    .LoadR1 (LoadR1),
    .LoadT  (LoadT),
    .LoadR (LoadR),
    .SelACC (SelACC),
    .SelR1  (SelR1),
    .SelR  (SelR),
    .EnableOp1 (EnableOp1),
    .EnableOp2 (EnableOp2),
    .EnableALU (EnableALU),
    .Clock (Clock),
    .nReset (nReset),
    .Req (Req),
    .CarryOut (CarryOut)
	
`ifdef SCANPORTS
	,
	.Test (1'b0),
	.SDI (1'b0),
	.SDO ()
`endif
    );

datapath datapath_inst(
    .CarryOut (CarryOut),
    .Result0 (Quotient),
    .Result1 (Remainder),
    .SDO (),
    .CarryIn (CarryIn),
    .Clock (Clock),
    .EnableALU (EnableALU),
    .EnableOp1 (EnableOp1),
    .EnableOp2 (EnableOp2),
    .F (F),
    .LoadACC (LoadACC),
    .LoadR (LoadR),
    .LoadR0 (LoadR0),
    .LoadR1 (LoadR1),
    .LoadT (LoadT),
    .nReset (nReset),
    .Operand1 (Operand1),
    .Operand2 (Operand2),
    .SDI (1'b0),
    .SelACC (SelACC),
    .SelR (SelR),
    .SelR1 (SelR1),
    .Test (1'b0)
    );
endmodule
