clear
close all;
clf;
pkg load signal
pkg load image
pkg load geometry
B=imread("motif.png");
mot=imread("mot.png");
##c=imread("c.png");
##mot2=imread("mot3.png");
##q=imread("q.png");
B=rgb2gray(B);
B=im2double(B);
##q=rgb2gray(q);
##q=im2double(q);
mot=rgb2gray(mot);
mot=im2double(mot);
##c=rgb2gray(c);
##c=im2double(c);
####mot2=rgb2gray(mot2);
####mot2=im2double(mot2);
B=B-mean(mean(B));
mot=mot-mean(mean(mot));
%mot2-mot2-mean(mean(mot2));
%ech=mot2(218:250,100:130);
##
saveas(imshow(B),"Rapports/illus/motifm0.png");
saveas(imshow(mot),"Rapports/illus/motm0.png");
ech=B;
figure(1)
imshow(mot)
figure
imshow(B)
d=normxcorr2(ech,mot);
figure
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