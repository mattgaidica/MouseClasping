videoFile = '/Users/mattgaidica/Dropbox/Projects/Mouse Clasping/IMG_3092.mov';
v = VideoReader(videoFile);

resizeScale = 0.15;
frame = read(v,1);
frame = imresize(frame,resizeScale);
imshow(frame);
h = imrect;
pos = getPosition(h);

v = VideoReader(videoFile);

allFrames = [];
ii = 1;
while hasFrame(v)
    disp(['Frame ',num2str(ii)]);
    frame = readFrame(v);
    frame = imresize(frame,resizeScale);
    frame = imcrop(frame,pos);
    frameGray = imadjust(rgb2gray(frame),[0.2 0.8]);
    allFrames(ii,:,:) = frameGray;
    ii = ii + 1;
end

% imshow(frame);
% h = imrect;
% pos = getPosition(h);

Fs = 30;
fpass = [1 15];
data = squeeze(reshape(allFrames,[size(allFrames,1) 1 size(allFrames,2)*size(allFrames,3) ]));
[W,freqList] = calculateComplexScalograms_EnMasse(data,'Fs',Fs,'fpass',fpass,'doplot',true);

% h = imfreehand;
% mask = createMask(h);
% close(hfig);
% 
% frameMasked = frameGray .* uint8(mask);
% imshow(frameMasked);