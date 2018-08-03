function [first_photon] = find_first_photon(data, opt)
figure(1); subplot(2,1,1); plot(data);
if isfield(opt, 'mask_bin')
    mask_bin = opt.mask_bin;
else
    [mask_bin,~] = ginput(1);    
    mask_bin
end
mask_bin = ceil(mask_bin);
[data_smoothed, data_edge]  = preprocess_data(data, mask_bin);
imagesc(data_smoothed);

data_edge = bsxfun(@times, data_edge, ([1:size(data_smoothed,2)]/2000+1).^2);

if isfield(opt, 'item_num')
    item_num = opt.item_num;
else
    item_num = input('number of item = ');
end
first_photon = nan(size(data,1),item_num);

I = data_smoothed;


if isfield(opt, 'edge_threshold')
    edge_threshold = opt.edge_threshold;
else
    edge_threshold = 80000;
end

if isfield(opt, 'show_transient')
    show_transient = opt.show_transient;
else
    show_transient = 0;
end

if show_transient == 1,
    figure(2);
end
for i = 1:size(data_edge,1)
    for m = 1:item_num
        %[pk,ls] = findpeaks(data_smoothed(i,:),'MinPeakDistance',500);
        %[Y,I] = sort(pk, 'descend');
        
        %first_peak_gt = min(ls(I(1:2)));
        %second_peak_gt = max(ls(I(1:2)));
        
        
        
        idx = find(data_edge(i,:) > edge_threshold,1);
        if show_transient == 1,
            subplot(3,1,1); plot(I(i,:));hold on;
            plot(mask_bin,0,'rx');
            if ~isempty(idx),
                plot(idx, I(i,idx), 'kx');
            end
            hold off;
            subplot(3,1,2); plot(data_edge(i,:));
        end
        
        
        if ~isempty(idx),
            first_photon(i,m) = idx;
            I(i,first_photon(i,m):first_photon(i,m) + 30) = nan;
        end
        

        idx = find(data_edge(i,idx+100:end) < edge_threshold/10, 1)+idx+100;
        data_edge(i,1:idx+50) = 0;

    end
end
figure(1); subplot(2,1,2); h = imagesc(I);
set(h, 'alphadata', ~isnan(I));
end


function [data_smoothed, data_edge] = preprocess_data(data, mask_bin)
data_smoothed = zeros(size(data));
data_edge = zeros(size(data));

data(:,1:mask_bin) = 0;
data(:,end-200:end) = 0;

sz = 200;    % length of gaussFilter vector
sigma = ceil(sz/2);
x = linspace(-sz / 2, sz / 2, sz);
gaussFilter = exp(-x .^ 2 / (2 * sigma ^ 2));
gaussFilter = gaussFilter / sum (gaussFilter);
edge_filter = [ones(1,sz) -ones(1,sz)];

for i = 1:size(data,1)
    data_smoothed(i,:) = conv(data(i,:), gaussFilter, 'same');
    data_smoothed(i,:) = data_smoothed(i,:) - data_smoothed(i,mask_bin+sz);

    data_smoothed(i,:) = data_smoothed(i,:)/max(data_smoothed(i,:));
    data_edge(i,:) = conv(data_smoothed(i,:), edge_filter, 'same');
end

data_edge(:,1:mask_bin+100) = 0;
data_edge(:,end-200:end) = 0;
end