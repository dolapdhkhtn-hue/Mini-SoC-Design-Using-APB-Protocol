
module cu (
    input clk,
    input reset_n,
    input [2:0] pc_out,
    input [15:0] instruction,

    input [7:0] data_r4,  // tin hieu R4 de so sanh RX_Done
    input [7:0] result,     // ket qua alu trong thanh ghi R3

    // tin hieu dieu khien register
    output reg read,                    // cho phep register ghi du lieu
    output reg [3:0] addr_read,     // dia chi ghi du lieu o register
    output reg [3:0] addr_data_1,           //dia chi lay du lieu 1 o registerfile
    output reg [3:0] addr_data_2,           //dia chi lay du lieu 2 o registerfile
    output reg data_source,                 // nguon chon data vao resgiter

   // tin hieu dieu khien ip uart
    output reg [7:0] p_addr,    // dia chi thanh ghi dich  16 thanh ghi
    output reg p_write,        // write = 1: Ip ghi du lieu, write = 0 doc du lieu thanh ghi
    output reg p_enable,        // tin hieu cho phep Ip thuc hien
    output reg p_sel_uart,          // chon ip uart
    output reg [7:0] p_data,        // du lieu de ghi vao thanh ghi trong ip

    //pc 
    output reg pc_enable,
    output reg [2:0] pc_next

);
    wire [3:0] op = instruction [15:12];   // 4 bit dau ma lenh
    wire [3:0] r_target = instruction [11:8]; // 4 bit dia chi thanh ghi dich resgister
    wire [7:0] r_data_ip = instruction [7:0];  // dia chi thanh ghi ip

    localparam READ = 4'b0001;
    localparam JUMP = 4'b0010;
    localparam ADD = 4'b0011;
    localparam STORE = 4'b0111;

    parameter FETCH = 2'd0;     // trang thai nhan tin hieu, add, store
    parameter SETUP = 2'd1;     // memmore acces
    parameter ACCESS = 2'd2;
    reg [1:0] state, next_state;
    // chuyen trang thai
    always @(*)begin
        next_state = state;
        case(state)
            FETCH:begin
                if(op == READ || op == STORE)begin
                    next_state = SETUP;
                end
            end
            SETUP:begin
                next_state = ACCESS;
            end
            ACCESS:begin
                next_state = FETCH;
            end
            default: next_state = FETCH;
        endcase
    end

    // khoi tuan tu
    always @(posedge clk or negedge reset_n)begin
        if(!reset_n)begin
            state <= FETCH;
        end
        else begin
            state <= next_state;
        end
    end

    always @(*)begin
        // Ip uart
        p_addr = 8'd0;
        p_write = 0;
        p_enable = 0;
        p_sel_uart = 0;
        p_data = 8'd0;
 
        // register
        read = 0;
        addr_read = 4'd0;
        addr_data_1 = 4'd0;
        addr_data_2 = 4'd0;
        data_source = 0;
        //
        pc_enable = 0;
            
        case(state)
            FETCH:begin
                
                if(op == JUMP)begin
                    if(data_r4 == 8'd1)begin
                        pc_next = pc_out + 1;
                        pc_enable = 1;
                    end
                    else begin
                        pc_next = pc_out - 1;
                        pc_enable = 1;
                    end
                    
                end
                else if(op == ADD)begin
                    read = 1;
                    addr_read = r_target;
                    addr_data_1 = instruction[7:4];
                    addr_data_2 = instruction[3:0];
                    pc_next = pc_out + 1;
                    pc_enable = 1;
                    data_source = 0;
                end
            end
            SETUP:begin
                if(op == READ)begin
                    p_sel_uart = 1;
                    p_write = 0;
                    p_addr = r_data_ip;
                    p_enable = 0;
                    

                end
                else if(op == STORE)begin
                    p_write = 1;
                    p_sel_uart = 1;
                    p_addr = r_data_ip;
                    p_enable = 0;
                    p_data = result;
                    
                end

            end
            ACCESS:begin
                if(op == READ)begin
                    p_sel_uart = 1;
                    p_write = 0;
                    p_addr = r_data_ip;
                    p_enable = 1;

                    addr_read = r_target;
                    read = 1;
                    pc_next = pc_out + 1;
                    pc_enable = 1;
                    data_source = 1;
                end
                else if(op == STORE)begin
                    p_write = 1;
                    p_sel_uart = 1;
                    p_addr = r_data_ip;
                    p_enable = 1;
                    p_data = result;
                    pc_next = pc_out + 1;
                    pc_enable = 1;
                end
            end
        endcase
    end
   
endmodule
