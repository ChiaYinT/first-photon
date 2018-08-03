function ShowCalibration4( CalibDS,calib_path,data_path,checkerBoardImage,detectorImage,V_Sources,V_Detector)
V_Sources = V_Sources *1e3;
V_Detector=V_Detector *1e3;

galvo_positions = dlmread(strcat(data_path,'position.txt'));
I = (imread(strcat(calib_path,checkerBoardImage)));
[J,RB]= imwarp(I,CalibDS.t);
I_locs = zeros(size(I));

for i=1:length(galvo_positions)
    x = galvo_positions(1,i);
    y = galvo_positions(2,i);
    fileName = (strcat(data_path,'scanPos_x_',num2str(x),'_y_',num2str(y),'.pgm'));
    I_locs = I_locs + double(imread(fileName));
end
I_locs = I_locs + double((imread(strcat(calib_path,detectorImage))));
I_locs(1,:) = 0;
[J_locs,RB]= imwarp(I_locs,CalibDS.t);
figure,
imshow(J_locs + double(J),[]);hold on;
plot(V_Sources(:,1)-RB.XWorldLimits(1)+1,V_Sources(:,2)-RB.YWorldLimits(1)+1,'ro');
plot(V_Sources(:,1)-RB.XWorldLimits(1)+1,V_Sources(:,2)-RB.YWorldLimits(1)+1);
plot(V_Detector(1)-RB.XWorldLimits(1)+1, V_Detector(2)-RB.YWorldLimits(1)+1,'r+');

J_locs =  (J_locs + double(J));

imwrite(uint8(J_locs/max(J_locs(:))*255),'calibrationDebug.png');

end

