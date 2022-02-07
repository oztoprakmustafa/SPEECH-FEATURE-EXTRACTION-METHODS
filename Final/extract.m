clc
clear
close all
[v_orig,F] =audioread('M03.wav');
Voice=v_orig(:,1)';

%downsample F
fs=8000;
Voice=resample(Voice,fs,F);

[endpoint,sp,ep,nw]= voicedetect(Voice);
VV=[];
for i=1:nw
    
    VT = Voice(sp(i)*fs:ep(i)*fs);
    VV=[VV VT];
    
end
L=length(VV);
WL=160;
NB=floor(L/WL);
%%
blocks = zeros(2,NB);
for i=1:NB
   
    blocks(1,i)=1+(i-1)*WL;
    blocks(2,i)=i*WL;
end
%%
[LPC]=findLPC(blocks,NB,VV,[]);
[LPCC]=findLPCC(blocks,NB,VV,[]);
[MFCC]=findMFCC(VV,blocks,NB,fs,12,128,18);
[BFCC]=findBFCC(VV,blocks,NB,fs,12,128,18);


%%
NNB=NB;
figure
XX=1:NNB;
YY=1:10;
ZZ=LPC(XX,:)';
surf(XX,YY,ZZ);
title('LPC')
%%
figure
XX=1:NNB;
YY=1:10;
ZZ=LPCC(XX,:)';
surf(XX,YY,ZZ);
title('LPCC')
%%
figure
XX=1:NB;
YY=1:12;
surf(XX,YY,MFCC');
title('MFCC')
%%
figure
XX=1:NNB;
YY=1:12;
ZZ=BFCC(XX,:)';
surf(XX,YY,ZZ);
title('BFCC')