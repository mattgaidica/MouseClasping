function y = lpd(x, pfilt, nlev)
% LPD   Multi-level Laplacian pyramid decomposition
%
%	y = lpdecn(x, pfilt, nlev)
%
% Input:
%   x:      input signal (of any dimension)
%   pfilt:  pyramid filter name (see PFILTERS)
%   nlev:   number of decomposition level
%
% Output:
%   y:      output in a cell vector from coarse to fine layers
%
% See also: LPR
%
% Note:     1-D input signals have to be in column vectors

nd = ndims(x);
sx = size(x);

% Consider column vectors as 1-D signals 
if nd == 2 & sx(2) == 1
    nd = 1;
end


if (nd == 1 & log2(sx(1)) < nlev) | (nd > 1 & min(log2(sx)) < nlev)
    error('Too many decomposition levels');
end
    
% Get the pyramidal filters from the filter name
[h, g] = pfilters(pfilt);

% Decide extension mode
switch pfilt
    case {'9-7', '9/7', '5-3', '5/3', 'Burt'}
        extmod = 'sym';
        
    otherwise
        extmod = 'per';
        
end

y = cell(1, nlev+1);

for n = 1:nlev
    [x, y{nlev-n+2}] = lpdec1(x, nd, h, g, extmod);
end

y{1} = x;
