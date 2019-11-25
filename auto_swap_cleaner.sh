#!/usr/bin/bash

# Start this script with your system start-up applications it'll look for excess SWAP accumulated and move the swap to 
# RAM whenever possible it is supposed to speed up your system

parse_meminfo() {
    echo "$1" | grep "$2" | rev | cut -f2 -d ' ' | rev 
}

while true; do
    meminfo=$(cat /proc/meminfo)

    sleep_time=20 # 20 second interval before checking RAM usage next time
    ideal_free_mem_after_done_in_percent=10 # After SWAP has been emptied 10% of the RAM should be free
    
    swap_total=$(parse_meminfo "$meminfo" SwapTotal)
    swap_free=$(parse_meminfo "$meminfo" SwapFree)
    swap_used=$(echo "$swap_total - $swap_free" | bc -l)
    
    # Swap has to be greater by 50MB to start a cleaning operation
    if [[ $swap_used -le 50*1024 ]]; then
        echo "[+] $swap_used kB swap is too low, waiting for it to fill after 1 minute" 
        sleep $sleep_time
        continue
    fi
    
    echo "swap_total: " $swap_total
    echo "swap_free: " $swap_free
    echo "swap_used: " $swap_used

    mem_avail=$(parse_meminfo "$meminfo" MemAvailable)
    mem_total=$(parse_meminfo "$meminfo" MemTotal)
    mem_used=$(echo "$mem_total - $mem_avail" | bc -l)

    echo "mem_avail: " $mem_avail
    echo "mem_total: " $mem_total
    echo "mem_used: " $mem_used

    # It's not a great idea to fill RAM to 100% after cleaning operation as system will again swap some of the excess RAM
    safety_buffer=75*1024 # mB * 1024 = kB

    # This will be total RAM used when cleaning operation is finished SWAP + Mem already being used + buffer
    mem_used_and_swap_used=$(echo "$swap_used + $mem_used + $safety_buffer" | bc -l) 
    memfree_after_done=$(echo "$mem_total - $mem_used_and_swap_used" | bc -l)
    # This is the free memory after swap is emptied it should be greater than 10% to start cleaning
    mem_free_after_done_in_percent=$(echo "($memfree_after_done / $mem_total) * 100" | bc -l)
    

    echo "mem_used_and_swap_used: " $mem_used_and_swap_used
    echo "memfree_after_done: " $memfree_after_done
    echo "mem_free_after_done_in_percent: " $mem_free_after_done_in_percent

    
    if  [ $(echo "$mem_free_after_done_in_percent > $ideal_free_mem_after_done_in_percent" | bc) -ne 0 ]; then
        echo "Cleaning some swap now"
        # notify-send --icon "dialog-warning" "Auto Swap Cleaner Notification" "Stay still! Moving $(expr $swap_used / 1024) MB swap to memory" # Debug
        sudo swapoff -a -v && sudo swapon -a
        # notify-send --icon "dialog-information" "Auto Swap Cleaner Notification" "Swap emptied" # Debug
    else
        # notify-send --icon "dialog-error" "Auto Swap Cleaner Notification" "Not enough space in RAM" # Debug
        sleep $sleep_time # Hope space is available after some time
        continue
    fi
done
