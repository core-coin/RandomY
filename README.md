# RandomY

RandomY is a proof-of-decentralized-efficiency (PoDE) algorithm that is optimized for IoT CPUs. RandomY uses random code execution (hence the name) together with several memory-hard techniques to minimize the efficiency advantage of specialized hardware.

## Overview

RandomX utilizes a virtual machine that executes programs in a special instruction set that consists of integer math, floating point math and branches. These programs can be translated into the CPU's native machine code on the fly. At the end, the outputs of the executed programs are consolidated into a 256-bit result using a cryptographic hashing function ([Blake2b](https://blake2.net/)).

RandomY can operate in two main modes with different memory requirements:

* **Fast mode** - requires 2080 MiB of shared memory.
* **Light mode** - requires only 256 MiB of shared memory, but runs significantly slower

Both modes are interchangeable as they give the same results. The fast mode is suitable for "mining", while the light mode is expected to be used only for proof verification.

## Build

RandomY is written in C++11 and builds a static library with a C API provided by header file [randomx.h](src/randomx.h). Minimal API usage example is provided in [api-example1.c](src/tests/api-example1.c). The reference code includes a `randomx-benchmark` and `randomx-tests` executables for testing.

### Linux

Build dependencies: `cmake` (minimum 2.8.7) and `gcc` (minimum version 4.8, but version 7+ is recommended).

To build optimized binaries for your machine, run:
```
git clone https://github.com/core-coin/RandomY.git
cd RandomY
mkdir build && cd build
cmake -DARCH=native ..
make
```

To build portable binaries, omit the `ARCH` option when executing cmake.

### Windows

On Windows, it is possible to build using MinGW (same procedure as on Linux) or using Visual Studio (solution file is provided).

### Precompiled binaries

Precompiled binaries are available on the [Releases page](https://github.com/core-coin/RandomY/releases).

## Proof of work

RandomY was primarily designed as a PDE algorithm for [Core](https://coreblockchain.cc/). The recommended usage is following:

* The key `K` is selected to be the hash of a block in the blockchain - this block is called the 'key block'. For optimal mining and verification performance, the key should change every 2048 blocks (~2.8 days) and there should be a delay of 64 blocks (~2 hours) between the key block and the change of the key `K`. This can be achieved by changing the key when `blockHeight % 2048 == 64` and selecting key block such that `keyBlockHeight % 2048 == 0`.
* The input `H` is the standard hashing blob with a selected nonce value.

RandomY was successfully activated on the Core network.

**Note**: To achieve ASIC resistance, the key `K` must change and must not be miner-selectable. We recommend to use blockchain data as the key in a similar way to the Core example above. If blockchain data cannot be used for some reason, use a predefined sequence of keys.

### CPU performance
The table below lists the performance of selected CPUs using the optimal number of threads (T) and large pages (if possible), in hashes per second (H/s). The hashrate is measured using [CoreMiner](https://github.com/catchthatrabbit/coreminer).

|CPU|RAM|OS|RandomY hashrate|Efficiency|Power consumption|
|---|---|--|----------------|----------|-----------------|
|AMD Ryzen 7 3700X|16GB DDR4-3600|Ubuntu 20.04 LTS|10000 H/s|38×|300W|
|Raspberry Pi 4|8GB LPDDR4-3200 SDRAM|Ubuntu 20.04 LTS|260 H/s|1×|5.5W|

Note that RandomY currently includes a JIT compiler for x86-64 and ARM64. Other architectures have to use the portable interpreter, which is much slower.

# FAQ

### Which CPU is best for mining RandomY?

Most Intel and AMD CPUs made since 2011 should be fairly efficient at RandomY. The RandomY is primarily focused on small IoT devices. More specifically, efficient mining requires:

* 64-bit architecture
* IEEE 754 compliant floating point unit
* Hardware AES support ([AES-NI](https://en.wikipedia.org/wiki/AES_instruction_set) extension for x86, Cryptography extensions for ARMv8)
* 16 KiB of L1 cache, 256 KiB of L2 cache and 2 MiB of L3 cache per mining thread
* Support for large memory pages
* At least 2.5 GiB of free RAM per NUMA node
* Multiple memory channels may be required:
    * DDR3 memory is limited to about 1500-2000 H/s per channel (depending on frequency and timings)
    * DDR4 memory is limited to about 4000-6000 H/s per channel  (depending on frequency and timings)

### Does RandomY facilitate botnets/malware mining or web mining?

Due to the way the algorithm works, mining malware is much easier to detect.

### Since RandomY uses floating point math, does it give reproducible results on different platforms?

RandomY uses only operations that are guaranteed to give correctly rounded results by the [IEEE 754](https://en.wikipedia.org/wiki/IEEE_754) standard: addition, subtraction, multiplication, division and square root. Special care is taken to avoid corner cases such as NaN values or denormals.

The reference implementation has been validated on the following platforms:
* x86 (32-bit, little-endian)
* x86-64 (64-bit, little-endian)
* ARMv7+VFPv3 (32-bit, little-endian)
* ARMv8 (64-bit, little-endian)
* PPC64 (64-bit, big-endian)

### Can FPGAs mine RandomY?

RandomY generates multiple unique programs for every hash, so FPGAs cannot dynamically reconfigure their circuitry because typical FPGA takes tens of seconds to load a bitstream. It is also not possible to generate bitstreams for RandomY programs in advance due to the sheer number of combinations (there are 2<sup>512</sup> unique programs).

Sufficiently large FPGAs can mine RandomY in a [soft microprocessor](https://en.wikipedia.org/wiki/Soft_microprocessor) configuration by emulating a CPU. Under these circumstances, an FPGA will be much less efficient than a CPU or a specialized chip (ASIC).

## Acknowledgements
* [tevador](https://github.com/tevador) - author
* [SChernykh](https://github.com/SChernykh) - contributed significantly to the design of RandomX
* [hyc](https://github.com/hyc) - original idea of using random code execution for PoW
* [Other contributors](https://github.com/tevador/RandomX/graphs/contributors)
* [Core Foundation](https://github.com/core-coin) - redefine code for RandomY & PoDE

RandomY uses some source code from the following 3rd party repositories:
* Argon2d, Blake2b hashing functions: https://github.com/P-H-C/phc-winner-argon2
