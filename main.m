clear all;
%close all;

% Import libraries
%graphics_toolkit gnuplot
pkg load signal
pkg load image
pkg load geometry

%Function definition
function res=findMax(d,trig)
  res=[];
  ja=length(d(1,:))-1;
  ia=length(d(:,1))-1;
  for i=1:ia
    for j=1:ja
      if d(i,j)>trig
          res=[res; [i,j]];
      endif
      endfor
  endfor
endfunction


function showLoc (cer,ech)
  figure(1)
  hold on;
  for i=1:length(cer)-1
    drawCircle(cer(i,2)-length(ech(1,:))/2, cer(i,1)-length(ech(:,1))/2, 10)
  endfor
  hold off;
endfunction

function res=picPrep(pic)
  pic=rgb2gray(pic); % Transform to gray scale
  pic=im2double(pic);% Transform to double data
  res=pic-mean(mean(pic));
endfunction
data=glob("alphabet/*.png");
mot=imread("mot.png");
mot=picPrep(mot);
textcreate={}
figure(1)
imshow(mot)

for i=1:length(data)
  l=strsplit(strsplit(data{i},"/"){2},"."){1}
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
  %view(0,-90)
  %saveas(figure(3),"Rapports/illus/cor1.png");
  maxs=findMax(d,0.977);
  for i=1:length(maxs)-1
    textcreate{end+1}= {l,[maxs(i,1),maxs(i,2)]};
  endfor
  showLoc(maxs,ech);
endfor

%celldisp(textcreate);
%saveas(figure(1),"Rapports/illus/motiflocal3.png")


textsorted={};



for j=1:length(textcreate)
  ind=0;
  mini1=inf;
  for i=1:length(textcreate)
    if textcreate{i}{2}(1)<mini1
      mini1=textcreate{i}{2}(1);
    endif
  endfor
  mini2=inf;
  for i=1:length(textcreate)
    if textcreate{i}{2}(1)==mini1
      if textcreate{i}{2}(2)<mini2
      mini2=textcreate{i}{2}(2);
      ind=i;
      endif
    endif
  endfor
  textsorted{end+1}=textcreate{ind};
  textcreate{ind}{2}=[inf,inf];
endfor
mot=[]
for i=1:length(textsorted)
  mot=[mot char(textsorted{i}(1))];
endfor
mot