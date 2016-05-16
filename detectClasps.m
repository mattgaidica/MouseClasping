function detectClasps(videoFile)
nFrames = 3;
padFactor = 3;

videoFileReader = vision.VideoFileReader(videoFile);
f1_shapeInserter = vision.ShapeInserter('BorderColor','Custom','CustomBorderColor',[0 0 1]);
f2_shapeInserter = vision.ShapeInserter('BorderColor','Custom','CustomBorderColor',[0 1 0]);
hblob = vision.BlobAnalysis('AreaOutputPort',true,...
    'CentroidOutputPort',true,... 
    'BoundingBoxOutputPort',true);

% circle active zone
frame = step(videoFileReader);
h_im = imshow(frame);
mask = createMask(imfreehand,h_im);

% foot 1
hsvBounds = getHsvBounds(videoFile,nFrames);
f1_thresholds = [
    mean(hsvBounds{1}), std(hsvBounds{1}) * padFactor...
    mean(hsvBounds{2})-(std(hsvBounds{2})*padFactor), mean(hsvBounds{2})+(std(hsvBounds{2})*padFactor)...
    mean(hsvBounds{3})-(std(hsvBounds{3})*padFactor), mean(hsvBounds{3})+(std(hsvBounds{3})*padFactor)...
    ];
% foot 2
hsvBounds = getHsvBounds(videoFile,nFrames);
f2_thresholds = [
    mean(hsvBounds{1}), std(hsvBounds{1}) * padFactor...
    mean(hsvBounds{2})-(std(hsvBounds{2})*padFactor), mean(hsvBounds{2})+(std(hsvBounds{2})*padFactor)...
    mean(hsvBounds{3})-(std(hsvBounds{3})*padFactor), mean(hsvBounds{3})+(std(hsvBounds{3})*padFactor)...
    ];

while ~isDone(videoFileReader)
  frame = step(videoFileReader);          
  hsvFrame = rgb2hsv(frame);
  mask = HSVthreshold(hsvFrame,thresholds);
  mask = imopen(mask,sedisk);
  mask = imfill(mask,'holes');
  [area,centroid,bbox] = step(hblob,mask);
  
  [areaVal,areaKey] = max(area);
                                        
  out = step(shapeInserter,frame,bbox(areaKey,:));
  step(videoPlayer,out);
end

frame = step(videoFileReader);
hsvFrame = rgb2hsv(frame);

end