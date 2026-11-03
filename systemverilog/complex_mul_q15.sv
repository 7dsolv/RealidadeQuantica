module complex_mul_q15 (
    input  logic signed [15:0] a_re_q15,
    input  logic signed [15:0] a_im_q15,
    input  logic signed [15:0] b_re_q15,
    input  logic signed [15:0] b_im_q15,
    output logic signed [32:0] result_re_q30,
    output logic signed [32:0] result_im_q30
);
    logic signed [31:0] a_re_wide;
    logic signed [31:0] a_im_wide;
    logic signed [31:0] b_re_wide;
    logic signed [31:0] b_im_wide;
    logic signed [31:0] product_rr;
    logic signed [31:0] product_ii;
    logic signed [31:0] product_ri;
    logic signed [31:0] product_ir;

    always_comb begin
        a_re_wide = {{16{a_re_q15[15]}}, a_re_q15};
        a_im_wide = {{16{a_im_q15[15]}}, a_im_q15};
        b_re_wide = {{16{b_re_q15[15]}}, b_re_q15};
        b_im_wide = {{16{b_im_q15[15]}}, b_im_q15};

        product_rr = a_re_wide * b_re_wide;
        product_ii = a_im_wide * b_im_wide;
        product_ri = a_re_wide * b_im_wide;
        product_ir = a_im_wide * b_re_wide;

        result_re_q30 = {product_rr[31], product_rr}
            - {product_ii[31], product_ii};
        result_im_q30 = {product_ri[31], product_ri}
            + {product_ir[31], product_ir};
    end
endmodule
