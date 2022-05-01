% script vyzaduje nasledujici funkce: 
% 1. fce 
% 2. fce_jednotlive_cevy
% 3. fce_kontrola
% 4. fce_median_cevy
% 5. fce_tloustka
% dale je potreba nastavit CESTU pro slozky s daty !!!
% ===================
% priznaky, uceni a testovani trva > 932.967342 seconds.
% nasledna klasifikace pro 1 obrazek trva > 216.391415 seconds seconds.
clear all
clc
warning("off","all"); % (warning vyskakuje pri postupnem vyplneni tabulky)
%%
tic
q = 0;
f = waitbar(q,"Bude to chvili trvat ... ");
%% pred spustenim nastavit tri slozky ~\clasified ~\images  a ~\manual1 :
listing_Evy = dir("C:\Users\START\Desktop\PROJ ABO\vessels_classification_HRF\clasified");
listing_images = dir("C:\Users\START\Desktop\PROJ ABO\vessels_classification_HRF\images");
listing_bin = dir("C:\Users\START\Desktop\PROJ ABO\vessels_classification_HRF\manual1");
% listing_dont_care = dir("C:\Users\START\Desktop\PROJ ABO\vessels_classification_HRF\mask");

% listing_Evy(3:8).name;
% listing_images(42:47).name
% listing_bin(42:47).name
%% vyplnovani tabulky T s priznaky 

% indexovani = {};
T = table('Size',[0 13],'VariableTypes',{'double','double','double','double', 'double','uint8','double','double','double','double','double','double','double'},'VariableNames',{'lum1','light1','med_lum', 'mean_lum' , 'mean_light','vysl','tloustka','lum_perc90','light_perc90','light_perc10','lum_perc10','std_light','std_lum'});
% tic Elapsed time is 201.913078 seconds.
N = 5;
for i = 1:N
    % !!! pokud se budou pridavat nebo mazat data v slozkach - zmenit
    % indexpvani zde ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
    raz = fullfile(listing_Evy(1).folder,(listing_Evy(8+i).name));
    dva = fullfile(listing_images(1).folder,(listing_images(41+i).name));
    tri = fullfile(listing_bin(1).folder,(listing_bin(41+i).name));
[med_lum, mean_lum , mean_light,lum1,light1, obsh, vysl,skel,tloustka_cev_obr,lum_perc90,light_perc90, light_perc10,lum_perc10,std_light,std_lum]= fce(raz, dva, tri);


light_perc10= light_perc10(:);
lum_perc10 = lum_perc10(:);
std_light = std_light(:);
std_lum = std_lum(:);
light_perc90 = light_perc90(:);
lum_perc90 = lum_perc90(:);
med_lum = med_lum(:);
mean_lum = mean_lum(:);
mean_light = mean_light(:);
tloustka_cev_obr = tloustka_cev_obr(:);
lum1 = lum1(:);
light1 = light1(:);
vysl = vysl(:);

C = [length(med_lum~=0); length(mean_lum~=0); length(mean_light~=0); length(tloustka_cev_obr~=0) ];
C_cell = {med_lum~=0; mean_lum~=0; mean_light~=0; tloustka_cev_obr~=0 };
[M,I] = min(C);
nenul = find(C_cell{I(1)});

light_perc10= light_perc10(nenul);
lum_perc10 = lum_perc10(nenul);
std_light = std_light(nenul);
std_lum = std_lum(nenul);
light_perc90 = light_perc90(nenul);
lum_perc90 = lum_perc90(nenul);
lum1 = lum1(nenul);
light1 = light1(nenul);
med_lum = med_lum(nenul);
mean_lum = mean_lum(nenul);
mean_light = mean_light(nenul);
vysl = vysl(nenul);
tloustka_cev_obr = tloustka_cev_obr(nenul);


sz = length(med_lum(:));


T.med_lum((i-1)*sz+1:sz*i) = med_lum(:);
T.mean_lum ((i-1)*sz+1:sz*i) = mean_lum(:);
T.mean_light((i-1)*sz+1:sz*i)  = mean_light(:);
T.vysl ((i-1)*sz+1:sz*i) = vysl(:);
T.tloustka((i-1)*sz+1:sz*i) = tloustka_cev_obr(:);
T.lum1 ((i-1)*sz+1:sz*i) = lum1(:);
T.lum_perc90((i-1)*sz+1:sz*i) = lum_perc90(:);
T.light_perc90((i-1)*sz+1:sz*i) = light_perc90(:);
T.light1((i-1)*sz+1:sz*i) = light1(:);

T.light_perc10((i-1)*sz+1:sz*i)= light_perc10(:);
T.lum_perc10((i-1)*sz+1:sz*i) = lum_perc10(:);
T.std_light((i-1)*sz+1:sz*i) = std_light(:);
T.std_lum((i-1)*sz+1:sz*i) = std_lum(:);

q = q + (0.5/N);
waitbar(q,f,["pro " + num2str(i) + "/" + num2str(N) + " obrazku jsou vytvorene priznaky"]);
end



%% rozdeleni testovacich a trenovacich dat
% vysledek : dataTest a dataTrain
cv = cvpartition(height(T),'HoldOut',0.3);
idx = cv.test;
dataTest=T(idx,:);
dataTrain=T(~idx,:);
q = q + 0.1;
waitbar(q,f,"Data jsou rozdelene pro testovani a trenovani ... ");
%% trenovani, testovani random forest
% tic  
ResponseVarName = 'vysl';

% Mdl = fitcnb(dataTrain,ResponseVarName) ;
% Yfit = predict(Mdl,dataTest);
% q = q + 0.1;
% waitbar(q,f,"fitcnb model je vytvoren ... ");

treeBag = TreeBagger(100,dataTrain,ResponseVarName);
Yfit = predict(treeBag,dataTest);
q = q + 0.1;
waitbar(q,f,"Random forest model je vytvoren ... ");

% toc
%% accuracy pro jednotlive pixely, neni to konecna accuracy. na obrazku je potreba uprava, aby kusy cev obsahovali jen jeden typ pixelu
% tic
R = dataTest.vysl;
RR = [];
for x = 1:length(Yfit)
    pom = Yfit(x,1);
    pomo = pom{1};
RR(x,1) = str2double(pomo);
end
rr = find(R==0);
R(rr)=[];
RR(rr)=[];
porovnani = R==RR;
disp(["accuracy of model pixel classification before median = " + 100*(sum(porovnani)/length(Yfit)) + "%"]);
toc

%% predtim jsme ucili a trenovali trees na jednotlive pixely, ted chci videt vysledek jako obrazek na naucene drive siti. bereme 1_dr(neucil se na tom ani netestoval):
tic
s = 3;
[med_lum, mean_lum , mean_light,lum1,light1, obsh, vysl,skel,tloustka_cev_obr,lum_perc90,light_perc90, light_perc10,lum_perc10,std_light,std_lum] = fce( fullfile(listing_Evy(1).folder,(listing_Evy(s).name)), fullfile(listing_images(1).folder,(listing_images(s).name)), fullfile(listing_bin(1).folder,(listing_bin(s).name)));

sz = length(med_lum(:));
T_posledni = table('Size',[0 12],'VariableTypes',{'double','double','double','double', 'double','double','double','double','double','double','double','double'},'VariableNames',{'lum1','light1','med_lum', 'mean_lum' , 'mean_light','tloustka','lum_perc90','light_perc90','light_perc10','lum_perc10','std_light','std_lum'});

T_posledni.med_lum(1:sz)  = med_lum(:);
T_posledni.mean_lum (1:sz)  = mean_lum(:);
T_posledni.mean_light(1:sz)   = mean_light(:);
T_posledni.tloustka(1:sz)   = tloustka_cev_obr(:);
T_posledni.lum_perc90(1:sz) = lum_perc90(:);
T_posledni.light_perc90(1:sz) = light_perc90(:);
T_posledni.lum1 (1:sz) = lum1(:);
T_posledni.light1(1:sz) = light1(:);

T_posledni.light_perc10(1:sz)= light_perc10(:);
T_posledni.lum_perc10(1:sz) = lum_perc10(:);
T_posledni.std_light(1:sz) = std_light(:);
T_posledni.std_lum(1:sz) = std_lum(:);

% predikce:
Yfit2 = predict(treeBag,T_posledni);
%  Yfit2 = predict(Mdl,T_posledni);

% detekovane pixely naskladame nazpet do podoby obrazku(D) :
RR = [];
for x = 1:length(Yfit2)
    pom = Yfit2(x,1);
    pomo = pom{1};
RR(x) = str2double(pomo);
end

D = reshape(RR,1168,1752);
q = q + 0.1;
waitbar(q,f,"Predikce obrazku probehla, posledni upravy ... ");

%% uprava, aby kusy cev obsahovali jen jeden class (byla pouzita hodnota mode)
% viz fce_median_cevy

[~,~,~,B] = fce_median_cevy(obsh, D);
x = isnan(B);
B(x)=0;
%% pro zobrazeni naseho vysledku a _Eva dat 1 do if:
if 1
figure()
RGB = label2rgb(B,'jet');
RGB2 = label2rgb(vysl,'jet');
imshowpair(RGB,RGB2,"montage");
title("Zleva - nase klasifikace, zprava - hotove data pro porovnani vysledku.");
end
%% vypisuje procento spravne a spatne detekovanych pixelu
% (pixelu v skeletu, tloustka cevy neni brana v potaz, lze ji umele zmenit
% bez zlepseni ucinnosti klasifikace)
vysl_skel = double(vysl).*double(skel);
obr_skel = double(B).*double(skel);
[spravne, spatne] = fce_kontrola(obr_skel, vysl_skel);
disp(["spravne = " + num2str(( spravne/(spravne+spatne)*100 )) + " %"]);
disp(["spatne = " + num2str((  spatne/(spravne+spatne) *100)) + " %"]);

disp(["spravne = " + num2str(spravne) + " px"]);
disp(["spatne = " + num2str(spatne) + " px"]);
toc
waitbar(1,f,"Hotovo! ");