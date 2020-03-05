clear all;
close all;

% Import libraries
%graphics_toolkit gnuplot
pkg load signal
pkg load image
pkg load geometry

% Image read
B=imread("motif3.png");
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

surf(d,"edgecolor","none")
saveas(figure(3),"Rapports/illus/cor.png");
view(0,-90)
saveas(figure(3),"Rapports/illus/cor1.png");
figure(1)
hold on;
res=[];
ja=length(d(1,:))-1;
ia=length(d(:,1))-1;
for i=1:ia
  for j=1:ja
    if d(i,j)>0.9
      res=[res; [i,j]];
    endif
  endfor
endfor

for i=1:length(res)
  drawCircle(res(i,2)-length(ech(1,:))/2, res(i,1)-length(ech(:,1))/2, 10)
endfor
saveas(figure(1),"Rapports/illus/motiflocal3.png")