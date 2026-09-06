# WE create the golden image via packer of hasicorp
##

# Quick Start:
```
# 1. Build the image (generates QCOW2, VMDK, and RAW)
packer build .

# 2. Deploy to your platform
./publish/to-incus.sh

# 3. Verify
incus image list         
```