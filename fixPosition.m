function [positions] = fixPosition(positions)

for a = [2:length(positions)]
   
    if positions(a)-positions(a-1) < (-5)
        positions(a:end) = positions(a:end)+positions(a-1)-positions(a);
    elseif positions(a)-positions(a-1) > 5
        positions(a:end) = positions(a:end)-positions(a)+positions(a-1);
    else
        continue
    end % end if statements 
end % end for loop 

end