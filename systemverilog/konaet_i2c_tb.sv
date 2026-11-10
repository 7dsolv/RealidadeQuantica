`timescale 1ns/1ps
module konaet_i2c_tb;
 reg clk=0; always #5 clk=~clk;
 reg rst=1,go=0,reading=0,start=1,stop=1,nack=0;
 reg [7:0] tx=8'ha5; wire done,failed,busy; wire [7:0] rx;
 tri1 scl,sda; reg slave_low=0;
 assign sda=slave_low?1'b0:1'bz;
 integer cases=0;
 konaet_i2c_byte #(.DIVIDER(3)) dut(.clk(clk),.rst(rst),.go(go),.read_mode(reading),
  .start_condition(start),.stop_condition(stop),.read_nack(nack),.write_data(tx),
  .scl(scl),.sda(sda),.done(done),.failed(failed),.read_data(rx),.busy(busy));
 task issue;
  begin @(negedge clk);go=1;@(negedge clk);go=0; end
 endtask
 task wait_result;
  integer count;
  begin count=0; while(!done && count<5000) begin @(negedge clk);count=count+1;end
   if(!done) $fatal(1,"I2C engine timeout"); end
 endtask
 task receive_write(input [7:0] expected,input bit ack);
  integer j; reg [7:0] value;
  begin
   @(negedge sda); // START while SCL is high.
   if(scl!==1'b1) $fatal(1,"Invalid start");
   for(j=7;j>=0;j=j-1) begin @(posedge scl); value[j]=sda; end
   if(value!==expected) $fatal(1,"I2C byte mismatch %h != %h",value,expected);
   @(negedge scl); slave_low=ack;
   @(posedge scl); @(negedge scl); slave_low=0;
  end
 endtask
 task provide_read(input [7:0] value,input bit expected_nack);
  integer j;
  begin
   @(negedge sda);
   for(j=7;j>=0;j=j-1) begin
    @(negedge scl); slave_low=!value[j]; @(posedge scl);
   end
   @(negedge scl);slave_low=0;
   @(posedge scl);if(sda!==expected_nack) $fatal(1,"Master ACK/NACK wrong");
   @(negedge scl);
  end
 endtask
 initial begin
  repeat(3) @(negedge clk);rst=0;
  fork issue();receive_write(8'ha5,1);join
  wait_result();if(failed) $fatal(1,"ACK accepted as failure");cases=cases+1;
  fork issue();receive_write(8'ha5,0);join
  wait_result();if(!failed) $fatal(1,"NACK accepted as success");cases=cases+1;
  reading=1;nack=1;
  fork issue();provide_read(8'hd3,1);join
  wait_result();if(failed || rx!==8'hd3) $fatal(1,"I2C read failed");cases=cases+1;
  reading=1;nack=0;
  fork issue();provide_read(8'h3c,0);join
  wait_result();if(failed || rx!==8'h3c) $fatal(1,"I2C ACK read failed");cases=cases+1;
  $display("KONAET_I2C_PASS cases=%0d",cases);$finish;
 end
 initial begin #1000000;$fatal(1,"I2C test deadlock");end
endmodule
