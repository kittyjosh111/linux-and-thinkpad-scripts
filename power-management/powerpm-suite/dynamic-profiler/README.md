to temporarily disable and control dynamic-profiler, follow these steps:

1) Lock dynamic-profiler. Do this by creating a file ```/tmp/dynamic-profiler-lock```. The filename must match that exactly. You can use command ```touch /tmp/dynamic-profiler-lock```.

2) To control turbo boost manually, create either ```/tmp/dynamic-profiler-turbo-on``` to turn it on, or ```/tmp/dynamic-profiler-turbo-off```. You can use the touch command again.

3) To control power governor by calling whichever commands you've set in the config file, create a file ```/tmp/dynamic-profier-manual``` and write the word "performance", "balanced", or "power" in it. You can do this for example with ```echo "performance" | tee /tmp/dynamic-profiler/manual```

4) To disable manual control and return to automatic management, remove the lock file. So, ```rm /tmp/dynamic-profiler-lock```
