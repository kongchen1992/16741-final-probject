function draw_model(object, varargin)    
% The function to draw 3D model
%
%   To draw a single model on current axis, run
%       draw_model(model, 'PropertyName', 'PropertyValue', ...);
%
%   To draw a model with ground truth on a new figure, run
%       draw_model(model, 'groundtruth', I, ...);

ip = inputParser;
addOptional(ip, 'EdgeColor', 'b');
addOptional(ip, 'FaceColor', [1, 1, 1]);
addOptional(ip, 'AnchorColor', 'r');
addOptional(ip, 'AnchorMarker', '*');
addOptional(ip, 'MarkerSize', 3);
addOptional(ip, 'FaceAlpha', 0.5);
addOptional(ip, 'projection', []);
addOptional(ip, 'axisLimit', []);
addOptional(ip, 'groundtruth', []);
addOptional(ip, 'EdgeAlpha', 1);
addOptional(ip, 'ColorMap', []);
addOptional(ip, 'rotation', []);
addOptional(ip, 'AnchorNum', false);
parse(ip, varargin{:});
option = ip.Results;

if ~isempty(option.projection)
    if size(option.projection.rotation, 1) == 2
        rotation = zeros(3);
        rotation(1:2, :) = option.projection.rotation;
        rotation(3, :) = cross(rotation(1, :), rotation(2, :));
        if det(rotation) < 0
            rotation(3, :) = -rotation(3, :);
        end
    else
        rotation = option.projection.rotation;
    end
    object.vtx = object.vtx*rotation';
end

if ~isempty(option.rotation)
    object.vtx = object.vtx*option.rotation';
end

if ~isempty(option.groundtruth)
    figure; subplot(1, 2, 1);
end

if isempty(option.ColorMap)
    h = trimesh(object.mesh, object.vtx(:, 1), object.vtx(:, 2), object.vtx(:, 3));
    h.EdgeColor = option.EdgeColor;
    h.FaceColor = option.FaceColor;
else
    h = trisurf(object.mesh, object.vtx(:, 1), object.vtx(:, 2), ...
        object.vtx(:, 3), option.ColorMap);
    colormap(winter);
    %h.EdgeColor = 'none';
    option.EdgeAlpha = 0.5;
end
h.EdgeAlpha = option.EdgeAlpha;
h.FaceAlpha = option.FaceAlpha;

xlabel('x');
ylabel('y');
zlabel('z');
axis equal;
if ~isempty(option.axisLimit)
    axis(option.axisLimit);
end
hold on;
plot3(object.vtx(object.anchor(object.anchor~=0), 1),...
    object.vtx(object.anchor(object.anchor~=0), 2), ...
    object.vtx(object.anchor(object.anchor~=0), 3),...
    'LineStyle', 'none', ...
    'color', option.AnchorColor, ...
    'marker', option.AnchorMarker,...
    'MarkerSize', option.MarkerSize);
%title(object.model_info.uid);
if option.AnchorNum
    for i = 1:numel(object.anchor)
        if object.anchor(i) == 0
            continue;
        end
        txt = num2str(i);
        text(object.vtx(object.anchor(i), 1),...
             object.vtx(object.anchor(i), 2), ...
             object.vtx(object.anchor(i), 3), ...
            txt, 'FontSize', 40, 'Color', 'r');
    end
end

if ~isempty(option.projection) || ~isempty(option.rotation)
    view(2);
end

if ~isempty(option.groundtruth)
    subplot(1, 2, 2);
    projection.rotation = option.groundtruth.rotation;
    projection.scale = 1;
    projection.translation = [0; 0];
    draw_model(option.groundtruth.cad, 'projection', projection);
end

drawnow;
