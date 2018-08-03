clear; clc; close all;

folder_name = 'pair2';
N = 10000;

unit_time = 0.01;

sz = 50;    % length of gaussFilter vector
sigma = ceil(sz/2);
x = linspace(-sz / 2, sz / 2, sz);
gaussFilter = exp(-x .^ 2 / (2 * sigma ^ 2));
gaussFilter = gaussFilter / sum (gaussFilter);

edge_filter = [ones(1,sz) -ones(1,sz)];

masked_time = 430;


transient_gt = zeros(1,3215);
for i = 1:N,
    if mod(i,100) == 1,
        fprintf('i=%d\n', i);
    end
    load([folder_name '/' num2str(i) '.mat']);
    transient_gt = transient_gt + data;
end

transient_gt = transient_gt/(N*unit_time);
transient_gt(1:masked_time) = 0;

data_smoothed = conv(transient_gt, gaussFilter, 'same');
[pk,ls] = findpeaks(data_smoothed,'MinPeakDistance',500);
[Y,I] = sort(pk, 'descend');

first_peak_gt = min(ls(I(1:2)));
second_peak_gt = max(ls(I(1:2)));

data_smoothed_edge = conv(data_smoothed, edge_filter, 'same');
data_smoothed_edge(1:masked_time+50) = 0;

first_photon_gt = find(data_smoothed_edge > 5000,1);
data_smoothed_edge(1:first_photon_gt+500) = 0;
second_photon_gt = find(data_smoothed_edge > 5000,1);


integration_time_interval = [0.01 0.02 0.05 0.1 0.2 0.5 1 2 5 10];
mean_first_photon = zeros(1,size(integration_time_interval,2));
mean_second_photon = zeros(1,size(integration_time_interval,2));
var_first_photon = zeros(1,size(integration_time_interval,2));
var_second_photon = zeros(1,size(integration_time_interval,2));
mean_first_peak = zeros(1,size(integration_time_interval,2));
mean_second_peak = zeros(1,size(integration_time_interval,2));
var_first_peak = zeros(1,size(integration_time_interval,2));
var_second_peak = zeros(1,size(integration_time_interval,2));
mean_transient_snr = zeros(1,size(integration_time_interval,2));
var_transient_snr = zeros(1,size(integration_time_interval,2));

mean_first_photon_snr = zeros(1,size(integration_time_interval,2));
first_photon_snr = cell(1,size(integration_time_interval,2));
mean_second_photon_snr = zeros(1,size(integration_time_interval,2));
second_photon_snr = cell(1,size(integration_time_interval,2));
mean_first_peak_snr = zeros(1,size(integration_time_interval,2));
first_peak_snr = cell(1,size(integration_time_interval,2));
mean_second_peak_snr = zeros(1,size(integration_time_interval,2));
second_peak_snr = cell(1,size(integration_time_interval,2));

for t = 1:size(integration_time_interval,2)
    integration_time = integration_time_interval(t);
    
    m = integration_time/unit_time;
    
    first_peak = zeros(1,N/m);
    second_peak = zeros(1,N/m);
    first_photon = zeros(1,N/m);
    second_photon = zeros(1,N/m);
    transient_snr = zeros(1,N/m);
    first_peak_snr_tmp = zeros(1,N/m);
    second_peak_snr_tmp = zeros(1,N/m);
    first_photon_snr_tmp = zeros(1,N/m);
    second_photon_snr_tmp = zeros(1,N/m);
    
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
            transient_snr(1,i/m) = snr(transient_gt, transient_gt-aggregated_data);
            
            data_smoothed = conv(aggregated_data, gaussFilter, 'same');
            %figure;
            %subplot(2,1,1); plot(aggregated_data);
            %subplot(2,1,2); plot(data_smoothed); hold on;
            %plot(ls(I(1:2)),pk(I(1:2)),'ro');
            [pk,ls] = findpeaks(data_smoothed,'MinPeakDistance',500);
            [Y,I] = sort(pk, 'descend');
            
            first_peak(1,i/m) = min(ls(I(1:2)));
            second_peak(1,i/m) = max(ls(I(1:2)));
            first_peak_snr_tmp(1,i/m) = snr(first_peak_gt,first_peak_gt-first_peak(1,i/m));
            second_peak_snr_tmp(1,i/m) = snr(second_peak_gt,second_peak_gt-second_peak(1,i/m));
            %plot(ls(I(1:2)),pk(I(1:2)),'ro');
            data_smoothed_edge = conv(data_smoothed, edge_filter, 'same');
            data_smoothed_edge(1:masked_time+50) = 0;
            
            first_photon(1,i/m) = find(data_smoothed_edge > 5000,1);
            data_smoothed_edge(1:first_photon(1,i/m)+500) = 0;
            second_photon(1,i/m) = find(data_smoothed_edge > 5000,1);
            first_photon_snr_tmp(1,i/m) = snr(first_photon_gt,first_photon_gt-first_photon(1,i/m));
            second_photon_snr_tmp(1,i/m) = snr(second_photon_gt,second_photon_gt-second_photon(1,i/m));

            %plot(first_photon(1,i/m), data_smoothed(1,first_photon(1,i/m)),'gx');
            %plot(second_photon(1,i/m), data_smoothed(1,second_photon(1,i/m)),'gx');
            
            aggregated_data = zeros(1,3215);
        end
    end
    
    mean_first_photon(1,t) = mean(first_photon);
    mean_second_photon(1,t) = mean(second_photon);
    var_first_photon(1,t) = var(first_photon);
    var_second_photon(1,t) = var(second_photon);

    
    tmp = repmat(first_photon_gt,1,size(first_photon,2));
    mean_first_photon_snr(1,t) = snr(tmp, tmp - first_photon );
    tmp =  repmat(second_photon_gt,1,size(second_photon,2));
    mean_second_photon_snr(1,t) = snr(tmp, tmp - second_photon );

    %first_peak_snr(1,t) = first_peak_snr_tmp;
    %second_peak_snr(1,t) = second_peak_snr_tmp;
    first_photon_snr{1,t} = first_photon_snr_tmp;
    second_photon_snr{1,t} = second_photon_snr_tmp; 
    
    mean_first_peak(1,t) = mean(first_peak);
    mean_second_peak(1,t) = mean(second_peak);
    var_first_peak(1,t) = var(first_peak);
    var_second_peak(1,t) = var(second_peak);
    
    %mean_first_peak_snr(1,t) = mean(first_peak_snr);
    %mean_second_peak_snr(1,t) = mean(second_peak_snr);
    %var_first_peak_snr(1,t) = var(first_peak_snr);
    %var_second_peak_snr(1,t) = var(second_peak_snr);
    
    mean_transient_snr(1,t) = mean(transient_snr);
    var_transient_snr(1,t) = var(transient_snr);
end

save(folder_name, 'integration_time_interval', 'mean_first_photon', 'mean_second_photon', 'var_first_photon', 'var_second_photon',...
    'mean_first_peak', 'mean_second_peak', 'var_first_peak', 'var_second_peak', 'mean_transient_snr', 'var_transient_snr');

figure; hold on;
set(0, 'DefaultAxesFontSize', 18);
errorbar(integration_time_interval,mean_first_photon,sqrt(var_first_photon),'bo-', 'LineWidth', 2, 'MarkerSize', 8);
set(gca,'XScale','log');
xlabel('integration time (s)');
ylabel('estimation (bin#)');
xlim([10^-2.3 20]);
set(gca, 'XTick', 10.^(-2:2))
plot([10^-2.3 20], [mean_first_photon(end) mean_first_photon(end)], 'k--', 'LineWidth', 2);

figure; hold on;
set(0, 'DefaultAxesFontSize', 18);
errorbar(integration_time_interval,mean_second_photon,sqrt(var_second_photon),'bo-', 'LineWidth', 2, 'MarkerSize', 8);
set(gca,'XScale','log');
xlabel('integration time (s)');
ylabel('estimation (bin#)');
xlim([10^-2.3 20]);
set(gca, 'XTick', 10.^(-2:2))
plot([10^-2.3 20], [mean_second_photon(end) mean_second_photon(end)], 'k--', 'LineWidth', 2);

figure; hold on;
set(0, 'DefaultAxesFontSize', 18);
errorbar(integration_time_interval,mean_first_peak,sqrt(var_first_peak),'bo-', 'LineWidth', 2, 'MarkerSize', 8);
set(gca,'XScale','log');
xlabel('integration time (s)');
ylabel('estimation (bin#)');
xlim([10^-2.3 20]);
set(gca, 'XTick', 10.^(-2:2))
plot([10^-2.3 20], [mean_first_peak(end) mean_first_peak(end)], 'k--', 'LineWidth', 2);


figure; hold on;
set(0, 'DefaultAxesFontSize', 18);
errorbar(integration_time_interval,mean_second_peak,sqrt(var_second_peak),'bo-', 'LineWidth', 2, 'MarkerSize', 8);
set(gca,'XScale','log');
xlabel('integration time (s)');
ylabel('estimation (bin#)');
xlim([10^-2.3 20]);
set(gca, 'XTick', 10.^(-2:2))
plot([10^-2.3 20], [mean_second_peak(end) mean_second_peak(end)], 'k--', 'LineWidth', 2);

filename = ['data_' folder_name];
save(filename, 'integration_time_interval', 'mean_transient_snr', 'var_transient_snr', 'mean_first_photon_snr', 'mean_second_photon_snr', 'first_photon_snr', 'second_photon_snr');
figure; hold on;
set(0, 'DefaultAxesFontSize', 18); 
errorbar(integration_time_interval,mean_transient_snr,sqrt(var_transient_snr),'ro-','LineWidth', 2, 'MarkerSize', 8);
plot(integration_time_interval,mean_first_photon_snr,'g*-.','LineWidth', 2, 'MarkerSize', 8);
plot(integration_time_interval,mean_second_photon_snr,'bv--','LineWidth', 2, 'MarkerSize', 8);
for t = 1:length(integration_time_interval),
    tmp = first_photon_snr{1,t};
    plot(repmat(integration_time_interval(t),1,size(tmp,2)), tmp , 'g*', 'MarkerSize', 8);
    tmp = second_photon_snr{1,t};
    plot(repmat(integration_time_interval(t),1,size(tmp,2)), tmp , 'bv', 'MarkerSize', 8);
end


set(gca,'XScale','log');
%title('snr');
xlabel('integration time (s)');
ylabel('SNR (dB)');
xlim([10^-2.3 20]);
set(gca, 'XTick', 10.^(-2:2));

legend('transient', 'first photon of first peak', 'first photon of second peak', 'Location', 'eastoutside');
