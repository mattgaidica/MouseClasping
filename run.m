% videoFile = '/Users/mattgaidica/Dropbox/Projects/Mouse Clasping/testVideo.mov';
% video = VideoReader(videoFile);
% 
videoFileReader = vision.VideoFileReader(videoFile);
videoPlayer = vision.VideoPlayer();
shapeInserter = vision.ShapeInserter('BorderColor','Custom','CustomBorderColor',[1 0 0]);
frame = step(videoFileReader);
hsvFrame = rgb2hsv(frame);



nFrames = 3;
hsvBounds = getHsvBounds(videoFile,nFrames);
padFactor = 3;
thresholds = [
    mean(hsvBounds{1}), std(hsvBounds{1}) * padFactor...
    mean(hsvBounds{2})-(std(hsvBounds{2})*padFactor), mean(hsvBounds{2})+(std(hsvBounds{2})*padFactor)...
    mean(hsvBounds{3})-(std(hsvBounds{3})*padFactor), mean(hsvBounds{3})+(std(hsvBounds{3})*padFactor)...
    ];

% thresholds = [hCenter max(hCenter - threshPad) min(hCenter + threshPad)...
%     sCenter max(sCenter - threshPad) min(sCenter + threshPad)...
%     vCenter max(vCenter - threshPad) min(vCenter + threshPad)];

mask = HSVthreshold(hsvFrame,thresholds);
sedisk = strel('disk',3);
mask = imopen(mask,sedisk);
mask = imfill(mask,'holes');
figure; imshow(mask);

% objectImage = step(shapeInserter, objectFrame, objectRegion);
% title('Red box shows object region');

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

release(videoPlayer);
release(videoFileReader);