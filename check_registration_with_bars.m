% To answer Craig's comments about registration
function check_registration

load('output_images','original','unregistered','registered_cp','registered_cp_corr','imf_before','imf_cp_corr')

% intionally create offset to show what if misaligned
% ended up the original tform was not optimal
offsetx = 0;
offsety = 0;
Offset = [offsetx offsety]

% get original size
size(original)
sizex1 = 1;
sizey1 = 1;
sizex2 = size(original,2);
sizey2 = size(original,1);


if 1
    % see the whole image
    sizex = 200;
    sizey = 300;
    
    % use a smaller window to see the pixelation
    sizex1 = 50;
    sizey1 = 50;
    
    sizex2 = sizex1 + sizex - 1;
    sizey2 = sizey1 + sizey - 1;
    
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

box_start = 0.1;
box_length = 0.8;
image_ratio = 0.1;
prof_ratio = 0.8;


image_Position = [box_start+image_ratio*box_length box_start+image_ratio*box_length...
    box_length*(1-image_ratio) box_length*(1-image_ratio)];



p_size_per_image = 1;
p_total_row = p_size_per_image+1;
p_total_column = p_size_per_image+1;

% cursorx = 27;
% cursory = 78;

% cursorx = 108;
% cursory = 541;

cursorx = 564;
cursory = 539;

cursorx = 88;
cursory = 516;

cursorx = 88;
cursory = 56;

% new figure
figure('Units','inches',...
    'Position',[1 1 10 10],...
    'PaperPositionMode','auto');

set(gca,...
    'Units','normalized',...
    'Position',[.15 .2 .75 .7],...
    'FontUnits','points',...
    'FontWeight','normal',...
    'FontSize',9,...
    'FontName','Arial');

im1tmp = im1;
im2tmp = im2;

% % Truth image
% subplot(p_total_row,p_total_column,find(p_mask_matrix_1'))
% im1tmp(cursory,:,1) = 0;
% im1tmp(:,cursorx,2) = 0;
% image(im1tmp);
% title('Truth')
%
% axis image
% axis off

p_mask_matrix_temp = zeros(p_total_row,p_total_column);
for i = 1:p_size_per_image
    for j = 1:p_size_per_image
        p_mask_matrix_temp(i,j+1) = 1;
    end
end
p_mask_matrix_4 = p_mask_matrix_temp;


% WSI image
graph = subplot(p_total_row,p_total_column,find(p_mask_matrix_4'));

im2tmp(cursory,1:2:end,1) = 0;  % cyan
im2tmp(1:2:end,cursorx,2) = 0;  % magenta

image(im2tmp);
axis ij

set(graph,'xticklabel',[])
set(graph,'yticklabel',[])
set(graph,'xtick',[])
set(graph,'ytick',[])


% in CIELAB
lab1 = rgb2lab(im1);
lab2 = rgb2lab(im2);

%% horizontal profile

profx = subplot(p_total_row,p_total_column,...
    (p_total_row-1)*p_total_column+1 : 1 : p_total_row*p_total_column);

line1 = lab1(cursory,:,1);
line2 = lab2(cursory,:,1);
line12ratio = mean(double(line1)./double(line2));

hold on
plot(line1,'c-')
plot(line2*line12ratio,'c:')

xlabel(sprintf('X position (Y=%d)',cursory))
ylabel('L^*','Rotation',0)
axis([1 size(lab1,2) 0 100])

profx.YAxisLocation = 'right';

%% vertical profile

profy = subplot(p_total_row,p_total_column,...
    1 : p_total_column : p_total_column*(p_total_row-1));

line1 = lab1(:,cursorx,1);
line2 = lab2(:,cursorx,1);
line12ratio = mean(double(line1)./double(line2));
di = [1:size(lab1,1)];

hold on
plot(line1,di,'m-')
plot(line2*line12ratio,di,'m:')

ylabel(sprintf('Y position (X=%d)',cursorx))
xlabel('L^*')
axis([0 100 1 size(lab1,1)])

set(profy,'Ydir','reverse')


%% align the 3 subplots

graph.Position = image_Position;

profx.Position(1) = graph.Position(1);
profx.Position(2) = box_start;
profx.Position(3) = graph.Position(3);
profx.Position(4) = (graph.Position(2)-box_start) * prof_ratio;

profy.Position(1) = box_start;
profy.Position(2) = graph.Position(2);
profy.Position(3) = (graph.Position(1)-box_start) * prof_ratio;
profy.Position(4) = graph.Position(4);



saveas(gcf,'finding registration.png')

end
