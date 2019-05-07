`timescale 1ns / 1ps

module sim_FIFO(

    );
    
    wire empty, full;
    wire [7:0] D_out;
    reg clk, rst, in_next, out_next;
    reg [7:0] D_in;
    
    FIFO #(.depth(4)) uut (
        .clk(clk),
        .rst(rst),
        .in(D_in),
        .in_next(in_next),
        .out(D_out),
        .out_next(out_next),
        .empty(empty),
        .full(full)
        );
    
    initial begin
        rst <= 1;
        clk <= 0;
        in_next <= 0;
        out_next <= 0;
        
        #10
        rst <= 0;
        
        #5
        D_in <= 8'd1;
        in_next <= 1'b1;
        
        #10
        D_in <= 8'd2;
        in_next <= 1'b1;
        
        #10
        D_in <= 8'd3;
        in_next <= 1'b1;        
        out_next <= 1'b1;
        
        #10
        D_in <= 8'd4;
        in_next <= 1'b1;        
        out_next <= 1'b0;
        
        #10
        D_in <= 8'd5;
        in_next <= 1'b1;
        
        #10
        in_next <= 0;
        
        #20
        out_next <= 1'b1;
    end
    
    
    always #5
        clk = ~clk;
endmodule
