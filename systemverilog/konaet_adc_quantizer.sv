// Exact q=round((ADC_code-13200)*127/16000), serial unsigned division.
// The voltage-to-temperature mapping is illustrative, not sensor calibration.
module konaet_adc_quantizer(input wire clk,input wire rst,input wire input_valid,
 input wire signed [15:0] code,output reg output_valid=0,
 output reg signed [7:0] quantized=0,output reg busy=0);
 wire signed [23:0] delta=$signed(code)-24'sd13200;
 wire signed [23:0] numerator=(delta<<<7)-delta;
 reg [23:0] dividend=0,quotient=0; reg [14:0] remainder=0;
 reg [4:0] index=0; reg negative=0;
 wire [15:0] trial={remainder,dividend[23]};
 wire subtract=(trial>=16000);
 wire [23:0] next_quotient={quotient[22:0],subtract};
 always @(posedge clk) begin
  output_valid<=0;
  if(rst) begin busy<=0;index<=0;quantized<=-128;end
  else if(input_valid && !busy) begin
   dividend<=((numerator<0)?-numerator:numerator)+24'd8000;
   negative<=(numerator<0);quotient<=0;remainder<=0;index<=23;busy<=1;
  end else if(busy) begin
   remainder<=subtract?(trial-16000):trial;
   quotient<=next_quotient;dividend<={dividend[22:0],1'b0};
   if(index==0) begin
    if(next_quotient>127) quantized<=-128;
    else quantized<=negative?-$signed(next_quotient[7:0]):$signed(next_quotient[7:0]);
    busy<=0;output_valid<=1;
   end else index<=index-1;
  end
 end
endmodule
