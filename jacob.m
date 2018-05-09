clear;
close all;
clc;
chiller_eff=xlsread('Final-Exam-Efficiency-Maps.xlsx','Sheet1');
pump_eff=xlsread('Final-Exam-Efficiency-Maps.xlsx','Pump Map');

%% 2-D Curve_fit for visualization
flow = 100:10:1700;
head = 0.5:0.5:56;
[X,Y] = meshgrid(flow,head);
RPM_fit_object = polyfit([pump_eff(:,1),pump_eff(:,2)],pump_eff(:,3), 'poly55');
RPM_fit = RPM_fit_object(X,Y);

eff_fit_object = polyfit([pump_eff(:,1),pump_eff(:,2)],pump_eff(:,4), 'poly22');
eff_fit = eff_fit_object(X,Y);


figure(1)

contourf(X,Y,RPM_fit,20);
xlabel ('Flow (GPM)');
ylabel ('Head (Feet)');
colorbar();
[row,col] = find(abs(RPM_fit-1780)<1);
hold on
max_x = diag(X(row,col));
max_y = diag(Y(row,col));
plot(max_x,max_y, 'r', 'LineWidth', 3)


figure(2)
contourf(X,Y,eff_fit,30);
xlabel ('Flow (GPM)');
ylabel ('Head (Feet)');
hold on
colorbar();
plot(max_x,max_y, 'r', 'LineWidth', 3)