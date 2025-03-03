function getwavetest()

IPaddress='172.25.1.1';
samplerate=80e9;
memory=3e5;
cl=[1, 2, 3, 4];
[deviceObj, interfaceObj, appObj]=LeCroyDSOcreate(IPaddress);
[T, Y1, Y2, Y3, Y4, DSO]=LeCroyDSOgetwaveform4ch(deviceObj, appObj, cl, samplerate, memory);
LeCroyDSOdisconnect(deviceObj, interfaceObj, appObj);
