function [f,c] = bark2frq(b,m)
%BARK2FRQ  Convert the BARK frequency scale to Hertz FRQ=(BARK)
%
% Inputs: b  matrix of frequencies in Bark
%         m  mode options
%            'h'   use high frequency correction from [1]
%            'l'   use low frequency correction from [1]
%            'H'   do not apply any high frequency correction
%            'L'   do not apply any low frequency correction
%            'u'   unipolar version: do not force b to be an odd function
%                  This has no effect on the default function which is odd anyway
%            's'   use the expression from Schroeder et al. (1979)
%            'g'   plot a graph
%
% Outputs: f  frequency values in Hz
%          c  Critical bandwidth: d(freq)/d(bark)


persistent A B C E D P Q R S T U V W X Y Z
if isempty(P)
    A=26.81;
    B=1960;
    C=-0.53;
    E = A+C;
    D=A*B;
    P=(0.53/(3.53)^2);
    V=3-0.5/P;
    W=V^2-9;
    Q=0.25;
    R=20.4;
    xy=2;
    S=0.5*Q/xy;
    T=R+0.5*xy;
    U=T-xy;
    X = T*(1+Q)-Q*R;
    Y = U-0.5/S;
    Z=Y^2-U^2;
end
if nargin<2
    m=' ';
end
if any(m=='u')
    a=b;
else
    a=abs(b);
end
if any(m=='s')
    f=650*sinh(a/7);
else
    if any(m=='l')
        m1=(a<2);
        a(m1)=(a(m1)-0.3)/0.85;
    elseif ~any(m=='L')
        m1=(a<3);
        a(m1)=V+sqrt(W+a(m1)/P);
    end
    if any(m=='h')
        m1=(a>20.1);
        a(m1)=(a(m1)+4.422)/1.22;
    elseif ~any(m=='H')
        m2=(a>X);
        m1=(a>U) & ~m2;
        a(m2)=(a(m2)+Q*R)/(1+Q);
        a(m1)=Y+sqrt(Z+a(m1)/S);
    end
    f=(D*(E-a).^(-1)-B);
end
if ~any(m=='u')
    f=f.*sign(b);          % force to be odd
end
if nargout>1
    [bx,c] = frq2bark(f,m);
end
if ~nargout || any(m=='g')
    [bx,c] = frq2bark(f,m);
    subplot(212)
    semilogy(b,c,'-r');
    ha=gca;
    xlabel('Bark');
    ylabel(['Critical BW (' yticksi 'Hz)']);
    subplot(211)
    plot(b,f,'x-b');
    hb=gca;
    xlabel('Bark');
    ylabel(['Frequency (' yticksi 'Hz)']);
    linkaxes([ha hb],'x');
end