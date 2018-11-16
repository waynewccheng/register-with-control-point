% show the misaligned pixels that are either red or green from imwarp
% try the difference

load('image_fused','imf')
im0 = reshape(imf,imsize(1)*imsize(2),3);

imsize = size(imf);

imfd = double(imf);
imdiff = imfd([2:end 1],:,:) - imfd([1:end],:,:);

im1 = reshape(imdiff,imsize(1)*imsize(2),3);
im1(:,3) = 0;

a = double(im1(:,1));
b = double(im1(:,2));

if 1
subplot(2,2,2)
plot(a,b,'.')
axis square
%axis([0 255 0 3])
end

if 1
subplot(2,2,3)
plot(a,a./b,'.')
axis square
%axis([0 255 0 3])
end

r = a./b;

upper = 20;
lower = -20;

m = a > upper | a < lower;
im1m = im0;
im1m(~m,:) = 0;
im2red = reshape(im1m,imsize(1),imsize(2),3);

m = b > upper | b < lower;
im1m = im0;
im1m(~m,:) = 0;
im2green = reshape(im1m,imsize(1),imsize(2),3);

subplot(2,2,1)
image(imf)
axis image

% subplot(1,3,2)
% image(im2red)
% axis image

subplot(2,2,4)
image(im2green+im2red)
axis image
