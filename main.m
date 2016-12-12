class = 'bottle';
%filenames = img_of_cls(class, false);
filenames = {'2008_000015', '2008_000911', '2008_002864', ...
    '2008_003076', '2008_005812'};
obj_index = {1, 1, [1, 2], 2, 1};
for ifilename = 1:numel(filenames)
    filename = filenames{ifilename};
    Is = load_pascal(class, filename);
    for iI = 1:numel(obj_index{ifilename})
        issave = 'n';
        while ~strcmp(lower(issave), 'y')
            I = Is{obj_index{ifilename}(iI)};
            if numel(find(~isnan(I.anchors(:, 1)))) < 4
                continue;
            end
            fprintf('class: %s, filename: %s, object index: %d\n', ...
                class, filename, iI);
            [bestCAD, bestProjection] = select_cad(I);
            fig1 = figure(1);
            hold off;
            imshow(I.image);
            fig2 = figure(2);
            hold off;
            draw_landmarks(I, 'model', bestCAD, ...
                'projection', bestProjection, 'show_connection', true, ...
                'MarkerSize', 40, 'LineWidth', 3, 'LineColor', 'r', ...
                'FaceAlpha', 0.1, 'silhouette', false);
            fig3 = figure(3);
            hold off;
            draw_model(bestCAD);

            [CPF, WF, CPs] = grasp_object(bestCAD);
            % draw contact screws
            fig4 = figure(4);
            hold off;
            draw_model(bestCAD);
            fig4 = figure(4);
            drawContactScrew(CPF, WF);
            fig4 = figure(4);
            axis off;
            prompt = 'Save? Y/N [N]: ';
            issave = input(prompt,'s');
            if isempty(issave)
                issave = 'N';
            end
            if strcmp(lower(issave), 'y')
                saveas(fig1, sprintf('../%s%s%d_1.png', class, filename, ...
                    obj_index{ifilename}(iI)));
                saveas(fig2, sprintf('../%s%s%d_2.png', class, filename, ...
                    obj_index{ifilename}(iI)));
                saveas(fig3, sprintf('../%s%s%d_3.png', class, filename, ...
                    obj_index{ifilename}(iI)));
                fig4 = figure(4);
                OptionZ.FrameRate=15;
                OptionZ.Duration=5.5;
                OptionZ.Periodic=true;
                CaptureFigVid([-20,10;-110,10;-190,80;-290,10;-380,10], ...
                    sprintf('../%s%s%d', class, filename, ...
                    obj_index{ifilename}(iI)), OptionZ)
            end
        end
    end
end
