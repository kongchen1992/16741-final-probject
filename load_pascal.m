function images = load_pascal(class, filename)
data_path;
load(fullfile(PASCAL3D_dir, 'Annotations', ...
    sprintf('%s_pascal', class), [filename, '.mat']));
load(fullfile(Anchor_dir, class2uid(class), 'anchor_names.mat'));

images = {};
for iobj = 1:numel(record.objects)
    if strcmp(record.objects(iobj).class, class)
        image.class = class;
        image.filename = filename;
        model_idx = record.objects(iobj).cad_index;
        image.cad = load_model(class, model_idx, 'dataset', 'pascal', ...
            'load_info', false);

        % add anchor info
        image.anchors = zeros(numel(anchor_names), 2);
        for ianchor = 1:numel(anchor_names)
            anchor = record.objects(iobj).anchors.(anchor_names{ianchor});
            if isempty(anchor.location)
                image.anchors(ianchor, :) = nan;
            else
                if anchor.location(1) > 0 && anchor.location(2) > 0
                    image.anchors(ianchor, :) = anchor.location;
                else
                    image.anchors(ianchor, :) = nan;
                end
            end
        end

        % add image
        image_file = fullfile(PASCAL3D_dir, 'Images', ...
            sprintf('%s_pascal', class), [filename, '.jpg']);
        image.image = imread(image_file);

        images = [images; image];
    end
end
