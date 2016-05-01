% DDFM method implementation
% Yu LIU, supervised by Prof. Ivan Markovsky
% 2015-2016 EIT Project
% Research on how the noise influence the performance of the method

%% Content:
% - Generate the data with specific system
% - Add Gaussian Noise
% - Applying different method for prediction
% - Varying the noise variance
% - Monte-Carlo iteration for statstics

%% Generating data

clear
close all;

set(0,'defaultFigurePosition', [10 10 600 450]);
set(0,'defaultAxesFontSize', 12);
set(0, 'defaultTextFontSize', 12);
set(0, 'defaultAxesFontName', 'Palatino Linotype');
set(0, 'defaultTextFontName', 'Palatino Linotype');

addpath(genpath('slra-slra-c3aa24c'),'data');

a = 0.42; b=0.44; xini = -1; % state space 
ub = 2; % ubar is the constant input step function
T = 200; % DT time pts 
N = 100; % Monte-Carlo iteration number
sN = 20;
s = 0.1; % noise variance
Ts = 0.2; % sampling rate
sensor = @(a) c2d(ss(-a, b, 1, 0), Ts); sys = sensor(a); %build the system

coff.g = dcgain(sys); p = size(coff.g, 1); n = size(sys, 'order'); 
coff.n = 1;
coff.ff = 0.9;

% simulate the step response
y0 = lsim(sys, ones(T, 1) * ub, [], xini);
% define est_error function
est_error = @(uh) sum(abs(ub - uh), 2); opt = [];

%% quantization the data
quantization
for i=2:8
    e(i,:)=y0(:)-y(i,:)';
    figure(1)
    plot(y(i,:)); hold on;
    figure(2)
    plot(e(i,:)); hold on;
    uh_dd(:,i) = lsdd(y(i,:)', coff.g, coff.n, coff.ff);
    figure(3)
    plot(uh_dd(:,i)); hold on;
	e_dd(i,:) = est_error(uh_dd(:,i));
end
figure(1)
axis([10 50 0.4 2])
xlabel('time (sec)');
ylabel('y(t)');

set(gcf, 'PaperSize', [6.25 6]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 6.25 6]);

set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperSize', [6.25 6]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 6.25 6]);

set(gcf, 'renderer', 'painters');
print(gcf, '-dpdf', 'fig5_qt.pdf');


% plot Y-bits, X-time
figure(3)
contourf(e_dd)
axis([4 50 2 8]);
ylabel('Bits'); xlabel('time'); %title('Error');
colorbar

set(gcf, 'PaperSize', [6.25 6]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 6.25 6]);

set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperSize', [6.25 6]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 6.25 6]);

set(gcf, 'renderer', 'painters');
print(gcf, '-dpdf', 'fig3_q.pdf');

%% apply moving average to quantizated data, to smooth it
fw = [1/4 1/4 1/4 1/4];

for i=2:8
    yf(i,:) = avgf(y(i,:),4,fw);
    ef(i,:)=y0(:)-yf(i,:)';
    figure(4)
    plot(yf(i,:)); hold on;
    figure(5)
    plot(ef(i,:)); hold on;
    uh_ddf(:,i) = lsdd(yf(i,:)', coff.g, coff.n, coff.ff);
	e_ddf(i,:) = est_error(uh_ddf(:,i));
end

figure(6)
contourf(e_ddf)
axis([4 50 2 8])
xlabel('time (sec)');
ylabel('error');
colorbar

set(gcf, 'PaperSize', [6.25 6]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 6.25 6]);

set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperSize', [6.25 6]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 6.25 6]);

set(gcf, 'renderer', 'painters');
print(gcf, '-dpdf', 'fig4_filtered.pdf');

% for biti=2:10 % iterating the bits for fraction from 2bits to 10bits
%     %setting the quantization parameter, signed, 8bit, 4bit for fraction
%     ntBP = numerictype(1,2+biti,biti); % the total bits is 2+biti,2^2 is enough for integer
%     y(biti,:) = quantize(y_BP,ntBP);
% 	figure
%     plot(y(biti,:));
% end


% iterate sensor noise variance
% s=0; ds=0.05;
% 
% for sit=1:sN
% 
% for it=1:N
%     
% %% add noise
% yn = randn(size(y0)); sn = s / norm(yn) * norm(y0);  % Noraml distribution
% if length(sn) ~= p, sn = sn * ones(1, p), end
% y = y0 + yn * diag(sn);
% % show the generated data
% % figure(1)
% % plot(y0,'g'); hold on; plot(y,'bo'); hold on;
% 
% %% DDFM Method
% uh_dd(:,it) = stepid_dd(y, coff.g, coff.n, coff.ff);
% e_dd(it,:) = est_error(uh_dd(:,it));
% %plot(uh,'r');
% % figure(2)
% % plot(e_nv(4:end),'k')
% % hold on;
% % figure(3)
% % plot(uh,'k'); hold on;
% %% Kalman Filter
% uh_kf(:,it) = stepid_kf(y, sys, diag(sn .^ 2));
% e_kf(it,:) = est_error(uh_kf(:,it));
% % figure(2)
% % plot(e_nv(4:end),'g'); hold on;
% % figure(3)
% % plot(uh,'g'); hold on;
% %% Naive Method
% uh_nv(:,it) = stepid_nv(y, coff.g);
% e_nv(it,:) = est_error(uh_nv(:,it));
% % figure(2)
% % plot(e_nv,'b'); hold on;
% % axis([4 inf 0 1])
% % figure(3)
% % plot(uh,'b'); hold on;
% % axis([10 inf 0 3])
% 
% end
% uh_dd_ = mean(uh_dd,2);
% uh_kf_ = mean(uh_kf,2);
% uh_nv_ = mean(uh_nv,2);
% 
% e_nv_ = mean(e_nv);
% e_kf_ = mean(e_kf);
% e_dd_ = mean(e_dd);
% 
% e100_dd(sit)=e_dd_(100);
% e100_kf(sit)=e_kf_(100);
% e100_nv(sit)=e_nv_(100);
% 
% s=s+ds;
% end
% figure(1)
% plot(e100_dd,'k'); hold on;
% plot(e100_kf,'g'); hold on;
% plot(e100_nv,'b'); hold on;
% 
% 
% % uh_dd_ = mean(uh_dd,2);
% % uh_kf_ = mean(uh_kf,2);
% % uh_nv_ = mean(uh_nv,2);
% % figure(2)
% % plot(uh_dd_,'k'); hold on;
% % plot(uh_kf_,'g'); hold on;
% % plot(uh_nv_,'b'); hold on;
% % axis([10 inf 0 3])
% % 
% % e_nv_ = mean(e_nv);
% % e_kf_ = mean(e_kf);
% % e_dd_ = mean(e_dd);
% % figure(3)
% % plot(e_dd_,'k'); hold on;
% % plot(e_kf_,'g'); hold on;
% % plot(e_nv_,'b'); hold on;
% % axis([4 inf 0 1])
