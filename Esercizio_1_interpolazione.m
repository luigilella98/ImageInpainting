%Candidati: Di Alessio Federico (n.9), Etere Giacomo (n.8), Lella Luigi (n.7)

%Questo codice funzione sia con immagini a colori che in scala di grigi

close all 
clear 
clc

disp('***Inpainting con interpolazione***');
disp('**Scegliere il metodo che si vuole applicare**');
mode = input('Nearest (1), Linear (2), Natural (3)');

switch mode
    case 1
        str_mode = 'nearest';
    case 2
        str_mode = 'linear';
    case 3
        str_mode = 'natural';
end

img = imread('parrotcol.bmp'); % importo immagine rovinata
mask = imread('parrot-mask.png'); % importo maschera
true = imread('parrotrue.png'); % importo immagine per il confronto 

subplot(1,2,1);
imshow(img); %show the original image

    cap= sprintf('Foto originale');
    title(cap, 'FontSize', 14);
    drawnow;

[R,C,D] = size(img); % estraggo righe, colonne e canali dell'immagine
    
rep_img = img.*(uint8(mask>0)); % tolgo la parte del danno

x = double.empty; % vettori con coordinate pixel buoni, inizializzo vuoto
y = double.empty; % non conosco a priori la dimensione

tic

if(D==1)
    v = double.empty; % vettore dei valori corrispondenti
end

if(D==3)
    vR = double.empty; % nel caso di immagine RGB servirà un vettore per canale 
    vG = double.empty;
    vB = double.empty;
end

r = 1; % contatore numero punti "buoni"

% vado ad iterare su tutta la maschera
for i = 1:R
    for j = 1:C
        
        if mask(i,j) == 255 % se il pixel è bianco(non rovinata)
            x(r) = i; % scrivo le coordinate del punto buono
            y(r) = j;
            
            if(D ==1)
                v(r) = img(i,j); % scrivo valore del livello di grigio
            end
            
            if(D == 3)
                vR(r) = img(i,j,1); % scrivo valore canale rosso
                vG(r) = img(i,j,2); % scrivo valore canale verde
                vB(r) = img(i,j,3); % scrivo valore canale blu 
            end
            
            r = r + 1; % incremento l'indice (r arriva al n° di punti buoni)
            
        end
    end
end

x = x'; % traspongo per avere vettore colonna 
y = y';

if(D==1)
    v = v';
end

if(D==3)
    vR = vR';
    vG = vG';
    vB = vB';
end

Cord = [x y]; % unisco in modo da ottenere vettoere rx2 coppie di coordinate

if(D==1)
    SI = scatteredInterpolant(Cord,v, str_mode); % creo oggetto SI per interpolare
end

if(D==3)
    SIR = scatteredInterpolant(Cord,vR, str_mode); % creo oggetto SI per ogni canale
    SIG = scatteredInterpolant(Cord,vG, str_mode);
    SIB = scatteredInterpolant(Cord,vB, str_mode);
end


for i = 1:R
    
         subplot(1,2,2);
imshow(rep_img); %show the original image

    cap= sprintf('Foto restaurata');
    title(cap, 'FontSize', 14);
    drawnow;
    
    
    
    for j = 1:C
        
        if mask(i,j) == 0  % se il pixel è rovinato
            
            if(D==1)
                rep_img(i,j) = SI(i,j); % lo sostituisco con il suo valore interpolato 
            end
            
            if(D==3)
                rep_img(i,j,1) = SIR(i,j); % sostituisco valore del pixel su ogni canale
                rep_img(i,j,2) = SIG(i,j);
                rep_img(i,j,3) = SIB(i,j);
            end
     
            
        end
    end
end

toc


peak = psnr(rep_img, true);  %calcolo in PSNR
display(peak);

