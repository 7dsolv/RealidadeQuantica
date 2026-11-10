`timescale 1ns/1ps
`include "konaet_model_params.vh"
module konaet_int8_tb;
    reg clk=0; always #5 clk=~clk;
    reg rst=1, sample_valid=0;
    reg signed [7:0] sample=0;
    wire ready,busy,result_valid,anomaly,invalid_result;
    wire signed [31:0] logit0,logit1;
    wire [15:0] cycle_count;
    reg signed [7:0] vectors[0:`KONAET_TEST_CASES*32-1];
    reg signed [31:0] expected[0:`KONAET_TEST_CASES*2-1];
    integer k,j,watchdog,checks=0,min_cycles=100000,max_cycles=0;
    konaet_int8_core dut(.clk(clk),.rst(rst),.sample_valid(sample_valid),.sample(sample),
        .sample_ready(ready),.busy(busy),.result_valid(result_valid),.anomaly(anomaly),
        .invalid_result(invalid_result),.logit0(logit0),.logit1(logit1),.cycle_count(cycle_count));
    initial begin
        $readmemh("artifacts/integrated/rtl/input.mem",vectors);
        $readmemh("artifacts/integrated/rtl/expected.mem",expected);
        repeat(3) @(negedge clk); rst=0;
        // Reset discards an incomplete frame.
        repeat(9) begin @(negedge clk); sample_valid=1; sample=15; end
        @(negedge clk); rst=1; sample_valid=0;
        @(negedge clk); rst=0;
        for(k=0;k<`KONAET_TEST_CASES;k=k+1) begin
            for(j=0;j<32;j=j+1) begin
                @(negedge clk);
                if(!ready) $fatal(1,"Input not ready in case %0d",k);
                sample_valid=1; sample=vectors[k*32+j];
            end
            @(negedge clk); sample_valid=0; watchdog=0;
            while(!result_valid && watchdog<3000) begin
                @(negedge clk); watchdog=watchdog+1;
                // Busy input must not overwrite the collected frame.
                if(watchdog<10) begin sample_valid=1; sample=-55; end
                else sample_valid=0;
            end
            if(!result_valid) $fatal(1,"Timeout case %0d",k);
            if(logit0!==expected[k*2] || logit1!==expected[k*2+1])
                $fatal(1,"Logit mismatch %0d: got %0d %0d expected %0d %0d",k,logit0,logit1,expected[k*2],expected[k*2+1]);
            if(anomaly!==($signed(expected[k*2+1])>$signed(expected[k*2])) || invalid_result)
                $fatal(1,"Decision mismatch case %0d",k);
            if(cycle_count<min_cycles) min_cycles=cycle_count;
            if(cycle_count>max_cycles) max_cycles=cycle_count;
            checks=checks+1;
        end
        // -128 is outside the symmetric input domain and must be flagged.
        for(j=0;j<32;j=j+1) begin @(negedge clk); sample_valid=1; sample=(j==10)?-128:0; end
        @(negedge clk); sample_valid=0; watchdog=0;
        while(!result_valid && watchdog<3000) begin @(negedge clk); watchdog=watchdog+1; end
        if(!result_valid || !invalid_result) $fatal(1,"Invalid input not flagged");
        checks=checks+1;
        $display("KONAET_RTL_PASS cases=%0d cycles_min=%0d cycles_max=%0d",checks,min_cycles,max_cycles);
        $finish;
    end
endmodule
