
module register (
    input clk,  
    input read,                 // kích hoạt tín hiệu ghi
    input [3:0] addr_data_1,      // địa chỉ đọc thanh ghi 1 từ Cu
    input [3:0] addr_data_2,      // địa chỉ đọc thanh ghi 2 từ Cu
    input [3:0] addr_read,       // địa chỉ ghi du lieu
    input [7:0] data_mux,               // 2 nguoon : 1: RX  2: Alu      (1. data_alu 2. data_rx)
    output [7:0] data_1,          // dữ liệu data1 xuất ra Alu
    output [7:0] data_2,           // dữ liệu data2 xuất ra Alu
    output [7:0] result,            // dư liệu tính kết quả
    output [7:0] data_r4               // dư liệu check rx_done
);
    reg [7:0] ram [0:15];
    // logic ghi
    always @(posedge clk) begin
        if(read)begin
            ram[addr_read] <= data_mux;
        end
    end
    // logic doc
    assign data_1 = ram[addr_data_1];
    assign data_2 = ram[addr_data_2];
    assign result = ram[4'b0011];
    assign data_r4 = ram[4'b0100];
endmodule
