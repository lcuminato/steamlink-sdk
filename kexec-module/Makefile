EXTRA_CFLAGS += -mfpu=neon
EXTRA_CFLAGS += -D__KERNEL__ -DKERNEL -DCONFIG_KEXEC -Wall -w -DCONFIG_MMU -DCONFIG_ARM_ERRATA_754322

ARCH		= arm
CPPFLAGS	=  -I$kernel/

obj-m += kexec_load.o
kexec_load-objs := kexec.o atags_proc.o sys.o machine_kexec.o relocate_kernel.o ksysfs.o call_with_stack.o idmap.o proc-v7.o tlb-v7.o cache-v7.o debug.o

all:
	make -C $(KERNEL) M=$(PWD) modules

clean:
	make -C $(KERNEL) M=$(PWD) clean
