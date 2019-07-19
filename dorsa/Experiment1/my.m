function my (fn1, fn2)

imtarget = imread(fntarget);
im0 = imread(fn0);
im1 = imread(fn1);
im2 = imread(fn2);

lab0 = rgb2lab(im0,'colorspace','srgb','whitepoint','d65');
lab1 = rgb2lab(im1,'colorspace','srgb','whitepoint','d65');
lab2 = rgb2lab(im2,'colorspace','srgb','whitepoint','d65');
lab1_lin = reshape(lab1,size(lab1,1)*size(lab1,2),3);
lab2_lin = reshape(lab2,size(lab2,1)*size(lab2,2),3);
de_lin = sum((lab1_lin - lab2_lin).^2,2).^0.5;
de = reshape(de_lin,size(lab2,1),size(lab2,2));

corrcoef(lab1_lin(:,1),lab2_lin(:,1))
mean(de_lin)

figure('units','normalized','outerposition',[0 0 1 1])

subplot(2,,1)
image(im0)
axis image
axis off
title(fn0)

subplot(2,4,2)
image(im1)
axis image
axis off
title(fn1)

subplot(2,4,3)
image(im2)
axis image
axis off
title(fn2)

subplot(2,4,4)
image(imtarget)
axis image
axis off
title(fntarget)

subplot(2,4,5)
histogram(de_lin)
xlabel('dE')
ylabel('Count')
title(sprintf('u=%.2f, s=%.2f',mean(de_lin),std(de_lin)))

subplot(2,4,6)
mesh(de)
axis image
axis off
colorbar('south')

subplot(2,4,7)
hold on
plot3(lab0(:,2),lab0(:,3),lab0(:,1),'.r')
plot3(lab1(:,2),lab1(:,3),lab1(:,1),'.g')
plot3(lab2(:,2),lab2(:,3),lab2(:,1),'.b')
grid on
xlabel('CIE a*')
ylabel('CIE b*')
zlabel('CIE L*')
legend(fn0,fn1,fn2)
view(-60,30)

saveas(gcf,sprintf('%s-%s.tif',fn1,fn2))
end
