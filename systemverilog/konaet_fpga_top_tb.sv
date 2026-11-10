`timescale 1ns/1ps
`include "konaet_model_params.vh"
module konaet_fpga_top_tb;
 reg clk=0;always #5 clk=~clk;
 reg rst=1,slave_low=0;tri1 scl,sda;
 assign sda=slave_low?1'b0:1'bz;
 wire normal_led_n,anomaly_led_n;
 integer samples=0;
 konaet_fpga_top #(.CLOCK_HZ(120000),.I2C_DIVIDER(1)) dut(.clk(clk),.reset_n(!rst),
  .scl(scl),.sda(sda),.normal_led_n(normal_led_n),.anomaly_led_n(anomaly_led_n));
 always @(posedge clk) begin
  if(dut.valid) samples<=samples+1;
  if(dut.quant_valid && dut.quantized!==8'sd0) $fatal(1,"ADC-to-INT8 mapping failed");
 end
 task verify_leds;
  begin
   wait(dut.result_valid);repeat(3) @(negedge clk);
   if(normal_led_n!==`KONAET_ZERO_ANOMALY || anomaly_led_n!==!`KONAET_ZERO_ANOMALY)
    $fatal(1,"Full acquisition-to-LED result differs from MATLAB");
  end
 endtask
 task start_wait;
  begin : search_start
   forever begin @(negedge sda);if(scl===1'b1) disable search_start;end
  end
 endtask
 task receive_byte(input [7:0] expected,input bit ack);
  integer j;reg [7:0] got;
  begin
   for(j=7;j>=0;j=j-1) begin @(posedge scl);got[j]=sda;end
   if(got!==expected) $fatal(1,"ADS1115 command %h != %h",got,expected);
   @(negedge scl);slave_low=ack;@(posedge scl);@(negedge scl);slave_low=0;
  end
 endtask
 task transmit_byte(input [7:0] value,input bit nack_expected);
  integer j;
  begin
   // Previous received ACK ended with SCL low; data are stable before first rise.
   slave_low=!value[7];
   for(j=7;j>=0;j=j-1) begin
    @(posedge scl);@(negedge scl);
    if(j>0) slave_low=!value[j-1];
   end
   slave_low=0;@(posedge scl);if(sda!==nack_expected) $fatal(1,"ADS1115 read ACK wrong");@(negedge scl);
  end
 endtask
 task normal_frame;
  begin
   start_wait();receive_byte(8'h90,1);receive_byte(8'h01,1);receive_byte(8'hc3,1);receive_byte(8'h83,1);
   start_wait();receive_byte(8'h90,1);receive_byte(8'h00,1);
   start_wait();receive_byte(8'h91,1);transmit_byte(8'h33,0);transmit_byte(8'h90,1);
  end
 endtask
 initial begin
  repeat(3) @(negedge clk);rst=0;
  repeat(32) normal_frame();verify_leds();
  start_wait();receive_byte(8'h90,0);
  wait(dut.error);repeat(3) @(negedge clk);
  if(normal_led_n!==1 || anomaly_led_n!==0) $fatal(1,"NACK must invalidate LEDs");
  repeat(32) normal_frame();verify_leds();
  if(samples!=64) $fatal(1,"Missing sensor samples: %0d",samples);
  $display("KONAET_TOP_PASS cases=3 samples=%0d normal=native-bus invalidation=NACK recovery=32-samples",samples);$finish;
 end
 initial begin #10000000;$fatal(1,"Full FPGA acquisition deadlock");end
endmodule