clear; clc; close all

load 'results/first_photon_idx';
load '../../data/dataset1/dataset';
label = nan(size(first_photon_idx));
idx = find(sum(~isnan(first_photon_idx),2)==4,1);
label(idx,:) = 1:4;
group_color = hsv(4);


[disc] = graphtraverse(sparse(distance_sensor < 10), idx);

img_first_photon = ones(size(dataset.laserPos,1), dataset.t,3);
figure;  hold on;
for i = 2:size(first_photon_idx,1),
    fprintf('i = %d\n', i);
    idx = disc(i);
    neighboring_idx = find(distance_sensor(:,idx) < 10);
    neighboring_idx(neighboring_idx==idx) = [];
    neighboring_first_photon_idx = first_photon_idx(neighboring_idx,:);
    neighboring_first_photon_idx = neighboring_first_photon_idx(:);
    neighboring_label = label(neighboring_idx,:);
    neighboring_label = neighboring_label(:);
    neighboring_first_photon_idx = neighboring_first_photon_idx(~isnan(neighboring_label));
    neighboring_label = neighboring_label(~isnan(neighboring_label));
    
    for j = 1:4,
        tof = first_photon_idx(idx,j);
        if isnan(tof) || isempty(neighboring_first_photon_idx)
            break;
        end
        [Y,I] = min(abs(neighboring_first_photon_idx - tof));
        label(idx,j) = neighboring_label(I);
        plot3(dataset.laserPos(idx,1), dataset.laserPos(idx,2), tof, '.', 'color', group_color(label(idx,j),:));
        neighboring_first_photon_idx = neighboring_first_photon_idx(neighboring_label~=label(idx,j));
        neighboring_label = neighboring_label(neighboring_label~=label(idx,j));
        img_first_photon(idx, tof:tof+150,:) = repmat(reshape(group_color( label(idx,j),:),1,1,3),1,151);
    end
    
end

figure; imagesc(img_first_photon(:,1:8000,:));
set(gca, 'FontSize', 18);

three_bounce_length = dataset.t0 + first_photon_idx*dataset.deltat;
distance = nan(4,size(dataset.laserPos,1));
s = dataset.laserPos';
light = dataset.cameraPos';

d1 = norm(dataset.cameraOrigin - dataset.cameraPos);
for i = 1:size(s,2)
    d4 = norm(dataset.laserOrigin - dataset.laserPos(i,:));
    d2_d3 = three_bounce_length(i,:) - d1-d4;
    
    for j = 1:size(label,2),
        g = label(i,j);
        if isnan(g),
            continue;
        end
        distance(g, i) = d2_d3(j);
    end
end


save('results/problem_cluster', 'distance', 'light', 's');
