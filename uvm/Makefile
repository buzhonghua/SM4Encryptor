VCS=vcs -full64 -cc gcc-4.9 -cpp g++-4.9 -sverilog -CC -DVCSMX +v2k -notice -CFLAGS "-std=c++11"
INCLUDE= +incdir+./uvm_lib/src
UVM_TESTING=uvm_testing
CFILE=./uvm_lib/src/dpi/uvm_dpi.cc ./$(UVM_TESTING)/uvm_wrapper.cpp
COVERAGE= -cm cond+line+fsm



run: simv
	./simv $(COVERAGE)
	urg -dir simv.vdb

simv:
	$(VCS) $(COVERAGE) \
	$(INCLUDE) \
	../include/sm4_encryptor_pkg.svh  \
	./uvm_lib/src/uvm_pkg.sv \
	../rtl/sbox.sv \
	../rtl/xor_tree.sv \
	../rtl/key_cache.sv \
	../rtl/roll_shifter.sv \
	../rtl/lru_recorder.sv \
	../rtl/sm4_encryptor.sv \
	../rtl/turn_transform.sv \
	../rtl/priority_encoder.sv \
	$(UVM_TESTING)/sm4_encryptor_wrapper.sv \
	$(UVM_TESTING)/sm4_crypt_transaction.sv \
	$(UVM_TESTING)/sm4_check_transaction.sv \
	$(UVM_TESTING)/sm4_driver.sv \
	$(UVM_TESTING)/sm4_monitor.sv \
	$(UVM_TESTING)/sm4_encryptor_if.sv \
	$(UVM_TESTING)/sm4_reference.sv \
	$(UVM_TESTING)/sm4_scoreboard.sv \
	$(UVM_TESTING)/sm4_sequencer.sv \
	$(UVM_TESTING)/sm4_env.sv \
	$(UVM_TESTING)/sm4_test.sv \
	$(UVM_TESTING)/testcase.sv \
	$(UVM_TESTING)/sm4_test_top.sv \
	$(CFILE)
	


clean:
	rm -rf csrc simv*
	rm -rf ucli.key
	rm -rf vc_hdrs.h