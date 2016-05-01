
function uh = stepid_kf(y, sys, v, x0, p0)
[a, b, c, d] = ssdata(sys); [p, m] = size(d); n = size(a, 1);
if ~exist('x0'), x0 = zeros(n + m, 1); end
if ~exist('p0'), p0 = 1e8 * eye(n + m); end
a_aut = [a b; zeros(m, n) eye(m)]; c_aut = [c d];
xeh = tvkf_oe(y, a_aut, c_aut, v, x0, p0); 
uh = xeh((n + 1):end, :)';
