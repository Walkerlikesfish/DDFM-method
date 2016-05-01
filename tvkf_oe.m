
function x = tvkf_oe(y, a, c, v, x0, p)
T = size(y, 1); y = y'; 
x = zeros(size(a, 1), T); x(:, 1) = x0; 
for t = 1:(T-1)
  k  = (a * p * c') * pinv(v + c * p * c');
  x(:, t + 1) = a * x(:, t) + k * (y(:, t) - c * x(:, t));
  p  = a * p * a' - k * (v + c * p * c') * k';
end
