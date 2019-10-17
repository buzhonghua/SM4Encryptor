`include "uvm_macros.svh"

import uvm_pkg::*;
import sm4_encryptor_pkg::*;

class sm4_env extends uvm_env;
    `uvm_component_utils(sm4_env);

    sm4_driver driver;
    sm4_monitor monitor;
    sm4_reference reference;
    sm4_scoreboard scoreboard;
    sm4_sequencer sequencer;

    uvm_tlm_analysis_fifo #(sm4_crypt_transaction) dri_ref_fifo;
    
    uvm_tlm_analysis_fifo #(sm4_check_transaction) ref_scb_fifo;
    uvm_tlm_analysis_fifo #(sm4_check_transaction) mon_scb_fifo;
    
    function new(string name="sm4_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        driver = sm4_driver::type_id::create("driver", this);
        monitor = sm4_monitor::type_id::create("monitor", this);
        reference = sm4_reference::type_id::create("reference", this);
        scoreboard = sm4_scoreboard::type_id::create("scoreboard", this);
        sequencer = sm4_sequencer::type_id::create("sequencer", this);
        dri_ref_fifo = new("dri_ref_fifo", this);
        ref_scb_fifo = new("ref_scb_fifo", this);
        mon_scb_fifo = new("mon_scb_fifo", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // dri_ref_fifo(driver to reference)
        driver.ap.connect(dri_ref_fifo.analysis_export);
        reference.port.connect(dri_ref_fifo.blocking_get_export);
        // mon_scb_fifo(monitor to scoreboard)
        monitor.ap.connect(mon_scb_fifo.analysis_export);
        scoreboard.actual_port.connect(mon_scb_fifo.blocking_get_export);
        // ref_scb_fifo(reference to scoreboard)
        reference.ap.connect(ref_scb_fifo.analysis_export);
        scoreboard.expect_port.connect(ref_scb_fifo.blocking_get_export);
        // from sequencer to driver
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
endclass