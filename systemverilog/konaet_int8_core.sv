`include "konaet_model_params.vh"
// KONAET Sense: serial dense 32-24-2, signed INT8 and INT32 MAC.
module konaet_int8_core #(
    parameter WEIGHT_FILE="artifacts/integrated/rtl/weights.mem",
    parameter BIAS_FILE="artifacts/integrated/rtl/bias.mem",
    parameter [31:0] REQUANT_MULT=`KONAET_REQUANT_MULTIPLIER
)(
    input wire clk, input wire rst,
    input wire sample_valid, input wire signed [7:0] sample,
    output wire sample_ready, output wire busy,
    output reg result_valid, output reg anomaly, output reg invalid_result,
    output reg signed [31:0] logit0, output reg signed [31:0] logit1,
    output reg [15:0] cycle_count
);
    localparam COLLECT=0, LOAD1=1, READ1=2, MAC1=3, QUANTIZE=4,
               LOAD2=5, READ2=6, MAC2=7;
    reg [3:0] state=COLLECT;
    reg signed [7:0] weights[0:815];
    reg signed [31:0] biases[0:25];
    reg signed [7:0] samples[0:31];
    reg signed [7:0] hidden[0:23];
    reg signed [7:0] weight_reg;
    reg [9:0] weight_address;
    reg [4:0] received=0, index=0, neuron=0;
    reg output_neuron=0, invalid_frame=0;
    reg signed [31:0] accumulator=0;
    reg [15:0] ticks=0;
    wire signed [7:0] operand=(state==MAC2)?hidden[index]:samples[index];
    wire signed [15:0] product=weight_reg*operand;
    wire signed [31:0] mac_next=accumulator+{{16{product[15]}},product};
    wire [31:0] positive=accumulator[31]?32'd0:accumulator;
    wire [63:0] scaled=positive*REQUANT_MULT+64'd536870912;
    wire [33:0] shifted=scaled[63:30];
    assign sample_ready=(state==COLLECT);
    assign busy=(state!=COLLECT);
    initial begin
        $readmemh(WEIGHT_FILE,weights); $readmemh(BIAS_FILE,biases);
    end
    // Registered ROM port allows mapping to FPGA block RAM.
    always @(posedge clk) weight_reg<=weights[weight_address];
    always @(posedge clk) begin
        result_valid<=0;
        if(rst) begin
            state<=COLLECT; received<=0; invalid_frame<=0; invalid_result<=0;
            ticks<=0; cycle_count<=0; logit0<=0; logit1<=0; anomaly<=0;
            accumulator<=0; index<=0; neuron<=0; output_neuron<=0; weight_address<=0;
        end else begin
            if(busy) ticks<=ticks+1;
            case(state)
                COLLECT: if(sample_valid) begin
                    samples[received]<=sample;
                    if(received==0) invalid_frame<=(sample==-128);
                    else invalid_frame<=invalid_frame || (sample==-128);
                    if(received==31) begin
                        state<=LOAD1; received<=0; index<=0; neuron<=0;
                        accumulator<=biases[0]; ticks<=0;
                    end else received<=received+1;
                end
                LOAD1: begin weight_address<={neuron,5'b0}+index; state<=READ1; end
                READ1: state<=MAC1;
                MAC1: begin
                    accumulator<=mac_next;
                    if(index==31) state<=QUANTIZE;
                    else begin index<=index+1; state<=LOAD1; end
                end
                QUANTIZE: begin
                    hidden[neuron]<=(shifted>127)?8'd127:shifted[7:0];
                    index<=0;
                    if(neuron==23) begin
                        state<=LOAD2; output_neuron<=0; accumulator<=biases[24];
                    end else begin
                        neuron<=neuron+1; accumulator<=biases[neuron+1]; state<=LOAD1;
                    end
                end
                LOAD2: begin weight_address<=768+(output_neuron?24:0)+index; state<=READ2; end
                READ2: state<=MAC2;
                MAC2: begin
                    accumulator<=mac_next;
                    if(index==23) begin
                        if(!output_neuron) begin
                            logit0<=mac_next; output_neuron<=1; index<=0;
                            accumulator<=biases[25]; state<=LOAD2;
                        end else begin
                            logit1<=mac_next; anomaly<=($signed(mac_next)>$signed(logit0));
                            invalid_result<=invalid_frame; result_valid<=1;
                            cycle_count<=ticks+1; state<=COLLECT;
                        end
                    end else begin index<=index+1; state<=LOAD2; end
                end
                default: begin state<=COLLECT; received<=0; invalid_frame<=1; end
            endcase
        end
    end
endmodule
