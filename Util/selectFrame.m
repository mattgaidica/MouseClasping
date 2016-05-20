function frameTime = selectFrame(videoFile,nn)
displaySize = 900; %px

v = VideoReader(videoFile);
nFrames = v.Duration * v.FrameRate;
frameSpace = round(linspace(1,nFrames-1,nn*nn));
allFrame = [];
for ii=1:nn*nn
    v.CurrentTime = frameSpace(ii) / v.FrameRate;
    frame = readFrame(v);
    frameScale = (displaySize/nn)/size(frame,2);
    frame = imresize(frame,frameScale);
    frame = insertText(frame,[1 1],num2str(frameSpace(ii)));
    allFrames(:,:,:,ii) = frame;
end
h = figure;
montage(allFrames,'Size',[nn nn]);
framePos = ginput(1);
frameX = ceil(framePos(1) / size(frame,2));
frameY = ceil(framePos(2) / size(frame,1));
frameNumber = frameSpace(((frameY - 1) * nn) + frameX);
frameTime = frameNumber / v.FrameRate;
close(h);