clear; close all; clc;
load '../data/dataset'

threshold = 14;
threshold_edge = 500;

N = 300;
alpha = 2.5;
g1 = gausswin(N, alpha);

mid = N/2;
x = 1:N;
sigma = N/(2*alpha);
g2 = -(x-mid)/(sigma*sigma).*exp(-((x-mid).^2/(2*sigma*sigma)));

first_photon_idx = nan(size(dataset.data,1),4);
img_first_photon = zeros(size(dataset.data,1), dataset.t);

for i = 1:size(dataset.data,1),
    s0 = reshape(dataset.data(i,:,:),1,dataset.t);
    
    s1 = conv(s0,g1,'same');
    s2 = conv(s1,g2,'same');
    
    s2(1,1:800) = 0;
    for j = 1:4,
        idx = find(s2 > threshold_edge, 1);
        if ~isempty(idx),
            idx = idx + mid;
            first_photon_idx(i,j) = idx;
            s2(1:idx+300) = 0;
            
            img_first_photon(i,idx:idx+200) = 1;
        else
            break;
        end
    end
    
end

figure; 
imagesc(img_first_photon);


save('results/first_photon_idx', 'first_photon_idx');
