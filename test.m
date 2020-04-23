clear all

function res=picPrep(pic) %Préparation des images 
  pic=rgb2gray(pic); % Transform to gray scale 
  pic=im2double(pic);% Transform to double data 
  res=pic-mean(mean(pic));% Signal à valeur moyenne nulle 
endfunction 

function res=countCaracLine(mot)
  a=0;
  A=mean(mot)
  A(A<max(max(mot))-0.001)=100;
  for i=25:length(A)
    if A(i)>10+A(i-1)
      a++;
    endif
  endfor
  res=a+1;
endfunction

while (1)%Interface utilisateur Chargement fichier
  fileAdr=input("Adresse du fichier(Laisser vide pour default)","s");
  if isempty(fileAdr)  
    file=imread("lorem2.png");% Import du text à analyser 
    break;
  else
    try 
      file=imread(fileAdr);
      break;
    catch 
      disp("Fichier non trouvé");
    end_try_catch
  endif
endwhile
file=255-file;
file=picPrep(file);
imshow(file)
function res=withoutMargin(file)
  A=mean(file);
  for i=1:length(A)-1
    if A(i)~=A(i+1)
      xmin=i-1;
      break
    endif
  endfor
  for i=length(A)-1:-1:1
    if A(i)~=A(i-1)
      xmax=i+1;
      break
    endif
  endfor
  A=mean(file');
  for i=1:length(A)-1
    if A(i)~=A(i+1)
      ymin=i-1;
      break
    endif
  endfor
  for i=length(A)-1:-1:1
    if A(i)~=A(i-1)
      ymax=i+1;
      break
    endif
  endfor
  res=file(ymin:ymax,xmin:xmax);
endfunction
imshow(mot)

countCaracLine(mot)
