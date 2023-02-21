
#!/bin/bash
#script to provide a simple "toggle-like" function by turning off a process if its on, or starting it if its off.
#hurr durr inefficient programming time

search="$1" #process to search for. By default, it takes in an argument by the user (ex: ./toggle.sh onboard). Change as needed
pid=$(pidof $search) #used for the if else logic below

#if else statement to determine whether to spawn process or destroy it
if [ ! -z "$pid" ];then
    kill "$pid"
else
    $search </dev/null &>/dev/null & #don't keep the program running in terminal
fi