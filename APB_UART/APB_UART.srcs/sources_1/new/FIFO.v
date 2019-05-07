`timescale 1ns / 1ps
module FIFO #(parameter depth = 32)(
    input clk,
    input rst,
    input [7:0] in,
    input in_next,
    output [7:0] out,
    input out_next,
    output empty,
    output full
    );
    
    reg [$clog2(depth+1)-1:0]count;
    reg [7:0] mem [depth-1:0];
    
    assign empty = (count == 0);
    assign full = (count == depth);
    assign out = mem[0];
    
    integer ii;
    always @(posedge clk) begin
        if(rst)
           count <= 0;
        else begin            
            if(in_next && !out_next) begin //write
                count <= count + 1;
                mem[count] <= in;
            end
            
            if(!in_next && out_next) begin //read
                count <= count - 1;
                for(ii = 0; ii < (depth-1); ii = ii + 1 )
                    mem[ii] <= mem[ii+1];
            end
            
            if(in_next && out_next) begin //write and read
                mem[count] = in;                
                for(ii = 0; ii < (depth-1); ii = ii + 1 )
                    mem[ii] <= mem[ii+1];
            end
        end
    end
    
endmodule
