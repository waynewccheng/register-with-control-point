% To answer Craig's comments about pixel-level registration

function check_registration_with_bars

% intentionally create offset to show what if misaligned
% ended up the original tform was not optimal
offset = [0 0]

%% determine where to profile
cursor = [26 78];

% the ROI size
% need to be square before the profiles sizing is fixed

load('output_images','original','unregistered','registered_cp','registered_cp_corr','imf_before','imf_cp_corr')

if 1
    sizex = 1200;
    sizey = 800;
else
    sizex = size(original,2);
    sizey = size(original,1);
end

done = 0;
while done==0
    
    %% determine ROI
    
    % get original size
    size(original)
    
    sizex2_original = size(original,2);
    sizey2_original = size(original,1);
    
    % size for im1
    sizex1 = 1;
    sizey1 = 1;
    sizex2 = min(sizex1 + sizex - 1, sizex2_original);
    sizey2 = min(sizey1 + sizey - 1, sizey2_original);
    
    % size for im2
    reg_sizex = [sizex1:sizex2]+offset(1);
    reg_sizex = min(reg_sizex,sizex2_original);
    reg_sizex = max(reg_sizex,1);
    
    reg_sizey = [sizey1:sizey2]+offset(2);
    reg_sizey = min(reg_sizey,sizey2_original);
    reg_sizey = max(reg_sizey,1);
    
    % retrieve the ROI
    im1 = original(sizey1:sizey2,sizex1:sizex2,:);
    
    im2 = registered_cp_corr(reg_sizey,reg_sizex,:);
    
    imf_test = imfuse(im1,im2,...
        'falsecolor','Scaling','joint',...
        'ColorChannels',[1 2 0]);
    
    [done offset] = compare_two_registered_images (im1, im2, cursor, offset);
    
end

%% save data

saveas(gcf,'finding registration.png')


end


function [done offsetnew] = compare_two_registered_images (im1, im2, cursor, offset)

%% annotate image by adding two lines



%% visualization

% control parameters
box_start = 0.1;
box_length = 0.8;

image_ratio = 0.1;
prof_ratio = 0.8;

image_Position = [box_start+image_ratio*box_length box_start+image_ratio*box_length...
    box_length*(1-image_ratio) box_length*(1-image_ratio)];


% original image size
winwidth = 10;
winheight = round(winwidth * size(im1,1) / size(im1,2));

% new figure
figure('Units','inches',...
    'Position',[1 1 winwidth winheight],...
    'PaperPositionMode','auto');

set(gca,...
    'Units','normalized',...
    'Position',[.15 .2 .75 .7],...
    'FontUnits','points',...
    'FontWeight','normal',...
    'FontSize',9,...
    'FontName','Arial');

graph = subplot(2,2,2);
profx = subplot(2,2,4);
profy = subplot(2,2,1);
offs = subplot(2,2,3);

subplot(graph)

flag = 1;
done = 0;
click_xy = cursor;

while flag==1
    
    switch gca
        
        case graph
            
            cursor = round(click_xy);
            
            if (cursor(1) >= 1 && cursor(1)<=size(im1,2) &&...
                    cursor(2) >= 1 && cursor(2)<=size(im1,1))
                
                
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
                
                %% show WSI image
                
                subplot(graph);
                
                image(imtmp);
                axis ij
                
                set(graph,'xticklabel',[])
                set(graph,'yticklabel',[])
                set(graph,'xtick',[])
                set(graph,'ytick',[])
                
                title(sprintf('Offset = (%d,%d)',offset(1),offset(2)))
                
                %% show horizontal profile
                
                subplot(profx);
                
                hold off
                plot(profxline1,'c-')
                hold on
                plot(profxline2,'c:')
                %plot(profxline2_adjusted,'c:')
                
                xlabel(sprintf('X position (Y=%d), R=%.4f',cursor(2),profxcorrcoef(1,2)))
                ylabel('L^*','Rotation',0)
                %axis([1 size(lab1,2) 0 100])
                
                profx.YAxisLocation = 'right';
                
                %% show vertical profile
                
                subplot(profy);
                
                hold off
                plot(profyline1,profydi,'m-')
                hold on
                plot(profyline2,profydi,'m:')
                %plot(profyline2_adjusted,profydi,'m:')
                
                xlabel('L^*')
                ylabel(sprintf('Y position (X=%d), R=%.4f',cursor(1),profycorrcoef(1,2)))
                %axis([0 100 1 size(lab1,1)])
                
                profy.XAxisLocation = 'top';
                set(profy,'Ydir','reverse')
                
                
                %% show offset control
                subplot(offs)
                hold off
                plot([0 1],[1/3 1/3])
                hold on
                plot([0 1],[2/3 2/3])
                plot([1/3 1/3],[0 1])
                plot([2/3 2/3],[0 1])
                axis([0 1 0 1])
                axis off
                
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
                
                offs.Position(1) = box_start;
                offs.Position(2) = box_start;
                offs.Position(3) = profy.Position(3);
                offs.Position(4) = profx.Position(4);
                
                disp('Click on the image to choose new cross-sections. Click outside the image to exit.')
                click_xy = ginput(1);
                
            else
                
                flag = 0;
                done = 1;
                offsetnew = offset;
                
            end
            
        case offs
            
            if (click_xy(1) >= 0 && click_xy(1)<=1 && click_xy(2) >= 0 && click_xy(2)<=1)
                
                % 9x9 buttons
                
                if click_xy(1) < 1/3
                    offset(1) = offset(1) - 1;
                else
                    if click_xy(1) > 2/3
                        offset(1) = offset(1) + 1;
                    end
                end
                
                if click_xy(2) < 1/3
                    offset(2) = offset(2) - 1;
                else
                    if click_xy(2) > 2/3
                        offset(2) = offset(2) + 1;
                    end
                end
                
                
                flag = 0;
                done = 0;
                offsetnew = offset;
                close(gcf)
                
            else
                
                flag = 0;
                done = 1;
                offsetnew = offset;
                
            end
            
            
        otherwise
            flag = 0;
            done = 1;
            offsetnew = offset;
            
    end
    
    % remove offset info
    if done==1
        cla(offs)
        
        subplot(graph)
        title('');
    end
end

end
