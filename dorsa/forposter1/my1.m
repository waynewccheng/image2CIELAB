function my1 (fn1, fn2)

im1 = imread(fn1);
im2 = imread(fn2);

lab1 = rgb2lab(im1,'colorspace','srgb','whitepoint','d65');
lab2 = rgb2lab(im2,'colorspace','srgb','whitepoint','d65');

lab1_lin = reshape(lab1,size(lab1,1)*size(lab1,2),3);
lab2_lin = reshape(lab2,size(lab2,1)*size(lab2,2),3);

de_lin = sum((lab1_lin - lab2_lin).^2,2).^0.5;
de = reshape(de_lin,size(lab2,1),size(lab2,2));

corrcoef(lab1_lin(:,1),lab2_lin(:,1))
mean(de_lin)

figure('units','normalized','outerposition',[0 0 1 1])

de_flipped = flip(de,1);
mesh(de_flipped)
axis image
axis off
colorbar('southoutside')
view(0,90)

saveas(gcf,sprintf('%s-%s.tif',fn1,fn2))
end
