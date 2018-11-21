% To answer Craig's comments about pixel-level registration

function check_registration_with_bars

load('output_images','original','unregistered','registered_cp','registered_cp_corr','imf_before','imf_cp_corr')

%% determine ROI
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


% see the whole image
sizex = 100;
sizey = 100;

% use a smaller window to see the pixelation
sizex1 = 50;
sizey1 = 50;

sizex2 = min(sizex1 + sizex - 1, sizex2_original);

sizey2 = min(sizey1 + sizey - 1, sizey2_original);


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

%% determine where to profile
% cursorx = 27;
% cursory = 78;

% cursorx = 108;
% cursory = 541;

cursorx = 564;
cursory = 539;

cursorx = 88;
cursory = 516;

cursorx = 44;
cursory = 56;

cursor = [44 56];

while (cursor(1) >= 1 && cursor(1)<=size(im1,2) && cursor(2) >= 1 && cursor(2)<=size(im1,1))
    
    cursornew = compare_two_registered_images (im1, im2, cursor);
    cursor = cursornew;

end

%% save data

saveas(gcf,'finding registration.png')


end


function ret = compare_two_registered_images (im1, im2, cursor)

%% annotate image by adding two lines

imtmp = im1;
imtmp(cursor(2),1:2:end,1) = 0;  % cyan
imtmp(1:2:end,cursor(1),2) = 0;  % magenta

%% get profile lines

% in CIELAB
lab1 = rgb2lab(im1);
lab2 = rgb2lab(im2);

profxline1 = lab1(cursor(2),:,1);
profxline2 = lab2(cursor(2),:,1);
profxline12ratio = mean(double(profxline1)./double(profxline2));
profxline2_adjusted = profxline2 * profxline12ratio;
profxcorrcoef = corrcoef(profxline1,profxline2_adjusted);

profyline1 = lab1(:,cursor(1),1);
profyline2 = lab2(:,cursor(1),1);
profyline12ratio = mean(double(profyline1)./double(profyline2));
profyline2_adjusted = profyline2 * profyline12ratio;
profycorrcoef = corrcoef(profyline1,profyline2_adjusted);

profydi = [1:size(lab1,1)];

%% visualization

% control parameters
box_start = 0.1;
box_length = 0.8;

image_ratio = 0.1;
prof_ratio = 0.8;

image_Position = [box_start+image_ratio*box_length box_start+image_ratio*box_length...
    box_length*(1-image_ratio) box_length*(1-image_ratio)];


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


%% show WSI image
graph = subplot(2,2,2);


image(imtmp);
axis ij

set(graph,'xticklabel',[])
set(graph,'yticklabel',[])
set(graph,'xtick',[])
set(graph,'ytick',[])


%% show horizontal profile

profx = subplot(2,2,4);

hold on
plot(profxline1,'c-')
plot(profxline2,'c:')
%plot(profxline2_adjusted,'c:')

xlabel(sprintf('X position (Y=%d), R=%.4f',cursor(2),profxcorrcoef(1,2)))
ylabel('L^*','Rotation',0)
%axis([1 size(lab1,2) 0 100])

profx.YAxisLocation = 'right';

%% show vertical profile

profy = subplot(2,2,1);

hold on
plot(profyline1,profydi,'m-')
plot(profyline2,profydi,'m:')
%plot(profyline2_adjusted,profydi,'m:')

xlabel('L^*')
ylabel(sprintf('Y position (X=%d), R=%.4f',cursor(1),profycorrcoef(1,2)))
%axis([0 100 1 size(lab1,1)])

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


ret = round(ginput(1));

end
