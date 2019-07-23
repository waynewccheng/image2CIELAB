fn = 'tumor_110';

for i = [9 8 7 6 5 4]
    subplot(3,3,i)
    image2CIELAB(fn,i)
end