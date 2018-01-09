
## ////////////////////////////////////////////////////////////////////////// ##
## /// CODAC VMs //////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

# CODAC_QEMU            ?= qemu-system-x86_64
# CODAC_QEMU_IMG_SIZE   ?= 40G
# CODAC_QEMU_IMG_FORMAT ?= qcow2

CODAC_VERSION   ?= 5
CODAC_NAME      ?= codac_v$(CODAC_VERSION)

DOWNLOADS = \
			codac_v4.iso \
			codac_v4.md5 \
			codac_v5.iso \
			codac_v5.md5 \
			codac_v6.iso \
			codac_v6.md5

codac_v4_iso_URL ?= http://static.iter.org/codac/cs-iso/Iter-CCS-v4.iso
codac_v4_md5_URL ?= http://static.iter.org/codac/cs-iso/Iter-CCS-v4.md5
codac_v5_iso_URL ?= http://static.iter.org/codac/cs-iso/Iter-CCS-v5.iso
codac_v5_md5_URL ?= http://static.iter.org/codac/cs-iso/Iter-CCS-v5.md5
codac_v6_iso_URL ?= http://static.iter.org/codac/cs-iso/Iter-CCS-v6.iso
codac_v6_md5_URL ?= http://static.iter.org/codac/cs-iso/Iter-CCS-v6.md5


$(CODAC_NAME).img:
	@ qemu-img create -f $(CODAC_QEMU_IMG_FORMAT) $@ $(CODAC_QEMU_IMG_SIZE)


install-iso: ##@codac boot iso to install codac
install-iso: $(CODAC_NAME).img $(CODAC_NAME).iso
	@ $(CODAC_QEMU) -m 4G -enable-kvm -cpu host -smp 4 \
			  -hda $(CODAC_NAME).img \
			  -cdrom $(CODAC_NAME).iso \
			  -boot d

boot: ##@codac boot into codac image
boot: $(CODAC_NAME).img
	@ $(CODAC_QEMU) -m 4G -enable-kvm -cpu host -smp 4 -hda $(CODAC_NAME).img


