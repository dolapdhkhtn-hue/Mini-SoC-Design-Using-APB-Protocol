
module program_counter (
    input clk,
    input reset_n,
    input pc_enable,                
    input [2:0] pc_next,
    output wire [2:0] pc_out
);
    reg [2:0] pc;
    
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            pc <= 3'b000; // Reset về 0
        end
        else if (pc_enable) begin 
            pc <= pc_next;
        end
    end
    
    assign pc_out = pc;
endmodule
