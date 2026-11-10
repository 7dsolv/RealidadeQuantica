// Subbloco demonstrativo sintetizavel. Nao implementa a regressao MATLAB.
// Entradas unsigned de 12 bits, normalizadas para 0..4095.
module xeno_fusion (
    input logic clk, reset, valid_in,
    input logic [11:0] chemical, tactile,
    output logic valid_out,
    output logic [11:0] command
);
    logic [13:0] weighted;
    always_comb begin
        weighted = ({2'b0, chemical} << 1) + {2'b0, chemical}
                 + {2'b0, tactile} + 14'd2;
    end
    always_ff @(posedge clk) begin
        if (reset) begin
            command <= 12'd0;
            valid_out <= 1'b0;
        end else begin
            valid_out <= valid_in;
            if (valid_in) command <= weighted[13:2];
        end
    end
endmodule
