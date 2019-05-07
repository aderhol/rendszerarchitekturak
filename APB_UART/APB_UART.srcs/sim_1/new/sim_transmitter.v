`timescale 1ns / 1ps

module sim_transmitter(

    );
    
    wire empty, full, Tx;
    reg clk, rst, next;
    reg [7:0] D;
    
    transmitter uut (
        .clk(clk),
        .rst(rst),
        .N(16'd2),
        .eight_bit(0),
        .two_stop(0),
        .empty(empty),
        .full(full),
        .data(D),
        .next(next),
        .Tx(Tx)
        );
    
    initial begin
        rst <= 1;
        clk <= 0;
        next <= 0;
        
        #10
        rst <= 0;
        
        #5
        D <= 8'b00110101;
        next <= 1'b1;
        
        #10
        D <= 8'b00110101;
        next <= 1'b1;
        
        #10
        next <= 1'b0;
    end
    
    
    always #5
        clk = ~clk;
endmodule
