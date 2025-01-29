# background

The cpu inside this device is an MediaTek Kompanio 500 (MT8183). This is an ARM processor with 4 Cortex A73 cores and 4 Cortex A53 cores. While we have nice tools on x86_64 for setting governers and other power management tweaks such as tuned or ppd, there doesn't seem to be a popular such solution for the ARM cpus.

This script attempts to manually set governors for the processors on this chipset. Interestingly, the A73 and A53 cores seem to support running different governors simultaneously. Thus you can do something like run A53s using ondemand, and A73s on performance.

To set frequencies, use the flag -g [ARGUMENT]. Supported arguments are as follows:

- 73p: Set all A73 cores to Performance

- 73o: Set all A73 cores to Ondemand

- 53p: Set all A53 cores to Performance

- 53o: Set all A53 cores to Ondemand

- performance: Set all cores (A73 + A53) to Performance

- ondemand: Set all cores (A73 + A53) to Ondemand


To monitor frequencies, use the flag -m. To see the help message, use flag -h.
