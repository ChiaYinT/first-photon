function [ H ] = DLT( X, X_)
%DLT Summary of this function goes here
%   Detailed explanation goes here
% X_ = X * H
X = [X ones(length(X),1)];
X_ = [X_ ones(length(X_),1)];

% H = X * Y' * inv(Y*Y');
% H = inv(Y'*Y) * Y' * X;

A = zeros(2*size(X,1),9);

A(1:2:end,1:3) = X;
A(2:2:end,4:6) = X;

A(1:2:end,7:9) = -[X(:,1).*X_(:,1) X(:,2).*X_(:,1) X_(:,1)] ;
A(2:2:end,7:9) = -[X(:,1).*X_(:,2) X(:,2).*X_(:,2) X_(:,2)] ;

[U S V] = svd(A);

H = reshape(V(:,end)/V(end,end),[3 3]);

end

