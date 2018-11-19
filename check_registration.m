function check_registration

load('output_images','original','unregistered','registered_cp','registered_cp_corr','imf_before','imf_cp_corr')

% intionally create offset to show what if misaligned
offsetx = -1;
offsety = -1;

% get original size
sizex1 = 1;
sizey1 = 1;
sizex2 = size(original,2);
sizey2 = size(original,1);

if 1
sizex1 = 100;
sizex2 = sizex1 + 50;

sizey1 = 100;
sizey2 = sizey1 + 50;

else
% reduce the size by offset
sizex1 = sizex1 + abs(offsetx);
sizex2 = sizex2 - abs(offsetx);

sizey1 = sizey1 + abs(offsety);
sizey2 = sizey2 - abs(offsety);
end

im1 = original(sizey1:sizey2,sizex1:sizex2,:);
im2 = registered_cp_corr([sizey1:sizey2]+offsety,[sizex1:sizex2]+offsetx,:);

imf_test = imfuse(im1,im2,...
    'falsecolor','Scaling','joint',...
    'ColorChannels',[1 2 0]);

%% visualization


cursorx = 25;
cursory = 20;


clf
im1tmp = im1;
im2tmp = im2;

subplot(5,3,[1 4 7])
im1tmp(cursory,:,1) = 0;
im1tmp(:,cursorx,2) = 0;
image(im1tmp);
title('Truth')

axis image
axis off

subplot(5,3,[2 5 8])
im2tmp(cursory,:,1) = 0;
im2tmp(:,cursorx,2) = 0;
image(im2tmp);
axis image
axis off
title(sprintf('WSI (%d,%d)',offsetx,offsety))

subplot(5,3,[3 6 9])
image(imf_test);
axis image
axis off
title('Compare images')

%% show profile


% in CIELAB
lab1 = rgb2lab(im1);
lab2 = rgb2lab(im2);

subplot(5,3,10:12)
hold on
line1 = lab1(cursory,:,1);
line2 = lab2(cursory,:,1);
line12 = mean(double(line1)./double(line2));
plot(line1,'c-')
plot(line2*line12,'c:')
title(sprintf('Profile at y=%d',cursory))
xlabel('X position')
ylabel('CIE L*')

subplot(5,3,13:15)
hold on
line1 = lab1(:,cursorx);
line2 = lab2(:,cursorx);
line12 = mean(double(line1)./double(line2));
plot(line1,'m-')
plot(line2*line12,'m:')
title(sprintf('Profile at x=%d',cursorx))
xlabel('Y position')
ylabel('CIE L*')

end
