
clear; close all;
pm = Keysight8163B();
CaliChNo=2;
RefChNo=1;
pm.AutoCalibration(CaliChNo,RefChNo);