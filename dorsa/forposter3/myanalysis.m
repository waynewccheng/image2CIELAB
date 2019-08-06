load('Macenko-Reinhard.mat', 'data')
data12 = data;
load('Reinhard-Vahadane.mat', 'data')
data23 = data;
load('Macenko-Vahadane.mat', 'data')
data13 = data;

xrange = 1:300;
clf
hold on
plot(data12(xrange),'r-')
plot(data23(xrange),'g-')
plot(data13(xrange),'b-')

return

load('Original-Macenko.mat', 'data')
data1 = data;
load('Original-Reinhard.mat', 'data')
data2 = data;
load('Original-Vahadane.mat', 'data')
data3 = data;

clf
hold on
plot(data1-data2,'r:')
plot(data1-data3,'g:')
plot(data2-data3,'b:')

return

hold on
plot(data1,'r:')
plot(data2,'g:')
plot(data3,'b:')
