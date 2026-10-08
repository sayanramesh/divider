// stimulus file bitslice_stim.sv for bitslice
// created by ext2svmod 13.1

module bitslice_stim;

timeunit 1ns;
timeprecision 10ps;

logic CarryIn ;
logic Clock ;
logic EnableALU ;
logic EnableOp1 ;
logic EnableOp2 ;
logic [0:0] F ;
logic LoadACC ;
logic LoadR ;
logic LoadR0 ;
logic LoadR1 ;
logic LoadT ;
logic nReset ;
logic Operand1 ;
logic Operand2 ;
logic SDI ;
logic SelACC ;
logic SelR ;
logic SelR1 ;
logic Test ;

wire CarryOut ;
wire Databus ;
wire Result0 ;
wire Result1 ;
wire SDO ;

bitslice instance1(
	.CarryOut,
	.Databus,
	.Result0,
	.Result1,
	.SDO,
	.CarryIn,
	.Clock,
	.EnableALU,
	.EnableOp1,
	.EnableOp2,
	.F,
	.LoadACC,
	.LoadR,
	.LoadR0,
	.LoadR1,
	.LoadT,
	.nReset,
	.Operand1,
	.Operand2,
	.SDI,
	.SelACC,
	.SelR,
	.SelR1,
	.Test
	);

// stimulus information follows

initial begin
Clock = 0;
forever #500 Clock = ~ Clock;
end

initial
  begin
    CarryIn = 0;
    EnableALU = 0;
    EnableOp1 = 0;
    EnableOp2 = 0;
    F = 0;
    LoadACC = 0;
    LoadR = 0;
    LoadR0 = 0;
    LoadR1 = 0;
    LoadT = 0;
    nReset = 0;
    Operand1 = 0;
    Operand2 = 0;
    SDI = 0;
    SelACC = 0;
    SelR = 0;
    SelR1 = 0;
    Test = 0;
	#1000 nReset = 1;
	
//test1 loading vlue and reseting it
	#1000 Operand1 = 1; EnableOp1 = 1; LoadACC = 1;
	#1000  EnableOp1 = 0; LoadACC = 0;	
	#1000 Operand2 = 1; EnableOp2 = 1; LoadR1 = 1;
	#1000  EnableOp2 = 0; LoadR1 = 0;
	#1000 nReset = 0;
	#1000 nReset = 1;
//test2  checking alu 
	#1000 SelACC = 0; SelR = 0; F = 0; EnableALU = 1; LoadT = 1;// 0+0=0 recieving value from databus to temp
    #1000 EnableALU = 0; LoadT= 0;
	#1000 Operand1 = 1; EnableOp1 = 1; LoadACC = 1;//acc=1
	#1000  EnableOp1 = 0; LoadACC = 0;
	#1000 Operand2 = 0; EnableOp2 = 1; LoadR1 = 1;//R1=0
	#1000  EnableOp2 = 0; LoadR1 = 0;
	#1000  SelACC = 1; SelR = 1; SelR1=1; F = 0; EnableALU = 1; LoadT=1;//adding acc and R1
	#1000  EnableALU = 0; LoadT=0;
	#1000 Operand2 = 1; EnableOp2 = 1; LoadR1 = 1;//R1=1
	#1000  EnableOp2 = 0; LoadR1 = 0;
	#1000  SelACC = 1; SelR = 1;SelR1 = 1; F = 1; EnableALU = 1; LoadT=1; CarryIn = 1; //subtract acc and R1
	#1000  EnableALU = 0; LoadT=0;
	#1000 Operand1 = 0; EnableOp1 = 1; LoadACC = 1;//acc = 0
	#1000  EnableOp1 = 0; LoadACC = 0;
	#1000  SelACC = 1; SelR = 1; F = 1; SelR1 = 1; EnableALU = 1; LoadT=1;//subtract acc and R1 (0-1)
	#1000  EnableALU = 0; LoadT=0;
    #1000 SelACC = 0; SelR1 = 0; SelR = 1; F = 0; CarryIn = 1; EnableALU = 1; LoadR0 = 1;// R0 = R0 + 1 (increment)
    #1000 EnableALU = 0; LoadR0 = 0;
	#2000
          $stop;
          $finish;
  end

// probe information follows

initial
  $monitor($time,
    ,"%b", CarryIn ,
    ,"%b", Clock ,
    ,"%b", EnableALU ,
    ,"%b", EnableOp1 ,
    ,"%b", EnableOp2 ,
    ,"%b", F ,
    ,"%b", LoadACC ,
    ,"%b", LoadR ,
    ,"%b", LoadR0 ,
    ,"%b", LoadR1 ,
    ,"%b", LoadT ,
    ,"%b", nReset ,
    ,"%b", Operand1 ,
    ,"%b", Operand2 ,
    ,"%b", SDI ,
    ,"%b", SelACC ,
    ,"%b", SelR ,
    ,"%b", SelR1 ,
    ,"%b", Test ,
    ,"%b", CarryOut ,
    ,"%b", Databus ,
    ,"%b", Result0 ,
    ,"%b", Result1 ,
    ,"%b", SDO ,
    ,"%b", instance1.ACC ,
    ,"%b", instance1.R0 ,
    ,"%b", instance1.R1 ,
    ,"%b", instance1.Temp ,
    );


//SIMVISION SCRIPT:bitslice.tcl

endmodule
