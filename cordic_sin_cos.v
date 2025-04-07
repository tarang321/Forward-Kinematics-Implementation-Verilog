`timescale 1ns / 1ps
module cordic_sin_cos (
    input clk,
    input rst,
    input start,
    input signed [15:0] angle_in,   // Q1.15
    output reg signed [15:0] cos_out,
    output reg signed [15:0] sin_out,
    output reg done
);
    parameter ITER = 16;

    reg signed [15:0] x, y, z;
    reg signed [15:0] x_new, y_new, z_new;
    reg [4:0] i;
    reg running;

    function signed [15:0] atan_table;
        input [4:0] index;
        case(index)
            0: atan_table = 16'd25735;  // 45°
            1: atan_table = 16'd15192;  // 26.56°
            2: atan_table = 16'd8027;
            3: atan_table = 16'd4074;
            4: atan_table = 16'd2045;
            5: atan_table = 16'd1023;
            6: atan_table = 16'd512;
            7: atan_table = 16'd256;
            8: atan_table = 16'd128;
            9: atan_table = 16'd64;
            10: atan_table = 16'd32;
            11: atan_table = 16'd16;
            12: atan_table = 16'd8;
            13: atan_table = 16'd4;
            14: atan_table = 16'd2;
            15: atan_table = 16'd1;
            default: atan_table = 0;
        endcase
    endfunction

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            x <= 0; y <= 0; z <= 0;
            i <= 0;
            done <= 0;
            running <= 0;
        end else begin
            if (start && !running) begin
                x <= 16'd19898;  // cos(0) * K ? 0.60725 * 32768
                y <= 0;
                z <= angle_in;
                i <= 0;
                running <= 1;
                done <= 0;
            end else if (running) begin
                if (i < ITER) begin
                    if (z >= 0) begin
                        x_new = x - (y >>> i);
                        y_new = y + (x >>> i);
                        z_new = z - atan_table(i);
                    end else begin
                        x_new = x + (y >>> i);
                        y_new = y - (x >>> i);
                        z_new = z + atan_table(i);
                    end
                    x <= x_new;
                    y <= y_new;
                    z <= z_new;
                    i <= i + 1;
                end else begin
                    cos_out <= x;
                    sin_out <= y;
                    done <= 1;
                    running <= 0;
                end
            end else begin
                done <= 0;
            end
        end
    end

endmodule

