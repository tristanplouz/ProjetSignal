clear all; 
close all; 
warning off 

% Import libraries 
%graphics_toolkit gnuplot 
pkg load signal 
pkg load image
pkg load matgeom

function res=picPrep(pic) %Préparation des images 
  pic=rgb2gray(pic); % Transform to gray scale 
  pic=im2double(pic);% Transform to double data 
  res=pic-mean(mean(pic));% Signal à valeur moyenne nulle 
endfunction 

function res=checkEmptyTile(tile) %Si la tuile est vide il s'agit d'un espace
  if abs(abs(min(min(tile))/mean(mean(tile)))-1)<10^-5 %Seuil à regler
    res=true;
  else
    res=false;
  endif
endfunction

function res=withoutMargin(file) %Detecte et supprime les marges du document à analyser
  A=mean(file);
  %On cherche la premiere colonne non vide
  for i=1:length(A)-1
    if A(i)~=A(i+1)
      xmin=i;
      break
    endif
  endfor
  %On cherche la derniere colonne non vide
  for i=length(A)-1:-1:1
    if A(i)~=A(i-1)
      xmax=i;
      break
    endif
  endfor
  
  A=mean(file');
  %On cherche la premiere ligne non vide
  for i=1:length(A)-1
    if A(i)~=A(i+1)
      ymin=i;
      break
    endif
  endfor
  %On cherche la derniere ligne non vide
  for i=length(A)-1:-1:1
    if A(i)~=A(i-1)
      ymax=i;
      break
    endif
  endfor
  try
    res=file(ymin:ymax,xmin:xmax+15);
  catch
    res=file(ymin:ymax,xmin:xmax);
  end_try_catch
endfunction

function res=countCaracLine(mot) % TO BE UPDATE Compte le nombre de caractères d'une ligne TO BE UPDATE
  a=0;
  A=mean(mot);
  A(A>min(min(mot))+0.001)=100;
  xprec=x=eprec=0;
  for i=2:length(A)
    if A(i)>10+A(i-1)
      if i-xprec>0.3*eprec
        a+=1;
        eprec=i-xprec;
        xprec=i;
      elseif i-xprec>1.9*eprec
        a+=2;
        xprec=i;
      else
        eprec=i-xprec;
        xprec=i;
      endif
    endif
  endfor
  res=a+1;
endfunction


function res=countLine(mot)% TO BE UPDATE Compte le nombre de caractères d'une ligne TO BE UPDATE
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
      elseif i-yprec>1.9*eprec
        a+=2;
        yprec=i;
      else
        eprec=i-yprec;
        yprec=i;
      endif
    endif
  endfor
  res=a+1;
endfunction
while (1)%Interface utilisateur Chargement fichier
  fileAdr=input("Adresse du fichier(Laisser vide pour default)","s");
  if isempty(fileAdr)  
    file=imread("Data/lorem.png");% Import du text à analyser 
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


rep=yes_or_no("Le texte foncé sur fond clair?"); %Demande de la gamme de couleur pour adaptation
if rep 
  file=255-file;
endif

file=picPrep(file);%Prépare le fichier
mot=withoutMargin(file);%Retire les marges
%figure(1) 
%imshow(mot) 

nb_carac_line=countCaracLine(mot)
nb_carac_col=countLine(mot)
tot=nb_carac_line*nb_carac_col; 
state=1; 

%Définition des pas de recherche
dx_search = length(mot(1,:))/nb_carac_line; 
dy_search = length(mot(:,1))/nb_carac_col; 

figure(1)
hold on;
imshow(mot)
for i=0:nb_carac_line
  for k=0:nb_carac_col
    drawRect([i*dx_search-3 k*dy_search-3  dx_search+3 dy_search+3]);
  endfor
endfor
hold off

dbquit


data=glob("alphabet/*.png");%Import des adresses de motif de l'alphabet 
rep=yes_or_no("Le texte contient uniquement des majuscules?"); 
if rep 
  data=data(37:end); %On importe que les majuscules et la ponctuation
endif

sec=sec0=time(); %init du chronomètre
disp("Chargement des éléments...")
alpha = cell();
scam=0;
for k=1:length(data)
  %On crée un tableau contenant les motifs et la lettre associé, on stocke en mémoire et limite l'accès au disque
  B=imread(data{k});
  sca=dx_search/(length(B)/3);
  B=imresize(B,sca);%On redimensionne chaque élement
  scam+=sca;
  alpha{end+1}={picPrep(B),strsplit(strsplit(data{k},"_"){2},"."){1}};
endfor
scam/=k;
clear B
clear file

%Information Utilisateur
disp("Nombre de caractère detecté:")
disp(tot)
disp("Caratère par ligne:")
disp(nb_carac_line)
disp("Nombre de ligne:")
disp(nb_carac_col)
disp("Facteur d'echelle:")
disp(scam)
disp("Début de l'analyse...")
mot_pred = "\n"; 


for j=1:nb_carac_col %Pour chaque ligne
  %Calcul des dimensions en y de la tuile
  ymin=dy_search*(j-1)-3; 
  ymax=dy_search*(j-1)+dy_search; 
  
  if ymax>length(mot(:,1)) 
    ymax=length(mot(:,1)); 
  elseif ymin<1 
    ymin=1; 
  endif 
  
  for i=1:nb_carac_line %Pour chaque caractère de la ligne
    max_global=0; 
    predict=""; 
    %Calcul des dimensions en x de la tuile 
    xmin=dx_search*(i-1)-3; 
    xmax=dx_search*(i-1)+dx_search; 
    if xmax>length(mot(1,:)) 
      xmax=length(mot(1,:)); 
    elseif xmin<1 
      xmin=1; 
    endif 

    tile = mot(ymin:ymax,xmin:xmax);%Création de la tuile
    alrChk=false;
    
    for k=1:length(data) 
     
      % Chargement des motifs 
      ech=cell2mat(alpha{k}(1));
      if alrChk == false
        if checkEmptyTile(tile) %Si la tuile est vide on défini un espace et on break
          predict=" ";
          break
        endif
        alrChk=true;
      endif
      
      % Display échantillon 
      %figure(2); 
      %imshow(ech); 
      %Display tuile 
      %figure(4);  
      %imshow(tile);
      
      %Intercorrelation  
      d=normxcorr2(ech,tile);  
 
      %Display correlation
      %figure(3); 
      %colormap("jet"); 
      %surf(d,"edgecolor","none") 
      
      max_local=max(max(d)); 
      if max_local > max_global 
        % Chargement de la lettre echantillon
        l=char(alpha{k}(2));
        max_global = max_local;
        if max_global < 0.7 
           predict = " "; 
        else 
            switch l 
              case "Qdot" 
                predict = "?";
              case "Ap" 
                predict = "'";
              case "Vir" 
                predict = ",";
              case "Vdot" 
                predict = ";";
              case "Edot" 
                predict = "!";
              case "Dot" 
                predict = "." ;
              case "Ddot" 
                predict = ":";
              otherwise 
                predict=l;
            endswitch 
        endif 
        if max_global > 0.85
          break %Si on est sûr du résultat on arrête de chercher
        endif 
      endif 
      
    endfor 
    mot_pred = cstrcat(mot_pred, predict); 
    %info utilisateur
    disp(cstrcat("Caractère : ",num2str(state)," sur ",num2str(tot) ," en ",num2str(time()-sec),"s (eta ",num2str((tot-state)*(time()-sec0)/state),"s)")) 
    state++; 
    sec=time(); 
  endfor 
  mot_pred = cstrcat(mot_pred, "\n"); 
endfor 

%Info utilisateur
disp(cstrcat("Texte extrait de ",fileAdr," en ",num2str(time()-sec0),":\n",mot_pred))