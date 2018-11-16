% Register an Aerial Photograph to a Digital Orthophoto
% how to show the aligned images?

orthophoto = imread('westconcordorthophoto.png');
%figure, imshow(orthophoto)
unregistered = imread('westconcordaerial.png');
%figure, imshow(unregistered)

cpselect(unregistered, orthophoto)

mytform = fitgeotrans(movingPoints, fixedPoints, 'projective');

registered = imwarp(unregistered, mytform,'OutputView',imref2d(size(orthophoto)) );

image(registered)

original = imread('westconcordorthophoto.png');
imshowpair(original,registered)