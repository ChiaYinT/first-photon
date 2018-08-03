function [Points,boardSize] = GetCheckerBoardPoints( I )
%GETCHECKERBOARDPOINTS Summary of this function goes here
%   Detailed explanation goes here

s = size(I);

%% 1
I_s = I( 1:s(1)/2, 1:s(2)/2 );
% I_s = I;
[P,boardSize,~] = detectCheckerboardPoints(I_s);
P = Organize(P);
Points = P;

% 2
I_s = I( s(1):-1:s(1)/2+1, 1:s(2)/2 );
[P,~,~] = detectCheckerboardPoints(I_s);
P(:,2) = s(1)-P(:,2); 
P = Organize(P);
Points = [Points;P];

% % 3
I_s = I( 1:s(1)/2, s(2)/2+1:s(2) );
[P,~,~] = detectCheckerboardPoints(I_s);
P(:,1) = s(2)/2+P(:,1);
P = Organize(P);
Points = [Points;P];
% 
% % 4
% I_s = I( s(1):-1:s(1)/2+1, s(2):-1:s(2)/2+1 );
% [P,~,~] = detectCheckerboardPoints(I_s);
% P(:,1) = s(2)-P(:,1);
% P(:,2) = s(1)-P(:,2);
% P = Organize(P);
% Points = [Points;P];

I_s = I( s(1)/2+1:s(1), s(2)/2+1:s(2) );
[P,~,~] = detectCheckerboardPoints(I_s);
P(:,1) = s(2)/2+P(:,1);
P(:,2) = s(1)/2+P(:,2);
P = Organize(P);
Points = [Points;P];

end