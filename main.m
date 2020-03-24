%clear all;
%close all;

% Import libraries
%graphics_toolkit gnuplot
pkg load signal
pkg load image
pkg load geometry

%Function definition
function res=findMax(d)
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
endfunction


function showLoc (res,ech)
  figure(1)
  hold on;
  for i=1:length(res)
    drawCircle(res(i,2)-length(ech(1,:))/2, res(i,1)-length(ech(:,1))/2, 10)
  endfor
  hold off;
endfunction

function res=picPrep(pic)
  pic=rgb2gray(pic); % Transform to gray scale
  pic=im2double(pic);% Transform to double data
  res=pic-mean(mean(pic));
endfunction
data=glob("alphabet/*.png")
mot=imread("mot.png");
mot=picPrep(mot);

figure(1)
imshow(mot)

for i=1:length(data)
% Image read
ech=imread(data{i});

%mot=imread("../photomotif.jpg");

ech=picPrep(ech);

% Save gray scale images
% saveas(imshow(B),   "Rapports/illus/motifm0.png");
% saveas(imshow(mot), "Rapports/illus/motm0.png");


figure(2)
imshow(ech)
d=normxcorr2(ech,mot);
figure(3)
colormap("jet");
%shading("flat");

surf(d,"edgecolor","none")
%saveas(figure(3),"Rapports/illus/cor.png");
view(0,-90)
%saveas(figure(3),"Rapports/illus/cor1.png");
showLoc(findMax(d),ech);
endfor
%saveas(figure(1),"Rapports/illus/motiflocal3.png")