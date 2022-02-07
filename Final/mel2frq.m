function [frq,mr] = mel2frq(mel)
%MEL2FRQ  Convert Mel frequency scale to Hertz FRQ=(MEL)
%    frq = mel2frq(mel) converts a vector of Mel frequencies
%    to the corresponding real frequencies.
%   mr gives the corresponding gradients in Hz/mel.
%    The Mel scale corresponds to the perceived pitch of a tone

%    The relationship between mel and frq is given by [1]:
%
%    m = ln(1 + f/700) * 1000 / ln(1+1000/700)
%
%      This means that m(1000) = 1000
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
persistent k
if isempty(k)
    k=1000/log(1+1000/700); % 1127.01048
end
frq=700*sign(mel).*(exp(abs(mel)/k)-1);
mr=(700+abs(frq))/k;
if ~nargout
    plot(mel,frq,'-x');
    xlabel(['Frequency (' xticksi 'Mel)']);
    ylabel(['Frequency (' yticksi 'Hz)']);
end