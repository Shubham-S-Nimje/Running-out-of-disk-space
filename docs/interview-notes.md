# Interview notes

**1. What are PV, VG and LV?**
PV (physical volume) is a real disk that LVM can use. VG (volume group) is a pool made from one or more PVs. LV (logical volume) is a piece of that pool that I format and mount like a normal disk.

**2. Why use LVM instead of plain partitions?**
A plain partition has a fixed size and is hard to grow. With LVM I can add a new disk to the pool and make the volume bigger while it is still mounted. I can also take snapshots.

**3. What is the difference between lvextend and xfs_growfs?**
`lvextend` makes the logical volume bigger. `xfs_growfs` makes the XFS filesystem inside it bigger. Both are needed. The `-r` flag on `lvextend` runs the filesystem grow for me.

**4. Why use the UUID in fstab?**
Device names like `/dev/nvme1n1` can change after a reboot or when disks are attached in a different order. The UUID stays the same, so the right disk always gets mounted.

**5. Can you shrink XFS?**
No. XFS can only grow. To make it smaller I would have to back up the data, make a new smaller filesystem and restore. ext4 can be shrunk, but only when it is unmounted.

**6. What happens if the fstab line is wrong?**
The system can fail to boot or drop into emergency mode. That is why I test with `mount -a` before rebooting, and why I used `nofail` for a data disk. I made this mistake myself in this project, see troubleshooting.md.
