
module alu (
    input [7:0] data_1, 
    input [7:0] data_2, 
    output reg [7:0] data_alu
);
    always @(*) begin
        data_alu = data_1 + data_2;
    end
endmodule
