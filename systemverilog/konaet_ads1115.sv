// ADS1115 AIN0 at 128 SPS single-shot, 10 Hz frame cadence. 3V3 external ADC.
module konaet_ads1115 #(parameter CLOCK_HZ=12000000,parameter I2C_DIVIDER=30)(
 input wire clk,input wire rst,inout wire scl,inout wire sda,
 output reg sample_valid=0,output reg signed [15:0] sample_code=0,
 output reg error=0
);
 localparam WAIT_SAMPLE=0,ISSUE=1,WAIT_BYTE=2,CONVERT=3;
 reg [2:0] state=WAIT_SAMPLE; reg [3:0] command=0;
 reg [31:0] counter=0,cadence=0; reg go=0; reg [7:0] high=0;
 wire read_mode=(command>=7); wire starts=(command==0 || command==4 || command==6);
 wire stops=(command==3 || command==8); wire nack=(command==8);
 wire [7:0] tx=(command==0 || command==4)?8'h90:
     (command==1)?8'h01:(command==2)?8'hc3:(command==3)?8'h83:
     (command==5)?8'h00:8'h91;
 wire done,failed,busy; wire [7:0] received;
 konaet_i2c_byte #(.DIVIDER(I2C_DIVIDER)) engine(.clk(clk),.rst(rst),.go(go),
  .read_mode(read_mode),.start_condition(starts),.stop_condition(stops),.read_nack(nack),
  .write_data(tx),.scl(scl),.sda(sda),.done(done),.failed(failed),.read_data(received),.busy(busy));
 always @(posedge clk) begin
  sample_valid<=0; go<=0;
  if(rst) begin state<=WAIT_SAMPLE; counter<=0; cadence<=0; command<=0; error<=0; end
  else begin
   if(cadence>=CLOCK_HZ/10-1) cadence<=0; else cadence<=cadence+1;
   case(state)
   WAIT_SAMPLE: if(cadence>=CLOCK_HZ/10-1) begin counter<=0; command<=0; state<=ISSUE; end
   ISSUE: if(!busy) begin go<=1; state<=WAIT_BYTE; end
   WAIT_BYTE: if(done) begin
    if(failed) begin error<=1; state<=WAIT_SAMPLE; counter<=0; end
    else if(command==3) begin counter<=0; command<=4; state<=CONVERT; end
    else if(command==8) begin sample_code<=$signed({high,received}); sample_valid<=1; error<=0; counter<=0; state<=WAIT_SAMPLE; end
    else begin
     if(command==7) high<=received;
     command<=command+1; state<=ISSUE;
    end
   end
   CONVERT: if(counter>=CLOCK_HZ/100-1) begin counter<=0; state<=ISSUE; end
            else counter<=counter+1;
   default: state<=WAIT_SAMPLE;
   endcase
  end
 end
endmodule
