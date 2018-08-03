function Sources = gatherSourceLocations( path,CalibDS )
%GATHERSOURCELOCATIONS Summary of this function goes here
%   Detailed explanation goes here

%%Copy these to a file
galvo_positions = dlmread(strcat(path,'position.txt'));
% files = dir(strcat(path,'/*.png'));
Sources = zeros(length(galvo_positions),2);
for i=1:length(galvo_positions)
    x = galvo_positions(1,i);
    y = galvo_positions(2,i);
%     x = round(100*galvo_positions(1,i)-1e-3);
%     if(x == -109)
%         x = -108;
%     end
%     y = round(100*galvo_positions(2,i)+0.001);

    fileName = (strcat(path,'scanPos_x_',num2str(x),'_y_',num2str(y),'.pgm'));
    I = imread(fileName);
    %I(1,:) = 0; % Hack as the images captured for T are slightly corrupted
    imageLocation = DetectCentroid(I,200);
%     figure(1),imshow(I,[]);hold on;plot(imageLocation(1),imageLocation(2),'r+');hold off
    Sources(i,:) = CalibDS.func(CalibDS.t,imageLocation);
end

Sources = Sources*1e-3; %Everything in meters
end

