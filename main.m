clear all;
close all;

% Import libraries
graphics_toolkit gnuplot
pkg load signal
pkg load image
pkg load geometry

% Image read
B=imread("motif.png");
mot=imread("mot.png");

% Transform to gray scale
B=rgb2gray(B);  
mot=rgb2gray(mot);

% Transform to double data
B=im2double(B); 
mot=im2double(mot);

B=B-mean(mean(B));
mot=mot-mean(mean(mot));

% Save gray scale images
% saveas(imshow(B),   "Rapports/illus/motifm0.png");
% saveas(imshow(mot), "Rapports/illus/motm0.png");

ech=B;
figure(1)
imshow(mot)
figure(2)
imshow(B)

d=normxcorr2(ech,mot);
figure(3)
colormap("jet");
shading("flat");

saveas(surf(d,"edgecolor","none"),"Rapports/illus/cor.png");
view(0,-90)
V=surf(d,"edgecolor","none")
view(0,-90)
saveas(V,"Rapports/illus/cor1.png");
figure(1)
hold on;
res=[];
ja=length(d(1,:))-1;
ia=length(d(:,1))-1;
for i=1:ia
  for j=1:ja
    if d(i,j)>0.8
      res=[res; [i,j]];
    endif
  endfor
endfor


facx=length(mot(1,:))/length(d(1,:));
facy=length(mot(:,1))/length(d(:,1));

for i=1:length(res)
  drawCircle(res(i,2)*facx, res(i,1)*facy, 10)
endfor