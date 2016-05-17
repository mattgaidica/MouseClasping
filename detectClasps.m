function detectClasps(videoFile)
nFrames = 1;
padFactor = 5;
videoWidth = 720;
rectHeight = 50;
rectSize = [videoWidth rectHeight];

videoFileReader = vision.VideoFileReader(videoFile);

hblob = vision.BlobAnalysis('AreaOutputPort',true,...
    'CentroidOutputPort',true,... 
    'BoundingBoxOutputPort',true);

% circle active zone
% % frame = step(videoFileReader);
% % h = figure;
% % imshow(frame);
% % activeRect = round(getPosition(imrect));
% % close(h);

f1_thresholds = getThresholds(videoFile,nFrames,padFactor);
f1_hsvRect = makeHsvRect(f1_thresholds,rectSize);

f2_thresholds = getThresholds(videoFile,nFrames,padFactor);
f2_hsvRect = makeHsvRect(f2_thresholds,rectSize);

initLoop = true;
while ~isDone(videoFileReader)
    frame = step(videoFileReader);
    videoScale = videoWidth / size(frame,2);
    frame = imresize(frame,videoScale);
    
    if initLoop
        initLoop = false;
        figureHeight = size(frame,1) + 2*rectHeight;
        h = figure('position',[0 0 size(frame,2) figureHeight]);
        hs(1) = subplot(3,1,1);
        setpixelposition(hs(1),[0 figureHeight-rectHeight videoWidth rectHeight]);
        imshow(hsv2rgb(f1_hsvRect));
        hs(2) = subplot(3,1,2);
        setpixelposition(hs(2),[0 figureHeight-rectHeight*2 videoWidth rectHeight]);
        imshow(hsv2rgb(f2_hsvRect));
        hs(3) = subplot(3,1,3);
        setpixelposition(hs(3),[0 0 size(frame,2) size(frame,1)]);
    end
    
% %     frame = imcrop(frame,activeRect);
    f1_mask = claspMask(frame,f1_thresholds);
    f2_mask = claspMask(frame,f2_thresholds);
    
    [f1_area,f1_centroid,f1_bbox] = step(hblob,f1_mask);
    [~,f1_areaKey] = max(f1_area);
    [f2_area,f2_centroid,f2_bbox] = step(hblob,f2_mask);
    [~,f2_areaKey] = max(f2_area);
    
    frame = insertObjectAnnotation(frame,'rectangle', ...
                    [f1_bbox(f1_areaKey,:);f2_bbox(f2_areaKey,:)],{'1','2'});
    if ~isempty(f1_centroid) && ~isempty(f2_centroid)
        frame = insertShape(frame,'Line',[f1_centroid(f1_areaKey,:) f2_centroid(f2_areaKey,:)]);
    end
    
    imshow(frame);
end

end

function mask=claspMask(frame,thresholds)
hsvFrame = rgb2hsv(frame);
mask = HSVthreshold(hsvFrame,thresholds);
mask = imopen(mask, strel('rectangle', [3,3]));
mask = imclose(mask, strel('rectangle', [15,15]));
mask = imfill(mask, 'holes');
end

function thresholds=getThresholds(videoFile,nFrames,padFactor)
hsvBounds = getHsvBounds(videoFile,nFrames);
thresholds = [
    mean(hsvBounds{1}), std(hsvBounds{1}) * padFactor...
    mean(hsvBounds{2}), std(hsvBounds{2}) * padFactor...
    mean(hsvBounds{3}), std(hsvBounds{3}) * padFactor...
];
end