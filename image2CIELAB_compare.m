%% Show 3D histogram in CIELAB for TIFF images from Camelyon16 
% for Weijie and Weizhe, Camelyon16 dataset
% 5/2/2019
%

%%
% use Camelyon16 naming convention; no ".tif"; optional leading folder
% wsi_id1 = 'tumor_001';
% wsi_id2 = 'tumor_110';

function image2CIELAB_compare (wsi_id1,wsi_id2)

% which layer in the TIFF to use
tiff_layer = 7

% add .tif to make a filename
fnn1 = [wsi_id1 '.tif'];
fnn2 = [wsi_id2 '.tif'];

% retrive the image
im1 = retrieve_layer(fnn1,tiff_layer);
im2 = retrieve_layer(fnn2,tiff_layer);

% output image size
image_size = size(im1)

% get scanner information
scanner1 = get_scanner(fnn1)
scanner2 = get_scanner(fnn2)

% remove background (empty area)
im1_clean = remove_background(im1);
im2_clean = remove_background(im2);

if 0
    
    %% output original images, masked images, and 3D histogram
    %
    %
    
    clf
    
    subplot(2,3,1)
    imshow(im1)
    title(sprintf('%s, %s',wsi_id1,scanner1),'Interpreter','none')
    
    subplot(2,3,2)
    imshow(im2)
    title(sprintf('%s, %s',wsi_id2,scanner2),'Interpreter','none')
    
    subplot(2,3,4)
    imshow(im1_clean)
    
    subplot(2,3,5)
    imshow(im2_clean)
    
    subplot(2,3,[3 6])
    hold on
    pixel_in_CIELAB(im1_clean,'o')
    pixel_in_CIELAB(im2_clean,'+')
    
    axis([0 40 -50 10 0 100])
    view([120 25])
    grid on
    
    if 0
        % write individual files?
        imwrite(im1,'im1.tif');
        imwrite(im2,'im2.tif');
        imwrite(im1_clean,'im1_masked.tif');
        imwrite(im2_clean,'im2_masked.tif');
    end
    
    return
end


h = gcf;
clf
hold on
pixel_in_CIELAB(im1_clean,'o')
pixel_in_CIELAB(im2_clean,'d')

% axis([0 40 -50 10 0 100])
axis equal
view([120 25])
grid on

%    saveas(gcf,'im1_vs_im2.tif')

if 0
    %% generate animation
    %
    %
    filename = '3D_rotate.gif';
    
    loops = 180;
    F(loops) = struct('cdata',[],'colormap',[]);
    for j = 1:loops
        view(360/loops*j,25)
        drawnow
        F(j) = getframe(gcf);
        
        % Capture the plot as an image
        frame = getframe(h);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        
        % Write to the GIF File
        if j == 1
            imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
        else
            imwrite(imind,cm,filename,'gif','WriteMode','append');
        end
        
    end
    
    %fig = figure;
    %movie(fig,F,1)
    
end

end

%% remove background for H&E slides
% rgb is the input image matrix from imread
function rgb2 = remove_background (rgb)

%
% threshold from white
%
chroma_from_white_threshold = 10;

% linearize
rgb1 = reshape(rgb,size(rgb,1)*size(rgb,2),3);

% convert to CIELAB
lab1 = rgb2lab(rgb1);

% calculate chroma from white -- delta-Eab
dEab = (lab1(:,2).^2 + lab1(:,3).^2) .^ 0.5;

% for every pixel having chroma less than the threshold
% change its color to green
rgb1(dEab < chroma_from_white_threshold,1) = 0;
rgb1(dEab < chroma_from_white_threshold,2) = 255;
rgb1(dEab < chroma_from_white_threshold,3) = 0;

% back to 2D
rgb2 = reshape(rgb1,size(rgb,1),size(rgb,2),3);

if 0
    % debug: visual check
    subplot(1,2,1)
    image(rgb)
    subplot(1,2,2)
    image(rgb2)
end

if 0
    % write result
    imwrite(rgb2,['_masked.tif'])
end

return
end

%% show image pixels in CIELAB
function pixel_in_CIELAB (rgb,mk)

%
% linearize
%
rgb1 = reshape(rgb,size(rgb,1)*size(rgb,2),3);

%
% remove masked green pixels
%
mask = (rgb1(:,1) == 0) & (rgb1(:,2) == 255) & (rgb1(:,3) == 0);
lab1 = rgb2lab(rgb1);
lab1_masked = lab1(~mask,:);
rgb1_masked = rgb1(~mask,:);

%
% discretize for binning
%
lab1_masked_rounded = round(lab1_masked);

if 0
    % check data by plot
    hold on
    plot(lab1_masked_rounded(:,1),'.')
    plot(lab1_masked_rounded(:,2),'.')
    plot(lab1_masked_rounded(:,3),'.')
    legend('L*','a*','b*')
end

%
% get 3D histogram by using accumarray()
%
subs = lab1_masked_rounded;

% 
% determine the threshold of showing the color in the 3D plot
%
threshold = 0.00001 * size(rgb,1)*size(rgb,2)

%
% the domain of CIELAB histogram
%
start_L = 0;
start_a = -100;
start_b = -100;

end_L = 100;
end_a = 100;
end_b = 100;

n_L = end_L - start_L + 1;
n_a = end_a - start_a + 1;
n_b = end_b - start_b + 1;

%
% adjust the range because accumarray requires integer index >= 1
%
subs(:,1) = subs(:,1) - (start_L) + 1;
subs(:,2) = subs(:,2) - (start_a) + 1;
subs(:,3) = subs(:,3) - (start_b) + 1;

%
% generate the 3D histogram with accumarray() and linearize it
%
AA = accumarray(subs,1,[n_L n_a n_b]);
AA1 = reshape(AA,n_L*n_a*n_b,1);

%
% select only the colors greater than the threshold
%
mask_selected_color = AA1 >= threshold;
AA11 = AA1(mask_selected_color);

%
% decide how to represent population with marker size -- to improve
%
population_min = min(AA11)
population_max = max(AA11)
marker_size_scale = prctile(AA11,95)

%
% generate all colors in the domain; need to transpose
%
[L A B] = ind2sub(size(AA),1:n_L*n_a*n_b);

L = L';
A = A';
B = B';

%
% adjust the range so that LAB can be used as matrix indices directly
%
L = L + (start_L) - 1;
A = A + (start_a) - 1;
B = B + (start_b) - 1;

%
% select only the colors with population greater than the threshold
%
Lab1 = [L(mask_selected_color) A(mask_selected_color) B(mask_selected_color)];

%
% calculate sRGB for painting the markers
%
rgb1 = lab2rgb(Lab1);

%
% decide the marker size
% notice that marker size needs to be 2 or larger for "markertype" to be
% effective!
%
size1 = AA11/marker_size_scale*50;

%
% show 3D plot
%
scatter3(Lab1(:,2),Lab1(:,3),Lab1(:,1),size1,double(rgb1(:,:)),mk,'filled')

%
% adjust plot appearance
%
% axis equal
xlabel('CIELAB a*')
ylabel('CIELAB b*')
zlabel('CIELAB L*')

end

%% retrieve a certain image from the TIFF
function im = retrieve_layer (fn,layer_no)

% layer_no = 9;
im = imread(fn,layer_no);

if 0
    % save the layer as an image file
    fn_layer = sprintf('L%d_%s',layer_no,fn);
    imwrite(im,fn_layer);
end

end

%% retrieve scanner name from metadata encoded in Camelyon16
% sample tag:
% 'DICOM_MANUFACTURER" Group="0x0008" Element="0x0070" PMSVR="IString">Hamamatsu</Attribute>
function manufacturer_name = get_scanner (fn)

% get ImageDescription
inf = imfinfo(fn);
id = inf(1).ImageDescription;

% get Manufacturer
pos_manu = strfind(id,'DICOM_MANUFACTURER');    % find the tag
str2 = id(pos_manu:end);                        % shorten the string
pos_1 = strfind(str2,'>');                      % scanner name sourrounded by > and <
pos_2 = strfind(str2,'<');
manufacturer_name = str2(1,pos_1+1:pos_2-1);

end


