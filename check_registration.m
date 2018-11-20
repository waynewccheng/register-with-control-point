% To answer Craig's comments about registration
function check_registration

load('output_images','original','unregistered','registered_cp','registered_cp_corr','imf_before','imf_cp_corr')

% intionally create offset to show what if misaligned
% ended up the original tform was not optimal
offsetx = -1;
offsety = 0;
Offset = [offsetx offsety]

% get original size
sizex1 = 1;
sizey1 = 1;
sizex2 = size(original,2);
sizey2 = size(original,1);

if 1
    % use a smaller window to see the pixelation
    sizen = 200;
    
    sizex1 = 50;
    sizey1 = 50;

    sizex2 = sizex1 + sizen;
    sizey2 = sizey1 + sizen;
    
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

p_size_per_image = 10;
p_1st_profile_start_from_row = p_size_per_image+0;
p_2nd_profile_start_from_row = p_1st_profile_start_from_row+2;
p_total_row = p_2nd_profile_start_from_row+1;
p_total_column = p_size_per_image*3;

p_mask_matrix_temp = zeros(p_total_row,p_total_column);
k = 1;
for i = 1:p_size_per_image
    for j = 1:p_size_per_image
        p_mask_matrix_temp(i,j+(k-1)*p_size_per_image) = 1;
    end
end
p_mask_matrix_1 = p_mask_matrix_temp;

p_mask_matrix_temp = zeros(p_total_row,p_total_column);
k = 2;
for i = 1:p_size_per_image
    for j = 1:p_size_per_image
        p_mask_matrix_temp(i,j+(k-1)*p_size_per_image) = 1;
    end
end
p_mask_matrix_2 = p_mask_matrix_temp;


p_mask_matrix_temp = zeros(p_total_row,p_total_column);
k = 3;
for i = 1:p_size_per_image
    for j = 1:p_size_per_image
        p_mask_matrix_temp(i,j+(k-1)*p_size_per_image) = 1;
    end
end
p_mask_matrix_3 = p_mask_matrix_temp;


cursorx = 27;
cursory = 78;


clf
im1tmp = im1;
im2tmp = im2;

% Truth image
subplot(p_total_row,p_total_column,find(p_mask_matrix_1'))
im1tmp(cursory,:,1) = 0;
im1tmp(:,cursorx,2) = 0;
image(im1tmp);
title('Truth')

axis image
axis off

% WSI image
subplot(p_total_row,p_total_column,find(p_mask_matrix_2'))
im2tmp(cursory,1:2:end,1) = 0;
im2tmp(1:2:end,cursorx,2) = 0;
image(im2tmp);
axis image
axis off
% hide the offset
% title(sprintf('WSI (%d,%d)',offsetx,offsety))
title(sprintf('WSI'))

% Fuse image
subplot(p_total_row,p_total_column,find(p_mask_matrix_3'))
image(imf_test);
axis image
axis off
title('Fused Image (R=Truth, G=WSI)')

%% show profile



% in CIELAB
lab1 = rgb2lab(im1);
lab2 = rgb2lab(im2);

subplot(p_total_row,p_total_column,p_total_column*p_1st_profile_start_from_row+1:p_total_column*(p_1st_profile_start_from_row+1))
hold on
line1 = lab1(cursory,:,1);
line2 = lab2(cursory,:,1);
line12 = mean(double(line1)./double(line2));
plot(line1,'c-')
plot(line2*line12,'c:')
title(sprintf('L* profile at y=%d',cursory))
xlabel('X position')
ylabel('CIE L*')
axis([1 sizen 0 100])

subplot(p_total_row,p_total_column,p_total_column*p_2nd_profile_start_from_row+1:p_total_column*(p_2nd_profile_start_from_row+1))
hold on
line1 = lab1(:,cursorx);
line2 = lab2(:,cursorx);
line12 = mean(double(line1)./double(line2));
plot(line1,'m-')
plot(line2*line12,'m:')
title(sprintf('L* profile at x=%d',cursorx))
xlabel('Y position')
ylabel('CIE L*')
axis([1 sizen 0 100])


saveas(gcf,'finding registration.png')

end
