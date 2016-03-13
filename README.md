# ANM

It deals with four assignments.

1. Develop a tool similar to MRTG using perl, PHP, HTML, MySql, SNMP, RRD. The tool visualizes the performance by showing bit rate graphically. Backend part of the tool is executed using crontab.

2. Develop a tool which correlates the performance of network devices and servers visually. The tool visualizes the correlation by showing bit rate graphically. Tool is developed using perl, PHP, HTML, MySql, RRD, SNMP. The tool has features to select multiple metrics at a time. Bit rate , Aggregated bit rate of specific interfaces probed, over all bit rate of all interfaces are displayed. Server metrics are the CPU load, number of requests, transferred bytes and number of bytes per request are displayed.

3. SNMP trap listener is developed. Traps received are stored as they come. Tool displays the current status of all the devices reported. When a certain device is in Fail/Danger state, a message is send to the manager of managers saying the respective status of the device reported. Tool is developed using perl, PHP, HTML, MySql, SNMP.

4. Tool is developed to fetch the System Up time of devices added to the tool. It displays the current sysup time, number of requests send, number of requests lost, updated time. The tool varies the colour of the device based on the number of lost requests. Tool is developed using perl, PHP, HTML, MySql, SNMP.
