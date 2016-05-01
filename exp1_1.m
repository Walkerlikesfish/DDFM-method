% Script for DDFM method tested on a thermeter scene
% Yu LIU, supervised by Prof. Ivan Markovsky
% 2015-2016 EIT Project
% Experiment 1-2
% Read exsit sensor data and show the performance of different method

%% Initiate the workspace
clear
close all

% Using system identification toolbox provided
addpath('slra-slra-c3aa24c','data');

% Load exsisted data
load('dataseg_1.mat', 'data');

y = data';
n = 2; % system order => 1 : known
g = 1; opt = []; % G mat => 1 : known 

%% system identificaiton
[ub, sys, info, yh] = stepid_io(y, g, n, opt); % system identification
% the result is [ubar,sys(A,B,C,D),yh(best fit)]
sn = std(y - yh); % noise std (sensor value - fit model)
gp = dcgain(sys); sys.b = sys.b / gp; sys.d = sys.d / gp; 

figure(1), clf, hold on % plot the estimation errors
T = length(y); t = 1:T; plot(t, y, 'g'), plot(t, yh, '-.k')
legend('sensor data   .', 'best fit', 'location', 'SouthEast');
xlabel('time (pts)');
ylabel('temperature (centi-degree)');
title('Data Fitting System Identification')

est_error = @(uh) sum(abs(ub - uh), 2);% define error method


%% Naive Method
uh = stepid_nv(y, g);
e_nv = est_error(uh);
f2=figure(2);
plot(uh,'-.r'); hold on;
figure(3)
plot(e_nv); hold on;

%% Kalman Filter
uh = stepid_kf(y, sys, diag(sn .^ 2));
e_nv = est_error(uh);
figure(2)
plot(uh,'--b'); hold on;
figure(3)
plot(e_nv); hold on;

%% FFDM
uh = stepid_dd(y, g, n);
e_nv = est_error(uh);
figure(2)
plot(uh,'k'); hold on;
axis([0 inf 37 45])

legend('Naive Method.', 'Kalman Filter','DDFM', 'location', 'SouthEast');
xlabel('time (pts)');
ylabel('temperature estimate (centi-degree)');

figure(3)
plot(e_nv); hold on;
axis([0 inf 0 2])

legend('Naive Method.', 'Kalman Filter','DDFM', 'location', 'NorthEast');
xlabel('time (pts)');
ylabel('error(centi-degree)');

%% applying DDFM estimate the input step

cof.n = 3; % system order
cof.ff = 1; % forgetting coefficient 
cof.G = 1; % the reading is equal to the temperature

uh_dd = lsdd(data', cof.G, cof.n, cof.ff);
%uh_dd = stepid_dd(data', cof.G, cof.n, cof.ff);

%% show the result
figure
plot(data,'r');
hold on;
plot(uh_dd,'b');
xlabel('time (s)');
ylabel('Amplitutde (ºC)')