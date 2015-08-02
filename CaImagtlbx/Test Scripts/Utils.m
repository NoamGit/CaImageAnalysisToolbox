a = handles.engine.planeArray(1).meanImageClean; 
b = handles.engine.planeArray(2).meanImageClean;
c = handles.engine.planeArray(3).meanImageClean;

figure;
subplot(1,3,1); imagesc(a); colormap(gray); title('Plane #1 - Mean Image [Clean]');
subplot(1,3,2); imagesc(b); colormap(gray); title('Plane #2 - Mean Image [Clean]');
subplot(1,3,3); imagesc(c); colormap(gray); title('Plane #3 - Mean Image [Clean]');


figure;
subplot(2,3,1), imshow(I), title('1.original');
subplot(2,3,2), imshow(BWs), title('2.binary gradient mask');
subplot(2,3,3),imshow(BWsdil), title('3.dilated gradient mask');
subplot(2,3,4), imshow(BWdfill); title('4.binary image with filled holes');
subplot(2,3,5), imshow(BWnobord), title('5.cleared border image');
subplot(2,3,6), imshow(planeArtifacts), title('6.final image');


figure;
subplot(1,2,1), imshow(planeArray(iSrcPlane).meanImage), title('1.original');
subplot(1,2,2), imshow(planeArtifacts), title('2.final image');

%%
figure;
planeNo = 1; cellNo = 2;
rawData = handles.engine.planeArray(planeNo).cellArray(cellNo).rawData;
normData = handles.engine.planeArray(planeNo).cellArray(cellNo).normData;
subplot(2,1,1), plot(rawData);
sTitle = sprintf('Plane#%d, Cell #%d Fluorescence Activity (Raw Data)', planeNo, cellNo);
title(sTitle); xlabel('Samples'); ylabel('Fluorescence');  
subplot(2,1,2), plot(normData);
sTitle = sprintf('Plane#%d, Cell #%d Fluorescence Activity (Normalized Data)', planeNo, cellNo);
title(sTitle); xlabel('Samples'); ylabel('Fluorescence');

%%

figure;
planeNo = 1; cellNo = 1;
fTimeSampleCell = 10;

c1 = handles.engine.planeArray(planeNo).cellArray(cellNo);
normData = c1.normData;

subplot(4,1,1), plot(normData);
sTitle = sprintf('Plane#%d, Cell #%d Fluorescence Activity (Normalized Data) Peak Detect Method #1', planeNo, cellNo);
title(sTitle); xlabel('Samples'); ylabel('Fluorescence');  
hold on
th = 0;
c1.calcPeaks_Method1(fTimeSampleCell, th);
peaksData = c1.peaksData;
peaksData (peaksData == 1) = normData(peaksData == 1);% maxGraph;
peaksData (peaksData == 0) = NaN;
plot(peaksData, 'k^', 'markerfacecolor', 'r');
hold off;

subplot(4,1,2), plot(normData);
sTitle = sprintf('Plane#%d, Cell #%d Fluorescence Activity (Normalized Data) Peak Detect Method #2', planeNo, cellNo);
title(sTitle); xlabel('Samples'); ylabel('Fluorescence');  
hold on
th = 0;
c1.calcPeaks_Method2(fTimeSampleCell, th);
peaksData = c1.peaksData;
peaksData (peaksData == 1) = normData(peaksData == 1);% maxGraph;
peaksData (peaksData == 0) = NaN;
plot(peaksData, 'k^', 'markerfacecolor', 'r');
hold off;

subplot(4,1,3), plot(normData);
sTitle = sprintf('Plane#%d, Cell #%d Fluorescence Activity (Normalized Data) Peak Detect Method #3', planeNo, cellNo);
title(sTitle); xlabel('Samples'); ylabel('Fluorescence');  
hold on
th = 0.3;
c1.calcPeaks_Method3(fTimeSampleCell, th);
peaksData = c1.peaksData;
peaksData (peaksData == 1) = normData(peaksData == 1);% maxGraph;
peaksData (peaksData == 0) = NaN;
plot(peaksData, 'k^', 'markerfacecolor', 'r');
hold off;

subplot(4,1,4), plot(normData);
sTitle = sprintf('Plane#%d, Cell #%d Fluorescence Activity (Normalized Data) Peak Detect Method #4', planeNo, cellNo);
title(sTitle); xlabel('Samples'); ylabel('Fluorescence');  
hold on
th = 0.03;
c1.calcPeaks_Method4(fTimeSampleCell, th);
peaksData = c1.peaksData;
peaksData (peaksData == 1) = normData(peaksData == 1);% maxGraph;
peaksData (peaksData == 0) = NaN;
plot(peaksData, 'k^', 'markerfacecolor', 'r');
hold off;