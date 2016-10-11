#!/usr/local/bin/bash

log=/tmp/CheckBattery.log
debug=0
email=root
warnlevel=15
warnsleeps=300
critlevel=10
critsleeps=120
loop=300

player="/usr/local/bin/mpg123"
shutdown="/sbin/shutdown"

#while true
#do

# TODO
# hw.acpi.thermal.tz0._CRT: 105.0C
# hw.acpi.thermal.tz0._HOT: 100.0C
# hw.acpi.thermal.tz0._PSV: 90.0C

battery1=$( /sbin/sysctl -n hw.acpi.battery.life )
acpower1=$( /sbin/sysctl -n hw.acpi.acline )
time=$( /sbin/sysctl -n hw.acpi.battery.time )
temperature=$( /sbin/sysctl -n hw.acpi.thermal.tz0.temperature )
echo \[$(date)\] t:$temperature \|  bat:$battery1\% \| time:$time min \| ac:$acpower1 >> $log

if [ ${battery1} -le ${critlevel} ] && [ ${acpower1} = "0" ]
then
    /bin/sleep ${critsleeps}
    battery2=$( /sbin/sysctl -n hw.acpi.battery.life )
    acpower2=$( /sbin/sysctl -n hw.acpi.acline )
    if [ ${battery2} -lt ${battery1} ] && [ ${acpower2} = "0" ]
    then
	echo "Insert power plug or kill PID $$ to prevent automatic shutdown." | /usr/bin/mail -s "Battery ${battery2}% Will shutdown in ${critsleeps} s" ${email}
	$player /home/admin/messages/bat-level-shutdown.mp3
	/bin/sleep ${critsleeps}
	acpower3=$( /sbin/sysctl -n hw.acpi.acline )
	if [ ${acpower3} = "0" ]
	then /sbin/shutdown -p now
	fi
    fi
fi

if [ ${battery1} -le ${warnlevel} ] && [ ${acpower1} = "0" ]
then
    echo "Insert power plug or kill PID $$ to prevent this email" | /usr/bin/mail -s "Warning: Battery ${battery1}%" ${email}
    $player /home/admin/messages/bat-level-warning.mp3
    #	/bin/sleep ${warnsleeps}
fi

# /bin/sleep ${loop}
# done
