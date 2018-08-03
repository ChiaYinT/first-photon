function Q = Organize(P)

Q = P; % intialization

[~, indices] = sort(P(:,1));
P_x = P(indices(:,1),:); %sort x-coordinates in increasing order

% sort y-coordinates in increasing order for each four points
rows = 11;
cols = 7;

for i=1:cols % Hardcoded for 5X4 checkerBoard
    [~, indices] = sort(P_x((i-1)*rows+1:i*rows,2));
    Q((i-1)*rows+1:i*rows,:) = P_x((i-1)*rows+indices,:);
end
% 
% for i=1:5 % Hardcoded for 5X4 checkerBoard
%     [~, indices] = sort(P_x((i-1)*4+1:i*4,2));
%     Q((i-1)*4+1:i*4,:) = P_x((i-1)*4+indices,:);
% end
