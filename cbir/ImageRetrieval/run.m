figure;
diffArr = [];
refCorr = hsvHistogram(frameRef);
for ii=400:500
    hsvHist = [];
    frame = read(v,ii);
    hsvHist = hsvHistogram(frame);
    diffArr(ii) = sum(abs(refCorr-hsvHist));
    hold on;
    plot(hsvHist);
end

% % figure('position',[0 0 600 800]);
% % for ii=1:10
% %     subplot(2,1,1);
% %     imshow(frameRef);
% %     subplot(2,1,2);
% %     imshow(read(v,b(ii)+400));
% %     disp('stop');
% % end