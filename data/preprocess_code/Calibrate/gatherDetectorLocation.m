function V_Detector = gatherDetectorLocation( fileName,CalibDS )

I = (imread(fileName));
% I(1,:) = 0; % Hack as the images captured for T are slightly corrupted
I(1:3,:) = 0; % Hack as the images captured for T are slightly corrupted
I(:,1:3) = 0; % Hack as the images captured for T are slightly corrupted

imageLocation = DetectCentroid(I,200);
V_Detector = CalibDS.func(CalibDS.t,imageLocation);

V_Detector = V_Detector *1e-3; %Everything in meters

end

