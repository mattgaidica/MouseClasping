function mask = HSVthreshold(hsv_img, thresholds)
%
% INPUTS:
%   hsv_img - image in hsv format
%   thresholds - [hue stdHue sat stdSat val stdVal]
%
% OUTPUTS:
%   mask - logical BW image masking out regions that fall within the
%       threshold ranges

h = squeeze(hsv_img(:,:,1));
s = squeeze(hsv_img(:,:,2));
v = squeeze(hsv_img(:,:,3));

s(s>1) = 1;
s(s<0) = 0;

v(v>1) = 1;
v(v<0) = 0;

h = h * 2 * pi;
h = exp(1i*h);
h_range_center = wrapToPi(thresholds(1) * 2*pi);
h_diff_from_center = angle(h) - h_range_center;
h_diff_from_center = abs(wrapToPi(h_diff_from_center));

angle_thresh = thresholds(2) * 2*pi;

h_mask = (h_diff_from_center <= angle_thresh);
s_mask = (s >= thresholds(3)-thresholds(4) & s <= thresholds(3)+thresholds(4));
v_mask = (v >= thresholds(5)-thresholds(6) & v <= thresholds(5)+thresholds(6));

mask = h_mask & s_mask & v_mask;