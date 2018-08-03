function [best_fit, best_err, best_inlier] = ransac_plane(x,iteration_num, threshold, inlier_num)
n = 3;
best_fit = [];
best_err = realmax;
best_inlier = [];
for iteration = 1:iteration_num,
    
    maybe_inlier = randsample(size(x,2), n);
    while line_check(x(:,maybe_inlier)) == 1,
        maybe_inlier = randsample(size(x,2), n);
    end
    
    [maybe_l] = plane_fit(x(:,maybe_inlier));
    err = abs(maybe_l(:,2)'*(x - repmat(maybe_l(:,1),1,size(x,2))));
    
    also_inlier = find(err < threshold);
    
    if length(also_inlier) > inlier_num,
        [better_l] = plane_fit(x(:,also_inlier));
        
        err = better_l(:,2)'*(x(:,also_inlier) - repmat(better_l(:,1),1,length(also_inlier)));

        mse = err*err'/length(also_inlier);
        if mse < best_err,
            best_fit = better_l;
            best_err = mse;
            best_inlier = also_inlier;
        end
    end
end

end

function [l] = plane_fit(X)

p = mean(X,2);
R = bsxfun(@minus,X,p);
[V,D] = eig(R*R');
n = V(:,1);
l = [p n];
end

function [check] = line_check(sensor)
threshold = 0.01;
if cross(sensor(:,2) - sensor(:,1), sensor(:,3) - sensor(:,1)) < threshold
    check = 0;
else
    check = 1;
end
end