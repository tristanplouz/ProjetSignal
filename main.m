clear all;
close all;
warning off
sec=sec0=time();

% Import libraries
%graphics_toolkit gnuplot
pkg load signal
pkg load image
pkg load geometry

function res=picPrep(pic) %Préparation des images
  pic=rgb2gray(pic); % Transform to gray scale
  pic=im2double(pic);% Transform to double data
  res=pic-mean(mean(pic));% Signal à valeur moyenne nulle
endfunction

data=glob("alphabet/*.png");%Import des adresses de l'alphabet
mot=imread("lorem.png");% Import du text à analyser
mot=picPrep(mot);

%figure(1)
%imshow(mot)

tmp=imread("etalon.png");
tmp=picPrep(tmp);
dy=length(tmp(:,1))/3;
dx=length(tmp(1,:))/3;

nb_carac_line=round(length(mot(1,:))/dx)
nb_carac_col =round(length(mot(:,1))/dy)
tot=nb_carac_line*nb_carac_col;
state=1;
dx_search = length(mot(1,:))/nb_carac_line;
dy_search = length(mot(:,1))/nb_carac_col;

mot_pred = "\n";

for j=1:nb_carac_col
  ymin=dy_search*(j-1)-3;
  ymax=dy_search*(j-1)+dy_search;
  if ymax>length(mot(:,1))
    ymax=length(mot(:,1));
  endif
  if ymin<1
    ymin=1;
  endif
  for i=1:nb_carac_line
    max_global=0;
    predict="";
    %Calcul de l'extraction
      xmin=dx_search*(i-1)-3;
      xmax=dx_search*(i-1)+dx_search+3;
      if xmax>length(mot(1,:))
        xmax=length(mot(1,:));
      endif
      if xmin<1
        xmin=1;
      endif
    for k=1:length(data)
      % Letter echantillon
      l=strsplit(strsplit(data{k},"/"){2},"."){1};
      
      % Image read
      ech=imread(data{k});
      ech=picPrep(ech);
      
      % Display echantillon
      %figure(2);
      %imshow(ech);
      %Display mot
      %figure(4); 
      %imshow(mot(ymin:ymax,xmin:xmax)); 
       
      % Intercorrelation 
      d=normxcorr2(ech,mot(ymin:ymax,xmin:xmax)); 
      %figure(3);
      %figure(3);
      %colormap("jet");
      %surf(d,"edgecolor","none")
      
      % Saving the ech performance
      max_local=max(max(d));
      if max_local > max_global
        max_global = max_local;
        if max_global < 0.8
           predict = " ";
        else
            switch l
              case "qdot"
                predict = "?";
              case "edot"
                predict = "!";
              case "dot"
                predict = ".";
              case "ddot"
                predict = ":";
              otherwise
                predict=l;
            endswitch
        endif
        if max_global > 0.9
          break
        endif
      endif
     
    endfor
    mot_pred = cstrcat(mot_pred, predict);
    mot_pred;
    disp(cstrcat("Caractère : ",num2str(state)," sur ",num2str(tot) ," en ",num2str(time()-sec),"s (eta ",num2str((tot-state)*(time()-sec)),"s)"))
    state++;
    sec=time();
  endfor
  mot_pred = cstrcat(mot_pred, "\n");
  mot_pred;
endfor

mot_pred
time()-sec0