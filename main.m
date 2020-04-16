clear all;
close all;
warning off

% Import libraries
%graphics_toolkit gnuplot
pkg load signal
pkg load image
pkg load geometry

function res=picPrep(pic)
  pic=rgb2gray(pic); % Transform to gray scale
  pic=im2double(pic);% Transform to double data
  res=pic-mean(mean(pic));
endfunction

data=glob("alphabet/*.png");
mot=imread("lorem.png");
mot=picPrep(mot);
%figure(1)
%imshow(mot)
dx=dy=0;
for i=1:length(data)-1
  tmp=imread(data{i});
  tmp=picPrep(tmp);
  dy+=length(tmp(:,1));
  dx+=length(tmp(1,:));
endfor
dy=109;
dx/=i;
dx+=11;

nb_carac_line=round(length(mot(1,:))/dx)
nb_carac_col =round(length(mot(:,1))/dy)

dx_search = round(length(mot(1,:))/nb_carac_line);
dy_search = round(length(mot(:,1))/nb_carac_col);

mot_pred = "";

for j=1:nb_carac_col
  for i=1:nb_carac_line
    max_global=0;
    predict="";
    for k=1:length(data)
      % Letter echantillon
      l=strsplit(strsplit(data{k},"/"){2},"."){1};
      
      % Image read
      ech=imread(data{k});
      ech=picPrep(ech);
      
      % Display echantillon
      figure(2);
      imshow(ech);
      %Display mot
      figure(4); 
      imshow(mot(dy_search*(j-1)+1:dy_search*(j-1)+dy_search,dx_search*(i-1)+1:dx_search*(i-1)+dx_search)); 
       
      % Intercorrelation 
      d=normxcorr2(ech,mot(dy_search*(j-1)+1:dy_search*(j-1)+dy_search,dx_search*(i-1)+1:dx_search*(i-1)+dx_search)); 
      %figure(3);
      %figure(3);
      %colormap("jet");
      %surf(d,"edgecolor","none")
      
      % Saving the ech performance
      max_local=max(max(d));
      if max_local > max_global
        max_global = max_local
        if max_global < 0.85
           predict = "\ "
        else
        predict = l
        endif
        if max_global > 0.9
          break
        endif
      endif
     
    endfor
    mot_pred = cstrcat(mot_pred, predict)
    mot_pred
  endfor
  mot_pred = cstrcat(mot_pred, "\n")
  mot_pred
endfor

mot_pred