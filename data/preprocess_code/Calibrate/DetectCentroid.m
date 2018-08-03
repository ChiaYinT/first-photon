function centroid=DetectCentroid(I,threshold)
% path = 'DATA/Measurements/8-4-2016_NoObject';
% fileName = (strcat(path,'/X_0_Y_0.png'));
% I = rgb2gray(imread(fileName));
I(1:3,:)=0;
I(:,1:3)=0;

[y,x,~] = find(I>200);

centroid = [mean(x) mean(y)];

% imshow(I,[]);hold on
% plot(y_mean,x_mean,'r+');