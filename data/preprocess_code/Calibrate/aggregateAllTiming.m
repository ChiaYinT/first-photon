function cleanData = aggregateAllTiming( data )
%AGGREGATEALLTIMING Summary of this function goes here
%   Detailed explanation goes here

rep = 25720/8; %% Confirm this number from Mauro

cleanData = zeros(size(data,1),rep);
for j=1:size(data,1)
    for i=1:8
        cleanData(j,:) = cleanData(j,:) + data(j,(i-1)*rep+1:i*rep);
    end
end

end

