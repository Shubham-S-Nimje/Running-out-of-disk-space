# Troubleshooting

## Wrong UUID in /etc/fstab

**What happened:** I added the fstab line for `/mnt/data` and ran `sudo umount /mnt/data` and `sudo mount -a`. Then `df -hT /mnt/data` showed `/dev/nvme0n1p1` with 8 GB. That is the root disk, not my 3 GB LVM volume.

**Why:** I had copied the UUID of the root disk (the one already in fstab for `/`) instead of the UUID of `datalv`.

**How I found it:** I did not reboot first. The `mount -a` test and `df -hT` showed the wrong device right away.

**Fix:** I ran `sudo blkid /dev/datavg/datalv` to get the right UUID, replaced it in the fstab line, then ran `mount -a` and `df -hT` again. This time it showed `/dev/mapper/datavg-datalv`.

**Lesson:** A wrong fstab line can stop a server from booting. Always test with `mount -a` before a reboot, and always check which device is mounted with `df -hT`. I also added `nofail` so the server still boots if a data disk fails to mount.

## Running commands on the wrong machine

After the reboot I ran `lsblk` in my local Git Bash by mistake and got "command not found". I had to SSH back in first. Small thing, but I now check the prompt before running anything.
