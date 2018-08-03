clc,clear,close all



% I = imread('8-2-2016/Calibration.png');
I = imread('DATA/calibrationData/39.png');
data_path = 'DATA/Measurements/8-5-2016_DoublePatch_1(2)/';


rect_x = 38.25*25.4; % in mm
rect_y = 28.25*25.4;


[imagePoints,boardSize] = GetCheckerBoardPoints(I);

figure(1),imshow(I,[]);hold on;
% plot(imagePoints(:,1),imagePoints(:,2),'ro');
% for i=1:size(imagePoints,1)
%     plot(imagePoints(i,1),imagePoints(i,2),'ro');pause(.2);
% end

imagePoints_main = [imagePoints(1,:);imagePoints(20,:);imagePoints(45,:);imagePoints(64,:)];
                
                
plot(imagePoints_main(:,1),imagePoints_main(:,2),'bo');

worldPoints = [0          0; ...
               0          rect_y; ...
               rect_x     0; ...
               rect_x     rect_y];

H = DLT(imagePoints_main,worldPoints);

t = maketform( 'projective',imagePoints_main,worldPoints);
% J = imtransform(I,t);

t = projective2d(t.tdata.T);
% t = projective2d(H);
[J,RB]= imwarp(I,t);
   
figure(2),imshow(J,[]);hold on;

worldPoints_rec = transformPointsForward(t,imagePoints);
plot(worldPoints_rec(:,1)-RB.XWorldLimits(1)+1,worldPoints_rec(:,2)-RB.YWorldLimits(1)+1,'ro');

%Method - II (SHOULD MATCH)
worldPoints_rec2 = [imagePoints ones(size(imagePoints,1),1)] * t.T;
worldPoints_rec2(:,1) = worldPoints_rec2(:,1)./worldPoints_rec2(:,3);
worldPoints_rec2(:,2) = worldPoints_rec2(:,2)./worldPoints_rec2(:,3);
plot(worldPoints_rec2(:,1)-RB.XWorldLimits(1)+1,worldPoints_rec2(:,2)-RB.YWorldLimits(1)+1,'bo');