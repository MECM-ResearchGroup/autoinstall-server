# Kubuntu autoinstall

A script to install and configure tftp and http servers for netbooting an Ubuntu Server autoinstall over PXE and IPv4 on UEFI firmware.
The server uses dnsmasq and lighttpd as the tftp and http implementations respectively.

There's also a postinstall script to further configure the system, and install software used by the MECM project, such as Abaqus, Anaconda and MATLAB.

Once the system boots, it parses the contents of `autoinstall.yaml` to install Kubuntu desktop natively on the target machine.

## Prerequisites
Download the tarball containing Abaqus and MATLAB required files from Google Drive. The file is named `postinstall.tar.zst`. If you do not wish to install any additional software along with the system, simply **comment out** the postinstall lines on `autoinstall.yaml`.

## Installation
**Some commands require root access, so always verify the scripts before running them.**

Download or clone the repo and run `./bootstrap.sh`. Set executing permission with `chmod +x bootstrap.sh`, if needed.
It's also possible to change the IP of the server on `autoinstall.yaml` and `grub.cfg`, and the hostname of the target system.

Then, move the tarball to /var/www/html:

`sudo mv postinstall.tar.zst /var/www/html/`

After that, instruct the target computer to netboot over IPv4 PXE. Every BIOS is different in this regard, but the process usually involves enabling PXE boot and listing it as an option on the boot menu. Then, reboot and choose PXE over IPv4 on the boot options menu.

Wait for the install to finish. The machine will reboot and hopefully start Kubuntu. If that doesn't happen, or the autoinstall process starts over, **shut down the machine** by pressing and holding the power button. Then turn it on and select the OS or disk entry instead of PXE on the boot menu.

After the boot finishes, **reboot again** to apply cloud-init specific configurations, and then open a terminal and give the postinstall script execution permission:

`sudo chmod +x /postinstall.sh`

Then, run the script:
`sudo /postinstall.sh`

Finally, `reboot` one last time.

## Testing
After running the setup script, execute `./test_autoinstall.yaml`. It should spin up a kvm and run the autoinstall. Keep in mind it still does not test the netboot functionality, but merely the install process itself. Ensure you have at least 60 Gb of storage available for the vm image.

## References
[https://ubuntu.com/server/docs/install/netboot-amd64](https://ubuntu.com/server/docs/install/netboot-amd64)

[https://ubuntu.com/server/docs/install/autoinstall-reference](https://ubuntu.com/server/docs/install/autoinstall-reference)

[https://github.com/canonical/autoinstall-desktop](https://github.com/canonical/autoinstall-desktop)
