`timescale 1ns / 1ps

module sim_APB_UART(

    );
    reg clk, rst;
    
    wire line;
    reg [31:0] PADDR, PWDATA;
    wire [31:0] PRDATA;
    reg PSEL, PENABLE, PWRITE;
    //wire PREADY;
    //wire [3:0] PSTRB;
    APB_UART uut(
    .Tx(line),
    .Rx(line),
    .PCLK(clk),
    .PRESETn(!rst),
    .PADDR(PADDR),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PWDATA(PWDATA),
    .PSTRB(4'b1111/*PSTRB*/),
    .PREADY(/*PREADY*/),
    .PRDATA(PRDATA)
    );
    
    
    initial begin
        rst <= 1;
        clk <= 0;
        
        PSEL <= 1'b0;
        PENABLE <= 1'b0;
        
        #11
        rst <= 0;
        
        //config
        #5
        PADDR <= 32'd0;
        PWRITE <= 1'b1;
        PSEL <= 1'b1;
        PWDATA <= {8'b0, {5'b0, 3'b101}, 16'd4}; //enable, 8N1, N=4
        #10
        PENABLE <= 1'b1;
        #10
        PSEL <= 1'b0;
        PENABLE <= 1'b0;
        
        //send
        #10
        PADDR <= 32'd12;
        PWRITE <= 1'b1;
        PSEL <= 1'b1;
        PWDATA <= {24'd0, 8'd123}; //send: 123
        #10
        PENABLE <= 1'b1;
        #10
        PSEL <= 1'b0;
        PENABLE <= 1'b0;
        
        //receive
        #7000
        PADDR <= 32'd8;
        PWRITE <= 1'b0;
        PSEL <= 1'b1;
        #10
        PENABLE <= 1'b1;
        #10
        PSEL <= 1'b0;
        PENABLE <= 1'b0;
        
    end
    
    
    
    
    
    always #5
        clk = ~clk;
endmodule
