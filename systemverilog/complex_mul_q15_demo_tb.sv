module complex_mul_q15_demo_tb;
    logic signed [15:0] a_re_q15;
    logic signed [15:0] a_im_q15;
    logic signed [15:0] b_re_q15;
    logic signed [15:0] b_im_q15;
    logic signed [32:0] result_re_q30;
    logic signed [32:0] result_im_q30;

    complex_mul_q15 dut (
        .a_re_q15(a_re_q15),
        .a_im_q15(a_im_q15),
        .b_re_q15(b_re_q15),
        .b_im_q15(b_im_q15),
        .result_re_q30(result_re_q30),
        .result_im_q30(result_im_q30)
    );

    initial begin
        a_re_q15 = 16'sd16384;
        a_im_q15 = 16'sd8192;
        b_re_q15 = 16'sd16384;
        b_im_q15 = -16'sd8192;
        #1;
        if (result_re_q30 !== 33'sd335544320 || result_im_q30 !== 33'sd0) begin
            $fatal(1, "Unexpected Q30 product: real=%0d imag=%0d",
                result_re_q30, result_im_q30);
        end

        $display("PASS: complex Q1.15 product, raw signed Q30 outputs: real=%0d imag=%0d",
            result_re_q30, result_im_q30);
        $finish;
    end
endmodule
