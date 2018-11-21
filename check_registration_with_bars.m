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

sizex2_original = size(original,2);
sizey2_original = size(original,1);

sizex1 = 1;
sizey1 = 1;
sizex2 = sizex2_original;
sizey2 = sizey2_original;


if 1
    % see the whole image
    sizex = 200;
    sizey = 300;
    
    % use a smaller window to see the pixelation
    sizex1 = 50;
    sizey1 = 50;
    
    sizex2 = min(sizex1 + sizex - 1, sizex2_original);
    
    sizey2 = min(sizey1 + sizey - 1, sizey2_original);
    
else
    % reduce the size by offset
    sizex1 = sizex1 + abs(offsetx);
    sizex2 = sizex2 - abs(offsetx);
    
    sizey1 = sizey1 + abs(offsety);
    sizey2 = sizey2 - abs(offsety);
end


reg_sizex = [sizex1:sizex2]+offsetx;
reg_sizex = min(reg_sizex,sizex2_original);
reg_sizex = max(reg_sizex,1);

reg_sizey = [sizey1:sizey2]+offsety;
reg_sizey = min(reg_sizey,sizey2_original);
reg_sizey = max(reg_sizey,1);


im1 = original(sizey1:sizey2,sizex1:sizex2,:);

im2 = registered_cp_corr(reg_sizey,reg_sizex,:);


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



% % Truth image
% subplot(p_total_row,p_total_column,find(p_mask_matrix_1'))
% im1tmp(cursory,:,1) = 0;
% im1tmp(:,cursorx,2) = 0;
% image(im1tmp);
% title('Truth')
%
% axis image
% axis off


% WSI image
graph = subplot(2,2,2);


% in CIELAB
lab1 = rgb2lab(im1);
lab2 = rgb2lab(im2);

im1tmp = im1;
im2tmp = im2;

im2tmp(cursory,1:2:end,1) = 0;  % cyan
im2tmp(1:2:end,cursorx,2) = 0;  % magenta

image(im2tmp);
axis ij

set(graph,'xticklabel',[])
set(graph,'yticklabel',[])
set(graph,'xtick',[])
set(graph,'ytick',[])


%% horizontal profile

profx = subplot(2,2,4);

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

profy = subplot(2,2,1);

line1 = lab1(:,cursorx,1);
line2 = lab2(:,cursorx,1);
line12ratio = mean(double(line1)./double(line2));
di = [1:size(lab1,1)];

hold on
plot(line1,di,'m-')
plot(line2*line12ratio,di,'m:')

xlabel('L^*')
ylabel(sprintf('Y position (X=%d)',cursorx))
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


%% save data

saveas(gcf,'finding registration.png')

end
