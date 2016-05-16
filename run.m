% videoFile = '/Users/mattgaidica/Dropbox/Projects/Mouse Clasping/testVideo.mov';
% video = VideoReader(videoFile);

% video = VideoReader(videoFile);

% [ ] use regionprops?

videoFileReader = vision.VideoFileReader(videoFile);
videoPlayer = vision.VideoPlayer();
shapeInserter = vision.ShapeInserter('BorderColor','Custom','CustomBorderColor',[1 0 0]);

objectFrame = step(videoFileReader);
objectHSV = rgb2hsv(objectFrame);
% objectRegion = [40, 45, 25, 25];
figure;
imshow(objectFrame);
objectRegion = round(getPosition(imrect));
objectImage = step(shapeInserter, objectFrame, objectRegion);
title('Red box shows object region');

tracker = vision.HistogramBasedTracker;
initializeObject(tracker, objectHSV(:,:,1) , objectRegion);

while ~isDone(videoFileReader)
  frame = step(videoFileReader);          
  hsv = rgb2hsv(frame);                   
  bbox = step(tracker, hsv(:,:,1));       
                                        
  out = step(shapeInserter, frame, bbox); 
  step(videoPlayer, out);                 
end

release(videoPlayer);
release(videoFileReader);