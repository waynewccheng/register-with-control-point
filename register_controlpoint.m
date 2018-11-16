% 8-15-2016
% Register an Aerial Photograph to a Digital Orthophoto
% how to show the aligned images?

function registered = register_controlpoint (original_fn,unregistered_fn)

%% 
% load two images
original = imread(original_fn);
unregistered = imread(unregistered_fn);

%%
% use cpselect GUI to choose control points
% and wait until control points are exported 
[movingPoints,fixedPoints] = cpselect(unregistered, original, 'Wait', true);

%% 
% refine the control points with cross correlation
% works only for translation (shifting on the XY plane)
movingPointsAdjusted = cpcorr(movingPoints,fixedPoints,...
    squeeze(unregistered(:,:,2)),...
    squeeze(original(:,:,2)));

%%
% calculate the transform
mytform = fitgeotrans(movingPointsAdjusted, fixedPoints, 'NonreflectiveSimilarity');

%%
% apply the transform
% and clip it with the window of the original image
registered = imwarp(unregistered, mytform,'OutputView',imref2d(size(original)) );

%% 
% show result
% using red and green fusion
imf = imfuse(original,registered,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
image(imf)

save('image_fused','imf')

return
end
