clc,clear,
close all

addpath('../Calibrate');

raw_data_folder_root = '../../dataset3-raw_data/';
calib_path= [raw_data_folder_root 'calibration/'];

exp_name = 'CurvedObject';
transient_data_folder_root = ['../../dataset3-transient_data/' exp_name '/'];
if ~exist(transient_data_folder_root, 'dir')
    mkdir(transient_data_folder_root);
end

data_img_path = [raw_data_folder_root 'PlaneCharacterization\03_21_2017_15deg_168\' ];

%%Calibration files
detector_Bias_file = '3-21-2017_ph300export_-021_--091.dat';
checkerBoardImage = '03-01-2017_checker.png';
detectorImage     = '03-01-2017_virtual_detector.png';
SourceImage       = '11_28_2016_VS.pgm';
Source_distance   = 2200.00;% in m.meters

CalibDS = Calibrate(strcat(calib_path,checkerBoardImage)); %Calibration data: Fails for some images

V_Sources = gatherSourceLocations(data_img_path,CalibDS);
V_Detector= gatherDetectorLocation(strcat(calib_path,detectorImage),CalibDS);
V_Source  = gatherDetectorLocation(strcat(calib_path,SourceImage),CalibDS);

ShowCalibration( CalibDS,calib_path,data_img_path,checkerBoardImage,detectorImage,V_Sources,V_Detector);

SourceLocation = [V_Source  Source_distance* 1e-3]; % Calibrated/Measured. Need to automate this.
DetectorLocation=[V_Detector Source_distance*1e-3];

vs = [V_Sources zeros(size(V_Sources,1),1)];
vd = [repmat(V_Detector,size(V_Sources,1),1) zeros(size(V_Sources,1),1)];
DetectorLocation = DetectorLocation - [V_Detector 0];
SourceLocation = SourceLocation - [V_Detector 0];
vs = vs - vd;
vd = vd - vd;

f = dir([raw_data_folder_root exp_name '/']);

for i = 1:size(f,1)
    file_name = f(i,1).name;
    if length(file_name) < 2,
        continue;
    end
    
    if strcmp(file_name(1:2), '03') == 1 || strcmp(file_name(1:2), 'SP') == 1
        data_name = [exp_name '\' file_name '\'];
        
        wrapAround = 3215;
        
        
        VariableFront = 0;
        data_path = [raw_data_folder_root data_name];
        
        data         = gatherCorrectedData(strcat(calib_path,detector_Bias_file),data_path,SourceLocation,[0 0],vs(:,1:2)); % The timing here is from VS to Object to VD to detector
       
        output = [transient_data_folder_root file_name '.mat'];
        save(output, 'vs', 'vd', 'data', 'DetectorLocation', 'SourceLocation' );
        
    end
end