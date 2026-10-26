module fifo #(parameter DATA_WIDTH = 8, parameter DEPTH = 16)(
input clk,
input rst_n,
input wr_en,
input rd_en,
input [DATA_WIDTH-1:0] wr_data,
output logic full,
output logic empty,
output logic [DATA_WIDTH-1:0] data_out
);

    logic [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];
    logic [$clog2(DEPTH):0] wr_ptr, rd_ptr;
    logic [$clog2(DEPTH):0] count; // NUmber of items in the FIFO, a write operation increments the count and a read operation decrements the count. When the count is equal to DEPTH, the FIFO is full, and when the count is 0, the FIFO is empty.
    logic write_ok, read_ok;

    assign write_ok = wr_en && !full;
    assign read_ok = rd_en && !empty;

    // Write operation
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
        end else if (write_ok) begin
            fifo_mem[wr_ptr] <= wr_data;
            wr_ptr <= (wr_ptr + 1) % DEPTH; // Wrap around the write pointer, for example, if DEPTH is 16, it will wrap around to 0 after reaching 15 because 15+1=16 and 16 % 16 = 0 while 15 % 16 = 15.
        end
    end

    // Read operation
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= 0;
            data_out <= 0;
        end else if (read_ok) begin
            data_out <= fifo_mem[rd_ptr];
            rd_ptr <= (rd_ptr + 1) % DEPTH; // Wrap around the read pointer, for example, if DEPTH is 16, it will wrap around to 0 after reaching 15 because 15+1=16 and 16 % 16 = 0 while 15 % 16 = 15.
        end
    end

    // Update occupancy based on accepted operations
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= '0;
        end else begin
            case ({write_ok, read_ok})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
                default: ; // Hold count when neither or both occur
            endcase
        end
    end

    // Full and empty flags
    assign full = (count == DEPTH);
    assign empty = (count == 0);
    
endmodule

    