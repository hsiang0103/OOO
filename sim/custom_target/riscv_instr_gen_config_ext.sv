// 繼承原本的 config class
class riscv_instr_gen_config_ext extends riscv_instr_gen_config;

  `uvm_object_utils(riscv_instr_gen_config_ext)

  function new(string name = "");
    super.new(name);

    no_fence = 1;
    no_csr_instr = 1;

    mem_region = '{
        '{name:"region_0", size_in_bytes: 4096, xwr: 3'b111},
        '{name:"region_1", size_in_bytes: 4096, xwr: 3'b111}
    };

    stack_len           = 1024;
    kernel_stack_len    = 1024;

    void'($value$plusargs("stack_len=%d", stack_len));
  endfunction

endclass