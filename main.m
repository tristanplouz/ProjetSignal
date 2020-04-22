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

function res=checkEmptyTile(tile) %Si la tuile est vide il s'agit d'un espace
  %min(min(tile))/abs(mean(mean(tile)))
  if abs(abs(min(min(tile))/mean(mean(tile)))-1)<10^-5 %Seuil à regler
    res=true;
  else
    res=false;
  endif
endfunction

while (1)
  file=input("Adresse du fichier(Laisser vide pour default)","s");
  if isempty(file)  
    mot=imread("lorem2.png");% Import du text à analyser 
    break;
  else
    try 
      mot=imread(file);
      break;
    catch 
      disp("Fichier non trouvé");
    end_try_catch
  endif
endwhile

data=glob("alphabet/*.png");%Import des adresses de motif de l'alphabet 
rep=yes_or_no("Le texte contient uniquement des majuscules?"); 
if rep 
  data=data(37:end); %On importe que les majuscules et la ponctuation
endif

alpha = cell();
for k=1:length(data)
  %On crée un tableau contenant les motifs et la lettre associé, on stocke en mémoire et limite l'accès au disque
  alpha{end+1}={picPrep(imread(data{k})),strsplit(strsplit(data{k},"_"){2},"."){1}};
endfor

mot=picPrep(mot); 

%figure(1) 
%imshow(mot) 

tmp=imread("etalon.png"); 
tmp=picPrep(tmp); 
dy=length(tmp(:,1))/3; 
dx=length(tmp(1,:))/3; 

nb_carac_line=length(mot(1,:))/dx; 

if nb_carac_line-fix(nb_carac_line)>0.8 %Seuil réglé après des tests
  nb_carac_line=ceil(nb_carac_line) 
elseif nb_carac_line-fix(nb_carac_line)<0.01
  nb_carac_line=floor(nb_carac_line)-1
else
  nb_carac_line=floor(nb_carac_line) 
endif 
nb_carac_col =floor(length(mot(:,1))/dy)
tot=nb_carac_line*nb_carac_col; 
state=1; 

dx_search = length(mot(1,:))/nb_carac_line; 
dy_search = length(mot(:,1))/nb_carac_col; 

mot_pred = "\n"; 

for j=1:nb_carac_col 
  %Calcul des dimensions en y de la tuile
  ymin=dy_search*(j-1)-3; 
  ymax=dy_search*(j-1)+dy_search; 
  if ymax>length(mot(:,1)) 
    ymax=length(mot(:,1)); 
  elseif ymin<1 
    ymin=1; 
  endif 
  for i=1:nb_carac_line 
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
        if checkEmptyTile(tile)
          predict=" ";
          break
        endif
        alrChk=true;
      endif
      
      % Display echantillon 
      %figure(2); 
      %imshow(ech); 
      %Display mot 
      %figure(4);  
      %imshow(tile);  
      % Intercorrelation  
      d=normxcorr2(ech,tile);  
      %figure(3); 
      %figure(3); 
      %colormap("jet"); 
      %surf(d,"edgecolor","none") 
       
      % Saving the ech performance 
      max_local=max(max(d)); 
      if max_local > max_global 
        % Chargement de la lettre echantillon
        l=char(alpha{k}(2));
        max_global = max_local;
        if max_global < 0.8 
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
                predict = "."; 
              case "Ddot" 
                predict = ":"; 
              otherwise 
                predict=l;
            endswitch 
        endif 
        if max_global > 0.88
          break %Si on est sûr du résultat on arrête de chercher
        endif 
      endif 
      
    endfor 
    mot_pred = cstrcat(mot_pred, predict); 
    disp(cstrcat("Caractère : ",num2str(state)," sur ",num2str(tot) ," en ",num2str(time()-sec),"s (eta ",num2str((tot-state)*(time()-sec0)/state),"s)")) 
    state++; 
    sec=time(); 
  endfor 
  mot_pred = cstrcat(mot_pred, "\n"); 
endfor 

disp(cstrcat("Texte extrait de ",file," en ",num2str(time()-sec0),":\n",mot_pred))