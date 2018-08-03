clear; close all; clc;

folder_name = 'pair1';
N = 10000;

unit_time = 0.01;

sz = 50;    % length of gaussFilter vector
sigma = ceil(sz/2);
x = linspace(-sz / 2, sz / 2, sz);
gaussFilter = exp(-x .^ 2 / (2 * sigma ^ 2));
gaussFilter = gaussFilter / sum (gaussFilter);

edge_filter = [ones(1,sz) -ones(1,sz)];

masked_time = 430;


integration_time_interval = [0.01 0.1 1 10];

figure;
for t = 1:size(integration_time_interval,2)
    integration_time = integration_time_interval(t);
    
    m = integration_time/unit_time;
    
    first_peak = zeros(1,N/m);
    second_peak = zeros(1,N/m);
    first_photon = zeros(1,N/m);
    second_photon = zeros(1,N/m);
    
    aggregated_data = zeros(1,3215);
    for i = 1:N,
        if mod(i,100) == 1,
            fprintf('t = %d, i=%d\n', t, i);
        end
        load([folder_name '/' num2str(i) '.mat']);
        aggregated_data = aggregated_data + data;
        if mod(i,m) == 0,
            aggregated_data = aggregated_data/integration_time;
            aggregated_data(1:masked_time) = 0;
            subplot(size(integration_time_interval,2),2,2*(t-1)+1);
            plot(aggregated_data, 'b-', 'LineWidth', 1);
            
            data_smoothed = conv(aggregated_data, gaussFilter, 'same');
            subplot(size(integration_time_interval,2),2,2*t);
            plot(data_smoothed, 'b-', 'LineWidth', 1); hold on;
            %figure;
            %subplot(2,1,1); plot(aggregated_data);
            %subplot(2,1,2); plot(data_smoothed); hold on;
            

            %[pk,ls] = findpeaks(data_smoothed,'MinPeakDistance',500);
            %[Y,I] = sort(pk, 'descend');
            %plot(ls(I(1:2)),pk(I(1:2)),'gx');
            data_smoothed_edge = conv(data_smoothed, edge_filter, 'same');
            data_smoothed_edge(1:masked_time+50) = 0;
            data_smoothed(1:masked_time) = 0;
            [pk,ls] = findpeaks(data_smoothed,'MinPeakDistance',500);
            [Y,I] = sort(pk, 'descend');
            
            first_peak(1,i/m) = min(ls(I(1:2)));
            second_peak(1,i/m) = max(ls(I(1:2)));
            
            plot(ls(I(1:2)),pk(I(1:2)),'gx', 'MarkerSize', 8);
            data_smoothed_edge = conv(data_smoothed, edge_filter, 'same');
            data_smoothed_edge(1:masked_time+50) = 0;
            
            first_photon(1,i/m) = find(data_smoothed_edge > 5000,1);
            data_smoothed_edge(1:first_photon+500) = 0;
            second_photon(1,i/m) = find(data_smoothed_edge > 5000,1);
            
            plot(first_photon(1,i/m), data_smoothed(1,first_photon(1,i/m)),'ro', 'MarkerSize', 8);
            plot(second_photon(1,i/m), data_smoothed(1,second_photon(1,i/m)),'ro', 'MarkerSize', 8);
            
            aggregated_data = zeros(1,3215);
            set(gca, 'FontSize', 15)
            %legend('transient', 'peak', 'first photon');
            break;
        end
    end
    
    
end
