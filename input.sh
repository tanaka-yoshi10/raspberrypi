echo 4 > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio4/direction 
echo "high" > /sys/class/gpio/gpio4/direction 

echo 17 > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio17/direction 
echo "1" > /sys/class/gpio/gpio17/value 
