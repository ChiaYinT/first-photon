clear; clc; close all


first_photon_folder =  '../../../data/dataset3-first_photon/MultiObject/';
transient_folder = strrep(first_photon_folder, 'first_photon', 'transient_data');

output_folder = 'result-cluster/';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end


file = dir(first_photon_folder);
for f = 1:size(file,1)
    if length(file(f,1).name)>2
        name = file(f,1).name;
        name
        
        first_photon_file = [first_photon_folder name];
        load(first_photon_file);
        
        item_num = size(first_photon,2);
        transient_file = [transient_folder name];
        load(transient_file);
        
        result_file = [output_folder name];
        label = nan(size(first_photon));
        [Y, idx] = max(sum(~isnan(first_photon),2));
        label(idx,:) = 1:item_num;
        group_color = hsv(item_num);
        distance_sensor = dist(vs');
        [disc] = graphtraverse(sparse(distance_sensor < 0.1), idx);
        
        first_photon_label = nan(size(first_photon));
        first_photon_label(idx,:) = 1:item_num;
        
        img_first_photon = ones(size(data,1), size(data,2),3);
        for i = 2:size(first_photon,1),
            idx = disc(i);
            neighboring_idx = find(distance_sensor(:,idx) < 0.1);
            neighboring_idx(neighboring_idx==idx) = [];
            neighboring_first_photon_idx = first_photon(neighboring_idx,:);
            neighboring_first_photon_idx = neighboring_first_photon_idx(:);
            neighboring_label = label(neighboring_idx,:);
            neighboring_label = neighboring_label(:);
            neighboring_first_photon_idx = neighboring_first_photon_idx(~isnan(neighboring_label));
            neighboring_label = neighboring_label(~isnan(neighboring_label));
            
            for j = 1:item_num,
                tof = first_photon(idx,j);
                if isnan(tof) || isempty(neighboring_first_photon_idx)
                    break;
                end
                [Y,I] = min(abs(neighboring_first_photon_idx - tof));
                label(idx,j) = neighboring_label(I);
                neighboring_first_photon_idx = neighboring_first_photon_idx(neighboring_label~=label(idx,j));
                neighboring_label = neighboring_label(neighboring_label~=label(idx,j));
                img_first_photon(idx, tof:tof+50,:) = repmat(reshape(group_color( label(idx,j),:),1,1,3),1,51);
                
                first_photon_label(idx,label(idx,j)) = first_photon(idx,j);
                
            end
            
        end
        
        figure; imagesc(img_first_photon);
        
        save(result_file, 'first_photon_label');
        
        
    end
end
