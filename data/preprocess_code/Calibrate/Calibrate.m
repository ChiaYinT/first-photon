function CalibDS = Calibrate( fileName )
%CALIBRATE Summary of this function goes here
%   Calibrate with a checker board

CalibDS.H = ones(3);
CalibDS.status = 'failed';


I = imread(fileName);

% Hard coded. Dimensions of the board from the first square to the last square
% rect_x = 38.25*25.4; % in mm
% rect_y = 28.25*25.4;
rect_x = 0:2.25*25.4:2.25* 6*25.4; % in mm
rect_y = 0:2.25*25.4:2.25*10*25.4;



[P,~,~] = detectCheckerboardPoints(I); % Returns the 64 points. There is a in-built matlab function that is failing sometimes
imagePoints = Organize(P);

% figure(1); imshow(I);hold on;
% for i=1:size(P,1)
%     plot(P(i,1),P(i,2),'r.');pause(.5);
% end
if(length(imagePoints) < 77)
    CalibDS.status = 'failed';
    return;
end

grid = combvec(rect_y,rect_x)';
worldPoints =[grid(:,2),grid(:,1)];

% H = DLT(imagePoints_main,worldPoints);
H = DLT(imagePoints,worldPoints);
t = projective2d(H);
% [J,RB]= imwarp(I,t); % Remove the homography (in this case, projective)

%Testing
worldPoints_rec = transformPointsForward(t,imagePoints);

% if( sum((worldPoints_rec(:)-worldPoints(:))./worldPoints(:) > 1e-1))
%     CalibDS.status = 'failed';
%     return;
% end

CalibDS.H = H;
CalibDS.t = t;
CalibDS.status = 'success';
CalibDS.func = @(t,x) (transformPointsForward(t,x));

end

