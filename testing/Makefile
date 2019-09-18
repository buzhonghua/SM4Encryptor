turn_transform:
	verilator --cc -sv --Wno-fatal \
	../include/sm4_encryptor.svh \
	../rtl/xor_tree.sv \
	../rtl/roll_shifter.sv \
	../rtl/sbox.sv \
	../rtl/turn_transform.sv \
	--exe turn_transform.cpp \
	--top-module turn_transform

	make -C obj_dir -f Vturn_transform.mk 