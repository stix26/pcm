FROM fedora:43@sha256:c177f6c7c6f10ad2838a7af67f1a4e9583dc7d5931d62f9994608cc091ac4003 AS builder
# Dockerfile for Intel PCM sensor server
# SPDX-License-Identifier: BSD-3-Clause
# Copyright (c) 2020-2024 Intel Corporation

RUN dnf -y install gcc-c++ git findutils make cmake openssl openssl-devel libasan libasan-static hwdata
COPY . /tmp/pcm
RUN cd /tmp/pcm && mkdir build && cd build && cmake -DPCM_NO_STATIC_LIBASAN=OFF .. && make -j

FROM fedora:43@sha256:c177f6c7c6f10ad2838a7af67f1a4e9583dc7d5931d62f9994608cc091ac4003
COPY --from=builder /tmp/pcm/build/bin/* /usr/local/bin/
COPY --from=builder /tmp/pcm/build/bin/opCode*.txt /usr/local/share/pcm/
COPY --from=builder /usr/share/hwdata/pci.ids /usr/share/hwdata/pci.ids
ENV PCM_NO_PERF=1

ENTRYPOINT [ "/usr/local/bin/pcm-sensor-server", "-p", "9738", "-r" ]
