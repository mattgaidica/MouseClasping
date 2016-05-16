function detectClasps(videoFile)
nFrames = 1;
padFactor = 3;
diskSize = 5;

videoFileReader = vision.VideoFileReader(videoFile);
f1_shapeInserter = vision.ShapeInserter('BorderColor','Custom','CustomBorderColor',[0 0 1]);
f2_shapeInserter = vision.ShapeInserter('BorderColor','Custom','CustomBorderColor',[0 1 0]);
hblob = vision.BlobAnalysis('AreaOutputPort',true,...
    'CentroidOutputPort',true,... 
    'BoundingBoxOutputPort',true);

% circle active zone
frame = step(videoFileReader);
h = figure;
imshow(frame);
activeRect = round(getPosition(imrect));
close(h);

f1_thresholds = getThresholds(videoFile,nFrames,padFactor);
f2_thresholds = getThresholds(videoFile,nFrames,padFactor);

figure;
while ~isDone(videoFileReader)
    frame = step(videoFileReader);
    frame = imcrop(frame,activeRect);
    f1_mask = claspMask(frame,f1_thresholds,diskSize);
    f2_mask = claspMask(frame,f2_thresholds,diskSize);
    
    [area,centroid,bbox] = step(hblob,f1_mask);
    [areaVal,areaKey] = max(area);
    frame = step(f1_shapeInserter,frame,bbox(areaKey,:));
    
    [area,centroid,bbox] = step(hblob,f2_mask);
    [areaVal,areaKey] = max(area);
    frame = step(f2_shapeInserter,frame,bbox(areaKey,:));
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