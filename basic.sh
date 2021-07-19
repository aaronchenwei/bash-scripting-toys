#!/usr/bin/env bash

### functions ###

command_exists() {
   command -v "$1" &>/dev/null
}

cpu_lscpu() {
    if ! command_exists lscpu;
    then
        echo "lscpu could not be found"
        return 1
    fi
    lscpu
}

cpu_cpuinfo() {
    echo "CPU threads: $(grep -c processor /proc/cpuinfo)"
    grep "model name" /proc/cpuinfo | uniq
}

cpu_query() {
    cpu_lscpu
    local ret=$?
    if [ $ret = 0 ]
    then
        return
    fi

    cpu_cpuinfo
}

mem_free() {
    free -kw
}

mem_meminfo() {
    egrep 'MemTotal|MemFree|MemAvailable|Buffers|Cached|SwapCached|SwapTotal|SwapFree|Dirty' /proc/meminfo
}

mem_query() {
    mem_free
    local ret=$?
    if [ $ret = 0 ]
    then
        return
    fi
    mem_meminfo
}

kernel_query() {
    sysctl -a 2>/dev/null | egrep 'vm.swappiness|vm.dirty_ratio|vm.dirty_background_ratio|vm.dirty_expire_centisecs|vm.min_free_kbytes'
}

numa_query() {
    if ! command_exists numactl;
    then
        echo "numactl could not be found"
        return 1
    fi
    numactl -H
    echo ""
    numactl -s
}

### main ###
echo `which bash`
echo `bash -version`

echo -e "\n\n\n"
cpu_query

echo -e "\n\n\n"
numa_query

echo -e "\n\n\n"
mem_query

echo -e "\n\n\n"
kernel_query

