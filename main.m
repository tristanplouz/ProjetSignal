clear all; 
%close all; 
warning off

% Import libraries 
%graphics_toolkit gnuplot 
pkg load signal 
pkg load image
pkg load matgeom

%Préparation des images
function res=picPrep(pic) 
  pic=rgb2gray(pic); % Transform to gray scale 
  pic=im2double(pic);% Transform to double data 
  res=pic-mean(mean(pic));% Signal à valeur moyenne nulle 
endfunction 
%Si la tuile est vide il s'agit d'un espace
function res=checkEmptyTile(tile) 
  if abs(abs(min(min(tile))/mean(mean(tile)))-1)<10^-5 %Seuil à regler
    res=true;
  else
    res=false;
  endif
endfunction
%Détecte et supprime les marges du document à analyser
function res=withoutMargin(file) 
  A=mean(file);
  %On cherche la première colonne non vide
  for i=1:length(A)-1
    if A(i)~=A(i+1)
      xmin=i;
      break
    endif
  endfor
  %On cherche la dernière colonne non vide
  for i=length(A)-1:-1:1
    if A(i)~=A(i-1)
      xmax=i;
      break
    endif
  endfor
  
  A=mean(file');
  %On cherche la première ligne non vide
  for i=1:length(A)-1
    if A(i)~=A(i+1)
      ymin=i;
      break
    endif
  endfor
  %On cherche la dernière ligne non vide
  for i=length(A)-1:-1:1
    if A(i)~=A(i-1)
      ymax=i;
      break
    endif
  endfor
  res=[ymin,ymax,xmin,xmax];
endfunction
%Compte le nombre de caractères d'une ligne
function [res,B]=countCaracLine(mot)  
  a=b=0;
  A=mean(mot);
  A(A>min(A)/2)=200;
  B=[A;A;A;A;A;A;A;A;A;A;A;A;A;A;A;A];
  xprec=x=eprec=0;
  for i=10:length(A)-15
    if A(i)>100+A(i-1)%Détection d'un saut de valeur
      if i-xprec>0.85*eprec
        a+=1;
        eprec=i-xprec;
        xprec=i;
      elseif i-xprec>1.9*eprec
        a+=2;
        eprec=i-xprec;
        xprec=i;
      else
        eprec=i-xprec;
        xprec=i;
      endif
    endif
  endfor
  res=a;
endfunction
%Compte le nombre de caractères d'une ligne
function [res,C]=countLine(mot)
 a=0;
  A=mean(mot');
  A(A>min(A)/2)=200;
  C=[A' A' A' A'];
  yprec=y=eprec=0;
  for i=15:length(A)-15
    if A(i)>A(i-1)+10
      if i-yprec>0.85*eprec
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
  if A(i)==200
  res=a+1;
  else
   res=a;
  endif
endfunction

function res=detectBgColor(file)
  color{1}{1}=[0,0,0];
  color{1}{2}=0;
  for i=1:10:length(file(:,1,1))-1
    for j=1:10:length(file(1,:,1))-1
      ctmp=[file(i,j,1),file(i,j,2),file(i,j,3)];
      p=0;
      for a=1:length(color)
        if color{a}{1} == ctmp
          color{a}{2}++;
          p=1;
          break;
        else
          p=0;
        endif
      endfor
      if p==0
        color{end+1}{1}=ctmp;
        color{end}{2}=1;
      endif
    endfor
  endfor
  res=color;
endfunction
%Interface utilisateur Chargement fichier
while (1)
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

if yes_or_no("Le texte foncé sur fond clair?"); %Demande de la gamme de couleur pour adaptation 
  fileI=255-file; %On veut toutes les images en fond foncé et écriture claire
else
  fileI=file;  
endif

figure(1) 
imshow(file)

fileG=picPrep(fileI);%Prépare le fichier
coor=withoutMargin(fileG);%Retire les marges
try
  mot=fileG(-5+coor(1):coor(2)+5,-5+coor(3):coor(4)+5);
catch
  mot=fileG(coor(1):coor(2),coor(3):coor(4));
end_try_catch
figure(2) 
imshow(mot) 
figure(3) 
imshow(fileG)
%Calcul du nombre de caractères
[nb_carac_line,b]=countCaracLine(mot);
nb_carac_col=countLine(mot);
tot=nb_carac_line*nb_carac_col; 
state=1; 

%Définition des pas de recherche
dx_search = length(mot(1,:))/(nb_carac_line); 
dy_search = length(mot(:,1))/nb_carac_col; 

%Affichage du découpage en tuile
##figure(1)
##hold on;
##imshow(mot)
##imshow(b)
##for i=0:nb_carac_line-1
##  for k=0:nb_carac_col-1
##    drawRect([i*dx_search-3 k*dy_search-3  dx_search+3 dy_search+3]);
##  endfor
##endfor
##hold off
##saveas(figure(1),"Rapports/illus/tuilesDUDH.png");

data=glob("alphabet/*.png");%Import des adresses de motif de l'alphabet 
if rep=yes_or_no("Le texte contient uniquement des majuscules?");  
  data=data(47:end); %On importe que les majuscules et la ponctuation
endif

hypert=false;

if rep=yes_or_no("Sortie fichier HTML (Si non, sortie console)?");  
 hypert=true;
 color=detectBgColor(file);
 colormax=[0,0];
  for i=1:length(color)
    if color{i}{2}>colormax(1)
      colormax(1)=color{i}{2};
      colormax(2)=i;
    endif
  endfor
  colorBG=color{colormax(2)}{1};
  disp("Couleur de fond:")
  disp(colorBG)
 endif
 
disp("Nombre de caractère détecté:")
disp(tot)
disp("Caractère par ligne:")
disp(nb_carac_line)
disp("Nombre de ligne:")
disp(nb_carac_col)

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
%Information Utilisateur
disp("Éléments chargés en ")
disp(strcat(num2str(time()-sec),"s"))
disp("Facteur d'échelle:")
disp(scam)
disp("Début de l'analyse...")
sec=time();
mot_pred = "\n"; 

for j=1:nb_carac_col %Pour chaque ligne
%Calcul des dimensions en y de la tuile
  ymin=dy_search*(j-1)-5; 
  ymax=dy_search*(j-1)+dy_search+5; 
  
  if ymax>length(mot(:,1)) 
    ymax=length(mot(:,1)); 
  elseif ymin<1 
    ymin=1; 
  endif 
  
  for i=1:nb_carac_line %Pour chaque caractère de la ligne
%Réinitialisation des paramètres de recherche
    max_global=0; 
    predict=""; 
    alrChk=false;
    
%Calcul des dimensions en x de la tuile 
    xmin=dx_search*(i-1)-3; 
    xmax=dx_search*(i-1)+dx_search+3; 
    if xmax>length(mot(1,:)) 
      xmax=length(mot(1,:)); 
    elseif xmin<1 
      xmin=1; 
    endif 

    tile = mot(ymin:ymax,xmin:xmax);%Création de la tuile
    if hypert
      tilec=file(coor(1)+ymin:coor(1)+ymax-4,coor(3)+xmin:coor(3)+xmax,:);
##      figure(4)
##      imshow(tilec)
      clear colorT
      colorT{1}{1}=colorBG;
      colorT{1}{2}=0;
      for i=1:5:length(tilec(:,1,1))-1
        for j=1:5:length(tilec(1,:,1))-1
          ctmp=[tilec(i,j,1),tilec(i,j,2),tilec(i,j,3)];
          p=0;
          for a=1:length(colorT)
            if colorT{a}{1} == ctmp
              colorT{a}{2}++;
              p=1;
              break;
            else
              p=0;
            endif
          endfor
          if p==0
            colorT{end+1}{1}=ctmp;
            colorT{end}{2}=1;
          endif
        endfor
      endfor
      colormax=[0,1];
      for i=1:length(colorT)
        if colorT{i}{2}>colormax(1)
          if colorT{i}{1}==colorBG
            colormax(1);
          else
            colormax(1)=colorT{i}{2};
            colormax(2)=i;
          endif
        endif
      endfor
      colorL=colorT{colormax(2)}{1};
    endif
    rapT=colorT{colormax(2)}{2}/colorT{1}{2};
    kech=0;
    
    mt=mean(tile)(1:end);
    a=2;
    while(mt(a-1)>=mt(a))
      a++;
      if a>length(mt)*9/10
        a=0;
        break
      end
    endwhile
     [c,d]=max(mt);
     vIt=(d-a)/c
     it=false;
     if ((vIt>38 &&vIt<130) ||(vIt>188 &&vIt<280) ||(vIt>720 && vIt<830))
       for h=1:length(tile)-1
        tile(end-h,:)=[tile(end-h,1+round(h*length(tile(1,:))/(length(tile)*4.1)):end) tile(end-h,1:round(h*length(tile(1,:))/(length(tile)*4.1)))];
        it=true;
       endfor
       tile(:,8.5*length(tile(1,:))/10:end)=min(min(tile));
       tile=[tile(:,8.5*length(tile(1,:))/10:end) tile(:,1:8.5*length(tile(1,:))/10)];
       tile(:,1:1.5*length(tile(1,:))/10)=min(min(tile));
     endif
    for k=1:length(alpha) 
      %Chargement des motifs 
      ech=cell2mat(alpha{k}(1));
      if alrChk == false
        if checkEmptyTile(tile) %Si la tuile est vide on défini un espace et on break
          predict=" ";
          break
        endif
        alrChk=true;
      endif
      
%Display échantillon 
##      figure(2); 
##      imshow(ech); 

      
%Intercorrelation  
      hold off
      d=normxcorr2(ech,tile);  
 
%Display correlation
##      figure(4); 
##      colormap("jet"); 
##      surf(d,"edgecolor","none") 
##      saveas(figure(3),"Rapports/illus/tuilev.png");
##      saveas(figure(2),"Rapports/illus/2echv.png");
##      saveas(figure(4),"Rapports/illus/2corv.png");

      max_local=max(max(d(length(d)*1.2/4:end,length(d(:,1))/9:8*length(d(:,1))/9))); 
      if max_local > max_global 
%Chargement de la lettre echantillon
        l=char(alpha{k}(2));
        kech=k;
        max_global = max_local;
        if max_global < 0.55
           predict = " "; 
        else 
            switch l 
              case "Qdot" 
                if predict==""
                  predict = "?";
                endif
            case "Ap" 
              if predict==""
                predict = "'";
                endif
            case "Vir" 
              if predict==""
                predict = ",";
                endif
            case "Vdot" 
              if predict==""
                predict = ";";
                endif
            case "Tir" 
              if predict==""
                predict = "-";
                endif
            case "Edot" 
              if predict==""
                predict = "!";
                endif
          case "Dot" 
              if predict==""
                predict = "." 
                endif
            case "Ddot" 
              if predict==""
                predict = ":";
                endif
              otherwise 
                predict=l;
            endswitch 
        endif 
        if max_global > 0.9
          switch predict
            case 'v'
            case 'n'
            case '.'
            case ','
            case ';'
            case 'o'
            otherwise 
                break
          endswitch 
        endif 
      endif 
      
    endfor 
    if hypert
      if kech!=0
      ech=cell2mat(alpha{kech}(1));
      ech=ech(:,end/3:2*end/3);
      clear colorE
      colorE{1}{1}=0;
      colorE{1}{2}=0;
      for i=1:5:length(ech(:,1,1))-1
        for j=1:5:length(ech(1,:,1))-1
          p=0;
          for a=1:length(colorE)
            if colorE{a}{1} == ech(i,j)
              colorE{a}{2}++;
              p=1;
              break;
            else
              p=0;
            endif
          endfor
          if p==0
            colorE{end+1}{1}=ech(i,j);
            colorE{end}{2}=1;
          endif
        endfor
      endfor
    else 
      G=0;
    endif
      rapE=colorE{3}{2}/colorE{2}{2};
      G=rapT/rapE
      if it && G > 0.63 && G < 10
        if predict=="A" && vIt>250
          predict=cstrcat("<em style='color:rgb(",num2str(colorL(1)),",",num2str(colorL(2)),",",num2str(colorL(3)),");'>",predict,"</em>");
        elseif predict=="A" && vIt<250
          predict=cstrcat("<strong style='color:rgb(",num2str(colorL(1)),",",num2str(colorL(2)),",",num2str(colorL(3)),");'>",predict,"</strong>");
          else 
          predict=cstrcat("<em><strong style='color:rgb(",num2str(colorL(1)),",",num2str(colorL(2)),",",num2str(colorL(3)),");'>",predict,"</strong></em>");
        endif
        disp("Gras et italique")
        
      elseif it
        disp("Italique")
        if predict=="Y" && vIt<110
          predict=cstrcat("<span style='color:rgb(",num2str(colorL(1)),",",num2str(colorL(2)),",",num2str(colorL(3)),");'>",predict,"</span>");
        else
          predict=cstrcat("<em style='color:rgb(",num2str(colorL(1)),",",num2str(colorL(2)),",",num2str(colorL(3)),");'>",predict,"</em>");
        endif
        it=false;
      elseif  G > 0.63 && G < 10
        disp("Gras")
        if predict=="I" && G<0.875
          predict=cstrcat("<span style='color:rgb(",num2str(colorL(1)),",",num2str(colorL(2)),",",num2str(colorL(3)),");'>",predict,"</span>");
        else
          predict=cstrcat("<strong style='color:rgb(",num2str(colorL(1)),",",num2str(colorL(2)),",",num2str(colorL(3)),");'>",predict,"</strong>");
        endif
      else
        predict=cstrcat("<span style='color:rgb(",num2str(colorL(1)),",",num2str(colorL(2)),",",num2str(colorL(3)),");'>",predict,"</span>");
      endif
      mot_pred = cstrcat(mot_pred, predict);
    else
    mot_pred = cstrcat(mot_pred, predict); 
    endif
    %info utilisateur
    disp(cstrcat("Caractère : ",num2str(state)," sur ",num2str(tot) ," en ",num2str(time()-sec),"s (eta ",num2str((tot-state)*(time()-sec0)/state),"s)")) 
    state++; 
    sec=time(); 
  endfor 
  if hypert
      mot_pred = cstrcat(mot_pred, "<br>"); 
    else
    mot_pred = cstrcat(mot_pred, "\n"); 
    endif
  
endfor 

if hypert
  

  page=cstrcat("<!DOCTYPE html><html><head><title>Texte créé par le script de décodage d'image</title><style>body{font-size:",num2str(dx_search*0.75),"px;color:white;background:rgb(",num2str(colorBG(1)),",",num2str(colorBG(2)),",",num2str(colorBG(3)),");}</style></head><body>",mot_pred,"</body></html>");
 
  fid=fopen ("output.html", "w");
  fputs(fid,page);
  disp("Texte décodé et sauvegardé dans output.html")
else
  %Info utilisateur
  disp(cstrcat("Texte extrait de ",fileAdr," en ",num2str(time()-sec0),":\n",mot_pred))
endif

%Ait(end-i,:)=[Ait(end-i,1+round(i*71/320):end) Ait(end-i,1:round(i*71/320))];

