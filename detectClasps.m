function detectClasps(videoFile)
% [] return log data
% [] pixels to distance option
% [] clasp detector
% [] save video
% [] min blob size (if color doesn't exist)

px2mm = 10;
threshStd = 3;
videoWidth = 320;
rectSize = [100 25];

v = VideoReader(videoFile);

hblob = vision.BlobAnalysis('AreaOutputPort',true,...
    'CentroidOutputPort',true,... 
    'BoundingBoxOutputPort',true,...
    'MinimumBlobArea',5*5,...
    'MaximumBlobArea',100*100,...
    'ExcludeBorderBlobs',true);

frameTime = selectFrame(videoFile,5);
v.CurrentTime = frameTime;
frame = readFrame(v);
v.CurrentTime = 0;

videoScale = videoWidth / size(frame,2);

bodyPos = markBody(frame); % [body, f1, f2]
bodyCenter = [bodyPos(1,1)+bodyPos(1,3)/2 bodyPos(1,2)+bodyPos(1,4)/2]*videoScale;

hsvData = getHsvData(frame,bodyPos);

% second ROI
f1_thresholds = formatThresholds(squeeze(hsvData(2,:,:)),threshStd);
f1_rect = im2uint8(hsv2rgb(makeHsvRect(f1_thresholds,rectSize)));
% third ROI
f2_thresholds = formatThresholds(squeeze(hsvData(3,:,:)),threshStd);
f2_rect = im2uint8(hsv2rgb(makeHsvRect(f2_thresholds,rectSize)));

initLoop = true;
logData = []; % [distance px, distance mm, clasped]
while hasFrame(v)
    frame = readFrame(v);
    frame = imresize(frame,videoScale);
    curFrame = round(v.CurrentTime * v.Duration)+1;
    logData(curFrame,:) = nan(1,3);
    
    if initLoop
        initLoop = false;
        h = figure('position',[0 0 fliplr(size(frame(:,:,1)))]);
    end
    
    f1_mask = claspMask(frame,f1_thresholds);
    f2_mask = claspMask(frame,f2_thresholds);
    
    [f1_area,f1_centroid,f1_bbox] = step(hblob,f1_mask);
    [~,f1_areaKey] = max(f1_area);
    [f2_area,f2_centroid,f2_bbox] = step(hblob,f2_mask);
    [~,f2_areaKey] = max(f2_area);
    
    frame = insertRect(frame,f1_rect,[10 10]);
    frame = insertRect(frame,f2_rect,[20+rectSize(2) 10]);
    frame = insertShape(frame,'FilledCircle',[bodyCenter 25]);
    
    if ~isempty(f1_areaKey)
        frame = insertObjectAnnotation(frame,'rectangle', ...
                    f1_bbox(f1_areaKey,:),'f1');
        frame = insertShape(frame,'Line',[f1_centroid(f1_areaKey,:) bodyCenter]);
    end
    if ~isempty(f2_areaKey)
        frame = insertObjectAnnotation(frame,'rectangle', ...
                    f2_bbox(f2_areaKey,:),'f2');
        frame = insertShape(frame,'Line',[f2_centroid(f2_areaKey,:) bodyCenter]);
    end
    if ~isempty(f1_centroid) && ~isempty(f2_centroid)
        frame = insertShape(frame,'Line',[f1_centroid(f1_areaKey,:) f2_centroid(f2_areaKey,:)],...
            'LineWidth',3);
        lineCenter = (f1_centroid(f1_areaKey,:) + f2_centroid(f2_areaKey,:)) / 2;
        lineDist = round(pdist([f1_centroid(f1_areaKey,:);f2_centroid(f2_areaKey,:)]));
        frame = insertText(frame,lineCenter + [10 -5],strcat(num2str(lineDist),' px'));
        
        logData(curFrame,1) = lineDist;
        if ~isempty(px2mm)
            logData(curFrame,2) = lineDist * px2mm;
        end
        if lineDist <= bodyPos(1,3) % presumably, body width
            logData(curFrame,3) = true;
            frame = insertText(frame,[10 size(frame,1)-25],'CLASPED','BoxColor','w');
        else
            logData(curFrame,3) = false;
            frame = insertText(frame,[10 size(frame,1)-25],'NOT CLASPED','BoxColor','r');
        end
    else
        logData(curFrame,1) = nan;
    end
    
    imshow(frame);
    pause(1);
end

close(h);
end

function frame = insertRect(frame,rect,pos)
% pos = [x,y] from top-left
frame(pos(1):pos(1)+size(rect,1)-1, pos(2):pos(2)+size(rect,2)-1,:) = rect;
end

function hsvData = getHsvData(frame,pos)
% hsvData: dim1=ROI,dim2=[mean,std],dim3=[h,s,v]
for ii=1:size(pos,1)
    frameRoi = imcrop(frame,pos(ii,:));
    figure;imshow(frameRoi); % debug
    frameRoi = rgb2hsv(frameRoi);
    for jj=1:3
        hsvData(ii,1,jj) = mean2(frameRoi(:,:,jj));
        hsvData(ii,2,jj) = std2(frameRoi(:,:,jj));
    end
end
end

function pos = markBody(frame)
    h = figure;
    imshow(frame);
    
    h1 = imrect(gca);
    pos(1,:) = wait(h1);
    setColor(h1,'k');
    
    h2 = imrect(gca);
    pos(2,:) = wait(h2);
    setColor(h2,'r');
    
    h3 = imrect(gca);
    pos(3,:) = wait(h3);
    setColor(h3,'r');
    
    close(h);
    pause(1);
end

function mask = claspMask(frame,thresholds)
hsvFrame = rgb2hsv(frame);
mask = HSVthreshold(hsvFrame,thresholds);
mask = imopen(mask, strel('rectangle', [3,3]));
mask = imclose(mask, strel('rectangle', [15,15]));
mask = imfill(mask, 'holes');
end

function thresholds = formatThresholds(hsvData,threshStd)
thresholds = [];
for ii=1:3
    thresholds = horzcat(thresholds,[hsvData(1,ii) hsvData(2,ii)*threshStd]);
end
end