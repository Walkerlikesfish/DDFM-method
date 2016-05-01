% Script for DDFM method tested on a thermeter scene
% Yu LIU, supervised by Prof. Ivan Markovsky
% 2015-2016 EIT Project
% Experiment 2-1

% content
% -read exsisted data
% -carry out the RLS step by step DDFM
% -Kalman Filter


clear
close all

% Using system identification toolbox provided
addpath(genpath('slra-slra-c3aa24c'),'data');

% Load exsisted data
load('dataseg_1.mat', 'data');

y = data';
n = 2; % system order => 1 : known
g = 1; opt = []; % G mat => 1 : known 

% Hand writing outlier to demostrate the effect
y(40)=43;

figure(1)
% implementation with iteration
% with pre-loaded data, fixed length T
f = 1; % [!] setting forgetting factor

finv = 1 / f;
T = size(y,1);
nc = n+1;
for i=1:T
    if i>=2
        dy(i-1)=y(i)-y(i-1);
        if i>n
            b(i-n)=y(i);
            A(i-n,:) = [g, dy(i-n:i-1)];
            if i==n*2+1
                Ai = A(1:nc, 1:nc);
                x(:,nc) = pinv(Ai) * (b(1:nc))';
                p = pinv(Ai' * Ai);
            elseif i>n*2+1
                ii = i-n;
                Ai = A(ii, :);
                k = finv * p * Ai' / (1 + finv * Ai * p * Ai');
                x(:, ii) = x(:, ii- 1) + k * (b(ii) - Ai * x(:, ii - 1));
                p  = 1 / f * (p - k * Ai * p);
                uh(i) = x(1,ii);
                er_(i) = abs(uh(i)-y(i));
                plot(i,y(i),'ro');
                hold on
                plot(i,uh(i),'bx');
                hold on
                %pause(0.1)
            end
        end
    end
end
legend('Naive','DDFM');
xlabel('time (sec)');
ylabel('Temperature (Degree)');
%title('Applying DDFM for temperature sensing')

set(gcf, 'PaperSize', [6.25 6]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 6.25 6]);

set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperSize', [6.25 6]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 6.25 6]);

set(gcf, 'renderer', 'painters');
print(gcf, '-dpdf', 'fig5_outlier.pdf');
%print(gcf, '-dpng', 'my-figure.png');
%print(gcf, '-depsc2', 'my-figure.eps');

