clc,clear,
close all

addpath('../Calibrate');

raw_data_folder_root = '../../dataset2-raw_data/';
calib_path= [raw_data_folder_root 'calibration/'];

transient_data_folder_root = ['../../dataset2-transient_data/' ];
if ~exist(transient_data_folder_root, 'dir')
    mkdir(transient_data_folder_root);
end

data_img_path = [raw_data_folder_root 'SP_Y_300_21.1_180_Dt_12_4_2016_48\' ];

%%Calibration files
detector_Bias_file= '11_28_2016_ph300export_-1085_-0383.dat';
checkerBoardImage = '11_28_2016_CheckerBoard.pgm';
detectorImage     = '11_28_2016_VD.pgm';
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

f = dir([raw_data_folder_root]);

for i = 1:size(f,1)
    file_name = f(i,1).name;
    if length(file_name) < 2,
        continue;
    end
    
    if  strcmp(file_name(1:2), 'SP') == 1
        
        data_name = [ file_name '\'];
        
        wrapAround = 3215;
        
        
        VariableFront = 0;
        data_path = [raw_data_folder_root data_name];
        
        data         = gatherCorrectedData(strcat(calib_path,detector_Bias_file),data_path,SourceLocation,[0 0],vs(:,1:2)); % The timing here is from VS to Object to VD to detector
       
        output = [transient_data_folder_root file_name '.mat'];
        save(output, 'vs', 'vd', 'data', 'DetectorLocation', 'SourceLocation' );
        
    end
end