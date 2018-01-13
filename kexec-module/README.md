# Steps to boot customized kernel

Follow this steps to boot a customized kernel into Valve's SteamLink. 
This will just replace the current running kernel with the customized one, therefore bypassing
any signature check done by the bootloader.
This method is not permanent, so rebooting brings you back to the stock kernel.

## Customize kernel and build

- Follow Valve's step to build the kernel
- Copy `arch/arm/boot/zImage` to `./images`

## Build the kexec module

```Bash
# export KERNEL=/path/to/kernel
# make
```
If everything works, this should give you kexec_load.ko

## Booting customized kernel

- First enable SSH access by following Valve's steps or use the internal serial port (see SteamLinkUART.jpeg for pinout)
- Login as root

### Preparation before booting customized kernel

In order to boot the new kernel we have to stop the watchdog timer and kill some Valve apps.
The easiest way I found to accomplish this was to avoid some startup scripts from running:
- To stop the watchdog startup script: 
	 ```Bash
	 # chmod -x /etc/init.d/startup/S80watchdog
	 ```
- To stop the apps: 
	```Bash
	# chmod -x /etc/init.d/startup/S99steam
	```
- Finally:
	```Bash
	# shutdown -r now
	```
That should prevent them from running on the next reboot.

### Finally running the customized kernel
- Use the script `load_kernel.sh` as an example. The script uses a NFS mount, so export MOUNT_DIR to point to the remote NFS export. If you want you can just copy all the needed files directly to SteamLink from an USB stick and then load all from there. You will need the following files: `tools/kexec`, `kexec-module/kexec_load.ko`, `images/berlin2cd-dongle.dtb`, `images/initrd.cpio` and `images/zImage`
- Run `load_kernel.sh` or run the commands manually (look what `load_kernel.sh` is doing)
- Should boot into the new kernel or crash, 50/50.
