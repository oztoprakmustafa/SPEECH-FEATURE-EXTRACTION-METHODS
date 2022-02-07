function [ codeword ] = findLPC( blocks,numBlock,vcommand,codeword )

%findLPC Extract LPC over each block 
%   Detailed explanation goes here



%           Add "blocks", "numBlock" as input to do feature extract frame
%           by frame, and using the averaged frame feature as block feature
%           coefficients.

%init loop variable
i = 1;
%init array


while i <= numBlock
    %start/stop point of blocks
    astart = blocks(1,i);
    bend = blocks(2,i);
  
    tempblock = vcommand(astart:bend);
    z=enframe(tempblock,triang(128),64);
    [r c]=size(z);
    j=1;
    while j<=r
        LPCBlock(j,:) = lpc(z(j,:),10); %generate 14th order LPC over 8ms frame
        %tempvect(1:10,j) = LPCBlock(2:11);
        tempvect(j,:) = poly2rc(LPCBlock(j,:));
        %tempvect(1:10,j) = poly2lsf(LPCBlock);
        j = j+1;
    end
    if r==1
        codeword(i,:) = tempvect;
    else
        codeword(i,:) = mean(tempvect);
    end
    %codeword(1:12,i) = mean(transpose(tempvect));
    i = i+1;
end
%codeword = codeword(1:12,1:15);
% codeword = codeword(1:numBlock,1:10);
%assignin('base','codeword',codeword);
end


