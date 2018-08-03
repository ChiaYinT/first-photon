function Obj = gatherCorrectedData( Detector_Bias_Calibration_file,data_path,SourceLocation,V_Detector,V_Sources)
%GATHERCORRECTEDDATA Summary of this function goes here
%   Detailed explanation goes here

% There is finite bias in SPAD measurements due to wires and all. 
% Detector_Bias_Calibration_file is measurements from the Source to VS/VD to Detector. Remove source effect from this measurement
% Substract (left shift) the VD to detector value from the histogram.
% Substract the Source to VS for each source position from the corresponding histogram



data_calib_bias = ImportPh300_data(Detector_Bias_Calibration_file)';
data_withObj = dlmread(strcat(data_path,'/data.txt'));

calib_bias = aggregateAllTiming(data_calib_bias);
withObj    = aggregateAllTiming(data_withObj);
Obj        = withObj;

Fixedbias = detectPeak(calib_bias) - getSourceToVSTime(SourceLocation,V_Detector); %  VD to D + bias of electronics

for i=1:length(V_Sources)
    VaryingBias = getSourceToVSTime(SourceLocation,V_Sources(i,:)); % Source to VS time
    Obj(i,:)    = leftShift(withObj(i,:),Fixedbias+VaryingBias);
end

end

function index = detectPeak(data)
    [~, indices] = find(data>max(data)/1.1);
    index = round(mean(indices)); 
end

function TimeIndex = getSourceToVSTime(SourceLocation,V_Source)
    c = 3e8;
    PicoHarpResolution = 4e-12;
    TimeIndex = round(norm(SourceLocation-[V_Source 0])/c/PicoHarpResolution);
end

function shifted_data = leftShift(data,index)
    shifted_data = data( [index:end 1:index-1]);
end
