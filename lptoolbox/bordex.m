function ind = bordex(n, lf, extmod, shift)
% BORDEX   Border extend for perfect reconstruction filter banks
%
%       ind = bordex(n, lf, extmod, shift)
%
% Input:
%   n:      signal length
%   lf:     filter length
%   extmod: extension mode (e.g. 'per' or 'sym')
%   shift:  specifies the window over which filtering occurs
%
% Output:
%   ind:    index for extended signal
%
% Note:
%   The origin of the filter f is assumed to be floor(size(f)/2) + 1.
%   Amount of shift should be no more than floor((size(f)-1)/2).

% Amount of extension at two ends
e1 = floor((lf - 1) / 2) + shift;
e2 = ceil((lf - 1) / 2) - shift;

switch extmod
    case 'per'
        ind = [n-e1+1:n, 1:n, 1:e2];
        if (n < e1) | (n < e2)
            ind = mod(ind, n);
            ind(ind==0) = n;
        end
        
    case 'sym'
        ind = [1:n];

        % Symmetrically extend left
        while (e1 >= 2*n-2)
            ind = [1:n-1, n:-1:2, ind];            
            e1 = e1 - (2*n-2);
        end

        if (e1 < n)
            ind = [e1+1:-1:2, ind];
        else
            ind = [2*n-1-e1:n-1, n:-1:2, ind];     
        end

        % Symmetrically extend right
        while (e2 >= 2*n-2)
            ind = [ind, n-1:-1:1, 2:n];
            e2 = e2 - (2*n-2);
        end

        if (e2 < n)
            ind = [ind, n-1:-1:n-e2];
        else
            ind = [ind, n-1:-1:1, 2:e2-n+2];
        end
        
    otherwise
        error('Invalid extension mode')
        
end