function detectClasps(videoFile)
nFrames = 3;
padFactor = 5;
diskSize = 3;
scaleFrame = 0.5;

videoFileReader = vision.VideoFileReader(videoFile);
f1_shapeInserter = vision.ShapeInserter('BorderColor','Custom','CustomBorderColor',[1 0 0]);
f2_shapeInserter = vision.ShapeInserter('BorderColor','Custom','CustomBorderColor',[1 0 0]);
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
f2_thresholds = getThresholds(videoFile,nFrames,padFactor);

figure;
while ~isDone(videoFileReader)
    frame = step(videoFileReader);
    frame = imresize(frame,scaleFrame);
% %     frame = imcrop(frame,activeRect);
    f1_mask = claspMask(frame,f1_thresholds,diskSize);
    f2_mask = claspMask(frame,f2_thresholds,diskSize);
    
    [f1_area,f1_centroid,f1_bbox] = step(hblob,f1_mask);
    [f1_areaVal,f1_areaKey] = max(f1_area);
    frame = step(f1_shapeInserter,frame,f1_bbox(f1_areaKey,:));
    
    [f2_area,f2_centroid,f2_bbox] = step(hblob,f2_mask);
    [f2_areaVal,f2_areaKey] = max(f2_area);
    frame = step(f2_shapeInserter,frame,f2_bbox(f2_areaKey,:));
    
    imshow(frame);
end

end

function mask=claspMask(frame,thresholds,diskSize)
sedisk = strel('disk',diskSize);
hsvFrame = rgb2hsv(frame);
mask = HSVthreshold(hsvFrame,thresholds);
mask = imopen(mask,sedisk);
mask = imfill(mask,'holes');
end

function thresholds=getThresholds(videoFile,nFrames,padFactor)
hsvBounds = getHsvBounds(videoFile,nFrames);
thresholds = [
    mean(hsvBounds{1}), std(hsvBounds{1}) * padFactor...
    mean(hsvBounds{2})-(std(hsvBounds{2})*padFactor), mean(hsvBounds{2})+(std(hsvBounds{2})*padFactor)...
    mean(hsvBounds{3})-(std(hsvBounds{3})*padFactor), mean(hsvBounds{3})+(std(hsvBounds{3})*padFactor)...
];
end