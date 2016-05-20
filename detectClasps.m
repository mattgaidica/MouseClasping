function logData = detectClasps(videoFile)
% [] return log data: frame data, color data, pos data (use cells)
% [] statistics: how many clasps? time spent clasp/notclasp

px2mm = 10;
threshStd = 5;
videoWidth = 320;
rectSize = [25 25];

v = VideoReader(videoFile);

[pathstr,name,~] = fileparts(videoFile);
newVideo = VideoWriter(fullfile(pathstr,[datestr(now,'yyyymmdd-HHMMSS') '_' name]),'Motion JPEG AVI');
newVideo.Quality = 100;
newVideo.FrameRate = v.FrameRate;
open(newVideo);

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


logData = []; % [v.CurrentTime, distance px, distance mm, clasped]
curFrame = 0;
h = figure('position',[0 0 fliplr(size(frame(:,:,1)))]);
while hasFrame(v)
    frame = readFrame(v);
    curFrame = curFrame + 1;
    frame = imresize(frame,videoScale);
    logData(curFrame,:) = nan(1,4);
    logData(curFrame,1) = v.CurrentTime;
    
    f1_mask = claspMask(frame,f1_thresholds);
    f2_mask = claspMask(frame,f2_thresholds);
    
    [f1_area,f1_centroid,f1_bbox] = step(hblob,f1_mask);
    [~,f1_areaKey] = max(f1_area);
    [f2_area,f2_centroid,f2_bbox] = step(hblob,f2_mask);
    [~,f2_areaKey] = max(f2_area);
    
    frame = insertRect(frame,f1_rect,[10 10]);
    frame = insertRect(frame,f2_rect,[20+rectSize(2) 10]);
% %     frame = insertShape(frame,'FilledCircle',[bodyCenter 25]);
    
    if ~isempty(f1_areaKey)
        frame = insertObjectAnnotation(frame,'rectangle', ...
                    f1_bbox(f1_areaKey,:),'f1');
% %         frame = insertShape(frame,'Line',[f1_centroid(f1_areaKey,:) bodyCenter]);
    end
    if ~isempty(f2_areaKey)
        frame = insertObjectAnnotation(frame,'rectangle', ...
                    f2_bbox(f2_areaKey,:),'f2');
% %         frame = insertShape(frame,'Line',[f2_centroid(f2_areaKey,:) bodyCenter]);
    end
    if ~isempty(f1_centroid) && ~isempty(f2_centroid)
        frame = insertShape(frame,'Line',[f1_centroid(f1_areaKey,:) f2_centroid(f2_areaKey,:)],...
            'LineWidth',3);
        lineCenter = (f1_centroid(f1_areaKey,:) + f2_centroid(f2_areaKey,:)) / 2;
        lineDist = round(pdist([f1_centroid(f1_areaKey,:);f2_centroid(f2_areaKey,:)]));
        logData(curFrame,2) = lineDist;
        
        if ~isempty(px2mm)
            logData(curFrame,2) = lineDist * px2mm;
            frame = insertText(frame,lineCenter,strcat(num2str(logData(curFrame,2)),' mm'),...
                'AnchorPoint','CenterTop','BoxOpacity',0);
        else
            frame = insertText(frame,lineCenter,strcat(num2str(lineDist),' px'),...
                'AnchorPoint','CenterTop','BoxOpacity',0);
        end
        if lineDist <= bodyPos(1,3) % presumably, body width
            logData(curFrame,3) = true;
            frame = insertText(frame,[10 size(frame,1)-25],'CLASPED','BoxColor','g');
        else
            logData(curFrame,3) = false;
            frame = insertText(frame,[10 size(frame,1)-25],'NOT CLASPED','BoxColor','r');
        end
    else
        logData(curFrame,1) = nan;
    end
    
    imshow(frame);
    disp(['Writing frame ',num2str(curFrame)]);
    writeVideo(newVideo,frame);
end

close(h);
close(newVideo);
end

function frame = insertRect(frame,rect,pos)
% pos = [x,y] from top-left
frame(pos(1):pos(1)+size(rect,1)-1, pos(2):pos(2)+size(rect,2)-1,:) = rect;
end

function hsvData = getHsvData(frame,pos)
% hsvData: dim1=ROI,dim2=[mean,std],dim3=[h,s,v]
for ii=1:size(pos,1)
    frameRoi = imcrop(frame,pos(ii,:));
% %     figure;imshow(frameRoi); % debug
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
    pos(1,:) = getPosition(imrect);
    pos(2,:) = getPosition(imrect);
    pos(3,:) = getPosition(imrect);
    close(h);
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