function hsvRect=makeHsvRect(thresholds,rectSize)
% make rect size [width,height]

gradient = [linspace(thresholds(1)-thresholds(2),thresholds(1)+thresholds(2),rectSize(1));...
    linspace(max(thresholds(3)-thresholds(4),0),min(thresholds(3)+thresholds(4),1),rectSize(1));...
    linspace(max(thresholds(5)-thresholds(6),0),min(thresholds(5)+thresholds(6),1),rectSize(1))];

% fix wrapping for hue
for ii=1:rectSize(1)
    if gradient(1,ii) > 1
        gradient(1,ii) = gradient(1,ii) - 1;
    elseif gradient(1,ii) < 0
        gradient(1,ii) = 1 + gradient(1,ii);
    end
end

hsvRect(:,:,1) = repmat(gradient(1,:),rectSize(2),1);
hsvRect(:,:,2) = repmat(gradient(2,:),rectSize(2),1);
hsvRect(:,:,3) = repmat(gradient(3,:),rectSize(2),1);