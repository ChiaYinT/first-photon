clc,clear,
close all

addpath('../Calibrate');

raw_data_folder_root = '../../dataset4-raw_data/';
calib_path= [raw_data_folder_root];

exp_name = 'data';
transient_data_folder_root = '../../dataset4-transient_data/';
if ~exist(transient_data_folder_root, 'dir')
    mkdir(transient_data_folder_root);
end

data_img_path = [raw_data_folder_root 'Pictures\' ];

%%Calibration files
detector_Bias_file = 'ph300export.dat';
checkerBoardImage = 'CheckerBoard.pgm';
detectorImage     = 'VD.pgm';
SourceImage       = 'VS.pgm';
Source_distance   = 2200.00;% in m.meters

CalibDS = Calibrate(strcat(calib_path,checkerBoardImage)); %Calibration data: Fails for some images

V_Sources = gatherSourceLocations4(data_img_path,CalibDS);
V_Detector= gatherDetectorLocation(strcat(calib_path,detectorImage),CalibDS);
V_Source  = gatherDetectorLocation(strcat(calib_path,SourceImage),CalibDS);

ShowCalibration4( CalibDS,calib_path,data_img_path,checkerBoardImage,detectorImage,V_Sources,V_Detector);

SourceLocation = [V_Source  Source_distance* 1e-3]; % Calibrated/Measured. Need to automate this.
DetectorLocation=[V_Detector Source_distance*1e-3];

vs = [V_Sources zeros(size(V_Sources,1),1)];
vd = [repmat(V_Detector,size(V_Sources,1),1) zeros(size(V_Sources,1),1)];
DetectorLocation = DetectorLocation - [V_Detector 0];
SourceLocation = SourceLocation - [V_Detector 0];
vs = vs - vd;
vd = vd - vd;

wrapAround = 3215;


VariableFront = 0;
f = dir([raw_data_folder_root exp_name '/']);

for i = 1:size(f,1)
    file_name = f(i,1).name;
    if length(file_name) < 2,
        continue;
    end
    
    if strcmp(file_name(1), 'F') == 1 || strcmp(file_name(1), 'M') == 1 ||  strcmp(file_name(1:2), 'Ro') == 1
        output_folder = [transient_data_folder_root file_name '/'];
        if ~exist(output_folder, 'dir')
            mkdir(output_folder)
        end
        
        g = dir( [raw_data_folder_root exp_name '\' file_name '\']);
        for j = 1:size(g,1)
            
            mat_file_name = g(j,1).name;
            if length(mat_file_name) > 2
                
                if strcmp(mat_file_name(1:2), 'To') == 1 || strcmp(mat_file_name(1:2), 'Ac') == 1
                    data_path =  [raw_data_folder_root exp_name '\' file_name '\' mat_file_name];
                    
                    data  = gatherCorrectedData4(strcat(calib_path,detector_Bias_file),data_path,SourceLocation,[0 0],vs(:,1:2)); % The timing here is from VS to Object to VD to detector
                    
                    output = [output_folder mat_file_name];
                    save(output, 'vs', 'vd', 'data', 'DetectorLocation', 'SourceLocation' );
                end
            end
        end
        
        
    end
end