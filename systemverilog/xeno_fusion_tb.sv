`timescale 1ns/1ps
module xeno_fusion_tb;
    logic clk=0, reset=1, valid_in=0, valid_out;
    logic [11:0] chemical=0, tactile=0, command;
    integer checks=0;
    integer a,b,expected,held,previous;
    xeno_fusion dut(.*);
    always #5 clk=~clk;
    task automatic sample(input integer ca,ta,en,rst);
        @(negedge clk);
        chemical=ca; tactile=ta; valid_in=(en!=0); reset=(rst!=0);
        held=command;
        @(posedge clk); #1;
        if (rst!=0) begin
            if (command!==0 || valid_out!==0) $fatal(1,"reset");
        end else if (en==0) begin
            if (command!==held || valid_out!==0) $fatal(1,"hold/valid");
        end else begin
            expected=(3*ca+ta+2)/4;
            if (command!==expected || valid_out!==1) $fatal(1,"arithmetic/latency");
            if (command < (ca<ta ? ca:ta) || command > (ca>ta ? ca:ta)) $fatal(1,"convex bounds");
        end
        checks=checks+1;
    endtask
    initial begin
        sample(4095,4095,1,1);
        sample(0,0,0,0);
        for (a=0;a<4096;a=a+1) begin
            sample(a,a,1,0);
            if (command!==a) $fatal(1,"idempotent blend");
        end
        for (b=0;b<=4095;b=b+315) begin
            previous=0;
            for (a=0;a<4096;a=a+31) begin
                sample(a,b,1,0);
                if (command<previous) $fatal(1,"monotonicity");
                previous=command;
            end
        end
        sample(4095,0,1,0); sample(0,4095,1,0);
        sample(4095,4095,1,0); sample(0,0,0,0);
        sample(0,0,0,1);
        $display("XENO_FUSION_PASS checks=%0d",checks);
        $finish;
    end
endmodule
