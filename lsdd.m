% DDFM method implementation
% Yu LIU, supervised by Prof. Ivan Markovsky
% 2015-2016 EIT Project
% function DDFM
% Read exsit sensor data and show the performance of different method
function ub = lsdd(y, g, n, cff)
% input:
%   -y: observations from output
%   -g: Gain
%   -n: order of system
%   -cf:coefficient forgetting factor
% output:
%   -ub: estimation of input u

    % Construct differential of y
    dy = diff(y);
    T = size(y,1);
    % construct Mat A, single input
    A = [ones(T-n, 1).*g, blkhank(dy, T-n)];
    % construct b
    b = y((n + 1):T, :);
    % recusive Least Square solution for Ax=b
    % Initialize the x and p
    [m, n] = size(A);  finv = 1 / cff;
    Ai = A(1:n, 1:n); x = zeros(n, m); 
    x(:, n) = pinv(Ai) * b(1:n); p = pinv(Ai' * Ai);
    % iteration after n_max + 1
    for i = (n + 1):m
        Ai = A(i, :);
        k  = finv * p * Ai' / (1 + finv * Ai * p * Ai');
        x(:, i) = x(:, i - 1) + k * (b(i) - Ai * x(:, i - 1));
        p  = finv * (p - k * Ai * p);
    end
    % extract ubar from x
    ub = x(1,1:m)'; 
end