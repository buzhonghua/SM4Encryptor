VCS=vcs -full64 -cc gcc-4.9 -cpp g++-4.9 -sverilog -CC -DVCSMX +v2k -notice -CFLAGS "-std=c++11"
INCLUDE= +incdir+./uvm_lib/src
CFILE=./uvm_lib/src/dpi/uvm_dpi.cc ./uvm_testing/uvm_wrapper.cpp
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
	uvm_testing/sm4_encryptor_wrapper.sv \
	uvm_testing/sm4_crypt_transaction.sv \
	uvm_testing/sm4_driver.sv \
	uvm_testing/sm4_monitor.sv \
	uvm_testing/sm4_encryptor_if.sv \
	uvm_testing/sm4_env.sv \
	uvm_testing/sm4_test_top.sv \
	$(CFILE)
	


clean:
	rm -rf csrc simv*
	rm -rf ucli.key
	rm -rf vc_hdrs.h