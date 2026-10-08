// stimulus file datapath_stim.sv for datapath
// created by ext2svmod 13.1

module datapath_stim;

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
logic [7:0] Operand1 ;
logic [7:0] Operand2 ;
logic SDI ;
logic SelACC ;
logic SelR ;
logic SelR1 ;
logic Test ;

wire CarryOut ;
wire [7:0] Result0 ;
wire [7:0] Result1 ;
wire SDO ;

integer errors    = 0;
integer test_num  = 0;

datapath instance1(
	.CarryOut,
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
forever #500 Clock = ~Clock;
end

task automatic do_reset();
begin
    CarryIn = 0;
    Clock = 0;
    EnableALU = 0;
    EnableOp1 = 0;
    EnableOp2 = 0;
    F = 0;
    LoadACC = 0;
    LoadR = 0;
    LoadR0 = 0;
    LoadR1 = 0;
    LoadT = 0;
    
    Operand1 = 0;
    Operand2 = 0;
    SDI = 0;
    SelACC = 0;
    SelR = 0;
    SelR1 = 0;
    Test = 0;
	nReset = 0;
	#1000
	nReset = 1;
    #1000;
end
endtask

task automatic load_acc(input [7:0] value); begin
	//load accumulator
    Operand1 = value; EnableOp1 = 1; LoadACC = 1;//loadacc : value
	#1000 EnableOp1 = 0; LoadACC = 0;
    #1000;
end
endtask

task automatic load_r1(input [7:0] value); begin
	Operand2 = value; EnableOp2 = 1; LoadR1 = 1;//load r1 : value
	#1000 EnableOp2 = 0; LoadR1 = 0;
    #1000;
end
endtask

task automatic clear_r0(); begin
	SelACC = 0; SelR = 0; EnableALU = 1; LoadR0 = 1; CarryIn = 0; F = 0;// r0 = 0
	#1000 EnableALU = 0; LoadR0 = 0;
    #1000;
end
endtask

task automatic subtract(output no_borrow, input sub); begin

	SelACC = 1; SelR = 1; SelR1 = 1; EnableALU = 1; CarryIn = 1; F=1;// check if acc>=r1 if greater than  proceed subtraction
	if (sub)
		LoadACC = 1;
		#1000
		no_borrow = CarryOut;
        EnableALU=0;
        LoadACC=0;
		#1000;
	
end
endtask

task automatic increment_r0(); begin
	SelACC = 0; SelR = 1; SelR1 = 0; EnableALU = 1; F = 0; CarryIn = 1; LoadR0 = 1;//increment r0
	#1000 EnableALU = 0; LoadR0 = 0;	
	#1000;
end
endtask

task automatic stage_temp;
begin
    SelACC=1; SelR=0; F=0; CarryIn=0; EnableALU=1; LoadT=1;//to temp reg
    #1000 EnableALU=0; LoadT=0;
    #1000;
end
endtask

task automatic commit_results;
begin
    SelACC=0; SelR1=0; SelR=1; F=0; CarryIn=0; EnableALU=1; LoadR=1;//both results
    #1000 EnableALU=0; LoadR=0;
    #1000;
end
endtask


task automatic run_division( input [7:0]a, input [7:0]b,  input [7:0] exp_quotient, input [7:0] exp_remainder);
	begin
	logic no_borrow;
	integer loop_count;
    integer max_loops;

	test_num = test_num+1;
	max_loops = 300; // safety cutoff
    loop_count = 0;
	$display("Test %0d : %0d/%0d", test_num, a, b);
	do_reset;
	load_acc(a);
	load_r1(b);
	clear_r0;
	subtract(no_borrow, 1'b0);
	while (no_borrow ==1 && loop_count < max_loops) begin
		subtract(no_borrow, 1'b1);
		increment_r0;
		loop_count = loop_count + 1;
		subtract(no_borrow, 1'b0);
	end

	if (loop_count >= max_loops)
        $display("loop safety cutoff hit");
	stage_temp;
	commit_results;
    #1000;

    if (Result0 !== exp_quotient || Result1 !== exp_remainder) begin
        errors = errors + 1;
        $display("FAIL: got Result0(Q)=%0d Result1(R)=%0d | expected Q=%0d R=%0d ", Result0, Result1, exp_quotient, exp_remainder);
    end else begin
        $display("PASS: Result0(Q)=%0d Result1(R)=%0d ", Result0, Result1);
    end
end
endtask
initial begin
    #10;

    run_division(8'd10, 8'd3,  8'd3, 8'd1);
    run_division(8'd9,  8'd3,  8'd3, 8'd0);
    run_division(8'd7,  8'd7,  8'd1, 8'd0);
    run_division(8'd3,  8'd7,  8'd0, 8'd3);
    run_division(8'd0,  8'd5,  8'd0, 8'd0);
    run_division(8'd255,8'd1,  8'd255,8'd0);
    run_division(8'd200,8'd7,  8'd28,8'd4);
	if (errors == 0)
        $display("ALL %0d TESTS PASSED", test_num);
    else
        $display("%0d OF %0d TESTS FAILED", errors, test_num);
          $stop;
          $finish;
  end

// probe information follows

/*initial
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
    ,"%b", Result0 ,
    ,"%b", Result1 ,
    ,"%b", SDO ,
    );*/

//SIMVISION SCRIPT:datapath.tcl




endmodule
