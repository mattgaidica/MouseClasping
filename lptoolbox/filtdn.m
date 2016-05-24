function y = filtdn(x, f, dim, extmod, shift)
% FILTDN   Filter and downsample (by 2) along a dimension
%
%       y = filtdn(x, f, dim, extmod, shift)
%
% Input:
%   x:      input signal
%   f:      1-D filter
%   dim:    the processing dimension
%   extmod: extension mode (e.g. 'per' or 'sym')
%   shift:  specifies the window over which filtering occurs
%
% Output:
%   y:      filtered and dowsampled signal
%
% Note:
%   The origin of the filter f is assumed to be floor(size(f)/2) + 1.
%   Amount of shift should be no more than floor((size(f)-1)/2).

% Cell array of indexes for each dimension
nd = ndims(x);
I = cell(1, nd);
for d = 1:nd
    I{d} = 1:size(x,d);
end

% Border extend the filtering dimension
n = size(x, dim);
lf = length(f);
I{dim} = bordex(n, lf, extmod, shift);
y = x(I{:});
    
% Filter, downsample, and return only the 'valid' part
y = filter(f, 1, y, [], dim);
I{dim} = (1:2:n) + lf - 1;
y = y(I{:});