function [ endpoint, sp, ep, numwords ] = voicedetect( vcommand )


%stdetection Uses STE to calculate word boundaries returns StartPoint and
%EndPoint and the number of word utterances based off of energy threshold
%requirements.

%Speech is a random signal and is therefore EXTREMELY difficult to model.
%However, over short time intervals 10-30ms, speech can be considered a
%stationary signal (easier for analysis) because of the physiological
%limits of human speech production.

%This program takes a recorded signal and analyzes it by 64 sample blocks
%corresponding to 8ms intervals.

%random notes: works best when words are spoken loudly and clearly
                %slurred words and quiet voices confuse the program

%       not sure whether or not my microphone is super awesome or my
%       laptop's sound drivers are above average, but recordings are 
%       pretty robust despite my boombox/ihome radio playing music to my
%       side and behind me.
%       it is speculated that the acoustic shields(chair/microphone
%       side covers) attenuates sound signals not directed to the mic

% Added hamming window for short time analysis over 8ms frames



x = vcommand;

Fs = 8000;
N = length(x); % signal length
n = 0:N-1;
ts = n*(1/Fs); % time for signal

%define the window
wintype = 'rectwin';
winlen = floor(Fs*16/1000);
winamp = [0.5,1]*(1/winlen);
winamp = winamp(2);

%generate the window
win = (winamp*(window(str2func(wintype),winlen)))';

%energy calculation
%%
%by kevin
% x2 = x.^2;
% E = winconv(x2,wintype,win,winlen);

%% 
% Modified 05/06/2012
disp('Short Time Energy Analyzed'); 
for i = 1 : N
    if(i<winlen  )
        speech(1:i) = times(x(1:i),win(winlen-i+1:winlen));
        STE(i) = sum(speech(1:i).^2);
%         for j = 1 : i
%             STZC(i) = STZC(i) + ( abs(Sgn(j+1) - Sgn(j)) )*win(winlen-i+1);
%         end
%         STZC(i) = STZC(i)/(2*i);
            
    else
        speech(i-winlen+1:i) = times(x(i-winlen+1:i), win);
        STE(i) = sum(speech(i-winlen+1:i).^2);
%         for j = i-winlen+1 : i
%             if( i+1>N )
%                 break;
%             end
%             STZC(i) =  STZC(i) + ( abs(Sgn(j+1) - Sgn(j)) )*win(j-i+winlen);
%         end
%         STZC(i) = STZC(i)/(2*winlen);
        
    end
end
figure
subplot(211);
plot(vcommand);
% legend(['Window length = ' num2str(win_len)  ' Window type:' str]);
title('The original cry signal');
subplot(212);
plot(STE/max(STE));
title('The STE')
% zc = zerocross(x,wintype,winamp(1),winlen);
% disp('Zero Crossings Calculated'); 
%%
%normalize STE for thresholding
STE = STE/max(STE);

%Threshold variables
%using laptop at home

STEthresh = 0.07;   %energy threshold minimum 
% STEthresh = .025;   %energy threshold minimum 

Tthresh = .14;  %minimum length of syllable 128/7350*8
%                    %eliminates impulse noises.
% STZCthresh = .01;   %zero crossing threshold


%find speech intervals (sig1 =1, where ste threshold is met)
sig1 = zeros(1,N);
for i = 1:N
    if STE(i) >= STEthresh
        sig1(i) = 1;
    else
        sig1(i) = -1;
    end
end
sig2 = zeros(1,N);
%find boundary edges from sign change values in speech interval threshold
sig1(N+1)=0;
for i = 1:N
    if  sig1(i) == sig1(i+1)
        sig2(i) = 0;
    else
        sig2(i) = 1;
    end
end

endpoint = find(sig2>.5);
endpoint = endpoint/8000; %change from samples to seconds

numwords = length(endpoint);
j = mod(numwords,2);
if  j == 1
    endpoint(:,numwords)=[];
    numwords = size(endpoint);
end

%divide boundary points into start and end points
numwords = length(endpoint);
i=1;
j=1;
while i<=numwords
startpoint(j) = endpoint(i);
i = i+2;
j = j+1;
end

i=2;
j=1;
while i<=numwords
stoppoint(j) = endpoint(i);
i = i+2;
j = j+1;
end
%disp('Removing spurious words');
%get rid of spurious words (boundary too short)

% by Kevin
check = stoppoint-startpoint;
check2 = find(check>Tthresh);% position of match element in vector
numwords =length(check2);

i=1;
while i<=numwords
    sp(i) = startpoint(check2(i));
    ep(i) = stoppoint(check2(i));
    i=i+1;
end

endpoint = zeros(2,numwords);
endpoint(1,1:numwords) = sp(1:numwords);
endpoint(2,1:numwords) = ep(1:numwords);

% by Yang
%m=1;
%for l=1:length(startpoint)
%    if stoppoint(l)-startpoint(l)>tthresh
%        sp(m)=startpoint(l);
%        ep(m)=stoppoint(l);
%        m=m+1;
%    end
%end

%by Kevin
% %find speech intervals (sig3 =1, where STZC threshold is met)
% sig3 = zeros(1,N);
% for i = 1:N
%     if STZC(i) >= STZCthresh
%         sig3(i) = 1;
%     else
%         sig3(i) = -1;
%     end
% end
% sig4 = zeros(1,N);
% %find boundary edges from sign change values in speech interval threshold
% sig3(40001)=0;
% for i = 1:N
%     if  sig3(i) == sig3(i+1)
%         sig4(i) = 0;
%     else
%         sig4(i) = 1;
%     end
% end
% 
% endpoint2 = find(sig4>.5);
% endpoint2 = endpoint2/8000; %change from samples to seconds
% 
% numwords2 = length(endpoint2);
% j = mod(numwords2,2);
% if  j == 1
%     endpoint2(:,numwords2)=[];
%     numwords2 = size(endpoint2);
% end
% 
% %divide boundary points into start and end points
% numwords2 = length(endpoint2);
% i=1;
% j=1;
% while i<=numwords2
% startpoint2(j) = endpoint2(i);
% i = i+2;
% j = j+1;
% end
% 
% i=2;
% j=1;
% while i<=numwords2
% stoppoint2(j) = endpoint2(i);
% i = i+2;
% j = j+1;
% end
% disp('Removing spurious words');
% %get rid of spurious words (boundary too short)
% check3 = stoppoint2-startpoint2;
% check4 = find(check3>Tthresh);
% numwords2 =length(check4);
% 
% i=1;
% while i<=numwords2
%     sp2(i) = startpoint2(check4(i));
%     ep2(i) = stoppoint2(check4(i));
%     i=i+1;
% end
% 
% endpoint2 = zeros(2,numwords2);
% endpoint2(1,1:numwords2) = sp2(1:numwords2);
% endpoint2(2,1:numwords2) = ep2(1:numwords2);

disp('Word Boundary points detected');
%start debug
assignin('base','endpoint',endpoint);  %add vcommand to workspace so i can
                                       %manually check output
%assignin('base','endpoint2',endpoint2);
%end debug
end




