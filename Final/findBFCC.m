function [BFCC]=findBFCC(s,blocks,numBlock,fs,nc,n,p,w,inc,fl,fh)
% BARKCEPST Calculate the bark cepstrum of a signal BFCC=(S,FS,W,NC,P,N,INC,FL,FH)
%           Add "blocks", "numBlock" as input to do feature extract frame
%           by frame, and using the averaged frame feature as block feature
%           coefficients.
% Simple use: c=melcepst(s,fs)	% calculate mel cepstrum with 12 coefs, 256 sample frames
%				  c=melcepst(s,fs,'e0dD') % include log energy, 0th cepstral coef, delta and delta-delta coefs
%
% Inputs:
%     s	 speech signal
%     fs  sample rate in Hz (default 11025)
%     nc  number of cepstral coefficients excluding 0'th coefficient (default 12)
%     n   length of frame in samples (default power of 2 < (0.03*fs))
%     p   number of filters in filterbank (default: floor(3*log(fs)) = approx 2.1 per ocatave)
%     inc frame increment (default n/2)
%     fl  low end of the lowest filter as a fraction of fs (default = 0)
%     fh  high end of highest filter as a fraction of fs (default = 0.5)
%
%		w   any sensible combination of the following:
%
%				'R'  rectangular window in time domain
%				'N'	Hanning window in time domain
%				'M'	Hamming window in time domain (default)
%
%		      't'  triangular shaped filters in mel domain (default)
%		      'n'  hanning shaped filters in mel domain
%		      'm'  hamming shaped filters in mel domain
%
%				'p'	filters act in the power domain
%				'a'	filters act in the absolute magnitude domain (default)
%
%			   '0'  include 0'th order cepstral coefficient
%				'e'  include log energy
%				'd'	include delta coefficients (dc/dt)
%				'D'	include delta-delta coefficients (d^2c/dt^2)
%
%		      'z'  highest and lowest filters taper down to zero (default)
%		      'y'  lowest filter remains at 1 down to 0 frequency and
%			   	  highest filter remains at 1 up to nyquist freqency
%
%		       If 'ty' or 'ny' is specified, the total power in the fft is preserved.
%
% Outputs:	c     bark cepstrum output: one frame per row. Log energy, if requested, is the
%                 first element of each row followed by the delta and then the delta-delta
%                 coefficients.
%

% BUGS: (1) should have power limit as 1e-16 rather than 1e-6 (or possibly a better way of choosing this)
%           and put into VOICEBOX
%       (2) get rdct to change the data length (properly) instead of doing it explicitly (wrongly)

%     
if nargin<11
   fh=0.5;   
   if nargin<10
     fl=0;
     if nargin<9
        inc=floor(n/2);
     end
  end
end

if nargin<8 
    w='tz'; end
if nargin<7 
    p=floor(3*log(fs)); end
if nargin<6 
    n=pow2(floor(log2(0.03*fs))); end
if nargin<5 
    nc=10; end
if nargin<4 
    fs=11025; end
if nargin<3 
    numBlock=8; end

i=1;
while i <= numBlock
        %start/stop point of blocks
    astart = blocks(1,i);
    bend = blocks(2,i);
        
    tempblock = s(astart:bend);
    
    if length(w)==0
       w='tz';
       z=enframe(tempblock,triang(n),inc);
    end
    if any(w=='R')
       z=enframe(tempblock,n,inc);
    elseif any (w=='N')
       z=enframe(tempblock,hanning(n),inc);
    else
       z=enframe(tempblock,hamming(n),inc);
    end
    f=rfft(z.');
    f = frq2bark(f);
    [m,a,b]=melbankm(p,n,fs,fl,fh,'b');
    pw=f(a:b,:).*conj(f(a:b,:));
pth=max(pw(:))*1E-20;
if any(w=='p')
   y=log(max(m*pw,pth));
else
   ath=sqrt(pth);
   y=log(max(m*abs(f(a:b,:)),ath));
end
c=rdct(y).';
nf=size(c,1);
nc=nc+1;
if p>nc
   c(:,nc+1:end)=[];
elseif p<nc
   c=[c zeros(nf,nc-p)];
end
if ~any(w=='0')
   c(:,1)=[];
   nc=nc-1;
end
if any(w=='e')
   c=[log(sum(pw)).' c];
   nc=nc+1;
end

% calculate derivative

if any(w=='D')
  vf=(4:-1:-4)/60;
  af=(1:-1:-1)/2;
  ww=ones(5,1);
  cx=[c(ww,:); c; c(nf*ww,:)];
  vx=reshape(filter(vf,1,cx(:)),nf+10,nc);
  vx(1:8,:)=[];
  ax=reshape(filter(af,1,vx(:)),nf+2,nc);
  ax(1:2,:)=[];
  vx([1 nf+2],:)=[];
  if any(w=='d')
     c=[c vx ax];
  else
     c=[c ax];
  end
elseif any(w=='d')
  vf=(4:-1:-4)/60;
  ww=ones(4,1);
  cx=[c(ww,:); c; c(nf*ww,:)];
  vx=reshape(filter(vf,1,cx(:)),nf+8,nc);
  vx(1:8,:)=[];
  c=[c vx];
end
 
if nargout<1
   [nf,nc]=size(c);
   t=((0:nf-1)*inc+(n-1)/2)/fs;
   ci=(1:nc)-any(w=='0')-any(w=='e');
   imh = imagesc(t,ci,c.');
   axis('xy');
   xlabel('Time (s)');
   ylabel('Mel-cepstrum coefficient');
	map = (0:63)'/63;
	colormap([map map map]);
	colorbar;
end    
[row col]=size(z);
if row==1
    BFCC(i,:)=c;
else
    c=mean(c);
    BFCC(i,:)=c;
end
i = i+1;
end