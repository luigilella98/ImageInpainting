


%Candidati: Di Alessio Federico (n.9), Etere Giacomo (n.8), Lella Luigi (n.7)

%Questo codice funzione sia con immagini a colori che in scala di grigi


clc;
clear all;
close all;


%% caricamento immagini
Aorig = imread('parrot.png');  %carico l'immagine (in scala di grigi o a colori)
Aorig = imnoise(Aorig);
mask = imread('parrot-mask.png'); %carico la maschera
subplot(1,2,1);
imshow(Aorig); %Mostro l'immagine da ricostruire
Vera_col = imread('parrotrue.png');   %Carico l'immagine vera senza il danno con la quale confronterò il risultato finale
cap= sprintf('Foto originale');
title(cap, 'FontSize', 14);
drawnow;


A = double(Aorig);
B = double(Aorig);  %creo un'ulteriore matrice dell'immagine di partenza al fine di poterne conservare i valori


[m,n,c] = size(A); %calcolo le dimensioni della matrice A


if(c==1)    %se abbiamo immagine in scala di grigi
  Vera = rgb2gray(Vera_col);   %immagine vera in scala di grigi
  Vera = double(Vera);
end

if(c==3)    %se abbiamo immagine a colori
  Vera = double(Vera_col);
end
  

PSNR_iniziale = psnr(A,Vera,255) %Calcolo del PSNR; espressO in dB;


Anext = double(A);

%% parametri di stabilità
ht = 0.4;
hx = 1;  %i pixel hanno larghezza 1
lambda = 0.5;
r = (ht*lambda)/hx^2;
tfin = 800;  %sulla basa di questo termine e l'ht determiniamo il numero di iterazioni del sistema
A = A.*(mask>0);  %Condizioni al contorno
d = 0;



%% Evoluzione nel tempo dell'equazione del calore


for t=0:ht:tfin %time advance
    for j=2:n-1 %go through the pixels, but avoiding the boundary ones
        for i=2:m-1
            if(mask(i,j)==0)
                
                if(c==1)
                    Anext(i,j)=A(i,j)+r*(A(i,j+1)+A(i+1,j)+A(i,j-1)+A(i-1,j)-4*A(i,j));
                end
                if(c==3)
                    Anext(i,j,1)=A(i,j,1)+r*(A(i,j+1,1)+A(i+1,j,1)+A(i,j-1,1)+A(i-1,j,1)-4*A(i,j,1));
                    Anext(i,j,2)=A(i,j,2)+r*(A(i,j+1,2)+A(i+1,j,2)+A(i,j-1,2)+A(i-1,j,2)-4*A(i,j,2));
                    Anext(i,j,3)=A(i,j,3)+r*(A(i,j+1,3)+A(i+1,j,3)+A(i,j-1,3)+A(i-1,j,3)-4*A(i,j,3));
                end
                
            end
            
            if(mask(i,j)~=0)
                if(c==1)
                    Anext(i,j) = A(i,j)+r*(A(i,j+1)+A(i+1,j)+A(i,j-1)+A(i-1,j)-4*A(i,j)) + ht.*(B(i,j)-A(i,j));
                end
                
                if(c==3)
                    Anext(i,j,1) = A(i,j,1)+r*(A(i,j+1,1)+A(i+1,j,1)+A(i,j-1,1)+A(i-1,j,1)-4*A(i,j,1)) + ht.*(B(i,j,1)-A(i,j,1));
                    Anext(i,j,2) = A(i,j,2)+r*(A(i,j+1,2)+A(i+1,j,2)+A(i,j-1,2)+A(i-1,j,2)-4*A(i,j,2)) + ht.*(B(i,j,2)-A(i,j,2));
                    Anext(i,j,3) = A(i,j,3)+r*(A(i,j+1,3)+A(i+1,j,3)+A(i,j-1,3)+A(i-1,j,3)-4*A(i,j,3)) + ht.*(B(i,j,3)-A(i,j,3));
                end
                
                
            end
        end
    end
    
    
    
    
    
    
    
    A=Anext;
    
    
    
    subplot(1,2,2);
    imshow(uint8(A),[0,256]);
    cap= sprintf('Numero di iterazioni = %d ', d);
    d=d+1;
    title(cap, 'FontSize', 14);
    drawnow;
    
    
end


%% calcolo del PSNR


PSNR_finale = psnr(A,Vera,255); %Calcolo del PSNR; espressO in dB;
display(PSNR_finale);


%% calcolo della chi_quadro

if(c==1)  %l'implementazione del chi_quadro è valida solo per immagini in scala di grigi
    
    mean=0;
    counter=0;
    for j=1:n
        for i=1:m
            if(mask(i,j)==0)
                mean=mean+ Vera(i,j);
                counter=counter+1;
            end
        end
    end
    
    mean=mean/counter;  %MEDIA dei pixel nella regione da ricostruire ;
    
    sigma_2=0;
    for j=1:n
        for i=1:m
            if(mask(i,j)==0)
                
                sigma_2=  sigma_2+ ( Vera(i,j)- mean)^2;
            end
        end
    end
    
    sigma_2= sigma_2/(counter-1);  %varianza nella regione da ricostruire;
    display(sigma_2);
    
    
    chi_quadro=0;
    for j=1:n
        for i=1:m
            if(mask(i,j)==0)
                chi_quadro=  chi_quadro + (A(i,j) - Vera(i,j))^2;
            end
        end
    end
    chi_quadro= chi_quadro/(counter*sigma_2);  %chi quadro;
    display(chi_quadro);
    
end




 
 
 
 
 













