sm4_encryptor:
	verilator --cc -sv -Wno-fatal --coverage \
	../include/sm4_encryptor_pkg.svh \
	../rtl/xor_tree.sv \
	../rtl/key_cache.sv \
	../rtl/sbox.sv \
	../rtl/roll_shifter.sv \
	../rtl/lru_recorder.sv \
	../rtl/sm4_encryptor.sv \
	../rtl/turn_transform.sv \
	../rtl/random_mask.sv \
	../rtl/priority_encoder.sv \
	--exe sm4_encryptor.cpp \
	--top-module sm4_encryptor 

	make -C obj_dir -f Vsm4_encryptor.mk


sbox_backup:
	verilator --cc -sv -Wno-fatal \
	../rtl/sbox_backup.sv \
	--exe sm4_box_backup.cpp \
	--top-module sbox_backup

	make -C obj_dir -f Vsbox_backup.mk

sbox:
	verilator --cc -sv -Wno-fatal \
	../rtl/sbox.sv \
	--exe sm4_box.cpp \
	--top-module sbox

	make -C obj_dir -f Vsbox.mk

key_cache:
	verilator --cc -sv -Wno-fatal \
	../include/sm4_encryptor_pkg.svh \
	../rtl/priority_encoder.sv \
	../rtl/lru_recorder.sv \
	../rtl/key_cache.sv \
	--exe key_cache.cpp \
	--top-module key_cache 

	make -C obj_dir -f Vkey_cache.mk

turn_transform:
	verilator --cc -sv --Wno-fatal \
	../include/sm4_encryptor_pkg.svh \
	../rtl/xor_tree.sv \
	../rtl/roll_shifter.sv \
	../rtl/sbox.sv \
	../rtl/turn_transform.sv \
	--exe turn_transform.cpp \
	--top-module turn_transform

	make -C obj_dir -f Vturn_transform.mk 


clean:
	rm -rf obj_dir