// Open-drain I2C byte engine. One owner, ACK/NACK, restart and bounded stretch.
module konaet_i2c_byte #(parameter DIVIDER=30)(
 input wire clk,input wire rst,input wire go,input wire read_mode,
 input wire start_condition,input wire stop_condition,input wire read_nack,
 input wire [7:0] write_data,
 inout wire scl,inout wire sda,
 output reg done=0,output reg failed=0,output reg [7:0] read_data=0,
 output wire busy
);
 localparam IDLE=0,START0=1,START1=2,BIT0=3,BIT1=4,BIT2=5,BIT3=6,
            ACK0=7,ACK1=8,ACK2=9,ACK3=10,STOP0=11,STOP1=12,STOP2=13;
 reg [3:0] state=IDLE; reg scl_low=0,sda_low=0;
 reg [15:0] divider=0,stretch=0; reg [2:0] bit_index=7;
 reg read_latch=0,stop_latch=0,nack_latch=0; reg [7:0] tx=0;
 assign scl=scl_low?1'b0:1'bz; assign sda=sda_low?1'b0:1'bz;
 assign busy=(state!=IDLE);
 wire tick=(divider==DIVIDER-1);
 always @(posedge clk) begin
  done<=0;
  if(rst) begin state<=IDLE; scl_low<=0; sda_low<=0; divider<=0; failed<=0; stretch<=0; end
  else if(state==IDLE) begin
   divider<=0; stretch<=0;
   if(go) begin
    read_latch<=read_mode; stop_latch<=stop_condition; nack_latch<=read_nack;
    tx<=write_data; read_data<=0; bit_index<=7; failed<=0;
    state<=start_condition?START0:BIT0;
   end
  end else if(!scl_low && scl!==1'b1) begin
   // Wait for an external device holding SCL low; abort after 65535 clocks.
   if(stretch==16'hffff) begin failed<=1; done<=1; state<=IDLE; scl_low<=0; sda_low<=0; end
   else stretch<=stretch+1;
  end else if(tick) begin
   divider<=0; stretch<=0;
   case(state)
    START0: begin scl_low<=0; sda_low<=0; state<=START1; end
    START1: begin sda_low<=1; state<=BIT0; end
    BIT0: begin scl_low<=1; sda_low<=read_latch?0:!tx[bit_index]; state<=BIT1; end
    BIT1: begin scl_low<=0; state<=BIT2; end
    BIT2: begin if(read_latch) read_data[bit_index]<=sda; state<=BIT3; end
    BIT3: begin
     scl_low<=1;
     if(bit_index==0) state<=ACK0;
     else begin bit_index<=bit_index-1; state<=BIT0; end
    end
    ACK0: begin sda_low<=read_latch?!nack_latch:0; state<=ACK1; end
    ACK1: begin scl_low<=0; state<=ACK2; end
    ACK2: begin if(!read_latch && sda!==1'b0) failed<=1; state<=ACK3; end
    ACK3: begin
     scl_low<=1;
     if(stop_latch) begin sda_low<=1; state<=STOP0; end
     else begin sda_low<=0; done<=1; state<=IDLE; end
    end
    STOP0: begin scl_low<=0; state<=STOP1; end
    STOP1: begin sda_low<=0; state<=STOP2; end
    STOP2: begin done<=1; state<=IDLE; end
    default: begin failed<=1; done<=1; state<=IDLE; scl_low<=0; sda_low<=0; end
   endcase
  end else divider<=divider+1;
 end
endmodule
