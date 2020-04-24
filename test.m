  clear all
  close all
  
  function res=picPrep(pic) %Préparation des images 
  pic=rgb2gray(pic); % Transform to gray scale 
  pic=im2double(pic);% Transform to double data 
  res=pic-mean(mean(pic));% Signal à valeur moyenne nulle 
endfunction 

  mot=imread("../ProjetPic/lorem2.png");
  mot=picPrep(mot);
  a=0;
  A=mean(mot);
  A(A>min(min(mot))+0.001)=100;
  B=[A;A;A;A;A;A;A;A;A;A;A;A;A;A;A;A];
  yprec=y=eprec=0;
  for i=2:length(A)
    if A(i)+10<A(i-1)
      if i-yprec>0.3*eprec
        a+=1;
        eprec=i-yprec
        yprec=i;
      elseif i-yprec>1.9*eprec
        a+=2;
        yprec=i;
      else
        eprec=i-yprec
        yprec=i;
      endif
    endif
  endfor
  nc=a+1
  
  a=0;
  A=mean(mot');
  A(A>min(min(mot))+0.0001)=100;
  C=[A' A' A' A'];
  yprec=y=eprec=0;
  for i=2:length(A)
    if A(i)>A(i-1)+10
      if i-yprec>0.3*eprec
        a+=1;
        eprec=i-yprec;
        yprec=i;
      elseif i-yprec>1.5*eprec
        a+=2;
        yprec=i;
      else
        eprec=i-yprec;
        yprec=i;
      endif
    endif
  endfor
  nl=a+1
  hold on
  imshow(mot)
####  
  imshow(C)
 imshow(B)