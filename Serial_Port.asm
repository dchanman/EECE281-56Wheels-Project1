$NOLIST
;----------------------------------------------------
;	Serial Port Interface
; 
;	Nina Dacanay and Glyn Han
;
;	Function:  1.)Takes and Reads the temperature from 
;				 the K-Type thermocouple connected to 
;				 the MCP3004 ADC Converter.
;				  
;			   2.)Displays the temperature to a Python
;				 Strip Chart through the Serial Port.
;	
;	Inputs:    1.)Temperature
;	Outputs:   2.)Temperature Strip Chart
;
;	Variables: 1.)Accumulator      
;----------------------------------------------------
CSEG

Serial_Port_Init:
	ret	
	
$LIST
