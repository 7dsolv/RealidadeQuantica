`timescale 1ns/1ps
module konaet_ads1115_tb;
 reg clk=0;always #5 clk=~clk;
 reg rst=1,slave_low=0;tri1 scl,sda;
 assign sda=slave_low?1'b0:1'bz;
 wire valid,error;wire signed [15:0] code;
 integer samples=0,cycles=0,last_sample=0,errors=0;
 konaet_ads1115 #(.CLOCK_HZ(120000),.I2C_DIVIDER(1)) dut(.clk(clk),.rst(rst),
  .scl(scl),.sda(sda),.sample_valid(valid),.sample_code(code),.error(error));
 always @(posedge clk) begin
  cycles<=cycles+1;
  if(valid) begin
   if(code!==16'sd13200) $fatal(1,"ADS1115 word order or value is wrong: %0d",code);
   if(samples>0 && samples<3 && cycles-last_sample!=12000) $fatal(1,"ADC cadence is not 10 Hz scaled clock");
   last_sample<=cycles;samples<=samples+1;
  end
  if(error) errors<=errors+1;
 end
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
  normal_frame();normal_frame();normal_frame();
  start_wait();receive_byte(8'h90,0); // Device absent: NACK must invalidate result.
  wait(error);normal_frame();
  wait(samples==4);
  if(error || errors==0) $fatal(1,"ADC did not recover from NACK");
  $display("KONAET_ADS1115_PASS samples=%0d cadence_cycles=12000 nack_recovery=1",samples);$finish;
 end
 initial begin #2000000;$fatal(1,"ADS1115 test deadlock");end
endmodule
