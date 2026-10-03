# debug interface triage

1. is looking for silk screen: TX RX GND VCC TDI TDO TCK TMS  
2. voltage matches and then connects to  
3. first reads only the serial port log  
4. records U-Boot interrupt key and environment variables (not free saveenv)  
5. After image extraction SHA256  