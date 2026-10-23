#!/bin/bash
# Commands I ran in this project (run line by line, not as one script).
# Device names are from my server. Check yours with: lsblk -o NAME,SIZE,SERIAL

# Check disks
lsblk -o NAME,SIZE,SERIAL

# Create PV, VG, LV
sudo dnf install -y lvm2
sudo pvcreate /dev/nvme1n1
sudo vgcreate datavg /dev/nvme1n1
sudo lvcreate -L 3G -n datalv datavg
sudo pvs && sudo vgs && sudo lvs

# Filesystem and mount
sudo mkfs.xfs /dev/datavg/datalv
sudo mkdir /mnt/data
sudo mount /dev/datavg/datalv /mnt/data
df -hT /mnt/data

# Permanent mount
sudo blkid /dev/datavg/datalv
sudo cp /etc/fstab /etc/fstab.bak
sudo vi /etc/fstab
# add this line (use your own UUID):
# UUID=<uuid> /mnt/data xfs defaults,nofail 0 0
sudo umount /mnt/data
sudo mount -a
df -hT /mnt/data

# Fill the disk
sudo dd if=/dev/zero of=/mnt/data/big.file bs=1M count=2500
echo "important data - must survive extend and reboot" | sudo tee /mnt/data/important.txt
df -h /mnt/data

# Extend online
sudo pvcreate /dev/nvme2n1
sudo vgextend datavg /dev/nvme2n1
sudo lvextend -l +100%FREE -r /dev/datavg/datalv
sudo vgs && sudo lvs
df -h /mnt/data
cat /mnt/data/important.txt

# Reboot test
sudo reboot
# after login:
lsblk
df -h /mnt/data
cat /mnt/data/important.txt

# Clean up
sudo umount /mnt/data
sudo vi /etc/fstab        # delete the /mnt/data line
sudo mount -a
sudo lvremove /dev/datavg/datalv
sudo vgremove datavg
sudo pvremove /dev/nvme1n1 /dev/nvme2n1
# then detach and delete both EBS volumes in the console