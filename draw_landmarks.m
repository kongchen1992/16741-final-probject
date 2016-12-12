function draw_landmarks(image, varargin)
ip = inputParser;
addOptional(ip, 'estimate', []);
addOptional(ip, 'model', []);
addOptional(ip, 'projection', []);
addOptional(ip, 'show_connection', false, @islogical);
addOptional(ip, 'flip', true, @islogical);
addOptional(ip, 'silhouette', true, @islogical);
addOptional(ip, 'landmark', true, @islogical);
addOptional(ip, 'text', false, @islogical);
addOptional(ip, 'MarkerSize', 10, @isnumeric);
addOptional(ip, 'LineWidth', 1, @isnumeric);
addOptional(ip, 'LineColor', 'g');
addOptional(ip, 'FontSize', 20, @isnumeric);
addOptional(ip, 'FaceAlpha', 0.1, @isnumeric);
parse(ip, varargin{:}); 
option = ip.Results;
if ~isempty(option.model)
    imshow(image.image);
    hold on;
    if option.silhouette
        Hmask = imshow(255*ones(size(image.image, 1), size(image.image, 2)));
        Hmask.AlphaData = image.segmentation*0.8;
    end

    % draw model
    model = option.model;
    scale = option.projection.scale;
    rotation = option.projection.rotation;
    translation = option.projection.translation;
    vertex = bsxfun(@plus, scale*rotation*model.vtx', translation);
    face = model.mesh;
    if option.flip
        vertex = im2xy(vertex, size(image.image));
    end
    patch('Vertices', vertex', 'Faces', face, ...
        'FaceColor', 'b', 'FaceAlpha', option.FaceAlpha, 'EdgeColor', 'none');
    
    % draw the connection between landmarks and estimation
    if option.show_connection
        % draw ground truth landmarks
        anchors = image.anchors(~isnan(image.anchors(:, 1)), :)';
        plot(anchors(1, :), anchors(2, :), 'g.', 'MarkerSize', option.MarkerSize, ...
            'LineWidth', option.LineWidth);
        
        % draw estimated landmarks
        anchors = model.vtx(model.anchor, :);
        anchor2d = bsxfun(@plus, scale*rotation*anchors', translation);
        if option.flip
            anchor2d = im2xy(anchor2d, size(image.image));
        end
        plot(anchor2d(1, :), anchor2d(2, :), 'r.', 'MarkerSize', option.MarkerSize, ...
            'LineWidth', option.LineWidth);

        for i = 1:size(anchor2d, 2)
            if ~isnan(image.anchors(i, 1))
                plot([image.anchors(i, 1), anchor2d(1, i)], ...
                    [image.anchors(i, 2), anchor2d(2, i)], '-', ...
                    'LineWidth', option.LineWidth, 'Color', option.LineColor);
            end
        end
    else
        % draw ground truth landmarks
        anchors = image.anchors(~isnan(image.anchors(:, 1)), :)';
        plot(anchors(1, :), anchors(2, :), 'go', 'MarkerSize', option.MarkerSize, ...
            'LineWidth', option.LineWidth);
        
        % draw estimated landmarks
        anchors = model.vtx(model.anchor, :);
        anchor2d = bsxfun(@plus, scale*rotation*anchors', translation);
        if option.flip
            anchor2d = im2xy(anchor2d, size(image.image));
        end
        plot(anchor2d(1, :), anchor2d(2, :), 'r*', 'MarkerSize', option.MarkerSize, ...
            'LineWidth', option.LineWidth);
    end

elseif ~isempty(option.estimate)
    imshow(image.image);
    hold on;
    if option.landmark
        anchors = image.anchors(~isnan(image.anchors(:, 1)), :)';
        plot(anchors(1, :), anchors(2, :), 'go', 'Markersize', option.MarkerSize, ...
        'LineWidth', option.LineWidth);
    end
    estimate = option.estimate;
    plot(estimate(1, :), estimate(2, :), 'r*', 'MarkerSize', option.MarkerSize, ...
        'LineWidth', option.LineWidth);

else
    imshow(image.image);
    hold on;
    if option.silhouette
        Hmask = imshow(255*ones(size(image.image, 1), size(image.image, 2)));
        Hmask.AlphaData = image.segmentation*0.8;
    end
    if option.landmark
        anchors = image.anchors(~isnan(image.anchors(:, 1)), :)';
        plot(anchors(1, :), anchors(2, :), 'g.', 'Markersize', option.MarkerSize, ...
        'LineWidth', option.LineWidth);
    end
    if option.text
        for i = 1:size(image.anchors, 1)
            if isnan(image.anchors(i, 1))
                continue;
            end
            txt = num2str(i);
            text(image.anchors(i, 1),...
                 image.anchors(i, 2), ...
                 txt, 'FontSize', option.FontSize, 'Color', 'r');
        end
    end
end
