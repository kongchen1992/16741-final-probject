function [bestCAD, bestProjection] = select_cad(I)
% load CAD models
class = 'bottle';
data_path;
cad_file = fullfile(PASCAL3D_dir, 'CAD', [class, '.mat']);
mat_content = load(cad_file);
num_cads = numel(mat_content.(class));
cads = cell(num_cads, 1);
anchor_names = anchor_of_cls(class);
for i = 1:num_cads
    cads{i}.vtx = mat_content.(class)(i).vertices;
    cads{i}.mesh = mat_content.(class)(i).faces;
    num_anchor = numel(anchor_names);
    cads{i}.anchor = zeros(1, num_anchor);
    for j = 1:num_anchor
        anchor_coor = mat_content.(class)(i).(anchor_names{j});
        dist = pdist2(anchor_coor, cads{i}.vtx);
        [~, anchor] = min(dist);
        cads{i}.anchor(j) = anchor;
    end
end

% Use Orthogonal Procrustes closed-form solution to solve landmark registration problem.
bestC = 0;
bestProjection = [];
bestProjErr = inf;
for i = 1:num_cads
    mask = (~isnan(I.anchors(:, 1)));
    % adjust from image coor
    W_0 = im2xy(I.anchors(mask, :)', size(I.image));
    % normalize W
    meanW = mean(W_0, 2);
    W = bsxfun(@minus, W_0, meanW);
    scaleW = mean(sqrt(sum(W.^2, 1)))/sqrt(2);
    W = W/scaleW;
    if ~isempty(find(cads{i}.anchor(mask)==0, 1))
        continue;
    end
    X_0 = cads{i}.vtx(cads{i}.anchor(mask), :)';
    % normalize X
    meanX = mean(X_0, 2);
    X = bsxfun(@minus, X_0, meanX);
    scaleX = mean(sqrt(sum(X.^2, 1)))/sqrt(2);
    X = X/scaleX;

    M = W*X'/(X*X');
    [Usvd, Ssvd, Vsvd] = svd(M, 'econ');
    projection.scale = scaleW/scaleX*sum(diag(Ssvd))/2;
    projection.rotation = Usvd*Vsvd';
    projection.translation = meanW - projection.scale*projection.rotation*meanX;

    % compure cost
    pX = bsxfun(@plus, projection.scale*projection.rotation*X_0, ...
        projection.translation);
    projErr = mean(sqrt(sum((W_0 - pX).^2, 1)));
    if projErr < bestProjErr
        fprintf('BestC = %d, BestProjErr = %.4f\n', i, projErr);
        bestC = i;
        bestProjection = projection;
        bestProjErr = projErr;
    end
end
bestCAD = cads{bestC};
