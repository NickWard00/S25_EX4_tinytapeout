`default_nettype none

module my_chip (
  input logic [11:0] io_in, // Inputs to your chip
  output logic [11:0] io_out, // Outputs from your chip
  input logic clock,
  input logic reset // Important: Reset is ACTIVE-HIGH
);
    
  // Basic counter design as an example
  // TODO: remove the counter design and use this module to insert your own design
  // DO NOT change the I/O header of this design

  assign data_in = io_in[11:2];
  assign go = data_in[0];
  assign finish = data_in[1];
  logic go, finish;
  logic [9:0] data_in;
  logic [9:0] data_max;
  logic [9:0] data_min;
  typedef enum logic [1:0] {waiting, starting, ending} state_t;
  state_t curr_state, next_state;

  always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
      curr_state <= waiting;
    end
    else begin
      curr_state <= next_state;
    end
  end
  
  always_comb begin
    case (curr_state)
      default: next_state = go ? starting : waiting;
      starting: next_state = finish ? ending : starting;
      ending: next_state = waiting;
    endcase
  end

  always_comb begin
    debug_error = 1'b1;
    if (go & finish) begin
      debug_error = 1'b1;
    end
    else begin
      case (curr_state)
        default: begin
          if (finish) begin
            debug_error = 1'b1;
          end
          else if (go) begin
            debug_error = 1'b0;
          end
        end
        starting: begin
          if (finish) begin
            debug_error = 1'b0;
          end
          else if (go) begin
            debug_error = 1'b0;
          end
        end
        ending: begin
          if (finish) begin
            debug_error = 1'b1;
          end
        end
      endcase
    end
  end

  assign data_max = (curr_state !== waiting) ? (data_in > data_max) ? data_in : data_max : {10{1'b0}};
  assign data_min = (curr_state !== waiting) ? (data_in < data_min) ? data_in : data_min : {10{1'b1}};
  assign range = finish ? data_max - data_min : {10{1'bz}};

  assign io_out = {2'b0, range};

endmodule
