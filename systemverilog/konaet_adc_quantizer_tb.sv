`timescale 1ns/1ps
module konaet_adc_quantizer_tb;
 reg clk=0;always #5 clk=~clk;
 reg rst=1,valid=0;reg signed [15:0] code=0;
 wire done,busy;wire signed [7:0] result;
 integer c,n,expected,checks=0,watchdog;
 konaet_adc_quantizer dut(.clk(clk),.rst(rst),.input_valid(valid),.code(code),
  .output_valid(done),.quantized(result),.busy(busy));
 initial begin
  repeat(3) @(negedge clk);rst=0;
  for(c=-32768;c<=32767;c=c+1) begin
   n=(c-13200)*127;
   expected=(n>=0)?(n+8000)/16000:-((-n+8000)/16000);
   if(expected>127 || expected< -127) expected=-128;
   @(negedge clk);code=c;valid=1;@(negedge clk);valid=0;watchdog=0;
   while(!done && watchdog<30) begin @(negedge clk);watchdog=watchdog+1;end
   if(!done || $signed(result)!==expected) $fatal(1,"ADC conversion mismatch code %0d: %0d != %0d",c,result,expected);
   checks=checks+1;
  end
  $display("KONAET_ADC_PASS cases=%0d",checks);$finish;
 end
endmodule
