% 11-17-2018
% changed to 6 subplots
% 11-16-2018
% for paper revision
% 8-15-2016
% Register an Aerial Photograph to a Digital Orthophoto
% how to show the aligned images?

function registered = register_controlpoint (original_fn, unregistered_fn)

%%
% load two images
original = imread(original_fn);
unregistered = imread(unregistered_fn);

% fuse two images with red and green
imf_before = imfuse(original,unregistered,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);

%% Control Points
% use cpselect GUI to choose control points
% and wait until control points are exported

% use previous selected control points?
if 1
    load('my_control_points','movingPoints','fixedPoints');
else
    [movingPoints,fixedPoints] = cpselect(unregistered, original, 'Wait', true);
    save('my_control_points','movingPoints','fixedPoints')
end

%% Registered results using control points only
% calculate the transform
mytform_cp = fitgeotrans(movingPoints, fixedPoints, 'NonreflectiveSimilarity');

% apply the transform and clip it with the window of the original image
registered_cp = imwarp(unregistered, mytform_cp,'OutputView',imref2d(size(original)));

% fuse two images with red and green
imf_cp = imfuse(original,registered_cp,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);


%% Cross correlation
% refine the control points with cross correlation
% works only for translation (shifting on the XY plane)
movingPointsAdjusted = cpcorr(movingPoints,fixedPoints,...
    squeeze(unregistered(:,:,2)),...
    squeeze(original(:,:,2)));

% calculate the transform
mytform_cp_corr = fitgeotrans(movingPointsAdjusted, fixedPoints, 'NonreflectiveSimilarity');

% apply the transform and clip it with the window of the original image
registered_cp_corr = imwarp(unregistered, mytform_cp_corr,'OutputView',imref2d(size(original)) );

% fuse two images with red and green
imf_cp_corr = imfuse(original,registered_cp_corr,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);

%% save files
save('output_images','original','unregistered','registered_cp','registered_cp_corr','imf_before','imf_cp_corr')


%% Visualization

    figure('Units','inches',...
    'Position',[5 5 6 6],...
    'PaperPositionMode','auto');

    set(gca,...
    'Units','normalized',...
    'Position',[.15 .2 .75 .7],...
    'FontUnits','points',...
    'FontWeight','normal',...
    'FontSize',9,...
    'FontName','Arial');

subplot(2,2,1)
image(original);
title('(a) Truth')
axis image
axis off

subplot(2,2,2)
image(unregistered);
title('(b) WSI')
axis image
axis off

subplot(2,2,3)
image(imf_before);
title('(c) Images fused before registration')
axis image
axis off

subplot(2,2,4)
image(imf_cp_corr);
title('(d) Images fused after registration')
axis image
axis off


return
end
