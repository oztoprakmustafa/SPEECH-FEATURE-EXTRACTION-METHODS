function [ blocks ] = findBlock( endpoint , numBlock )

%findBlock Divides an utterance into blocks
%   Takes endpoints of an utterance and further subdivides it into
%   endpoints for each block.  The output argument is in terms of discrete
%   samples instead of continuous time.

start = round(endpoint(1,1)*8000);
stop = round(endpoint(2,1)*8000);
wordLen = (stop-start);   %length of word in samples = endpoint-stoppoint
blockLen = round(wordLen/numBlock);      

i = 1;
while i <= numBlock
    blocks(1,i) = start + (i-1)*blockLen;
    blocks(2,i) = start + i*blockLen-1;
    i = i+1;
end


end

