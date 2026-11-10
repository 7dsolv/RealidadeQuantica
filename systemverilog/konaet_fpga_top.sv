module konaet_fpga_top(input wire clk,input wire reset_n,
 inout wire scl,inout wire sda,output wire normal_led_n,output wire anomaly_led_n);
 reg [3:0] startup=0; always @(posedge clk) if(!(&startup)) startup<=startup+1;
 wire rst=(!reset_n)||(!(&startup));
 wire valid,error; wire signed [15:0] code;
 konaet_ads1115 adc(.clk(clk),.rst(rst),.scl(scl),.sda(sda),.sample_valid(valid),.sample_code(code),.error(error));
 // Code is V/125uV. Mapping below is illustrative T=50+20*(V-1.65), not calibration.
 wire signed [23:0] delta=$signed(code)-24'sd13200;
 wire signed [31:0] numerator=delta*32'sd127;
 wire signed [31:0] rounded=(numerator>=0)?(numerator+8000)/16000:-((-numerator+8000)/16000);
 wire signed [7:0] quantized=(rounded>127 || rounded< -127)?-8'sd128:rounded[7:0];
 wire ready,busy,result_valid,anomaly,invalid; wire signed [31:0] l0,l1; wire [15:0] cycles;
 reg last_anomaly=0,last_invalid=1;
 konaet_int8_core network(.clk(clk),.rst(rst),.sample_valid(valid && ready),.sample(quantized),
  .sample_ready(ready),.busy(busy),.result_valid(result_valid),.anomaly(anomaly),
  .invalid_result(invalid),.logit0(l0),.logit1(l1),.cycle_count(cycles));
 always @(posedge clk) begin
  if(rst || error) last_invalid<=1;
  else if(result_valid) begin last_anomaly<=anomaly; last_invalid<=invalid; end
 end
 assign normal_led_n=!(~last_anomaly && ~last_invalid);
 assign anomaly_led_n=!(last_anomaly || last_invalid || error);
endmodule
